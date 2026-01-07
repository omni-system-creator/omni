<template>
  <div class="page-container">
    <div class="action-header">
      <div class="search-area">
        <a-input-search
          v-model:value="searchText"
          placeholder="搜索项目名称/客户名称"
          style="width: 250px"
          @search="onSearch"
        />
        <a-select v-model:value="filterStatus" style="width: 120px; margin-left: 8px" @change="onSearch">
          <a-select-option value="all">所有状态</a-select-option>
          <a-select-option v-for="item in statusOptions" :key="item.value" :value="item.value">
            {{ item.label }}
          </a-select-option>
        </a-select>
      </div>
      <div class="btn-area">
        <a-button type="primary" @click="handleAdd">
          <template #icon><PlusOutlined /></template>
          新增报备
        </a-button>
      </div>
    </div>

    <a-table 
      :columns="columns" 
      :data-source="registrationList" 
      :pagination="pagination"
      :loading="loading"
      @change="handleTableChange"
      row-key="id"
    >
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'status'">
          <a-tag :color="getStatusColor(record.status)">
            {{ getStatusText(record.status) }}
          </a-tag>
        </template>
        <template v-else-if="column.key === 'amount'">
          ¥{{ record.amount.toLocaleString() }}
        </template>
        <template v-else-if="column.key === 'date'">
          {{ dayjs(record.date).format('YYYY-MM-DD') }}
        </template>
        <template v-else-if="column.key === 'action'">
          <a-space>
            <a @click="handleDetail(record)">详情</a>
            <a-divider type="vertical" />
            <a-dropdown>
              <a class="ant-dropdown-link" @click.prevent>
                <MoreOutlined style="font-size: 16px; cursor: pointer; color: #1890ff;" />
              </a>
              <template #overlay>
                <a-menu>
                  <a-menu-item key="edit" @click="handleEdit(record)">
                    编辑
                  </a-menu-item>
                  
                  <template v-if="record.status === 'pending'">
                    <a-menu-divider />
                    <a-menu-item key="approve">
                      <a-popconfirm title="确定通过这条报备吗？" @confirm="handleStatusChange(record, 'approved')">
                        <span style="color: #52c41a">通过</span>
                      </a-popconfirm>
                    </a-menu-item>
                    <a-menu-item key="reject">
                      <a-popconfirm title="确定驳回这条报备吗？" @confirm="handleStatusChange(record, 'rejected')">
                        <span style="color: #ff4d4f">驳回</span>
                      </a-popconfirm>
                    </a-menu-item>
                  </template>

                  <a-menu-divider />
                  <a-menu-item key="delete">
                    <a-popconfirm title="确定要删除这条报备吗？" @confirm="onDelete(record.id)">
                      <span style="color: #ff4d4f">删除</span>
                    </a-popconfirm>
                  </a-menu-item>
                </a-menu>
              </template>
            </a-dropdown>
          </a-space>
        </template>
      </template>
    </a-table>

    <!-- Create/Edit Modal -->
    <a-modal v-model:visible="modalVisible" :title="modalTitle" @ok="handleModalOk">
      <a-form ref="formRef" :model="formData" :rules="rules" :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }">
        <div style="text-align: right; margin-bottom: 16px; padding-right: 48px;">
          <a-button type="dashed" size="small" @click="handleAiFill" :loading="aiLoading">
            <template #icon><ThunderboltOutlined /></template>
            {{ aiLoading ? 'AI生成中(约20秒)...' : 'AI 一键填写示例' }}
          </a-button>
        </div>
        <a-form-item label="项目名称" name="projectName">
          <a-input v-model:value="formData.projectName" placeholder="请输入项目名称" />
        </a-form-item>
        <a-form-item label="客户名称" name="customerName">
          <a-input v-model:value="formData.customerName" placeholder="请输入客户名称" />
        </a-form-item>
        <a-form-item label="联系人" name="contact">
          <a-input v-model:value="formData.contact" placeholder="请输入联系人姓名" />
        </a-form-item>
        <a-form-item label="联系电话" name="phone">
          <a-input v-model:value="formData.phone" placeholder="请输入联系电话" />
        </a-form-item>
        <a-form-item label="预计金额" name="amount">
          <a-input-number 
            v-model:value="formData.amount" 
            style="width: 100%" 
            :formatter="(value: any) => `¥ ${value}`.replace(/\B(?=(\d{3})+(?!\d))/g, ',')"
            :parser="(value: any) => value.replace(/\¥\s?|(,*)/g, '')"
            placeholder="请输入预计金额" 
          />
        </a-form-item>
        <a-form-item label="报备日期" name="date">
          <a-date-picker v-model:value="formData.date" style="width: 100%" value-format="YYYY-MM-DD" />
        </a-form-item>
        <a-form-item label="备注" name="remarks">
          <a-textarea v-model:value="formData.remarks" :rows="3" placeholder="请输入备注信息" />
        </a-form-item>
      </a-form>
    </a-modal>
    <!-- Detail Modal -->
    <a-modal v-model:visible="detailVisible" title="报备详情" :footer="null" width="700px">
      <a-descriptions bordered :column="2">
        <a-descriptions-item label="项目名称" :span="2">{{ currentDetail?.projectName }}</a-descriptions-item>
        <a-descriptions-item label="客户名称">{{ currentDetail?.customerName }}</a-descriptions-item>
        <a-descriptions-item label="报备日期">{{ currentDetail?.date ? dayjs(currentDetail.date).format('YYYY-MM-DD') : '-' }}</a-descriptions-item>
        <a-descriptions-item label="联系人">{{ currentDetail?.contact }}</a-descriptions-item>
        <a-descriptions-item label="联系电话">{{ currentDetail?.phone }}</a-descriptions-item>
        <a-descriptions-item label="预计金额">¥{{ currentDetail?.amount?.toLocaleString() }}</a-descriptions-item>
        <a-descriptions-item label="状态">
          <a-tag :color="getStatusColor(currentDetail?.status || '')">
            {{ getStatusText(currentDetail?.status || '') }}
          </a-tag>
        </a-descriptions-item>
        <a-descriptions-item label="负责人">{{ currentDetail?.owner }}</a-descriptions-item>
        <a-descriptions-item label="创建时间">{{ currentDetail?.createdAt ? dayjs(currentDetail.createdAt).format('YYYY-MM-DD HH:mm:ss') : '-' }}</a-descriptions-item>
        <a-descriptions-item label="备注" :span="2">{{ currentDetail?.remarks || '-' }}</a-descriptions-item>
      </a-descriptions>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, reactive } from 'vue';
