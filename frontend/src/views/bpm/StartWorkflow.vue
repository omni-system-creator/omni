<template>
  <div class="start-workflow-container">
    <a-card :bordered="false" class="mb-4">
      <div class="search-wrapper">
        <a-input-search
          v-model:value="searchText"
          placeholder="搜索流程名称..."
          enter-button
          size="large"
          @search="onSearch"
          style="max-width: 600px;"
        />
      </div>
    </a-card>

    <a-card :bordered="false">
      <a-tabs v-model:activeKey="activeCategory">
        <a-tab-pane key="all" tab="全部流程" />
        <a-tab-pane key="project" tab="项目研发" />
        <a-tab-pane key="hr" tab="人事行政" />
        <a-tab-pane key="finance" tab="财务相关" />
        <a-tab-pane key="it" tab="IT运维" />
      </a-tabs>

      <div class="process-list mt-4">
        <div v-if="filteredProcesses.length === 0" class="empty-state">
          <a-empty description="未找到相关流程" />
        </div>
        
        <a-row :gutter="[24, 24]" v-else>
          <a-col :xs="24" :sm="12" :md="8" :lg="6" v-for="proc in filteredProcesses" :key="proc.id">
            <a-card hoverable class="process-card" @click="handleStart(proc)">
              <div class="card-content">
                <div class="icon-wrapper" :style="{ backgroundColor: proc.color }">
                  <component :is="proc.icon" class="proc-icon" />
                </div>
                <div class="text-info">
                  <h4 class="proc-title">{{ proc.name }}</h4>
                  <p class="proc-desc">{{ proc.description }}</p>
                </div>
              </div>
              <template #actions>
                <span class="action-btn"><PlayCircleOutlined /> 发起流程</span>
              </template>
            </a-card>
          </a-col>
        </a-row>
      </div>
    </a-card>

    <!-- 发起流程弹窗 (Mock) -->
    <a-modal v-model:open="visible" :title="`发起: ${currentProcess?.name}`" @ok="handleOk">
      <a-form layout="vertical">
        <a-alert message="这里将加载动态表单组件，根据流程定义渲染不同字段" type="info" show-icon class="mb-4" />
        <a-form-item label="申请标题" required>
          <a-input v-model:value="formData.title" :placeholder="`请输入${currentProcess?.name}标题`" />
        </a-form-item>
        <a-form-item label="紧急程度">
          <a-radio-group v-model:value="formData.priority">
            <a-radio value="low">普通</a-radio>
            <a-radio value="medium">重要</a-radio>
            <a-radio value="high">紧急</a-radio>
          </a-radio-group>
        </a-form-item>
        <a-form-item label="申请原因/备注">
          <a-textarea v-model:value="formData.reason" :rows="4" />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import { 
  PlayCircleOutlined, 
  CodeOutlined, 
  RocketOutlined, 
  AuditOutlined, 
  UsergroupAddOutlined, 
  CarOutlined, 
  PayCircleOutlined, 
  LaptopOutlined, 
  CloudServerOutlined 
} from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';

const searchText = ref('');
const activeCategory = ref('all');
const visible = ref(false);
const currentProcess = ref<any>(null);
const formData = ref({ title: '', priority: 'low', reason: '' });

// Mock Data: Software Company Processes
const processes = [
  // Project & R&D
  { id: 'p1', category: 'project', name: '项目立项申请', description: '新软件项目立项审批流程，需包含MRD/PRD文档。', icon: RocketOutlined, color: '#1890ff' },
  { id: 'p2', category: 'project', name: '生产环境发布', description: '代码上线生产环境审批，需附带测试报告。', icon: CloudServerOutlined, color: '#faad14' },
  { id: 'p3', category: 'project', name: '技术方案评审', description: '重大架构变更或技术选型评审申请。', icon: CodeOutlined, color: '#722ed1' },
  
  // HR
  { id: 'h1', category: 'hr', name: '请假申请', description: '员工年假、事假、病假等申请。', icon: CarOutlined, color: '#52c41a' },
  { id: 'h2', category: 'hr', name: '加班申请', description: '非工作时间加班报备及调休申请。', icon: AuditOutlined, color: '#13c2c2' },
  { id: 'h3', category: 'hr', name: '转正申请', description: '试用期员工转正考核及审批。', icon: UsergroupAddOutlined, color: '#eb2f96' },

  // Finance
  { id: 'f1', category: 'finance', name: '差旅报销', description: '出差费用报销流程，需上传发票。', icon: PayCircleOutlined, color: '#fa8c16' },
  { id: 'f2', category: 'finance', name: '采购申请', description: '软硬件设备及办公用品采购申请。', icon: PayCircleOutlined, color: '#fa541c' },

  // IT
  { id: 'i1', category: 'it', name: 'VPN/权限申请', description: '内部系统访问权限或VPN账号开通。', icon: LaptopOutlined, color: '#2f54eb' },
];

const filteredProcesses = computed(() => {
  return processes.filter(p => {
    const matchCategory = activeCategory.value === 'all' || p.category === activeCategory.value;
    const matchSearch = p.name.includes(searchText.value) || p.description.includes(searchText.value);
    return matchCategory && matchSearch;
  });
});

const onSearch = () => {
  // Triggered automatically by computed
};

const handleStart = (proc: any) => {
  currentProcess.value = proc;
  formData.value = { title: `${proc.name}-${new Date().toLocaleDateString()}`, priority: 'low', reason: '' };
  visible.value = true;
};

const handleOk = () => {
  message.loading('正在提交申请...', 1)
    .then(() => {
      message.success('流程发起成功！请至"我的待办"查看进度。');
      visible.value = false;
    });
};
</script>

<style scoped>
.start-workflow-container {
  padding: 16px;
  flex: 1;
}
.search-wrapper {
  display: flex;
  justify-content: center;
  padding: 20px 0;
}
.process-card {
  border-radius: 8px;
  overflow: hidden;
  transition: all 0.3s;
}
.process-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 4px 12px rgba(0,0,0,0.15);
}
.card-content {
  display: flex;
  padding: 24px;
  align-items: flex-start;
  min-height: 140px;
}
.icon-wrapper {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 16px;
  flex-shrink: 0;
}
.proc-icon {
  font-size: 24px;
  color: #fff;
}
.text-info {
  flex: 1;
}
.proc-title {
  margin: 0 0 8px 0;
  font-size: 16px;
  font-weight: 600;
  color: #1f1f1f;
}
.proc-desc {
  margin: 0;
  color: #8c8c8c;
  font-size: 13px;
  line-height: 1.5;
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
.action-btn {
  color: #1890ff;
  font-weight: 500;
}
.mb-4 {
  margin-bottom: 16px;
}
.mt-4 {
  margin-top: 16px;
}
</style>
