<template>
  <div class="dwg-preview-container">
    <a-result
      status="info"
      title="正在唤起桌面客户端进行预览"
      sub-title="由于图纸文件较大，为了提供更好的预览体验，请使用桌面客户端查看。"
    >
      <template #extra>
        <a-button type="primary" :href="desktopLink">
          如果未自动打开，请点击这里
        </a-button>
        <div style="margin-top: 16px">
          <a-typography-text type="secondary">
            还没有安装桌面客户端？
            <a href="#">点击下载</a>
          </a-typography-text>
        </div>
      </template>
    </a-result>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue';
import { useRoute } from 'vue-router';

const route = useRoute();
const docId = ref('');
const fileName = ref('');

const desktopLink = computed(() => {
  return `oms://preview?id=${docId.value}&name=${encodeURIComponent(fileName.value)}`;
});

onMounted(() => {
  docId.value = route.params.id as string || '';
  fileName.value = route.query.name as string || `Document-${docId.value}.dwg`;
  
  if (docId.value) {
    // Attempt to launch automatically
    window.location.href = desktopLink.value;
  }
});
</script>

<style scoped>
.dwg-preview-container {
  height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  background: #f0f2f5;
}
</style>
