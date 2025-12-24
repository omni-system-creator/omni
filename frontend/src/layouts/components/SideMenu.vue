<template>
  <a-layout-sider 
    :collapsed="collapsed" 
    collapsible 
    :trigger="null" 
    :width="240" 
    class="sider-fixed"
    @update:collapsed="emit('update:collapsed', $event)"
  >
    <div class="logo-container">
      <img :src="systemStore.systemLogo" :alt="systemStore.systemName" class="logo-img" />
      <h1 v-if="!collapsed" class="logo-text">{{ systemStore.systemName }}</h1>
    </div>
    <div class="menu-container">
      <a-menu
        v-model:selectedKeys="selectedKeys"
        theme="dark"
        mode="inline"
        :open-keys="openKeys"
        @openChange="onOpenChange"
      >
        <template v-for="item in menuData" :key="item.key">
          <!-- If item has children, render SubMenu -->
          <a-sub-menu v-if="item.children && item.children.length > 0" :key="item.key + '_sub'" popupClassName="sider-popup-menu">
            <template #title>
              <span>
                <DynamicIcon :icon="item.icon" v-if="item.icon" />
                <span>{{ item.title }}</span>
              </span>
            </template>
            <!-- 仅在弹出菜单中显示的标题 -->
            <a-menu-item :key="item.key + '_title'" disabled class="popup-menu-title">
              {{ item.title }}
            </a-menu-item>
            <a-menu-item v-for="child in item.children" :key="child.key" @click="handleMenuClick(child)">
              {{ child.title }}
            </a-menu-item>
          </a-sub-menu>

          <!-- If item has no children, render MenuItem -->
          <a-menu-item v-else :key="item.key" @click="handleMenuClick(item)">
            <DynamicIcon :icon="item.icon" v-if="item.icon" />
            <span>{{ item.title }}</span>
          </a-menu-item>
        </template>
      </a-menu>
    </div>
    <!-- 自定义折叠触发器 -->
    <div class="sider-trigger" @click="emit('update:collapsed', !collapsed)">
      <div class="trigger-line"></div>
      <div class="trigger-circle">
        <DynamicIcon :icon="collapsed ? 'ant-design:right-outlined' : 'ant-design:left-outlined'" style="color: #999; font-size: 12px;" />
      </div>
    </div>
  </a-layout-sider>
</template>

<script lang="ts" setup>
import { ref, computed, watch } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { useSystemStore } from '@/stores/system';
import { useUserStore } from '@/stores/user';
import DynamicIcon from '@/components/DynamicIcon.vue';
import type { MenuItem } from '@/types/menu';

const props = defineProps<{
  collapsed: boolean;
  menuData: MenuItem[];
}>();

const emit = defineEmits<{
  (e: 'update:collapsed', value: boolean): void;
}>();

const router = useRouter();
const route = useRoute();
const systemStore = useSystemStore();
const userStore = useUserStore();

// Local Storage Helpers
const getSettings = () => {
  try {
    return JSON.parse(localStorage.getItem('oms.settings') || '{}');
  } catch {
    return {};
  }
};

const saveSettings = (key: string, value: any) => {
  const settings = getSettings();
  settings[key] = value;
  localStorage.setItem('oms.settings', JSON.stringify(settings));
};

const getUserSettingKey = (key: string) => {
  const userId = userStore.username || 'guest';
  return `${userId}_${key}`;
};

// Menu Logic
const handleMenuClick = (item: MenuItem) => {
  if (item.path) {
    if (item.query) {
      const queryParams = new URLSearchParams(item.query);
      const query: Record<string, string> = {};
      queryParams.forEach((value, key) => {
        query[key] = value;
      });
      router.push({ path: item.path, query });
    } else {
      router.push(item.path);
    }
  }
};

const selectedKeys = computed({
  get: () => {
    if (route.name) return [route.name as string];
    const currentPath = route.path;
    const findKeyByPath = (items: readonly MenuItem[]): string | undefined => {
      for (const item of items) {
        if (item.path === currentPath) return item.key;
        if (item.children) {
          const key = findKeyByPath(item.children);
          if (key) return key;
        }
      }
    };
    const key = findKeyByPath(props.menuData);
    return key ? [key] : [];
  },
  set: (_val) => {}
});

const getSavedOpenKeys = () => {
  return getSettings()[getUserSettingKey('menuOpenKeys')] || [];
};

const openKeys = ref<string[]>(getSavedOpenKeys());

const onOpenChange = (keys: string[]) => {
  openKeys.value = keys;
  saveSettings(getUserSettingKey('menuOpenKeys'), keys);
};

