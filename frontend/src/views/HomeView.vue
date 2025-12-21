<template>
  <div class="home-container">
    <div class="dashboard-controls" v-if="workbenchStore.isEditMode">
      <div class="left-controls"></div>
      <a-space>
        <a-button type="dashed" @click="showWidgetDrawer">
          <template #icon><DynamicIcon icon="ant-design:plus-outlined" /></template>
          添加组件
        </a-button>
        <a-button type="primary" @click="saveLayout">
          <template #icon><DynamicIcon icon="ant-design:save-outlined" /></template>
          保存布局
        </a-button>
        <a-button @click="resetLayout">
          <template #icon><DynamicIcon icon="ant-design:reload-outlined" /></template>
          重置默认
        </a-button>
        <a-button type="primary" danger @click="cancelEdit">
          取消编辑
        </a-button>
      </a-space>
    </div>

    <div class="grid-container">
      <GridLayout
        v-if="layout.length"
        v-model:layout="layout"
        :col-num="12"
        :row-height="30"
        :is-draggable="workbenchStore.isEditMode"
        :is-resizable="workbenchStore.isEditMode"
        :vertical-compact="true"
        :use-css-transforms="true"
      >
        <GridItem
          v-for="item in layout"
          :key="item.i"
          :x="item.x"
          :y="item.y"
          :w="item.w"
          :h="item.h"
          :i="item.i"
          :min-w="2"
          :min-h="2"
          :is-resizable="workbenchStore.isEditMode"
          :is-draggable="workbenchStore.isEditMode"
          class="grid-item-card"
          :class="{ 'is-editing': workbenchStore.isEditMode }"
        >
          <div class="widget-content">
            <component :is="componentMap[item.type]" />
            <div v-if="workbenchStore.isEditMode" class="widget-mask">
              <span class="drag-handle">按住拖拽</span>
              <a-button type="text" danger size="small" class="delete-btn" @click.stop="removeWidget(item.i)">
                <template #icon><DynamicIcon icon="ant-design:delete-outlined" /></template>
              </a-button>
            </div>
          </div>
        </GridItem>
      </GridLayout>
    </div>

    <a-drawer
      v-model:open="drawerVisible"
      title="组件库"
      placement="right"
      width="320"
    >
      <div v-if="filteredAvailableWidgets.length === 0" class="empty-widget-tip">
        <DynamicIcon icon="ant-design:inbox-outlined" style="font-size: 48px; color: #ccc; margin-bottom: 16px;" />
        <p>所有组件已添加</p>
      </div>
      <div class="widget-list" v-else>
        <div
          v-for="widget in filteredAvailableWidgets"
          :key="widget.type"
          class="widget-item"
          @click="addWidget(widget)"
        >
          <div class="widget-preview">
            <DynamicIcon :icon="widget.icon" style="font-size: 24px; color: #1890ff;" />
          </div>
          <div class="widget-info">
            <h4>{{ widget.title }}</h4>
            <p>{{ widget.description }}</p>
          </div>
          <div class="add-icon">
            <DynamicIcon icon="ant-design:plus-circle-outlined" />
          </div>
        </div>
      </div>
    </a-drawer>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, defineAsyncComponent, computed } from 'vue';
import { GridLayout, GridItem } from 'grid-layout-plus';
import DynamicIcon from '@/components/DynamicIcon.vue';
import { message } from 'ant-design-vue';
import { v4 as uuidv4 } from 'uuid';
import { useWorkbenchStore } from '@/stores/workbench';

const workbenchStore = useWorkbenchStore();

// 异步加载组件
const WelcomeCard = defineAsyncComponent(() => import('@/components/widgets/WelcomeCard.vue'));
const QuickNav = defineAsyncComponent(() => import('@/components/widgets/QuickNav.vue'));
const StatsCard = defineAsyncComponent(() => import('@/components/widgets/StatsCard.vue'));
const SystemStatus = defineAsyncComponent(() => import('@/components/widgets/SystemStatus.vue'));
const RecentActivities = defineAsyncComponent(() => import('@/components/widgets/RecentActivities.vue'));
const PendingTasks = defineAsyncComponent(() => import('@/components/widgets/PendingTasks.vue'));
const ProjectList = defineAsyncComponent(() => import('@/components/widgets/ProjectList.vue'));
const TeamSchedule = defineAsyncComponent(() => import('@/components/widgets/TeamSchedule.vue'));
const AnnouncementCard = defineAsyncComponent(() => import('@/components/widgets/AnnouncementCard.vue'));
const TodoCalendar = defineAsyncComponent(() => import('@/components/widgets/TodoCalendar.vue'));

