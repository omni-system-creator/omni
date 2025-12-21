<template>
  <div class="page-container">
    <a-card :bordered="false" class="main-card">
      <a-tabs v-model:activeKey="activeTab">
        <a-tab-pane key="pending" tab="我的待办">
          <div class="table-operations">
            <a-space>
              <a-button type="primary" @click="showCreateModal">
                <template #icon><PlusOutlined /></template>
                新建待办
              </a-button>
              <a-input-search
                v-model:value="searchText"
                placeholder="搜索任务标题"
                style="width: 250px"
                @search="onSearch"
              />
              <a-select v-model:value="filterType" style="width: 120px" placeholder="任务类型">
                <a-select-option value="">全部类型</a-select-option>
                <a-select-option value="approval">审批</a-select-option>
                <a-select-option value="task">任务</a-select-option>
                <a-select-option value="notice">通知</a-select-option>
              </a-select>
              <a-date-picker v-model:value="dateFilter" placeholder="截止日期" style="width: 150px" />
            </a-space>
          </div>
          
          <a-table
            :columns="pendingColumns"
            :data-source="filteredPendingData"
            :pagination="{ showSizeChanger: true, showQuickJumper: true }"
            row-key="id"
          >
            <template #bodyCell="{ column, record }">
              <template v-if="column.key === 'priority'">
                <a-tag :color="getPriorityColor(record.priority)">
                  {{ getPriorityText(record.priority) }}
                </a-tag>
              </template>
              <template v-if="column.key === 'type'">
                <a-tag :color="getTypeColor(record.type)">
                  {{ getTypeText(record.type) }}
                </a-tag>
              </template>
              <template v-if="column.key === 'action'">
                <a-button type="link" size="small" @click="handleTask(record)">处理</a-button>
              </template>
            </template>
          </a-table>
        </a-tab-pane>
        
        <a-tab-pane key="completed" tab="我的已办">
          <div class="table-operations">
            <a-space>
              <a-input-search
                v-model:value="searchText"
                placeholder="搜索任务标题"
                style="width: 250px"
                @search="onSearch"
              />
              <a-select v-model:value="filterType" style="width: 120px" placeholder="任务类型">
                <a-select-option value="">全部类型</a-select-option>
                <a-select-option value="approval">审批</a-select-option>
                <a-select-option value="task">任务</a-select-option>
                <a-select-option value="notice">通知</a-select-option>
              </a-select>
            </a-space>
          </div>

          <a-table
            :columns="completedColumns"
            :data-source="completedData"
            :pagination="{ showSizeChanger: true, showQuickJumper: true }"
            row-key="id"
          >
            <template #bodyCell="{ column, record }">
              <template v-if="column.key === 'priority'">
                <a-tag :color="getPriorityColor(record.priority)">
                  {{ getPriorityText(record.priority) }}
                </a-tag>
              </template>
              <template v-if="column.key === 'type'">
                <a-tag :color="getTypeColor(record.type)">
                  {{ getTypeText(record.type) }}
                </a-tag>
              </template>
              <template v-if="column.key === 'status'">
                <a-tag color="success">已完成</a-tag>
              </template>
              <template v-if="column.key === 'action'">
                <a-button type="link" size="small" @click="viewTask(record)">查看</a-button>
              </template>
            </template>
          </a-table>
        </a-tab-pane>

        <a-tab-pane key="subordinates" tab="下属任务">
          <div class="table-operations">
            <a-space>
              <a-button type="primary" @click="showAssignModal">
                <template #icon><UserAddOutlined /></template>
                派发任务
              </a-button>
              <a-select v-model:value="selectedSubordinate" style="width: 150px" placeholder="选择下属">
                <a-select-option value="">全部下属</a-select-option>
                <a-select-option v-for="sub in subordinates" :key="sub.id" :value="sub.id">
                  {{ sub.name }}
                </a-select-option>
              </a-select>
              <a-radio-group v-model:value="subordinateTaskStatus" button-style="solid">
                <a-radio-button value="pending">待办</a-radio-button>
                <a-radio-button value="completed">已办</a-radio-button>
              </a-radio-group>
              <a-input-search
                v-model:value="searchText"
                placeholder="搜索任务标题"
                style="width: 200px"
                @search="onSearch"
              />
            </a-space>
          </div>

          <a-table
            :columns="subordinateColumns"
            :data-source="filteredSubordinateData"
            :pagination="{ showSizeChanger: true, showQuickJumper: true }"
            row-key="id"
          >
            <template #bodyCell="{ column, record }">
              <template v-if="column.key === 'priority'">
                <a-tag :color="getPriorityColor(record.priority)">
                  {{ getPriorityText(record.priority) }}
                </a-tag>
              </template>
              <template v-if="column.key === 'type'">
                <a-tag :color="getTypeColor(record.type)">
                  {{ getTypeText(record.type) }}
                </a-tag>
              </template>
              <template v-if="column.key === 'status'">
                 <a-tag :color="record.status === 'completed' ? 'success' : 'processing'">
                   {{ record.status === 'completed' ? '已完成' : '进行中' }}
                 </a-tag>
              </template>
              <template v-if="column.key === 'action'">
                <a-button type="link" size="small" @click="viewTask(record)">查看</a-button>
              </template>
            </template>
          </a-table>
        </a-tab-pane>
      </a-tabs>
    </a-card>

    <!-- 新建/派发待办模态框 -->
    <a-modal
      v-model:visible="createVisible"
      :title="isAssignMode ? '派发任务' : '新建待办事项'"
      @ok="handleCreateOk"
      @cancel="handleCreateCancel"
    >
      <a-form
        ref="createFormRef"
        :model="createFormState"
        :rules="createRules"
        layout="vertical"
      >
        <a-form-item label="任务标题" name="title">
          <a-input v-model:value="createFormState.title" placeholder="请输入任务标题" />
        </a-form-item>
        <a-form-item v-if="isAssignMode" label="指派给" name="assignee">
          <a-select v-model:value="createFormState.assignee" placeholder="请选择执行人">
             <a-select-option v-for="sub in subordinates" :key="sub.id" :value="sub.id">
               {{ sub.name }}
             </a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="优先级" name="priority">
          <a-select v-model:value="createFormState.priority" placeholder="请选择优先级">
            <a-select-option value="high">高</a-select-option>
            <a-select-option value="medium">中</a-select-option>
            <a-select-option value="low">低</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="截止时间" name="deadline">
          <a-date-picker
            v-model:value="createFormState.deadline"
            show-time
            format="YYYY-MM-DD HH:mm:ss"
            style="width: 100%"
            placeholder="请选择截止时间"
          />
        </a-form-item>
        <a-form-item label="任务描述" name="description">
          <a-textarea
            v-model:value="createFormState.description"
            placeholder="请输入任务描述"
            :rows="4"
          />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, reactive, computed, onMounted } from 'vue';
