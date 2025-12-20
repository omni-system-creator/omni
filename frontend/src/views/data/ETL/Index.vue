<template>
  <div class="page-container">
    <div class="header-actions">
      <div class="filters">
        <a-input-search placeholder="搜索ETL任务名称" style="width: 300px" />
        <a-select defaultValue="all" style="width: 120px; margin-left: 16px">
          <a-select-option value="all">全部状态</a-select-option>
          <a-select-option value="active">启用</a-select-option>
          <a-select-option value="disabled">停用</a-select-option>
        </a-select>
      </div>
      <a-button type="primary" @click="showDrawer">
        <template #icon><PlusOutlined /></template>
        新建ETL任务
      </a-button>
    </div>

    <a-table :columns="columns" :data-source="data" :pagination="{ pageSize: 10 }">
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'status'">
          <a-switch v-model:checked="record.status" checked-children="启用" un-checked-children="停用" />
        </template>
        <template v-else-if="column.key === 'lastRunStatus'">
          <a-tag :color="record.lastRunStatus === 'success' ? 'success' : record.lastRunStatus === 'failed' ? 'error' : 'default'">
            {{ record.lastRunStatus === 'success' ? '成功' : record.lastRunStatus === 'failed' ? '失败' : '未运行' }}
          </a-tag>
        </template>
        <template v-else-if="column.key === 'action'">
          <a-space>
            <a @click="openEdit(record)">编辑</a>
            <a>立即运行</a>
            <a>日志</a>
            <a-popconfirm title="确定删除吗？">
              <a style="color: #ff4d4f">删除</a>
            </a-popconfirm>
          </a-space>
        </template>
      </template>
    </a-table>

    <EtlEditorDrawer
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
import EtlEditorDrawer from './components/EtlEditorDrawer.vue';

const visible = ref(false);
const editingId = ref<string | null>(null);
const drawerData = ref<any>(null);

const columns = [
  { title: '任务名称', dataIndex: 'name', key: 'name' },
  { title: '调度策略', dataIndex: 'cron', key: 'cron' },
  { title: '上次运行时间', dataIndex: 'lastRunTime', key: 'lastRunTime' },
  { title: '运行状态', dataIndex: 'lastRunStatus', key: 'lastRunStatus' },
  { title: '任务状态', dataIndex: 'status', key: 'status', width: 100 },
  { title: '操作', key: 'action', width: 250 },
];

const data = ref([
  { 
    key: '1', 
    name: '每日销售清洗入库', 
    cron: '0 0 2 * * ?', 
    lastRunTime: '2023-10-25 02:00:00', 
    lastRunStatus: 'success', 
    status: true 
  },
  { 
    key: '2', 
    name: 'CRM客户数据同步', 
    cron: '0 */30 * * * ?', 
    lastRunTime: '2023-10-25 10:30:00', 
    lastRunStatus: 'failed', 
    status: true 
  },
  { 
    key: '3', 
    name: '用户行为日志分析', 
    cron: '0 0/5 * * * ?', 
    lastRunTime: '2023-10-25 11:05:00', 
    lastRunStatus: 'success', 
    status: true 
  },
  { 
    key: '4', 
    name: '库存实时同步', 
    cron: '0 0 * * * ?', 
    lastRunTime: '2023-10-25 11:00:00', 
    lastRunStatus: 'default', 
    status: false 
  },
]);

interface NodeData {
  id: string;
  type: 'extract' | 'transform' | 'load';
  x: number;
  y: number;
  data: any;
}

interface EdgeData {
  id: string;
  sourceId: string;
  targetId: string;
}

const mockGraphData: Record<string, { nodes: NodeData[], edges: EdgeData[] }> = {
    '1': { // 每日销售清洗入库
        nodes: [
            { id: 'n1', type: 'extract', x: 50, y: 100, data: { sourceId: 'db1', query: 'SELECT * FROM sales_daily' } },
            { id: 'n2', type: 'transform', x: 300, y: 100, data: { method: 'filter' } },
            { id: 'n3', type: 'transform', x: 550, y: 100, data: { method: 'map' } },
            { id: 'n4', type: 'load', x: 800, y: 100, data: { targetId: 'dw1', targetTable: 'fact_sales' } }
        ],
        edges: [
            { id: 'e1', sourceId: 'n1', targetId: 'n2' },
            { id: 'e2', sourceId: 'n2', targetId: 'n3' },
            { id: 'e3', sourceId: 'n3', targetId: 'n4' }
        ]
    },
    '2': { // CRM客户数据同步
        nodes: [
            { id: 'n1', type: 'extract', x: 50, y: 100, data: { sourceId: 'api1' } },
            { id: 'n2', type: 'transform', x: 350, y: 100, data: { method: 'map' } },
            { id: 'n3', type: 'load', x: 650, y: 100, data: { targetId: 'db1', targetTable: 'dim_customer' } }
        ],
        edges: [
            { id: 'e1', sourceId: 'n1', targetId: 'n2' },
            { id: 'e2', sourceId: 'n2', targetId: 'n3' }
        ]
    },
    '3': { // 用户行为日志分析
        nodes: [
            { id: 'n1', type: 'extract', x: 50, y: 50, data: { sourceId: 'db2', query: 'db.logs.find({...})' } },
            { id: 'n2', type: 'transform', x: 300, y: 50, data: { method: 'script', script: '// Parse UserAgent' } },
            { id: 'n3', type: 'transform', x: 300, y: 200, data: { method: 'filter', script: '// Filter bots' } },
            { id: 'n4', type: 'load', x: 600, y: 125, data: { targetId: 'dw1', targetTable: 'log_analytics' } }
        ],
        edges: [
            { id: 'e1', sourceId: 'n1', targetId: 'n2' },
            { id: 'e2', sourceId: 'n1', targetId: 'n3' },
            { id: 'e3', sourceId: 'n2', targetId: 'n4' },
            { id: 'e4', sourceId: 'n3', targetId: 'n4' }
        ]
    },
    '4': { // 库存实时同步
        nodes: [
            { id: 'n1', type: 'extract', x: 50, y: 100, data: { sourceId: 'db1', query: 'SELECT * FROM inventory_changes' } },
            { id: 'n2', type: 'load', x: 400, y: 100, data: { targetId: 'api1', targetTable: '/api/v1/inventory/sync' } }
        ],
        edges: [
            { id: 'e1', sourceId: 'n1', targetId: 'n2' }
        ]
    }
};

const showDrawer = () => {
  editingId.value = null;
  drawerData.value = null;
  visible.value = true;
};

const openEdit = (record: any) => {
  editingId.value = record.key;
  const graph = mockGraphData[record.key];
  drawerData.value = {
      name: record.name,
      cron: record.cron,
      desc: '这是一个示例任务描述',
      notifications: [],
      nodes: graph ? JSON.parse(JSON.stringify(graph.nodes)) : [],
      edges: graph ? JSON.parse(JSON.stringify(graph.edges)) : []
  };
  visible.value = true;
};

const onSave = (data: any) => {
    console.log('Saved:', data);
    visible.value = false;
};
</script>

<style scoped>
.page-container {
  padding: 24px;
}
.header-actions {
  display: flex;
  justify-content: space-between;
  margin-bottom: 24px;
}
</style>
