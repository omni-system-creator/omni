<template>
  <a-layout style="min-height: 100vh">
    <a-layout-sider v-model:collapsed="collapsed" collapsible :trigger="null" :width="240" class="sider-fixed">
      <div class="logo-container">
        <img src="@/assets/logo.svg" alt="Logo" class="logo-img" />
        <h1 v-if="!collapsed" class="logo-text">金兰®综合信息管理系统</h1>
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
      <div class="sider-trigger" @click="collapsed = !collapsed">
        <div class="trigger-line"></div>
        <div class="trigger-circle">
          <DynamicIcon :icon="collapsed ? 'ant-design:right-outlined' : 'ant-design:left-outlined'" style="color: #999; font-size: 12px;" />
        </div>
      </div>
    </a-layout-sider>
    
    <a-layout :style="{ marginLeft: collapsed ? '80px' : '240px', transition: 'all 0.2s', height: '100vh', overflow: 'hidden', display: 'flex', flexDirection: 'column' }">
      <a-layout-header class="header">
        <div class="header-left">
          <div v-if="isHome" class="welcome-text">
            欢迎使用 金兰®综合信息管理系统 - 全面的一站式管理组织、合同、项目、财务、CRM、进销存、流程、数据分析、系统管理等。
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
          <a-space size="middle">
            <HelpButton />
            
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
            <router-view :key="route.fullPath" />
          </div>
          <router-view v-else v-slot="{ Component }">
            <transition :name="transitionName" mode="out-in">
              <keep-alive :include="tabsStore.cachedViews">
                <component :is="Component" :key="route.fullPath" />
              </keep-alive>
            </transition>
          </router-view>
        </div>
      </a-layout-content>
    </a-layout>
  </a-layout>
</template>

<script lang="ts" setup>
import { ref, computed, watch } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { message } from 'ant-design-vue';
import TabsView from '../components/TabsView.vue';
import { useTabsStore } from '../stores/tabs';
import { useUserStore } from '@/stores/user';
import { usePermissionStore } from '@/stores/permission';
import DynamicIcon from '@/components/DynamicIcon.vue';
import HelpButton from './components/HelpButton.vue';
import NotificationBell from './components/NotificationBell.vue';
import StatusDropdown from './components/StatusDropdown.vue';
import UserDropdown from './components/UserDropdown.vue';

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

const userStore = useUserStore(); // 提前声明 userStore

// 辅助函数：根据用户 ID 获取唯一的 key
const getUserSettingKey = (key: string) => {
  const userId = userStore.username || 'guest'; // 最好用 userId，但 username 也行
  return `${userId}_${key}`;
};

const collapsed = ref<boolean>(getSettings().menuCollapsed === true);

watch(collapsed, (val) => {
  saveSettings('menuCollapsed', val);
});

const router = useRouter();
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

// Define menu data type
interface MenuItem {
  key: string;
  title: string;
  icon?: string;
  path?: string;
  component?: string;
  children?: MenuItem[];
}

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
          children: undefined // 扁平化，不再包含 children
        };
      }

      return {
        key: route.name as string,
        title: route.meta?.title as string || route.name as string,
        icon: route.meta?.icon,
        path: route.path,
        component: route.component,
        children: route.children ? transformRouteToMenu(route.children) : undefined
      };
    });
  };
  return transformRouteToMenu(permissionStore.routes);
});

const handleMenuClick = (item: MenuItem) => {
  if (item.path) {
    router.push(item.path);
  }
};

const selectedKeys = computed({
  get: () => {
    // 优先匹配当前路由
    if (route.name) return [route.name as string];
    // 如果没有 name，尝试用 path 匹配
    const currentPath = route.path;
    // 遍历菜单寻找匹配项
    const findKeyByPath = (items: MenuItem[]): string | undefined => {
      for (const item of items) {
        if (item.path === currentPath) return item.key;
        if (item.children) {
          const key = findKeyByPath(item.children);
          if (key) return key;
        }
      }
    };
    const key = findKeyByPath(menuData.value);
    return key ? [key] : [];
  },
  set: (_val) => {
    // 这里不需要做什么，因为点击菜单会触发路由跳转，进而触发 get
  }
});

// Initialize openKeys from localStorage or default to empty
const getSavedOpenKeys = () => {
  return getSettings()[getUserSettingKey('menuOpenKeys')] || [];
};

const openKeys = ref<string[]>(getSavedOpenKeys());

const onOpenChange = (keys: string[]) => {
  openKeys.value = keys;
  saveSettings(getUserSettingKey('menuOpenKeys'), keys);
};

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


</script>

<style scoped>
.welcome-text {
  font-size: 16px;
}

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
  background: #002140; /* 保持和 logo 一致或稍微变色 */
  position: relative;
  transition: all 0.3s;
}

.sider-trigger:hover .trigger-circle {
  background: #003a70; /* 悬停时使用不透明的亮色背景，防止露出后面的线 */
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

.header {
  background: #fff;
  padding: 0 24px;
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
  background: #f0f2f5;
  flex: 1;
  overflow-y: auto;
  overflow-x: hidden;
  position: relative;
  display: flex;
  flex-direction: column;
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
  color: rgba(255, 255, 255, 0.85) !important; /* 暗色主题下的文字颜色 */
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  margin-bottom: 4px;
  background-color: transparent !important;
  pointer-events: none; /* 禁止鼠标交互 */
  padding-left: 16px !important; /* 保持对齐 */
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
  top: 15px; /* 居中对齐第一个菜单项 */
  left: -4px; /* 稍微伸出 */
  width: 8px;
  height: 8px;
  background: #001529; /* 和菜单背景一致 */
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