import { PlusOutlined, UserAddOutlined } from '@ant-design/icons-vue';
import type { FormInstance } from 'ant-design-vue';
import dayjs, { Dayjs } from 'dayjs';
import { useRoute } from 'vue-router';

interface TaskItem {
  id: string;
  title: string;
  type: string;
  priority: string;
  creator: string;
  createTime: string;
  deadline: string;
  finishTime?: string;
  assigneeId?: string;
  assigneeName?: string;
  status?: string;
}

const route = useRoute();
const activeTab = ref('pending');
const searchText = ref('');
const filterType = ref(undefined);
const dateFilter = ref<Dayjs | undefined>(undefined);

// 下属相关
const selectedSubordinate = ref(undefined);
const subordinateTaskStatus = ref('pending');
const isAssignMode = ref(false);

const subordinates = [
  { id: 'sub1', name: '王小二' },
  { id: 'sub2', name: '李小四' },
  { id: 'sub3', name: '张小五' },
];

// 新建任务相关
const createVisible = ref(false);
const createFormRef = ref<FormInstance>();
const createFormState = reactive({
  title: '',
  priority: 'medium',
  deadline: undefined,
  description: '',
  assignee: undefined,
});

const createRules = {
  title: [{ required: true, message: '请输入任务标题', trigger: 'blur' }],
  priority: [{ required: true, message: '请选择优先级', trigger: 'change' }],
  deadline: [{ required: true, message: '请选择截止时间', trigger: 'change' }],
  assignee: [{ required: true, message: '请选择执行人', trigger: 'change' }],
};

const showCreateModal = () => {
  isAssignMode.value = false;
  createFormState.assignee = undefined;
  createVisible.value = true;
};

const showAssignModal = () => {
  isAssignMode.value = true;
  createVisible.value = true;
};

