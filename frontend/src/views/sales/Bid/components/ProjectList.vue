<template>
  <div class="project-list">
    <a-card :bordered="false">
      <template #title>
        <a-form layout="inline" :model="searchForm" @submit="handleSearch">
          <a-form-item label="项目名称/编号">
            <a-input v-model:value="searchForm.keyword" placeholder="请输入" allow-clear />
          </a-form-item>
          <a-form-item label="地区">
            <a-select v-model:value="searchForm.region" placeholder="选择地区" style="width: 120px" allow-clear>
              <a-select-option value="华东">华东</a-select-option>
              <a-select-option value="华北">华北</a-select-option>
              <a-select-option value="华南">华南</a-select-option>
              <a-select-option value="西北">西北</a-select-option>
              <a-select-option value="西南">西南</a-select-option>
            </a-select>
          </a-form-item>
          <a-form-item label="类型">
            <a-select v-model:value="searchForm.type" placeholder="项目类型" style="width: 150px" allow-clear>
              <a-select-option value="软件开发">软件开发</a-select-option>
              <a-select-option value="硬件集成">硬件集成</a-select-option>
              <a-select-option value="运维服务">运维服务</a-select-option>
            </a-select>
          </a-form-item>
          <a-form-item>
            <a-button type="primary" @click="handleSearch">查询</a-button>
            <a-button style="margin-left: 8px" @click="handleReset">重置</a-button>
          </a-form-item>
        </a-form>
      </template>
      <template #extra>
        <a-button type="primary" @click="handleCreate">
          <template #icon><PlusOutlined /></template>
          新建项目
        </a-button>
      </template>

      <a-table 
        :columns="columns" 
        :data-source="data" 
        row-key="id"
        :loading="loading"
        :pagination="pagination"
        @change="handleTableChange"
      >
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'action'">
             <a @click="handleEdit(record)">详情/管理</a>
             <a-divider type="vertical" />
             <a-popconfirm title="确定删除该项目吗？" @confirm="handleDelete(record.id)">
               <a class="text-danger">删除</a>
             </a-popconfirm>
          </template>
          <template v-else-if="column.key === 'status'">
             <a-tag :color="record.status === '进行中' ? 'processing' : (record.status === '已结束' ? 'default' : 'success')">
                {{ record.status }}
             </a-tag>
          </template>
        </template>
      </a-table>
    </a-card>

    <!-- Create Modal -->
    <DraggableModal
      v-model:visible="createVisible"
      title="新建招标项目"
      @ok="handleCreateSubmit"
      @cancel="handleCreateCancel"
      :confirmLoading="createLoading"
      :footer="true"
      width="700px"
    >
      <BidProjectForm
        ref="createFormRef"
        v-model="createForm"
      />
    </DraggableModal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { PlusOutlined } from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import dayjs from 'dayjs';
import DraggableModal from '@/components/DraggableModal.vue';
import BidProjectForm from './BidProjectForm.vue';
import { getBidProjects, deleteBidProject, createBidProject, type BidProjectDto, type CreateBidProjectDto } from '@/api/sales';

const router = useRouter();
const loading = ref(false);
const data = ref<BidProjectDto[]>([]);

// Create Modal State
const createVisible = ref(false);
const createLoading = ref(false);
const createFormRef = ref();
const createForm = reactive<CreateBidProjectDto>({
  code: '',
  name: '',
  customer: '',
  region: undefined,
  type: undefined,
  budget: '',
  bidTime: undefined,
  leader: '',
  status: '进行中',
  description: ''
});

const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0,
  showSizeChanger: true,
  showQuickJumper: true,
});

const searchForm = reactive({
  keyword: '',
  region: undefined as string | undefined,
  type: undefined as string | undefined,
});

const columns = [
  { title: '项目编号', dataIndex: 'code', key: 'code' },
  { title: '项目名称', dataIndex: 'name', key: 'name' },
  { title: '地区', dataIndex: 'region', key: 'region' },
  { title: '类型', dataIndex: 'type', key: 'type' },
  { 
    title: '开标时间', 
    dataIndex: 'bidTime', 
    key: 'bidTime',
    customRender: ({ text }: { text: string }) => text ? dayjs(text).format('YYYY-MM-DD') : '-'
  },
  { title: '状态', dataIndex: 'status', key: 'status' },
  { title: '操作', key: 'action', width: 150 }
];

const fetchData = async () => {
  loading.value = true;
  try {
    const res = await getBidProjects({
      page: pagination.current,
      pageSize: pagination.pageSize,
      keyword: searchForm.keyword,
      region: searchForm.region,
      type: searchForm.type,
    });
    data.value = res.items;
    pagination.total = res.total;
  } catch (error) {
    console.error(error);
    message.error('获取项目列表失败');
  } finally {
    loading.value = false;
  }
};

const handleTableChange = (pag: any) => {
  pagination.current = pag.current;
  pagination.pageSize = pag.pageSize;
  fetchData();
};

const handleSearch = () => {
  pagination.current = 1;
  fetchData();
};

const handleReset = () => {
  searchForm.keyword = '';
  searchForm.region = undefined;
  searchForm.type = undefined;
  handleSearch();
};

const handleCreate = () => {
  createVisible.value = true;
  // Reset form
  Object.assign(createForm, {
    code: `BID-${dayjs().format('YYYY')}-${Math.floor(Math.random() * 1000).toString().padStart(3, '0')}`, // Auto-generate simple code
    name: '',
    customer: '',
    region: undefined,
    type: undefined,
    budget: '',
    bidTime: undefined,
    leader: '',
    status: '进行中',
    description: ''
  });
};

const handleCreateCancel = () => {
  createVisible.value = false;
  createFormRef.value?.resetFields();
};

const handleCreateSubmit = async () => {
  try {
    await createFormRef.value.validate();
    createLoading.value = true;
    
    const submitData = {
      ...createForm,
      bidTime: createForm.bidTime ? dayjs(createForm.bidTime).toISOString() : undefined
    };
    
    await createBidProject(submitData);
    message.success('创建成功');
    createVisible.value = false;
    fetchData(); // Refresh list
  } catch (error) {
    console.error(error);
    // Validation error or API error
  } finally {
    createLoading.value = false;
  }
};

const handleEdit = (record: any) => {
  router.push({ name: 'BidDetail', params: { id: record.id } });
};

const handleDelete = async (id: string) => {
  try {
    await deleteBidProject(id);
    message.success('删除成功');
    fetchData();
  } catch (error) {
    console.error(error);
    message.error('删除失败');
  }
};

onMounted(() => {
  fetchData();
});
</script>

<style scoped>
.text-danger {
  color: #ff4d4f;
}
</style>
