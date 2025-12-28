<template>
  <div class="property-editor">
    <div v-if="!node" class="empty-selection">
      请选择一个组件
    </div>
    <div v-else>
      <div class="section-title">基本信息</div>
      <a-form layout="vertical">
        <a-form-item label="组件 ID">
          <a-input :value="node.id" disabled />
        </a-form-item>
        <a-form-item label="组件类型">
          <a-tag color="blue">{{ node.type }}</a-tag>
        </a-form-item>
        <a-form-item label="文本内容" v-if="hasText">
          <a-input v-model:value="node.text" />
        </a-form-item>
        <a-form-item label="v-model 绑定">
          <a-input v-model:value="node.model" placeholder="输入变量名 (如 formData.name)" />
        </a-form-item>
      </a-form>

      <a-collapse v-model:activeKey="activeKey" ghost>
        <a-collapse-panel key="props" header="属性 (Props)">
          <div v-for="(val, key) in node.props" :key="key" class="prop-row">
            <div class="prop-key">{{ key }}</div>
            <div class="prop-val">
              <a-input v-if="typeof val === 'string'" v-model:value="node.props[key]" />
              <a-switch v-else-if="typeof val === 'boolean'" v-model:checked="node.props[key]" />
              <a-input-number v-else-if="typeof val === 'number'" v-model:value="node.props[key]" />
              <a-button type="text" danger size="small" @click="removeProp(key)">
                <template #icon><DeleteOutlined /></template>
              </a-button>
            </div>
          </div>
          <div class="add-prop">
            <a-input v-model:value="newPropKey" placeholder="新属性名" size="small" style="width: 100px" />
            <a-button type="dashed" size="small" @click="addProp">添加</a-button>
          </div>
        </a-collapse-panel>

        <a-collapse-panel key="style" header="样式 (Style)">
          <div v-for="(_val, key) in node.style" :key="key" class="prop-row">
            <div class="prop-key">{{ key }}</div>
            <div class="prop-val">
              <a-input v-model:value="node.style[key]" />
              <a-button type="text" danger size="small" @click="removeStyle(key)">
                <template #icon><DeleteOutlined /></template>
              </a-button>
            </div>
          </div>
          <div class="add-prop">
            <a-input v-model:value="newStyleKey" placeholder="样式名 (如 color)" size="small" style="width: 100px" />
            <a-button type="dashed" size="small" @click="addStyle">添加</a-button>
          </div>
        </a-collapse-panel>

        <a-collapse-panel key="events" header="事件 (Events)">
          <div v-for="(val, key) in node.events" :key="key" class="prop-row">
            <div class="prop-key">@{{ key }}</div>
            <div class="prop-val">
              <span class="event-preview">{{ val ? '已编写' : '空' }}</span>
              <a-button type="text" size="small" @click="openEventEditor(key as string)">
                <template #icon><EditOutlined /></template>
              </a-button>
              <a-button type="text" danger size="small" @click="removeEvent(key)">
                <template #icon><DeleteOutlined /></template>
              </a-button>
            </div>
          </div>
          <div class="add-prop">
             <a-select 
              v-model:value="newEventKey" 
              placeholder="选择事件" 
              style="width: 120px" 
              size="small"
              :options="availableEvents.map(e => ({ label: e, value: e }))"
             />
            <a-button type="dashed" size="small" @click="addEvent" :disabled="!newEventKey">添加</a-button>
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
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import { DeleteOutlined, EditOutlined } from '@ant-design/icons-vue';
import type { ComponentNode } from './types';
import { getComponentEvents, getEventSignature } from './ComponentRegistry';
import CodeEditor from './CodeEditor.vue';
import DraggableModal from '@/components/DraggableModal.vue';

const props = defineProps<{
  node?: ComponentNode;
}>();

const emit = defineEmits(['delete']);

const activeKey = ref(['props', 'style', 'events']);
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

const hasText = computed(() => {
  if (!props.node) return false;
  return ['AButton', 'div', 'span', 'p', 'h1', 'ATag'].includes(props.node.type) || props.node.text !== undefined;
});

const availableEvents = computed(() => {
  if (!props.node) return [];
  const events = getComponentEvents(props.node.type);
  return events.filter(e => !props.node?.events[e]);
});

const openEventEditor = (eventName: string) => {
  if (!props.node) return;
  editingEventName.value = eventName;
  editingEventCode.value = props.node.events[eventName] || '';
  editModalVisible.value = true;
};

const saveEventCode = () => {
  if (props.node) {
    props.node.events[editingEventName.value] = editingEventCode.value;
  }
  editModalVisible.value = false;
};

const addProp = () => {
  if (props.node && newPropKey.value) {
    props.node.props[newPropKey.value] = ''; // Default string
    newPropKey.value = '';
  }
};

const removeProp = (key: string) => {
  if (props.node) {
    delete props.node.props[key];
  }
};

const addStyle = () => {
  if (props.node && newStyleKey.value) {
    props.node.style[newStyleKey.value] = '';
    newStyleKey.value = '';
  }
};

const removeStyle = (key: string) => {
  if (props.node) {
    delete props.node.style[key];
  }
};

const addEvent = () => {
  if (props.node && newEventKey.value) {
    props.node.events[newEventKey.value] = '';
    newEventKey.value = undefined;
  }
};

const removeEvent = (key: string) => {
  if (props.node) {
    delete props.node.events[key];
  }
};
</script>

<style scoped>
.property-editor {
  padding: 10px;
}

.empty-selection {
  color: #999;
  text-align: center;
  margin-top: 50px;
}

.section-title {
  font-weight: 600;
  margin-bottom: 10px;
  padding-bottom: 5px;
  border-bottom: 1px solid #eee;
}

.prop-row {
  display: flex;
  align-items: center;
  margin-bottom: 8px;
}

.prop-key {
  width: 80px;
  font-size: 12px;
  color: #666;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.prop-val {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 4px;
}

.event-preview {
  flex: 1;
  font-size: 12px;
  color: #999;
  background: #f5f5f5;
  padding: 2px 5px;
  border-radius: 4px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.add-prop {
  display: flex;
  gap: 8px;
  margin-top: 8px;
}

.event-editor-wrapper {
  border: 1px solid #d9d9d9;
  border-radius: 4px;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  height: 100%;
}

.code-header, .code-footer {
  padding: 5px 10px;
  background: #f0f0f0;
  font-family: monospace;
  font-size: 12px;
  color: #666;
}

.code-header {
  border-bottom: 1px solid #d9d9d9;
}

.code-body {
  flex: 1;
  overflow: hidden;
}

.code-footer {
  border-top: 1px solid #d9d9d9;
}
</style>
