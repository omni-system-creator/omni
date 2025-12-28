<template>
  <div class="property-editor">
    <div v-if="!node" class="empty-selection">
      请选择一个组件
    </div>
    <div v-else>
      <div class="section-title">基本信息</div>
      <div class="prop-grid">
        <div class="grid-row">
          <div class="grid-cell grid-label">组件 ID</div>
          <div class="grid-cell grid-value">
            <a-input :value="node.id" disabled size="small" />
          </div>
        </div>
        <div class="grid-row">
          <div class="grid-cell grid-label">组件类型</div>
          <div class="grid-cell grid-value">
            <a-tag color="blue">{{ node.type }}</a-tag>
          </div>
        </div>
        <div class="grid-row" v-if="hasText">
          <div class="grid-cell grid-label">文本内容</div>
          <div class="grid-cell grid-value">
            <a-input v-model:value="node.text" size="small" />
          </div>
        </div>
        <div class="grid-row">
          <div class="grid-cell grid-label">v-model</div>
          <div class="grid-cell grid-value">
            <a-input v-model:value="node.model" placeholder="变量名" size="small" />
          </div>
        </div>
      </div>

      <a-collapse v-model:activeKey="activeKey" ghost class="prop-collapse">
        <a-collapse-panel key="props" header="属性 (Props)">
          <div class="prop-grid">
            <div class="grid-row header-row">
              <div class="grid-cell grid-label header">属性名</div>
              <div class="grid-cell grid-value header">
                <span>设置</span>
                <a-button type="link" size="small" @click="showAddProp = !showAddProp">
                  <PlusOutlined />
                </a-button>
              </div>
            </div>

            <div v-if="showAddProp" class="grid-row add-row">
              <div class="grid-cell grid-label">
                <a-input v-model:value="newPropKey" placeholder="新属性名" size="small" />
              </div>
              <div class="grid-cell grid-value">
                <a-button type="primary" size="small" @click="addProp">添加</a-button>
              </div>
            </div>

            <div v-for="prop in allPropsList" :key="prop.key" class="grid-row">
              <div class="grid-cell grid-label" :title="prop.key">
                <span>{{ prop.label }}</span>
                <span class="prop-key-sub">{{ prop.key }}</span>
              </div>
              <div class="grid-cell grid-value">
                <!-- String / Number / Default -->
                <template v-if="prop.type === 'string' || prop.type === 'number'">
                   <a-input 
                    v-if="prop.type === 'string'" 
                    :value="prop.value" 
                    @update:value="(val: any) => updateProp(prop.key, val)"
                    size="small" 
                    allowClear
                  />
                  <a-input-number 
                    v-else 
                    :value="prop.value" 
                    @update:value="(val: any) => updateProp(prop.key, val)"
                    size="small" 
                    style="width: 100%"
                  />
                </template>

                <!-- Boolean -->
                <template v-else-if="prop.type === 'boolean'">
                  <a-switch 
                    :checked="prop.value" 
                    @update:checked="(val: any) => updateProp(prop.key, val)"
                    size="small" 
                  />
                </template>

                <!-- Select -->
                <template v-else-if="prop.type === 'select'">
                  <a-select 
                    :value="prop.value" 
                    @update:value="(val: any) => updateProp(prop.key, val)"
                    size="small" 
                    style="width: 100%"
                    :options="prop.options"
                    allowClear
                  />
                </template>

                <!-- JSON / Object -->
                <template v-else-if="prop.type === 'json' || (prop.type as string) === 'object'">
                  <a-button size="small" @click="editPropJson(prop.key)">
                    <EditOutlined /> 编辑数据
                  </a-button>
                </template>

                <!-- Delete for custom props -->
                <a-button 
                  v-if="!prop.isSchema" 
                  type="text" 
                  danger 
                  size="small" 
                  class="del-btn"
                  @click="removeProp(prop.key)"
                >
                  <DeleteOutlined />
                </a-button>
              </div>
            </div>
          </div>
        </a-collapse-panel>

        <a-collapse-panel key="style" header="样式 (Style)">
          <div class="prop-grid">
            <div v-for="style in allStylesList" :key="style.key" class="grid-row">
              <div class="grid-cell grid-label" :title="style.key">
                 <span>{{ style.label }}</span>
                 <span class="prop-key-sub">{{ style.key }}</span>
              </div>
              <div class="grid-cell grid-value">
                <template v-if="style.type === 'select'">
                  <a-select 
                    :value="style.value" 
                    @update:value="(val: any) => updateStyle(style.key, val)"
                    size="small" 
                    style="width: 100%"
                    :options="style.options"
                    allowClear
                  />
                </template>
                <template v-else-if="style.type === 'color'">
                   <div style="display: flex; align-items: center; width: 100%">
                     <input 
                       type="color" 
                       :value="style.value || '#000000'" 
                       @input="e => updateStyle(style.key, (e.target as HTMLInputElement).value)"
                       style="margin-right: 5px; height: 24px; width: 24px; padding: 0; border: none;"
                     />
                     <a-input 
                       :value="style.value" 
                       @update:value="(val: any) => updateStyle(style.key, val)"
                       size="small" 
                       allowClear
                     />
                   </div>
                </template>
                <template v-else>
                   <a-input 
                    :value="style.value" 
                    @update:value="(val: any) => updateStyle(style.key, val)"
                    size="small" 
                    allowClear
                  />
                </template>
                
                 <!-- Delete for custom styles -->
                <a-button 
                  v-if="!style.isSchema" 
                  type="text" 
                  danger 
                  size="small" 
                  class="del-btn"
                  @click="removeStyle(style.key)"
                >
                  <DeleteOutlined />
                </a-button>
              </div>
            </div>
            <div class="grid-row add-row">
              <div class="grid-cell grid-label">
                <a-input v-model:value="newStyleKey" placeholder="样式名" size="small" />
              </div>
              <div class="grid-cell grid-value">
                <a-button type="dashed" size="small" @click="addStyle">添加</a-button>
              </div>
            </div>
          </div>
        </a-collapse-panel>

        <a-collapse-panel key="events" header="事件 (Events)">
          <div class="prop-grid">
            <div class="grid-row header-row">
              <div class="grid-cell grid-label header">事件名</div>
              <div class="grid-cell grid-value header">
                <span>动作</span>
                <a-popover trigger="click" placement="bottomRight">
                  <template #content>
                    <a-input
                      v-model:value="newEventKey"
                      placeholder="自定义事件名"
                      size="small"
                      @pressEnter="addEvent"
                    />
                    <a-button size="small" type="primary" style="margin-top: 8px; width: 100%" @click="addEvent">添加</a-button>
                  </template>
                  <a-button type="link" size="small"><PlusOutlined /></a-button>
                </a-popover>
              </div>
            </div>
            
            <div v-for="evt in allEventsList" :key="evt.key" class="grid-row">
              <div class="grid-cell grid-label">@{{ evt.key }}</div>
              <div class="grid-cell grid-value">
                <a-tag :color="evt.isConfigured ? 'green' : 'default'" class="event-status">
                  {{ evt.isConfigured ? '已配置' : '未配置' }}
                </a-tag>
                <div class="event-actions">
                  <a-button type="text" size="small" @click="openEventEditor(evt.key)">
                    <EditOutlined />
                  </a-button>
                  <a-button v-if="evt.isConfigured" type="text" danger size="small" @click="removeEvent(evt.key)">
                    <DeleteOutlined />
                  </a-button>
                </div>
              </div>
            </div>
          </div>
        </a-collapse-panel>
      </a-collapse>
    </div>

    <DraggableModal
      v-model:visible="editModalVisible"
      :title="`编辑事件: @${editingEventName}`"
      width="800"
      height="600"
      :maskClosable="false"
    >
      <div class="event-editor-wrapper">
        <div class="code-header">{{ editingEventSignature }}</div>
        <div class="code-body">
          <CodeEditor 
            v-model:value="editingEventCode" 
            language="javascript" 
            height="100%" 
            theme="dark"
            placeholder="// 编写事件处理逻辑"
          />
        </div>
        <div class="code-footer">}</div>
      </div>
      <template #footer>
        <a-button @click="editModalVisible = false">取消</a-button>
        <a-button type="primary" @click="saveEventCode">确定</a-button>
      </template>
    </DraggableModal>

    <!-- JSON Property Editor Modal -->
    <DraggableModal
      v-model:visible="jsonEditModalVisible"
      :title="`编辑属性: ${editingPropName}`"
      :width="600"
      :height="500"
    >
      <CodeEditor
        v-model:value="editingJsonCode"
        language="json"
        style="height: 100%"
      />
      <template #footer>
        <a-button @click="jsonEditModalVisible = false">取消</a-button>
        <a-button type="primary" @click="savePropJson">确定</a-button>
      </template>
    </DraggableModal>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import { message } from 'ant-design-vue';
