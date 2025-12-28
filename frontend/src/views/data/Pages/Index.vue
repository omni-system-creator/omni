<template>
  <div class="pages-container">
    <a-layout style="height: 100%">
      <!-- Left Sidebar: Category Tree -->
      <a-layout-sider 
        width="260" 
        theme="light" 
        v-if="viewMode === 'list'"
        class="page-sider"
      >
        <PageCategoryTree @select="onCategorySelect" />
      </a-layout-sider>
      
      <!-- Main Content -->
      <a-layout-content class="page-content">
        <!-- List View -->
        <PageList 
          v-if="viewMode === 'list'" 
          :categoryId="currentCategoryId"
          :categoryName="currentCategoryName"
          @design="handleDesign"
          @preview="handlePreview"
        />
        
        <!-- Designer View -->
        <PageDesigner 
          v-if="viewMode === 'design' && currentPage" 
          :pageData="currentPage"
          @back="viewMode = 'list'"
          @save="onPageSaved"
        />
      </a-layout-content>
    </a-layout>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import PageCategoryTree from './components/PageCategoryTree.vue';
import PageList from './components/PageList.vue';
import PageDesigner from './components/PageDesigner.vue';
import type { PageDefinition } from '@/api/page';

const viewMode = ref<'list' | 'design'>('list');
const currentCategoryId = ref<number | undefined>(undefined);
const currentCategoryName = ref<string>('');
const currentPage = ref<PageDefinition | null>(null);

const onCategorySelect = (id: number, node: any) => {
  currentCategoryId.value = id;
  currentCategoryName.value = node ? node.name : '';
};

const handleDesign = (page: PageDefinition) => {
  currentPage.value = page;
  viewMode.value = 'design';
};

const handlePreview = (page: PageDefinition) => {
  // Simple alert for now, or open a modal
  alert('预览功能待实现: ' + page.name);
};

const onPageSaved = () => {
  // Refresh list if needed, or just stay
};

</script>

<style scoped>
.pages-container {
  height: 100%;
  width: 100%;
  overflow: hidden;
}

.page-sider {
  border-right: 1px solid #f0f0f0;
}

.page-content {
  height: 100%;
  overflow: hidden;
  background: #fff;
}
</style>
