<template>
  <div class="page-container">
    <div class="action-bar">
      <a-button type="primary">新建盘点任务</a-button>
      <a-select placeholder="盘点状态" style="width: 150px; margin-left: 16px">
        <a-select-option value="all">全部</a-select-option>
        <a-select-option value="pending">待盘点</a-select-option>
        <a-select-option value="processing">盘点中</a-select-option>
        <a-select-option value="completed">已完成</a-select-option>
      </a-select>
    </div>

    <a-table :columns="columns" :data-source="data" style="margin-top: 16px">
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'status'">
          <a-badge :status="getStatusBadge(record.status)" :text="getStatusText(record.status)" />
        </template>
        <template v-else-if="column.key === 'result'">
          <span :style="{ color: record.diff === 0 ? 'green' : 'red' }">
            {{ record.diff === 0 ? '无差异' : (record.diff > 0 ? `盘盈 ${record.diff}` : `盘亏 ${Math.abs(record.diff)}`) }}
          </span>
        </template>
        <template v-else-if="column.key === 'action'">
          <a-space>
            <a>详情</a>
            <a v-if="record.status === 'processing'">录入结果</a>
            <a v-if="record.status === 'pending'">开始</a>
          </a-space>
        </template>
      </template>
    </a-table>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';

const columns = [
  { title: '盘点单号', dataIndex: 'id', key: 'id' },
  { title: '盘点仓库', dataIndex: 'warehouse', key: 'warehouse' },
  { title: '盘点类型', dataIndex: 'type', key: 'type' },
  { title: '计划日期', dataIndex: 'date', key: 'date' },
  { title: '负责人', dataIndex: 'manager', key: 'manager' },
  { title: '状态', dataIndex: 'status', key: 'status' },
  { title: '盘点结果', key: 'result' },
  { title: '操作', key: 'action' },
];

const data = [
  { id: 'ST20251230001', warehouse: '上海主仓库', type: '月度全盘', date: '2025-12-31', manager: '张三', status: 'pending', diff: 0 },
  { id: 'ST20251130001', warehouse: '北京分仓', type: '动态盘点', date: '2025-11-30', manager: '李四', status: 'completed', diff: -5 },
  { id: 'ST20251130002', warehouse: '广州冷链仓', type: '月度全盘', date: '2025-11-30', manager: '王五', status: 'completed', diff: 2 },
];

const getStatusBadge = (status: string) => {
  const map: Record<string, string> = {
    pending: 'default',
    processing: 'processing',
    completed: 'success',
  };
  return map[status] || 'default';
};

const getStatusText = (status: string) => {
  const map: Record<string, string> = {
    pending: '待盘点',
    processing: '盘点中',
    completed: '已完成',
  };
  return map[status] || status;
};
</script>

<style scoped>
.page-container {
  padding: 24px;
  background: #fff;
  min-height: 100%;
}
.action-bar {
  margin-bottom: 16px;
}
</style>