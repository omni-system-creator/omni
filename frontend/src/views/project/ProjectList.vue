<template>
  <div class="project-list-container">
    <a-card :bordered="false" class="filter-card">
      <a-form layout="inline" :model="queryParams">
        <a-form-item label="项目状态">
          <a-select v-model:value="queryParams.status" placeholder="全部" style="width: 120px" allow-clear>
            <a-select-option value="ongoing">进行中</a-select-option>
            <a-select-option value="completed">已完成</a-select-option>
            <a-select-option value="paused">已暂停</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="项目类型">
          <a-select v-model:value="queryParams.type" placeholder="全部" style="width: 120px" allow-clear>
            <a-select-option value="dev">研发</a-select-option>
            <a-select-option value="impl">实施</a-select-option>
            <a-select-option value="internal">内部</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="负责人">
          <a-input v-model:value="queryParams.leader" placeholder="请输入负责人" allow-clear />
        </a-form-item>
        <a-form-item>
          <a-button type="primary" @click="handleSearch">查询</a-button>
          <a-button style="margin-left: 8px" @click="resetSearch">重置</a-button>
        </a-form-item>
      </a-form>
    </a-card>

    <a-card :bordered="false" style="margin-top: 16px">
      <a-tabs v-model:activeKey="activeTab" @change="handleTabChange">
        <a-tab-pane key="all" tab="全部项目" />
        <a-tab-pane key="my" tab="我的项目" />
        <a-tab-pane key="participated" tab="我参与的" />
      </a-tabs>

      <a-table :columns="columns" :data-source="projectList" :pagination="pagination" :loading="loading">
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'status'">
            <a-tag :color="getStatusColor(record.status)">
              {{ getStatusText(record.status) }}
            </a-tag>
          </template>
          <template v-if="column.key === 'progress'">
             <a-progress :percent="record.progress" :status="record.status === 'paused' ? 'exception' : (record.progress === 100 ? 'success' : 'active')" />
          </template>
          <template v-if="column.key === 'action'">
            <a @click="viewDetail(record)">详情</a>
            <a-divider type="vertical" />
            <a @click="editProject(record)">编辑</a>
          </template>
        </template>
      </a-table>
    </a-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue';
import { message } from 'ant-design-vue';

const queryParams = reactive({
  status: undefined,
  type: undefined,
  leader: '',
  dateRange: []
});

const activeTab = ref('all');
const loading = ref(false);

const columns = [
  { title: '项目名称', dataIndex: 'name', key: 'name' },
  { title: '项目编号', dataIndex: 'code', key: 'code' },
  { title: '类型', dataIndex: 'type', key: 'type' },
  { title: '负责人', dataIndex: 'leader', key: 'leader' },
  { title: '状态', dataIndex: 'status', key: 'status' },
  { title: '进度', dataIndex: 'progress', key: 'progress', width: 200 },
  { title: '计划结束时间', dataIndex: 'endDate', key: 'endDate' },
  { title: '操作', key: 'action', width: 150 }
];

const projectList = ref([
  { id: 1, name: 'OMS 系统重构', code: 'P2024001', type: '研发', leader: '张三', status: 'ongoing', progress: 65, endDate: '2024-12-31' },
  { id: 2, name: '客户A CRM实施', code: 'P2024002', type: '实施', leader: '李四', status: 'paused', progress: 30, endDate: '2024-10-15' },
  { id: 3, name: '年度审计', code: 'P2024003', type: '内部', leader: '王五', status: 'completed', progress: 100, endDate: '2024-06-30' },
]);

const pagination = {
  total: 100,
  current: 1,
  pageSize: 10,
  showSizeChanger: true
};

const getStatusColor = (status: string) => {
  const map: any = { ongoing: 'blue', completed: 'green', paused: 'orange' };
  return map[status] || 'default';
};

const getStatusText = (status: string) => {
  const map: any = { ongoing: '进行中', completed: '已完成', paused: '已暂停' };
  return map[status] || status;
};

const handleSearch = () => {
  loading.value = true;
  setTimeout(() => loading.value = false, 500);
};

const resetSearch = () => {
  queryParams.status = undefined;
  queryParams.type = undefined;
  queryParams.leader = '';
};

const handleTabChange = (key: string) => {
  message.info(`切换到：${key}`);
  handleSearch();
};

const viewDetail = (record: any) => {
  message.info(`查看项目详情：${record.name}`);
};

const editProject = (record: any) => {
  message.info(`编辑项目：${record.name}`);
};
</script>

<style scoped>
.project-list-container {
  padding: 16px;
  flex: 1;
}
</style>
