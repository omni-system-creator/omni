<template>
  <div class="workflow-statistics-container">
    <!-- 关键指标卡片 -->
    <a-row :gutter="24" class="mb-4">
      <a-col :span="6">
        <a-card :bordered="false">
          <a-statistic title="流程总实例数" :value="1285" style="margin-right: 50px">
            <template #suffix>
              <span class="text-xs text-gray-500">本月 +120</span>
            </template>
          </a-statistic>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card :bordered="false">
          <a-statistic title="平均审批耗时" :value="1.8" :precision="1" suffix="天" :value-style="{ color: '#cf1322' }">
             <template #prefix>
              <ClockCircleOutlined />
            </template>
          </a-statistic>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card :bordered="false">
          <a-statistic title="按时完成率" :value="92.5" :precision="1" suffix="%" :value-style="{ color: '#3f8600' }">
             <template #prefix>
              <CheckCircleOutlined />
            </template>
          </a-statistic>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card :bordered="false">
          <a-statistic title="待办任务总数" :value="45" :value-style="{ color: '#faad14' }">
             <template #prefix>
              <ScheduleOutlined />
            </template>
          </a-statistic>
        </a-card>
      </a-col>
    </a-row>

    <a-row :gutter="24">
      <!-- 流程效率分析 -->
      <a-col :span="16">
        <a-card title="各流程平均耗时排行 (Top 10)" :bordered="false" class="mb-4">
          <div ref="processEfficiencyChartRef" style="height: 350px;"></div>
        </a-card>
      </a-col>
      
      <!-- 流程分布 -->
      <a-col :span="8">
        <a-card title="流程类型分布" :bordered="false" class="mb-4">
          <div ref="processTypeChartRef" style="height: 350px;"></div>
        </a-card>
      </a-col>
    </a-row>

    <a-row :gutter="24">
      <!-- 部门审批效率 -->
      <a-col :span="24">
        <a-card title="各部门审批效率分析" :bordered="false">
          <a-table :columns="deptColumns" :data-source="deptData" :pagination="false" size="middle">
             <template #bodyCell="{ column, record }">
               <template v-if="column.key === 'efficiency'">
                 <a-progress :percent="record.efficiency" :status="record.efficiency < 60 ? 'exception' : 'active'" />
               </template>
             </template>
          </a-table>
        </a-card>
      </a-col>
    </a-row>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue';
import { ClockCircleOutlined, CheckCircleOutlined, ScheduleOutlined } from '@ant-design/icons-vue';
import * as echarts from 'echarts';

const processEfficiencyChartRef = ref<HTMLElement | null>(null);
const processTypeChartRef = ref<HTMLElement | null>(null);
let processEfficiencyChart: echarts.ECharts | null = null;
let processTypeChart: echarts.ECharts | null = null;

// Mock Data for Department Efficiency
const deptColumns = [
  { title: '部门名称', dataIndex: 'name', key: 'name' },
  { title: '处理任务数', dataIndex: 'taskCount', key: 'taskCount' },
  { title: '平均响应时间(小时)', dataIndex: 'avgResponse', key: 'avgResponse' },
  { title: '平均处理时间(小时)', dataIndex: 'avgHandle', key: 'avgHandle' },
  { title: '超时任务数', dataIndex: 'overdueCount', key: 'overdueCount' },
  { title: '处理效率评分', dataIndex: 'efficiency', key: 'efficiency' },
];

const deptData = [
  { name: '研发部', taskCount: 450, avgResponse: 2.5, avgHandle: 18, overdueCount: 12, efficiency: 85 },
  { name: '产品部', taskCount: 210, avgResponse: 1.8, avgHandle: 12, overdueCount: 5, efficiency: 92 },
  { name: '测试部', taskCount: 180, avgResponse: 1.5, avgHandle: 8, overdueCount: 2, efficiency: 95 },
  { name: '财务部', taskCount: 120, avgResponse: 4.0, avgHandle: 24, overdueCount: 8, efficiency: 78 },
  { name: '人事部', taskCount: 150, avgResponse: 3.5, avgHandle: 10, overdueCount: 3, efficiency: 88 },
  { name: '运维部', taskCount: 90, avgResponse: 1.2, avgHandle: 6, overdueCount: 1, efficiency: 98 },
];

const initCharts = () => {
  if (processEfficiencyChartRef.value) {
    processEfficiencyChart = echarts.init(processEfficiencyChartRef.value);
    processEfficiencyChart.setOption({
      tooltip: { trigger: 'axis' },
      grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
      xAxis: { type: 'value', name: '小时' },
      yAxis: { 
        type: 'category', 
        data: ['采购申请', '合同审批', '项目立项', '差旅报销', '招聘需求', '转正申请', '离职审批', '请假申请', '加班申请', 'VPN申请']
      },
      series: [
        {
          name: '平均耗时',
          type: 'bar',
          data: [48, 42, 36, 24, 18, 12, 10, 8, 4, 2],
          itemStyle: { color: '#1890ff' }
        }
      ]
    });
  }

  if (processTypeChartRef.value) {
    processTypeChart = echarts.init(processTypeChartRef.value);
    processTypeChart.setOption({
      tooltip: { trigger: 'item' },
      legend: { bottom: '5%', left: 'center' },
      series: [
        {
          name: '流程类型',
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
            label: { show: true, fontSize: '20', fontWeight: 'bold' }
          },
          labelLine: { show: false },
          data: [
            { value: 450, name: '项目研发' },
            { value: 300, name: '人事行政' },
            { value: 200, name: '财务相关' },
            { value: 150, name: 'IT运维' },
            { value: 185, name: '其他' }
          ]
        }
      ]
    });
  }
};

const handleResize = () => {
  processEfficiencyChart?.resize();
  processTypeChart?.resize();
};

onMounted(() => {
  initCharts();
  window.addEventListener('resize', handleResize);
});

onUnmounted(() => {
  window.removeEventListener('resize', handleResize);
  processEfficiencyChart?.dispose();
  processTypeChart?.dispose();
});
</script>

<style scoped>
.workflow-statistics-container {
  padding: 16px;
  flex: 1;
}
.mb-4 {
  margin-bottom: 24px;
}
.text-xs {
  font-size: 12px;
}
.text-gray-500 {
  color: #8c8c8c;
}
</style>
