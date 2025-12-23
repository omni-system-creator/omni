<template>
  <div class="schedule-container">
    <div class="fixed-header">
      <van-nav-bar
        title="我的日程"
        left-text="返回"
        left-arrow
        @click-left="onClickLeft"
      >
        <template #right>
          <span class="nav-btn" @click="onToday">今天</span>
          <van-icon name="plus" size="18" @click="onAdd" style="margin-left: 16px" />
        </template>
      </van-nav-bar>
      <van-calendar
        ref="calendarRef"
        :default-date="currentDate"
        @confirm="onConfirm"
        :poppable="false"
        :show-confirm="false"
        :show-title="false"
        :show-subtitle="false"
        :formatter="formatter"
        class="custom-calendar"
        color="#1989fa"
        :min-date="minDate"
        :max-date="maxDate"
      />
      <div class="timeline-header-bar">
        <div class="timeline-header">
          <div class="header-left">
            <span class="date-title">{{ formattedDate }}</span>
            <div class="lunar-info">{{ additionalDateInfo }}</div>
          </div>
          <span class="task-count">{{ currentEvents.length }}个日程</span>
        </div>
      </div>
    </div>

    <div class="schedule-content">
      <van-pull-refresh v-model="refreshing" @refresh="onRefresh">
        <div class="timeline-container">
          <div class="timeline-list">
            <template v-if="currentEvents.length > 0">
              <div 
                v-for="event in currentEvents" 
                :key="event.id"
                class="timeline-item" 
                :class="{ past: isPast(getEventTime(event.startHour, event.startMinute)) }"
              >
                <div class="time-col">
                  <span class="start-time">{{ event.startTime }}</span>
                  <span class="end-time">{{ event.endTime }}</span>
                </div>
                <div class="content-col">
                  <div 
                    class="event-card" 
                    :class="{ active: !isPast(getEventTime(event.startHour, event.startMinute)) && !isPast(getEventTime(event.endHour, event.endMinute)) }"
                  >
                    <h3>{{ event.title }}</h3>
                    <p class="location"><van-icon name="location-o" /> {{ event.location }}</p>
                    <p class="desc">{{ event.description }}</p>
                    <div class="tags">
                      <van-tag 
                        v-for="(tag, idx) in event.tags" 
                        :key="idx" 
                        :type="tag.type" 
                        plain
                      >
                        {{ tag.text }}
                      </van-tag>
                    </div>
                  </div>
                </div>
              </div>
            </template>
            <van-empty v-else description="今日暂无日程" />
          </div>
        </div>
      </van-pull-refresh>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue';
import { useRouter } from 'vue-router';
import { showToast } from 'vant';
import { Lunar, Solar, HolidayUtil } from 'lunar-javascript';

const router = useRouter();
const now = new Date();
const minDate = new Date(now.getFullYear() - 1, 0, 1);
const maxDate = new Date(now.getFullYear() + 1, 11, 31);
const currentDate = ref(now);
const calendarRef = ref();
const refreshing = ref(false);

const weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];

interface ScheduleEvent {
  id: number;
  startTime: string;
  endTime: string;
  title: string;
  location: string;
  description: string;
  tags: { type: any; text: string }[];
  startHour: number;
  startMinute: number;
  endHour: number;
  endMinute: number;
}

