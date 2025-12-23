<template>
  <div class="table-details">
     <div class="detail-header">
       <h3>{{ title }}</h3>
       <a-space>
         <a-button @click="refresh">
            <template #icon><ReloadOutlined /></template> 刷新
         </a-button>
       </a-space>
     </div>
    
    <a-tabs v-model:activeKey="activeSubTab" class="table-tabs">
      <a-tab-pane key="columns" tab="列信息">
        <TableColumnList
          :column-defs="columnDefs"
          :column-data="columnData"
          :loading-columns="loadingColumns"
          @addColumn="$emit('addColumn')"
          @editColumn="(record) => $emit('editColumn', record)"
          @deleteColumn="handleDeleteColumn"
        />
      </a-tab-pane>
      <a-tab-pane key="data" tab="数据管理">
        <TableDataList
          :column-data="columnData"
          :preview-columns="previewColumns"
          :preview-data="previewData"
          :pagination="pagination"
          :loading-data="loadingData"
          :query-state="queryState"
          @insertRow="$emit('insertRow')"
          @filter="executeFilter"
          @resetFilter="resetFilter"
          @tableChange="handleTableChange"
          @editRow="(record) => $emit('editRow', record)"
          @deleteRow="handleDeleteRow"
        />
      </a-tab-pane>
    </a-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue';
import { message } from 'ant-design-vue';
import { ReloadOutlined } from '@ant-design/icons-vue';
import * as api from '@/api/dataSource';
import TableColumnList from './TableColumnList.vue';
import TableDataList from './TableDataList.vue';

const props = defineProps<{
  connectionId: number;
  databaseName: string;
  tableName: string;
  title: string;
  columnsTrigger?: number;
  dataTrigger?: number;
}>();

const emit = defineEmits([
  'addColumn', 
  'editColumn', 
  'insertRow', 
  'editRow'
]);

// Watch triggers
import { watch } from 'vue';
watch(() => props.columnsTrigger, () => {
  loadColumns();
});

watch(() => props.dataTrigger, () => {
  loadTableData();
});

const activeSubTab = ref('columns');

// Columns
const loadingColumns = ref(false);
const columnData = ref<any[]>([]);

const columnDefs = [
  { title: '列名', dataIndex: 'name', key: 'name' },
  { title: '类型', dataIndex: 'columnType', key: 'columnType' },
  { title: 'PK', dataIndex: 'isPrimaryKey', key: 'isPrimaryKey', width: 60, align: 'center' },
  { title: 'Null', dataIndex: 'isNullable', key: 'isNullable', width: 60, align: 'center' },
  { title: '默认值', dataIndex: 'defaultValue', key: 'defaultValue' },
  { title: '注释', dataIndex: 'comment', key: 'comment' },
  { title: '操作', key: 'action', width: 120 }
];

// Data Preview
const loadingData = ref(false);
const previewData = ref<any[]>([]);
const previewColumns = ref<any[]>([]);

const pagination = reactive({
  current: 1,
  pageSize: 20,
  total: 0,
  showSizeChanger: true,
  pageSizeOptions: ['10', '20', '50', '100']
});

const queryState = reactive({
  filterField: undefined,
  filterOperator: '=',
  filterValue: '',
  sortField: '',
  sortOrder: ''
});

const getFieldLabel = (col: any) => {
  if (!col.comment) return col.name;
  let label = col.comment.split(/,|，/)[0];
  if (label.length > 8) {
    label = label.substring(0, 8) + '...';
  }
  return label;
};

// --- Methods ---

const loadColumns = async () => {
  loadingColumns.value = true;
  try {
    const res = await api.getColumns(
      props.connectionId, 
      props.databaseName, 
      props.tableName
    );
    if (res) {
      columnData.value = res.map((col: any) => ({
          ...col,
          comment: col.comment || col.Comment || ''
      }));
    }
  } catch (error) {
    message.error('加载列信息失败');
  } finally {
    loadingColumns.value = false;
  }
};

