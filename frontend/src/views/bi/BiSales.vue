<template>
  <div class="bi-sales-container">
    <a-row :gutter="24">
      <a-col :span="16">
        <!-- 销售漏斗与趋势 -->
        <a-card title="销售漏斗分析" :bordered="false" class="mb-4">
          <div ref="funnelChartRef" style="height: 400px;"></div>
        </a-card>

        <a-card title="销售业绩趋势 (VS 目标)" :bordered="false">
          <div ref="trendChartRef" style="height: 350px;"></div>
        </a-card>
      </a-col>

      <a-col :span="8">
        <!-- 销售排行榜 -->
        <a-card title="销售精英排行榜" :bordered="false" class="mb-4">
          <a-list item-layout="horizontal" :data-source="salesRanking">
            <template #renderItem="{ item, index }">
              <a-list-item>
                <a-list-item-meta :description="`完成率: ${item.rate}% | 签约额: ¥${item.amount}万`">
                  <template #title>
                    <span class="font-bold">{{ item.name }}</span>
                    <a-tag color="blue" class="ml-2">{{ item.level }}</a-tag>
                  </template>
                  <template #avatar>
                    <a-avatar :style="{ backgroundColor: index < 3 ? '#ffbf00' : '#d9d9d9', color: '#fff' }">
                      {{ index + 1 }}
                    </a-avatar>
                  </template>
                </a-list-item-meta>
              </a-list-item>
            </template>
          </a-list>
        </a-card>

        <!-- 客户来源分析 -->
        <a-card title="商机来源分布" :bordered="false">
          <div ref="sourceChartRef" style="height: 300px;"></div>
        </a-card>
      </a-col>
    </a-row>

    <!-- 详细报表 -->
    <a-card title="各产品线销售表现" :bordered="false" class="mt-4">
      <a-table :columns="productColumns" :data-source="productData" :pagination="false">
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'growth'">
             <span :class="record.growth >= 0 ? 'text-success' : 'text-danger'">
               {{ record.growth >= 0 ? '+' : '' }}{{ record.growth }}%
             </span>
          </template>
          <template v-if="column.key === 'contribution'">
             <a-progress :percent="record.contribution" size="small" />
          </template>
        </template>
      </a-table>
    </a-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import * as echarts from 'echarts';

const funnelChartRef = ref();
const trendChartRef = ref();
const sourceChartRef = ref();

const salesRanking = [
  { name: '王金牌', level: '资深顾问', amount: 850, rate: 120 },
  { name: '李销冠', level: '销售经理', amount: 720, rate: 105 },
  { name: '张大单', level: '大客户经理', amount: 680, rate: 98 },
  { name: '赵努力', level: '销售顾问', amount: 450, rate: 85 },
  { name: '陈新人', level: '销售专员', amount: 200, rate: 60 },
];

const productColumns = [
  { title: '产品线', dataIndex: 'name', key: 'name' },
  { title: '本季度销售额 (万)', dataIndex: 'amount', key: 'amount', align: 'right' },
  { title: '环比增长', dataIndex: 'growth', key: 'growth', align: 'right' },
  { title: '平均客单价 (万)', dataIndex: 'avgPrice', key: 'avgPrice', align: 'right' },
  { title: '营收贡献度', dataIndex: 'contribution', key: 'contribution' }
] as any[];

const productData = [
  { key: 1, name: 'OMS 标准版 SaaS', amount: 450, growth: 15.2, avgPrice: 2.5, contribution: 35 },
  { key: 2, name: '企业级 ERP 定制', amount: 680, growth: 5.8, avgPrice: 85.0, contribution: 45 },
  { key: 3, name: 'BI 数据分析插件', amount: 120, growth: 32.5, avgPrice: 1.2, contribution: 12 },
  { key: 4, name: '运维托管服务', amount: 80, growth: -2.5, avgPrice: 5.0, contribution: 8 },
];

onMounted(() => {
  initCharts();
  window.addEventListener('resize', resizeCharts);
});

let funnelChart: echarts.ECharts;
let trendChart: echarts.ECharts;
let sourceChart: echarts.ECharts;

const resizeCharts = () => {
  funnelChart?.resize();
  trendChart?.resize();
  sourceChart?.resize();
};

const initCharts = () => {
  if (funnelChartRef.value) {
    funnelChart = echarts.init(funnelChartRef.value);
    funnelChart.setOption({
      tooltip: { trigger: 'item', formatter: '{a} <br/>{b} : {c}' },
      legend: { data: ['线索 (Leads)', '初步沟通', '需求确认', '方案报价', '合同签约'] },
      series: [
        {
          name: '销售漏斗',
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
            { value: 100, name: '线索 (Leads)' },
            { value: 80, name: '初步沟通' },
            { value: 60, name: '需求确认' },
            { value: 40, name: '方案报价' },
            { value: 20, name: '合同签约' }
          ]
        }
      ]
    });
  }

  if (trendChartRef.value) {
    trendChart = echarts.init(trendChartRef.value);
    trendChart.setOption({
      tooltip: { trigger: 'axis' },
      legend: { data: ['实际销售额', '销售目标'] },
      xAxis: { type: 'category', data: ['1月', '2月', '3月', '4月', '5月', '6月'] },
      yAxis: { type: 'value', name: '万元' },
      series: [
        { name: '实际销售额', type: 'bar', data: [120, 150, 180, 200, 210, 250], itemStyle: { color: '#1890ff' } },
        { name: '销售目标', type: 'line', data: [130, 160, 190, 210, 230, 260], itemStyle: { color: '#faad14' }, lineStyle: { type: 'dashed' } }
      ]
    });
  }

  if (sourceChartRef.value) {
    sourceChart = echarts.init(sourceChartRef.value);
    sourceChart.setOption({
      tooltip: { trigger: 'item' },
      series: [
        {
          name: '商机来源',
          type: 'pie',
          radius: ['50%', '70%'],
          avoidLabelOverlap: false,
          label: { show: false, position: 'center' },
          emphasis: { label: { show: true, fontSize: '20', fontWeight: 'bold' } },
          data: [
            { value: 40, name: '销售自拓' },
            { value: 25, name: '官网咨询' },
            { value: 20, name: '客户转介绍' },
            { value: 10, name: '合作伙伴' },
            { value: 5, name: '市场活动' }
          ]
        }
      ]
    });
  }
};
</script>

<style scoped>
.bi-sales-container {
  padding: 16px;
  flex: 1;
}
.mb-4 {
  margin-bottom: 16px;
}
.mt-4 {
  margin-top: 16px;
}
.ml-2 {
  margin-left: 8px;
}
.font-bold {
  font-weight: bold;
}
.text-success {
  color: #52c41a;
}
.text-danger {
  color: #f5222d;
}
</style>
