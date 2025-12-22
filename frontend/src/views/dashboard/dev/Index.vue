<template>
  <div class="dashboard-container">
    <!-- Dev Stats -->
    <a-row :gutter="16">
      <a-col :span="6">
        <a-card>
          <a-statistic title="本周代码提交 (Commits)" :value="42" suffix="次">
            <template #prefix><code-outlined style="color: #1890ff" /></template>
          </a-statistic>
          <div class="stat-desc">击败了 85% 的同事</div>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card>
          <a-statistic title="待修复 Bug" :value="5" suffix="个">
            <template #prefix><bug-outlined style="color: #ff4d4f" /></template>
          </a-statistic>
          <div class="stat-desc">严重级别: 1 个</div>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card>
          <a-statistic title="代码评审 (CR)" :value="3" suffix="个待审">
            <template #prefix><eye-outlined style="color: #faad14" /></template>
          </a-statistic>
          <div class="stat-desc">平均响应时间: 2小时</div>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card>
          <a-statistic title="当前迭代剩余时间" :value="4" suffix="天">
            <template #prefix><calendar-outlined style="color: #52c41a" /></template>
          </a-statistic>
          <div class="stat-desc">Sprint 42 结束日: 周五</div>
        </a-card>
      </a-col>
    </a-row>

    <!-- Charts & Lists -->
    <a-row :gutter="16" style="margin-top: 16px;">
      <a-col :span="16">
        <a-card title="迭代燃尽图 (Sprint Burndown)" :bordered="false">
          <div ref="burndownChart" style="height: 300px;"></div>
        </a-card>
        
        <a-card title="我的任务看板" :bordered="false" style="margin-top: 16px;">
          <a-row :gutter="16">
            <a-col :span="8">
              <div class="kanban-column">
                <div class="kanban-header todo">待处理 (3)</div>
                <a-card size="small" class="kanban-card">
                  <p>用户登录接口优化</p>
                  <a-tag color="blue">Backend</a-tag>
                </a-card>
                <a-card size="small" class="kanban-card">
                  <p>编写 API 文档</p>
                  <a-tag color="cyan">Docs</a-tag>
                </a-card>
                <a-card size="small" class="kanban-card">
                  <p>调研 WebSocket 方案</p>
                  <a-tag color="purple">Research</a-tag>
                </a-card>
              </div>
            </a-col>
            <a-col :span="8">
              <div class="kanban-column">
                <div class="kanban-header doing">进行中 (2)</div>
                <a-card size="small" class="kanban-card">
                  <p>订单支付状态同步</p>
                  <a-tag color="orange">Priority: High</a-tag>
                </a-card>
                <a-card size="small" class="kanban-card">
                  <p>修复报表导出内存溢出</p>
                  <a-tag color="red">Bug</a-tag>
                </a-card>
              </div>
            </a-col>
            <a-col :span="8">
              <div class="kanban-column">
                <div class="kanban-header done">已完成 (5)</div>
                <a-card size="small" class="kanban-card done-card">
                  <p>前端路由配置重构</p>
                  <check-circle-outlined style="color: #52c41a" />
                </a-card>
                 <a-card size="small" class="kanban-card done-card">
                  <p>升级 Ant Design 版本</p>
                  <check-circle-outlined style="color: #52c41a" />
                </a-card>
              </div>
            </a-col>
          </a-row>
        </a-card>
      </a-col>
      
      <a-col :span="8">
        <a-card title="代码贡献热力图" :bordered="false">
           <div ref="heatmapChart" style="height: 200px;"></div>
        </a-card>
        
        <a-card title="最新构建状态 (CI/CD)" :bordered="false" style="margin-top: 16px;">
          <a-timeline>
            <a-timeline-item color="green">
              <p>Master Branch Build #452</p>
              <p style="font-size: 12px; color: #999">Success - 10 mins ago</p>
            </a-timeline-item>
            <a-timeline-item color="green">
              <p>Feature/Login Build #33</p>
              <p style="font-size: 12px; color: #999">Success - 1 hour ago</p>
            </a-timeline-item>
            <a-timeline-item color="red">
              <p>Hotfix/Payment Build #5</p>
              <p style="font-size: 12px; color: #999">Failed - Unit Test Error</p>
            </a-timeline-item>
             <a-timeline-item color="gray">
              <p>Nightly Build</p>
              <p style="font-size: 12px; color: #999">Scheduled - 02:00 AM</p>
            </a-timeline-item>
          </a-timeline>
        </a-card>
      </a-col>
    </a-row>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import * as echarts from 'echarts';
