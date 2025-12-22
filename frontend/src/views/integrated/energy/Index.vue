<template>
  <div class="energy-container">
    <!-- Header: Global Energy Stats -->
    <a-card :bordered="false" class="header-card">
      <template #title>
        <span style="font-weight: bold; color: #1890ff;">
          <ThunderboltOutlined /> 集团能耗总览 (2025年度)
        </span>
      </template>
      <template #extra>
        <a-space>
          <a-tag color="green">节能减排目标完成率: 92%</a-tag>
          <a-button type="link">下载能耗报告</a-button>
        </a-space>
      </template>
      <a-row :gutter="24">
        <a-col :span="6">
          <div class="stat-item">
            <div class="stat-label">总用电量 (kWh)</div>
            <div class="stat-value">1,245,890</div>
            <div class="stat-trend down">
              <ArrowDownOutlined /> 环比下降 5.2%
            </div>
          </div>
        </a-col>
        <a-col :span="6">
          <div class="stat-item">
            <div class="stat-label">总用水量 (m³)</div>
            <div class="stat-value">45,230</div>
            <div class="stat-trend up">
              <ArrowUpOutlined /> 环比上升 1.8%
            </div>
          </div>
        </a-col>
        <a-col :span="6">
          <div class="stat-item">
            <div class="stat-label">天然气消耗 (m³)</div>
            <div class="stat-value">12,450</div>
            <div class="stat-trend down">
              <ArrowDownOutlined /> 环比下降 2.1%
            </div>
          </div>
        </a-col>
        <a-col :span="6">
          <div class="stat-item">
            <div class="stat-label">碳排放总量 (tCO2e)</div>
            <div class="stat-value">890.5</div>
            <div class="stat-trend down">
              <ArrowDownOutlined /> 同比下降 8.5%
            </div>
          </div>
        </a-col>
      </a-row>
    </a-card>

    <!-- Main Content: Charts & Alerts -->
    <a-row :gutter="24" style="margin-top: 24px;">
      <a-col :span="16">
        <a-card title="能耗趋势分析" :bordered="false">
          <template #extra>
            <a-radio-group v-model:value="trendPeriod" button-style="solid" size="small">
              <a-radio-button value="week">本周</a-radio-button>
              <a-radio-button value="month">本月</a-radio-button>
              <a-radio-button value="year">全年</a-radio-button>
            </a-radio-group>
          </template>
          <div ref="trendChartRef" style="height: 320px; width: 100%;"></div>
        </a-card>
      </a-col>
      <a-col :span="8">
        <a-card title="实时告警监控" :bordered="false" style="height: 100%;">
          <a-list item-layout="horizontal" :data-source="alerts">
            <template #renderItem="{ item }">
              <a-list-item>
                <a-list-item-meta>
                  <template #title>
                    <span :style="{ color: item.level === 'high' ? '#f5222d' : '#faad14' }">
                      [{{ item.type }}] {{ item.location }}
                    </span>
                  </template>
                  <template #description>
                    {{ item.message }} - {{ item.time }}
                  </template>
                  <template #avatar>
                    <a-avatar :style="{ backgroundColor: item.level === 'high' ? '#f5222d' : '#faad14' }">
                      <template #icon>
                        <AlertOutlined />
                      </template>
                    </a-avatar>
                  </template>
                </a-list-item-meta>
              </a-list-item>
            </template>
          </a-list>
        </a-card>
      </a-col>
    </a-row>

    <!-- Data Table -->
    <a-card title="各分公司/部门能耗定额执行情况" :bordered="false" style="margin-top: 24px;">
      <template #extra>
        <a-space>
          <a-input-search placeholder="搜索部门名称" style="width: 200px" />
          <a-button type="primary">
            <template #icon><ExportOutlined /></template> 导出报表
          </a-button>
        </a-space>
      </template>
      <a-table :columns="columns" :data-source="tableData" :pagination="{ pageSize: 5 }">
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'status'">
            <a-tag :color="record.ratio > 100 ? 'red' : 'green'">
              {{ record.ratio > 100 ? '超额' : '正常' }}
            </a-tag>
          </template>
          <template v-if="column.key === 'ratio'">
            <a-progress :percent="record.ratio" :status="record.ratio > 100 ? 'exception' : 'success'" size="small" />
          </template>
        </template>
      </a-table>
    </a-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import * as echarts from 'echarts';
