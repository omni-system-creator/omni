<template>
  <div class="widget-card">
    <div class="card-header">
      <h3>项目进度</h3>
      <a href="#">更多</a>
    </div>
    <div class="projects-container">
      <a-table :dataSource="projects" :columns="columns" pagination="false" size="small">
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'status'">
            <a-tag :color="getStatusColor(record.status)">
              {{ record.status }}
            </a-tag>
          </template>
          <template v-if="column.key === 'progress'">
            <a-progress :percent="record.progress" size="small" :status="record.progress === 100 ? 'success' : 'active'" />
          </template>
        </template>
      </a-table>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';

const columns = [
  {
    title: '项目名称',
    dataIndex: 'name',
    key: 'name',
    width: '30%',
  },
  {
    title: '负责人',
    dataIndex: 'leader',
    key: 'leader',
    width: '15%',
  },
  {
    title: '状态',
    dataIndex: 'status',
    key: 'status',
    width: '15%',
  },
  {
    title: '进度',
    dataIndex: 'progress',
    key: 'progress',
  },
];

const projects = ref([
  { key: '1', name: 'OMS 系统重构', leader: '张三', status: '进行中', progress: 65 },
  { key: '2', name: '移动端适配', leader: '李四', status: '延期', progress: 40 },
  { key: '3', name: '数据可视化大屏', leader: '王五', status: '已完成', progress: 100 },
  { key: '4', name: 'API 网关集成', leader: '赵六', status: '进行中', progress: 80 },
  { key: '5', name: '用户权限模块', leader: '钱七', status: '待开始', progress: 0 },
]);

const getStatusColor = (status: string) => {
  switch (status) {
    case '进行中': return 'processing';
    case '已完成': return 'success';
    case '延期': return 'error';
    case '待开始': return 'default';
    default: return 'default';
  }
};
</script>

<style scoped>
.widget-card {
  height: 100%;
  padding: 16px;
  background: #fff;
  border-radius: 8px;
  display: flex;
  flex-direction: column;
}
.card-header {
  margin-bottom: 12px;
  border-bottom: 1px solid #f0f0f0;
  padding-bottom: 8px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.card-header h3 {
  margin: 0;
  font-size: 16px;
  color: #333;
}
.projects-container {
  flex: 1;
  overflow-y: auto;
}
:deep(.ant-table-wrapper) {
  width: 100%;
}
</style>