import {
  CodeOutlined,
  BugOutlined,
  EyeOutlined,
  CalendarOutlined,
  CheckCircleOutlined
} from '@ant-design/icons-vue';

const burndownChart = ref(null);
const heatmapChart = ref(null);

onMounted(() => {
  // Burndown Chart
  const bChart = echarts.init(burndownChart.value);
  bChart.setOption({
    tooltip: { trigger: 'axis' },
    legend: { data: ['理想剩余', '实际剩余'] },
    xAxis: { type: 'category', data: ['Day 1', 'Day 2', 'Day 3', 'Day 4', 'Day 5', 'Day 6', 'Day 7'] },
    yAxis: { type: 'value', name: 'Story Points' },
    series: [
      {
        name: '理想剩余',
        type: 'line',
        data: [50, 42, 34, 26, 18, 10, 0],
        itemStyle: { color: '#bfbfbf' },
        lineStyle: { type: 'dashed' }
      },
      {
        name: '实际剩余',
        type: 'line',
        data: [50, 45, 38, 30, 28, 15, null],
        itemStyle: { color: '#1890ff' },
        areaStyle: { opacity: 0.2 }
      }
    ]
  });

  // Heatmap (Simulated with simple scatter/heatmap logic or just visual blocks)
  // Since real calendar heatmap needs complex data, I'll use a simple GitHub-like contribution simulation
  const hChart = echarts.init(heatmapChart.value);
  // Generate mock data for heatmap
  const hours = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const days = ['Morning', 'Afternoon', 'Evening'];
  const data = [[0,0,5],[0,1,1],[0,2,0],[0,3,0],[0,4,0],[0,5,0],[0,6,0],
                [1,0,2],[1,1,3],[1,2,8],[1,3,1],[1,4,0],[1,5,0],[1,6,0],
                [2,0,0],[2,1,0],[2,2,0],[2,3,0],[2,4,0],[2,5,0],[2,6,0]];
  // Simplified for demo: Just showing activity intensity
  hChart.setOption({
    tooltip: { position: 'top' },
    grid: { height: '50%', top: '10%' },
    xAxis: { type: 'category', data: hours, splitArea: { show: true } },
    yAxis: { type: 'category', data: days, splitArea: { show: true } },
    visualMap: { min: 0, max: 10, calculable: true, orient: 'horizontal', left: 'center', bottom: '15%' },
    series: [{
      name: 'Activity',
      type: 'heatmap',
      data: data.map(function (item) {
        return [item[1], item[0], item[2] || Math.floor(Math.random() * 10)];
      }),
      label: { show: true },
      emphasis: { itemStyle: { shadowBlur: 10, shadowColor: 'rgba(0, 0, 0, 0.5)' } }
    }]
  });


  window.addEventListener('resize', () => {
    bChart.resize();
    hChart.resize();
  });
});
</script>

<style scoped>
.dashboard-container {
  padding: 16px;
  background-color: #f0f2f5;
  min-height: 100vh;
}
.stat-desc {
  font-size: 12px;
  color: #8c8c8c;
  margin-top: 8px;
}
.kanban-column {
  background-color: #f5f5f5;
  padding: 8px;
  border-radius: 4px;
  min-height: 300px;
}
.kanban-header {
  font-weight: bold;
  padding-bottom: 8px;
  margin-bottom: 8px;
  border-bottom: 2px solid #ddd;
}
.kanban-header.todo { border-color: #1890ff; }
.kanban-header.doing { border-color: #faad14; }
.kanban-header.done { border-color: #52c41a; }

.kanban-card {
  margin-bottom: 8px;
  cursor: move;
}
.done-card {
  opacity: 0.7;
  text-decoration: line-through;
}
</style>
