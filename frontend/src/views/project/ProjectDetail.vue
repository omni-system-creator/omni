<template>
  <div class="project-detail-container">
    <Controls :isActive="true" />
    <div class="main-content">
      <a-tabs v-model:activeKey="activeTab" type="card" class="project-tabs" :tabBarStyle="{ margin: 0, padding: '8px 8px 0' }">
        <template #leftExtra>
          <div id="tab-toolbar-target" style="display: flex; align-items: center; min-width: 200px; margin-right: 16px;"></div>
        </template>
        <a-tab-pane key="flowchart" tab="泳道图">
          <div class="tab-view-container">
            <div class="canvas-area">
              <LeaferCanvas />
            </div>
          </div>
        </a-tab-pane>
        <a-tab-pane key="gantt" tab="甘特图">
          <div class="tab-view-container">
             <TaskGanttView :isActive="activeTab === 'gantt'" />
          </div>
        </a-tab-pane>
        <a-tab-pane key="kanban" tab="看板">
          <div class="tab-view-container">
             <KanbanView />
          </div>
        </a-tab-pane>
      </a-tabs>
      <StatusBar />
    </div>

    <!-- Global Detail Panel (Right Side) -->
    <div class="detail-area" v-if="store.selectedElement">
      <DetailPanel />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted, watch } from 'vue';
import { useRoute } from 'vue-router';
import { useProjectFlowStore } from '@/stores/projectFlowStore';
import { useTabsStore } from '@/stores/tabs';
import Controls from './components/Controls.vue';
import LeaferCanvas from './components/LeaferCanvas.vue';
import DetailPanel from './components/DetailPanel.vue';
import TaskGanttView from './components/TaskGanttView.vue';
import KanbanView from './components/KanbanView.vue';
import StatusBar from './components/StatusBar.vue';

const route = useRoute();
const store = useProjectFlowStore();
const tabsStore = useTabsStore();
const activeTab = ref('flowchart');

onMounted(async () => {
  const projectId = route.params.id as string;
  if (projectId) {
    console.log('Project Detail mounted for project:', projectId);
    await store.fetchProject(projectId);
    
    // Update tab title and tooltip
    if (store.projectInfo) {
      const title = `项目详情[${store.projectInfo.code}]`;
      const managerPart = store.projectInfo.manager ? `（${store.projectInfo.manager}）` : '';
      const tooltip = `【${store.projectInfo.code}】${store.projectInfo.name}${managerPart}`;
      tabsStore.updateViewTitle(route.fullPath, title, tooltip);
    }

    // Initialize real-time collaboration
    store.initSocket();
  }
});

onUnmounted(() => {
    if (store.socket) {
        store.socket.stop();
    }
});

// Clear selection when switching tabs to avoid context confusion (optional)
watch(activeTab, () => {
  store.clearSelection();
});
</script>

<style scoped>
.project-detail-container {
  display: flex;
  flex-direction: row;
  height: 100%; /* Use 100% to fill available space in flex container */
  background: #fff;
  overflow: hidden;
}

.main-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.project-tabs {
  height: 100%;
  display: flex;
  flex-direction: column;
}

:deep(.ant-tabs-content-holder) {
  flex: 1;
  overflow: hidden;
}

:deep(.ant-tabs-content) {
  height: 100%;
}

:deep(.ant-tabs-tabpane) {
  height: 100%;
}

:deep(.ant-tabs-nav) {
  width: 100%;
}

:deep(.ant-tabs-nav-wrap) {
  flex: 1;
  display: flex;
  justify-content: flex-end;
}

.tab-view-container {
  display: flex;
  flex-direction: column;
  height: 100%;
  width: 100%;
}

.toolbar-area {
  padding: 8px;
  border-bottom: 1px solid #f0f0f0;
  background: #fff;
  flex-shrink: 0;
}

.canvas-area {
  flex: 1;
  position: relative;
  overflow: hidden;
}

.detail-area {
  width: 320px;
  border-left: 1px solid #f0f0f0;
  background: #fff;
  display: flex;
  flex-direction: column;
  z-index: 20;
  flex-shrink: 0;
}
</style>
