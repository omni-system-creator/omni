<template>
  <div class="app-container">
    <a-card title="主生产计划 (MPS)" :bordered="false">
      <template #extra>
        <a-space>
          <a-button type="primary">新建计划</a-button>
          <a-button>导出</a-button>
        </a-space>
      </template>

      <a-row :gutter="16" style="margin-bottom: 24px;">
        <a-col :span="6">
          <a-statistic title="本月计划总数" :value="12" suffix="个" />
        </a-col>
        <a-col :span="6">
          <a-statistic title="进行中" :value="5" :value-style="{ color: '#1890ff' }" />
        </a-col>
        <a-col :span="6">
          <a-statistic title="即将延期" :value="1" :value-style="{ color: '#faad14' }" />
        </a-col>
        <a-col :span="6">
          <a-statistic title="完成率" :value="85" suffix="%" />
        </a-col>
      </a-row>

      <a-table :columns="columns" :data-source="data" :pagination="false">
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'status'">
            <a-tag :color="getStatusColor(record.status)">
              {{ record.status }}
            </a-tag>
          </template>
          <template v-else-if="column.key === 'progress'">
            <a-progress :percent="record.progress" size="small" />
          </template>
          <template v-else-if="column.key === 'action'">
            <a-space size="small">
              <a>调整</a>
              <a>分解MRP</a>
            </a-space>
          </template>
        </template>
      </a-table>
    </a-card>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';

const columns = [
  { title: '计划编号', dataIndex: 'id', key: 'id' },
  { title: '产品名称', dataIndex: 'product', key: 'product' },
  { title: '计划数量', dataIndex: 'quantity', key: 'quantity' },
  { title: '计划开始', dataIndex: 'startDate', key: 'startDate' },
  { title: '计划结束', dataIndex: 'endDate', key: 'endDate' },
  { title: '当前进度', dataIndex: 'progress', key: 'progress', width: 200 },
  { title: '状态', dataIndex: 'status', key: 'status' },
  { title: '操作', key: 'action' },
];

const data = ref([
  {
    key: '1',
    id: 'MPS-202401-001',
    product: '高性能服务器主机 A1',
    quantity: 500,
    startDate: '2024-01-10',
    endDate: '2024-01-25',
    progress: 65,
    status: '进行中',
  },
  {
    key: '2',
    id: 'MPS-202401-002',
    product: '工业控制面板 X5',
    quantity: 1200,
    startDate: '2024-01-15',
    endDate: '2024-02-05',
    progress: 30,
    status: '进行中',
  },
  {
    key: '3',
    id: 'MPS-202401-003',
    product: '智能网关 G200',
    quantity: 3000,
    startDate: '2024-02-01',
    endDate: '2024-02-28',
    progress: 0,
    status: '未开始',
  },
  {
    key: '4',
    id: 'MPS-202312-009',
    product: '传感器模组 S1',
    quantity: 5000,
    startDate: '2023-12-20',
    endDate: '2024-01-05',
    progress: 100,
    status: '已完成',
  },
]);

const getStatusColor = (status: string) => {
  switch (status) {
    case '进行中': return 'blue';
    case '已完成': return 'green';
    case '未开始': return 'default';
    case '延期': return 'red';
    default: return 'default';
  }
};
</script>

<style scoped>
.app-container {
  padding: 20px;
}
</style>
