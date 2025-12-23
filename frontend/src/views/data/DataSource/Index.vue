<template>
  <div class="page-container">
    <DataSourceSidebar
      ref="sidebarRef"
      @select="onSidebarSelect"
      @addConnection="onAddConnection"
      @createDb="onCreateDb"
      @createTable="onCreateTable"
      @editConnection="onEditConnection"
      @nodeRefreshed="onNodeRefreshed"
    />
    
    <DataSourceTabs
      ref="tabsRef"
      @createDb="onCreateDb"
      @createTable="onCreateTable"
      @handleOpenAddColumn="onOpenAddColumn"
      @handleOpenEditColumn="onOpenEditColumn"
      @handleInsertRow="onInsertRow"
      @handleEditRow="onEditRow"
    />

    <DataSourceModals
      ref="modalsRef"
      @connectionSuccess="onConnectionSuccess"
      @createDbSuccess="onCreateDbSuccess"
      @createTableSuccess="onCreateTableSuccess"
      @columnSuccess="onColumnSuccess"
      @rowSuccess="onRowSuccess"
    />
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import DataSourceSidebar from './components/DataSourceSidebar.vue';
import DataSourceTabs from './components/DataSourceTabs.vue';
import DataSourceModals from './components/DataSourceModals.vue';

const sidebarRef = ref();
const tabsRef = ref();
const modalsRef = ref();

// Sidebar Events
const onSidebarSelect = (node: any) => {
  tabsRef.value?.openTab(node);
};

const onAddConnection = () => {
  modalsRef.value?.openAddConnection();
};

const onEditConnection = (id: number) => {
  modalsRef.value?.openEditConnection(id);
};

const onCreateDb = (connectionId: number) => {
  modalsRef.value?.openCreateDb(connectionId);
};

const onCreateTable = (databaseNode: any) => {
  modalsRef.value?.openCreateTable(databaseNode);
};

// Tabs Events
const onOpenAddColumn = (pane: any) => {
  modalsRef.value?.openAddColumn(pane);
};

const onOpenEditColumn = (record: any, pane: any) => {
  modalsRef.value?.openEditColumn(record, pane);
};

const onInsertRow = (pane: any) => {
  modalsRef.value?.openInsertRow(pane);
};

const onEditRow = (record: any, pane: any) => {
  modalsRef.value?.openEditRow(record, pane);
};

const onNodeRefreshed = (_node: any, _children: any[]) => {
    // Optional: Sync tabs if needed
};

// Modal Success Handlers
const onConnectionSuccess = () => {
  sidebarRef.value?.loadDataSources();
};

const onCreateDbSuccess = (connectionId: number) => {
  // Refresh connection node in sidebar
  sidebarRef.value?.refreshNodeByKey(`conn-${connectionId}`);
  // Refresh connection tab if open
  tabsRef.value?.refreshNode({ key: `conn-${connectionId}` });
};

const onCreateTableSuccess = (databaseNode: any) => {
  sidebarRef.value?.refreshNode(databaseNode);
  tabsRef.value?.refreshNode(databaseNode);
};

const onColumnSuccess = (pane: any) => {
  if (pane) {
     tabsRef.value?.refreshTableColumns(pane);
  }
};

const onRowSuccess = (pane: any) => {
  if (pane) {
      tabsRef.value?.refreshTableData(pane);
  }
};

</script>

<style scoped>
.page-container {
  display: flex;
  height: 100vh;
  overflow: hidden;
}
</style>
