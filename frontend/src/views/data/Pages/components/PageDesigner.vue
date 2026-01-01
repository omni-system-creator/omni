<template>
  <div class="page-designer">
    <div class="designer-header">
      <div class="left">
        <a-button type="link" @click="$emit('back')">
          <template #icon><ArrowLeftOutlined /></template>
          返回
        </a-button>
        <span class="page-name">{{ pageData.name }}</span>
      </div>
      <div class="center-toolbar">
        <a-space style="margin-right: 16px">
          <a-tooltip title="撤销 (Ctrl+Z)">
            <a-button :disabled="!canUndo" @click="undo">
              <template #icon><UndoOutlined /></template>
            </a-button>
          </a-tooltip>
          <a-tooltip title="重做 (Ctrl+Y)">
            <a-button :disabled="!canRedo" @click="redo">
              <template #icon><RedoOutlined /></template>
            </a-button>
          </a-tooltip>
          <a-tooltip title="清空设计">
            <a-button :disabled="pageConfig.root.children.length === 0" @click="handleClear">
              <template #icon><ClearOutlined /></template>
            </a-button>
          </a-tooltip>
          <a-tooltip title="删除选中组件 (Del)">
            <a-button :disabled="!selectedId" danger @click="handleDeleteNode(selectedId)">
              <template #icon><DeleteOutlined /></template>
            </a-button>
          </a-tooltip>
          <a-dropdown v-if="pageConfig.root.children.length === 0">
            <template #overlay>
              <a-menu @click="handleInitTemplate">
                <a-menu-item key="data-list">数据列表页面</a-menu-item>
                <a-menu-item key="add-edit">新增/修改页面</a-menu-item>
                <a-menu-item key="view-page">详情查看页面</a-menu-item>
              </a-menu>
            </template>
            <a-button>
              初始化模板
              <DownOutlined />
            </a-button>
          </a-dropdown>
        </a-space>
        <a-radio-group v-model:value="mode" button-style="solid">
          <a-radio-button value="design">设计</a-radio-button>
          <a-radio-button value="script">脚本</a-radio-button>
          <a-radio-button value="css">CSS</a-radio-button>
          <a-radio-button value="json">JSON</a-radio-button>
          <a-radio-button value="preview">预览</a-radio-button>
        </a-radio-group>
      </div>
      <div class="right">
        <a-button @click="handleSave" type="primary">保存</a-button>
      </div>
    </div>
    
    <div class="designer-body">
      <!-- Design Mode: Split Layout for Left Sidebar + Canvas + Right Sidebar -->
      <template v-if="mode === 'design'">
        <div class="design-mode-wrapper">
          <!-- Outer Split: Left Sidebar vs Main Area -->
          <SplitLayout position="left" :initialWidth="260" :minWidth="200" :maxWidth="500">
            <template #sidebar>
              <div class="sidebar left-sidebar-content">
                <a-tabs default-active-key="components" size="small" class="full-height-tabs" :tabBarStyle="{ width: '100%', display: 'flex' }">
                  <a-tab-pane key="components" tab="组件库">
                    <div class="component-list-container">
                      <a-collapse v-model:activeKey="activeGroups" ghost>
                        <a-collapse-panel v-for="(group, idx) in componentGroups" :key="idx" :header="group.title">
                          <div class="component-grid">
                            <div 
                              v-for="item in group.items" 
                              :key="item.type" 
                              class="comp-item" 
                              draggable="true" 
                              @dragstart="onDragStart($event, item)"
                            >
                              {{ item.label }}
                            </div>
                          </div>
                        </a-collapse-panel>
                      </a-collapse>
                    </div>
                  </a-tab-pane>
                  <a-tab-pane key="tree" tab="大纲树">
                    <ComponentTree 
                      :root="pageConfig.root" 
                      :selectedId="selectedId"
                      @select="handleSelect"
                      @node-drop="handleNodeDrop"
                    />
                  </a-tab-pane>
                </a-tabs>
              </div>
            </template>
            
            <template #main>
              <!-- Inner Split: Canvas vs Right Sidebar -->
              <SplitLayout position="right" :initialWidth="300" :minWidth="250" :maxWidth="600">
                <template #main>
                  <div class="visual-canvas" @click="selectedId = ''">
                    <CanvasRenderer 
                      :node="pageConfig.root" 
                      :selectedId="selectedId" 
                      :isRoot="true"
                      @select="handleSelect"
                      @node-drop="handleNodeDrop"
                    />
                  </div>
                </template>
                <template #sidebar>
                  <div class="sidebar right-sidebar">
                    <div class="panel-title">属性设置</div>
                    <div class="panel-content">
                      <PropertyEditor :node="selectedNode" @delete="handleDeleteNode" />
                    </div>
                  </div>
                </template>
              </SplitLayout>
            </template>
          </SplitLayout>
        </div>
      </template>
      
      <!-- Other Modes -->
      <div v-else class="main-area">
        <div v-if="mode === 'script'" class="code-editor-container">
          <CodeEditor 
            v-model:value="pageConfig.script" 
            language="typescript"
            placeholder="// Script content here..."
            theme="dark"
          />
        </div>

        <div v-else-if="mode === 'css'" class="code-editor-container">
          <CodeEditor 
            v-model:value="pageConfig.css" 
            language="css"
            placeholder="/* Global CSS */"
            theme="dark"
          />
        </div>
        
        <div v-else-if="mode === 'json'" class="code-editor-container">
          <CodeEditor 
            :value="jsonString" 
            @change="handleJsonChange"
            language="json"
            theme="dark"
          />
        </div>

        <div v-else-if="mode === 'preview'" class="preview-container">
           <!-- Simple Preview: Just render without selection logic -->
           <!-- In a real app, this might be a separate component that executes the script -->
           <CanvasRenderer 
             :node="pageConfig.root"
             :selectedId="''"
             :preview="true"
           />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted, onUnmounted, watch, nextTick, createVNode } from 'vue';
