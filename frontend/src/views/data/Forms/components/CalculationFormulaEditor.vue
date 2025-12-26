<template>
  <div class="formula-editor">
    <div class="editor-area">
      <a-textarea 
        v-model:value="formula" 
        :rows="4" 
        placeholder="点击下方字段或运算符生成公式"
        @change="handleChange"
      />
    </div>
    
    <div class="operators-area">
      <div class="area-title">运算符</div>
      <div class="operator-buttons">
        <a-button size="small" v-for="op in operators" :key="op" @click="insertText(op)">{{ op }}</a-button>
      </div>
    </div>

    <div class="fields-area">
      <div class="area-title">可用字段</div>
      <div class="field-list" v-if="availableFields.length > 0">
        <a-tag 
          v-for="field in availableFields" 
          :key="field.value" 
          color="blue" 
          style="cursor: pointer; margin-bottom: 5px;"
          @click="insertText('{' + field.value + '}')"
        >
          {{ field.label }}
        </a-tag>
      </div>
      <div v-else class="no-fields">暂无数字类型的可用字段</div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue';

const props = defineProps({
  modelValue: {
    type: String,
    default: ''
  },
  formItems: {
    type: Array as () => any[],
    default: () => []
  },
  currentItemId: {
    type: String,
    default: ''
  }
});

const emit = defineEmits(['update:modelValue']);

const formula = ref(props.modelValue);
// const textareaRef = ref();

watch(() => props.modelValue, (val) => {
  if (val !== formula.value) {
    formula.value = val;
  }
});

const operators = ['+', '-', '*', '/', '(', ')'];

const availableFields = computed(() => {
  const fields: { label: string; value: string }[] = [];
  
  const traverse = (items: any[]) => {
    items.forEach(item => {
      // Exclude current item to avoid self-reference
      if (item.id === props.currentItemId) return;

      // Only include number inputs or calculation components
      if (['number', 'calculation'].includes(item.type)) {
        fields.push({
          label: item.label,
          value: item.field
        });
      }
      
      // Handle subtables - usually we don't calculate across subtable rows in a simple formula,
      // but for now let's keep it simple and only include main form items or maybe aggregate subtable fields later.
      // For this implementation, we'll stick to top-level items for simplicity unless requested.
    });
  };

  traverse(props.formItems);
  return fields;
});

const insertText = (text: string) => {
  // const textarea = textareaRef.value?.$el?.nextElementSibling || textareaRef.value?.$el; // Antdv textarea might wrap input
  // Fallback if ref structure is different in different antd versions, simpler approach:
  // Just append for now, proper cursor insertion requires more DOM manipulation which might be flaky without direct access.
  // Let's try to append to end for simplicity, or use simple string concat.
  
  // Improvement: Insert at cursor position if possible
  // Since we don't have easy access to cursor position in this simple setup without more complex logic,
  // appending is a safe MVP.
  formula.value += text;
  emit('update:modelValue', formula.value);
};

const handleChange = () => {
  emit('update:modelValue', formula.value);
};
</script>

<style scoped>
.formula-editor {
  border: 1px solid #d9d9d9;
  border-radius: 4px;
  padding: 10px;
  background: #fafafa;
}

.area-title {
  font-size: 12px;
  font-weight: bold;
  color: #666;
  margin-bottom: 5px;
  margin-top: 10px;
}

.operator-buttons {
  display: flex;
  gap: 5px;
  flex-wrap: wrap;
}

.fields-area {
  margin-top: 10px;
}

.field-list {
  display: flex;
  flex-wrap: wrap;
  gap: 5px;
}

.no-fields {
  font-size: 12px;
  color: #999;
}
</style>