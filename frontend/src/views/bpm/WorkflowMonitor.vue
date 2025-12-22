<template>
  <div class="workflow-monitor-container">
    <a-card :bordered="false">
      <div class="table-page-search-wrapper">
        <a-form layout="inline">
          <a-form-item label="流程实例ID">
            <a-input v-model:value="queryParam.instanceId" placeholder="请输入" />
          </a-form-item>
          <a-form-item label="发起人">
            <a-input v-model:value="queryParam.starter" placeholder="请输入" />
          </a-form-item>
          <a-form-item label="状态">
            <a-select v-model:value="queryParam.status" placeholder="请选择" style="width: 120px">
              <a-select-option value="all">全部</a-select-option>
              <a-select-option value="running">运行中</a-select-option>
              <a-select-option value="suspended">已挂起</a-select-option>
              <a-select-option value="completed">已结束</a-select-option>
            </a-select>
          </a-form-item>
          <a-form-item>
            <a-space>
              <a-button type="primary" @click="handleSearch">查询</a-button>
              <a-button @click="handleReset">重置</a-button>
            </a-space>
          </a-form-item>
        </a-form>
      </div>

      <div class="table-operator my-4">
        <a-space>
          <a-button type="primary" danger :disabled="selectedRowKeys.length === 0">批量终止</a-button>
          <a-button :disabled="selectedRowKeys.length === 0">批量挂起</a-button>
        </a-space>
      </div>

      <a-table 
        :columns="columns" 
        :data-source="data" 
        :pagination="pagination"
        :row-selection="{ selectedRowKeys: selectedRowKeys, onChange: onSelectChange }"
      >
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'status'">
             <a-tag :color="getStatusColor(record.status)">{{ record.statusLabel }}</a-tag>
          </template>
          <template v-if="column.key === 'progress'">
            <a-progress :percent="record.progress" size="small" :status="record.status === 'suspended' ? 'exception' : 'active'" />
          </template>
          <template v-if="column.key === 'action'">
            <a @click="handleDetail(record)">详情</a>
            <a-divider type="vertical" />
            <a @click="handleDiagram(record)">流程图</a>
            <a-divider type="vertical" />
            <a-popconfirm title="确定要挂起该流程吗？" v-if="record.status === 'running'">
              <a class="warning-text">挂起</a>
            </a-popconfirm>
            <a-popconfirm title="确定要激活该流程吗？" v-else-if="record.status === 'suspended'">
              <a class="success-text">激活</a>
            </a-popconfirm>
          </template>
        </template>
      </a-table>
    </a-card>

    <!-- 流程详情抽屉 -->
    <a-drawer
      v-model:open="visible"
      title="流程执行详情"
      width="600"
      placement="right"
    >
      <a-descriptions title="基本信息" :column="2" bordered>
        <a-descriptions-item label="实例ID">{{ currentInstance?.id }}</a-descriptions-item>
        <a-descriptions-item label="流程名称">{{ currentInstance?.name }}</a-descriptions-item>
        <a-descriptions-item label="发起人">{{ currentInstance?.starter }}</a-descriptions-item>
        <a-descriptions-item label="开始时间">{{ currentInstance?.startTime }}</a-descriptions-item>
        <a-descriptions-item label="当前节点" :span="2">
          <a-tag color="blue">{{ currentInstance?.currentNode }}</a-tag>
        </a-descriptions-item>
      </a-descriptions>

      <a-divider />

      <h3>审批记录</h3>
      <a-timeline mode="left" class="mt-4">
        <a-timeline-item color="green">
          <p class="mb-1 font-bold">流程发起</p>
          <p class="text-gray-500 text-sm">{{ currentInstance?.startTime }} - {{ currentInstance?.starter }}</p>
        </a-timeline-item>
        <a-timeline-item color="green">
          <p class="mb-1 font-bold">部门经理审批 - 通过</p>
          <p class="text-gray-500 text-sm">2024-12-20 14:00 - 张经理</p>
          <p class="text-gray-500 text-sm">意见：同意立项，请尽快完善详细方案。</p>
        </a-timeline-item>
        <a-timeline-item color="blue" v-if="currentInstance?.status === 'running'">
          <p class="mb-1 font-bold">CTO审批 - 处理中</p>
          <p class="text-gray-500 text-sm">当前处理人：李总</p>
        </a-timeline-item>
      </a-timeline>
    </a-drawer>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue';