import { ArrowLeftOutlined, UndoOutlined, RedoOutlined, DownOutlined, ClearOutlined, DeleteOutlined, ExclamationCircleOutlined } from '@ant-design/icons-vue';
import { message, Modal } from 'ant-design-vue';
import { savePage, type PageDefinition } from '@/api/page';
import { componentGroups } from './designer/ComponentRegistry';
import CanvasRenderer from './designer/CanvasRenderer.vue';
import PropertyEditor from './designer/PropertyEditor.vue';
import CodeEditor from './designer/CodeEditor.vue';
import ComponentTree from './designer/ComponentTree.vue';
import SplitLayout from '@/components/SplitLayout/index.vue';
import { type ComponentNode, generateId, type PageConfig, defaultPageConfig } from './designer/types';
import { getDataListTemplate, getAddEditTemplate, getViewTemplate } from './designer/TemplateData';

const props = defineProps<{
  pageData: PageDefinition;
  initialMode?: 'design' | 'preview';
}>();

const emit = defineEmits(['back', 'save']);

// State
const mode = ref<'design' | 'script' | 'css' | 'json' | 'preview'>('design');
const activeGroups = ref([0, 1, 2, 3, 4]);
const selectedId = ref('');

// Initial Page Config
const pageConfig = reactive<PageConfig>(JSON.parse(JSON.stringify(defaultPageConfig)));

// --- Undo/Redo System ---
const history = ref<string[]>([]);
const historyIndex = ref(-1);
let isUndoRedoOperation = false;
// let isInternalUpdate = false;

const canUndo = computed(() => historyIndex.value > 0);
const canRedo = computed(() => historyIndex.value < history.value.length - 1);

const recordHistory = (config: PageConfig) => {
  if (isUndoRedoOperation) return;
  
  const snapshot = JSON.stringify(config);
  
  // If we have history after current index, discard it
  if (historyIndex.value < history.value.length - 1) {
    history.value = history.value.slice(0, historyIndex.value + 1);
  }
  
  // Avoid duplicate snapshots if multiple updates happen quickly or are identical
  if (history.value.length > 0 && history.value[history.value.length - 1] === snapshot) {
    return;
  }
  
  history.value.push(snapshot);
  historyIndex.value++;
  
  // Limit history size (optional, e.g. 50 steps)
  if (history.value.length > 50) {
    history.value.shift();
    historyIndex.value--;
  }
};

