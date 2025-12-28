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

        <!-- Preview View -->
        <PageDesigner 
          v-if="viewMode === 'preview' && currentPage" 
          :pageData="currentPage"
          initialMode="preview"
          @back="viewMode = 'list'"
        />
      </a-layout-content>
    </a-layout>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { message } from 'ant-design-vue';
import PageCategoryTree from './components/PageCategoryTree.vue';
import PageList from './components/PageList.vue';
import PageDesigner from './components/PageDesigner.vue';
import { type PageDefinition, getPageById } from '@/api/page';

const viewMode = ref<'list' | 'design' | 'preview'>('list');
const currentCategoryId = ref<number | undefined>(undefined);
const currentCategoryName = ref<string>('');
const currentPage = ref<PageDefinition | null>(null);

const onCategorySelect = (id: number, node: any) => {
  currentCategoryId.value = id;
  currentCategoryName.value = node ? node.name : '';
};

const handleDesign = async (page: PageDefinition) => {
  try {
    const res = await getPageById(page.id);
    if (res) {
      currentPage.value = res;
      viewMode.value = 'design';
    }
  } catch (e) {
    message.error('加载页面详情失败');
  }
};

const handlePreview = async (page: PageDefinition) => {
  try {
    const res = await getPageById(page.id);
    if (res) {
      currentPage.value = res;
      viewMode.value = 'preview';
    }
  } catch (e) {
    message.error('加载页面详情失败');
  }
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
