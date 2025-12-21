<template>
  <a-tooltip title="消息通知">
    <a-badge count="5" dot>
      <a-button type="text" shape="circle" @click="router.push('/personal/messages')">
        <template #icon><DynamicIcon icon="ant-design:bell-outlined" /></template>
      </a-button>
    </a-badge>
  </a-tooltip>
</template>

<script lang="ts" setup>
import { useRouter } from 'vue-router';
import DynamicIcon from '@/components/DynamicIcon.vue';

const router = useRouter();
</script>
