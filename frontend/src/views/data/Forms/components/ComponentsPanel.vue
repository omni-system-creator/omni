<template>
  <div class="components-panel">
    <div class="panel-title">组件库</div>
    
    <div v-for="(group, index) in componentGroups" :key="index" class="component-group">
      <div class="group-title">{{ group.title }}</div>
      <draggable
        class="component-list"
        :list="group.components"
        :group="{ name: 'people', pull: 'clone', put: false }"
        :clone="cloneComponent"
        item-key="type"
        :sort="false"
        ghost-class="ghost"
      >
        <template #item="{ element }">
          <div class="component-item">
            <span>{{ element.label }}</span>
          </div>
        </template>
      </draggable>
    </div>
  </div>
</template>

<script setup lang="ts">
import draggable from 'vuedraggable';

const props = defineProps({
  cloneComponent: {
    type: Function,
    required: true
  }
});

const componentGroups = [
  {
    title: '基础组件',
    components: [
      { type: 'input', label: '单行文本', field: 'field_1', required: false, placeholder: '', span: 24, showLabel: true, hidden: false },
      { type: 'textarea', label: '多行文本', field: 'field_2', required: false, placeholder: '', span: 24, showLabel: true, hidden: false },
      { type: 'number', label: '数字输入', field: 'field_3', required: false, span: 24, showLabel: true, hidden: false },
      { type: 'date', label: '日期选择', field: 'field_4', required: false, span: 24, showLabel: true, hidden: false },
      { type: 'select', label: '下拉选择', field: 'field_5', required: false, span: 24, showLabel: true, hidden: false },
    ]
  },
  {
    title: '布局组件',
    components: [
      { type: 'text', label: '文字说明', field: 'text_1', content: '这是一段文字说明', fontSize: 14, bold: false, align: 'left', color: '#000000', span: 24, showLabel: false, hidden: false },
      { type: 'rich-text', label: '富文本', field: 'rich_text_1', content: '<p>这里是富文本内容</p>', span: 24, showLabel: false, hidden: false },
      { type: 'divider', label: '分割线', field: 'divider_1', text: '分割线', orientation: 'center', dashed: false, marginTop: 24, marginBottom: 24, span: 24, showLabel: false, hidden: false },
      { 
        type: 'subtable', 
        label: '子表', 
        field: 'subtable_1', 
        required: false, 
        span: 24, 
        columns: [],
        showRowNumber: true,
        showSummary: false,
        showLabel: true,
        hidden: false
      }
    ]
  },
  {
    title: '高级组件',
    components: [
      { 
        type: 'calculation', 
        label: '计算公式', 
        field: 'calc_1', 
        required: false, 
        span: 24, 
        showLabel: true, 
        hidden: false,
        formula: '', 
        returnType: 'number'
      },
      { 
        type: 'current-time', 
        label: '当前时间', 
        field: 'time_1', 
        required: false, 
        span: 24, 
        showLabel: true, 
        hidden: false,
        format: 'YYYY-MM-DD HH:mm:ss' 
      },
      { 
        type: 'current-user', 
        label: '当前人员', 
        field: 'user_1', 
        required: false, 
        span: 24, 
        showLabel: true, 
        hidden: false,
        showField: 'name' 
      }
    ]
  }
];
</script>

<style scoped>
.components-panel {
  width: 250px;
  background: #fff;
  border-right: 1px solid #ddd;
  padding: 10px;
  display: flex;
  flex-direction: column;
}

.panel-title {
  font-weight: bold;
  margin-bottom: 10px;
  padding-bottom: 10px;
  border-bottom: 1px solid #eee;
}

.component-group {
  margin-bottom: 15px;
}

.group-title {
  font-size: 12px;
  color: #666;
  margin-bottom: 8px;
  padding-left: 5px;
  font-weight: bold;
}

.component-list {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
}

.component-item {
  padding: 10px;
  border: 1px dashed #ddd;
  cursor: move;
  background: #fafafa;
  text-align: center;
  font-size: 13px;
  border-radius: 4px;
  transition: all 0.3s;
}

.component-item:hover {
  border-color: #1890ff;
  color: #1890ff;
  box-shadow: 0 2px 5px rgba(0,0,0,0.1);
}
</style>
