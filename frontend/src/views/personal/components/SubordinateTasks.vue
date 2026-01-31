<template>
  <div class="subordinate-tasks">
    <smart-table
      table-key="subordinate-tasks"
      :columns="columns"
      :data-source="filteredData"
      :pagination="pagination"
      :loading="loading"
      row-key="id"
      @change="handleTableChange"
    >
      <template #toolbar>
        <a-space>
          <a-button type="primary" @click="emit('dispatch')">
            <template #icon><UserAddOutlined /></template>
            派发任务
          </a-button>
          <!-- 下属筛选暂不支持，后端需要提供接口获取下属列表 -->
          <!-- <a-select v-model:value="selectedSubordinate" style="width: 150px" placeholder="选择下属">
            <a-select-option value="">全部下属</a-select-option>
            <a-select-option v-for="sub in subordinates" :key="sub.id" :value="sub.id">
              {{ sub.name }}
            </a-select-option>
          </a-select> -->
          <!-- 状态筛选暂不支持，后端需要提供筛选 -->
          <!-- <a-radio-group v-model:value="subordinateTaskStatus" button-style="solid">
            <a-radio-button value="pending">待办</a-radio-button>
            <a-radio-button value="completed">已办</a-radio-button>
          </a-radio-group> -->
          <a-input-search
            v-model:value="searchText"
            placeholder="搜索任务标题"
            style="width: 200px"
            @search="onSearch"
          />
          <a-button @click="refresh">刷新</a-button>
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
          <a-button type="link" size="small" @click="emit('view', record)">查看</a-button>
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
        <template v-if="column.key && ['createTime', 'deadline'].includes(column.key as string)">
          {{ (record as any)[column.key] ? dayjs((record as any)[column.key]).format('YYYY-MM-DD HH:mm:ss') : '-' }}
        </template>
      </template>
    </smart-table>
  </div>
</template>

<script lang="ts" setup>
import { ref, computed, onMounted } from 'vue';
import { UserAddOutlined } from '@ant-design/icons-vue';
import { getSubordinateTasks, type TaskItem } from '@/api/task';
import dayjs from 'dayjs';

import SmartTable from '@/components/SmartTable/index.vue';

const emit = defineEmits(['dispatch', 'view']);

const searchText = ref('');
// const selectedSubordinate = ref(undefined);
// const subordinateTaskStatus = ref('pending');
const loading = ref(false);
const subordinateData = ref<TaskItem[]>([]);

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
  { title: '执行人', dataIndex: 'assigneeName', key: 'assigneeName', width: 120 },
  { title: '类型', dataIndex: 'type', key: 'type', width: 100 },
  { title: '优先级', dataIndex: 'priority', key: 'priority', width: 100 },
  { title: '派发时间', dataIndex: 'createTime', key: 'createTime', width: 180 },
  { title: '开始时间', dataIndex: 'startTime', key: 'startTime', width: 180 },
  { title: '截止时间', dataIndex: 'deadline', key: 'deadline', width: 180 },
  { title: '状态', key: 'status', width: 100 },
  { title: '操作', key: 'action', width: 100, fixed: 'right' as const },
];

const fetchData = async () => {
  loading.value = true;
  try {
    const res = await getSubordinateTasks();
    if (res) {
      subordinateData.value = res;
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
  let data = subordinateData.value;
  
  // 暂时只支持前端简单搜索
  
  // 过滤搜索文本
  if (searchText.value) {
    data = data.filter(item => item.title.includes(searchText.value));
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
