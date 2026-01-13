<template>
  <div class="project-list-container">
    <a-card :bordered="false" class="filter-card">
      <div style="display: flex; justify-content: space-between;">
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
        <div>
          <a-button type="primary" @click="handleCreate">新建项目</a-button>
        </div>
      </div>
    </a-card>

    <a-card :bordered="false" style="margin-top: 16px">
      <a-tabs v-model:activeKey="activeTab" @change="handleTabChange">
        <a-tab-pane key="all" tab="全部项目" />
        <a-tab-pane key="my" tab="我的项目" />
        <a-tab-pane key="participated" tab="我参与的" />
      </a-tabs>

      <a-table :columns="columns" :data-source="filteredProjectList" :pagination="pagination" :loading="loading">
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
            <a @click="viewDetail(record as ProjectListItem)">详情</a>
            <a-divider type="vertical" />
            <a @click="editProject(record as ProjectListItem)">编辑</a>
            <a-divider type="vertical" />
            <a @click="handleClone(record as ProjectListItem)">克隆</a>
          </template>
        </template>
      </a-table>
    </a-card>

    <CloneProjectDialog
      v-model:open="showCloneDialog"
      :initialName="cloningProject?.name"
      :initialManager="cloningProject?.manager"
      :loading="cloneLoading"
      @confirm="onCloneConfirm"
    />

    <ProjectFormDialog
      v-model:open="showFormDialog"
      :project="editingProject"
      :loading="formLoading"
      @confirm="onFormConfirm"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, computed } from 'vue';
import { useRouter } from 'vue-router';
import { message } from 'ant-design-vue';
import { getProjects, getProject, saveProject } from '@/api/project';
import type { ProjectListItem, ProjectFullDto, ProjectInfo } from '@/types/project';
import { useUserStore } from '@/stores/user';
import CloneProjectDialog from './components/CloneProjectDialog.vue';
import ProjectFormDialog from './components/ProjectFormDialog.vue';

const router = useRouter();
const userStore = useUserStore();

const queryParams = reactive({
  status: undefined,
  type: undefined,
  leader: '',
  dateRange: []
});

const activeTab = ref('all');
const loading = ref(false);

const columns: ColumnType[] = [
  { title: '项目名称', dataIndex: 'name', key: 'name' },
  { title: '项目编号', dataIndex: 'code', key: 'code' },
  { title: '类型', dataIndex: 'type', key: 'type' },
  { title: '负责人', dataIndex: 'manager', key: 'manager' },
  { title: '状态', dataIndex: 'status', key: 'status' },
  { title: '进度', dataIndex: 'progress', key: 'progress', width: 200 },
  { title: '计划结束时间', dataIndex: 'plannedEndDate', key: 'plannedEndDate' },
  { title: '操作', key: 'action', width: 150 }
];

const projectList = ref<ProjectListItem[]>([]);

const filteredProjectList = computed(() => {
  const current = userStore.username;
  let list = projectList.value;

  // 1. Visibility Filter: Only manager or members can see
  list = list.filter(p => {
    // If current user is manager
    if (p.manager === current) return true;
    // If current user is in members
    if (p.members && p.members.some(m => m.username === current)) return true;
    // If admin (optional, but good practice)
    if (userStore.isAdmin) return true;
    return false;
  });

  // 2. Tab Filter
  if (activeTab.value === 'my') {
    list = list.filter(p => p.manager === current);
  } else if (activeTab.value === 'participated') {
    list = list.filter(p => p.members && p.members.some(m => m.username === current) && p.manager !== current);
  }

  return list;
});

const pagination = computed(() => ({
  total: filteredProjectList.value.length,
  current: 1,
  pageSize: 10,
  showSizeChanger: true
}));

