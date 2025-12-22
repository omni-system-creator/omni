<template>
  <div class="security-container">
    <a-tabs v-model:activeKey="activeKey" type="card" class="security-tabs">
      <a-tab-pane key="level" tab="密级管理">
        <Level />
      </a-tab-pane>
      <a-tab-pane key="watermark-settings" tab="水印设置">
        <WatermarkSettings />
      </a-tab-pane>
      <a-tab-pane key="watermark-logs" tab="水印日志">
        <WatermarkLogs />
      </a-tab-pane>
    </a-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import Level from './Level.vue';
import WatermarkSettings from './WatermarkSettings.vue';
import WatermarkLogs from './WatermarkLogs.vue';

const activeKey = ref('level');
</script>

<style scoped>
.security-container {
  padding: 16px;
  height: 100%;
  background-color: #f0f2f5;
}
.security-tabs {
  background-color: #fff;
  padding: 16px;
  min-height: 100%;
}
</style>
