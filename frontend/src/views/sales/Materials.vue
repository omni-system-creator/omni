<template>
  <div class="page-container">
    <a-tabs v-model:activeKey="activeTab">
      <a-tab-pane key="1" tab="话术库">
        <SalesScriptLibrary />
      </a-tab-pane>
      <a-tab-pane key="2" tab="产品资料">
        <ProductDocuments />
      </a-tab-pane>
      <a-tab-pane key="3" tab="流程规则">
        <ProcessRules />
      </a-tab-pane>
    </a-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import SalesScriptLibrary from './components/SalesScriptLibrary.vue';
import ProductDocuments from './components/ProductDocuments.vue';
import ProcessRules from './components/ProcessRules.vue';

const activeTab = ref('1');
</script>

<style scoped>
.page-container {
  padding: 16px;
  flex: 1;
  background: #fff;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.page-container :deep(.ant-tabs) {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.page-container :deep(.ant-tabs-content-holder) {
  flex: 1;
  overflow: auto;
}

.page-container :deep(.ant-tabs-content) {
  height: 100%;
}

.page-container :deep(.ant-tabs-tabpane) {
  height: 100%;
}
</style>