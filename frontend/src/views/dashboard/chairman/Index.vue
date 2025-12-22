<template>
  <div class="dashboard-container">
    <!-- Top Stats Row -->
    <a-row :gutter="16">
      <a-col :span="6">
        <a-card :bordered="false" class="stat-card">
          <a-statistic title="年度营收目标 (亿)" :value="12.5" :precision="2" suffix="RMB" :value-style="{ color: '#cf1322' }">
            <template #prefix>
              <money-collect-outlined />
            </template>
          </a-statistic>
          <div class="stat-footer">
            <span>完成率</span>
            <a-progress :percent="85" size="small" status="active" stroke-color="#cf1322" />
          </div>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card :bordered="false" class="stat-card">
          <a-statistic title="集团净利润" :value="3.2" :precision="2" suffix="亿" :value-style="{ color: '#3f8600' }">
            <template #prefix>
              <rise-outlined />
            </template>
          </a-statistic>
          <div class="stat-footer">
            <span>同比去年</span>
            <span style="color: #3f8600">+12.5% <arrow-up-outlined /></span>
          </div>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card :bordered="false" class="stat-card">
          <a-statistic title="实时股价" :value="68.5" :precision="2" suffix="CNY" :value-style="{ color: '#cf1322' }">
            <template #prefix>
              <stock-outlined />
            </template>
          </a-statistic>
          <div class="stat-footer">
            <span>今日涨跌</span>
            <span style="color: #cf1322">+1.2% <arrow-up-outlined /></span>
          </div>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card :bordered="false" class="stat-card">
          <a-statistic title="全球员工总数" :value="1256" suffix="人">
            <template #prefix>
              <team-outlined />
            </template>
          </a-statistic>
          <div class="stat-footer">
            <span>本月入职</span>
            <span>+24</span>
          </div>
        </a-card>
      </a-col>
    </a-row>

    <!-- Main Charts Row -->
    <a-row :gutter="16" style="margin-top: 16px;">
      <a-col :span="16">
        <a-card title="集团营收趋势分析 (2025)" :bordered="false">
          <div ref="revenueChart" style="height: 350px;"></div>
        </a-card>
      </a-col>
      <a-col :span="8">
        <a-card title="业务板块营收占比" :bordered="false">
          <div ref="pieChart" style="height: 350px;"></div>
        </a-card>
      </a-col>
    </a-row>

    <!-- Bottom Row: Strategy & Risks -->
    <a-row :gutter="16" style="margin-top: 16px;">
      <a-col :span="12">
        <a-card title="2025 战略里程碑" :bordered="false">
          <a-steps direction="vertical" :current="2">
            <a-step title="Q1: 完成 AI 研发中心组建" description="已完成 - 核心团队到位，基础设施搭建完毕。" />
            <a-step title="Q2: 发布 OMS Cloud V3.0" description="已完成 - 市场反响良好，首月签约 50 家。" />
            <a-step title="Q3: 拓展东南亚市场" description="进行中 - 新加坡分公司注册中，首批代理商洽谈。" />
            <a-step title="Q4: 启动 IPO 辅导" description="计划中 - 接触券商与律所。" />
          </a-steps>
        </a-card>
      </a-col>
      <a-col :span="12">
        <a-card title="关键大客户动态" :bordered="false">
          <a-table :dataSource="keyAccounts" :columns="columns" pagination="false" size="small">
            <template #bodyCell="{ column, record }">
              <template v-if="column.key === 'status'">
                <a-tag :color="record.status === 'stable' ? 'green' : record.status === 'risk' ? 'red' : 'orange'">
                  {{ record.statusText }}
                </a-tag>
              </template>
            </template>
          </a-table>
        </a-card>
      </a-col>
    </a-row>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import * as echarts from 'echarts';
import {
  MoneyCollectOutlined,
  RiseOutlined,
  StockOutlined,
  TeamOutlined,
  ArrowUpOutlined
} from '@ant-design/icons-vue';

const revenueChart = ref(null);
const pieChart = ref(null);

const keyAccounts = [
  { key: '1', name: 'XX 能源集团', project: 'ERP 数字化转型', amount: '5,000万', status: 'stable', statusText: '合作稳定' },
  { key: '2', name: 'XX 汽车制造', project: '智能制造 MES', amount: '3,200万', status: 'warning', statusText: '需求变更' },
  { key: '3', name: 'XX 银行总部', project: '金融大数据平台', amount: '8,500万', status: 'stable', statusText: '交付中' },
  { key: '4', name: 'Global Retail Co.', project: '亚太区供应链', amount: '4,000万', status: 'risk', statusText: '回款延期' },
];

const columns = [
  { title: '客户名称', dataIndex: 'name', key: 'name' },
  { title: '合作项目', dataIndex: 'project', key: 'project' },
  { title: '合同金额', dataIndex: 'amount', key: 'amount' },
  { title: '状态', key: 'status' },
];

onMounted(() => {
  // Revenue Chart
  const rChart = echarts.init(revenueChart.value);
  rChart.setOption({
    tooltip: { trigger: 'axis' },
    legend: { data: ['目标营收', '实际营收'] },
    grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
    xAxis: { type: 'category', data: ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'] },
    yAxis: { type: 'value', name: '金额 (千万)' },
    series: [
      {
        name: '目标营收',
        type: 'line',
        data: [8, 8.5, 9, 9.5, 10, 10.5, 11, 11.5, 12, 12.5, 13, 13.5],
        itemStyle: { color: '#bfbfbf' },
        lineStyle: { type: 'dashed' }
      },
      {
        name: '实际营收',
        type: 'line',
        data: [7.8, 8.6, 9.2, 9.4, 10.2, 11.5, 10.8, 11.9, 12.8, null, null, null],
        itemStyle: { color: '#1890ff' },
        areaStyle: { color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [{ offset: 0, color: '#1890ff' }, { offset: 1, color: '#e6f7ff' }]) }
      }
    ]
  });

  // Pie Chart
  const pChart = echarts.init(pieChart.value);
  pChart.setOption({
    tooltip: { trigger: 'item' },
    legend: { top: '5%', left: 'center' },
    series: [
      {
        name: '营收来源',
        type: 'pie',
        radius: ['40%', '70%'],
        avoidLabelOverlap: false,
        itemStyle: { borderRadius: 10, borderColor: '#fff', borderWidth: 2 },
        label: { show: false, position: 'center' },
        emphasis: { label: { show: true, fontSize: '20', fontWeight: 'bold' } },
        labelLine: { show: false },
        data: [
          { value: 540, name: 'ERP 软件许可' },
          { value: 320, name: '实施服务费' },
          { value: 210, name: '云服务订阅' },
          { value: 135, name: '定制开发' },
          { value: 80, name: '硬件销售' }
        ]
      }
    ]
  });

  window.addEventListener('resize', () => {
    rChart.resize();
    pChart.resize();
  });
});
</script>

<style scoped>
.dashboard-container {
  padding: 16px;
  background-color: #f0f2f5;
  min-height: 100vh;
}
.stat-card {
  height: 100%;
}
.stat-footer {
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px solid #f0f0f0;
  display: flex;
  justify-content: space-between;
  color: #8c8c8c;
  font-size: 12px;
}
</style>
