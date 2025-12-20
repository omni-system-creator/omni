<template>
  <div class="page-container">
    <a-row :gutter="24">
      <a-col :span="12">
        <a-card title="年度采购支出趋势" :bordered="false">
          <div ref="trendChartRef" style="height: 300px"></div>
        </a-card>
      </a-col>
      <a-col :span="12">
        <a-card title="采购品类占比" :bordered="false">
          <div ref="categoryChartRef" style="height: 300px"></div>
        </a-card>
      </a-col>
    </a-row>

    <div class="history-list" style="margin-top: 24px">
      <a-card title="历史采购记录" :bordered="false">
        <template #extra>
          <a-range-picker style="margin-right: 16px" />
          <a-button>导出报表</a-button>
        </template>
        <a-table :columns="columns" :data-source="historyList" />
      </a-card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue';
import * as echarts from 'echarts';

const trendChartRef = ref<HTMLElement | null>(null);
const categoryChartRef = ref<HTMLElement | null>(null);
let trendChart: echarts.ECharts | null = null;
let categoryChart: echarts.ECharts | null = null;

const columns = [
  { title: '完成日期', dataIndex: 'date', key: 'date' },
  { title: '采购单号', dataIndex: 'orderId', key: 'orderId' },
  { title: '供应商', dataIndex: 'supplier', key: 'supplier' },
  { title: '品类', dataIndex: 'category', key: 'category' },
  { title: '金额', dataIndex: 'amount', key: 'amount' },
  { title: '评价', dataIndex: 'rating', key: 'rating' },
];

const historyList = [
  { date: '2025-11-15', orderId: 'PO20251115001', supplier: 'XX电子', category: '原材料', amount: '¥ 500,000', rating: '满意' },
  { date: '2025-10-20', orderId: 'PO20251020003', supplier: 'YY设备', category: '设备设施', amount: '¥ 120,000', rating: '一般' },
  { date: '2025-09-05', orderId: 'PO20250905008', supplier: 'ZZ服务', category: '服务外包', amount: '¥ 80,000', rating: '满意' },
];

const initCharts = () => {
  if (trendChartRef.value) {
    trendChart = echarts.init(trendChartRef.value);
    trendChart.setOption({
      tooltip: { trigger: 'axis' },
      xAxis: { type: 'category', data: ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'] },
      yAxis: { type: 'value' },
      series: [{ data: [150, 230, 224, 218, 135, 147, 260, 200, 300, 250, 400, 350], type: 'line', smooth: true }]
    });
  }

  if (categoryChartRef.value) {
    categoryChart = echarts.init(categoryChartRef.value);
    categoryChart.setOption({
      tooltip: { trigger: 'item' },
      legend: { bottom: '0%' },
      series: [{
        type: 'pie',
        radius: ['40%', '70%'],
        data: [
          { value: 1048, name: '原材料' },
          { value: 735, name: '设备设施' },
          { value: 580, name: '服务外包' },
          { value: 484, name: '办公用品' },
        ]
      }]
    });
  }
};

const handleResize = () => {
  trendChart?.resize();
  categoryChart?.resize();
};

onMounted(() => {
  initCharts();
  window.addEventListener('resize', handleResize);
});

onUnmounted(() => {
  window.removeEventListener('resize', handleResize);
  trendChart?.dispose();
  categoryChart?.dispose();
});
</script>

<style scoped>
.page-container {
  padding: 24px;
}
</style>