import { message } from 'ant-design-vue';

const queryParam = reactive({
  instanceId: '',
  starter: '',
  status: 'all'
});

const visible = ref(false);
const currentInstance = ref<any>(null);
const selectedRowKeys = ref<string[]>([]);

const columns = [
  { title: '实例ID', dataIndex: 'id', key: 'id' },
  { title: '流程标题', dataIndex: 'title', key: 'title' },
  { title: '流程名称', dataIndex: 'name', key: 'name' },
  { title: '发起人', dataIndex: 'starter', key: 'starter' },
  { title: '当前节点', dataIndex: 'currentNode', key: 'currentNode' },
  { title: '发起时间', dataIndex: 'startTime', key: 'startTime' },
  { title: '进度', key: 'progress', width: 150 },
  { title: '状态', key: 'status', width: 100 },
  { title: '操作', key: 'action', width: 200 }
];

const data = ref([
  { 
    id: 'INST-2024122001', 
    title: 'OMS二期项目立项申请', 
    name: '项目立项申请', 
    starter: '王研发', 
    currentNode: 'CTO审批', 
    startTime: '2024-12-20 09:30', 
    progress: 60,
    status: 'running', 
    statusLabel: '运行中' 
  },
  { 
    id: 'INST-2024122105', 
    title: '李四-年假申请(3天)', 
    name: '请假申请', 
    starter: '李四', 
    currentNode: 'HR备案', 
    startTime: '2024-12-21 10:00', 
    progress: 80,
    status: 'running', 
    statusLabel: '运行中' 
  },
  { 
    id: 'INST-2024121902', 
    title: '服务器扩容采购', 
    name: '采购申请', 
    starter: '赵运维', 
    currentNode: '财务审批', 
    startTime: '2024-12-19 15:20', 
    progress: 40,
    status: 'suspended', 
    statusLabel: '已挂起' 
  },
  { 
    id: 'INST-2024121801', 
    title: '前端框架升级方案评审', 
    name: '技术方案评审', 
    starter: '钱架构', 
    currentNode: '结束', 
    startTime: '2024-12-18 11:00', 
    progress: 100,
    status: 'completed', 
    statusLabel: '已结束' 
  },
  { 
    id: 'INST-2024122203', 
    title: '张三-加班申请', 
    name: '加班申请', 
    starter: '张三', 
    currentNode: '部门经理审批', 
    startTime: '2024-12-22 18:00', 
    progress: 20,
    status: 'running', 
    statusLabel: '运行中' 
  }
]);

const pagination = {
  total: 50,
  current: 1,
  pageSize: 10
};

const getStatusColor = (status: string) => {
  switch (status) {
    case 'running': return 'processing';
    case 'suspended': return 'warning';
    case 'completed': return 'success';
    default: return 'default';
  }
};

const onSelectChange = (keys: string[]) => {
  selectedRowKeys.value = keys;
};

const handleSearch = () => {
  message.loading('查询中...');
};

const handleReset = () => {
  queryParam.instanceId = '';
  queryParam.starter = '';
  queryParam.status = 'all';
};

const handleDetail = (record: any) => {
  currentInstance.value = record;
  visible.value = true;
};

const handleDiagram = (record: any) => {
  message.info(`查看流程图: ${record.title}`);
};
</script>

<style scoped>
.workflow-monitor-container {
  padding: 16px;
  flex: 1;
}
.my-4 {
  margin-top: 16px;
  margin-bottom: 16px;
}
.warning-text {
  color: #faad14;
}
.success-text {
  color: #52c41a;
}
.mt-4 {
  margin-top: 16px;
}
.mb-1 {
  margin-bottom: 4px;
}
.font-bold {
  font-weight: bold;
}
.text-gray-500 {
  color: #8c8c8c;
}
.text-sm {
  font-size: 12px;
}
</style>
