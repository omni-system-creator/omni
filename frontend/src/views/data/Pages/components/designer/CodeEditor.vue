<template>
  <div class="code-editor-wrapper" :style="{ height: height || '100%' }">
    <codemirror
      v-model="code"
      :placeholder="placeholder"
      :style="{ height: '100%' }"
      :autofocus="true"
      :indent-with-tab="true"
      :tab-size="2"
      :extensions="extensions"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue';
import { Codemirror } from 'vue-codemirror';
import { basicSetup } from 'codemirror';
import { javascript } from '@codemirror/lang-javascript';
import { json } from '@codemirror/lang-json';
import { css } from '@codemirror/lang-css';
import { oneDark } from '@codemirror/theme-one-dark';

const props = defineProps<{
  value?: string;
  language?: 'javascript' | 'typescript' | 'json' | 'css';
  placeholder?: string;
  height?: string;
  theme?: 'dark' | 'light';
}>();

const emit = defineEmits(['update:value', 'change']);

const code = ref(props.value || '');
const lastEmittedValue = ref(props.value || '');

watch(() => props.value, (newVal) => {
  const val = newVal || '';
  // 只有当新值既不等于当前内部值，也不等于上次发出的值时，才更新内部值
  // 这样可以避免父组件回流旧值覆盖用户新输入的内容
  if (val !== code.value && val !== lastEmittedValue.value) {
    code.value = val;
  }
});

const extensions = computed(() => {
  const exts = [basicSetup];
  
  // Theme
  if (props.theme !== 'light') {
    exts.push(oneDark);
  }

  // Language
  switch (props.language) {
    case 'javascript':
    case 'typescript':
      exts.push(javascript({ typescript: true }));
      break;
    case 'json':
      exts.push(json());
      break;
    case 'css':
      exts.push(css());
      break;
    default:
      break;
  }
  
  return exts;
});

watch(code, (newVal) => {
  if (newVal !== props.value) {
    lastEmittedValue.value = newVal;
    emit('update:value', newVal);
    emit('change', newVal);
  }
});
</script>

<style scoped>
.code-editor-wrapper {
  font-size: 14px;
  border: 1px solid #d9d9d9;
  border-radius: 4px;
  overflow: hidden;
}

:deep(.cm-editor) {
  height: 100%;
}

:deep(.cm-scroller) {
  font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
}
</style>
