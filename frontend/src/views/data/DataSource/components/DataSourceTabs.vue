<template>
  <div class="right-panel">
    <a-tabs 
      v-model:activeKey="activeKey" 
      type="editable-card" 
      hide-add 
      @edit="onEdit"
      class="main-tabs"
    >
      <a-tab-pane v-for="pane in panes" :key="pane.key" :tab="pane.title" :closable="pane.closable">
        
        <ConnectionInfo 
          v-if="pane.type === 'connection'"
          :title="pane.title"
          :data="pane.contentData || []"
          :loading="pane.loading || false"
          :columns="dbColumns"
          @createDb="$emit('createDb', pane.data.id)"
          @refresh="refreshPane(pane)"
          @openTab="openTab"
        />

        <DatabaseInfo 
          v-if="pane.type === 'database'"
          :title="pane.title"
          :data="pane.contentData || []"
          :loading="pane.loading || false"
          :columns="tableListColumns"
          @createTable="$emit('createTable', pane.data)"
          @refresh="refreshPane(pane)"
          @openTable="openTableTab($event, pane.data)"
        />

        <TableDetail 
          v-if="pane.type === 'table'"
          :connection-id="pane.data.connectionId"
          :database-name="pane.data.databaseName"
          :table-name="pane.data.tableName"
          :title="pane.title"
          @addColumn="$emit('handleOpenAddColumn', pane)"
          @editColumn="(record) => $emit('handleOpenEditColumn', record, pane)"
          @insertRow="$emit('handleInsertRow', pane)"
          @editRow="(record) => $emit('handleEditRow', record, pane)"
        />

      </a-tab-pane>
    </a-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { message } from 'ant-design-vue';
import * as api from '@/api/dataSource';
import ConnectionInfo from './ConnectionInfo.vue';
import DatabaseInfo from './DatabaseInfo.vue';
import TableDetail from './TableDetail.vue';

const emit = defineEmits([
  'createDb',
  'createTable',
  'handleOpenAddColumn',
  'handleOpenEditColumn',
  'handleInsertRow',
  'handleEditRow'
]);

// Tab State
interface Pane {
  title: string;
  key: string;
  type: 'connection' | 'database' | 'table';
  closable?: boolean;
  data: any; // Node data
  contentData?: any[]; // For lists (DBs, Tables)
  loading?: boolean;
  columnsTrigger?: number;
  dataTrigger?: number;
}

const activeKey = ref<string>('');
const panes = ref<Pane[]>([]);

// List Columns
const dbColumns = [
  { title: '数据库名称', dataIndex: 'name', key: 'name' },
  { title: '字符集', dataIndex: 'charSet', key: 'charSet' },
  { title: '排序规则', dataIndex: 'collation', key: 'collation' },
  { title: '表数量', dataIndex: 'tableCount', key: 'tableCount' },
  { title: '数据大小', dataIndex: 'dataLength', key: 'dataLength' },
  { title: '操作', key: 'action', width: 150 }
];

const tableListColumns = [
  { title: '表名称', dataIndex: 'name', key: 'name' },
  { title: '备注', dataIndex: 'comment', key: 'comment' },
  { title: '行数', dataIndex: 'rows', key: 'rows' },
  { title: '数据大小', dataIndex: 'dataLength', key: 'dataLength' },
  { title: '操作', key: 'action', width: 150 }
];

const formatBytes = (bytes: number, decimals = 2) => {
    if (!bytes) return '0 B';
    const k = 1024;
    const dm = decimals < 0 ? 0 : decimals;
    const sizes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
};

const fetchNodeChildren = async (nodeData: any) => {
  if (nodeData.type === 'connection') {
    const res = await api.getDatabases(nodeData.id);
    if (res) {
      return res.map((db: any) => ({
        title: db.name,
        key: `db-${nodeData.id}-${db.name}`,
        type: 'database',
        connectionId: nodeData.id,
        name: db.name,
        charSet: db.charSet,
        collation: db.collation,
        tableCount: db.tableCount,
        dataLength: formatBytes(db.dataLength),
        isLeaf: false
      }));
    }
  } else if (nodeData.type === 'database') {
    const res = await api.getTables(nodeData.connectionId, nodeData.name);
    if (res) {
      return res.map((tb: any) => ({
        title: tb.name,
        key: `tb-${nodeData.connectionId}-${nodeData.name}-${tb.name}`,
        type: 'table',
        connectionId: nodeData.connectionId,
        databaseName: nodeData.name,
        tableName: tb.name,
        name: tb.name,
        comment: tb.comment,
        rows: tb.rows,
        dataLength: formatBytes(tb.dataLength),
        isLeaf: true
      }));
    }
  }
  return [];
};

