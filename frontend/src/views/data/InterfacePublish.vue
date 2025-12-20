<template>
  <div class="page-container">
    <div class="header-actions">
      <div class="filters">
        <a-input-search placeholder="搜索发布接口名称/URL" style="width: 300px" />
        <a-select defaultValue="all" style="width: 120px; margin-left: 16px">
          <a-select-option value="all">全部状态</a-select-option>
          <a-select-option value="published">已发布</a-select-option>
          <a-select-option value="offline">已下线</a-select-option>
        </a-select>
      </div>
      <a-button type="primary">
        <template #icon><PlusOutlined /></template>
        发布新接口
      </a-button>
    </div>

    <a-table :columns="columns" :data-source="data" :pagination="{ pageSize: 10 }">
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'status'">
          <a-tag :color="record.status === 'published' ? 'success' : 'default'">
            {{ record.status === 'published' ? '已发布' : '已下线' }}
          </a-tag>
        </template>
        <template v-else-if="column.key === 'action'">
          <a-space>
            <a>编辑</a>
            <a>文档</a>
            <a style="color: #ff4d4f">下线</a>
          </a-space>
        </template>
      </template>
    </a-table>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { PlusOutlined } from '@ant-design/icons-vue';

const columns = [
  { title: '接口名称', dataIndex: 'name', key: 'name' },
  { title: 'URL路径', dataIndex: 'path', key: 'path' },
  { title: '版本', dataIndex: 'version', key: 'version' },
  { title: '状态', dataIndex: 'status', key: 'status', width: 100 },
  { title: '发布时间', dataIndex: 'publishTime', key: 'publishTime' },
  { title: '操作', key: 'action', width: 200 },
];

const data = ref([
  {
    key: '1',
    name: '获取商品库存',
    path: '/api/v1/inventory/query',
    version: 'v1.0.0',
    status: 'published',
    publishTime: '2023-10-20 10:00:00',
  },
  {
    key: '2',
    name: '订单状态查询',
    path: '/api/v1/order/status',
    version: 'v1.0.1',
    status: 'published',
    publishTime: '2023-10-22 14:30:00',
  },
]);
</script>

<style scoped>
.page-container {
  padding: 24px;
  background: #fff;
  min-height: 100%;
}

.header-actions {
  display: flex;
  justify-content: space-between;
  margin-bottom: 16px;
}

.filters {
  display: flex;
  align-items: center;
}
</style>
