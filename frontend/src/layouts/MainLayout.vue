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
            <a-sub-menu v-if="item.children && item.children.length > 0" :key="item.key" popupClassName="sider-popup-menu">
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
            <a-tooltip title="使用文档">
              <a-button type="text" shape="circle">
                <template #icon><DynamicIcon icon="ant-design:question-circle-outlined" /></template>
              </a-button>
            </a-tooltip>
            
            <a-tooltip title="消息通知">
              <a-badge count="5" dot>
                <a-button type="text" shape="circle">
                  <template #icon><DynamicIcon icon="ant-design:bell-outlined" /></template>
                </a-button>
              </a-badge>
            </a-tooltip>
            
            <a-dropdown>
              <span class="action-item" style="display: flex; align-items: center; cursor: pointer; padding: 0 8px;">
                <a-badge :color="currentStatusColor" :text="statusOptions.find(s => s.value === userStatus)?.label" />
              </span>
              <template #overlay>
                <a-menu>
                  <a-menu-item v-for="option in statusOptions" :key="option.value" @click="handleStatusChange(option.value)">
                    <a-badge :status="option.color" :text="option.label" />
                    <DynamicIcon v-if="userStatus === option.value" icon="ant-design:check-outlined" style="margin-left: 8px; font-size: 12px;" />
                  </a-menu-item>
                </a-menu>
              </template>
            </a-dropdown>

            <a-dropdown>
              <span class="user-dropdown-link">
                <a-avatar style="background-color: #1890ff" icon="user" />
                <span class="username">Admin</span>
              </span>
              <template #overlay>
                <a-menu>
                  <a-menu-item key="password" @click="showChangePassword">
                    <DynamicIcon icon="ant-design:lock-outlined" /> 修改密码
                  </a-menu-item>
                  <a-menu-item key="about" @click="showAbout">
                    <DynamicIcon icon="ant-design:info-circle-outlined" />
                    <span>关于系统</span>
                  </a-menu-item>
                  <a-menu-divider />
                  <a-menu-item key="logout">
                    <DynamicIcon icon="ant-design:logout-outlined" />
                    <span>退出登录</span>
                  </a-menu-item>
                </a-menu>
              </template>
            </a-dropdown>
          </a-space>
        </div>
      </a-layout-header>
      
      <a-layout-content style="display: flex; flex-direction: column; overflow: hidden; flex: 1;">
        <tabs-view />
        
        <div class="site-layout-content">
          <router-view v-slot="{ Component }">
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

  <a-modal
    v-model:open="aboutVisible"
    title="关于系统"
    :footer="null"
  >
    <div style="text-align: center; padding: 20px 0;">
      <img src="@/assets/logo.svg" alt="Logo" style="width: 64px; height: 64px; margin-bottom: 16px;" />
      <h3>金兰®综合信息管理系统</h3>
      <p style="color: #999; margin-top: 24px;">©2025 Created by jinlan.info</p>
      <p style="color: #999;">Version 1.0.0</p>
    </div>
  </a-modal>
  <a-modal
    v-model:open="passwordVisible"
    title="修改密码"
    @ok="handlePasswordOk"
  >
    <a-form :model="passwordForm" layout="vertical">
      <a-form-item label="旧密码" required>
        <a-input-password v-model:value="passwordForm.oldPassword" placeholder="请输入旧密码" />
      </a-form-item>
      <a-form-item label="新密码" required>
        <a-input-password v-model:value="passwordForm.newPassword" placeholder="请输入新密码" />
      </a-form-item>
      <a-form-item label="确认新密码" required>
        <a-input-password v-model:value="passwordForm.confirmPassword" placeholder="请再次输入新密码" />
      </a-form-item>
    </a-form>
  </a-modal>
</template>

<script lang="ts" setup>
import { ref, computed, watch, reactive } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { message } from 'ant-design-vue';
import TabsView from '../components/TabsView.vue';
import { useTabsStore } from '../stores/tabs';
import menuDataJson from '@/assets/menu.json';
import DynamicIcon from '@/components/DynamicIcon.vue';

const collapsed = ref<boolean>(localStorage.getItem('oms_menu_collapsed') === 'true');

watch(collapsed, (val) => {
  localStorage.setItem('oms_menu_collapsed', String(val));
});

const router = useRouter();
const route = useRoute();
const tabsStore = useTabsStore();

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

const menuData = ref<MenuItem[]>(menuDataJson);

const handleMenuClick = (item: MenuItem) => {
  if (item.path) {
    router.push(item.path);
  }
};


const aboutVisible = ref(false);

const showAbout = () => {
  aboutVisible.value = true;
};

// Handle menu selection based on current route
const selectedKeys = computed(() => [route.name as string]);

// Initialize openKeys from localStorage or default to empty
const getSavedOpenKeys = () => {
  const saved = localStorage.getItem('oms_menu_open_keys');
  if (saved) {
    try {
      return JSON.parse(saved);
    } catch (e) {
      console.error('Failed to parse open keys from localStorage', e);
    }
  }
  return [];
};

const openKeys = ref<string[]>(getSavedOpenKeys());

const onOpenChange = (keys: string[]) => {
  openKeys.value = keys;
  localStorage.setItem('oms_menu_open_keys', JSON.stringify(keys));
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
    return [{ meta: { title: parentMenuTitle } }, ...matched];
  }
  
  return matched;
});

// Status Logic
const userStatus = ref('online');
const statusOptions = [
  { label: '在岗', value: 'online', color: 'success' },
  { label: '出差中', value: 'business', color: 'warning' },
  { label: '临时外出', value: 'out', color: 'processing' },
  { label: '休假中', value: 'leave', color: 'error' },
];

const handleStatusChange = (status: string) => {
  userStatus.value = status;
  message.success(`状态已切换为：${statusOptions.find(s => s.value === status)?.label}`);
};

const currentStatusColor = computed(() => {
  const option = statusOptions.find(s => s.value === userStatus.value);
  switch (option?.color) {
    case 'success': return '#52c41a';
    case 'warning': return '#faad14';
    case 'processing': return '#1890ff';
    case 'error': return '#ff4d4f';
    default: return '#52c41a';
  }
});

// Password Logic
const passwordVisible = ref(false);
const passwordForm = reactive({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
});

const showChangePassword = () => {
  passwordVisible.value = true;
};

const handlePasswordOk = () => {
  if (!passwordForm.oldPassword || !passwordForm.newPassword || !passwordForm.confirmPassword) {
    message.warning('请填写完整信息');
    return;
  }
  if (passwordForm.newPassword !== passwordForm.confirmPassword) {
    message.error('两次输入的密码不一致');
    return;
  }
  // Mock API call
  setTimeout(() => {
    message.success('密码修改成功');
    passwordVisible.value = false;
    passwordForm.oldPassword = '';
    passwordForm.newPassword = '';
    passwordForm.confirmPassword = '';
  }, 1000);
};
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

.user-dropdown-link {
  cursor: pointer;
  display: flex;
  align-items: center;
  padding: 0 12px;
  transition: all 0.3s;
}

.user-dropdown-link:hover {
  background: rgba(0, 0, 0, 0.025);
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
