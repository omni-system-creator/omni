<template>
  <div class="tabs-view-container" :class="{ 'fullscreen-mode': tabsStore.isWebFull }">
    <div v-if="tabsStore.isWebFull" class="fullscreen-trigger"></div>
    <div class="tabs-wrapper">
      <a-tabs
        v-model:activeKey="activeKey"
        type="editable-card"
        hide-add
        @edit="onEdit"
        @change="onChange"
        class="tabs-view"
      >
        <template #renderTabBar>
          <div class="tabs-nav-wrap">
            <div 
              v-show="showLeftArrow" 
              class="nav-arrow left-arrow" 
              @mouseenter="startScroll('left')"
              @mouseleave="stopScroll"
            >
              <DynamicIcon icon="ant-design:left-outlined" />
            </div>
            
            <div 
              class="tabs-scroll-wrapper" 
              ref="scrollContainer"
              @wheel.prevent="onTabScroll"
              @scroll="checkScrollState"
            >
              <draggable
                :list="visitedViews"
                item-key="fullPath"
                class="ant-tabs-nav-list"
                :component-data="{ style: 'display: flex; height: 100%;' }"
                :move="checkMove"
                @start="onDragStart"
                @end="onDragEnd"
              >
                <template #item="{ element, index }">
                  <a-dropdown :trigger="['contextmenu']">
                    <a-tooltip :title="element.tooltip" placement="top" :mouseEnterDelay="0.5" :destroyTooltipOnHide="true">
                      <div
                        class="ant-tabs-tab"
                        :class="{ 'ant-tabs-tab-active': activeKey === element.fullPath }"
                        @click="onChange(element.fullPath)"
                      >
                        <div class="ant-tabs-tab-btn">
                          {{ element.title }}
                          <span
                            v-if="!isAffix(element)"
                            class="ant-tabs-tab-remove"
                            @click.stop="removeTab(element.fullPath)"
                          >
                            <DynamicIcon icon="ant-design:close-outlined" />
                          </span>
                        </div>
                      </div>
                    </a-tooltip>
                    <template #overlay>
                      <a-menu>
                        <a-menu-item
                          key="toggleEditMode"
                          v-if="element.name === 'HomeView'"
                          @click="toggleWorkbenchEditMode"
                        >
                          <DynamicIcon icon="ant-design:edit-outlined" /> {{ workbenchStore.isEditMode ? '退出编辑' : '进入编辑' }}
                        </a-menu-item>
                        <a-menu-divider v-if="element.name === 'HomeView'" />
                        <a-menu-item
                          key="refresh"
                          v-if="activeKey === element.fullPath"
                          @click="refreshSelectedTag(element)"
                        >
                          <DynamicIcon icon="ant-design:reload-outlined" /> 刷新当前
                        </a-menu-item>
                        <a-menu-item key="closeLeft" v-if="hasLeftClosable(index)" @click="closeLeftTags(element)">
                          <DynamicIcon icon="ant-design:vertical-right-outlined" /> 关闭左边
                        </a-menu-item>
                        <a-menu-item key="closeRight" v-if="hasRightClosable(index)" @click="closeRightTags(element)">
                          <DynamicIcon icon="ant-design:vertical-left-outlined" /> 关闭右边
                        </a-menu-item>
                        <a-menu-item key="closeOthers" v-if="hasOtherClosable(element)" @click="closeOthersTags(element)">
                          <DynamicIcon icon="ant-design:close-circle-outlined" /> 关闭其他
                        </a-menu-item>
                        <a-menu-item key="closeAll" v-if="hasAnyClosable()" @click="closeAllTags(element)">
                          <DynamicIcon icon="ant-design:minus-square-outlined" /> 全部关闭
                        </a-menu-item>
                      </a-menu>
                    </template>
                  </a-dropdown>
                </template>
              </draggable>
            </div>

            <div 
              v-show="showRightArrow" 
              class="nav-arrow right-arrow" 
              @mouseenter="startScroll('right')"
              @mouseleave="stopScroll"
            >
              <DynamicIcon icon="ant-design:right-outlined" />
            </div>
          </div>
        </template>
        <a-tab-pane
          v-for="tag in visitedViews"
          :key="tag.fullPath"
          :tab="tag.title"
          :closable="!isAffix(tag)"
        />
      </a-tabs>
      <div class="fullscreen-btn" @click="toggleFullScreen" title="网页全屏">
        <DynamicIcon :icon="tabsStore.isWebFull ? 'ant-design:compress-outlined' : 'ant-design:expand-outlined'" />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref, watch, onMounted, onBeforeUnmount, nextTick } from 'vue';