// Debounce helper
const debounce = (fn: Function, delay: number) => {
  let timeoutId: any;
  return (...args: any[]) => {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => fn(...args), delay);
  };
};

// Watch for changes
const debouncedRecord = debounce((newVal: PageConfig) => {
  recordHistory(newVal);
}, 500);

watch(pageConfig, (newVal) => {
  if (isUndoRedoOperation) return;
  // Immediate record for structure changes could be handled separately if needed,
  // but deep watch covers everything.
  debouncedRecord(newVal);
}, { deep: true });

const undo = () => {
  if (!canUndo.value) return;
  
  isUndoRedoOperation = true;
  historyIndex.value--;
  const previousState = JSON.parse(history.value[historyIndex.value] || '{}');
  
  // Restore state
  // We need to replace root and other props
  // Using Object.assign on reactive object works if we match structure
  Object.assign(pageConfig, previousState);
  
  // Reset flag after DOM update
  nextTick(() => {
    isUndoRedoOperation = false;
  });
};

const redo = () => {
  if (!canRedo.value) return;
  
  isUndoRedoOperation = true;
  historyIndex.value++;
  const nextState = JSON.parse(history.value[historyIndex.value] || '{}');
  
  Object.assign(pageConfig, nextState);
  
  nextTick(() => {
    isUndoRedoOperation = false;
  });
};

const handleKeydown = (e: KeyboardEvent) => {
  // Undo
  if ((e.ctrlKey || e.metaKey) && e.key === 'z') {
    e.preventDefault();
    undo();
    return;
  } 
  
  // Redo
  if ((e.ctrlKey || e.metaKey) && e.key === 'y') {
    e.preventDefault();
    redo();
    return;
  }

  // Delete Node
  // Only trigger if we have a selected node and we are NOT in an input/textarea
  if ((e.key === 'Delete' || e.key === 'Backspace') && selectedId.value) {
    const activeTag = document.activeElement?.tagName.toLowerCase();
    if (activeTag === 'input' || activeTag === 'textarea' || document.activeElement?.getAttribute('contenteditable') === 'true') {
      return;
    }
    e.preventDefault();
    handleDeleteNode(selectedId.value);
  }
};

// Load existing config if available
onMounted(() => {
  if (props.initialMode) {
    mode.value = props.initialMode;
  }
  
  window.addEventListener('keydown', handleKeydown);
  
  if (props.pageData.config) {
    try {
      const parsed = JSON.parse(props.pageData.config);
      // Check if it's the new format (has root) or old format (is root)
      if (parsed.root) {
        Object.assign(pageConfig, parsed);
      } else if (parsed.id) {
        // Migration: Old format (root node only)
        Object.assign(pageConfig.root, parsed);
      }
    } catch (e) {
      console.error('Failed to parse page config', e);
    }
  }
  
  // Record initial state
  recordHistory(pageConfig);
});

onUnmounted(() => {
  window.removeEventListener('keydown', handleKeydown);
});

const selectedNode = computed(() => {
  if (!selectedId.value) return undefined;
  return findNode(pageConfig.root, selectedId.value);
});

const jsonString = computed(() => JSON.stringify(pageConfig, null, 2));

const handleJsonChange = (val: string) => {
  try {
    const parsed = JSON.parse(val);
    Object.assign(pageConfig, parsed);
  } catch (e) {
    // ignore
  }
};

const findNode = (node: ComponentNode, id: string): ComponentNode | undefined => {
  if (node.id === id) return node;
  for (const child of node.children) {
    const found = findNode(child, id);
    if (found) return found;
  }
  return undefined;
};

const onDragStart = (e: DragEvent, item: any) => {
  e.dataTransfer?.setData('type', item.type);
  e.dataTransfer?.setData('defaultProps', JSON.stringify(item.defaultProps));
  e.dataTransfer?.setData('text', item.text || '');
};

