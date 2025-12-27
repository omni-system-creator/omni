<template>
  <a-alert message="发送响应" type="info" show-icon style="margin-bottom: 16px">
    <template #description>
      <div style="font-size: 12px;">
        <p>结束流程并返回数据。</p>
        <p><strong>默认行为:</strong> 自动返回上下文中的最后一次操作结果 (例如 <code>dbResult</code>)。</p>
        <p><strong>自定义:</strong> 如需返回特定结构，请在响应节点前添加“脚本逻辑”节点进行处理。</p>
      </div>
    </template>
  </a-alert>
  <a-form-item label="响应类型">
    <a-select v-model:value="node.data.contentType" defaultValue="json">
      <a-select-option value="json">JSON</a-select-option>
      <a-select-option value="xml">XML</a-select-option>
      <a-select-option value="text">Text</a-select-option>
    </a-select>
  </a-form-item>
</template>

<script setup lang="ts">
defineProps<{
  node: any;
  readOnly?: boolean;
}>();
</script>