import { useTabsStore, type TabItem } from '../stores/tabs';
import { useRoute, useRouter } from 'vue-router';
import draggable from 'vuedraggable';
import DynamicIcon from '@/components/DynamicIcon.vue';
import { useWorkbenchStore } from '@/stores/workbench';
import { userConfigApi } from '@/api/userConfig';
import { useUserStore } from '@/stores/user';
import { useLoadingStore } from '@/stores/loading';

const tabsStore = useTabsStore();
const workbenchStore = useWorkbenchStore();
const userStore = useUserStore();
const loadingStore = useLoadingStore();
const route = useRoute();
const router = useRouter();

const TAB_SESSION_CONFIG_KEY = 'ui.tabs.session';
const TAB_SESSION_CONFIG_PREFIX = 'ui.tabs.';

interface StoredTabItem {
  title: string;
  path: string;
  name: string;
  fullPath: string;
  tooltip?: string;
  activeAt: string;
  openedAt?: string;
}

interface StoredTabSession {
  version: number;
  tabs: StoredTabItem[];
}

const isRestoringTabs = ref(false);
// 恢复最后活跃 Tab 的 Loading 走全局通用 loadingStore（App.vue 统一挂遮罩）
const currentOrgId = computed(() => userStore.currentOrg?.id);
const tabsSessionScope = computed(() => {
  if (!userStore.id || !currentOrgId.value) {
    return '';
  }

  // 标签页会话按“用户 + 组织”隔离，模拟登录切换用户时也必须重新恢复。
  return `${userStore.id}:${currentOrgId.value}`;
});
let persistTabsTimer: ReturnType<typeof setTimeout> | null = null;

function toggleFullScreen() {
  tabsStore.toggleWebFull();
  
  // Update URL query param
  const currentQuery = { ...route.query };
  
  if (tabsStore.isWebFull) {
    currentQuery.webFull = '1';
  } else {
    delete currentQuery.webFull;
  }
  
  router.replace({
    path: route.path,
    query: currentQuery
  });
}

function getPathWithWebFull(path: string) {
  // 1. Remove webFull param if it exists
  let cleanPath = path;
  if (path.includes('webFull=')) {
     try {
       // Handle relative paths by adding a dummy base
       const dummyUrl = new URL(path, 'http://dummy.com');
       const params = new URLSearchParams(dummyUrl.search);
       params.delete('webFull');
       const newSearch = params.toString();
       // Reconstruct path: pathname + new query string
       cleanPath = dummyUrl.pathname + (newSearch ? `?${newSearch}` : '');
     } catch(e) {
       // Fallback: simple string replacement if URL parsing fails
       cleanPath = path.replace(/[\?&]webFull=[^&]+/, '').replace(/(\?|&)$/, '');
     }
  }

  // 2. If not in webFull mode, return clean path
  if (!tabsStore.isWebFull) return cleanPath;
  
  // 3. If in webFull mode, append the param
  const separator = cleanPath.includes('?') ? '&' : '?';
  return `${cleanPath}${separator}webFull=1`;
}

const visitedViews = computed({
  get: () => tabsStore.visitedViews,
  set: (val) => {
    tabsStore.replaceViews(val);
  },
});
const activeKey = ref(route.fullPath);

// Watch active key to scroll
watch(activeKey, () => {
  nextTick(() => {
    scrollToActiveTab();
  });
});

// Watch route change to add tab
watch(
  () => route.fullPath,
  () => {
    addTags();
    tabsStore.touchView(route.fullPath);
    activeKey.value = route.fullPath;
  }
);

