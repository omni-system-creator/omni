<template>
  <div class="page-container">
    <div class="left-panel">
      <div class="panel-header">
        <span class="title">数据源连接</span>
        <a-button type="primary" size="small" @click="showAddModal">
          <template #icon><PlusOutlined /></template>
        </a-button>
      </div>
      <div class="tree-container">
        <a-tree
          v-model:expandedKeys="expandedKeys"
          v-model:selectedKeys="selectedKeys"
          :tree-data="treeData"
          @select="onSelect"
        >
          <template #title="{ title, type }">
            <span v-if="type === 'connection'"><DatabaseOutlined /> {{ title }}</span>
            <span v-else-if="type === 'database'"><FolderOutlined /> {{ title }}</span>
            <span v-else-if="type === 'table'"><TableOutlined /> {{ title }}</span>
            <span v-else>{{ title }}</span>
          </template>
        </a-tree>
      </div>
    </div>
    
    <div class="right-panel">
      <div v-if="selectedNode && selectedNode.type === 'table'" class="table-details">
        <div class="detail-header">
          <h3>{{ selectedNode.title }} <a-tag color="blue">InnoDB</a-tag></h3>
          <a-space>
            <a-button>刷新</a-button>
            <a-button type="primary">保存修改</a-button>
          </a-space>
        </div>
        
        <a-tabs v-model:activeKey="activeTab">
          <a-tab-pane key="columns" tab="列信息">
            <a-table :columns="columnDefs" :data-source="columnData" :pagination="false" size="small" bordered>
              <template #bodyCell="{ column, record }">
                <template v-if="['pk', 'nn', 'ai'].includes(column.key)">
                  <a-checkbox v-model:checked="record[column.key]" />
                </template>
              </template>
            </a-table>
          </a-tab-pane>
          <a-tab-pane key="indexes" tab="索引信息">
            <a-table :columns="indexDefs" :data-source="indexData" :pagination="false" size="small" bordered />
          </a-tab-pane>
          <a-tab-pane key="data" tab="数据管理">
             <div class="data-toolbar">
               <a-input-search placeholder="输入SQL查询条件" style="width: 300px" />
               <a-space>
                 <a-button type="dashed">执行查询</a-button>
                 <a-button><PlusOutlined /> 新增行</a-button>
               </a-space>
             </div>
             <a-table :columns="previewColumns" :data-source="previewData" :pagination="{ pageSize: 20 }" size="small" scroll="{ x: 1000 }" />
          </a-tab-pane>
        </a-tabs>
      </div>
      
      <div v-else class="empty-state">
        <a-empty description="请选择左侧的数据表进行管理" />
      </div>
    </div>

    <!-- Add Connection Modal -->
    <a-modal v-model:visible="visible" title="新建数据源连接" @ok="handleOk">
      <a-form :model="formState" :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }">
        <a-form-item label="连接名称">
          <a-input v-model:value="formState.name" />
        </a-form-item>
        <a-form-item label="数据源类型">
          <a-select v-model:value="formState.type">
            <a-select-option value="mysql">MySQL</a-select-option>
            <a-select-option value="postgresql">PostgreSQL</a-select-option>
            <a-select-option value="oracle">Oracle</a-select-option>
            <a-select-option value="sqlserver">SQL Server</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="主机地址">
          <a-input v-model:value="formState.host" placeholder="127.0.0.1" />
        </a-form-item>
        <a-form-item label="端口">
          <a-input v-model:value="formState.port" placeholder="3306" />
        </a-form-item>
        <a-form-item label="用户名">
          <a-input v-model:value="formState.user" />
        </a-form-item>
        <a-form-item label="密码">
          <a-input-password v-model:value="formState.password" />
        </a-form-item>
        <a-form-item label="默认数据库">
          <a-input v-model:value="formState.database" />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue';
import { 
  PlusOutlined, 
  DatabaseOutlined, 
  FolderOutlined, 
  TableOutlined 
} from '@ant-design/icons-vue';

const expandedKeys = ref<string[]>(['0-0', '0-0-0']);
const selectedKeys = ref<string[]>([]);
const selectedNode = ref<any>(null);
const activeTab = ref('columns');
const visible = ref(false);

const formState = reactive({
  name: '',
  type: 'mysql',
  host: '',
  port: '',
  user: '',
  password: '',
  database: '',
});

