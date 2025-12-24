<template>
  <a-tooltip :title="isFullscreen ? '退出全屏' : '全屏模式'">
    <a-button type="text" shape="circle" @click="toggleFullscreen">
      <template #icon>
        <DynamicIcon :icon="isFullscreen ? 'ant-design:fullscreen-exit-outlined' : 'ant-design:fullscreen-outlined'" />
      </template>
    </a-button>
  </a-tooltip>
</template>

<script lang="ts" setup>
import { ref, onMounted, onUnmounted } from 'vue';
import DynamicIcon from '@/components/DynamicIcon.vue';

const isFullscreen = ref(false);

const toggleFullscreen = () => {
  if (!document.fullscreenElement) {
    document.documentElement.requestFullscreen();
  } else {
    if (document.exitFullscreen) {
      document.exitFullscreen();
    }
  }
};

const checkFullscreen = () => {
  isFullscreen.value = !!document.fullscreenElement;
};

onMounted(() => {
  document.addEventListener('fullscreenchange', checkFullscreen);
});

onUnmounted(() => {
  document.removeEventListener('fullscreenchange', checkFullscreen);
});
</script>
