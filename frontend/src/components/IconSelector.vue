<template>
  <div class="icon-selector">
    <a-tabs v-model:activeKey="currentTab" @change="handleTabChange">
      <a-tab-pane key="ant-design" tab="Ant Design" />
      <a-tab-pane key="mdi" tab="Material Design" />
      <a-tab-pane key="fa" tab="Font Awesome" />
      <a-tab-pane key="ri" tab="Remix Icon" />
      <a-tab-pane key="carbon" tab="Carbon" />
    </a-tabs>

    <a-input-search
      v-model:value="searchText"
      placeholder="搜索当前库图标..."
      style="margin: 16px 0"
      @search="onSearch"
      allow-clear
    />
    
    <div class="icon-list" v-if="!loading">
      <div 
        v-for="icon in displayIcons" 
        :key="icon"
        class="icon-item"
        :class="{ active: modelValue === icon }"
        @click="selectIcon(icon)"
      >
        <DynamicIcon :icon="icon" style="font-size: 24px;" />
        <span class="icon-name" :title="icon">{{ icon.split(':')[1] || icon }}</span>
      </div>
    </div>
    <div v-else class="loading-container">
      <a-spin tip="加载图标库中..." />
    </div>
    
    <div class="pagination-wrapper">
      <a-pagination
        v-model:current="currentPage"
        :total="filteredIcons.length"
        :page-size="pageSize"
        size="small"
        show-less-items
        show-quick-jumper
        :show-total="(total: number) => `共 ${total} 个`"
      />
    </div>
  </div>
</template>

<script lang="ts" setup>
import { ref, computed, watch, onMounted } from 'vue';
// import * as AntdIcons from '@ant-design/icons-vue';
import DynamicIcon from './DynamicIcon.vue';

const props = defineProps<{
  modelValue?: string;
}>();

const emit = defineEmits(['update:modelValue', 'select']);

const currentTab = ref('ant-design');
const loading = ref(false);
const allIcons = ref<string[]>([]);
const searchText = ref('');
const currentPage = ref(1);
const pageSize = 36;

// 缓存已加载的图标数据
const iconCache: Record<string, string[]> = {};

// 加载 Ant Design 图标 (本地同步)
// const loadAntdIcons = () => {
//   // ... (removed unused code)
//   loadIconifyCollection('ant-design');
// };

// 动态加载 Iconify JSON
const loadIconifyCollection = async (prefix: string) => {
  if (iconCache[prefix]) {
    allIcons.value = iconCache[prefix];
    return;
  }

  loading.value = true;
  try {
    let iconsJson: any;
    switch (prefix) {
      case 'ant-design':
        iconsJson = await import('@iconify-json/ant-design/icons.json');
        break;
      case 'mdi':
        iconsJson = await import('@iconify-json/mdi/icons.json');
        break;
      case 'fa':
        iconsJson = await import('@iconify-json/fa/icons.json');
        break;
      case 'ri':
        iconsJson = await import('@iconify-json/ri/icons.json');
        break;
      case 'carbon':
        iconsJson = await import('@iconify-json/carbon/icons.json');
        break;
    }

    if (iconsJson) {
      const data = iconsJson.default || iconsJson;
      // 解析 Iconify JSON 结构
      const iconNames = Object.keys(data.icons || {});
      // 加上前缀
      const fullNames = iconNames.map(name => `${prefix}:${name}`);
      
      iconCache[prefix] = fullNames;
      allIcons.value = fullNames;
    }
  } catch (error) {
    console.error(`Failed to load icons for ${prefix}`, error);
    allIcons.value = [];
  } finally {
    loading.value = false;
  }
};

const handleTabChange = () => {
  searchText.value = '';
  currentPage.value = 1;
  loadIconifyCollection(currentTab.value);
};

const filteredIcons = computed(() => {
  if (!searchText.value) return allIcons.value;
  const lower = searchText.value.toLowerCase();
  return allIcons.value.filter(key => key.toLowerCase().includes(lower));
});

const displayIcons = computed(() => {
  const start = (currentPage.value - 1) * pageSize;
  const end = start + pageSize;
  return filteredIcons.value.slice(start, end);
});

const onSearch = () => {
  currentPage.value = 1;
};

watch(searchText, () => {
  currentPage.value = 1;
});

const selectIcon = (icon: string) => {
  emit('update:modelValue', icon);
  emit('select', icon);
};

onMounted(() => {
  loadIconifyCollection('ant-design');
});
</script>

<style scoped>
.icon-selector {
  width: 100%;
}

.loading-container {
  height: 300px;
  display: flex;
  justify-content: center;
  align-items: center;
}

.icon-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(100px, 1fr));
  gap: 12px;
  height: 350px;
  overflow-y: auto;
  padding: 4px;
}

.icon-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 12px 4px;
  cursor: pointer;
  border: 1px solid #f0f0f0;
  border-radius: 4px;
  transition: all 0.3s;
  height: 80px;
}

.icon-item:hover {
  border-color: #1890ff;
  color: #1890ff;
  background-color: #e6f7ff;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.09);
}

.icon-item.active {
  border-color: #1890ff;
  background-color: #1890ff;
  color: #fff;
}

.icon-name {
  margin-top: 8px;
  font-size: 12px;
  text-align: center;
  width: 100%;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  color: inherit;
}

.pagination-wrapper {
  margin-top: 16px;
  text-align: right;
}
</style>
