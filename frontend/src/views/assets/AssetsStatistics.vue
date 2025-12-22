<template>
  <div class="assets-statistics-container">
    <!-- Top Cards -->
    <a-row :gutter="16">
      <a-col :span="6">
        <a-card :bordered="false" class="stat-card">
          <a-statistic title="固定资产总值" :value="2450000" prefix="¥" :precision="2">
            <template #suffix>
              <span class="stat-trend up">
                <ArrowUpOutlined /> 5.2%
              </span>
            </template>
          </a-statistic>
          <div class="stat-footer">含服务器、PC、办公设备</div>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card :bordered="false" class="stat-card">
          <a-statistic title="在用设备数" :value="128" suffix="台">
            <template #prefix>
              <DesktopOutlined />
            </template>
          </a-statistic>
          <div class="stat-footer">闲置设备: 12 台</div>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card :bordered="false" class="stat-card">
          <a-statistic title="软件订阅年费" :value="350000" prefix="¥" :precision="2">
             <template #suffix>
              <span class="stat-trend up">
                <ArrowUpOutlined /> 12%
              </span>
            </template>
          </a-statistic>
          <div class="stat-footer">含 IDE、云服务、设计软件</div>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card :bordered="false" class="stat-card">
          <a-statistic title="本月新增资产" :value="5" suffix="件">
            <template #prefix>
              <PlusCircleOutlined />
            </template>
          </a-statistic>
          <div class="stat-footer">采购金额: ¥ 85,000</div>
        </a-card>
      </a-col>
    </a-row>

    <!-- Charts Row 1 -->
    <a-row :gutter="16" style="margin-top: 16px">
      <a-col :span="12">
        <a-card title="资产类别分布" :bordered="false">
          <div ref="categoryChartRef" style="height: 350px"></div>
        </a-card>
      </a-col>
      <a-col :span="12">
        <a-card title="部门资产价值分布 (Top 5)" :bordered="false">
          <div ref="deptChartRef" style="height: 350px"></div>
        </a-card>
      </a-col>
    </a-row>

    <!-- Charts Row 2 -->
    <a-row :gutter="16" style="margin-top: 16px">
      <a-col :span="24">
        <a-card title="年度资产投入趋势" :bordered="false">
          <div ref="trendChartRef" style="height: 300px"></div>
        </a-card>
      </a-col>
    </a-row>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue';
import { 
  ArrowUpOutlined, 
  DesktopOutlined, 
  PlusCircleOutlined 
} from '@ant-design/icons-vue';
import * as echarts from 'echarts';

const categoryChartRef = ref();
const deptChartRef = ref();
const trendChartRef = ref();

let categoryChart: echarts.ECharts | null = null;
let deptChart: echarts.ECharts | null = null;
let trendChart: echarts.ECharts | null = null;

const initCategoryChart = () => {
  if (!categoryChartRef.value) return;
  categoryChart = echarts.init(categoryChartRef.value);
  categoryChart.setOption({
    tooltip: {
      trigger: 'item',
      formatter: '{b}: {c} ({d}%)'
    },
    legend: {
      orient: 'vertical',
      left: 'left'
    },
    series: [
      {
        name: '资产类别',
        type: 'pie',
        radius: '70%',
        data: [
          { value: 1200000, name: '开发服务器' },
          { value: 800000, name: '员工电脑(Mac/PC)' },
          { value: 150000, name: '显示器 & 外设' },
          { value: 200000, name: '办公家具' },
          { value: 100000, name: '测试设备(手机/平板)' }
        ],
        emphasis: {
          itemStyle: {
            shadowBlur: 10,
            shadowOffsetX: 0,
            shadowColor: 'rgba(0, 0, 0, 0.5)'
          }
        }
      }
    ]
  });
};

const initDeptChart = () => {
  if (!deptChartRef.value) return;
  deptChart = echarts.init(deptChartRef.value);
  deptChart.setOption({
    tooltip: {
      trigger: 'axis',
      axisPointer: { type: 'shadow' }
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      containLabel: true
    },
    xAxis: {
      type: 'value',
      name: '金额 (万元)'
    },
    yAxis: {
      type: 'category',
      data: ['研发部', '运维部', '设计部', '总经办', '市场部']
    },
    series: [
      {
        name: '资产价值',
        type: 'bar',
        data: [150, 45, 20, 15, 10],
        itemStyle: {
          color: '#1890ff'
        }
      }
    ]
  });
};

const initTrendChart = () => {
  if (!trendChartRef.value) return;
  trendChart = echarts.init(trendChartRef.value);
  trendChart.setOption({
    tooltip: {
      trigger: 'axis'
    },
    legend: {
      data: ['硬件采购', '软件订阅']
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      containLabel: true
    },
    xAxis: {
      type: 'category',
      boundaryGap: false,
      data: ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月']
    },
    yAxis: {
      type: 'value',
      name: '投入金额 (万元)'
    },
    series: [
      {
        name: '硬件采购',
        type: 'line',
        data: [5, 2, 8, 3, 15, 4, 6, 2, 5, 8, 20, 5],
        smooth: true,
        itemStyle: { color: '#52c41a' }
      },
      {
        name: '软件订阅',
        type: 'line',
        data: [12, 0, 0, 0, 2, 0, 0, 0, 5, 0, 0, 15],
        smooth: true,
        itemStyle: { color: '#722ed1' },
        markPoint: {
          data: [
            { type: 'max', name: 'Max' }
          ]
        }
      }
    ]
  });
};

const handleResize = () => {
  categoryChart?.resize();
  deptChart?.resize();
  trendChart?.resize();
};

onMounted(() => {
  initCategoryChart();
  initDeptChart();
  initTrendChart();
  window.addEventListener('resize', handleResize);
});

onUnmounted(() => {
  window.removeEventListener('resize', handleResize);
  categoryChart?.dispose();
  deptChart?.dispose();
  trendChart?.dispose();
});
</script>

<style scoped>
.assets-statistics-container {
  padding: 16px;
  background-color: #f0f2f5;
  min-height: 100%;
}
.stat-card {
  height: 100%;
}
.stat-trend {
  font-size: 14px;
  margin-left: 8px;
}
.stat-trend.up {
  color: #cf1322;
}
.stat-trend.down {
  color: #3f8600;
}
.stat-footer {
  margin-top: 8px;
  color: #8c8c8c;
  font-size: 12px;
}
</style>