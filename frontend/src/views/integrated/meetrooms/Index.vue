<template>
  <div class="meet-container">
    <!-- Filter & Actions -->
    <a-card :bordered="false" class="filter-card">
      <a-form layout="inline">
        <a-form-item label="所属区域">
          <a-select v-model:value="query.area" style="width: 150px">
            <a-select-option value="all">全部区域</a-select-option>
            <a-select-option value="hq">总部大楼</a-select-option>
            <a-select-option value="rd">研发中心</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="日期">
          <a-date-picker v-model:value="query.date" />
        </a-form-item>
        <a-form-item label="设备需求">
          <a-select v-model:value="query.equipment" mode="multiple" style="width: 200px" placeholder="选择设备">
            <a-select-option value="projector">投影仪</a-select-option>
            <a-select-option value="video">视频会议系统</a-select-option>
            <a-select-option value="board">电子白板</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item>
          <a-button type="primary" html-type="submit">
            <template #icon><SearchOutlined /></template> 查询
          </a-button>
        </a-form-item>
        <a-form-item style="margin-left: auto;">
           <a-button type="primary" size="large">
            <template #icon><PlusOutlined /></template> 发起会议预定
          </a-button>
        </a-form-item>
      </a-form>
    </a-card>

    <a-row :gutter="16" style="margin-top: 16px;">
      <!-- Room List & Status -->
      <a-col :span="17">
        <a-list :grid="{ gutter: 16, column: 2 }" :data-source="rooms">
          <template #renderItem="{ item }">
            <a-list-item>
              <a-card hoverable class="room-card">
                <template #title>
                  <a-space>
                    <span style="font-weight: bold">{{ item.name }}</span>
                    <a-tag color="blue">{{ item.capacity }}人</a-tag>
                    <a-tag v-if="item.status === 'free'" color="success">空闲</a-tag>
                    <a-tag v-else color="processing">使用中</a-tag>
                  </a-space>
                </template>
                <template #extra>
                  <a-button type="link" size="small">详情</a-button>
                </template>
                
                <div class="room-content">
                  <div class="room-image">
                    <!-- Placeholder for room image -->
                    <div style="width: 100%; height: 120px; background: #e6f7ff; display: flex; align-items: center; justify-content: center; color: #1890ff; border-radius: 4px;">
                      <DesktopOutlined style="font-size: 48px; opacity: 0.5" />
                    </div>
                  </div>
                  <div class="room-info">
                    <p><EnvironmentOutlined /> {{ item.location }}</p>
                    <p>
                      <AppstoreOutlined /> 
                      <a-tag v-for="eq in item.equipment" :key="eq" style="margin-right: 4px">{{ eq }}</a-tag>
                    </p>
                    <div class="next-meeting">
                      <p style="color: #8c8c8c; margin-bottom: 4px;">下场会议:</p>
                      <p v-if="item.nextMeeting" style="font-weight: 500;">{{ item.nextMeeting.time }} | {{ item.nextMeeting.title }}</p>
                      <p v-else style="color: #bfbfbf; font-style: italic;">暂无会议预约</p>
                    </div>
                  </div>
                </div>

                <template #actions>
                  <span key="schedule"><CalendarOutlined /> 查看日程</span>
                  <span key="book" style="color: #1890ff">立即预定</span>
                </template>
              </a-card>
            </a-list-item>
          </template>
        </a-list>
      </a-col>

      <!-- Sidebar: My Meetings & Approvals -->
      <a-col :span="7">
        <a-card title="待办审批" :bordered="false" style="margin-bottom: 24px">
          <a-list item-layout="horizontal" :data-source="approvals">
            <template #renderItem="{ item }">
              <a-list-item>
                <template #actions>
                  <a href="#">审批</a>
                </template>
                <a-list-item-meta :description="`${item.dept} - ${item.applicant}`">
                  <template #title>
                    {{ item.room }} ({{ item.date }})
                  </template>
                  <template #avatar>
                     <a-avatar style="background-color: #faad14">待</a-avatar>
                  </template>
                </a-list-item-meta>
              </a-list-item>
            </template>
          </a-list>
        </a-card>

        <a-card title="今日会议安排" :bordered="false">
          <a-timeline>
            <a-timeline-item color="green">
              <p>09:00 - 10:00 部门早会</p>
              <p style="color: #999; font-size: 12px">会议室 201</p>
            </a-timeline-item>
            <a-timeline-item color="blue">
              <p>14:00 - 16:00 产品评审会</p>
              <p style="color: #999; font-size: 12px">大会议室 A (需视频连线)</p>
            </a-timeline-item>
            <a-timeline-item color="gray">
              <p>16:30 - 17:30 临时沟通</p>
              <p style="color: #999; font-size: 12px">洽谈室 B</p>
            </a-timeline-item>
          </a-timeline>
        </a-card>
      </a-col>
    </a-row>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import {
  SearchOutlined,
  PlusOutlined,
  EnvironmentOutlined,
  AppstoreOutlined,
  CalendarOutlined,
  DesktopOutlined
} from '@ant-design/icons-vue';

const query = ref({
  area: 'all',
  date: null,
  equipment: []
});

const rooms = [
  {
    id: 1,
    name: '第一会议室',
    capacity: 20,
    status: 'free',
    location: '总部大楼 3F-301',
    equipment: ['投影仪', '白板'],
    nextMeeting: { time: '14:00', title: 'Q3 财务汇报' }
  },
  {
    id: 2,
    name: '多功能报告厅',
    capacity: 200,
    status: 'busy',
    location: '总部大楼 1F',
    equipment: ['LED大屏', '音响系统', '同传设备'],
    nextMeeting: null
  },
  {
    id: 3,
    name: '视频会议室 A',
    capacity: 10,
    status: 'free',
    location: '研发中心 5F',
    equipment: ['Polycom终端', '4K显示器'],
    nextMeeting: { time: '15:30', title: '上海分公司连线' }
  },
  {
    id: 4,
    name: 'VIP 接待室',
    capacity: 8,
    status: 'free',
    location: '总部大楼 20F',
    equipment: ['茶水服务', '高级沙发'],
    nextMeeting: null
  }
];

const approvals = [
  { id: 1, room: '多功能报告厅', date: '2023-10-25', dept: '市场部', applicant: '张经理' },
  { id: 2, room: '视频会议室 A', date: '2023-10-26', dept: '技术部', applicant: '李工' },
];
</script>

<style scoped>
.meet-container {
  padding: 16px;
  flex: 1;
}
.room-card {
  height: 100%;
  display: flex;
  flex-direction: column;
}
:deep(.room-card .ant-card-body) {
  flex: 1;
  display: flex;
  flex-direction: column;
}
.room-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 16px;
}
.room-info {
  flex: 1;
  display: flex;
  flex-direction: column;
}
.room-info p {
  margin-bottom: 8px;
  color: #595959;
}
.next-meeting {
  margin-top: auto;
  padding: 8px;
  background-color: #f5f5f5;
  border-radius: 4px;
  font-size: 12px;
}

:deep(.ant-list-item) {
  padding: 0 !important;
}
</style>