import { DeleteOutlined, EditOutlined, PlusOutlined } from '@ant-design/icons-vue';
import type { ComponentNode } from './types';
import { getComponentEvents, getEventSignature, getComponentPropsSchema, commonStyleSchema, type PropSchema } from './ComponentRegistry';
import CodeEditor from './CodeEditor.vue';
import DraggableModal from '@/components/DraggableModal.vue';

const props = defineProps<{
  node?: ComponentNode;
}>();

const emit = defineEmits(['delete']);

const activeKey = ref(['props', 'style', 'events']);
const showAddProp = ref(false);
const newPropKey = ref('');
const newStyleKey = ref('');
const newEventKey = ref<string | undefined>(undefined);

// Event editing state
const editModalVisible = ref(false);
const editingEventName = ref('');
const editingEventCode = ref('');
const editingEventSignature = computed(() => {
  return `(${getEventSignature(editingEventName.value)}) => {`;
});

// JSON Property editing state
const jsonEditModalVisible = ref(false);
const editingPropName = ref('');
const editingJsonCode = ref('');

// --- Props Grid Logic ---
interface PropItem extends PropSchema {
  key: string;
  value: any;
  isSchema: boolean;
}

const allPropsList = computed(() => {
  if (!props.node) return [];
  const schema = getComponentPropsSchema(props.node.type);
  const currentProps = props.node.props || {};
  
  const result: PropItem[] = [];
  
  // 1. Add props from schema
  for (const key in schema) {
    const propDef = schema[key] as PropSchema;
    result.push({
      key,
      ...propDef,
      label: propDef.label || key,
      value: currentProps[key],
      isSchema: true
    });
  }
  
  // 2. Add extra props that are set but not in schema
  for (const key in currentProps) {
    if (!(key in schema)) {
      result.push({
        key,
        label: key,
        type: typeof currentProps[key] === 'object' ? 'json' : 'string',
        value: currentProps[key],
        isSchema: false
      });
    }
  }
  
  return result;
});