const loadTableData = async () => {
  loadingData.value = true;
  
  const filters = [];
  if (queryState.filterField && queryState.filterValue) {
    filters.push({
      field: queryState.filterField,
      operator: queryState.filterOperator,
      value: queryState.filterValue
    });
  }

  const query = {
    page: pagination.current,
    pageSize: pagination.pageSize,
    sortField: queryState.sortField,
    sortOrder: queryState.sortOrder,
    filters: filters
  };

  try {
    const res = await api.getTableData(
      props.connectionId, 
      props.databaseName, 
      props.tableName,
      query
    );
    
    if (res && res.rows) {
      const result = res; 
      pagination.total = result.total;
      
      if (result.columns && result.columns.length > 0) {
        const cols: any[] = result.columns.map((col: any) => {
          return {
            title: getFieldLabel(col),
            dataIndex: col.name,
            key: col.name,
            width: 150,
            ellipsis: true,
            sorter: true,
            tooltip: col.name
          };
        });
        cols.push({
            title: '操作',
            key: 'action',
            width: 120,
            fixed: 'right'
        });
        previewColumns.value = cols;
      }
      
      previewData.value = result.rows;
    } else {
        if (res.rows) {
             pagination.total = res.total;
             if (res.columns) {
                const cols: any[] = res.columns.map((col: any) => {
                  return {
                    title: getFieldLabel(col),
                    dataIndex: col.name,
                    key: col.name,
                    width: 150,
                    ellipsis: true,
                    sorter: true,
                    tooltip: col.name
                  };
                });
                cols.push({
                    title: '操作',
                    key: 'action',
                    width: 120,
                    fixed: 'right'
                });
                previewColumns.value = cols;
             }
             previewData.value = res.rows;
        }
    }
  } catch (error) {
    message.error('加载数据失败');
  } finally {
    loadingData.value = false;
  }
};

const refresh = async () => {
  await loadColumns();
  if (activeSubTab.value === 'data') {
      loadTableData();
  }
};

const handleDeleteColumn = async (record: any) => {
    try {
        await api.deleteColumn(props.connectionId, props.databaseName, props.tableName, record.name);
        message.success('删除列成功');
        loadColumns();
    } catch (error) {
        message.error('删除列失败');
    }
};

const handleDeleteRow = async (record: any) => {
  const keys: Record<string, any> = {};
  if (columnData.value) {
      columnData.value.filter(c => c.isPrimaryKey).forEach(c => {
          keys[c.name] = record[c.name];
      });
  }
  
  if (Object.keys(keys).length === 0) {
      message.error('该表没有主键，无法删除行数据');
      return;
  }
  
  try {
      await api.deleteRow(props.connectionId, props.databaseName, props.tableName, keys);
      message.success('删除成功');
      loadTableData();
  } catch (error) {
      message.error('删除失败');
  }
};

const handleTableChange = (pag: any, _filters: any, sorter: any) => {
  pagination.current = pag.current;
  pagination.pageSize = pag.pageSize;
  
  if (sorter.field) {
    queryState.sortField = sorter.field;
    queryState.sortOrder = sorter.order === 'ascend' ? 'asc' : (sorter.order === 'descend' ? 'desc' : '');
  }
  
  loadTableData();
};

const executeFilter = () => {
  pagination.current = 1;
  loadTableData();
};

const resetFilter = () => {
  queryState.filterField = undefined;
  queryState.filterOperator = '=';
  queryState.filterValue = '';
  queryState.sortField = '';
  queryState.sortOrder = '';
  executeFilter();
};

onMounted(() => {
  loadColumns();
  // Optional: Lazy load data when tab switched? Or load immediately?
  // User might want to see data immediately.
  loadTableData();
});

defineExpose({
    refresh,
    loadTableData,
    loadColumns,
    columnData // Expose column data for Modals
});
</script>

<style lang="scss" scoped>
.table-details {
  height: 100%;
  display: flex;
  flex-direction: column;
  padding: 16px;
}

.detail-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.table-tabs {
  :deep(.ant-tabs-nav-wrap) {
    height: 40px;
  }
  :deep(.ant-tabs-tab) {
    padding: 0;
    height: 40px;
  }
}

:deep(.ant-tabs-tab-btn) {
  padding: 0 10px;
}
</style>