import {
  ThunderboltOutlined,
  ArrowUpOutlined,
  ArrowDownOutlined,
  AlertOutlined,
  ExportOutlined
} from '@ant-design/icons-vue';

const trendPeriod = ref('month');
const trendChartRef = ref<HTMLElement | null>(null);

const alerts = [
  { type: '电力', location: '总部大楼-3F机房', message: '电流负载超过阈值(95%)', time: '10:23:45', level: 'high' },
  { type: '用水', location: '研发中心-B1食堂', message: '检测到持续异常流量', time: '09:15:20', level: 'medium' },
  { type: '空调', location: '行政楼-会议室A', message: '非工作时间长时间运行', time: '08:00:00', level: 'medium' },
];

const columns = [
  { title: '部门/单位', dataIndex: 'dept', key: 'dept' },
  { title: '责任人', dataIndex: 'manager', key: 'manager' },
  { title: '本月用电配额 (kWh)', dataIndex: 'quota', key: 'quota' },
  { title: '实际使用 (kWh)', dataIndex: 'used', key: 'used' },
  { title: '使用率', dataIndex: 'ratio', key: 'ratio', width: 200 },
  { title: '状态', dataIndex: 'status', key: 'status' },
];

const tableData = [
  { key: 1, dept: '集团总部-行政部', manager: '王主任', quota: 5000, used: 4200, ratio: 84 },
  { key: 2, dept: '研发中心-服务器机房', manager: '张工', quota: 80000, used: 82500, ratio: 103.1 },
  { key: 3, dept: '制造一厂', manager: '李厂长', quota: 500000, used: 480000, ratio: 96 },
  { key: 4, dept: '物流中心', manager: '赵经理', quota: 15000, used: 12000, ratio: 80 },
  { key: 5, dept: '员工宿舍区', manager: '孙主管', quota: 20000, used: 18500, ratio: 92.5 },
];

onMounted(() => {
  if (trendChartRef.value) {
    const chart = echarts.init(trendChartRef.value);
    const option = {
      tooltip: { trigger: 'axis' },
      legend: { data: ['用电量 (kWh)', '用水量 (m³)'] },
      grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
      xAxis: {
        type: 'category',
        boundaryGap: false,
        data: ['1日', '5日', '10日', '15日', '20日', '25日', '30日']
      },
      yAxis: [
        { type: 'value', name: '用电量' },
        { type: 'value', name: '用水量' }
      ],
      series: [
        {
          name: '用电量 (kWh)',
          type: 'line',
          smooth: true,
          data: [1200, 1320, 1010, 1340, 900, 2300, 2100],
          itemStyle: { color: '#1890ff' },
          areaStyle: {
             color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
              { offset: 0, color: 'rgba(24, 144, 255, 0.3)' },
              { offset: 1, color: 'rgba(24, 144, 255, 0.01)' }
            ])
          }
        },
        {
          name: '用水量 (m³)',
          type: 'line',
          smooth: true,
          yAxisIndex: 1,
          data: [220, 182, 191, 234, 290, 330, 310],
          itemStyle: { color: '#52c41a' }
        }
      ]
    };
    chart.setOption(option);
    window.addEventListener('resize', () => chart.resize());
  }
});
</script>

<style scoped>
.energy-container {
  padding: 16px;
  flex: 1;
}
.stat-item {
  text-align: center;
  padding: 16px;
  background: #f9f9f9;
  border-radius: 4px;
}
.stat-label {
  font-size: 14px;
  color: #8c8c8c;
}
.stat-value {
  font-size: 24px;
  font-weight: bold;
  margin: 8px 0;
  color: #262626;
}
.stat-trend {
  font-size: 12px;
}
.stat-trend.up { color: #f5222d; }
.stat-trend.down { color: #52c41a; }
</style>
