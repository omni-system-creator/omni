<template>
  <a-layout style="min-height: 100vh">
    <SideMenu v-if="!tabsStore.isWebFull" v-model:collapsed="collapsed" :menu-data="menuData" />
    
    <a-layout :style="{ marginLeft: tabsStore.isWebFull ? '0' : (collapsed ? '80px' : '240px'), transition: 'all 0.2s', height: '100vh', overflow: 'hidden', display: 'flex', flexDirection: 'column' }">
      <a-layout-header class="header" v-if="!tabsStore.isWebFull">
        <div class="header-left">
          <menu-unfold-outlined
            v-if="collapsed"
            class="trigger"
            @click="() => (collapsed = !collapsed)"
          />
          <menu-fold-outlined v-else class="trigger" @click="() => (collapsed = !collapsed)" />
          <div v-if="isHome" class="welcome-text">
            <a-tooltip :title="welcomeText">
              <span class="welcome-ellipsis">{{ welcomeText }}</span>
            </a-tooltip>
          </div>
          <a-breadcrumb v-else>
            <a-breadcrumb-item>
              <router-link to="/">首页</router-link>
            </a-breadcrumb-item>
            <a-breadcrumb-item v-for="(item, index) in breadcrumbs" :key="index">
              {{ item.meta.title }}
            </a-breadcrumb-item>
          </a-breadcrumb>
        </div>
        <div class="header-right">
          <a-space size="small">
            <a-tooltip title="GitHub 仓库">
              <a-button type="text" shape="circle" @click="openLink('github')">
                <template #icon><DynamicIcon icon="ri:github-fill" /></template>
              </a-button>
            </a-tooltip>
            <a-tooltip title="Gitee 仓库">
              <a-button type="text" shape="circle" @click="openLink('gitee')">
                <template #icon><DynamicIcon icon="ri:gitee-fill" /></template>
              </a-button>
            </a-tooltip>
            <HelpButton />
            <FullscreenButton />
            <OnlineUsersButton />            
            <NotificationBell />            
            <StatusDropdown />
            <UserDropdown />
          </a-space>
        </div>
      </a-layout-header>
      
      <a-layout-content style="display: flex; flex-direction: column; overflow: hidden; flex: 1;">
        <tabs-view />
        
        <div class="site-layout-content">
          <div v-if="isHome">
            <router-view :key="tabsStore.getTabIdentity(route.fullPath)" />
          </div>
          <router-view v-else v-slot="{ Component }">
            <transition :name="transitionName" mode="out-in">
              <keep-alive :include="tabsStore.cachedViews">
                <component :is="Component" :key="tabsStore.getTabIdentity(route.fullPath)" />
              </keep-alive>
            </transition>
          </router-view>
          
          <!-- Special handling for iframe KeepAlive -->
          <iframe-view />
        </div>
      </a-layout-content>
    </a-layout>
  </a-layout>
</template>

<script lang="ts" setup>
import { ref, computed, watch } from 'vue';
import { useRoute } from 'vue-router';
import {
  MenuUnfoldOutlined,
  MenuFoldOutlined,
} from '@ant-design/icons-vue';
import TabsView from '../components/TabsView.vue';
import { useTabsStore } from '../stores/tabs';
import { useSystemStore } from '@/stores/system';
import { usePermissionStore } from '@/stores/permission';
import HelpButton from './components/HelpButton.vue';
import FullscreenButton from './components/FullscreenButton.vue';
import NotificationBell from './components/NotificationBell.vue';
import StatusDropdown from './components/StatusDropdown.vue';
import UserDropdown from './components/UserDropdown.vue';
import OnlineUsersButton from './components/OnlineUsersButton.vue';
import IframeView from './components/IframeView.vue';
import DynamicIcon from '@/components/DynamicIcon.vue';

import SideMenu from './components/SideMenu.vue';
import type { MenuItem } from '@/types/menu';

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

const systemStore = useSystemStore();
systemStore.fetchConfigs();

const collapsed = ref<boolean>(getSettings().menuCollapsed === true);

watch(collapsed, (val) => {
  saveSettings('menuCollapsed', val);
});

const route = useRoute();
const tabsStore = useTabsStore();
const permissionStore = usePermissionStore();

const transitionName = ref('fade');

watch(
  () => route.path,
  () => {
    if (tabsStore.cachedViews.includes(route.name as string)) {
      transitionName.value = '';
    } else {
      transitionName.value = 'fade';
    }
  },
  { flush: 'pre' }
);

