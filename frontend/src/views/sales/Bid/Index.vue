<template>
  <div class="bid-management-container">
    <div class="tabs-wrapper">
      <a-tabs v-model:activeKey="mainTab" class="bid-tabs">
        <a-tab-pane key="project" tab="招标项目管理">
          <ProjectList />
        </a-tab-pane>
        <a-tab-pane key="law" tab="法律法规库">
          <LawLibrary />
        </a-tab-pane>
        <a-tab-pane key="blacklist" tab="黑名单管理">
          <Blacklist />
        </a-tab-pane>
      </a-tabs>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import ProjectList from './components/ProjectList.vue';
import LawLibrary from './components/LawLibrary.vue';
import Blacklist from './components/Blacklist.vue';

const mainTab = ref('project');
</script>

<style scoped>
.bid-management-container {
  flex: 1;
  display: flex;
  flex-direction: column;
  background-color: #f0f2f5;
  overflow: hidden;
}

.tabs-wrapper {
  flex: 1;
  background-color: #fff;
  padding: 0;
  border-radius: 4px;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.bid-tabs {
  height: 100%;
  display: flex;
  flex-direction: column;
}

:deep(.ant-tabs-content) {
  flex: 1;
  height: 0; /* Important for flex child to scroll */
}

:deep(.ant-tabs-tabpane) {
  height: 100%;
}

:deep(.ant-tabs-tab) {
  padding: 12px 24px !important;
  margin: 0 !important;
}

.project-detail-wrapper {
  height: 100%;
  background-color: #fff;
  border-radius: 4px;
}
</style>
