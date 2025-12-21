<template>
  <div class="tabs-view-container">
    <a-tabs
      v-model:activeKey="activeKey"
      type="editable-card"
      hide-add
      @edit="onEdit"
      @change="onChange"
      class="tabs-view"
    >
      <template #renderTabBar>
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
                    <DynamicIcon icon="ant-design:close-square-outlined" /> 关闭其他
                  </a-menu-item>
                  <a-menu-item key="closeAll" v-if="hasAnyClosable()" @click="closeAllTags(element)">
                    <DynamicIcon icon="ant-design:minus-square-outlined" /> 全部关闭
                  </a-menu-item>
                </a-menu>
              </template>
            </a-dropdown>
          </template>
        </draggable>
      </template>
      <a-tab-pane
        v-for="tag in visitedViews"
        :key="tag.fullPath"
        :tab="tag.title"
        :closable="!isAffix(tag)"
      />
    </a-tabs>
  </div>
</template>

<script setup lang="ts">
import { computed, ref, watch, onMounted, nextTick } from 'vue';
import { useTabsStore, type TabItem } from '../stores/tabs';
import { useRoute, useRouter } from 'vue-router';
import draggable from 'vuedraggable';
import DynamicIcon from '@/components/DynamicIcon.vue';
import { useWorkbenchStore } from '@/stores/workbench';

const tabsStore = useTabsStore();
const workbenchStore = useWorkbenchStore();
const route = useRoute();
const router = useRouter();

const visitedViews = computed({
  get: () => tabsStore.visitedViews,
  set: (val) => {
    tabsStore.visitedViews = val;
  },
});
const activeKey = ref(route.fullPath);

// Watch route change to add tab
watch(
  () => route.fullPath,
  () => {
    addTags();
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

function onChange(key: string) {
  router.push(key);
}

function toggleWorkbenchEditMode() {
  workbenchStore.toggleEditMode();
}

function onEdit(targetKey: string | MouseEvent, action: string) {
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
  const latestView = visitedViews.slice(-1)[0];
  if (latestView) {
    router.push(latestView.fullPath);
  } else {
    if (view.name === 'HomeView') {
      router.replace({ path: '/redirect' + view.fullPath });
    } else {
      router.push('/');
    }
  }
}

function refreshSelectedTag(view: TabItem) {
  tabsStore.delCachedView(view);
  const { fullPath } = view;
  nextTick(() => {
    router.replace({
      path: '/redirect' + fullPath,
    });
  });
}

function closeLeftTags(view: TabItem) {
  tabsStore.delLeftViews(view);
  if (!visitedViews.value.find((v) => v.fullPath === route.fullPath)) {
    router.push(view.fullPath);
  }
}

function closeRightTags(view: TabItem) {
  tabsStore.delRightViews(view);
  if (!visitedViews.value.find((v) => v.fullPath === route.fullPath)) {
    router.push(view.fullPath);
  }
}

function closeOthersTags(view: TabItem) {
  router.push(view);
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

onMounted(() => {
  initTags();
  addTags();
});
</script>

<style scoped>
.tabs-view-container {
  padding: 6px 0 0;
  background: #f5f5f5;
  border-bottom: 1px solid #d9d9d9;
  overflow: hidden; /* 确保左侧负边距被裁剪 */
}

.tabs-view {
  margin-top: 5px;
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
}

/* 自定义 Tab 样式 */
.ant-tabs-tab {
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
