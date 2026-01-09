<template>
  <div class="bi-finance-container">
    <!-- 关键财务指标 -->
    <a-row :gutter="24" class="mb-4">
      <a-col :span="6">
        <a-card :bordered="false">
          <a-statistic title="毛利润 (Gross Profit)" :value="680" prefix="¥" suffix="万" :precision="1">
             <template #suffix>
              <small class="text-success ml-2">Margin 45%</small>
            </template>
          </a-statistic>
          <a-progress :percent="45" size="small" :show-info="false" stroke-color="#52c41a" class="mt-2" />
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card :bordered="false">
          <a-statistic title="净利润 (Net Profit)" :value="210" prefix="¥" suffix="万" :precision="1">
             <template #suffix>
              <small class="text-success ml-2">Margin 14%</small>
            </template>
          </a-statistic>
           <a-progress :percent="14" size="small" :show-info="false" stroke-color="#1890ff" class="mt-2" />
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card :bordered="false">
          <a-statistic title="现金流储备 (Runway)" :value="12.5" suffix="个月" :precision="1" />
           <div class="mt-2 text-gray-500 text-xs">基于当前月均支出 ¥120万 计算</div>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card :bordered="false">
          <a-statistic title="应收账款周转天数 (DSO)" :value="45" suffix="天">
             <template #suffix>
              <span class="text-warning ml-2"><ArrowUpOutlined /> +5天</span>
            </template>
          </a-statistic>
          <div class="mt-2 text-gray-500 text-xs">行业平均: 40天</div>
        </a-card>
      </a-col>
    </a-row>

    <a-row :gutter="24">
      <a-col :span="12">
        <a-card title="成本结构分析 (Cost Structure)" :bordered="false" class="mb-4">
          <div ref="costChartRef" style="height: 350px;"></div>
        </a-card>
      </a-col>
      <a-col :span="12">
        <a-card title="现金流趋势预测" :bordered="false" class="mb-4">
          <div ref="cashFlowChartRef" style="height: 350px;"></div>
        </a-card>
      </a-col>
    </a-row>

    <!-- 应收账款账龄分析 -->
    <a-card title="应收账款账龄分析 (AR Aging)" :bordered="false">
      <template #extra>
        <a-radio-group v-model:value="arType" button-style="solid">
          <a-radio-button value="customer">按客户</a-radio-button>
          <a-radio-button value="project">按项目</a-radio-button>
        </a-radio-group>
      </template>
      <a-table :columns="arColumns" :data-source="arData" :pagination="false">
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'amount'">
            <strong>¥{{ record.amount }}</strong>
          </template>
           <template v-if="column.key === 'status'">
            <a-tag :color="record.status === 'Normal' ? 'green' : (record.status === 'Warning' ? 'orange' : 'red')">
              {{ record.status }}
            </a-tag>
          </template>
        </template>
      </a-table>
    </a-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { ArrowUpOutlined } from '@ant-design/icons-vue';
import * as echarts from 'echarts';

const arType = ref('customer');
const costChartRef = ref();
const cashFlowChartRef = ref();

const arColumns = [
  { title: '客户名称', dataIndex: 'name', key: 'name' },
  { title: '总应收金额 (万)', dataIndex: 'amount', key: 'amount', align: 'right' },
  { title: '0-30天', dataIndex: 'day30', key: 'day30', align: 'right' },
  { title: '31-60天', dataIndex: 'day60', key: 'day60', align: 'right' },
  { title: '61-90天', dataIndex: 'day90', key: 'day90', align: 'right' },
  { title: '>90天', dataIndex: 'dayMore', key: 'dayMore', align: 'right' },
  { title: '状态', dataIndex: 'status', key: 'status' }
] as any[];

const arData = [
  { key: 1, name: '某大型国企', amount: 120, day30: 0, day60: 0, day90: 50, dayMore: 70, status: 'Critical' },
  { key: 2, name: '互联网创业公司A', amount: 45, day30: 45, day60: 0, day90: 0, dayMore: 0, status: 'Normal' },
  { key: 3, name: '连锁零售集团', amount: 80, day30: 20, day60: 60, day90: 0, dayMore: 0, status: 'Warning' },
  { key: 4, name: '政府信息中心', amount: 200, day30: 0, day60: 0, day90: 0, dayMore: 200, status: 'Critical' },
];

onMounted(() => {
  initCharts();
  window.addEventListener('resize', resizeCharts);
});

let costChart: echarts.ECharts;
let cashFlowChart: echarts.ECharts;

const resizeCharts = () => {
  costChart?.resize();
  cashFlowChart?.resize();
};

const initCharts = () => {
  if (costChartRef.value) {
    costChart = echarts.init(costChartRef.value);
    costChart.setOption({
      tooltip: { trigger: 'item' },
      legend: { bottom: '5%', left: 'center' },
      series: [
        {
          name: '成本构成',
          type: 'pie',
          radius: ['40%', '70%'],
          avoidLabelOverlap: false,
          itemStyle: { borderRadius: 10, borderColor: '#fff', borderWidth: 2 },
          data: [
            { value: 55, name: '研发人员薪酬 (R&D Salary)' },
            { value: 15, name: '云服务资源 (Cloud Infra)' },
            { value: 12, name: '销售与市场 (S&M)' },
            { value: 10, name: '行政与办公 (G&A)' },
            { value: 8, name: '软件订阅授权 (SaaS Subs)' }
          ]
        }
      ]
    });
  }

  if (cashFlowChartRef.value) {
    cashFlowChart = echarts.init(cashFlowChartRef.value);
    cashFlowChart.setOption({
      tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
      legend: { data: ['经营性现金流', '投资性现金流', '筹资性现金流', '净现金流'] },
      grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
      xAxis: { type: 'category', data: ['1月', '2月', '3月', '4月', '5月', '6月'] },
      yAxis: { type: 'value', name: '万元' },
      series: [
        { name: '经营性现金流', type: 'bar', stack: 'total', data: [120, 132, 101, 134, 90, 230] },
        { name: '投资性现金流', type: 'bar', stack: 'total', data: [-50, -60, -40, -80, -30, -50] },
        { name: '筹资性现金流', type: 'bar', stack: 'total', data: [0, 0, 200, 0, 0, 0] },
        { name: '净现金流', type: 'line', data: [70, 72, 261, 54, 60, 180], smooth: true }
      ]
    });
  }
};
</script>

<style scoped>
.bi-finance-container {
  padding: 16px;
  flex: 1;
}
.mb-4 {
  margin-bottom: 16px;
}
.mt-2 {
  margin-top: 8px;
}
.ml-2 {
  margin-left: 8px;
}
.text-success {
  color: #52c41a;
}
.text-warning {
  color: #faad14;
}
.text-gray-500 {
  color: #8c8c8c;
}
.text-xs {
  font-size: 12px;
}
</style>
