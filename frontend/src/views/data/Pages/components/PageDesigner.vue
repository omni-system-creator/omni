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
      <!-- Left: Components -->
      <div class="sidebar" v-if="mode === 'design'">
        <div class="panel-title">组件库</div>
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
      </div>
      
      <!-- Middle: Canvas -->
      <div class="main-area">
        <div v-if="mode === 'design'" class="visual-canvas" @click="selectedId = ''">
          <CanvasRenderer 
            :node="pageConfig.root" 
            :selectedId="selectedId" 
            :isRoot="true"
            @select="handleSelect"
            @node-drop="handleNodeDrop"
          />
        </div>

        <div v-else-if="mode === 'script'" class="code-editor-container">
          <CodeEditor 
            v-model:value="pageConfig.script" 
            language="typescript"
            placeholder="// <script setup lang='ts'> content here..."
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
      
      <!-- Right: Properties -->
      <div class="sidebar right-sidebar" v-if="mode === 'design'">
        <div class="panel-title">属性设置</div>
        <div class="panel-content">
          <PropertyEditor :node="selectedNode" @delete="handleDeleteNode" />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue';
import { ArrowLeftOutlined } from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import { savePage, type PageDefinition } from '@/api/page';
import { componentGroups } from './designer/ComponentRegistry';
import CanvasRenderer from './designer/CanvasRenderer.vue';
import PropertyEditor from './designer/PropertyEditor.vue';
import CodeEditor from './designer/CodeEditor.vue';
import { type ComponentNode, generateId, type PageConfig, defaultPageConfig } from './designer/types';

const props = defineProps<{
  pageData: PageDefinition;
}>();

const emit = defineEmits(['back', 'save']);

const mode = ref('design');
const activeGroups = ref([0, 1, 2, 3, 4]);
const selectedId = ref('');

// Initial Page Config
const pageConfig = reactive<PageConfig>(JSON.parse(JSON.stringify(defaultPageConfig)));

// Load existing config if available
onMounted(() => {
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

const handleNodeDrop = (payload: { targetId: string, type?: string, nodeId?: string }) => {
  const target = findNode(pageConfig.root, payload.targetId);
  if (!target) return;

  // Case 1: Move existing node
  if (payload.nodeId) {
    // Prevent moving into itself or its children
    if (payload.nodeId === payload.targetId) return;
    
    const nodeToMove = findNode(pageConfig.root, payload.nodeId);
    if (!nodeToMove) return;

    // Check if target is a descendant of nodeToMove
    const isTargetDescendant = findNode(nodeToMove, payload.targetId);
    if (isTargetDescendant) {
      message.warning('无法将组件移动到其子组件内部');
      return;
    }

    const oldParent = findParent(pageConfig.root, payload.nodeId);
    if (oldParent && oldParent.children) {
      const idx = oldParent.children.findIndex(c => c.id === payload.nodeId);
      if (idx > -1) {
        oldParent.children.splice(idx, 1);
        if (!target.children) target.children = [];
        target.children.push(nodeToMove);
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
    
    if (!target.children) target.children = [];
    target.children.push(newNode);
    
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
      config: JSON.stringify(pageConfig)
    };
    await savePage(dataToSave);
    message.success('保存成功');
    emit('save');
  } catch (e) {
    message.error('保存失败');
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
  width: 260px;
  background: #fff;
  border-right: 1px solid #ddd;
  display: flex;
  flex-direction: column;
}

.right-sidebar {
  width: 300px;
  border-right: none;
  border-left: 1px solid #ddd;
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
  flex: 1;
  overflow-y: auto;
  padding: 10px;
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