import { PlusOutlined, ThunderboltOutlined, MoreOutlined } from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import type { FormInstance } from 'ant-design-vue';
import dayjs from 'dayjs';
import { 
  getRegistrations, 
  createRegistration, 
  updateRegistration, 
  deleteRegistration,
  generateRegistration,
  type SalesRegistrationDto,
  type CreateRegistrationDto
} from '@/api/sales';

const searchText = ref('');
const filterStatus = ref('all');
const loading = ref(false);
const aiLoading = ref(false);
const modalVisible = ref(false);
const detailVisible = ref(false);
const modalTitle = ref('新增报备');
const formRef = ref<FormInstance>();
const editingId = ref<string | null>(null);
const currentDetail = ref<SalesRegistrationDto | null>(null);

const statusOptions = [
  { label: '审核中', value: 'pending' },
  { label: '已通过', value: 'approved' },
  { label: '已驳回', value: 'rejected' },
];

const columns = [
  { title: '项目名称', dataIndex: 'projectName', key: 'projectName' },
  { title: '客户名称', dataIndex: 'customerName', key: 'customerName' },
  { title: '联系人', dataIndex: 'contact', key: 'contact' },
  { title: '联系电话', dataIndex: 'phone', key: 'phone' },
  { title: '预计金额', dataIndex: 'amount', key: 'amount' },
  { title: '报备日期', dataIndex: 'date', key: 'date' },
  { title: '状态', dataIndex: 'status', key: 'status' },
  { title: '负责人', dataIndex: 'owner', key: 'owner' },
  { title: '操作', key: 'action' },
];

const registrationList = ref<SalesRegistrationDto[]>([]);

const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0,
  showSizeChanger: true,
  showQuickJumper: true,
});

const formData = reactive<Partial<CreateRegistrationDto>>({
  projectName: '',
  customerName: '',
  contact: '',
  phone: '',
  amount: undefined,
  date: dayjs().format('YYYY-MM-DD'),
  remarks: ''
});

const rules = {
  projectName: [{ required: true, message: '请输入项目名称', trigger: 'blur' }],
  customerName: [{ required: true, message: '请输入客户名称', trigger: 'blur' }],
  amount: [{ required: true, message: '请输入预计金额', trigger: 'change' }],
  date: [{ required: true, message: '请选择报备日期', trigger: 'change' }],
};