const mockScheduleGroups: ScheduleEvent[][] = [
  [
    {
      id: 1,
      startTime: '09:00',
      endTime: '10:00',
      title: '部门晨会',
      location: '2号会议室',
      description: '周一例行晨会，同步本周工作计划',
      tags: [{ type: 'primary', text: '会议' }, { type: 'warning', text: '重要' }],
      startHour: 9, startMinute: 0, endHour: 10, endMinute: 0
    },
    {
      id: 2,
      startTime: '14:00',
      endTime: '15:30',
      title: '产品需求评审',
      location: '1号会议室',
      description: 'OMS 二期移动端需求评审会',
      tags: [{ type: 'primary', text: '评审' }],
      startHour: 14, startMinute: 0, endHour: 15, endMinute: 30
    },
    {
      id: 3,
      startTime: '16:00',
      endTime: '17:30',
      title: '客户拜访',
      location: '外出',
      description: '拜访意向客户，演示系统功能',
      tags: [{ type: 'success', text: '外勤' }],
      startHour: 16, startMinute: 0, endHour: 17, endMinute: 30
    }
  ],
  [
    {
      id: 4,
      startTime: '10:00',
      endTime: '11:30',
      title: '技术分享会',
      location: '培训室',
      description: '前端新技术分享：Vue 3.3 新特性',
      tags: [{ type: 'primary', text: '培训' }],
      startHour: 10, startMinute: 0, endHour: 11, endMinute: 30
    },
    {
      id: 5,
      startTime: '13:30',
      endTime: '14:00',
      title: '面试',
      location: '3号会议室',
      description: '前端高级工程师岗位初试',
      tags: [{ type: 'danger', text: '招聘' }],
      startHour: 13, startMinute: 30, endHour: 14, endMinute: 0
    },
    {
      id: 6,
      startTime: '15:00',
      endTime: '17:00',
      title: '代码评审',
      location: '工位',
      description: '核心模块代码 Review',
      tags: [{ type: 'primary', text: '研发' }],
      startHour: 15, startMinute: 0, endHour: 17, endMinute: 0
    }
  ],
  [
    {
      id: 7,
      startTime: '09:30',
      endTime: '10:00',
      title: '每日站会',
      location: '办公区',
      description: '同步昨日进度与今日计划',
      tags: [{ type: 'primary', text: '会议' }],
      startHour: 9, startMinute: 30, endHour: 10, endMinute: 0
    },
    {
      id: 8,
      startTime: '14:00',
      endTime: '18:00',
      title: '项目封闭开发',
      location: '封闭开发室',
      description: '攻关核心难题，请勿打扰',
      tags: [{ type: 'danger', text: '攻关' }, { type: 'warning', text: '勿扰' }],
      startHour: 14, startMinute: 0, endHour: 18, endMinute: 0
    }
  ],
  [] // Empty day
];

const currentEvents = ref<ScheduleEvent[]>([]);

const loadEvents = (isRandom = false) => {
  if (isRandom) {
    // 随机选择一组
    const randomIndex = Math.floor(Math.random() * mockScheduleGroups.length);
    currentEvents.value = mockScheduleGroups[randomIndex];
  } else {
    // 根据日期确定性选择
    const date = currentDate.value;
    const index = date.getDate() % mockScheduleGroups.length;
    currentEvents.value = mockScheduleGroups[index];
  }
};

// 监听日期变化
watch(currentDate, () => {
  loadEvents(false);
}, { immediate: true });

const onRefresh = () => {
  setTimeout(() => {
    loadEvents(true);
    showToast('刷新成功');
    refreshing.value = false;
  }, 1000);
};

const onConfirm = (date: Date) => {
  currentDate.value = date;
};

const formatter = (day: any) => {
  const date = day.date;
  const lunar = Lunar.fromDate(date);
  const solar = Solar.fromDate(date);

  // 优先级：节日 > 节气 > 农历
  let bottomInfo = '';
  
  // 公历节日
  const solarFestivals = solar.getFestivals();
  if (solarFestivals.length > 0) {
    bottomInfo = solarFestivals[0];
  }

  // 农历节日
  if (!bottomInfo) {
    const lunarFestivals = lunar.getFestivals();
    if (lunarFestivals.length > 0) {
      bottomInfo = lunarFestivals[0];
    }
  }

  // 节气
  if (!bottomInfo) {
    const jieqi = lunar.getJieQi();
    if (jieqi) {
      bottomInfo = jieqi;
    }
  }

  // 农历日期
  if (!bottomInfo) {
    bottomInfo = lunar.getDayInChinese();
    if (bottomInfo === '初一') {
      bottomInfo = lunar.getMonthInChinese() + '月';
    }
  }
  
  day.bottomInfo = bottomInfo;

  // 法定节假日/调休
  const holiday = HolidayUtil.getHoliday(date.getFullYear(), date.getMonth() + 1, date.getDate());
  if (holiday) {
    if (holiday.isWork()) {
      day.className = 'workday';
      day.topInfo = '班';
    } else {
      day.className = 'holiday';
      day.topInfo = '休';
    }
  }

  return day;
};

const formattedDate = computed(() => {
  const date = currentDate.value;
  const month = date.getMonth() + 1;
  const day = date.getDate();
  const weekDay = weekDays[date.getDay()];
  
  const isToday = date.toDateString() === now.toDateString();
  return `${month}月${day}日 ${weekDay}${isToday ? ' (今天)' : ''}`;
});

