<template>
  <div class="engineer-dashboard">
    <a-row :gutter="16">
      <a-col :span="6">
        <a-card>
          <a-statistic title="系统在线率 (SLA)" :value="99.98" suffix="%" :value-style="{ color: '#3f8600' }">
            <template #prefix>
              <check-circle-outlined />
            </template>
          </a-statistic>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card>
          <a-statistic title="活跃告警" :value="3" :value-style="{ color: '#cf1322' }">
            <template #prefix>
              <alert-outlined />
            </template>
          </a-statistic>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card>
          <a-statistic title="今日部署" :value="12" :value-style="{ color: '#1890ff' }">
            <template #prefix>
              <cloud-upload-outlined />
            </template>
          </a-statistic>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card>
          <a-statistic title="平均修复时间 (MTTR)" value="15" suffix="min">
            <template #prefix>
              <clock-circle-outlined />
            </template>
          </a-statistic>
        </a-card>
      </a-col>
    </a-row>

    <a-row :gutter="16" style="margin-top: 16px;">
      <a-col :span="16">
        <a-card title="服务器集群负载监控" :bordered="false">
          <div ref="loadChart" style="height: 350px;"></div>
        </a-card>
      </a-col>
      <a-col :span="8">
        <a-card title="核心服务状态" :bordered="false">
          <a-list item-layout="horizontal" :data-source="services">
            <template #renderItem="{ item }">
              <a-list-item>
                <a-list-item-meta :description="'Uptime: ' + item.uptime">
                  <template #title>
                    <a href="#">{{ item.name }}</a>
                  </template>
                  <template #avatar>
                    <a-tag :color="item.status === 'Running' ? 'success' : 'error'">{{ item.status }}</a-tag>
                  </template>
                </a-list-item-meta>
                <div>Latency: {{ item.latency }}ms</div>
              </a-list-item>
            </template>
          </a-list>
        </a-card>
      </a-col>
    </a-row>

    <a-row :gutter="16" style="margin-top: 16px;">
      <a-col :span="12">
        <a-card title="实时告警日志" :bordered="false">
          <a-table :dataSource="alerts" :columns="alertColumns" size="small" :pagination="false">
            <template #bodyCell="{ column, record }">
              <template v-if="column.key === 'level'">
                <a-tag :color="record.level === 'Critical' ? 'red' : 'orange'">{{ record.level }}</a-tag>
              </template>
            </template>
          </a-table>
        </a-card>
      </a-col>
      <a-col :span="12">
        <a-card title="数据库 QPS 趋势" :bordered="false">
          <div ref="qpsChart" style="height: 300px;"></div>
        </a-card>
      </a-col>
    </a-row>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { CheckCircleOutlined, AlertOutlined, CloudUploadOutlined, ClockCircleOutlined } from '@ant-design/icons-vue';
import * as echarts from 'echarts';

const loadChart = ref(null);
const qpsChart = ref(null);

const services = [
  { name: 'Auth Service', status: 'Running', uptime: '15d 4h', latency: 45 },
  { name: 'Order Service', status: 'Running', uptime: '12d 1h', latency: 120 },
  { name: 'Payment Gateway', status: 'Running', uptime: '30d 2h', latency: 210 },
  { name: 'Notification Svc', status: 'Down', uptime: '0h', latency: 0 },
  { name: 'Search Engine', status: 'Running', uptime: '5d 8h', latency: 85 },
];

const alerts = [
  { key: '1', time: '10:23:45', level: 'Critical', message: 'Payment Service Timeout', host: 'srv-pay-01' },
  { key: '2', time: '10:21:12', level: 'Warning', message: 'High CPU Usage > 90%', host: 'srv-db-03' },
  { key: '3', time: '10:15:30', level: 'Warning', message: 'Disk Space Low < 10%', host: 'srv-log-02' },
  { key: '4', time: '09:58:22', level: 'Critical', message: 'Redis Connection Failed', host: 'srv-cache-01' },
];

const alertColumns = [
  { title: '时间', dataIndex: 'time', key: 'time', width: 100 },
  { title: '级别', dataIndex: 'level', key: 'level', width: 80 },
  { title: '主机', dataIndex: 'host', key: 'host', width: 120 },
  { title: '信息', dataIndex: 'message', key: 'message' },
];

onMounted(() => {
  // Init Load Chart
  if (loadChart.value) {
    const lChart = echarts.init(loadChart.value);
    lChart.setOption({
      tooltip: { trigger: 'axis' },
      legend: { data: ['CPU Usage', 'Memory Usage'] },
      grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
      xAxis: { type: 'category', boundaryGap: false, data: ['10:00', '10:05', '10:10', '10:15', '10:20', '10:25', '10:30'] },
      yAxis: { type: 'value', max: 100, name: '%' },
      series: [
        { name: 'CPU Usage', type: 'line', smooth: true, data: [45, 52, 48, 85, 92, 65, 50], itemStyle: { color: '#ff4d4f' } },
        { name: 'Memory Usage', type: 'line', smooth: true, data: [60, 62, 65, 68, 70, 72, 71], itemStyle: { color: '#1890ff' } }
      ]
    });
    
    window.addEventListener('resize', () => lChart.resize());
  }

  // Init QPS Chart
  if (qpsChart.value) {
    const qChart = echarts.init(qpsChart.value);
    qChart.setOption({
      tooltip: { trigger: 'axis' },
      grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
      xAxis: { type: 'category', data: ['10:00', '10:05', '10:10', '10:15', '10:20', '10:25', '10:30'] },
      yAxis: { type: 'value', name: 'QPS' },
      series: [
        { name: 'QPS', type: 'bar', data: [1200, 1350, 1400, 1100, 2500, 1800, 1600], itemStyle: { color: '#52c41a' } }
      ]
    });
    
    window.addEventListener('resize', () => qChart.resize());
  }
});
</script>

<style scoped>
.engineer-dashboard {
  padding: 24px;
}
</style>