const allStylesList = computed(() => {
  if (!props.node) return [];
  const currentStyles = props.node.style || {};
  
  const result: PropItem[] = [];
  
  // 1. Add common styles
  for (const key in commonStyleSchema) {
    const styleDef = commonStyleSchema[key] as PropSchema;
    result.push({
      key,
      ...styleDef,
      label: styleDef.label || key,
      value: currentStyles[key],
      isSchema: true
    });
  }
  
  // 2. Add extra styles
  for (const key in currentStyles) {
    if (!(key in commonStyleSchema)) {
      result.push({
        key,
        label: key,
        type: 'string',
        value: currentStyles[key],
        isSchema: false
      });
    }
  }
  
  return result;
});

const allEventsList = computed(() => {
  if (!props.node) return [];
  const supportedEvents = getComponentEvents(props.node.type);
  const configuredEvents = props.node.events || {};
  
  // Merge and deduplicate
  const allKeys = Array.from(new Set([...supportedEvents, ...Object.keys(configuredEvents)]));
  
  return allKeys.map(key => ({
    key,
    isConfigured: !!configuredEvents[key]
  }));
});

const updateProp = (key: string, value: any) => {
  if (!props.node) return;
  // If value is null/undefined/empty string, consider removing it? 
  // For now, keep it to be explicit.
  if (!props.node.props) {
    props.node.props = {};
  }
  props.node.props[key] = value;
};

const updateStyle = (key: string, value: any) => {
  if (!props.node) return;
  if (!props.node.style) {
    props.node.style = {};
  }
  props.node.style[key] = value;
};

const addProp = () => {
  if (props.node && newPropKey.value) {
    if (!props.node.props) {
      props.node.props = {};
    }
    props.node.props[newPropKey.value] = ''; 
    newPropKey.value = '';
    showAddProp.value = false;
  }
};

const removeProp = (key: string) => {
  if (props.node && props.node.props) {
    delete props.node.props[key];
  }
};

const editPropJson = (key: string) => {
  if (!props.node) return;
  editingPropName.value = key;
  const val = props.node.props ? props.node.props[key] : undefined;
  try {
    editingJsonCode.value = JSON.stringify(val, null, 2);
  } catch (e) {
    editingJsonCode.value = '{}';
  }
  jsonEditModalVisible.value = true;
};