function initTags() {
  const routes = router.getRoutes();
  const affixTags = routes.filter((route) => route.meta && route.meta.affix);
  for (const tag of affixTags) {
    if (tag.name) {
      tabsStore.addView({
        ...tag,
        fullPath: tag.path,
      } as any);
    }
  }

  // 强制初始化首页 Tab (如果它不在 affixTags 中)
  // 因为现在首页可能是动态路由，meta.affix 可能没生效，或者 router.getRoutes() 还没拿到最新的
  if (!tabsStore.visitedViews.some(v => v.path === '/')) {
    tabsStore.addView({
      path: '/',
      name: 'HomeView',
      meta: { title: '首页', affix: true },
      fullPath: '/'
    } as any);
  }
}

function addTags() {
  if (route.name) {
    tabsStore.addView(route);
  }
}

function buildStoredTabSession(): StoredTabSession {
  return {
    version: 1,
    tabs: tabsStore.visitedViews.map(view => ({
      title: view.title,
      path: view.path,
      name: view.name,
      fullPath: view.fullPath,
      tooltip: view.tooltip,
      activeAt: view.activeAt,
    })),
  };
}

async function persistTabsConfig() {
  if (isRestoringTabs.value || !currentOrgId.value || !userStore.id) {
    return;
  }

  await userConfigApi.setConfig({
    key: TAB_SESSION_CONFIG_KEY,
    value: JSON.stringify(buildStoredTabSession()),
    description: '用户标签页会话',
  });
}

function schedulePersistTabsConfig() {
  if (isRestoringTabs.value) {
    return;
  }

  if (persistTabsTimer) {
    clearTimeout(persistTabsTimer);
  }

  // 用短延迟合并频繁操作，避免拖拽排序时连续发送请求。
  persistTabsTimer = setTimeout(() => {
    void persistTabsConfig();
  }, 300);
}

function isNotFoundRoute(fullPath: string) {
  const resolved = router.resolve(fullPath);
  return resolved.matched.some(item => item.path === '/:pathMatch(.*)*');
}

function mapStoredTabToView(savedTab: StoredTabItem) {
  const resolved = router.resolve(savedTab.fullPath);
  if (!resolved?.matched?.length || isNotFoundRoute(savedTab.fullPath)) {
    return null;
  }

  return {
    title: savedTab.title || (resolved.meta.title as string) || (resolved.name as string),
    path: resolved.path,
    name: (resolved.name as string) || savedTab.name,
    fullPath: savedTab.fullPath,
    meta: resolved.meta,
    tooltip: savedTab.tooltip,
    activeAt: savedTab.activeAt || savedTab.openedAt || new Date().toISOString(),
  } as TabItem;
}