const additionalDateInfo = computed(() => {
  const date = currentDate.value;
  const lunar = Lunar.fromDate(date);
  const solar = Solar.fromDate(date);
  
  let info = `农历${lunar.getMonthInChinese()}月${lunar.getDayInChinese()}`;
  
  const festivals: string[] = [];
  
  // 公历节日
  const solarFestivals = solar.getFestivals();
  if (solarFestivals.length > 0) {
    festivals.push(...solarFestivals);
  }
  
  // 农历节日
  const lunarFestivals = lunar.getFestivals();
  if (lunarFestivals.length > 0) {
    festivals.push(...lunarFestivals);
  }
  
  // 节气
  const jieqi = lunar.getJieQi();
  if (jieqi) {
    festivals.push(jieqi);
  }

  // 法定节假日
  const holiday = HolidayUtil.getHoliday(date.getFullYear(), date.getMonth() + 1, date.getDate());
  if (holiday) {
    const name = holiday.getName();
    const status = holiday.isWork() ? '班' : '休';
    // 如果节日名称已经在列表中，就不重复添加，但可以添加休/班标记
    if (!festivals.includes(name)) {
       festivals.push(`${name}(${status})`);
    } else {
       // 找到那个节日并加上状态? 或者简单点直接加在后面
       // 这里简单处理，直接添加带状态的名称，依靠Set去重可能不够（因为带了状态）
       // 所以我们手动过滤一下
       const index = festivals.indexOf(name);
       if (index > -1) {
         festivals[index] = `${name}(${status})`;
       } else {
         festivals.push(`${name}(${status})`);
       }
    }
  }
  
  const uniqueFestivals = [...new Set(festivals)];
  if (uniqueFestivals.length > 0) {
    info += ` · ${uniqueFestivals.join(' ')}`;
  }
  
  return info;
});

const onClickLeft = () => {
  router.back();
};

const onToday = () => {
  const today = new Date();
  calendarRef.value?.reset(today);
  currentDate.value = today;
  showToast('已回到今天');
};

const onAdd = () => {
  showToast('新建日程功能开发中');
};

const getEventTime = (hour: number, minute: number = 0) => {
  const d = new Date(currentDate.value);
  d.setHours(hour, minute, 0, 0);
  return d;
};

const isPast = (time: Date) => {
  return time < new Date();
};
</script>

<style scoped>
.schedule-container {
  min-height: 100vh;
  background-color: #f7f8fa;
}

.fixed-header {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 999;
  background-color: #fff;
  box-shadow: 0 2px 8px rgba(0,0,0,0.02);
}

.nav-btn {
  color: #1989fa;
  font-size: 14px;
}

.custom-calendar {
  height: 320px;
}

.schedule-content {
  padding-top: 430px; /* nav(46) + calendar(320) + header(64) */
}

.timeline-header-bar {
  background: #fff;
  padding: 10px 20px 10px;
  border-top: 1px solid #e1e1e1;
  border-bottom: 1px solid #f7f8fa;
}

.timeline-container {
  background: #fff;
  min-height: calc(100vh - 450px);
  padding: 10px;
}

.timeline-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-left {
  display: flex;
  flex-direction: column;
}

.lunar-info {
  font-size: 12px;
  color: #969799;
  margin-top: 4px;
}

.date-title {
  font-size: 16px;
  font-weight: bold;
  color: #323233;
}

.task-count {
  font-size: 13px;
  color: #969799;
}

.timeline-list {
  position: relative;
}

.timeline-item {
  display: flex;
  margin-bottom: 10px;
}

.timeline-item:last-child {
  margin-bottom: 0;
}

.time-col {
  width: 50px;
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-right: 12px;
  padding-top: 4px;
}

.start-time {
  font-size: 16px;
  font-weight: 500;
  color: #323233;
}

.end-time {
  font-size: 12px;
  color: #969799;
  margin-top: 4px;
}

.content-col {
  flex: 1;
}

.event-card {
  background: #f7f8fa;
  border-radius: 8px;
  padding: 12px;
  border-left: 4px solid #dcdee0;
}

.event-card.active {
  background: #e8f3ff;
  border-left-color: #1989fa;
}

.event-card h3 {
  margin: 0 0 8px 0;
  font-size: 15px;
  color: #323233;
}

.location {
  margin: 0 0 4px 0;
  font-size: 13px;
  color: #646566;
  display: flex;
  align-items: center;
}

.location .van-icon {
  margin-right: 4px;
}

.desc {
  margin: 0 0 8px 0;
  font-size: 13px;
  color: #969799;
}

.tags {
  display: flex;
  gap: 8px;
}

.past .start-time,
.past .end-time {
  opacity: 0.6;
}

.past .event-card {
  opacity: 0.8;
}

:deep(.holiday) .van-calendar__top-info {
  color: #ee0a24;
  background-color: rgba(238, 10, 36, 0.1);
}

:deep(.workday) .van-calendar__top-info {
  color: #333;
  background-color: rgba(0, 0, 0, 0.1);
}
</style>