const treeData = [
  {
    title: 'Local MySQL',
    key: '0-0',
    type: 'connection',
    children: [
      {
        title: 'oms_db',
        key: '0-0-0',
        type: 'database',
        children: [
          { title: 'sys_user', key: '0-0-0-0', type: 'table' },
          { title: 'sys_role', key: '0-0-0-1', type: 'table' },
          { title: 'biz_order', key: '0-0-0-2', type: 'table' },
          { title: 'biz_product', key: '0-0-0-3', type: 'table' },
        ],
      },
      {
        title: 'test_db',
        key: '0-0-1',
        type: 'database',
        children: [{ title: 'temp_log', key: '0-0-1-0', type: 'table' }],
      },
    ],
  },
  {
    title: 'Prod PostgreSQL',
    key: '0-1',
    type: 'connection',
    children: [
      { title: 'analytics', key: '0-1-0', type: 'database', isLeaf: true },
    ],
  },
];

// Mock Columns
const columnDefs = [
  { title: '名', dataIndex: 'name', key: 'name' },
  { title: '类型', dataIndex: 'type', key: 'type' },
  { title: '长度', dataIndex: 'length', key: 'length' },
  { title: 'PK', dataIndex: 'pk', key: 'pk', width: 50 },
  { title: 'NN', dataIndex: 'nn', key: 'nn', width: 50 },
  { title: 'AI', dataIndex: 'ai', key: 'ai', width: 50 }, // Auto Increment
  { title: '默认值', dataIndex: 'default', key: 'default' },
  { title: '注释', dataIndex: 'comment', key: 'comment' },
];

const columnData = ref([
  { key: '1', name: 'id', type: 'BIGINT', length: 20, pk: true, nn: true, ai: true, default: '', comment: '主键' },
  { key: '2', name: 'username', type: 'VARCHAR', length: 50, pk: false, nn: true, ai: false, default: '', comment: '用户名' },
  { key: '3', name: 'status', type: 'TINYINT', length: 1, pk: false, nn: true, ai: false, default: '1', comment: '状态' },
  { key: '4', name: 'created_at', type: 'DATETIME', length: 0, pk: false, nn: false, ai: false, default: 'CURRENT_TIMESTAMP', comment: '创建时间' },
]);

// Mock Indexes
const indexDefs = [
  { title: '索引名', dataIndex: 'name', key: 'name' },
  { title: '类型', dataIndex: 'type', key: 'type' }, // PRIMARY, UNIQUE, INDEX
  { title: '列', dataIndex: 'columns', key: 'columns' },
  { title: '方法', dataIndex: 'method', key: 'method' }, // BTREE
];

const indexData = ref([
  { key: '1', name: 'PRIMARY', type: 'PRIMARY', columns: 'id', method: 'BTREE' },
  { key: '2', name: 'idx_username', type: 'UNIQUE', columns: 'username', method: 'BTREE' },
]);

// Mock Preview Data
const previewColumns = [
  { title: 'id', dataIndex: 'id' },
  { title: 'username', dataIndex: 'username' },
  { title: 'status', dataIndex: 'status' },
  { title: 'created_at', dataIndex: 'created_at' },
];

const previewData = ref([
  { id: 1, username: 'admin', status: 1, created_at: '2025-01-01 10:00:00' },
  { id: 2, username: 'user01', status: 1, created_at: '2025-01-02 11:30:00' },
]);

const onSelect = (_keys: string[], info: any) => {
  if (info.node.type === 'table') {
    selectedNode.value = { ...info.node };
  } else {
    selectedNode.value = null;
  }
};

const showAddModal = () => {
  visible.value = true;
};

const handleOk = () => {
  visible.value = false;
  // Logic to add connection
};
</script>

<style scoped>
.page-container {
  display: flex;
  height: 100%;
  background: #fff;
}

.left-panel {
  width: 280px;
  border-right: 1px solid #f0f0f0;
  display: flex;
  flex-direction: column;
}

.panel-header {
  padding: 16px;
  border-bottom: 1px solid #f0f0f0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #fafafa;
}

.title {
  font-weight: 500;
  color: #333;
}

.tree-container {
  flex: 1;
  overflow-y: auto;
  padding: 8px;
}

.right-panel {
  flex: 1;
  padding: 24px;
  overflow-y: auto;
  background: #fff;
}

.table-details {
  height: 100%;
}

.detail-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.data-toolbar {
  margin-bottom: 16px;
  display: flex;
  justify-content: space-between;
}

.empty-state {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100%;
  color: #999;
}
</style>