const handleSelect = (id: string) => {
  selectedId.value = id;
};

const findParent = (node: ComponentNode, targetId: string): ComponentNode | undefined => {
  if (!node.children) return undefined;
  for (const child of node.children) {
    if (child.id === targetId) return node;
    const found = findParent(child, targetId);
    if (found) return found;
  }
  return undefined;
};

const handleDeleteNode = (id: string) => {
  const parent = findParent(pageConfig.root, id);
  if (parent && parent.children) {
    const idx = parent.children.findIndex(c => c.id === id);
    if (idx > -1) {
      parent.children.splice(idx, 1);
      selectedId.value = '';
      message.success('组件已删除');
    }
  } else {
    message.warning('无法删除根节点或未找到节点');
  }
};

const handleNodeDrop = (payload: { targetId: string, type?: string, nodeId?: string, position?: string }) => {
  const target = findNode(pageConfig.root, payload.targetId);
  if (!target) return;
  
  // Resolve actual insertion target and index
  let parent = target;
  let insertIndex = -1; // -1 means append to children
  
  const isBefore = payload.position === 'top' || payload.position === 'left' || payload.position === 'before';
  const isAfter = payload.position === 'bottom' || payload.position === 'right' || payload.position === 'after';

  if (isBefore || isAfter) {
    const p = findParent(pageConfig.root, payload.targetId);
    if (p && p.children) {
      parent = p;
      const idx = p.children.findIndex(c => c.id === payload.targetId);
      insertIndex = isBefore ? idx : idx + 1;
    } else {
      // Should not happen for root
      return;
    }
  }

  // Case 1: Move existing node
  if (payload.nodeId) {
    // Prevent moving into itself or its children
    if (payload.nodeId === payload.targetId && payload.position === 'inside') return;
    
    const nodeToMove = findNode(pageConfig.root, payload.nodeId);
    if (!nodeToMove) return;

    // Check if target is a descendant of nodeToMove
    if (payload.position === 'inside') {
      const isTargetDescendant = findNode(nodeToMove, payload.targetId);
      if (isTargetDescendant) {
        message.warning('无法将组件移动到其子组件内部');
        return;
      }
    }

    const oldParent = findParent(pageConfig.root, payload.nodeId);
    if (oldParent && oldParent.children) {
      const idx = oldParent.children.findIndex(c => c.id === payload.nodeId);
      if (idx > -1) {
        oldParent.children.splice(idx, 1);
        
        // If moving within same parent, we need to adjust insertIndex if we removed an item before it
        if (oldParent.id === parent.id && insertIndex > idx) {
          insertIndex--;
        }

        if (!parent.children) parent.children = [];
        
        if (insertIndex === -1) {
          parent.children.push(nodeToMove);
        } else {
          parent.children.splice(insertIndex, 0, nodeToMove);
        }
        
        selectedId.value = nodeToMove.id; // Keep selected
      }
    }
    return;
  }

  // Case 2: Add new node
  if (payload.type) {
    const groupItem = findComponentConfig(payload.type);
    
    const newNode: ComponentNode = {
      id: generateId(),
      type: payload.type,
      props: groupItem ? JSON.parse(JSON.stringify(groupItem.defaultProps)) : {},
      style: {},
      children: [],
      events: {},
      text: groupItem?.text || undefined
    };
    
    if (!parent.children) parent.children = [];
    
    if (insertIndex === -1) {
      parent.children.push(newNode);
    } else {
      parent.children.splice(insertIndex, 0, newNode);
    }
    
    selectedId.value = newNode.id;
  }
};

const findComponentConfig = (type: string) => {
  for (const group of componentGroups) {
    const found = group.items.find(i => i.type === type);
    if (found) return found;
  }
  return null;
};

const handleSave = async () => {
  try {
    const dataToSave = {
      ...props.pageData,
      code: pageConfig.script,
      config: JSON.stringify(pageConfig),
      apiBindings: JSON.stringify([]) // Add apiBindings if needed
    };
    await savePage(dataToSave);
    message.success('保存成功');
    emit('save');
  } catch (e) {
    message.error('保存失败');
  }
};