const handleCreateOk = () => {
  createFormRef.value?.validate().then(() => {
    const newTask = {
      id: Date.now().toString(),
      title: createFormState.title,
      type: 'task', // 默认为任务类型
      priority: createFormState.priority,
      creator: '当前用户', // 模拟当前用户
      assigneeId: isAssignMode.value ? createFormState.assignee : 'self',
      assigneeName: isAssignMode.value ? subordinates.find(s => s.id === createFormState.assignee)?.name : '当前用户',
      createTime: dayjs().format('YYYY-MM-DD HH:mm:ss'),
      deadline: createFormState.deadline ? dayjs(createFormState.deadline).format('YYYY-MM-DD HH:mm:ss') : '-',
      status: 'pending'
    };
    
    if (isAssignMode.value) {
      subordinateData.value.unshift(newTask);
      // 切换到下属任务Tab并选中该下属
      activeTab.value = 'subordinates';
      selectedSubordinate.value = createFormState.assignee;
      subordinateTaskStatus.value = 'pending';
    } else {
      pendingData.value.unshift(newTask);
    }
    
    createVisible.value = false;
    resetCreateForm();
  }).catch(error => {
    console.log('Validation failed:', error);
  });
};

const handleCreateCancel = () => {
  createVisible.value = false;
  resetCreateForm();
};

const resetCreateForm = () => {
  createFormState.title = '';
  createFormState.priority = 'medium';
  createFormState.deadline = undefined;
  createFormState.description = '';
  createFormState.assignee = undefined;
  createFormRef.value?.resetFields();
};

// 模拟数据 - 改为 ref 以支持动态添加
const pendingData = ref<TaskItem[]>([
  {
    id: '1',
    title: '销售合同审批 - HT20231201001',
    type: 'approval',
    priority: 'high',
    creator: '张三',
    createTime: '2023-12-01 10:00:00',
    deadline: '2023-12-03 18:00:00',
  },
  {
    id: '2',
    title: '完成项目周报',
    type: 'task',
    priority: 'medium',
    creator: '李四',
    createTime: '2023-12-02 09:30:00',
    deadline: '2023-12-05 17:00:00',
  },
  {
    id: '3',
    title: '系统升级通知',
    type: 'notice',
    priority: 'low',
    creator: '系统管理员',
    createTime: '2023-12-03 14:00:00',
    deadline: '-',
  },
]);

const filteredPendingData = computed(() => {
  let data = pendingData.value;
  
  if (searchText.value) {
    data = data.filter(item => item.title.includes(searchText.value));
  }
  
  if (filterType.value) {
    data = data.filter(item => item.type === filterType.value);
  }

  if (dateFilter.value) {
    const filterDateStr = dateFilter.value.format('YYYY-MM-DD');
    data = data.filter(item => {
      if (item.deadline === '-') return false;
      return item.deadline.startsWith(filterDateStr);
    });
  }
  
  return data;
});

const completedData = ref<TaskItem[]>([
  {
    id: '101',
    title: '采购合同审批 - CG20231125002',
    type: 'approval',
    priority: 'high',
    creator: '王五',
    createTime: '2023-11-25 11:00:00',
    finishTime: '2023-11-26 09:15:00',
    deadline: '-' // Added to satisfy interface
  },
  {
    id: '102',
    title: '部门会议纪要整理',
    type: 'task',
    priority: 'medium',
    creator: '赵六',
    createTime: '2023-11-28 15:00:00',
    finishTime: '2023-11-28 17:30:00',
    deadline: '2023-11-28 18:00:00' // Added
  },
]);

const subordinateData = ref<TaskItem[]>([
  {
    id: '201',
    title: '客户拜访记录整理',
    type: 'task',
    priority: 'high',
    creator: '当前用户',
    assigneeId: 'sub1',
    assigneeName: '王小二',
    createTime: '2023-12-04 09:00:00',
    deadline: '2023-12-06 18:00:00',
    status: 'pending'
  },
  {
    id: '202',
    title: '月度报表统计',
    type: 'task',
    priority: 'medium',
    creator: '当前用户',
    assigneeId: 'sub2',
    assigneeName: '李小四',
    createTime: '2023-12-04 10:30:00',
    deadline: '2023-12-07 12:00:00',
    status: 'pending'
  },
  {
    id: '203',
    title: '合同归档',
    type: 'task',
    priority: 'low',
    creator: '当前用户',
    assigneeId: 'sub1',
    assigneeName: '王小二',
    createTime: '2023-12-01 14:00:00',
    deadline: '2023-12-02 17:00:00',
    finishTime: '2023-12-02 16:30:00',
    status: 'completed'
  }
]);