async function restoreTabsConfig() {
  if (!currentOrgId.value || !userStore.id) {
    return;
  }

  try {
    const res = await userConfigApi.getConfigs(TAB_SESSION_CONFIG_PREFIX);
    // 响应拦截器里已经把 ApiResponse.data 剥出来了，这里做运行时防御 + 类型收敛
    if (!res || !Array.isArray(res)) {
      console.debug('[TabsView.restoreTabsConfig] 后端未返回数组', res);
      return;
    }
    const sessionConfig = res.find(config => config.key === TAB_SESSION_CONFIG_KEY);
    if (!sessionConfig?.value) {
      console.debug('[TabsView.restoreTabsConfig] 当前 user+org 在后端没有已保存的 tab 会话', {
        userId: userStore.id,
        orgId: currentOrgId.value,
      });
      return;
    }

    const parsed = JSON.parse(sessionConfig.value) as StoredTabSession;
    if (!parsed || !Array.isArray(parsed.tabs)) {
      return;
    }
    // 关键调试：先把后端存的原始 tab 快照打印出来，区分「库里本来就没存那个 tab」还是「恢复时被过滤掉了」
    console.debug('[TabsView.restoreTabsConfig] 后端原始会话快照', {
      userId: userStore.id,
      orgId: currentOrgId.value,
      rawTabs: parsed.tabs.map(t => ({ title: t.title, path: t.path, name: t.name, fullPath: t.fullPath, activeAt: t.activeAt })),
    });

    const affixViews = tabsStore.visitedViews.filter(isAffix);
    const restoredViews: TabItem[] = [...affixViews];
    // 先找已存在的首页引用，后面用持久化的 activeAt 覆盖它（initTags 刚刚给它塞了 new Date()，会污染最大活跃时间判定）
    const homeView = restoredViews.find(v => v.path === '/' || v.name === 'HomeView');

    const skippedByFilter: string[] = [];
    const skippedByExist: string[] = [];

    for (const savedTab of parsed.tabs) {
      if (!savedTab?.fullPath) {
        continue;
      }

      const isHome = savedTab.path === '/' || savedTab.name === 'HomeView';
      // 首页不重复入列，但必须把持久化的 activeAt 写回已有首页对象，避免它永远被 new Date() 冒充"最后活跃"
      if (isHome) {
        if (homeView) {
          homeView.activeAt = savedTab.activeAt || savedTab.openedAt || homeView.activeAt;
        }
        continue;
      }

      const restoredTab = mapStoredTabToView(savedTab);
      if (!restoredTab) {
        // mapStoredTabToView 内部会用 router.resolve 校验 matched 和 /:pathMatch(.*)*
        skippedByFilter.push(savedTab.fullPath);
        continue;
      }

      const exists = restoredViews.some(view => tabsStore.getTabIdentity(view.fullPath) === tabsStore.getTabIdentity(restoredTab.fullPath));
      if (!exists) {
        restoredViews.push(restoredTab);
      } else {
        skippedByExist.push(savedTab.fullPath);
      }
    }

    tabsStore.replaceViews(restoredViews);
    console.debug('[TabsView.restoreTabsConfig] 恢复完成', {
      restored: restoredViews.map(v => ({ title: v.title, fullPath: v.fullPath, activeAt: v.activeAt })),
      skippedByFilter,
      skippedByExist,
      homeViewActiveAtAfter: homeView?.activeAt,
    });
  } catch (error) {
    console.error('恢复标签页会话失败', error);
  }
}

async function initializeTabsSession() {
  if (persistTabsTimer) {
    clearTimeout(persistTabsTimer);
    persistTabsTimer = null;
  }

  isRestoringTabs.value = true;
  try {
    tabsStore.replaceViews(tabsStore.visitedViews.filter(isAffix));
    initTags();
    await restoreTabsConfig();
    addTags();
  } finally {
    isRestoringTabs.value = false;
    schedulePersistTabsConfig();
  }
}

