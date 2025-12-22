<template>
  <div class="production-dashboard">
    <a-row :gutter="16">
      <a-col :span="16">
        <a-card title="产品发布路线图 (Roadmap)" :bordered="false">
          <a-steps :current="1" status="process">
            <a-step title="v2.0 规划" description="2023-10-01" />
            <a-step title="v2.1 开发中" description="当前阶段" />
            <a-step title="v2.2 测试" description="预计 2023-11-15" />
            <a-step title="v3.0 预研" description="预计 2024-01-01" />
          </a-steps>
          <div style="margin-top: 24px;">
            <h4>本季度核心特性进度</h4>
            <a-progress :percent="75" status="active" :stroke-width="15" />
            <div style="display: flex; justify-content: space-between; margin-top: 8px;">
              <span>AI 智能助手模块</span>
              <span>75%</span>
            </div>
            
            <a-progress :percent="45" status="active" :stroke-width="15" stroke-color="#faad14" style="margin-top: 16px;" />
            <div style="display: flex; justify-content: space-between; margin-top: 8px;">
              <span>多租户架构升级</span>
              <span>45%</span>
            </div>

            <a-progress :percent="90" status="active" :stroke-width="15" stroke-color="#52c41a" style="margin-top: 16px;" />
            <div style="display: flex; justify-content: space-between; margin-top: 8px;">
              <span>移动端适配优化</span>
              <span>90%</span>
            </div>
          </div>
        </a-card>
      </a-col>
      <a-col :span="8">
        <a-card title="用户反馈分布" :bordered="false">
          <div ref="feedbackChart" style="height: 250px;"></div>
        </a-card>
      </a-col>
    </a-row>

    <a-row :gutter="16" style="margin-top: 16px;">
      <a-col :span="12">
        <a-card title="活跃用户趋势 (DAU/MAU)" :bordered="false">
          <div ref="userChart" style="height: 300px;"></div>
        </a-card>
      </a-col>
      <a-col :span="12">
        <a-card title="发布日历 & 待办" :bordered="false">
          <a-tabs default-active-key="1">
            <a-tab-pane key="1" tab="发布计划">
              <a-timeline mode="left">
                <a-timeline-item color="green" label="2023-10-20">v2.0.5 Hotfix 发布成功</a-timeline-item>
                <a-timeline-item color="blue" label="2023-10-28">v2.1.0 Beta 灰度发布</a-timeline-item>
                <a-timeline-item color="red" label="2023-11-05">v2.1.0 正式上线 (预计)</a-timeline-item>
                <a-timeline-item label="2023-11-20">v2.2.0 功能冻结</a-timeline-item>
              </a-timeline>
            </a-tab-pane>
            <a-tab-pane key="2" tab="高优先级需求">
              <a-list item-layout="horizontal" :data-source="features">
                <template #renderItem="{ item }">
                  <a-list-item>
                    <a-list-item-meta :description="'优先级: ' + item.priority">
                      <template #title>
                        <a href="#">{{ item.title }}</a>
                      </template>
                      <template #avatar>
                        <a-avatar style="background-color: #1890ff">{{ item.id }}</a-avatar>
                      </template>
                    </a-list-item-meta>
                    <div>{{ item.status }}</div>
                  </a-list-item>
                </template>
              </a-list>
            </a-tab-pane>
          </a-tabs>
        </a-card>
      </a-col>
    </a-row>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import * as echarts from 'echarts';

const feedbackChart = ref(null);
const userChart = ref(null);

const features = [
  { id: 'F-102', title: '支持 Dark Mode', priority: 'P1', status: 'In Review' },
  { id: 'F-105', title: '导出 Excel 性能优化', priority: 'P0', status: 'To Do' },
  { id: 'F-110', title: '集成 SSO 登录', priority: 'P1', status: 'In Progress' },
];

onMounted(() => {
  // Init Feedback Chart
  if (feedbackChart.value) {
    const fChart = echarts.init(feedbackChart.value);
    fChart.setOption({
      tooltip: { trigger: 'item' },
      legend: { bottom: '0%', left: 'center' },
      series: [
        {
          name: '反馈类型',
          type: 'pie',
          radius: ['40%', '70%'],
          avoidLabelOverlap: false,
          itemStyle: { borderRadius: 10, borderColor: '#fff', borderWidth: 2 },
          label: { show: false, position: 'center' },
          emphasis: { label: { show: true, fontSize: '20', fontWeight: 'bold' } },
          labelLine: { show: false },
          data: [
            { value: 1048, name: '功能建议' },
            { value: 735, name: 'Bug 报告' },
            { value: 580, name: 'UI/UX' },
            { value: 484, name: '性能问题' },
            { value: 300, name: '其他' }
          ]
        }
      ]
    });
    window.addEventListener('resize', () => fChart.resize());
  }

  // Init User Chart
  if (userChart.value) {
    const uChart = echarts.init(userChart.value);
    uChart.setOption({
      tooltip: { trigger: 'axis' },
      legend: { data: ['DAU', 'MAU'] },
      grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
      xAxis: { type: 'category', boundaryGap: false, data: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'] },
      yAxis: { type: 'value' },
      series: [
        { name: 'DAU', type: 'line', stack: 'Total', data: [120, 132, 101, 134, 90, 230, 210], smooth: true },
        { name: 'MAU', type: 'line', stack: 'Total', data: [220, 182, 191, 234, 290, 330, 310], smooth: true }
      ]
    });
    window.addEventListener('resize', () => uChart.resize());
  }
});
</script>

<style scoped>
.production-dashboard {
  padding: 24px;
}
</style>