const filteredSubordinateData = computed(() => {
  let data = subordinateData.value;
  
  // 过滤状态
  data = data.filter(item => item.status === subordinateTaskStatus.value);
  
  // 过滤下属
  if (selectedSubordinate.value) {
    data = data.filter(item => item.assigneeId === selectedSubordinate.value);
  }
  
  // 过滤搜索文本
  if (searchText.value) {
    data = data.filter(item => item.title.includes(searchText.value));
  }
  
  return data;
});

const pendingColumns = [
  { title: '任务标题', dataIndex: 'title', key: 'title', width: 300 },
  { title: '类型', dataIndex: 'type', key: 'type', width: 100 },
  { title: '优先级', dataIndex: 'priority', key: 'priority', width: 100 },
  { title: '发起人', dataIndex: 'creator', key: 'creator', width: 120 },
  { title: '接收时间', dataIndex: 'createTime', key: 'createTime', width: 180 },
  { title: '截止时间', dataIndex: 'deadline', key: 'deadline', width: 180 },
  { title: '操作', key: 'action', width: 100, fixed: 'right' },
];

const completedColumns = [
  { title: '任务标题', dataIndex: 'title', key: 'title', width: 300 },
  { title: '类型', dataIndex: 'type', key: 'type', width: 100 },
  { title: '优先级', dataIndex: 'priority', key: 'priority', width: 100 },
  { title: '发起人', dataIndex: 'creator', key: 'creator', width: 120 },
  { title: '接收时间', dataIndex: 'createTime', key: 'createTime', width: 180 },
  { title: '完成时间', dataIndex: 'finishTime', key: 'finishTime', width: 180 },
  { title: '状态', key: 'status', width: 100 },
  { title: '操作', key: 'action', width: 100, fixed: 'right' },
];

const subordinateColumns = [
  { title: '任务标题', dataIndex: 'title', key: 'title', width: 300 },
  { title: '执行人', dataIndex: 'assigneeName', key: 'assigneeName', width: 120 },
  { title: '类型', dataIndex: 'type', key: 'type', width: 100 },
  { title: '优先级', dataIndex: 'priority', key: 'priority', width: 100 },
  { title: '派发时间', dataIndex: 'createTime', key: 'createTime', width: 180 },
  { title: '截止时间', dataIndex: 'deadline', key: 'deadline', width: 180 },
  { title: '状态', key: 'status', width: 100 },
  { title: '操作', key: 'action', width: 100, fixed: 'right' },
];

const getPriorityColor = (priority: string) => {
  const map: Record<string, string> = {
    high: 'red',
    medium: 'orange',
    low: 'blue',
  };
  return map[priority] || 'default';
};

const getPriorityText = (priority: string) => {
  const map: Record<string, string> = {
    high: '高',
    medium: '中',
    low: '低',
  };
  return map[priority] || priority;
};

const getTypeColor = (type: string) => {
  const map: Record<string, string> = {
    approval: 'purple',
    task: 'cyan',
    notice: 'green',
  };
  return map[type] || 'default';
};

const getTypeText = (type: string) => {
  const map: Record<string, string> = {
    approval: '审批',
    task: '任务',
    notice: '通知',
  };
  return map[type] || type;
};

const onSearch = () => {
  console.log('Searching:', searchText.value);
};

const handleTask = (record: any) => {
  console.log('Handle task:', record);
};

const viewTask = (record: any) => {
  console.log('View task:', record);
};

onMounted(() => {
  if (route.query.date) {
    const dateStr = route.query.date as string;
    dateFilter.value = dayjs(dateStr);
  }
});
</script>

<style scoped>
.page-container {
  padding: 16px;
  height: calc(100vh - 110px); /* Adjust based on layout header/footer */
  display: flex;
  flex-direction: column;
}

.main-card {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

:deep(.ant-card-body) {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  padding: 0 24px 24px 24px;
}

:deep(.ant-tabs) {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

:deep(.ant-tabs-content) {
  flex: 1;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

:deep(.ant-tabs-tabpane) {
  flex: 1;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.table-operations {
  margin-bottom: 16px;
}
</style>