// Auto expand parent menus when selectedKey changes
const findPathToKey = (targetKey: string, items: readonly MenuItem[], path: string[] = []): string[] | null => {
  for (const item of items) {
    if (item.key === targetKey) {
      return path;
    }
    if (item.children && item.children.length > 0) {
      const subMenuKey = item.key + '_sub';
      const foundPath = findPathToKey(targetKey, item.children, [...path, subMenuKey]);
      if (foundPath) {
        return foundPath;
      }
    }
  }
  return null;
};

watch(
  [() => selectedKeys.value, () => props.menuData],
  () => {
    const keys = selectedKeys.value;
    if (keys.length === 0) return;
    const targetKey = keys[0];
    if (!targetKey) return;
    const path = findPathToKey(targetKey, props.menuData);
    
    if (path && path.length > 0) {
      const newKeys = [...new Set([...openKeys.value, ...path])];
      if (newKeys.length !== openKeys.value.length) {
        openKeys.value = newKeys;
        saveSettings(getUserSettingKey('menuOpenKeys'), newKeys);
      }
    }
  },
  { immediate: true }
);
</script>

<style scoped>
.logo-container {
  height: 64px;
  padding: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #002140;
  overflow: hidden;
  transition: all 0.3s;
}

.logo-img {
  height: 24px;
  width: 24px;
}

.logo-text {
  color: #fff;
  font-size: 18px;
  margin: 0 0 0 10px;
  font-weight: 600;
  white-space: nowrap;
  opacity: 1;
  transition: opacity 0.3s;
}

.sider-fixed {
  position: fixed;
  height: 100vh;
  left: 0;
  top: 0;
  overflow: hidden;
  z-index: 100;
  box-shadow: 2px 0 8px 0 rgba(29, 35, 41, 0.05);
}

.menu-container {
  height: calc(100vh - 64px - 48px);
  overflow-y: auto;
  overflow-x: hidden;
}

.sider-trigger {
  height: 48px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  background: #002140;
  position: relative;
  transition: all 0.3s;
}

.sider-trigger:hover .trigger-circle {
  background: #003a70;
  border-color: #003a70;
}

.sider-trigger:hover .trigger-circle :deep(.anticon) {
  color: #fff !important;
}

.trigger-line {
  position: absolute;
  top: 50%;
  left: 10px;
  right: 10px;
  height: 1px;
  background: rgba(255, 255, 255, 0.1);
  transform: translateY(-50%);
}

.trigger-circle {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  background: #002140;
  border: 1px solid rgba(255, 255, 255, 0.1);
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  z-index: 1;
  transition: all 0.3s;
}

/* Scrollbar styling for menu */
.menu-container::-webkit-scrollbar {
  width: 6px;
}
.menu-container::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.2);
  border-radius: 3px;
}
.menu-container::-webkit-scrollbar-track {
  background: transparent;
}

/* 正常内嵌模式下隐藏标题 */
:deep(.ant-menu-inline .popup-menu-title) {
  display: none !important;
}

/* 弹出模式下显示标题并设置样式 */
:global(.ant-menu-submenu-popup .popup-menu-title) {
  display: block !important;
  opacity: 1 !important;
  cursor: default !important;
  font-weight: 600;
  font-size: 14px;
  color: rgba(255, 255, 255, 0.85) !important;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  margin-bottom: 4px;
  background-color: transparent !important;
  pointer-events: none;
  padding-left: 16px !important;
}

/* 弹出菜单左侧小尖头 */
:global(.sider-popup-menu) {
  overflow: visible !important;
}

:global(.sider-popup-menu .ant-menu) {
  overflow: visible !important;
  position: relative !important;
}

:global(.sider-popup-menu .ant-menu::before) {
  content: '';
  position: absolute;
  top: 15px;
  left: -4px;
  width: 8px;
  height: 8px;
  background: #001529;
  transform: rotate(45deg);
  z-index: 100;
  box-shadow: -1px 1px 2px rgba(0, 0, 0, 0.2);
}

/* Custom arrow direction for SubMenu */
:deep(.ant-menu-submenu-title .ant-menu-submenu-arrow) {
  transform: translateX(4px) translateY(-50%) rotate(-90deg) !important;
  transform-origin: center center;
}

:deep(.ant-menu-submenu-open > .ant-menu-submenu-title > .ant-menu-submenu-arrow) {
  transform: translateY(-50%) rotate(-180deg) !important;
  transform-origin: center center;
}
</style>
