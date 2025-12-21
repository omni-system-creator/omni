<template>
  <div class="todo-calendar-widget">
    <a-calendar :fullscreen="false" :value="currentDate" @select="onSelect" @panelChange="onPanelChange" :locale="zhCN">
      <template #headerRender="{ value, onChange }">
        <div class="custom-header">
          <div class="header-left">
            <a-button type="text" size="small" @click="changeMonth(value, -1, onChange)">
              上一月
            </a-button>
          </div>
          <div class="header-center">
            <a-date-picker
              :value="value"
              picker="month"
              :allowClear="false"
              :bordered="false"
              :inputReadOnly="true"
              format="YYYY年MM月"
              @change="onChange"
              class="month-picker-text"
              :locale="zhCN"
            >
              <template #suffixIcon><span></span></template>
            </a-date-picker>
          </div>
          <div class="header-right">
            <a-button 
              v-if="!isCurrentMonth(value)" 
              type="link" 
              size="small" 
              class="back-today-btn"
              @click="backToToday(onChange)"
            >
              回到本月
            </a-button>
            <a-button type="text" size="small" @click="changeMonth(value, 1, onChange)">
              下一月
            </a-button>
          </div>
        </div>
      </template>
      <template #dateFullCellRender="{ current }">
        <div 
          class="custom-date-cell"
          :class="{ 
            'is-today': isToday(current),
            'is-selected': isSelected(current)
          }"
        >
          <div class="date-value">{{ current.date() }}</div>
          <div v-if="hasTask(current)" class="task-dot"></div>
        </div>
      </template>
    </a-calendar>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import dayjs, { Dayjs } from 'dayjs';
import 'dayjs/locale/zh-cn';
import zhCN from 'ant-design-vue/es/date-picker/locale/zh_CN';

dayjs.locale('zh-cn');

const router = useRouter();
const currentDate = ref(dayjs());
const selectedDate = ref<Dayjs | null>(dayjs());

const changeMonth = (value: Dayjs, offset: number, onChange: (date: Dayjs) => void) => {
  const newValue = value.add(offset, 'month');
  onChange(newValue);
  // 切换月份不更新选中日期
};

const backToToday = (onChange: (date: Dayjs) => void) => {
  const today = dayjs();
  onChange(today);
  selectedDate.value = today;
};

const isToday = (date: Dayjs) => {
  return date.isSame(dayjs(), 'day');
};

const isSelected = (date: Dayjs) => {
  return selectedDate.value && date.isSame(selectedDate.value, 'day');
};

const isCurrentMonth = (date: Dayjs) => {
  return date.isSame(dayjs(), 'month');
};

// 模拟任务数据
const taskMap: Record<string, number> = {
  '2025-12-21': 3,
  '2025-12-25': 1,
  '2025-12-28': 2,
  '2025-12-05': 1,
  '2025-12-15': 4,
};

const hasTask = (date: Dayjs) => {
  const dateStr = date.format('YYYY-MM-DD');
  return !!taskMap[dateStr] || Math.random() > 0.8; // 模拟随机数据，保证有些天有红点
};

const onSelect = (date: Dayjs, info: any) => {
  // 只有当 source 为 'date' 时才跳转，避免切换月份时触发
  if (info?.source === 'date') {
    selectedDate.value = date;
    router.push({
      path: '/personal/todo',
      query: {
        date: date.format('YYYY-MM-DD')
      }
    });
  }
};

const onPanelChange = (date: Dayjs) => {
  currentDate.value = date;
};
</script>

<style scoped>
.todo-calendar-widget {
  height: 100%;
  display: flex;
  flex-direction: column;
  background: #fff;
  overflow: hidden;
}

.custom-header {
  position: relative;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 16px;
}

.header-left, .header-right {
  display: flex;
  align-items: center;
  min-width: 60px; /* Ensure space for buttons */
}

.header-right {
  justify-content: flex-end;
  gap: 4px;
}

.header-center {
  position: absolute;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  justify-content: center;
}

.month-picker-text {
  width: auto;
  min-width: 120px;
}

:deep(.ant-picker-input > input) {
  text-align: center;
  font-size: 16px;
  font-weight: 500;
  color: rgba(0, 0, 0, 0.85);
  cursor: pointer;
}

:deep(.ant-picker) {
  padding: 4px 11px 4px;
  
}

:deep(.ant-picker-content th) {
  line-height: 48px;
}

:deep(.ant-picker-focused) {
  box-shadow: none;
}

:deep(.ant-picker-calendar) {
  background: transparent;
}

:deep(.ant-picker-panel) {
  background: transparent;
}

:deep(.ant-picker-calendar-header) {
  padding: 8px 16px;
}

/* 覆盖 Ant Design 默认选中样式 */
:deep(.ant-picker-cell-selected .ant-picker-cell-inner) {
  background: transparent !important;
}

:deep(.ant-picker-cell-today .ant-picker-cell-inner::before) {
  border: none !important;
}

.custom-date-cell {
  height: 38px;
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
  align-items: center;
  padding-bottom: 4px;
  position: relative;
  cursor: pointer;
  border-radius: 4px;
  transition: all 0.3s;
}

.custom-date-cell:hover {
  background: rgba(0, 0, 0, 0.04);
}

.custom-date-cell.is-selected {
  background: #1677ff;
  color: #fff;
}

.custom-date-cell.is-today {
  border: 1px solid #1677ff;
}

.custom-date-cell.is-today.is-selected {
  border: none;
}

.date-value {
  font-size: 14px;
  line-height: 24px;
}

.task-dot {
  width: 6px;
  height: 6px;
  background-color: #ff4d4f;
  border-radius: 50%;
  position: absolute;
  bottom: 4px;
}

/* 当选中时，红点变成白色以适应蓝色背景 */
.custom-date-cell.is-selected .task-dot {
  background-color: #fff;
}
</style>
