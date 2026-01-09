<template>
  <div class="bi-dashboard-container">
    <!-- 顶部筛选栏 -->
    <a-card :bordered="false" class="mb-4">
      <div class="flex justify-between items-center">
        <span class="text-lg font-bold">经营概况 (2024 Q4)</span>
        <a-range-picker v-model:value="dateRange as any" />
      </div>
    </a-card>

    <!-- 核心指标 -->
    <a-row :gutter="24" class="mb-4">
      <a-col :span="6">
        <a-card :bordered="false">
          <a-statistic title="年度经常性收入 (ARR)" :value="1580" prefix="¥" suffix="万" :precision="1">
            <template #suffix>
              <span class="trend-up text-sm ml-2"><ArrowUpOutlined /> 23% YoY</span>
            </template>
          </a-statistic>
          <div class="mt-2 text-gray-500 text-xs">SaaS订阅 + 维护服务</div>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card :bordered="false">
          <a-statistic title="项目交付准时率" :value="92.5" suffix="%">
             <template #suffix>
              <span class="trend-up text-sm ml-2"><ArrowUpOutlined /> 1.5% MoM</span>
            </template>
          </a-statistic>
          <div class="mt-2 text-gray-500 text-xs">在建项目: 12个 | 延期: 1个</div>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card :bordered="false">
          <a-statistic title="人员平均利用率" :value="85.4" suffix="%">
             <template #suffix>
              <span class="trend-down text-sm ml-2"><ArrowDownOutlined /> 2% MoM</span>
            </template>
          </a-statistic>
          <div class="mt-2 text-gray-500 text-xs">研发: 90% | 实施: 78%</div>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card :bordered="false">
          <a-statistic title="客户净推荐值 (NPS)" :value="48" suffix="分">
             <template #suffix>
              <span class="trend-up text-sm ml-2"><ArrowUpOutlined /> 5分</span>
            </template>
          </a-statistic>
          <div class="mt-2 text-gray-500 text-xs">调研样本: 150家客户</div>
        </a-card>
      </a-col>
    </a-row>

    <!-- 图表区域 -->
    <a-row :gutter="24" class="mb-4">
      <a-col :span="16">
        <a-card title="营收构成趋势 (License vs Service)" :bordered="false">
          <div ref="revenueChartRef" style="height: 350px;"></div>
        </a-card>
      </a-col>
      <a-col :span="8">
        <a-card title="研发资源投入分布" :bordered="false">
          <div ref="resourceChartRef" style="height: 350px;"></div>
        </a-card>
      </a-col>
    </a-row>

    <!-- 项目健康度列表 -->
    <a-card title="重点项目健康度监控" :bordered="false">
      <template #extra><a href="#">查看全部</a></template>
      <a-table :columns="projectColumns" :data-source="projectData" :pagination="false" size="middle">
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'status'">
            <a-badge :status="record.statusType" :text="record.status" />
          </template>
          <template v-if="column.key === 'progress'">
            <a-progress :percent="record.progress" size="small" :status="record.progress === 100 ? 'success' : 'active'" />
          </template>
           <template v-if="column.key === 'risk'">
            <a-tag :color="record.risk === 'High' ? 'red' : (record.risk === 'Medium' ? 'orange' : 'green')">
              {{ record.risk }}
            </a-tag>
          </template>
        </template>
      </a-table>
    </a-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { ArrowUpOutlined, ArrowDownOutlined } from '@ant-design/icons-vue';
import * as echarts from 'echarts';
import dayjs from 'dayjs';

const dateRange = ref([dayjs().subtract(30, 'days'), dayjs()]);
const revenueChartRef = ref();
const resourceChartRef = ref();

const projectColumns = [
  { title: '项目名称', dataIndex: 'name', key: 'name' },
  { title: '客户', dataIndex: 'client', key: 'client' },
  { title: '阶段', dataIndex: 'stage', key: 'stage' },
  { title: '进度', dataIndex: 'progress', key: 'progress', width: 200 },
  { title: '状态', dataIndex: 'status', key: 'status' },
  { title: '风险等级', dataIndex: 'risk', key: 'risk' },
  { title: '交付日期', dataIndex: 'deadline', key: 'deadline' }
];

