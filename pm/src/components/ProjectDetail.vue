<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useProjectStore } from '../stores/projectStore'
import Controls from './Controls.vue'
import LeaferCanvas from './LeaferCanvas.vue'
import DetailPanel from './DetailPanel.vue'
import StatusBar from './StatusBar.vue'
import TaskGanttView from './TaskGanttView.vue'
import KanbanView from './KanbanView.vue'
import DocumentView from './DocumentView.vue'
import MemberView from './MemberView.vue'
import { NTabs, NTabPane, NEmpty } from 'naive-ui'

const activeTab = ref('swimlane')
const store = useProjectStore()

onMounted(() => {
  store.fetchSelectableUsers()
})
</script>

<template>
  <div class="project-detail-container">
    <Controls />
    <div class="tabs-container">
      <n-tabs v-model:value="activeTab" type="line" animated display-directive="show">
        <n-tab-pane name="swimlane" tab="泳道图">
          <div class="tab-content main-content">
             <div class="chart-area">
               <LeaferCanvas />
             </div>
             <DetailPanel />
          </div>
        </n-tab-pane>
        <n-tab-pane name="list_gantt" tab="任务列表&甘特图">
          <div class="tab-content">
             <TaskGanttView />
          </div>
        </n-tab-pane>
        <n-tab-pane name="kanban" tab="看板">
          <div class="tab-content main-content">
             <KanbanView />
          </div>
        </n-tab-pane>
        <n-tab-pane name="docs" tab="文档">
          <div class="tab-content">
             <DocumentView />
          </div>
        </n-tab-pane>
        <n-tab-pane name="members" tab="人员">
          <div class="tab-content">
             <MemberView />
          </div>
        </n-tab-pane>
        <n-tab-pane name="discussion" tab="讨论">
          <div class="tab-content">
             <n-empty description="讨论区开发中..." />
          </div>
        </n-tab-pane>
      </n-tabs>
    </div>
    <StatusBar />
  </div>
</template>

<style scoped>
.project-detail-container {
  display: flex;
  flex-direction: column;
  width: 100vw;
  height: 100vh;
  overflow: hidden;
}

.tabs-container {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

:deep(.n-tabs) {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

:deep(.n-tabs-pane-wrapper) {
  flex: 1;
  overflow: hidden;
}

:deep(.n-tabs-content) {
  flex: 1;
  height: 100%;
}

:deep(.n-tabs-tab-pad) {
  width: 0 !important;
}

:deep(.n-tabs-tab) {
  padding-left: 15px;
  padding-right: 15px;
}

:deep(.n-tab-pane) {
  height: 100%;
  padding: 0 !important;
}

/* This matches App.vue .main-content style */
.main-content {
  display: flex;
  flex-direction: row;
  height: 100%;
  width: 100%;
  overflow: hidden;
}

.chart-area {
  flex: 1;
  overflow: hidden;
  position: relative;
}

.tab-content {
    height: 100%;
    width: 100%;
    display: flex;
    justify-content: center;
    align-items: center;
}

/* Make sure the swimlane tab content fills the space */
.tab-content.main-content {
    justify-content: flex-start;
    align-items: stretch;
}
</style>
