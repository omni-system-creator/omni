<template>
  <div class="training-container">
    <!-- Banner -->
    <div class="banner">
      <div class="banner-content">
        <h1>本周技术分享：AI 辅助编程的最佳实践</h1>
        <p>主讲人：张三 (首席架构师) | 时间：周五 16:00 | 地点：大会议室 & Zoom</p>
        <a-button type="primary" size="large" shape="round">立即报名</a-button>
      </div>
    </div>

    <a-row :gutter="24" style="margin-top: 24px">
      <!-- Main Content: Course Library -->
      <a-col :span="16">
        <a-card :bordered="false" title="课程图书馆">
          <template #extra>
            <a-radio-group v-model:value="courseType" button-style="solid">
              <a-radio-button value="all">全部</a-radio-button>
              <a-radio-button value="tech">技术</a-radio-button>
              <a-radio-button value="product">产品</a-radio-button>
              <a-radio-button value="general">通识</a-radio-button>
            </a-radio-group>
          </template>

          <a-list :grid="{ gutter: 16, column: 3 }" :data-source="filteredCourses">
            <template #renderItem="{ item }">
              <a-list-item>
                <a-card hoverable class="course-card">
                  <template #cover>
                    <div class="course-cover" :style="{ background: item.color }">
                      <component :is="item.icon" style="font-size: 48px; color: rgba(255,255,255,0.8)" />
                    </div>
                  </template>
                  <a-card-meta :title="item.title">
                    <template #description>
                      <div class="course-desc">
                        <span><UserOutlined /> {{ item.instructor }}</span>
                        <span><ClockCircleOutlined /> {{ item.duration }}</span>
                      </div>
                      <a-rate :value="item.rating" disabled style="font-size: 12px; margin-top: 8px" />
                    </template>
                  </a-card-meta>
                </a-card>
              </a-list-item>
            </template>
          </a-list>
        </a-card>
      </a-col>

      <!-- Sidebar: My Learning & Schedule -->
      <a-col :span="8">
        <!-- My Progress -->
        <a-card title="我的学习进度" :bordered="false" style="margin-bottom: 24px">
          <div v-for="plan in myPlans" :key="plan.id" class="plan-item">
            <div class="plan-header">
              <span class="plan-title">{{ plan.title }}</span>
              <span class="plan-percent">{{ plan.percent }}%</span>
            </div>
            <a-progress :percent="plan.percent" :status="plan.percent === 100 ? 'success' : 'active'" :stroke-color="plan.color" />
            <div class="plan-footer">截止日期: {{ plan.deadline }}</div>
          </div>
        </a-card>

        <!-- Leaderboard -->
        <a-card title="学习积分排行榜 (Top 5)" :bordered="false">
          <a-list item-layout="horizontal" :data-source="leaderboard">
            <template #renderItem="{ item, index }">
              <a-list-item>
                <a-list-item-meta :description="`积分: ${item.score}`">
                  <template #title>
                    <a href="#">{{ item.name }}</a>
                  </template>
                  <template #avatar>
                    <div class="rank-badge" :class="`rank-${index + 1}`">{{ index + 1 }}</div>
                    <a-avatar :src="item.avatar" style="margin-left: 12px" />
                  </template>
                </a-list-item-meta>
              </a-list-item>
            </template>
          </a-list>
        </a-card>
      </a-col>
    </a-row>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import { 
  UserOutlined, 
  ClockCircleOutlined,
  CodeOutlined,
  RocketOutlined,
  BulbOutlined,
  ReadOutlined
} from '@ant-design/icons-vue';

const courseType = ref('all');

const courses = [
  { id: 1, title: '微服务架构实战', instructor: '张架构', duration: '12小时', rating: 4.8, type: 'tech', color: 'linear-gradient(135deg, #1890ff 0%, #36cfc9 100%)', icon: CodeOutlined },
  { id: 2, title: 'Vue 3 深度解析', instructor: '李前端', duration: '8小时', rating: 4.9, type: 'tech', color: 'linear-gradient(135deg, #52c41a 0%, #95de64 100%)', icon: CodeOutlined },
  { id: 3, title: '高效沟通技巧', instructor: '王HR', duration: '4小时', rating: 4.5, type: 'general', color: 'linear-gradient(135deg, #faad14 0%, #ffc53d 100%)', icon: BulbOutlined },
  { id: 4, title: '产品思维入门', instructor: '赵产品', duration: '6小时', rating: 4.6, type: 'product', color: 'linear-gradient(135deg, #722ed1 0%, #b37feb 100%)', icon: RocketOutlined },
  { id: 5, title: 'Kubernetes运维', instructor: '孙运维', duration: '15小时', rating: 4.7, type: 'tech', color: 'linear-gradient(135deg, #eb2f96 0%, #ffadd2 100%)', icon: CodeOutlined },
  { id: 6, title: '设计心理学', instructor: '周设计', duration: '5小时', rating: 4.4, type: 'product', color: 'linear-gradient(135deg, #f5222d 0%, #ff7875 100%)', icon: ReadOutlined },
];

const filteredCourses = computed(() => {
  if (courseType.value === 'all') return courses;
  return courses.filter(c => c.type === courseType.value);
});

const myPlans = [
  { id: 1, title: '新员工入职培训', percent: 100, deadline: '2023-10-01', color: '#52c41a' },
  { id: 2, title: '安全编码规范', percent: 65, deadline: '2023-12-31', color: '#1890ff' },
  { id: 3, title: 'Golang基础', percent: 30, deadline: '2024-01-15', color: '#722ed1' },
];

const leaderboard = [
  { name: '吴九 (后端组)', score: 1250, avatar: '' },
  { name: '郑十 (前端组)', score: 1180, avatar: '' },
  { name: '陈十一 (测试组)', score: 1050, avatar: '' },
  { name: '刘十二 (产品组)', score: 980, avatar: '' },
  { name: '黄十三 (设计组)', score: 850, avatar: '' },
];
</script>

<style scoped>
.training-container {
  padding: 16px;
  flex: 1;
}

.banner {
  background: linear-gradient(90deg, #10239e 0%, #1890ff 100%);
  border-radius: 8px;
  padding: 40px;
  color: white;
  position: relative;
  overflow: hidden;
}

.banner-content {
  position: relative;
  z-index: 1;
}

.banner h1 {
  color: white;
  font-size: 28px;
  margin-bottom: 16px;
}

.banner p {
  font-size: 16px;
  margin-bottom: 24px;
  opacity: 0.9;
}

.course-card {
  margin-bottom: 16px;
}

.course-cover {
  height: 120px;
  display: flex;
  justify-content: center;
  align-items: center;
}

.course-desc {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  color: #8c8c8c;
}

.plan-item {
  margin-bottom: 24px;
}

.plan-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
}

.plan-footer {
  font-size: 12px;
  color: #8c8c8c;
  margin-top: 4px;
}

.rank-badge {
  width: 20px;
  height: 20px;
  border-radius: 50%;
  background-color: #f0f0f0;
  color: #666;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 12px;
  font-weight: bold;
}

.rank-1 { background-color: #fadb14; color: #fff; }
.rank-2 { background-color: #d9d9d9; color: #fff; }
.rank-3 { background-color: #d48806; color: #fff; }
</style>