const fetchData = async () => {
  loading.value = true;
  try {
    const data = await getProjects(queryParams);
    if (data) {
        projectList.value = data.map(item => ({
            ...item,
            plannedEndDate: item.plannedEndDate ? item.plannedEndDate.split('T')[0] : ''
        }));
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

const getStatusColor = (status: string) => {
  const map: any = { ongoing: 'blue', completed: 'green', paused: 'orange' };
  return map[status] || 'default';
};

const getStatusText = (status: string) => {
  const map: any = { ongoing: '进行中', completed: '已完成', paused: '已暂停' };
  return map[status] || status;
};

const handleSearch = () => {
  fetchData();
};

const resetSearch = () => {
  queryParams.status = undefined;
  queryParams.type = undefined;
  queryParams.leader = '';
  handleSearch();
};

const handleTabChange = (activeKey: any) => {
  message.info(`切换到：${activeKey}`);
  handleSearch();
};

const viewDetail = (record: ProjectListItem) => {
  router.push({ name: 'ProjectDetail', params: { id: record.code } });
};

const editProject = async (record: ProjectListItem) => {
  try {
    const full = await getProject(record.code);
    if (full) {
      editingProject.value = full.projectInfo;
      // Keep reference to full object to preserve other fields
      currentFullProject.value = full;
      showFormDialog.value = true;
    }
  } catch (e) {
    message.error('获取项目详情失败');
  }
};

const showFormDialog = ref(false);
const editingProject = ref<ProjectInfo | undefined>(undefined);
const currentFullProject = ref<ProjectFullDto | undefined>(undefined);
const formLoading = ref(false);

const handleCreate = () => {
  editingProject.value = undefined;
  currentFullProject.value = undefined;
  showFormDialog.value = true;
};

const onFormConfirm = async (info: ProjectInfo) => {
  formLoading.value = true;
  try {
    let dto: ProjectFullDto;
    if (currentFullProject.value) {
      // Edit mode: merge with existing
      dto = {
        ...currentFullProject.value,
        projectInfo: info
      };
    } else {
      // Create mode: new structure
      dto = {
        projectInfo: info,
        phases: [],
        swimlanes: [],
        tasks: []
      };
    }
    
    await saveProject(dto);
    message.success(editingProject.value ? '项目更新成功' : '项目创建成功');
    showFormDialog.value = false;
    fetchData();
  } catch (e) {
    message.error('保存失败');
    console.error(e);
  } finally {
    formLoading.value = false;
  }
};

const showCloneDialog = ref(false);
const cloningProject = ref<ProjectListItem | null>(null);
const cloneLoading = ref(false);

const handleClone = (record: ProjectListItem) => {
  cloningProject.value = record;
  showCloneDialog.value = true;
};

const onCloneConfirm = async (values: { code: string, name: string, manager: string, startDate: string }) => {
  if (!cloningProject.value) return;
  cloneLoading.value = true;
  try {
    const fullProject = await getProject(cloningProject.value.code);
    if (!fullProject) {
      message.error('无法获取原项目详情');
      return;
    }

    const newProject = cloneAndShiftProject(fullProject, values);
    await saveProject(newProject);
    message.success('克隆成功');
    showCloneDialog.value = false;
    fetchData();
  } catch (error) {
    console.error(error);
    message.error('克隆失败');
  } finally {
    cloneLoading.value = false;
  }
};

const cloneAndShiftProject = (source: ProjectFullDto, targetInfo: { code: string, name: string, manager: string, startDate: string }) => {
  const newProject = JSON.parse(JSON.stringify(source));
  
  newProject.projectInfo.code = targetInfo.code;
  newProject.projectInfo.name = targetInfo.name;
  newProject.projectInfo.manager = targetInfo.manager;
  
  const oldStartStr = source.projectInfo.plannedStartDate;
  const newStartStr = targetInfo.startDate;
  
  newProject.projectInfo.plannedStartDate = newStartStr;
  
  if (oldStartStr && newStartStr) {
    const oldStart = new Date(oldStartStr);
    const newStart = new Date(newStartStr);
    const diffTime = newStart.getTime() - oldStart.getTime();
    
    const shift = (dateStr: string | undefined) => {
      if (!dateStr) return '';
      const d = new Date(dateStr);
      if (isNaN(d.getTime())) return dateStr;
      const nd = new Date(d.getTime() + diffTime);
      const y = nd.getFullYear();
      const m = String(nd.getMonth() + 1).padStart(2, '0');
      const day = String(nd.getDate()).padStart(2, '0');
      return `${y}-${m}-${day}`;
    };
    
    newProject.projectInfo.plannedEndDate = shift(source.projectInfo.plannedEndDate);
    
    if (newProject.tasks) {
      newProject.tasks.forEach((t: any) => {
        t.startDate = shift(t.startDate);
        t.endDate = shift(t.endDate);
      });
    }
  }
  
  return newProject;
};

</script>

<style scoped>
.project-list-container {
  padding: 16px;
  flex: 1;
}
</style>