// 会话切换（登录/模拟登录/退出模拟/组织切换初始化）后的恢复兜底：
// 只要 tabs 会话刚从 user_config 恢复完成、当前地址仍然停留在首页「/」，
// 就跳到该用户+组织维度下 activeAt 最大的最后活跃 Tab。
//
// 为什么不再依赖 localStorage 一次性 flag？
// 因为整页刷新后会先 onMounted（已拿到 flag → 清掉 → 准备跳转），
// 但 App 启动时 userStore.fetchOrganizations() 会给 B 用户自动 switchOrg(默认组织)，
// switchOrg 改 currentOrg → tabsSessionScope 变化 → watch 里再跑一遍 initializeTabsSession，
// 此时 localStorage 里 flag 已经被第一遍清掉了，第二遍初始化后就停在首页不再跳。
// 现在改为「只要当前地址是 / 且配置里有最后活跃的非首页 Tab 就跳」，两种初始化入口都能覆盖。
async function maybeRestoreLastActiveTab() {
  // 如果用户手动刷新时带了具体路由（例如 /personal/todo），尊重显式访问意图，不强制跳
  const currentPathOnly = route.path;
  if (currentPathOnly !== '/') {
    return;
  }

  const latestView = tabsStore.getLatestActiveView();
  if (!latestView) {
    return;
  }

  // 库里最后活跃就是首页本身，没别的业务 Tab 可切
  if (!latestView.path || latestView.path === '/' || latestView.name === 'HomeView') {
    return;
  }

  const currentIdentity = tabsStore.getTabIdentity(route.fullPath);
  const latestIdentity = tabsStore.getTabIdentity(latestView.fullPath);
  if (currentIdentity === latestIdentity) {
    return;
  }

  const targetTitle = latestView.title || latestView.name;
  const targetFullPath = getPathWithWebFull(latestView.fullPath);

  // 全屏遮罩：显示「正在打开 xxx...」Spin，压过所有内容（遮罩 DOM 挂 App.vue 根下，走全局通用 loadingStore）
  // 固定 id = 'tabs-restore-last-active' 保证「多次触发时只留最后一次文案」，不会重复叠加
  const closeLoading = loadingStore.show(`正在打开 ${targetTitle} ...`, 'tabs-restore-last-active');

  let loadingClosed = false;
  const safeHide = () => {
    if (!loadingClosed) {
      loadingClosed = true;
      closeLoading();
    }
  };

  try {
    console.debug('[TabsView] 自动跳转到最后活跃 Tab:', {
      from: route.fullPath,
      to: latestView.fullPath,
      toTitle: latestView.title,
      toActiveAt: latestView.activeAt,
    });

    tabsStore.touchView(latestView.fullPath);
    activeKey.value = latestView.fullPath;

    // 注册一次性 afterEach：路由真正 resolve（异步组件加载完成）后再关 loading
    const offAfterEach = router.afterEach((_to, _from, failure) => {
      offAfterEach();
      if (failure) {
        console.warn('[TabsView] 跳转最后活跃 Tab 被中断', failure);
      }
      // 再等一个 nextTick 让目标组件的 setup 至少执行完，页面才不会继续空
      void nextTick().then(safeHide);
    });

    // 兜底超时：不管 afterEach 有没有触发，3s 后强制关，避免遮罩永远盖着
    const timeoutTimer = setTimeout(safeHide, 3000);
    const offBefore = router.beforeEach(() => {
      // 如果目标 Tab 还在加载中，用户又被守卫重定向到了别的地方（比如 401 跳登录），提前关遮罩
      clearTimeout(timeoutTimer);
      offBefore();
    });

    await router.replace(targetFullPath);
  } catch (error) {
    console.warn('恢复最后活跃 Tab 失败', error);
    safeHide();
  }
}

function isAffix(tag: TabItem) {
  return tag.meta && tag.meta.affix;
}

function hasLeftClosable(index: number) {
  const views = visitedViews.value;
  if (!views || index <= 0) return false;
  for (let i = 0; i < index; i++) {
    const view = views[i];
    if (view && !isAffix(view)) {
      return true;
    }
  }
  return false;
}

function hasRightClosable(index: number) {
  const views = visitedViews.value;
  if (!views || index >= views.length - 1) return false;
  for (let i = index + 1; i < views.length; i++) {
    const view = views[i];
    if (view && !isAffix(view)) {
      return true;
    }
  }
  return false;
}

function hasOtherClosable(view: TabItem) {
  return visitedViews.value.some(v => v.fullPath !== view.fullPath && !isAffix(v));
}

function hasAnyClosable() {
  return visitedViews.value.some(v => !isAffix(v));
}

function onChange(key: any) {
  router.push(getPathWithWebFull(key as string));
}

function toggleWorkbenchEditMode() {
  workbenchStore.toggleEditMode();
}

function onEdit(targetKey: any, action: string) {
  if (action === 'remove' && typeof targetKey === 'string') {
    removeTab(targetKey);
  }
}

function removeTab(key: string) {
  const view = visitedViews.value.find((v) => v.fullPath === key);
  if (!view) return;
  
  tabsStore.delView(view);
  
  if (activeKey.value === key) {
    toLastView(visitedViews.value, view);
  }
}

function toLastView(visitedViews: TabItem[], view: TabItem) {
  const latestView = tabsStore.getLatestActiveView(visitedViews);
  if (latestView) {
    router.push(getPathWithWebFull(latestView.fullPath));
  } else {
    if (view.name === 'HomeView') {
      router.replace({ path: '/redirect' + getPathWithWebFull(view.fullPath) });
    } else {
      router.push(getPathWithWebFull('/'));
    }
  }
}

