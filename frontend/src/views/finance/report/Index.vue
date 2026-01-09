<template>
  <div class="finance-report-container">
    <a-tabs v-model:activeKey="activeTab">
      <a-tab-pane key="overview" tab="经营概况">
        <a-row :gutter="16">
          <a-col :span="6">
             <a-card :bordered="false" class="mb-4">
              <a-statistic title="本月营收" :value="1250000" prefix="¥" :precision="2">
                <template #suffix>
                  <span class="trend-up"><ArrowUpOutlined /> 12%</span>
                </template>
              </a-statistic>
             </a-card>
          </a-col>
          <a-col :span="6">
             <a-card :bordered="false" class="mb-4">
              <a-statistic title="本月支出" :value="860000" prefix="¥" :precision="2">
                 <template #suffix>
                  <span class="trend-down"><ArrowDownOutlined /> 5%</span>
                </template>
              </a-statistic>
             </a-card>
          </a-col>
           <a-col :span="6">
             <a-card :bordered="false" class="mb-4">
              <a-statistic title="毛利润" :value="390000" prefix="¥" :precision="2" :value-style="{ color: '#3f8600' }" />
             </a-card>
          </a-col>
           <a-col :span="6">
             <a-card :bordered="false" class="mb-4">
              <a-statistic title="毛利率" :value="31.2" suffix="%" :precision="1" />
             </a-card>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="16">
            <a-card title="收支趋势" :bordered="false">
              <div ref="trendChartRef" style="height: 350px;"></div>
            </a-card>
          </a-col>
          <a-col :span="8">
            <a-card title="支出构成" :bordered="false">
              <div ref="pieChartRef" style="height: 350px;"></div>
            </a-card>
          </a-col>
        </a-row>
      </a-tab-pane>

      <a-tab-pane key="income" tab="利润表">
        <a-card :bordered="false">
          <template #extra>
            <a-button>导出Excel</a-button>
          </template>
          <a-table :columns="incomeColumns" :data-source="incomeData" :pagination="false" size="middle" bordered />
        </a-card>
      </a-tab-pane>

      <a-tab-pane key="balance" tab="资产负债表">
        <a-card :bordered="false">
           <template #extra>
            <a-button>导出Excel</a-button>
          </template>
          <a-table :columns="balanceColumns" :data-source="balanceData" :pagination="false" size="middle" bordered />
        </a-card>
      </a-tab-pane>
    </a-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { ArrowUpOutlined, ArrowDownOutlined } from '@ant-design/icons-vue';
import * as echarts from 'echarts';

const activeTab = ref('overview');
const trendChartRef = ref();
const pieChartRef = ref();

const incomeColumns: ColumnType[] = [
  { title: '项目', dataIndex: 'item', key: 'item' },
  { title: '本月金额', dataIndex: 'currentAmount', key: 'currentAmount', align: 'right' as const },
  { title: '本年累计', dataIndex: 'yearAmount', key: 'yearAmount', align: 'right' as const }
];

const incomeData = ref([
  { key: 1, item: '一、营业收入', currentAmount: '1,250,000.00', yearAmount: '15,000,000.00' },
  { key: 2, item: '减：营业成本', currentAmount: '860,000.00', yearAmount: '9,500,000.00' },
  { key: 3, item: '税金及附加', currentAmount: '12,000.00', yearAmount: '150,000.00' },
  { key: 4, item: '二、营业利润', currentAmount: '378,000.00', yearAmount: '5,350,000.00' },
]);

const balanceColumns: ColumnType[] = [
  { title: '资产', dataIndex: 'asset', key: 'asset' },
  { title: '期末余额', dataIndex: 'endBalance', key: 'endBalance', align: 'right' as const },
  { title: '负债及所有者权益', dataIndex: 'liability', key: 'liability' },
  { title: '期末余额', dataIndex: 'lBalance', key: 'lBalance', align: 'right' as const },
];

const balanceData = ref([
  { key: 1, asset: '流动资产', endBalance: '5,000,000.00', liability: '流动负债', lBalance: '2,000,000.00' },
  { key: 2, asset: '货币资金', endBalance: '1,200,000.00', liability: '应付账款', lBalance: '800,000.00' },
  { key: 3, asset: '应收账款', endBalance: '2,500,000.00', liability: '短期借款', lBalance: '500,000.00' },
]);

onMounted(() => {
  // Wait for DOM to render inside Tabs
  setTimeout(() => {
    initCharts();
  }, 100);
});

const initCharts = () => {
  if (trendChartRef.value) {
    const trendChart = echarts.init(trendChartRef.value);
    trendChart.setOption({
      tooltip: { trigger: 'axis' },
      legend: { data: ['收入', '支出', '利润'] },
      grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
      xAxis: { type: 'category', boundaryGap: false, data: ['1月', '2月', '3月', '4月', '5月', '6月', '7月'] },
      yAxis: { type: 'value' },
      series: [
        { name: '收入', type: 'line', smooth: true, data: [80, 92, 105, 110, 115, 120, 125] },
        { name: '支出', type: 'line', smooth: true, data: [60, 65, 70, 75, 80, 82, 86] },
        { name: '利润', type: 'line', smooth: true, data: [20, 27, 35, 35, 35, 38, 39] }
      ]
    });
  }

  if (pieChartRef.value) {
    const pieChart = echarts.init(pieChartRef.value);
    pieChart.setOption({
      tooltip: { trigger: 'item' },
      legend: { bottom: '5%', left: 'center' },
      series: [
        {
          name: '支出构成',
          type: 'pie',
          radius: ['40%', '70%'],
          avoidLabelOverlap: false,
          itemStyle: { borderRadius: 10, borderColor: '#fff', borderWidth: 2 },
          data: [
            { value: 45, name: '人力成本' },
            { value: 25, name: '采购成本' },
            { value: 15, name: '营销费用' },
            { value: 10, name: '房租水电' },
            { value: 5, name: '其他' }
          ]
        }
      ]
    });
  }
};
</script>

<style scoped>
.finance-report-container {
  padding: 16px;
  flex: 1;
}
.trend-up {
  color: #3f8600;
  font-size: 14px;
  margin-left: 8px;
}
.trend-down {
  color: #3f8600; /* Usually green means good in finance for cost reduction? Or red? Standard is Green Up Red Down, but for Cost, Down is good (Green). Let's stick to Green for Good. */
  /* Actually standard finance: Red is bad/loss, Green is profit/gain.
     For Cost: Cost going down is good (Green). Cost going up is bad (Red).
     ArrowDown for Cost: Green.
  */
  color: #3f8600;
  font-size: 14px;
  margin-left: 8px;
}
.mb-4 {
  margin-bottom: 16px;
}
</style>
