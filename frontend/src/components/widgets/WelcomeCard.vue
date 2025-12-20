<template>
  <div class="widget-card welcome-card">
    <h3>欢迎回来，Admin</h3>
    <p>今天是 {{ currentDate }}，祝您工作愉快！</p>
    <div style="margin-top: 10px;">
      <a-tag color="blue">V1.0.0</a-tag>
      <span style="font-size: 12px; color: #666;">系统运行正常</span>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import dayjs from 'dayjs';

const currentDate = computed(() => dayjs().format('YYYY年MM月DD日'));
</script>

<style scoped>
.widget-card {
  height: 100%;
  padding: 20px;
  background: #fff;
  border-radius: 8px;
  display: flex;
  flex-direction: column;
  justify-content: center;
}
.welcome-card {
  background: #fff;
  color: #333;
  border: 1px solid #f0f0f0;
}
h3 {
  color: #333;
  margin-bottom: 8px;
}
</style>