const handleClear = () => {
  Modal.confirm({
    title: '确认清空',
    icon: createVNode(ExclamationCircleOutlined),
    content: '确定要清空所有设计内容吗？',
    okText: '确认',
    cancelText: '取消',
    onOk() {
      const defaults = JSON.parse(JSON.stringify(defaultPageConfig));
      Object.assign(pageConfig, defaults);
      selectedId.value = '';
      message.success('设计已清空');
    }
  });
};

const handleInitTemplate = ({ key }: { key: string }) => {
  let templateConfig: PageConfig | null = null;
  
  if (key === 'data-list') {
    templateConfig = getDataListTemplate();
  } else if (key === 'add-edit') {
    templateConfig = getAddEditTemplate();
  } else if (key === 'view-page') {
    templateConfig = getViewTemplate();
  }
  
  if (templateConfig) {
    Object.assign(pageConfig, templateConfig);
    recordHistory(pageConfig);
  }
};
</script>

<style scoped>
.page-designer {
  height: 100%;
  display: flex;
  flex-direction: column;
  background: #f5f5f5;
}

.designer-header {
  height: 50px;
  background: #fff;
  border-bottom: 1px solid #ddd;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 20px;
}

.page-name {
  font-weight: 600;
  margin-left: 10px;
}

.designer-body {
  flex: 1;
  display: flex;
  overflow: hidden;
}

.sidebar {
  width: 100% !important;
  height: 100%;
  background: #fff;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.design-mode-wrapper {
  flex: 1;
  display: flex;
  overflow: hidden;
  height: 100%;
}

.design-mode-wrapper :deep(.split-layout) {
  flex: 1;
  width: 100%;
  height: 100%;
}

.left-sidebar-content {
  border-right: none !important;
}

/* Tabs Styling */
.full-height-tabs {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.full-height-tabs :deep(.ant-tabs-nav) {
  margin: 0 !important;
}

.full-height-tabs :deep(.ant-tabs-nav-list) {
  width: 100%;
}

.full-height-tabs :deep(.ant-tabs-tab) {
  width: 50%;
  margin: 0 !important;
  display: flex;
  justify-content: center;
}

.full-height-tabs :deep(.ant-tabs-content-holder) {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  min-height: 0;
}

.full-height-tabs :deep(.ant-tabs-content) {
  flex: 1;
  display: flex;
  flex-direction: column;
  height: 100%;
}

.full-height-tabs :deep(.ant-tabs-tabpane) {
  flex: 1;
  height: 100%;
  overflow: auto;
  display: flex;
  flex-direction: column;
  padding: 0;
}

.right-sidebar {
  border: none;
}

.panel-title {
  padding: 10px;
  background: #fafafa;
  font-weight: 600;
  border-bottom: 1px solid #eee;
}

.panel-content {
  flex: 1;
  overflow: auto;
}

.component-list-container {
  /* flex: 1; */
  /* overflow-y: auto; */
  padding: 10px;
  /* height: 100%; */
}

.component-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px;
}

.comp-item {
  padding: 8px;
  background: #f9f9f9;
  border: 1px solid #e8e8e8;
  cursor: grab;
  border-radius: 4px;
  text-align: center;
  font-size: 12px;
  transition: all 0.3s;
}

.comp-item:hover {
  border-color: #1890ff;
  color: #1890ff;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}

.main-area {
  flex: 1;
  background: #fff;
  margin: 0;
  display: flex;
  flex-direction: column;
  position: relative;
}

.visual-canvas {
  flex: 1;
  background: #f0f2f5;
  padding: 20px;
  overflow: auto;
}

.code-editor-container, .preview-container {
  flex: 1;
  height: 100%;
  overflow: hidden;
}

.code-textarea {
  height: 100%;
  width: 100%;
  font-family: 'Consolas', monospace;
  background: #2d2d2d;
  color: #ccc;
  border: none;
  resize: none;
  padding: 20px;
}

.preview-container {
  padding: 20px;
  background: #fff;
  overflow: auto;
}
</style>
