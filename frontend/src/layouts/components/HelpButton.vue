<template>
  <a-tooltip title="使用文档">
    <a-button type="text" shape="circle" @click="router.push('/help/manual')">
      <template #icon><DynamicIcon icon="ant-design:question-circle-outlined" /></template>
    </a-button>
  </a-tooltip>
</template>

<script lang="ts" setup>
import { useRouter } from 'vue-router';
import DynamicIcon from '@/components/DynamicIcon.vue';

const router = useRouter();
</script>
