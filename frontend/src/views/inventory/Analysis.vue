<template>
  <div class="page-container">
    <a-tabs v-model:activeKey="activeTab">
      <a-tab-pane key="safety" tab="安全库存预警">
        <a-alert message="当前有 3 种物品低于安全库存，请及时补货" type="warning" show-icon style="margin-bottom: 16px" />
        <a-table :columns="safetyColumns" :data-source="safetyData">
          <template #bodyCell="{ column, record }">
            <template v-if="column.key === 'stock'">
              <span style="color: red; font-weight: bold" v-if="record.stock < record.min">{{ record.stock }}</span>
              <span v-else>{{ record.stock }}</span>
            </template>
            <template v-else-if="column.key === 'action'">
              <a-button type="link" size="small">生成采购申请</a-button>
            </template>
          </template>
        </a-table>
      </a-tab-pane>
      
      <a-tab-pane key="value" tab="库存价值分析">
        <a-row :gutter="24">
          <a-col :span="12">
            <a-card title="库存总价值趋势" :bordered="false">
              <div ref="trendChartRef" style="height: 300px"></div>
            </a-card>
          </a-col>
          <a-col :span="12">
            <a-card title="各类目库存价值占比" :bordered="false">
              <div ref="pieChartRef" style="height: 300px"></div>
            </a-card>
          </a-col>
        </a-row>
      </a-tab-pane>
    </a-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue';
import * as echarts from 'echarts';

const activeTab = ref('safety');
const trendChartRef = ref<HTMLElement | null>(null);
const pieChartRef = ref<HTMLElement | null>(null);
let trendChart: echarts.ECharts | null = null;
let pieChart: echarts.ECharts | null = null;

const safetyColumns = [
  { title: '物品编码', dataIndex: 'code', key: 'code' },
  { title: '物品名称', dataIndex: 'name', key: 'name' },
  { title: '当前库存', dataIndex: 'stock', key: 'stock' },
  { title: '安全库存下限', dataIndex: 'min', key: 'min' },
  { title: '建议补货量', dataIndex: 'suggest', key: 'suggest' },
  { title: '操作', key: 'action' },
];

const safetyData = [
  { code: 'P001', name: '高端芯片X', stock: 50, min: 100, suggest: 200 },
  { code: 'P002', name: '专用电阻R', stock: 800, min: 1000, suggest: 500 },
  { code: 'P003', name: '连接器C', stock: 120, min: 200, suggest: 300 },
];

const initCharts = () => {
  // Wait for DOM
  setTimeout(() => {
    if (trendChartRef.value) {
      trendChart = echarts.init(trendChartRef.value);
      trendChart.setOption({
        tooltip: { trigger: 'axis' },
        xAxis: { type: 'category', data: ['1月', '2月', '3月', '4月', '5月', '6月'] },
        yAxis: { type: 'value', name: '万元' },
        series: [{ data: [120, 132, 101, 134, 90, 230], type: 'line', smooth: true }]
      });
    }
    if (pieChartRef.value) {
      pieChart = echarts.init(pieChartRef.value);
      pieChart.setOption({
        tooltip: { trigger: 'item' },
        series: [{
          type: 'pie',
          radius: '50%',
          data: [
            { value: 1048, name: '电子元器件' },
            { value: 735, name: '机械部件' },
            { value: 580, name: '办公用品' },
          ]
        }]
      });
    }
  }, 100);
};

const handleResize = () => {
  trendChart?.resize();
  pieChart?.resize();
};

onMounted(() => {
  // Only init charts if tab is active, but since we use v-show (tabs), we might need to watch activeTab
  // Simple hack: init anyway, or watch activeTab. 
  // For simplicity in this demo, we can init when tab changes or just try to init.
  // Actually Ant Design Vue Tabs unmounts hidden tabs by default unless forceRender is used.
  // Let's watch activeTab
});

import { watch } from 'vue';
watch(activeTab, (val) => {
  if (val === 'value') {
    initCharts();
  }
});
// Also init if start with value (unlikely but good practice)
if (activeTab.value === 'value') initCharts();

onUnmounted(() => {
  window.removeEventListener('resize', handleResize);
  trendChart?.dispose();
  pieChart?.dispose();
});
</script>

<style scoped>
.page-container {
  padding: 24px;
  background: #fff;
  min-height: 100%;
}
</style>