<template>
  <div class="widget-card">
    <div class="card-header">
      <h3>核心数据</h3>
    </div>
    <div class="stats-container">
      <a-row :gutter="16">
        <a-col :span="12">
          <a-statistic title="今日销售额" :value="112893" :precision="2" prefix="¥">
            <template #suffix>
              <DynamicIcon icon="ant-design:rise-outlined" style="color: #cf1322" />
            </template>
          </a-statistic>
        </a-col>
        <a-col :span="12">
          <a-statistic title="活跃用户" :value="1128" style="margin-right: 50px">
            <template #suffix>
              <DynamicIcon icon="ant-design:arrow-up-outlined" style="color: #3f8600" />
            </template>
          </a-statistic>
        </a-col>
      </a-row>
      <div style="margin-top: 16px;">
        <a-row :gutter="16">
          <a-col :span="12">
            <a-statistic title="待办事项" :value="5" class="warning-stat" />
          </a-col>
          <a-col :span="12">
            <a-statistic title="本月目标完成度" :value="68" suffix="%" />
          </a-col>
        </a-row>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import DynamicIcon from '../DynamicIcon.vue';
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
.stats-container {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
}
</style>