const refreshPane = async (pane: Pane, showMessage = true) => {
  pane.loading = true;
  try {
    const children = await fetchNodeChildren(pane.data);
    pane.contentData = children;
    if (showMessage) {
      message.success('刷新成功');
    }
  } catch (error) {
    message.error('刷新失败');
  } finally {
    pane.loading = false;
  }
};

const openTab = (node: any) => {
  const existingPane = panes.value.find(p => p.key === node.key);
  if (existingPane) {
    activeKey.value = existingPane.key;
    refreshPane(existingPane, false); // Optional: auto-refresh on switch
    return;
  }

  const newPane: Pane = {
    title: node.title,
    key: node.key,
    type: node.type,
    closable: true,
    data: node,
    loading: false,
    contentData: []
  };

  panes.value.push(newPane);
  activeKey.value = newPane.key;

  if (node.type === 'connection' || node.type === 'database') {
    refreshPane(newPane, false);
  }
};

const openTableTab = (record: any, parentNode: any) => {
  const node = {
    ...record,
    connectionId: parentNode.connectionId,
    databaseName: parentNode.name,
    tableName: record.name,
    type: 'table',
    title: record.name,
    key: `tb-${parentNode.connectionId}-${parentNode.name}-${record.name}`
  };
  openTab(node);
};

const removeTab = (targetKey: string) => {
  let lastIndex = -1;
  panes.value.forEach((pane, i) => {
    if (pane.key === targetKey) {
      lastIndex = i - 1;
    }
  });
  panes.value = panes.value.filter(pane => pane.key !== targetKey);
  if (panes.value.length && activeKey.value === targetKey) {
    if (lastIndex >= 0) {
      activeKey.value = panes.value[lastIndex]!.key;
    } else {
      activeKey.value = panes.value[0]!.key;
    }
  }
};

const onEdit = (targetKey: any, action: string) => {
  if (action === 'remove') {
    removeTab(targetKey as string);
  }
};

// Exposed for parent to call
const refreshNode = (node: any) => {
  const pane = panes.value.find(p => p.key === node.key);
  if (pane) {
    refreshPane(pane);
  }
};

const refreshTableColumns = (paneData: any) => {
  // Try to find by pane object or key
  const pane = panes.value.find(p => p.key === paneData.key);
  if (pane) {
    pane.columnsTrigger = (pane.columnsTrigger || 0) + 1;
  }
};

const refreshTableData = (paneData: any) => {
  const pane = panes.value.find(p => p.key === paneData.key);
  if (pane) {
    pane.dataTrigger = (pane.dataTrigger || 0) + 1;
  }
};

const getActivePane = () => {
  return panes.value.find(p => p.key === activeKey.value);
};

defineExpose({
  openTab,
  refreshNode,
  refreshTableColumns,
  refreshTableData,
  getActivePane
});
</script>

<style scoped>
.right-panel {
  flex: 1;
  overflow-y: auto;
  background: #fff;
  display: flex;
  flex-direction: column;
}

.main-tabs {
  height: 100%;
}

/* Ant Design Override for full height */
:deep(.ant-tabs) {
  flex: 1;
  display: flex;
  flex-direction: column;
}

:deep(.ant-tabs-top >.ant-tabs-nav) {
  margin-bottom: 0 !important;
}

:deep(.ant-tabs-content) {
  flex: 1;
  display: flex;
  flex-direction: column;
}

:deep(.ant-tabs-tabpane) {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow-y: auto; /* Allow scrolling within tab pane */
}

/* Custom Tab Styles */
:deep(.ant-tabs-nav-wrap) {
  height: 50px;
}

:deep(.ant-tabs-tab) {
  border-radius: 0 !important;
  height: 50px; 
  border-top: none !important;
}
</style>
