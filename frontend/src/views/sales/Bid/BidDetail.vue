<template>
  <div class="bid-detail-wrapper">
    <ProjectDetail :project="projectInfo" @refresh="handleRefresh" />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import { message } from 'ant-design-vue';
import ProjectDetail from './components/ProjectDetail.vue';
import { useTabsStore } from '@/stores/tabs';
import { getBidProject, type BidProjectDto } from '@/api/sales';

const route = useRoute();
const tabsStore = useTabsStore();

const projectInfo = ref<BidProjectDto | null>(null);

const fetchProject = async (id: string) => {
  try {
    const res = await getBidProject(id);
    projectInfo.value = res;
    
    // Update tab title
    const title = `招投标详情[${res.code}]`;
    tabsStore.updateViewTitle(route.fullPath, title);
  } catch (error) {
    console.error(error);
    message.error('获取项目详情失败');
  }
};

const handleRefresh = () => {
  const id = route.params.id as string;
  if (id) {
    fetchProject(id);
  }
};

onMounted(() => {
  const id = route.params.id as string;
  if (id) {
    fetchProject(id);
  }
});
</script>

<style scoped>
.bid-detail-wrapper {
  flex: 1;
  background-color: #f0f2f5;
  overflow: hidden;
}
</style>
