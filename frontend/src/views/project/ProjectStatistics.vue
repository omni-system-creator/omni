<template>
  <div class="project-statistics-container">
    <a-row :gutter="16">
      <a-col :span="6">
        <a-card :bordered="false">
          <a-statistic title="项目总数" :value="126" style="margin-right: 50px">
            <template #suffix>
              <span class="stat-trend up"><ArrowUpOutlined /> 12%</span>
            </template>
          </a-statistic>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card :bordered="false">
          <a-statistic title="进行中" :value="45" :value-style="{ color: '#1890ff' }">
             <template #suffix>
              <span class="stat-desc">占比 35%</span>
            </template>
          </a-statistic>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card :bordered="false">
          <a-statistic title="已延期" :value="8" :value-style="{ color: '#cf1322' }">
             <template #suffix>
              <span class="stat-trend down"><ArrowUpOutlined /> 2%</span>
            </template>
          </a-statistic>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card :bordered="false">
          <a-statistic title="本月完成" :value="12" :value-style="{ color: '#3f8600' }">
             <template #suffix>
              <span class="stat-trend up"><ArrowUpOutlined /> 5%</span>
            </template>
          </a-statistic>
        </a-card>
      </a-col>
    </a-row>

    <a-row :gutter="16" style="margin-top: 16px">
      <a-col :span="12">
        <a-card title="项目状态分布" :bordered="false">
          <div ref="statusChartRef" style="height: 300px"></div>
        </a-card>
      </a-col>
      <a-col :span="12">
        <a-card title="项目类型统计" :bordered="false">
          <div ref="typeChartRef" style="height: 300px"></div>
        </a-card>
      </a-col>
    </a-row>

    <a-row :gutter="16" style="margin-top: 16px">
      <a-col :span="24">
        <a-card title="项目进度与延期分析" :bordered="false">
           <div ref="progressChartRef" style="height: 350px"></div>
        </a-card>
      </a-col>
    </a-row>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { ArrowUpOutlined } from '@ant-design/icons-vue';
import * as echarts from 'echarts';

const statusChartRef = ref();
const typeChartRef = ref();
const progressChartRef = ref();

onMounted(() => {
  initStatusChart();
  initTypeChart();
  initProgressChart();
});

const initStatusChart = () => {
  const chart = echarts.init(statusChartRef.value);
  chart.setOption({
    tooltip: { trigger: 'item' },
    legend: { top: '5%', left: 'center' },
    series: [
      {
        name: '状态分布',
        type: 'pie',
        radius: ['40%', '70%'],
        avoidLabelOverlap: false,
        itemStyle: {
          borderRadius: 10,
          borderColor: '#fff',
          borderWidth: 2
        },
        label: { show: false, position: 'center' },
        emphasis: {
          label: { show: true, fontSize: 20, fontWeight: 'bold' }
        },
        data: [
          { value: 45, name: '进行中' },
          { value: 65, name: '已完成' },
          { value: 8, name: '已延期' },
          { value: 5, name: '已暂停' },
          { value: 3, name: '未开始' }
        ]
      }
    ]
  });
};

const initTypeChart = () => {
  const chart = echarts.init(typeChartRef.value);
  chart.setOption({
    tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
    grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
    xAxis: [
      {
        type: 'category',
        data: ['研发类', '实施类', '内部事务', '市场活动', '其他'],
        axisTick: { alignWithLabel: true }
      }
    ],
    yAxis: [{ type: 'value' }],
    series: [
      {
        name: '项目数量',
        type: 'bar',
        barWidth: '60%',
        data: [52, 38, 24, 8, 4]
      }
    ]
  });
};

const initProgressChart = () => {
  const chart = echarts.init(progressChartRef.value);
  chart.setOption({
    tooltip: { trigger: 'axis' },
    legend: { data: ['计划进度', '实际进度'] },
    grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
    xAxis: {
      type: 'category',
      boundaryGap: false,
      data: ['1月', '2月', '3月', '4月', '5月', '6月', '7月']
    },
    yAxis: { type: 'value' },
    series: [
      {
        name: '计划进度',
        type: 'line',
        data: [10, 25, 40, 55, 70, 85, 100]
      },
      {
        name: '实际进度',
        type: 'line',
        data: [10, 22, 35, 50, 65, 80, 92]
      }
    ]
  });
};
</script>

<style scoped>
.project-statistics-container {
  padding: 16px;
  flex: 1;
}
.stat-trend {
  font-size: 14px;
  margin-left: 8px;
}
.stat-trend.up {
  color: #3f8600;
}
.stat-trend.down {
  color: #cf1322;
}
.stat-desc {
  font-size: 14px;
  color: #888;
  margin-left: 8px;
}
</style>
