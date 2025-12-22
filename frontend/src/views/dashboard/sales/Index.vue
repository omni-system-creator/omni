<template>
  <div class="dashboard-container">
    <!-- Sales Stats -->
    <a-row :gutter="16">
      <a-col :span="6">
        <a-card>
          <a-statistic title="本月个人业绩 (万)" :value="85.4" :precision="1" suffix=" / 100">
            <template #prefix><trophy-outlined style="color: #faad14" /></template>
          </a-statistic>
          <a-progress :percent="85.4" status="active" stroke-color="#faad14" style="margin-top: 10px" />
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card>
          <a-statistic title="销售漏斗总值 (万)" :value="420.5" :precision="1">
            <template #prefix><funnel-plot-outlined style="color: #1890ff" /></template>
          </a-statistic>
          <div class="stat-desc">潜在商机: 15 个</div>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card>
          <a-statistic title="本季度赢单率" :value="32.5" suffix="%">
            <template #prefix><aim-outlined style="color: #52c41a" /></template>
          </a-statistic>
          <div class="stat-desc">行业平均: 25%</div>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card>
          <a-statistic title="待签合同金额 (万)" :value="120.0" :precision="1">
            <template #prefix><file-done-outlined style="color: #eb2f96" /></template>
          </a-statistic>
          <div class="stat-desc">预计下周回款: 50万</div>
        </a-card>
      </a-col>
    </a-row>

    <!-- Charts Area -->
    <a-row :gutter="16" style="margin-top: 16px;">
      <a-col :span="12">
        <a-card title="销售漏斗分析" :bordered="false">
          <div ref="funnelChart" style="height: 400px;"></div>
        </a-card>
      </a-col>
      <a-col :span="12">
        <a-card title="月度业绩趋势" :bordered="false">
          <div ref="trendChart" style="height: 400px;"></div>
        </a-card>
      </a-col>
    </a-row>

    <!-- Hot Leads & Contracts -->
    <a-row :gutter="16" style="margin-top: 16px;">
      <a-col :span="14">
        <a-card title="重点跟进商机 (Hot Leads)" :bordered="false">
          <a-table :dataSource="leads" :columns="leadColumns" pagination="false" size="small">
            <template #bodyCell="{ column, record }">
              <template v-if="column.key === 'probability'">
                <a-progress :percent="record.probability" size="small" :status="record.probability > 70 ? 'success' : 'active'" />
              </template>
              <template v-if="column.key === 'action'">
                <a-button type="link" size="small">跟进</a-button>
              </template>
            </template>
          </a-table>
        </a-card>
      </a-col>
      <a-col :span="10">
        <a-card title="待办事项提醒" :bordered="false">
          <a-list item-layout="horizontal" :data-source="todos">
            <template #renderItem="{ item }">
              <a-list-item>
                <a-list-item-meta :description="item.time">
                  <template #title>
                    <a href="#">{{ item.title }}</a>
                  </template>
                  <template #avatar>
                    <a-avatar :style="{ backgroundColor: item.color, verticalAlign: 'middle' }">
                      {{ item.type }}
                    </a-avatar>
                  </template>
                </a-list-item-meta>
              </a-list-item>
            </template>
          </a-list>
        </a-card>
      </a-col>
    </a-row>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import * as echarts from 'echarts';
import {
  TrophyOutlined,
  FunnelPlotOutlined,
  AimOutlined,
  FileDoneOutlined
} from '@ant-design/icons-vue';

const funnelChart = ref(null);
const trendChart = ref(null);

const leads = [
  { key: '1', customer: 'XX 科技股份有限公司', amount: '80万', stage: '方案验证', probability: 80 },
  { key: '2', customer: 'XX 城市商业银行', amount: '150万', stage: '商务谈判', probability: 60 },
  { key: '3', customer: 'XX 智慧物流园', amount: '45万', stage: '需求调研', probability: 30 },
  { key: '4', customer: 'XX 跨境电商平台', amount: '200万', stage: '初步接触', probability: 10 },
];

const leadColumns = [
  { title: '客户名称', dataIndex: 'customer', key: 'customer' },
  { title: '预计金额', dataIndex: 'amount', key: 'amount' },
  { title: '当前阶段', dataIndex: 'stage', key: 'stage' },
  { title: '赢单概率', key: 'probability', width: 150 },
  { title: '操作', key: 'action' },
];

const todos = [
  { title: '回访客户：张总 (XX 科技)', time: '今天 14:30', type: '访', color: '#1890ff' },
  { title: '准备投标书：XX 银行项目', time: '明天 10:00 截止', type: '标', color: '#ff4d4f' },
  { title: '合同评审会', time: '周五 16:00', type: '会', color: '#52c41a' },
];

onMounted(() => {
  // Funnel Chart
  const fChart = echarts.init(funnelChart.value);
  fChart.setOption({
    tooltip: { trigger: 'item', formatter: '{b} : {c}%' },
    legend: { data: ['线索', '初步接触', '需求调研', '方案验证', '商务谈判', '赢单'] },
    series: [
      {
        name: 'Funnel',
        type: 'funnel',
        left: '10%',
        top: 60,
        bottom: 60,
        width: '80%',
        min: 0,
        max: 100,
        minSize: '0%',
        maxSize: '100%',
        sort: 'descending',
        gap: 2,
        label: { show: true, position: 'inside' },
        labelLine: { length: 10, lineStyle: { width: 1, type: 'solid' } },
        itemStyle: { borderColor: '#fff', borderWidth: 1 },
        emphasis: { label: { fontSize: 20 } },
        data: [
          { value: 100, name: '线索' },
          { value: 80, name: '初步接触' },
          { value: 60, name: '需求调研' },
          { value: 40, name: '方案验证' },
          { value: 20, name: '商务谈判' },
          { value: 10, name: '赢单' }
        ]
      }
    ]
  });

  // Trend Chart
  const tChart = echarts.init(trendChart.value);
  tChart.setOption({
    tooltip: { trigger: 'axis' },
    xAxis: { type: 'category', data: ['1月', '2月', '3月', '4月', '5月', '6月'] },
    yAxis: { type: 'value', name: '金额 (万)' },
    series: [
      {
        data: [20, 35, 40, 55, 60, 85.4],
        type: 'bar',
        itemStyle: { color: '#1890ff' },
        showBackground: true,
        backgroundStyle: { color: 'rgba(180, 180, 180, 0.2)' }
      },
      {
        data: [20, 35, 40, 55, 60, 85.4],
        type: 'line',
        itemStyle: { color: '#faad14' }
      }
    ]
  });

  window.addEventListener('resize', () => {
    fChart.resize();
    tChart.resize();
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
