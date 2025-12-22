<template>
  <div class="analysis-container">
    <a-row :gutter="[16, 16]">
      <!-- 顶部统计卡片 -->
      <a-col :span="6">
        <a-card>
          <a-statistic title="馆藏总数" :value="12580" suffix="卷">
            <template #prefix>
              <FileTextOutlined />
            </template>
          </a-statistic>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card>
          <a-statistic title="数字化容量" :value="850" suffix="GB">
            <template #prefix>
              <HddOutlined />
            </template>
          </a-statistic>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card>
          <a-statistic title="今日借阅" :value="24" suffix="次">
            <template #prefix>
              <AuditOutlined />
            </template>
          </a-statistic>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card>
          <a-statistic title="待办审批" :value="5" suffix="个">
            <template #prefix>
              <BellOutlined />
            </template>
          </a-statistic>
        </a-card>
      </a-col>

      <!-- 中间图表区 -->
      <a-col :span="16">
        <a-card title="档案增长趋势" :bordered="false">
          <div ref="growthChartRef" style="height: 350px"></div>
        </a-card>
      </a-col>
      <a-col :span="8">
        <a-card title="档案类型分布" :bordered="false">
          <div ref="typeChartRef" style="height: 350px"></div>
        </a-card>
      </a-col>

      <!-- 底部图表区 -->
      <a-col :span="24">
        <a-card title="部门借阅排名 (Top 10)" :bordered="false">
          <div ref="deptChartRef" style="height: 300px"></div>
        </a-card>
      </a-col>
    </a-row>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue';
import { FileTextOutlined, HddOutlined, AuditOutlined, BellOutlined } from '@ant-design/icons-vue';
import * as echarts from 'echarts';

const growthChartRef = ref<HTMLElement>();
const typeChartRef = ref<HTMLElement>();
const deptChartRef = ref<HTMLElement>();

let growthChart: echarts.ECharts | null = null;
let typeChart: echarts.ECharts | null = null;
let deptChart: echarts.ECharts | null = null;

const initCharts = () => {
  if (growthChartRef.value) {
    growthChart = echarts.init(growthChartRef.value);
    growthChart.setOption({
      tooltip: { trigger: 'axis' },
      grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
      xAxis: {
        type: 'category',
        boundaryGap: false,
        data: ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月']
      },
      yAxis: { type: 'value' },
      series: [
        {
          name: '新增档案',
          type: 'line',
          smooth: true,
          data: [120, 132, 101, 134, 90, 230, 210, 180, 250, 280, 310, 350],
          areaStyle: {}
        }
      ]
    });
  }

  if (typeChartRef.value) {
    typeChart = echarts.init(typeChartRef.value);
    typeChart.setOption({
      tooltip: { trigger: 'item' },
      legend: { top: '5%', left: 'center' },
      series: [
        {
          name: '档案类型',
          type: 'pie',
          radius: ['40%', '70%'],
          avoidLabelOverlap: false,
          itemStyle: { borderRadius: 10, borderColor: '#fff', borderWidth: 2 },
          label: { show: false, position: 'center' },
          emphasis: { label: { show: true, fontSize: 20, fontWeight: 'bold' } },
          labelLine: { show: false },
          data: [
            { value: 1048, name: '文书档案' },
            { value: 735, name: '科技档案' },
            { value: 580, name: '人事档案' },
            { value: 484, name: '会计档案' },
            { value: 300, name: '实物档案' }
          ]
        }
      ]
    });
  }

  if (deptChartRef.value) {
    deptChart = echarts.init(deptChartRef.value);
    deptChart.setOption({
      tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
      grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
      xAxis: { type: 'value' },
      yAxis: {
        type: 'category',
        data: ['行政部', '人力资源部', '财务部', '研发部', '市场部', '销售部', '客服部', '法务部', '采购部', '总经办']
      },
      series: [
        {
          name: '借阅次数',
          type: 'bar',
          data: [320, 302, 280, 250, 210, 190, 150, 120, 110, 80],
          itemStyle: { color: '#1890ff' }
        }
      ]
    });
  }
};

const handleResize = () => {
  growthChart?.resize();
  typeChart?.resize();
  deptChart?.resize();
};

onMounted(() => {
  initCharts();
  window.addEventListener('resize', handleResize);
});

onUnmounted(() => {
  window.removeEventListener('resize', handleResize);
  growthChart?.dispose();
  typeChart?.dispose();
  deptChart?.dispose();
});
</script>

<style scoped>
.analysis-container {
  padding: 16px;
}
</style>
