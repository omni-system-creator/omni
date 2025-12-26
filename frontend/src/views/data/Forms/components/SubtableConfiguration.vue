<template>
  <div class="subtable-props">
    <a-form-item label="显示行号">
      <a-switch v-model:checked="selectedItem.showRowNumber" />
    </a-form-item>
    <a-form-item label="显示合计行">
      <a-switch v-model:checked="selectedItem.showSummary" />
    </a-form-item>

    <div class="panel-title" style="margin-top: 20px;">列配置</div>
    
    <div v-if="selectedSubtableColumn" class="subtable-column-props">
      <div style="font-weight: bold; margin-bottom: 10px;">当前选中列: {{ selectedSubtableColumn.label }}</div>
      <a-form-item label="列名">
        <a-input v-model:value="selectedSubtableColumn.label" />
      </a-form-item>
      <a-form-item label="字段Key">
        <a-input v-model:value="selectedSubtableColumn.field" @blur="handleFieldChange($event)" />
      </a-form-item>
      <a-form-item label="类型">
        <a-select v-model:value="selectedSubtableColumn.type">
          <a-select-option value="input">单行文本</a-select-option>
          <a-select-option value="textarea">多行文本</a-select-option>
          <a-select-option value="number">数字输入</a-select-option>
          <a-select-option value="date">日期选择</a-select-option>
          <a-select-option value="select">下拉选择</a-select-option>
        </a-select>
      </a-form-item>
      <a-form-item label="列宽类型">
        <a-radio-group v-model:value="selectedSubtableColumn.widthType" button-style="solid">
          <a-radio-button value="px">像素(px)</a-radio-button>
          <a-radio-button value="percent">百分比(%)</a-radio-button>
        </a-radio-group>
      </a-form-item>
      <a-form-item :label="selectedSubtableColumn.widthType === 'percent' ? '列宽 (%)' : '列宽 (px)'">
        <a-input-number v-model:value="selectedSubtableColumn.width" style="width: 100%" placeholder="默认自适应" />
      </a-form-item>
      
      <a-form-item label="汇总方式" v-if="selectedItem.showSummary">
        <a-select v-model:value="selectedSubtableColumn.summaryType" allowClear placeholder="不汇总">
          <a-select-option value="count">计数</a-select-option>
          <a-select-option value="sum">求和</a-select-option>
          <a-select-option value="avg">平均</a-select-option>
        </a-select>
      </a-form-item>
    </div>

    <div v-else class="no-column-selected">
      请点击子表中的列进行配置
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue';
import { message } from 'ant-design-vue';

const props = defineProps({
  selectedItem: {
    type: Object,
    required: true
  },
  selectedSubtableColumn: {
    type: Object,
    default: null
  },
  formItems: {
    type: Array as () => any[],
    required: true
  }
});

const editingFieldOriginalValue = ref('');

watch(() => props.selectedSubtableColumn, (newVal) => {
  if (newVal) {
    editingFieldOriginalValue.value = newVal.field;
  }
}, { immediate: true });

const checkDuplicateField = (field: string, excludeId: string) => {
  for (const item of props.formItems) {
    if (item.id !== excludeId && item.field === field) return item;
    if (item.type === 'subtable' && item.columns) {
      for (const col of item.columns) {
        if (col.id !== excludeId && col.field === field) return col;
      }
    }
  }
  return null;
};

const handleFieldChange = (e?: FocusEvent) => {
  if (!props.selectedSubtableColumn) return;
  
  const currentField = props.selectedSubtableColumn.field;
  const currentId = props.selectedSubtableColumn.id;

  if (!currentField) return;
  if (currentField === editingFieldOriginalValue.value) return;

  const duplicateItem = checkDuplicateField(currentField, currentId);
  if (duplicateItem) {
    message.error(`字段名 "${currentField}" 已存在 (与组件 "${duplicateItem.label}" 冲突)，请重新修改`);
    // Try to keep focus
    if (e && e.target) {
      const target = e.target as HTMLInputElement;
      target.focus();
      
      // If focus is still lost (e.g. user clicked away forcibly), revert to original valid value
      setTimeout(() => {
        if (document.activeElement !== target) {
          props.selectedSubtableColumn.field = editingFieldOriginalValue.value;
        }
      }, 0);
    }
  } else {
    editingFieldOriginalValue.value = currentField;
  }
};
</script>

<style scoped>
.panel-title {
  font-weight: bold;
  margin-bottom: 10px;
  padding-bottom: 10px;
  border-bottom: 1px solid #eee;
}

.subtable-column-props {
  background: #fafafa;
  padding: 10px;
  border: 1px solid #eee;
  margin-bottom: 10px;
}

.no-column-selected {
  color: #999;
  text-align: center;
  padding: 20px;
  border: 1px dashed #ddd;
  margin-bottom: 10px;
}
</style>