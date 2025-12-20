<template>
  <div class="page-container">
    <div class="action-header">
      <div class="left-actions">
        <a-tabs v-model:activeKey="activeTab">
          <a-tab-pane key="all" tab="全部需求" />
          <a-tab-pane key="pending" tab="待审批" />
          <a-tab-pane key="processing" tab="采购中" />
          <a-tab-pane key="completed" tab="已完成" />
        </a-tabs>
      </div>
      <div class="right-actions">
        <a-button type="primary">
          <template #icon><PlusOutlined /></template>
          提报需求
        </a-button>
      </div>
    </div>

    <a-table :columns="columns" :data-source="requestList" :pagination="pagination">
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'status'">
          <a-tag :color="getStatusColor(record.status)">
            {{ getStatusText(record.status) }}
          </a-tag>
        </template>
        <template v-else-if="column.key === 'priority'">
          <a-tag :color="record.priority === 'high' ? 'red' : 'blue'">
            {{ record.priority === 'high' ? '紧急' : '普通' }}
          </a-tag>
        </template>
        <template v-else-if="column.key === 'action'">
          <a-space>
            <a v-if="record.status === 'pending'">审批</a>
            <a v-if="record.status === 'approved'">转订单</a>
            <a>详情</a>
          </a-space>
        </template>
      </template>
    </a-table>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { PlusOutlined } from '@ant-design/icons-vue';

const activeTab = ref('all');

const columns = [
  { title: '需求单号', dataIndex: 'id', key: 'id' },
  { title: '需求主题', dataIndex: 'title', key: 'title', width: 250 },
  { title: '申请部门', dataIndex: 'department', key: 'department' },
  { title: '申请人', dataIndex: 'applicant', key: 'applicant' },
  { title: '预估总价', dataIndex: 'amount', key: 'amount' },
  { title: '期望交付日', dataIndex: 'date', key: 'date' },
  { title: '优先级', dataIndex: 'priority', key: 'priority' },
  { title: '状态', dataIndex: 'status', key: 'status' },
  { title: '操作', key: 'action', width: 150 },
];

const requestList = ref([
  { id: 'PR20251201001', title: '研发中心服务器扩容采购', department: '研发部', applicant: '张三', amount: '¥ 120,000', date: '2025-12-30', priority: 'high', status: 'pending' },
  { id: 'PR20251202005', title: '行政办公用品季度采购', department: '行政部', applicant: '李四', amount: '¥ 5,000', date: '2025-12-15', priority: 'normal', status: 'processing' },
  { id: 'PR20251120003', title: '年会礼品采购', department: '人力资源部', applicant: '王五', amount: '¥ 30,000', date: '2025-12-25', priority: 'normal', status: 'approved' },
]);

const pagination = {
  total: 20,
  showSizeChanger: true,
  showQuickJumper: true,
};

const getStatusColor = (status: string) => {
  const map: Record<string, string> = {
    pending: 'orange',
    approved: 'green',
    processing: 'blue',
    rejected: 'red',
    completed: 'default',
  };
  return map[status] || 'default';
};

const getStatusText = (status: string) => {
  const map: Record<string, string> = {
    pending: '待审批',
    approved: '已审批',
    processing: '采购中',
    rejected: '已驳回',
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

.action-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}
</style>