const projectData = [
  { key: 1, name: 'OMS 系统 2.0 升级', client: '集团内部', stage: '开发中', progress: 65, status: '正常', statusType: 'success', risk: 'Low', deadline: '2025-02-15' },
  { key: 2, name: '智慧物流 ERP 定制', client: '顺丰速运', stage: 'UAT测试', progress: 92, status: '风险', statusType: 'warning', risk: 'Medium', deadline: '2025-01-20' },
  { key: 3, name: 'CRM 数据迁移项目', client: '字节跳动', stage: '需求分析', progress: 15, status: '正常', statusType: 'processing', risk: 'Low', deadline: '2025-03-01' },
  { key: 4, name: 'AI 智能客服集成', client: '招商银行', stage: '开发中', progress: 45, status: '延期', statusType: 'error', risk: 'High', deadline: '2024-12-30' },
  { key: 5, name: '供应链协同平台', client: '联想集团', stage: '系统部署', progress: 98, status: '正常', statusType: 'success', risk: 'Low', deadline: '2025-01-10' }
];

onMounted(() => {
  initCharts();
  window.addEventListener('resize', resizeCharts);
});

let revenueChart: echarts.ECharts;
let resourceChart: echarts.ECharts;

const resizeCharts = () => {
  revenueChart?.resize();
  resourceChart?.resize();
};

const initCharts = () => {
  if (revenueChartRef.value) {
    revenueChart = echarts.init(revenueChartRef.value);
    revenueChart.setOption({
      tooltip: { trigger: 'axis' },
      legend: { data: ['SaaS订阅', '定制开发', '技术服务'] },
      grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
      xAxis: { type: 'category', boundaryGap: false, data: ['7月', '8月', '9月', '10月', '11月', '12月'] },
      yAxis: { type: 'value', name: '万元' },
      series: [
        { name: 'SaaS订阅', type: 'line', smooth: true, stack: 'Total', areaStyle: {}, data: [120, 132, 145, 150, 165, 180] },
        { name: '定制开发', type: 'line', smooth: true, stack: 'Total', areaStyle: {}, data: [220, 182, 191, 234, 290, 330] },
        { name: '技术服务', type: 'line', smooth: true, stack: 'Total', areaStyle: {}, data: [50, 60, 55, 70, 80, 90] }
      ],
      color: ['#5B8FF9', '#5AD8A6', '#F6BD16']
    });
  }

  if (resourceChartRef.value) {
    resourceChart = echarts.init(resourceChartRef.value);
    resourceChart.setOption({
      tooltip: { trigger: 'item' },
      legend: { top: '5%', left: 'center' },
      series: [
        {
          name: '资源投入',
          type: 'pie',
          radius: ['40%', '70%'],
          avoidLabelOverlap: false,
          itemStyle: { borderRadius: 10, borderColor: '#fff', borderWidth: 2 },
          label: { show: false, position: 'center' },
          emphasis: { label: { show: true, fontSize: '18', fontWeight: 'bold' } },
          data: [
            { value: 45, name: '产品研发 (R&D)' },
            { value: 25, name: '项目实施 (Delivery)' },
            { value: 15, name: '客户支持 (Support)' },
            { value: 10, name: '售前咨询 (Pre-sales)' },
            { value: 5, name: '内部运维 (Ops)' }
          ]
        }
      ]
    });
  }
};
</script>

<style scoped>
.bi-dashboard-container {
  padding: 16px;
  flex: 1;
}
.mb-4 {
  margin-bottom: 16px;
}
.trend-up {
  color: #3f8600;
}
.trend-down {
  color: #cf1322;
}
.flex {
  display: flex;
}
.justify-between {
  justify-content: space-between;
}
.items-center {
  align-items: center;
}
.text-lg {
  font-size: 18px;
}
.font-bold {
  font-weight: bold;
}
.text-sm {
  font-size: 12px;
}
.ml-2 {
  margin-left: 8px;
}
.mt-2 {
  margin-top: 8px;
}
.text-gray-500 {
  color: #8c8c8c;
}
.text-xs {
  font-size: 12px;
}
</style>