// 监听 URL 参数以控制全屏状态
watch(
  () => route.query,
  (query) => {
    // webFull: 隐藏左侧菜单和顶部导航 (1 或 true)
    if (query.webFull === '1' || query.webFull === 'true') {
      tabsStore.isWebFull = true;
    } else {
      // 只要不是明确的 1 或 true，都认为是 false (包括 undefined/null/0/false)
      tabsStore.isWebFull = false;
    }
  },
  { immediate: true }
);

// Define menu data type (Moved to types/menu.ts)

// 使用 Store 中的动态路由数据，并转换为菜单所需的格式
const menuData = computed<MenuItem[]>(() => {
  const transformRouteToMenu = (routes: any[]): MenuItem[] => {
    return routes.map(route => {
      // 检查是否为只有一个子节点且需要提升显示的路由
      // 如果路由是 Layout (path: '/') 且只有一个子节点 (path: '')，则直接展示该子节点
      if (route.path === '/' && route.children && route.children.length === 1 && route.children[0].path === '') {
        const child = route.children[0];
        return {
          key: child.name as string,
          title: child.meta?.title as string || child.name as string,
          icon: child.meta?.icon,
          path: '/', // 使用父级路径或者 child.path 拼合（如果是 / 则直接用 /）
          component: child.component,
          query: child.meta?.query as string,
          children: undefined // 扁平化，不再包含 children
        };
      }

      return {
        key: route.name as string,
        title: route.meta?.title as string || route.name as string,
        icon: route.meta?.icon,
        path: route.path,
        component: route.component,
        query: route.meta?.query as string,
        children: route.children ? transformRouteToMenu(route.children) : undefined
      };
    });
  };
  return transformRouteToMenu(permissionStore.routes);
});

const isHome = computed(() => route.path === '/' || route.name === 'HomeView');

const breadcrumbs = computed(() => {
  const matched = route.matched.filter(item => item.meta && item.meta.title && item.name !== 'HomeView');
  
  // Try to find parent menu item
  const currentPath = route.path;
  let parentMenuTitle = '';
  
  for (const menu of menuData.value) {
    if (menu.children) {
      for (const child of menu.children) {
        if (child.path === currentPath) {
          parentMenuTitle = menu.title;
          break;
        }
      }
    }
    if (parentMenuTitle) break;
  }
  
  if (parentMenuTitle) {
    // Check if parent menu title already exists in matched routes to avoid duplication
    const exists = matched.some(item => item.meta?.title === parentMenuTitle);
    if (!exists) {
      return [{ meta: { title: parentMenuTitle } }, ...matched];
    }
  }
  
  return matched;
});

const welcomeText = '集中管理各种信息数据的系统，类似包括但不只是OA、ERP、WMS、CRM等，各种能做的都可以做。';

const openLink = (site: 'github' | 'gitee') => {
  const urls: Record<string, string> = {
    github: 'https://github.com/omni-system-creator/omni',
    gitee: 'https://gitee.com/kinglan_gitee/omni'
  };
  const url = urls[site];
  if (url) {
    window.open(url, '_blank');
  }
};


</script>

<style scoped>
.header-left {
  display: flex;
  align-items: center;
}

.trigger {
  font-size: 18px;
  line-height: 64px;
  padding: 0 24px;
  cursor: pointer;
  transition: color 0.3s;
}

.trigger:hover {
  color: #1890ff;
}

.welcome-text {
  font-size: 16px;
  flex: 1;
  min-width: 0;
  margin-left: 12px;
  display: flex;
  align-items: center;
}

.welcome-ellipsis {
  display: inline-block;
  max-width: 100%;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.header {
  background: #fff;
  padding: 0 24px;
  padding-left: 0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 1px 4px rgba(0, 21, 41, 0.08);
  z-index: 1;
  flex-shrink: 0; /* Prevent header from shrinking */
}

.header-right {
  display: flex;
  align-items: center;
}



.site-layout-content {
  position: relative;
  background: #f0f2f5;
  flex: 1;
  overflow-y: auto;
  overflow-x: hidden;
  display: flex;
  flex-direction: column;
}

/* Hide scrollbar when iframe is active to prevent double scrolling */
.site-layout-content:has(.active-iframe) {
  overflow: hidden;
}

/* Transition effects */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
