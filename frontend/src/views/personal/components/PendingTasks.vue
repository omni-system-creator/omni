<template>
  <div class="pending-tasks">
    <smart-table
      table-key="pending-tasks"
      :columns="columns"
      :data-source="filteredData"
      :pagination="pagination"
      :loading="loading"
      row-key="id"
      @change="handleTableChange"
    >
      <template #toolbar>
        <a-space>
          <a-button type="primary" @click="emit('create')">
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
      </template>

      <template #bodyCell="{ column, record, index }">
        <template v-if="column.key === 'index'">
          {{ (pagination.current - 1) * pagination.pageSize + index + 1 }}
        </template>
        <template v-if="column.key === 'priority'">
          <a-tag :color="getPriorityColor(record.priority)">
            {{ getPriorityText(record.priority) }}
          </a-tag>
        </template>
        <template v-if="column.key === 'creatorName'">
          <a-space>
            <a-avatar :src="record.creatorAvatar" :size="24">{{ record.creatorName?.charAt(0) }}</a-avatar>
            {{ record.creatorName }}
          </a-space>
        </template>
        <template v-if="column.key === 'assigneeName'">
          <a-space>
            <a-avatar :src="record.assigneeAvatar" :size="24">{{ record.assigneeName?.charAt(0) }}</a-avatar>
            {{ record.assigneeName }}
          </a-space>
        </template>
        <template v-if="column.key === 'type'">
          <a-tag :color="getTypeColor(record.type)">
            {{ getTypeText(record.type) }}
          </a-tag>
        </template>
        <template v-if="column.key === 'action'">
          <a-button type="link" size="small" @click="emit('process', record)">详情</a-button>
        </template>
        <template v-if="column.key === 'members'">
          <div v-if="record.members && record.members.length > 0">
            <a-space v-if="record.members.length < 3">
              <span v-for="member in record.members" :key="member.userId">
                <a-avatar :src="member.avatar" size="small" style="background-color: #1890ff; margin-right: 4px">
                  {{ member.name?.[0]?.toUpperCase() || 'M' }}
                </a-avatar>
                {{ member.name }}
              </span>
            </a-space>
            <a-space v-else>
              <span v-for="member in record.members.slice(0, 2)" :key="member.userId">
                <a-avatar :src="member.avatar" size="small" style="background-color: #1890ff; margin-right: 4px">
                  {{ member.name?.[0]?.toUpperCase() || 'M' }}
                </a-avatar>
                {{ member.name }}
              </span>
              <span>等{{ record.members.length }}人</span>
            </a-space>
          </div>
        </template>
        <template v-if="column.key && ['createTime', 'startTime', 'deadline'].includes(column.key as string)">
          {{ (record as any)[column.key] ? dayjs((record as any)[column.key]).format('YYYY-MM-DD HH:mm:ss') : '-' }}
        </template>
      </template>
    </smart-table>
  </div>
</template>

<script lang="ts" setup>
import { ref, computed, onMounted } from 'vue';
import { PlusOutlined } from '@ant-design/icons-vue';
import dayjs, { type Dayjs } from 'dayjs';
import SmartTable from '@/components/SmartTable/index.vue';
import { getPendingTasks, type TaskItem } from '@/api/task';

const emit = defineEmits(['create', 'process']);

const searchText = ref('');
const filterType = ref(undefined);
const dateFilter = ref<Dayjs | undefined>(undefined);
const loading = ref(false);

const pagination = ref({
  current: 1,
  pageSize: 10,
  showSizeChanger: true,
  showQuickJumper: true
});

const handleTableChange = (pag: any) => {
  pagination.value = { ...pagination.value, ...pag };
};

const columns = [
  { title: '序号', key: 'index', width: 60, align: 'center' as const, fixed: 'left' as const },
  { title: '任务标题', dataIndex: 'title', key: 'title', width: 300 },
  { title: '类型', dataIndex: 'type', key: 'type', width: 100 },
  { title: '优先级', dataIndex: 'priority', key: 'priority', width: 100 },
  { title: '创建者', dataIndex: 'creatorName', key: 'creatorName', width: 120 },
  { title: '负责人', dataIndex: 'assigneeName', key: 'assigneeName', width: 120 },
  { title: '成员', dataIndex: 'members', key: 'members', width: 150 },
  { title: '接收时间', dataIndex: 'createTime', key: 'createTime', width: 180 },
  { title: '开始时间', dataIndex: 'startTime', key: 'startTime', width: 180 },
  { title: '截止时间', dataIndex: 'deadline', key: 'deadline', width: 180 },
  { title: '操作', key: 'action', width: 100, fixed: 'right' as const },
];

const pendingData = ref<TaskItem[]>([]);

const fetchData = async () => {
  loading.value = true;
  try {
    const res = await getPendingTasks();
    if (res) {
        // Map backend fields if necessary, but DTO matches TaskItem mostly
        // Backend returns "creatorName", frontend used "creator". 
        // DTO has CreatorName.
        pendingData.value = res;
    }
  } catch (error) {
    console.error(error);
  } finally {
    loading.value = false;
  }
};

onMounted(() => {
  fetchData();
});

const refresh = () => {
  fetchData();
};

defineExpose({
  refresh
});

const filteredData = computed(() => {
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
      if (!item.deadline || item.deadline === '-') return false;
      return item.deadline.startsWith(filterDateStr);
    });
  }
  
  return data;
});

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
  // 搜索逻辑
};
</script>

<style scoped>
.table-operations {
  margin-bottom: 16px;
}
</style>
