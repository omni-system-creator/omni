<template>
  <a-result status="404" title="404" sub-title="抱歉，您访问的页面不存在。">
    <template #extra>
      <a-button type="primary" @click="router.push('/')">返回首页</a-button>
    </template>
  </a-result>
</template>

<script lang="ts" setup>
import { useRouter } from 'vue-router';
const router = useRouter();
</script>
