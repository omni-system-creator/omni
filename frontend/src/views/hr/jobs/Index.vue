<template>
  <div class="jobs-container">
    <!-- Header Stats -->
    <a-row :gutter="16" class="stats-row">
      <a-col :span="6">
        <a-card>
          <a-statistic title="招聘中职位" :value="12" suffix="个">
            <template #prefix><SolutionOutlined /></template>
          </a-statistic>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card>
          <a-statistic title="本周新增简历" :value="86" suffix="份">
            <template #prefix><FileTextOutlined /></template>
          </a-statistic>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card>
          <a-statistic title="面试进行中" :value="24" suffix="人">
            <template #prefix><TeamOutlined /></template>
          </a-statistic>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card>
          <a-statistic title="Offer接受率" :value="88" suffix="%">
            <template #prefix><CheckCircleOutlined /></template>
          </a-statistic>
        </a-card>
      </a-col>
    </a-row>

    <!-- Filters & Actions -->
    <div class="actions-bar">
      <a-radio-group v-model:value="filterType" button-style="solid">
        <a-radio-button value="all">全部职位</a-radio-button>
        <a-radio-button value="urgent">急招</a-radio-button>
        <a-radio-button value="rd">研发类</a-radio-button>
        <a-radio-button value="product">产品/设计</a-radio-button>
      </a-radio-group>
      <a-button type="primary">
        <template #icon><PlusOutlined /></template> 发布新职位
      </a-button>
    </div>

    <!-- Job Cards Grid -->
    <a-row :gutter="[16, 16]">
      <a-col :xs="24" :sm="12" :md="8" :lg="6" v-for="job in filteredJobs" :key="job.id">
        <a-card hoverable class="job-card">
          <template #actions>
            <a-tooltip title="查看简历">
              <FileSearchOutlined key="resume" />
            </a-tooltip>
            <a-tooltip title="编辑职位">
              <EditOutlined key="edit" />
            </a-tooltip>
            <a-tooltip title="分享职位">
              <ShareAltOutlined key="share" />
            </a-tooltip>
          </template>
          <a-card-meta>
            <template #title>
              <div class="job-title-row">
                <span class="job-title">{{ job.title }}</span>
                <a-tag color="red" v-if="job.urgent">急招</a-tag>
              </div>
            </template>
            <template #description>
              <div class="job-desc">
                <p class="salary">{{ job.salary }}</p>
                <div class="tags">
                  <a-tag v-for="tag in job.tags" :key="tag">{{ tag }}</a-tag>
                </div>
                <div class="progress-section">
                  <div class="progress-info">
                    <span>招聘进度</span>
                    <span>{{ job.hired }}/{{ job.headcount }}</span>
                  </div>
                  <a-progress :percent="Math.round((job.hired / job.headcount) * 100)" size="small" :status="job.hired >= job.headcount ? 'success' : 'active'" />
                </div>
              </div>
            </template>
          </a-card-meta>
          
          <div class="card-footer-info">
            <span class="dept">{{ job.department }}</span>
            <span class="time">{{ job.postedTime }}</span>
          </div>
        </a-card>
      </a-col>
    </a-row>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import {
  SolutionOutlined,
  FileTextOutlined,
  TeamOutlined,
  CheckCircleOutlined,
  PlusOutlined,
  FileSearchOutlined,
  EditOutlined,
  ShareAltOutlined
} from '@ant-design/icons-vue';

const filterType = ref('all');

const jobs = [
  {
    id: 1,
    title: '高级Java开发工程师',
    department: '研发部 - 支付平台',
    salary: '30k-50k·16薪',
    tags: ['Java', 'Spring Cloud', 'MySQL'],
    urgent: true,
    hired: 1,
    headcount: 3,
    postedTime: '2天前发布',
    category: 'rd'
  },
  {
    id: 2,
    title: '资深前端工程师',
    department: '研发部 - 效率工具',
    salary: '25k-45k·15薪',
    tags: ['Vue3', 'TypeScript', 'Node.js'],
    urgent: false,
    hired: 2,
    headcount: 2,
    postedTime: '5天前发布',
    category: 'rd'
  },
  {
    id: 3,
    title: 'Go语言后端专家',
    department: '研发部 - 基础架构',
    salary: '40k-70k·16薪',
    tags: ['Go', 'K8s', 'Service Mesh'],
    urgent: true,
    hired: 0,
    headcount: 1,
    postedTime: '1周前发布',
    category: 'rd'
  },
  {
    id: 4,
    title: '产品总监',
    department: '产品部',
    salary: '50k-80k·14薪',
    tags: ['B端', 'SaaS', '战略规划'],
    urgent: true,
    hired: 0,
    headcount: 1,
    postedTime: '3天前发布',
    category: 'product'
  },
  {
    id: 5,
    title: 'UI/UX设计师',
    department: '设计部',
    salary: '15k-25k·14薪',
    tags: ['Figma', 'Sketch', 'C4D'],
    urgent: false,
    hired: 1,
    headcount: 2,
    postedTime: '2周前发布',
    category: 'product'
  },
  {
    id: 6,
    title: '测试开发工程师',
    department: '测试部',
    salary: '20k-35k·15薪',
    tags: ['Python', 'Automation', 'CI/CD'],
    urgent: false,
    hired: 3,
    headcount: 5,
    postedTime: '1周前发布',
    category: 'rd'
  },
  {
    id: 7,
    title: '技术运营经理',
    department: '运营部',
    salary: '20k-30k·14薪',
    tags: ['社区运营', '内容创作', '活动策划'],
    urgent: false,
    hired: 0,
    headcount: 1,
    postedTime: '1天前发布',
    category: 'ops'
  },
  {
    id: 8,
    title: 'Android开发工程师',
    department: '研发部 - 移动端',
    salary: '25k-40k·15薪',
    tags: ['Kotlin', 'Flutter', 'Performance'],
    urgent: true,
    hired: 1,
    headcount: 4,
    postedTime: '3天前发布',
    category: 'rd'
  }
];

const filteredJobs = computed(() => {
  if (filterType.value === 'all') return jobs;
  if (filterType.value === 'urgent') return jobs.filter(j => j.urgent);
  if (filterType.value === 'rd') return jobs.filter(j => j.category === 'rd');
  if (filterType.value === 'product') return jobs.filter(j => j.category === 'product');
  return jobs;
});
</script>

<style scoped>
.jobs-container {
  padding: 16px;
  flex: 1;
}

.stats-row {
  margin-bottom: 24px;
}

.actions-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.job-card {
  height: 100%;
}

.job-title-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.job-title {
  font-size: 16px;
  font-weight: bold;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 70%;
}

.salary {
  color: #ff4d4f;
  font-weight: 500;
  margin-bottom: 8px;
}

.tags {
  margin-bottom: 16px;
  height: 24px;
  overflow: hidden;
}

.progress-section {
  margin-top: 16px;
}

.progress-info {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  color: #8c8c8c;
  margin-bottom: 4px;
}

.card-footer-info {
  margin-top: 16px;
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  color: #bfbfbf;
  border-top: 1px solid #f0f0f0;
  padding-top: 12px;
}
</style>