const componentMap: Record<string, any> = {
  WelcomeCard,
  QuickNav,
  StatsCard,
  SystemStatus,
  RecentActivities,
  PendingTasks,
  ProjectList,
  TeamSchedule,
  AnnouncementCard,
  TodoCalendar
};

const drawerVisible = ref(false);

interface LayoutItem {
  i: string;
  x: number;
  y: number;
  w: number;
  h: number;
  type: string;
}

interface WidgetMeta {
  type: string;
  title: string;
  description: string;
  icon: string;
  defaultW: number;
  defaultH: number;
  allowDuplicate?: boolean;
}

const availableWidgets: WidgetMeta[] = [
  {
    type: 'WelcomeCard',
    title: '欢迎卡片',
    description: '显示欢迎信息和日期',
    icon: 'ant-design:idcard-outlined',
    defaultW: 8,
    defaultH: 4,
    allowDuplicate: false
  },
  {
    type: 'QuickNav',
    title: '快捷导航',
    description: '常用功能的快速入口',
    icon: 'ant-design:appstore-outlined',
    defaultW: 4,
    defaultH: 6,
    allowDuplicate: false
  },
  {
    type: 'StatsCard',
    title: '核心数据',
    description: '展示关键业务指标',
    icon: 'ant-design:bar-chart-outlined',
    defaultW: 4,
    defaultH: 6,
    allowDuplicate: false
  },
  {
    type: 'SystemStatus',
    title: '系统状态',
    description: 'CPU、内存和磁盘监控',
    icon: 'ant-design:dashboard-outlined',
    defaultW: 4,
    defaultH: 10,
    allowDuplicate: false
  },
  {
    type: 'RecentActivities',
    title: '最近动态',
    description: '系统和用户活动日志',
    icon: 'ant-design:field-time-outlined',
    defaultW: 4,
    defaultH: 10,
    allowDuplicate: false
  },
  {
    type: 'PendingTasks',
    title: '待办任务',
    description: '待处理的审批和任务',
    icon: 'ant-design:ordered-list-outlined',
    defaultW: 4,
    defaultH: 10,
    allowDuplicate: false
  },
  {
    type: 'ProjectList',
    title: '项目进度',
    description: '项目列表及进度追踪',
    icon: 'ant-design:project-outlined',
    defaultW: 8,
    defaultH: 10,
    allowDuplicate: false
  },
  {
    type: 'TeamSchedule',
    title: '团队日程',
    description: '团队会议和日程安排',
    icon: 'ant-design:calendar-outlined',
    defaultW: 4,
    defaultH: 10,
    allowDuplicate: false
  },
  {
    type: 'AnnouncementCard',
    title: '系统公告',
    description: '重要通知和公告',
    icon: 'ant-design:sound-outlined',
    defaultW: 12,
    defaultH: 6,
    allowDuplicate: false
  },
  {
    type: 'TodoCalendar',
    title: '事项日历',
    description: '查看每日待办事项',
    icon: 'ant-design:calendar-outlined',
    defaultW: 4,
    defaultH: 10,
    allowDuplicate: false
  }
];

const filteredAvailableWidgets = computed(() => {
  return availableWidgets.filter(widget => {
    if (widget.allowDuplicate) {
      return true;
    }
    // Check if widget is already in layout
    return !layout.value.some(item => item.type === widget.type);
  });
});

const defaultLayout: LayoutItem[] = [
  { i: 'welcome', x: 0, y: 0, w: 8, h: 4, type: 'WelcomeCard' },
  { i: 'todo', x: 8, y: 0, w: 4, h: 10, type: 'TodoCalendar'},
  { i: 'quick-nav', x: 4, y: 4, w: 4, h: 6, type: 'QuickNav' },
  { i: 'stats', x: 0, y: 4, w: 4, h: 6, type: 'StatsCard' },
  { i: 'system', x: 0, y: 9, w: 4, h: 10, type: 'SystemStatus' },
  { i: 'activities', x: 4, y: 9, w: 4, h: 10, type: 'RecentActivities' },
  { i: 'tasks', x: 8, y: 9, w: 4, h: 10, type: 'PendingTasks' },
  { i: 'projects', x: 0, y: 19, w: 8, h: 10, type: 'ProjectList' },
  { i: 'schedule', x: 8, y: 19, w: 4, h: 10, type: 'TeamSchedule' },
  { i: 'announcement', x: 0, y: 29, w: 12, h: 6, type: 'AnnouncementCard' },
];

