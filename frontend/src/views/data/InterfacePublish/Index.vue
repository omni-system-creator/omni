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
      <a-button type="primary" @click="showDrawer">
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
            <a @click.prevent="openEdit(record)">编辑</a>
            <a>文档</a>
            <a style="color: #ff4d4f">下线</a>
          </a-space>
        </template>
      </template>
    </a-table>

    <ApiEditorDrawer
      v-model:visible="visible"
      :editingId="editingId"
      :initialData="drawerData"
      @save="onSave"
    />
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { PlusOutlined } from '@ant-design/icons-vue';
import ApiEditorDrawer from './components/ApiEditorDrawer.vue';
import { v4 as uuidv4 } from 'uuid';

const visible = ref(false);
const editingId = ref<string | null>(null);
const drawerData = ref<any>(null);

const showDrawer = () => {
  editingId.value = null;
  drawerData.value = null;
  visible.value = true;
};

const openEdit = (record: any) => {
  editingId.value = record.key;
  // Clone to avoid direct mutation
  drawerData.value = JSON.parse(JSON.stringify(record));
  visible.value = true;
};

const onSave = (data: any) => {
  console.log('Saved API:', data);
  visible.value = false;
  // In a real app, we would update the list here
};

const columns = [
  { title: '接口名称', dataIndex: 'name', key: 'name' },
  { title: 'URL路径', dataIndex: 'path', key: 'path' },
  { title: '版本', dataIndex: 'version', key: 'version' },
  { title: '状态', dataIndex: 'status', key: 'status', width: 100 },
  { title: '发布时间', dataIndex: 'publishTime', key: 'publishTime' },
  { title: '操作', key: 'action', width: 200 },
];

// --- Mock Data Generators ---

const generateSimpleCRUD = () => {
  const reqId = uuidv4();
  const dbId = uuidv4();
  const resId = uuidv4();
  
  return {
    nodes: [
      { id: reqId, type: 'request', x: 50, y: 100, data: { path: '/api/v1/inventory/query', method: 'GET' } },
      { id: dbId, type: 'database', x: 350, y: 100, data: { sourceId: 'db1', opType: 'select', sql: 'SELECT * FROM inventory WHERE item_id = ?' } },
      { id: resId, type: 'response', x: 650, y: 100, data: { contentType: 'json' } }
    ],
    edges: [
      { id: uuidv4(), sourceId: reqId, targetId: dbId },
      { id: uuidv4(), sourceId: dbId, targetId: resId }
    ]
  };
};

const generateApiAggregation = () => {
  const reqId = uuidv4();
  const api1Id = uuidv4();
  const api2Id = uuidv4();
  const scriptId = uuidv4();
  const resId = uuidv4();

  return {
    nodes: [
      { id: reqId, type: 'request', x: 50, y: 200, data: { path: '/api/v1/user/full-profile', method: 'GET' } },
      { id: api1Id, type: 'api', x: 350, y: 100, data: { url: 'http://user-service/info', method: 'GET' } },
      { id: api2Id, type: 'api', x: 350, y: 300, data: { url: 'http://order-service/history', method: 'GET' } },
      { id: scriptId, type: 'script', x: 650, y: 200, data: { script: 'return { user: input1, orders: input2 };' } },
      { id: resId, type: 'response', x: 900, y: 200, data: { contentType: 'json' } }
    ],
    edges: [
      { id: uuidv4(), sourceId: reqId, targetId: api1Id },
      { id: uuidv4(), sourceId: reqId, targetId: api2Id },
      { id: uuidv4(), sourceId: api1Id, targetId: scriptId },
      { id: uuidv4(), sourceId: api2Id, targetId: scriptId },
      { id: uuidv4(), sourceId: scriptId, targetId: resId }
    ]
  };
};

const generateComplexLogic = () => {
  const reqId = uuidv4();
  const dbCheckId = uuidv4();
  const scriptId = uuidv4();
  const dbUpdateId = uuidv4();
  const resId = uuidv4();

  return {
    nodes: [
      { id: reqId, type: 'request', x: 50, y: 150, data: { path: '/api/v1/order/submit', method: 'POST' } },
      { id: dbCheckId, type: 'database', x: 300, y: 150, data: { sourceId: 'db1', opType: 'select', sql: 'SELECT stock FROM items WHERE id = ?' } },
      { id: scriptId, type: 'script', x: 550, y: 150, data: { script: 'if (input[0].stock < req.qty) throw new Error("Out of stock"); return req;' } },
      { id: dbUpdateId, type: 'database', x: 800, y: 150, data: { sourceId: 'db1', opType: 'update', sql: 'UPDATE items SET stock = stock - ? WHERE id = ?' } },
      { id: resId, type: 'response', x: 1050, y: 150, data: { contentType: 'json' } }
    ],
    edges: [
      { id: uuidv4(), sourceId: reqId, targetId: dbCheckId },
      { id: uuidv4(), sourceId: dbCheckId, targetId: scriptId },
      { id: uuidv4(), sourceId: scriptId, targetId: dbUpdateId },
      { id: uuidv4(), sourceId: dbUpdateId, targetId: resId }
    ]
  };
};

const data = ref([
  {
    key: '1',
    name: '获取商品库存',
    path: '/api/v1/inventory/query',
    version: 'v1.0.0',
    status: 'published',
    publishTime: '2023-10-20 10:00:00',
    description: '查询指定商品的实时库存信息',
    auth: { type: 'apikey', keyName: 'X-API-KEY' },
    flow: generateSimpleCRUD()
  },
  {
    key: '2',
    name: '用户全景信息聚合',
    path: '/api/v1/user/full-profile',
    version: 'v1.0.1',
    status: 'published',
    publishTime: '2023-10-22 14:30:00',
    description: '聚合用户基本信息和订单历史',
    auth: { type: 'oauth2' },
    flow: generateApiAggregation()
  },
  {
    key: '3',
    name: '提交订单处理',
    path: '/api/v1/order/submit',
    version: 'v2.0.0',
    status: 'offline',
    publishTime: '2023-11-05 09:15:00',
    description: '包含库存检查和扣减的复杂订单处理流程',
    auth: { type: 'jwt' },
    flow: generateComplexLogic()
  }
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