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

  <a-divider style="margin: 12px 0" />
  
  <div style="margin-bottom: 8px; font-weight: 500;">输出数据</div>
  <a-radio-group v-model:value="node.data.paramMode" style="margin-bottom: 12px" name="paramMode">
    <a-radio-button value="default">默认 (最后结果)</a-radio-button>
    <a-radio-button value="custom">自定义映射</a-radio-button>
  </a-radio-group>
  <div v-if="node.data.paramMode === 'default'" style="font-size: 12px; color: #888; margin-bottom: 16px;">
    自动返回上下文中的最后一次操作结果 (例如 dbResult)。
  </div>

  <template v-if="node.data.paramMode === 'custom'">
    <a-alert type="info" style="margin-bottom: 8px" show-icon>
      <template #message>
        <span style="font-size: 12px">使用 JavaScript 构建返回结构</span>
      </template>
      <template #description>
        <div style="font-size: 12px">
          <p>请编写脚本返回最终数据结构。可用变量: <code>context</code></p>
          <p>示例1：</p>
          <p><pre style="margin: 0; background: rgba(0,0,0,0.05); padding: 4px; border-radius: 4px;">return context;</pre></p>
          <p>示例2：</p>
          <pre style="margin: 0; background: rgba(0,0,0,0.05); padding: 4px; border-radius: 4px;">return context.code_1;</pre>
        </div>
      </template>
    </a-alert>
    <a-textarea 
      v-model:value="node.data.script" 
      :rows="8" 
      placeholder="// Return your response object here..." 
      style="font-family: monospace;" 
    />
  </template>
</template>

<script setup lang="ts">
defineProps<{
  node: any;
  readOnly?: boolean;
}>();
</script>
