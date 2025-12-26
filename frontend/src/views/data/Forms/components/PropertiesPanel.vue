<template>
  <div class="properties-panel">
    <div class="panel-title">属性设置</div>
    <div v-if="selectedItem" class="properties-content">
      <a-form layout="vertical">
        <a-form-item label="标题">
          <a-switch v-model:checked="selectedItem.showLabel" checked-children="显示" un-checked-children="隐藏" />
          <a-input v-if="selectedItem.showLabel" v-model:value="selectedItem.label" style="margin-top: 5px;" />
        </a-form-item>
        <a-form-item label="字段名">
          <a-input v-model:value="selectedItem.field" @blur="handleFieldChange($event)" />
        </a-form-item>
        <a-form-item label="状态设置">
           <a-checkbox v-model:checked="selectedItem.required">必填</a-checkbox>
           <a-checkbox v-model:checked="selectedItem.hidden">隐藏</a-checkbox>
        </a-form-item>
        <a-form-item label="栅格占比 (1-24)">
          <a-slider 
            v-model:value="selectedItem.span" 
            :min="1" 
            :max="24" 
            :marks="{ 6: '6', 8: '8', 12: '12', 24: '24' }"
          />
        </a-form-item>
        <a-form-item label="占位符" v-if="['input', 'textarea'].includes(selectedItem.type)">
          <a-input v-model:value="selectedItem.placeholder" />
        </a-form-item>

        <div v-if="selectedItem.type === 'text'">
           <a-form-item label="内容">
             <a-textarea v-model:value="selectedItem.content" :rows="4" />
           </a-form-item>
           <a-form-item label="字体大小">
             <a-input-number v-model:value="selectedItem.fontSize" />
           </a-form-item>
           <a-form-item label="粗体">
             <a-switch v-model:checked="selectedItem.bold" />
           </a-form-item>
           <a-form-item label="对齐方式">
             <a-radio-group v-model:value="selectedItem.align" button-style="solid">
               <a-radio-button value="left">左</a-radio-button>
               <a-radio-button value="center">中</a-radio-button>
               <a-radio-button value="right">右</a-radio-button>
             </a-radio-group>
           </a-form-item>
           <a-form-item label="颜色">
              <a-input type="color" v-model:value="selectedItem.color" style="width: 100%; height: 32px;" />
            </a-form-item>
         </div>

         <div v-if="selectedItem.type === 'rich-text'">
           <a-form-item label="内容编辑">
             <a-button type="primary" block @click="$emit('open-rich-text-modal')">
               <EditOutlined /> 编辑富文本内容
             </a-button>
           </a-form-item>
         </div>

         <div v-if="selectedItem.type === 'divider'">
           <a-form-item label="文字内容">
             <a-input v-model:value="selectedItem.text" />
           </a-form-item>
           <a-form-item label="文字位置">
             <a-radio-group v-model:value="selectedItem.orientation" button-style="solid">
               <a-radio-button value="left">左</a-radio-button>
               <a-radio-button value="center">中</a-radio-button>
               <a-radio-button value="right">右</a-radio-button>
             </a-radio-group>
           </a-form-item>
           <a-form-item label="虚线">
             <a-switch v-model:checked="selectedItem.dashed" />
           </a-form-item>
           <a-form-item label="上间距 (px)">
             <a-input-number v-model:value="selectedItem.marginTop" />
           </a-form-item>
           <a-form-item label="下间距 (px)">
             <a-input-number v-model:value="selectedItem.marginBottom" />
           </a-form-item>
        </div>

        <div v-if="selectedItem.type === 'subtable'">
          <SubtableConfiguration
            :selectedItem="selectedItem"
            :selectedSubtableColumn="selectedSubtableColumn"
            :formItems="formItems"
          />
        </div>

        <div v-if="selectedItem.type === 'calculation'">
           <a-form-item label="计算公式">
             <CalculationFormulaEditor
               v-model="selectedItem.formula"
               :formItems="formItems"
               :currentItemId="selectedItem.id"
             />
           </a-form-item>
           <a-form-item label="结果类型">
             <a-select v-model:value="selectedItem.returnType">
               <a-select-option value="number">数字</a-select-option>
               <a-select-option value="string">文本</a-select-option>
             </a-select>
           </a-form-item>
        </div>

        <div v-if="selectedItem.type === 'current-time'">
           <a-form-item label="日期格式">
             <a-select v-model:value="selectedItem.format">
               <a-select-option value="YYYY-MM-DD HH:mm:ss">YYYY-MM-DD HH:mm:ss</a-select-option>
               <a-select-option value="YYYY-MM-DD">YYYY-MM-DD</a-select-option>
               <a-select-option value="HH:mm:ss">HH:mm:ss</a-select-option>
             </a-select>
           </a-form-item>
        </div>

        <div v-if="selectedItem.type === 'current-user'">
           <a-form-item label="显示属性">
             <a-select v-model:value="selectedItem.showField">
               <a-select-option value="name">姓名</a-select-option>
               <a-select-option value="id">工号/ID</a-select-option>
               <a-select-option value="dept">部门</a-select-option>
             </a-select>
           </a-form-item>
        </div>
      </a-form>
    </div>
    <div v-else class="empty-properties">
      请选择组件设置属性
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue';
import { EditOutlined } from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import SubtableConfiguration from './SubtableConfiguration.vue';
import CalculationFormulaEditor from './CalculationFormulaEditor.vue';

const props = defineProps({
  selectedItem: {
    type: Object,
    default: null
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

const emit = defineEmits(['open-rich-text-modal']);

const editingFieldOriginalValue = ref('');

// Only watch selectedItem for field changes in the main panel
watch(() => props.selectedItem, (newVal) => {
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
  // Only handle selectedItem field change
  if (!props.selectedItem) return;
  
  // Skip if we are editing a subtable column (this is handled in SubtableConfiguration)
  // Actually, if selectedSubtableColumn is present, we shouldn't be editing the main item's field here anyway
  // But wait, the main item's field input is always visible if selectedItem is selected.
  // The original logic checked if selectedSubtableColumn was set.
  // Now, since we removed the subtable column editing from this template,
  // we only care about the main item's field.
  
  // However, if the user selects a subtable, selectedItem is the subtable.
  // PropertiesPanel shows "Field Name" for the subtable itself (lines 10-12).
  // This function handles THAT input.
  
  const currentField = props.selectedItem.field;
  const currentId = props.selectedItem.id;

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
          props.selectedItem.field = editingFieldOriginalValue.value;
        }
      }, 0);
    }
  } else {
    editingFieldOriginalValue.value = currentField;
  }
};
</script>

<style scoped>
.properties-panel {
  width: 300px;
  background: #fff;
  border-left: 1px solid #ddd;
  padding: 10px;
}

.panel-title {
  font-weight: bold;
  margin-bottom: 10px;
  padding-bottom: 10px;
  border-bottom: 1px solid #eee;
}

.empty-properties {
  text-align: center;
  color: #999;
  margin-top: 50px;
}
.subtable-props {
    /* Styles specific to subtable props if any */
}

.subtable-column-props {
    /* Styles */
}

.no-column-selected {
    /* Styles */
}
</style>
