<template>
  <div class="widget-card">
    <div class="card-header">
      <h3>系统状态</h3>
    </div>
    <div class="status-container">
      <div class="status-item">
        <div class="label">
          <span>CPU 使用率</span>
          <span>{{ cpuUsage }}%</span>
        </div>
        <a-progress :percent="cpuUsage" :status="cpuStatus" :show-info="false" />
      </div>
      <div class="status-item">
        <div class="label">
          <span>内存使用率</span>
          <span>{{ memUsage }}%</span>
        </div>
        <a-progress :percent="memUsage" :status="memStatus" stroke-color="#faad14" :show-info="false" />
      </div>
      <div class="status-item">
        <div class="label">
          <span>磁盘空间</span>
          <span>45%</span>
        </div>
        <a-progress :percent="45" stroke-color="#52c41a" :show-info="false" />
      </div>
      <div class="status-summary">
        <a-row :gutter="8">
          <a-col :span="12">
            <div class="stat-box">
              <span class="stat-label">运行时间</span>
              <span class="stat-value">12天 5小时</span>
            </div>
          </a-col>
          <a-col :span="12">
            <div class="stat-box">
              <span class="stat-label">在线节点</span>
              <span class="stat-value">3/3</span>
            </div>
          </a-col>
        </a-row>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue';

const cpuUsage = ref(35);
const memUsage = ref(62);

const cpuStatus = computed(() => cpuUsage.value > 80 ? 'exception' : 'active');
const memStatus = computed(() => memUsage.value > 80 ? 'exception' : 'active');

let timer: any = null;

onMounted(() => {
  timer = setInterval(() => {
    // Mock fluctuations
    cpuUsage.value = Math.max(10, Math.min(95, cpuUsage.value + Math.floor(Math.random() * 10) - 5));
    memUsage.value = Math.max(40, Math.min(90, memUsage.value + Math.floor(Math.random() * 6) - 3));
  }, 3000);
});

onUnmounted(() => {
  if (timer) clearInterval(timer);
});
</script>

<style scoped>
.widget-card {
  height: 100%;
  padding: 16px;
  background: #fff;
  border-radius: 8px;
  display: flex;
  flex-direction: column;
}
.card-header {
  margin-bottom: 16px;
  border-bottom: 1px solid #f0f0f0;
  padding-bottom: 8px;
}
.card-header h3 {
  margin: 0;
  font-size: 16px;
  color: #333;
}
.status-container {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: space-around;
}
.status-item {
  margin-bottom: 12px;
}
.status-item .label {
  display: flex;
  justify-content: space-between;
  margin-bottom: 4px;
  font-size: 13px;
  color: #666;
}
.status-summary {
  margin-top: 8px;
}
.stat-box {
  background: #f5f7fa;
  padding: 8px;
  border-radius: 4px;
  text-align: center;
}
.stat-label {
  display: block;
  font-size: 12px;
  color: #999;
}
.stat-value {
  display: block;
  font-size: 14px;
  font-weight: bold;
  color: #333;
}
</style>