const savePropJson = () => {
  try {
    const parsed = JSON.parse(editingJsonCode.value);
    if (props.node) {
      if (!props.node.props) {
        props.node.props = {};
      }
      props.node.props[editingPropName.value] = parsed;
    }
    jsonEditModalVisible.value = false;
    message.success('属性更新成功');
  } catch (e) {
    message.error('JSON 格式错误: ' + (e as Error).message);
  }
};

const hasText = computed(() => {
  if (!props.node) return false;
  return ['AButton', 'div', 'span', 'p', 'h1', 'ATag'].includes(props.node.type) || props.node.text !== undefined;
});

// const availableEvents = computed(() => {
//   if (!props.node) return [];
//   const events = getComponentEvents(props.node.type);
//   return events.filter(e => !props.node?.events?.[e]);
// });

const openEventEditor = (eventName: string) => {
  if (!props.node) return;
  editingEventName.value = eventName;
  editingEventCode.value = (props.node.events && props.node.events[eventName]) || '';
  editModalVisible.value = true;
};

const saveEventCode = () => {
  if (props.node) {
    if (!props.node.events) {
      props.node.events = {};
    }
    props.node.events[editingEventName.value] = editingEventCode.value;
  }
  editModalVisible.value = false;
};

const addStyle = () => {
  if (props.node && newStyleKey.value) {
    if (!props.node.style) {
      props.node.style = {};
    }
    props.node.style[newStyleKey.value] = '';
    newStyleKey.value = '';
  }
};

const removeStyle = (key: string) => {
  if (props.node && props.node.style) {
    delete props.node.style[key];
  }
};

const addEvent = () => {
  if (props.node && newEventKey.value) {
    if (!props.node.events) {
      props.node.events = {};
    }
    props.node.events[newEventKey.value] = '';
    newEventKey.value = undefined;
  }
};

const removeEvent = (key: string) => {
  if (props.node && props.node.events) {
    delete props.node.events[key];
  }
};
</script>

<style scoped>
.property-editor {
  padding: 0;
  height: 100%;
  overflow-y: auto;
}

.empty-selection {
  color: #999;
  text-align: center;
  margin-top: 50px;
  padding: 20px;
}

.section-title {
  font-weight: 600;
  padding: 12px;
  background: #fafafa;
  border-bottom: 1px solid #eee;
}

/* Prop Grid Styles */
.prop-grid {
  display: grid;
  grid-template-columns: 100px 1fr;
  border-bottom: 1px solid #eee;
}

.grid-row {
  display: contents;
}

.grid-cell {
  padding: 6px 8px;
  border-bottom: 1px solid #f0f0f0;
  font-size: 13px;
  display: flex;
  align-items: center;
  min-height: 36px;
}

.grid-label {
  background: #fafafa;
  border-right: 1px solid #f0f0f0;
  color: #666;
  flex-direction: column;
  align-items: flex-start;
  justify-content: center;
  line-height: 1.2;
}

.grid-value {
  background: #fff;
  position: relative;
  overflow: hidden;
}

.header-row .grid-cell {
  background: #e6f7ff;
  font-weight: 600;
  color: #096dd9;
  border-bottom: 1px solid #bae7ff;
}

.header .grid-cell {
  justify-content: space-between;
}

.prop-key-sub {
  font-size: 10px;
  color: #999;
  font-family: monospace;
}

.del-btn {
  position: absolute;
  right: 4px;
  top: 50%;
  transform: translateY(-50%);
  opacity: 0;
  transition: opacity 0.2s;
}

.grid-row:hover .del-btn {
  opacity: 1;
}

.event-status {
  margin-right: 8px;
}

.event-actions {
  margin-left: auto;
  display: flex;
  gap: 4px;
}

.event-editor-wrapper {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.code-header, .code-footer {
  padding: 10px;
  background: #1e1e1e;
  color: #d4d4d4;
  font-family: monospace;
}

.code-body {
  flex: 1;
  overflow: hidden;
}

.prop-collapse :deep(.ant-collapse-content-box) {
  padding: 0 !important;
}

.prop-collapse :deep(.ant-collapse-header) {
  background: #fafafa;
  padding: 8px 12px !important;
  font-weight: 600;
}
</style>