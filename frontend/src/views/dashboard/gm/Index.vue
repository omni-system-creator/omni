<template>
  <div class="dashboard-container">
    <!-- Header: Operational Overview -->
    <a-card title="月度运营总览" :bordered="false" class="header-card">
      <a-row :gutter="24">
        <a-col :span="6">
          <div class="kpi-item">
            <span class="label">本月运营成本</span>
            <span class="value">¥ 4,250,000</span>
            <span class="trend down">
              环比 -5.2% <arrow-down-outlined />
            </span>
          </div>
        </a-col>
        <a-col :span="6">
          <div class="kpi-item">
            <span class="label">项目交付准时率</span>
            <span class="value">92.5%</span>
            <span class="trend up">
              环比 +1.5% <arrow-up-outlined />
            </span>
          </div>
        </a-col>
        <a-col :span="6">
          <div class="kpi-item">
            <span class="label">客户净推荐值 (NPS)</span>
            <span class="value">48.0</span>
            <span class="trend up">
              同比 +4.0 <arrow-up-outlined />
            </span>
          </div>
        </a-col>
        <a-col :span="6">
          <div class="kpi-item">
            <span class="label">核心人才流失率</span>
            <span class="value">1.2%</span>
            <span class="trend stable">
              处于健康区间
            </span>
          </div>
        </a-col>
      </a-row>
    </a-card>

    <a-row :gutter="16" style="margin-top: 16px;">
      <!-- Budget Execution -->
      <a-col :span="14">
        <a-card title="各部门预算执行情况 (Q4)" :bordered="false">
          <div ref="budgetChart" style="height: 320px;"></div>
        </a-card>
      </a-col>
      <!-- Risk Radar -->
      <a-col :span="10">
        <a-card title="企业运营风险概览" :bordered="false">
          <div ref="riskChart" style="height: 320px;"></div>
        </a-card>
      </a-col>
    </a-row>

    <!-- Department Reports -->
    <a-card title="部门负责人月报摘要" :bordered="false" style="margin-top: 16px;">
      <a-list item-layout="horizontal" :data-source="deptReports">
        <template #renderItem="{ item }">
          <a-list-item>
            <template #actions>
              <a-button type="link">查看详情</a-button>
            </template>
            <a-list-item-meta :description="item.summary">
              <template #title>
                <a href="#">{{ item.dept }} - {{ item.manager }}</a>
                <a-tag :color="item.statusColor" style="margin-left: 8px">{{ item.status }}</a-tag>
              </template>
              <template #avatar>
                <a-avatar :src="item.avatar" />
              </template>
            </a-list-item-meta>
            <div class="report-stats">
              <div>完成度: <span :style="{ color: item.completion >= 90 ? '#52c41a' : '#faad14' }">{{ item.completion }}%</span></div>
              <div>问题数: {{ item.issues }}</div>
            </div>
          </a-list-item>
        </template>
      </a-list>
    </a-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import * as echarts from 'echarts';
import { ArrowUpOutlined, ArrowDownOutlined } from '@ant-design/icons-vue';

const budgetChart = ref(null);
const riskChart = ref(null);

const deptReports = [
  {
    dept: '研发中心',
    manager: '王总监',
    avatar: 'https://joeschmoe.io/api/v1/random',
    summary: 'OMS V3.0 核心模块开发完成，进入集成测试阶段。本月新增 3 项专利申请。',
    status: '正常',
    statusColor: 'green',
    completion: 95,
    issues: 2
  },
  {
    dept: '市场部',
    manager: '李总监',
    avatar: 'https://joeschmoe.io/api/v1/female/random',
    summary: 'Q4 营销战役启动，目前线索转化率低于预期，需增加投放预算。',
    status: '预警',
    statusColor: 'orange',
    completion: 82,
    issues: 5
  },
  {
    dept: '人力资源部',
    manager: '赵总监',
    avatar: 'https://joeschmoe.io/api/v1/male/random',
    summary: '校园招聘结束，发出 Offer 120 份。年度绩效考核方案已制定。',
    status: '正常',
    statusColor: 'green',
    completion: 100,
    issues: 0
  },
  {
    dept: '财务部',
    manager: '钱总监',
    avatar: 'https://joeschmoe.io/api/v1/female/2',
    summary: '年度审计准备工作已开始。税务合规性自查完成。',
    status: '正常',
    statusColor: 'green',
    completion: 98,
    issues: 1
  }
];

onMounted(() => {
  // Budget Chart
  const bChart = echarts.init(budgetChart.value);
  bChart.setOption({
    tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
    legend: { data: ['预算', '实际支出'] },
    grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
    xAxis: { type: 'category', data: ['研发', '市场', '销售', '人力', '行政', 'IT'] },
    yAxis: { type: 'value' },
    series: [
      {
        name: '预算',
        type: 'bar',
        data: [200, 150, 120, 50, 40, 60],
        itemStyle: { color: '#f0f0f0' },
        barGap: '-100%'
      },
      {
        name: '实际支出',
        type: 'bar',
        data: [180, 160, 110, 45, 38, 55],
        itemStyle: {
          color: (params: any) => {
            const budget = [200, 150, 120, 50, 40, 60];
            const budgetValue = budget[params.dataIndex] || 0;
            return (params.value as number) > budgetValue ? '#ff4d4f' : '#1890ff';
          }
        }
      }
    ]
  });

  // Risk Chart
  const rChart = echarts.init(riskChart.value);
  rChart.setOption({
    tooltip: {},
    legend: { data: ['当前风险值', '安全阈值'], bottom: 0 },
    radar: {
      indicator: [
        { name: '资金流', max: 100 },
        { name: '合规性', max: 100 },
        { name: '交付质量', max: 100 },
        { name: '市场竞争', max: 100 },
        { name: '人才流失', max: 100 },
        { name: '数据安全', max: 100 }
      ]
    },
    series: [
      {
        name: 'Risk Analysis',
        type: 'radar',
        data: [
          {
            value: [80, 90, 70, 60, 50, 85],
            name: '当前风险值',
            itemStyle: { color: '#1890ff' },
            areaStyle: { opacity: 0.3 }
          },
          {
            value: [60, 80, 60, 50, 40, 70],
            name: '安全阈值',
            itemStyle: { color: '#ff4d4f' },
            lineStyle: { type: 'dashed' }
          }
        ]
      }
    ]
  });

  window.addEventListener('resize', () => {
    bChart.resize();
    rChart.resize();
  });
});
</script>

<style scoped>
.dashboard-container {
  padding: 16px;
  background-color: #f0f2f5;
  min-height: 100vh;
}
.kpi-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 16px 0;
  border-right: 1px solid #f0f0f0;
}
.kpi-item:last-child {
  border-right: none;
}
.kpi-item .label {
  color: #8c8c8c;
  font-size: 14px;
  margin-bottom: 8px;
}
.kpi-item .value {
  color: #262626;
  font-size: 24px;
  font-weight: bold;
  margin-bottom: 8px;
}
.trend {
  font-size: 12px;
}
.trend.up { color: #52c41a; }
.trend.down { color: #ff4d4f; }
.trend.stable { color: #1890ff; }

.report-stats {
  text-align: right;
  min-width: 100px;
  color: #8c8c8c;
  font-size: 12px;
}
</style>
