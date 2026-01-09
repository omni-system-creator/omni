<template>
  <div class="dashboard-container">
    <!-- Procurement Stats -->
    <a-row :gutter="16">
      <a-col :span="6">
        <a-card>
          <a-statistic title="年度采购总额 (万)" :value="1250" :precision="2">
            <template #prefix><shopping-cart-outlined style="color: #1890ff" /></template>
          </a-statistic>
          <div class="stat-desc">预算使用率: 78%</div>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card>
          <a-statistic title="本月节约成本 (万)" :value="45.2" :precision="2">
            <template #prefix><pay-circle-outlined style="color: #52c41a" /></template>
          </a-statistic>
          <div class="stat-desc">同比去年: +12%</div>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card>
          <a-statistic title="待审批采购申请" :value="8" suffix="单">
            <template #prefix><audit-outlined style="color: #faad14" /></template>
          </a-statistic>
          <div class="stat-desc">其中急件: 2 单</div>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card>
          <a-statistic title="活跃供应商" :value="124" suffix="家">
            <template #prefix><shop-outlined style="color: #722ed1" /></template>
          </a-statistic>
          <div class="stat-desc">本月新增: 3 家</div>
        </a-card>
      </a-col>
    </a-row>

    <!-- Charts -->
    <a-row :gutter="16" style="margin-top: 16px;">
      <a-col :span="12">
        <a-card title="采购品类支出分析" :bordered="false">
          <div ref="categoryChart" style="height: 350px;"></div>
        </a-card>
      </a-col>
      <a-col :span="12">
        <a-card title="供应商绩效评分 TOP5" :bordered="false">
          <div ref="supplierChart" style="height: 350px;"></div>
        </a-card>
      </a-col>
    </a-row>

    <!-- Recent Requests -->
    <a-card title="待处理采购申请" :bordered="false" style="margin-top: 16px;">
      <a-table :dataSource="requests" :columns="columns" :pagination="false">
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'status'">
            <a-badge :status="record.status === 'urgent' ? 'error' : 'processing'" :text="record.statusText" />
          </template>
          <template v-if="column.key === 'action'">
            <a-space>
              <a href="#">审批</a>
              <a href="#">退回</a>
            </a-space>
          </template>
        </template>
      </a-table>
    </a-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import * as echarts from 'echarts';
import {
  ShoppingCartOutlined,
  PayCircleOutlined,
  AuditOutlined,
  ShopOutlined
} from '@ant-design/icons-vue';

const categoryChart = ref(null);
const supplierChart = ref(null);

const requests = [
  { key: '1', id: 'PR-20231025-01', dept: '研发中心', item: '高性能服务器 (GPU)', amount: '350,000', status: 'urgent', statusText: '急需审批', date: '2023-10-25' },
  { key: '2', id: 'PR-20231025-02', dept: '行政部', item: '办公笔记本电脑 (20台)', amount: '120,000', status: 'normal', statusText: '待审批', date: '2023-10-25' },
  { key: '3', id: 'PR-20231024-05', dept: '市场部', item: '展会搭建服务', amount: '80,000', status: 'normal', statusText: '待审批', date: '2023-10-24' },
];

const columns = [
  { title: '申请单号', dataIndex: 'id', key: 'id' },
  { title: '申请部门', dataIndex: 'dept', key: 'dept' },
  { title: '采购内容', dataIndex: 'item', key: 'item' },
  { title: '预估金额', dataIndex: 'amount', key: 'amount' },
  { title: '申请日期', dataIndex: 'date', key: 'date' },
  { title: '状态', key: 'status' },
  { title: '操作', key: 'action' },
];

onMounted(() => {
  // Category Pie Chart
  const cChart = echarts.init(categoryChart.value);
  cChart.setOption({
    tooltip: { trigger: 'item' },
    legend: { orient: 'vertical', left: 'left' },
    series: [
      {
        name: '采购支出',
        type: 'pie',
        radius: '50%',
        data: [
          { value: 450, name: 'IT 硬件设备' },
          { value: 320, name: '软件授权许可' },
          { value: 280, name: '外包服务' },
          { value: 120, name: '办公用品' },
          { value: 80, name: '营销物料' }
        ],
        emphasis: {
          itemStyle: { shadowBlur: 10, shadowOffsetX: 0, shadowColor: 'rgba(0, 0, 0, 0.5)' }
        }
      }
    ]
  });

  // Supplier Bar Chart
  const sChart = echarts.init(supplierChart.value);
  sChart.setOption({
    tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
    grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
    xAxis: { type: 'value', max: 100 },
    yAxis: { type: 'category', data: ['Dell', 'Microsoft', 'AWS', 'Salesforce', 'Lenovo'] },
    series: [
      {
        name: '评分',
        type: 'bar',
        data: [95, 92, 88, 85, 82],
        itemStyle: { color: '#52c41a' },
        label: { show: true, position: 'right' }
      }
    ]
  });

  window.addEventListener('resize', () => {
    cChart.resize();
    sChart.resize();
  });
});
</script>

<style scoped>
.dashboard-container {
  padding: 16px;
  background-color: #f0f2f5;
  min-height: 100vh;
}
.stat-desc {
  font-size: 12px;
  color: #8c8c8c;
  margin-top: 8px;
}
</style>