const fetchData = async () => {
  loading.value = true;
  try {
    const res = await getRegistrations({
      searchText: searchText.value,
      status: filterStatus.value === 'all' ? undefined : filterStatus.value,
      page: pagination.current,
      pageSize: pagination.pageSize
    });
    
    // Check if res is the response data structure directly (due to interceptor)
    if (res && (res as any).items) {
      registrationList.value = (res as any).items;
      pagination.total = (res as any).total;
    } else if (Array.isArray(res)) {
       // Fallback if API returns array
       registrationList.value = res as unknown as SalesRegistrationDto[];
    }
  } catch (error) {
    console.error('Failed to fetch registrations', error);
  } finally {
    loading.value = false;
  }
};

onMounted(() => {
  fetchData();
});

const onSearch = () => {
  pagination.current = 1;
  fetchData();
};

const handleTableChange = (pag: any) => {
  pagination.current = pag.current;
  pagination.pageSize = pag.pageSize;
  fetchData();
};

const getStatusColor = (status: string) => {
  switch (status) {
    case 'approved': return 'success';
    case 'rejected': return 'error';
    case 'pending': return 'processing';
    default: return 'default';
  }
};

const getStatusText = (status: string) => {
  const option = statusOptions.find(opt => opt.value === status);
  return option ? option.label : status;
};

const handleDetail = (record: SalesRegistrationDto) => {
  currentDetail.value = record;
  detailVisible.value = true;
};

const handleStatusChange = async (record: SalesRegistrationDto, status: string) => {
  try {
    await updateRegistration(record.id, { status });
    message.success(status === 'approved' ? '已通过' : '已驳回');
    fetchData();
  } catch (error) {
    console.error('Failed to update status', error);
  }
};

const handleAiFill = async () => {
  aiLoading.value = true;
  try {
    const data = await generateRegistration();
    if (data) {
      formData.projectName = data.projectName;
      formData.customerName = data.customerName;
      formData.contact = data.contact;
      formData.phone = data.phone;
      formData.amount = data.amount;
      formData.date = data.date ? dayjs(data.date).format('YYYY-MM-DD') : dayjs().format('YYYY-MM-DD');
      formData.remarks = data.remarks;
      message.success('AI 已为您自动生成示例数据');
    }
  } catch (error) {
    console.error('AI generation failed', error);
    message.error('AI 生成失败，请重试');
  } finally {
    aiLoading.value = false;
  }
};

const handleAdd = () => {
  modalTitle.value = '新增报备';
  editingId.value = null;
  
  // Reset form
  formData.projectName = '';
  formData.customerName = '';
  formData.contact = '';
  formData.phone = '';
  formData.amount = undefined;
  formData.date = dayjs().format('YYYY-MM-DD');
  formData.remarks = '';
  
  modalVisible.value = true;
};

const handleEdit = (record: SalesRegistrationDto) => {
  modalTitle.value = '编辑报备';
  editingId.value = record.id;
  
  // Fill form
  formData.projectName = record.projectName;
  formData.customerName = record.customerName;
  formData.contact = record.contact;
  formData.phone = record.phone;
  formData.amount = record.amount;
  formData.date = record.date ? dayjs(record.date).format('YYYY-MM-DD') : undefined;
  formData.remarks = record.remarks;
  
  modalVisible.value = true;
};

const onDelete = async (id: string) => {
  try {
    await deleteRegistration(id);
    message.success('删除成功');
    fetchData();
  } catch (error) {
    console.error('Delete failed', error);
  }
};

const handleModalOk = () => {
  formRef.value?.validate().then(async () => {
    loading.value = true;
    try {
      if (editingId.value) {
        // Update
        await updateRegistration(editingId.value, formData as any);
        message.success('更新成功');
      } else {
        // Create
        await createRegistration(formData as CreateRegistrationDto);
        message.success('创建成功');
      }
      modalVisible.value = false;
      fetchData();
    } catch (error) {
      console.error('Operation failed', error);
    } finally {
      loading.value = false;
    }
  }).catch(err => {
    console.log('Validation failed:', err);
  });
};
</script>

<style scoped>
.page-container {
  padding: 24px;
  background: #fff;
  min-height: 100%;
}

.action-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 16px;
}

.search-area {
  display: flex;
}

.delete-btn {
  color: #ff4d4f;
}
</style>