const layout = ref<LayoutItem[]>([]);

const loadLayout = () => {
  const saved = localStorage.getItem('oms_dashboard_layout_v2');
  if (saved) {
    try {
      const savedLayout = JSON.parse(saved);
      // Merge with default layout to ensure new widgets appear
      const existingIds = new Set(savedLayout.map((item: any) => item.i));
      const newItems = defaultLayout.filter(item => !existingIds.has(item.i));
      
      layout.value = [...savedLayout, ...newItems];
    } catch (e) {
      layout.value = JSON.parse(JSON.stringify(defaultLayout));
    }
  } else {
    layout.value = JSON.parse(JSON.stringify(defaultLayout));
  }
};

const saveLayout = () => {
  localStorage.setItem('oms_dashboard_layout_v2', JSON.stringify(layout.value));
  message.success('布局已保存');
  workbenchStore.setEditMode(false);
};

const cancelEdit = () => {
  loadLayout(); // Reload to discard changes
  workbenchStore.setEditMode(false);
  message.info('已取消编辑');
};

const resetLayout = () => {
  layout.value = JSON.parse(JSON.stringify(defaultLayout));
  message.info('已恢复默认布局');
};

const showWidgetDrawer = () => {
  drawerVisible.value = true;
};

const addWidget = (widget: WidgetMeta) => {
  // 计算当前布局的最底部，避免使用 Infinity 导致浏览器卡死
  let maxY = 0;
  layout.value.forEach(item => {
    const bottom = item.y + item.h;
    if (bottom > maxY) {
      maxY = bottom;
    }
  });

  const newItem: LayoutItem = {
    i: uuidv4(),
    x: 0,
    y: maxY, 
    w: widget.defaultW,
    h: widget.defaultH,
    type: widget.type
  };
  layout.value.push(newItem);
  message.success(`已添加 ${widget.title}`);
  drawerVisible.value = false;
};

const removeWidget = (id: string) => {
  const index = layout.value.findIndex(item => item.i === id);
  if (index !== -1) {
    layout.value.splice(index, 1);
  }
};

onMounted(() => {
  loadLayout();
});
</script>

<style scoped>
/* ... existing styles ... */
.home-container {
  padding: 0;
  height: 100%;
  display: flex;
  flex-direction: column;
}

.dashboard-controls {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 8px;
  padding-top: 8px;
}

.grid-container {
  flex: 1;
  overflow-y: auto;
  overflow-x: hidden;
}

.grid-item-card {
  background: transparent;
  border-radius: 8px;
  transition: box-shadow 0.3s;
}

.grid-item-card.is-editing {
  border: 1px dashed #1890ff;
  background: rgba(24, 144, 255, 0.05);
}

.widget-content {
  height: 100%;
  position: relative;
  overflow: hidden;
  border-radius: 8px;
}

.widget-mask {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.1);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: move;
  z-index: 10;
}

.drag-handle {
  background: rgba(0, 0, 0, 0.6);
  color: #fff;
  padding: 4px 12px;
  border-radius: 16px;
  font-size: 12px;
  pointer-events: none;
}

.delete-btn {
  position: absolute;
  top: 8px;
  right: 8px;
  color: #ff4d4f;
  background: #fff;
  border-radius: 50%;
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  pointer-events: auto;
}

.widget-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.widget-item {
  display: flex;
  align-items: center;
  padding: 12px;
  border: 1px solid #f0f0f0;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s;
}

.widget-item:hover {
  border-color: #1890ff;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.widget-preview {
  width: 48px;
  height: 48px;
  background: #f5f5f5;
  border-radius: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 16px;
}

.widget-info {
  flex: 1;
}

.widget-info h4 {
  margin: 0 0 4px 0;
  font-size: 14px;
}

.widget-info p {
  margin: 0;
  font-size: 12px;
  color: #999;
}

.add-icon {
  font-size: 18px;
  color: #1890ff;
  opacity: 0;
  transition: opacity 0.3s;
}

.widget-item:hover .add-icon {
  opacity: 1;
}

:deep(.vgl-item__resizer) {
  z-index: 100 !important;
  width: 20px !important;
  height: 20px !important;
}

:deep(.vgl-item__resizer::before) {
  border-right: 2px solid #1890ff !important;
  border-bottom: 2px solid #1890ff !important;
  width: 10px !important;
  height: 10px !important;
  right: 4px !important;
  bottom: 4px !important;
}

.empty-widget-tip {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 48px 0;
  color: #999;
}
</style>
