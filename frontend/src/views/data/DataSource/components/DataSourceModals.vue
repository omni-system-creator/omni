<template>
  <div>
    <ConnectionModal
      v-model:open="connectionVisible"
      :edit-id="isEditMode ? currentDataSourceId : undefined"
      @success="emit('connectionSuccess')"
    />

    <CreateDatabaseModal
      v-model:open="createDbVisible"
      :connection-id="currentConnectionId"
      @success="emit('createDbSuccess', currentConnectionId)"
    />

    <CreateTableModal
      v-model:open="createTableVisible"
      :connection-id="currentDatabaseNode?.connectionId || 0"
      :database-name="currentDatabaseNode?.name || ''"
      @success="emit('createTableSuccess', currentDatabaseNode)"
    />

    <ColumnModal
      v-model:open="columnModal.visible"
      :mode="columnModal.mode"
      :initial-data="columnModal.formData"
      :existing-columns="columnModal.existingColumns"
      :connection-id="columnModal.pane?.data.connectionId || 0"
      :database-name="columnModal.pane?.data.databaseName || ''"
      :table-name="columnModal.pane?.data.tableName || ''"
      @success="emit('columnSuccess', columnModal.pane)"
    />

    <RowModal
      v-model:open="rowModal.visible"
      :mode="rowModal.mode"
      :columns="rowModal.pane?.columnData || []"
      :initial-data="rowModal.formData"
      :connection-id="rowModal.pane?.data.connectionId || 0"
      :database-name="rowModal.pane?.data.databaseName || ''"
      :table-name="rowModal.pane?.data.tableName || ''"
      @success="emit('rowSuccess', rowModal.pane)"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue';
import ConnectionModal from './ConnectionModal.vue';
import CreateDatabaseModal from './CreateDatabaseModal.vue';
import CreateTableModal from './CreateTableModal.vue';
import ColumnModal from './ColumnModal.vue';
import RowModal from './RowModal.vue';

const emit = defineEmits([
  'connectionSuccess',
  'createDbSuccess',
  'createTableSuccess',
  'columnSuccess',
  'rowSuccess'
]);

// Connection Modal State
const connectionVisible = ref(false);
const isEditMode = ref(false);
const currentDataSourceId = ref(0);

const openAddConnection = () => {
  isEditMode.value = false;
  currentDataSourceId.value = 0;
  connectionVisible.value = true;
};

const openEditConnection = (id: number) => {
  isEditMode.value = true;
  currentDataSourceId.value = id;
  connectionVisible.value = true;
};

// Create Database State
const createDbVisible = ref(false);
const currentConnectionId = ref<number>(0);

const openCreateDb = (connectionId: number) => {
  currentConnectionId.value = connectionId;
  createDbVisible.value = true;
};

// Create Table State
const createTableVisible = ref(false);
const currentDatabaseNode = ref<any>(null);

const openCreateTable = (databaseNode: any) => {
  currentDatabaseNode.value = databaseNode;
  createTableVisible.value = true;
};

// Column Modal State
const columnModal = reactive({
  visible: false,
  mode: 'add' as 'add' | 'edit',
  loading: false,
  pane: null as any,
  formData: {
     name: '',
     dataType: 'varchar',
     length: 255,
     isNullable: true,
     isPrimaryKey: false,
     isAutoIncrement: false,
     defaultValue: '',
     comment: '',
     isFirst: false,
     afterColumn: undefined as string | undefined
  },
  existingColumns: [] as any[],
  originalName: ''
});

const openAddColumn = (pane: any) => {
  columnModal.pane = pane;
  columnModal.mode = 'add';
  // Reset form
  columnModal.formData = {
     name: '',
     dataType: 'varchar',
     length: 255,
     isNullable: true,
     isPrimaryKey: false,
     isAutoIncrement: false,
     defaultValue: '',
     comment: '',
     isFirst: false,
     afterColumn: undefined
  };
  columnModal.existingColumns = pane.columnData || [];
  columnModal.visible = true;
};

const openEditColumn = (record: any, pane: any) => {
  columnModal.pane = pane;
  columnModal.mode = 'edit';
  columnModal.originalName = record.name;
  
  // Try to parse length from columnType, e.g. "varchar(255)"
  let length = 255;
  const match = (record.columnType || '').match(/\((\d+)(?:,(\d+))?\)/);
  if (match) {
      length = parseInt(match[1]);
  }

  columnModal.formData = {
     name: record.name,
     dataType: record.dataType,
     length: length,
     isNullable: record.isNullable,
     isPrimaryKey: record.isPrimaryKey,
     isAutoIncrement: (record.columnType || '').toLowerCase().includes('auto_increment'),
     defaultValue: record.defaultValue,
     comment: record.comment,
     isFirst: false,
     afterColumn: undefined
  };
  
  columnModal.existingColumns = (pane.columnData || []).filter((c: any) => c.name !== record.name);
  columnModal.visible = true;
};

// Row Modal State
const rowModal = reactive({
  visible: false,
  mode: 'insert' as 'insert' | 'edit',
  loading: false,
  pane: null as any,
  formData: {} as Record<string, any>
});

const openInsertRow = (pane: any) => {
  rowModal.pane = pane;
  rowModal.mode = 'insert';
  rowModal.formData = {};
  
  // Initialize default values
  if (pane.columnData) {
      pane.columnData.forEach((col: any) => {
          if (col.defaultValue !== null) {
             rowModal.formData[col.name] = col.defaultValue;
          } else {
             rowModal.formData[col.name] = null; // or undefined
          }
      });
  }
  
  rowModal.visible = true;
};

const openEditRow = (record: any, pane: any) => {
  rowModal.pane = pane;
  rowModal.mode = 'edit';
  rowModal.formData = { ...record }; // Clone data
  rowModal.visible = true;
};

defineExpose({
  openAddConnection,
  openEditConnection,
  openCreateDb,
  openCreateTable,
  openAddColumn,
  openEditColumn,
  openInsertRow,
  openEditRow
});
</script>
