<template>
  <a-alert message="流程入口" type="info" show-icon style="margin-bottom: 16px">
    <template #description>
      <div style="font-size: 12px;">
        <p>接收外部HTTP请求，参数将注入到上下文中。</p>
        <p><strong>注意:</strong> 请求路径和方法在“基本信息”中配置，此处仅作为入口定义。</p>
        <p><strong>Input:</strong> Query/Body (e.g. ?id=1001)</p>
        <p><strong>Context:</strong> { id: 1001 }</p>
      </div>
    </template>
  </a-alert>
</template>

<script setup lang="ts">
defineProps<{
  node: any;
  readOnly?: boolean;
}>();
</script>
