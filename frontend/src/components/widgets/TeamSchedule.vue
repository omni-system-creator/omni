<template>
  <div class="widget-card">
    <div class="card-header">
      <h3>团队日程</h3>
      <div class="date-display">{{ currentDate }}</div>
    </div>
    <div class="schedule-container">
      <div v-for="(item, index) in schedules" :key="index" class="schedule-item">
        <div class="time-col">
          <span class="time">{{ item.time }}</span>
          <div class="line"></div>
        </div>
        <div class="content-col" :class="item.type">
          <div class="title">{{ item.title }}</div>
          <div class="desc">{{ item.desc }}</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import dayjs from 'dayjs';

const currentDate = computed(() => dayjs().format('MM月DD日 dddd'));

const schedules = ref([
  { time: '09:30', title: '晨会', desc: '研发中心全员', type: 'meeting' },
  { time: '11:00', title: 'Code Review', desc: '前端组 - OMS项目', type: 'review' },
  { time: '14:00', title: '产品需求评审', desc: '会议室 A203', type: 'planning' },
  { time: '16:30', title: '技术分享会', desc: 'Zoom 线上会议', type: 'sharing' },
]);
</script>

<style scoped>
.widget-card {
  height: 100%;
  padding: 16px;
  background: #fff;
  border-radius: 8px;
  display: flex;
  flex-direction: column;
}
.card-header {
  margin-bottom: 16px;
  border-bottom: 1px solid #f0f0f0;
  padding-bottom: 8px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.card-header h3 {
  margin: 0;
  font-size: 16px;
  color: #333;
}
.date-display {
  font-size: 12px;
  color: #999;
}
.schedule-container {
  flex: 1;
  overflow-y: auto;
}
.schedule-item {
  display: flex;
  margin-bottom: 16px;
}
.schedule-item:last-child {
  margin-bottom: 0;
}
.time-col {
  width: 50px;
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-right: 12px;
}
.time {
  font-size: 13px;
  font-weight: bold;
  color: #333;
}
.line {
  flex: 1;
  width: 1px;
  background: #f0f0f0;
  margin-top: 4px;
}
.content-col {
  flex: 1;
  padding: 8px 12px;
  border-radius: 4px;
  border-left: 3px solid #1890ff;
  background: #f0f5ff;
}
.content-col.meeting { border-color: #1890ff; background: #e6f7ff; }
.content-col.review { border-color: #722ed1; background: #f9f0ff; }
.content-col.planning { border-color: #fa8c16; background: #fff7e6; }
.content-col.sharing { border-color: #52c41a; background: #f6ffed; }

.title {
  font-size: 13px;
  font-weight: 500;
  color: #333;
  margin-bottom: 4px;
}
.desc {
  font-size: 12px;
  color: #666;
}
</style>