function refreshSelectedTag(view: TabItem) {
  tabsStore.delCachedView(view);
  const { path } = view;
  nextTick(() => {
    router.replace({
      path: '/redirect' + path,
      query: route.query
    });
  });
}

function closeLeftTags(view: TabItem) {
  tabsStore.delLeftViews(view);
  if (!visitedViews.value.find((v) => v.fullPath === route.fullPath)) {
    toLastView(tabsStore.visitedViews, view);
  }
}

function closeRightTags(view: TabItem) {
  tabsStore.delRightViews(view);
  if (!visitedViews.value.find((v) => v.fullPath === route.fullPath)) {
    toLastView(tabsStore.visitedViews, view);
  }
}

function closeOthersTags(view: TabItem) {
  router.push(getPathWithWebFull(view.fullPath));
  tabsStore.delOthersViews(view);
}

function closeAllTags(view: TabItem) {
  tabsStore.delAllViews();
  if (tabsStore.visitedViews.some((tag) => tag.path === view.path)) {
    return;
  }
  toLastView(tabsStore.visitedViews, view);
}

function onDragStart() {
  // Drag start logic if needed
}

function onDragEnd() {
  // Drag end logic if needed
}

function checkMove(evt: any) {
  // 禁止拖动 HomeView
  if (evt.draggedContext.element.name === 'HomeView') return false;
  // 禁止拖动到第一个位置 (HomeView 的位置)
  if (evt.relatedContext.index === 0) return false;
  return true;
}

const scrollContainer = ref<HTMLElement | null>(null);
const showLeftArrow = ref(false);
const showRightArrow = ref(false);

let rafId: number | null = null;
let targetScrollLeft = 0;
let scrollIntervalId: number | null = null;

function onTabScroll(e: WheelEvent) {
  if (!scrollContainer.value) return;

  const currentScrollLeft = scrollContainer.value.scrollLeft;
  const maxScrollLeft = scrollContainer.value.scrollWidth - scrollContainer.value.clientWidth;

  // 如果没有正在进行的动画，初始化目标位置为当前位置
  if (rafId === null) {
    targetScrollLeft = currentScrollLeft;
  }

  // 累加滚动距离
  targetScrollLeft += e.deltaY;

  // 边界限制
  if (targetScrollLeft < 0) targetScrollLeft = 0;
  if (targetScrollLeft > maxScrollLeft) targetScrollLeft = maxScrollLeft;

  // 如果没有动画在运行，启动动画循环
  if (rafId === null) {
    animateScroll();
  }
}

function animateScroll() {
  if (!scrollContainer.value) {
    rafId = null;
    return;
  }

  const currentScrollLeft = scrollContainer.value.scrollLeft;
  const diff = targetScrollLeft - currentScrollLeft;

  // 当距离足够近时，直接定位并停止动画
  if (Math.abs(diff) < 1) {
    scrollContainer.value.scrollLeft = targetScrollLeft;
    rafId = null;
    checkScrollState(); // 滚动结束时检查箭头状态
    return;
  }

  // 惯性平滑处理 (Lerp)，因子 0.2 控制平滑度
  scrollContainer.value.scrollLeft += diff * 0.2;
  checkScrollState(); // 滚动过程中实时更新箭头状态
  
  rafId = requestAnimationFrame(animateScroll);
}

function startScroll(direction: 'left' | 'right') {
  if (scrollIntervalId) return;
  
  const step = direction === 'left' ? -10 : 10;
  
  const scrollLoop = () => {
    if (!scrollContainer.value) return;
    
    // 直接累加到目标位置，复用 animateScroll 的平滑逻辑
    if (rafId === null) {
      targetScrollLeft = scrollContainer.value.scrollLeft;
    }
    
    targetScrollLeft += step;
    
    const maxScrollLeft = scrollContainer.value.scrollWidth - scrollContainer.value.clientWidth;
    if (targetScrollLeft < 0) targetScrollLeft = 0;
    if (targetScrollLeft > maxScrollLeft) targetScrollLeft = maxScrollLeft;
    
    if (rafId === null) {
      animateScroll();
    }
    
    scrollIntervalId = requestAnimationFrame(scrollLoop);
  };
  
  scrollLoop();
}

