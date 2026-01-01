<script setup lang="ts">
import { useProjectStore } from '../stores/projectStore'
import { computed } from 'vue'

const store = useProjectStore()

const statusText = computed(() => {
  if (store.saveStatus === 'saving') return '正在保存...'
  if (store.saveStatus === 'error') return '保存失败'
  if (store.saveStatus === 'synced' && store.lastSyncTime) {
    const timeStr = store.lastSyncTime.toLocaleTimeString();
    const userStr = store.lastSyncUser ? `来自 ${store.lastSyncUser} 的` : '';
    return `已同步${userStr}修改 ${timeStr}`;
  }
  if (store.saveStatus === 'saved' && store.lastSaveTime) {
    return `自动保存成功 ${store.lastSaveTime.toLocaleTimeString()}`
  }
  return ''
})
</script>

<template>
  <div class="status-bar">
    <span>{{ statusText }}</span>
  </div>
</template>

<style scoped>
.status-bar {
  height: 24px;
  background: #f5f5f5;
  border-top: 1px solid #e0e0e0;
  display: flex;
  align-items: center;
  padding: 0 16px;
  font-size: 12px;
  color: #888;
  flex-shrink: 0;
}
</style>