function stopScroll() {
  if (scrollIntervalId !== null) {
    cancelAnimationFrame(scrollIntervalId);
    scrollIntervalId = null;
  }
}

function checkScrollState() {
  if (!scrollContainer.value) return;
  
  const { scrollLeft, scrollWidth, clientWidth } = scrollContainer.value;
  const tolerance = 2; // 增加容差，避免因小数或 subpixel 导致判定不准
  
  showLeftArrow.value = scrollLeft > tolerance;
  showRightArrow.value = scrollWidth > clientWidth && scrollLeft < scrollWidth - clientWidth - tolerance;
}

onBeforeUnmount(() => {
  if (rafId !== null) {
    cancelAnimationFrame(rafId);
  }
  if (scrollIntervalId !== null) {
    cancelAnimationFrame(scrollIntervalId);
  }
  if (persistTabsTimer) {
    clearTimeout(persistTabsTimer);
  }
});

function scrollToActiveTab() {
  if (!scrollContainer.value) return;
  const activeTab = scrollContainer.value.querySelector('.ant-tabs-tab-active') as HTMLElement;
  if (!activeTab) return;
  
  activeTab.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'center' });
  // scrollIntoView 是异步的，这里做个延时检查，或者依赖 scroll 事件
  setTimeout(checkScrollState, 300);
}

onMounted(() => {
  void initializeTabsSession()
    .then(() => maybeRestoreLastActiveTab())
    .then(() => nextTick(() => {
      scrollToActiveTab();
      checkScrollState();
      window.addEventListener('resize', checkScrollState);
    }));
});

onBeforeUnmount(() => {
  window.removeEventListener('resize', checkScrollState);
});

// 监听 tab 变化，重新检查滚动状态
watch(
  () => tabsStore.visitedViews.length,
  () => {
    nextTick(checkScrollState);
  }
);

watch(
  () => tabsStore.visitedViews,
  () => {
    schedulePersistTabsConfig();
  },
  { deep: true }
);

watch(
  tabsSessionScope,
  async (newScope, oldScope) => {
    if (!newScope || newScope === oldScope) {
      return;
    }

    await initializeTabsSession();
    // 模拟登录/退出模拟会通过整页刷新走 onMounted 路径
    // 这里兜底：如果是带标记的会话切换场景，也尝试恢复最后活跃 Tab
    await maybeRestoreLastActiveTab();
    await nextTick();
    if (route.fullPath) {
      addTags();
      tabsStore.touchView(route.fullPath);
      activeKey.value = route.fullPath;
    }
    await nextTick();
    scrollToActiveTab();
    checkScrollState();
  }
);
</script>

<style scoped>
.tabs-view-container {
  background: #f5f5f5;
  border-bottom: 1px solid #d9d9d9;
  overflow: hidden;
  position: relative;
  transition: all 0.3s;
}

.tabs-wrapper {
  display: flex;
  align-items: flex-end; /* Align to bottom so tabs sit on line */
}

.tabs-view {
  flex: 1;
  width: 0; /* Allow shrinking */
  margin-top: 5px;
}

.fullscreen-btn {
  height: 40px; /* Approximate tab height */
  padding: 0 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  color: #666;
  transition: all 0.3s;
  margin-bottom: 1px; /* Adjust for border */
  border-left: 1px solid #d9d9d9;
}

.fullscreen-btn:hover {
  background: rgba(0, 0, 0, 0.025);
  color: #1890ff;
}

/* Fullscreen Mode */
.tabs-view-container.fullscreen-mode {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  z-index: 1001;
  padding: 0;
  background: transparent;
  border: none;
  pointer-events: none;
}

.tabs-view-container.fullscreen-mode .tabs-wrapper {
  background: #f5f5f5;
  padding: 6px 0 0;
  border-bottom: 1px solid #d9d9d9;
  transform: translateY(-100%);
  transition: transform 0.3s;
  pointer-events: auto;
  /* box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15); */
}

.tabs-view-container.fullscreen-mode:hover .tabs-wrapper,
.tabs-view-container.fullscreen-mode:has(.fullscreen-trigger:hover) .tabs-wrapper {
  transform: translateY(0);
}

.fullscreen-trigger {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 6px;
  z-index: 1002;
  pointer-events: auto;
}

/* 覆盖 Ant Design 默认样式，隐藏原有的 bar */
:deep(.ant-tabs-nav) {
  margin: 0 !important;
}

:deep(.ant-tabs-nav::before) {
  border-bottom: none !important;
}

:deep(.ant-tabs-nav-list) {
  display: flex !important;
  flex-wrap: nowrap;
  width: max-content;
  min-width: 100%;
}

:deep(.ant-tabs-nav-list > *) {
  flex-shrink: 0;
}

.tabs-nav-wrap {
  position: relative;
  display: flex;
  width: 100%;
  overflow: hidden;
}

.nav-arrow {
  position: absolute;
  top: 0;
  bottom: 0;
  width: 24px;
  background: rgba(255, 255, 255, 0.9);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  z-index: 10;
  border-top: 1px solid #d9d9d9;
  box-shadow: 0 0 5px rgba(0, 0, 0, 0.1);
  color: #666;
  transition: all 0.3s;
}

.nav-arrow:hover {
  background: #f0f0f0;
  color: #1890ff;
}

.left-arrow {
  left: 0;
  border-right: 1px solid #d9d9d9;
}

.right-arrow {
  right: 0;
  border-left: 1px solid #d9d9d9;
}

.tabs-scroll-wrapper {
  width: 100%;
  overflow-x: auto;
  overflow-y: hidden;
  white-space: nowrap;
  scrollbar-width: none; /* Firefox */
  display: flex;
  scroll-behavior: auto; /* 使用自定义平滑滚动 */
}

.tabs-scroll-wrapper::-webkit-scrollbar {
  display: none; /* Chrome/Safari/Webkit */
}

/* 自定义 Tab 样式 */
.ant-tabs-tab {
  flex-shrink: 0; /* 防止宽度被压缩 */
  white-space: nowrap; /* 防止文字换行 */
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0 12px;
  min-width: 80px;
  height: 34px;
  line-height: 34px;
  margin: 0 -1px 0 0 !important; /* 强制覆盖所有 margin，并设置负右边距 */
  cursor: pointer;
  background: #e8e8e8;
  border: 1px solid #d9d9d9;
  border-bottom: none;
  transition: all 0.3s;
  z-index: 1;
  user-select: none;
}

/* 内容反向倾斜，保持文字端正 */
.ant-tabs-tab-btn {
  display: flex;
  align-items: center;
  font-size: 13px;
  color: #666;
}

/* 激活状态 */
.ant-tabs-tab-active {
  background: #fff;
  z-index: 10; /* 激活的层级最高 */
  border-top: 2px solid #1890ff;
  border-bottom: 1px solid #fff; /* 遮住底部的线，看起来和内容连在一起 */
  box-shadow: 0 -2px 5px rgba(0, 0, 0, 0.05);
}

/* 激活的前一个兄弟元素 */
.ant-tabs-tab-active + .ant-tabs-tab {
  z-index: 1;
}

.ant-tabs-tab-active .ant-tabs-tab-btn {
  color: #1890ff;
  font-weight: 500;
}

/* 悬停状态 */
.ant-tabs-tab:hover:not(.ant-tabs-tab-active) {
  background: #f0f0f0;
  z-index: 5;
}

/* 关闭按钮 */
.ant-tabs-tab-remove {
  margin-left: 8px;
  font-size: 12px;
  color: #999;
  transition: all 0.2s;
  border-radius: 50%;
  width: 16px;
  height: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.ant-tabs-tab-remove:hover {
  background: #ff4d4f;
  color: #fff;
}
</style>
