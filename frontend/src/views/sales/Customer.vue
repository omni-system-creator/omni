<template>
  <div class="page-container">
    <div class="action-header">
      <div class="search-area">
        <a-input-search
          v-model:value="searchText"
          placeholder="搜索客户名称/联系人"
          style="width: 250px"
          @search="onSearch"
        />
        <a-select v-model:value="filterStatus" style="width: 120px; margin-left: 8px" @change="onSearch">
          <a-select-option value="all">所有状态</a-select-option>
          <a-select-option v-for="item in statusDictOptions" :key="item.value" :value="item.value">
            {{ item.label }}
          </a-select-option>
        </a-select>
      </div>
      <div class="btn-area">
        <a-button type="primary" @click="handleAdd">
          <template #icon><PlusOutlined /></template>
          新增客户
        </a-button>
        <a-button>
          <template #icon><ExportOutlined /></template>
          导出
        </a-button>
      </div>
    </div>

    <a-table 
      :columns="columns" 
      :data-source="customerList" 
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
        <template v-else-if="column.key === 'action'">
          <a-space>
            <a>详情</a>
            <a @click="handleEdit(record)">编辑</a>
            <a-divider type="vertical" />
            <a class="delete-btn" @click="onDelete(record.id)">删除</a>
          </a-space>
        </template>
      </template>
    </a-table>

    <!-- Create/Edit Modal -->
    <a-modal v-model:visible="modalVisible" :title="modalTitle" @ok="handleModalOk">
      <a-form :model="formData" :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }">
        <a-form-item label="客户名称" required>
          <a-input v-model:value="formData.name" />
        </a-form-item>
        <a-form-item label="行业">
          <a-input v-model:value="formData.industry" />
        </a-form-item>
        <a-form-item label="联系人">
          <a-input v-model:value="formData.contact" />
        </a-form-item>
        <a-form-item label="电话">
          <a-input v-model:value="formData.phone" />
        </a-form-item>
        <a-form-item label="客户等级">
          <a-select v-model:value="formData.level">
            <a-select-option v-for="item in levelDictOptions" :key="item.value" :value="item.value">
              {{ item.label }}
            </a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="状态">
          <a-select v-model:value="formData.status">
            <a-select-option v-for="item in statusDictOptions" :key="item.value" :value="item.value">
              {{ item.label }}
            </a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="负责人">
          <a-input v-model:value="formData.owner" />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, reactive } from 'vue';
import { PlusOutlined, ExportOutlined } from '@ant-design/icons-vue';
import { message, Modal } from 'ant-design-vue';
import { getCustomers, deleteCustomer, createCustomer, updateCustomer, type CustomerDto, type CreateCustomerDto } from '@/api/sales';
import { getDictDataByCode } from '@/api/dict';
import type { DictDataDto } from '@/api/dict';

const searchText = ref('');
const filterStatus = ref('all');
const loading = ref(false);
const customerList = ref<CustomerDto[]>([]);
const statusDictOptions = ref<DictDataDto[]>([]);
const levelDictOptions = ref<DictDataDto[]>([]);

const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0,
  showSizeChanger: true,
  showQuickJumper: true,
});

const columns = [
  { title: '客户名称', dataIndex: 'name', key: 'name' },
  { title: '行业', dataIndex: 'industry', key: 'industry' },
  { title: '联系人', dataIndex: 'contact', key: 'contact' },
  { title: '电话', dataIndex: 'phone', key: 'phone' },
  { title: '客户等级', dataIndex: 'level', key: 'level' },
  { title: '状态', dataIndex: 'status', key: 'status' },
  { title: '负责人', dataIndex: 'owner', key: 'owner' },
  { title: '操作', key: 'action', width: 200 },
];

const loadData = async () => {
  loading.value = true;
  try {
    const res = await getCustomers({
      searchText: searchText.value,
      status: filterStatus.value === 'all' ? undefined : filterStatus.value,
      page: pagination.current,
      pageSize: pagination.pageSize
    });
    customerList.value = res.items;
    pagination.total = res.total;
  } catch (error) {
    console.error(error);
    message.error('获取客户列表失败');
  } finally {
    loading.value = false;
  }
};

onMounted(() => {
  loadStatusDict();
  loadLevelDict();
  loadData();
});

const onSearch = () => {
  pagination.current = 1;
  loadData();
};

const handleTableChange = (pag: any) => {
  pagination.current = pag.current;
  pagination.pageSize = pag.pageSize;
  loadData();
};

const onDelete = (id: string) => {
  Modal.confirm({
    title: '确认删除',
    content: '确定要删除这个客户吗？',
    onOk: async () => {
      try {
        await deleteCustomer(id);
        message.success('删除成功');
        loadData();
      } catch (error) {
        console.error(error);
        message.error('删除失败');
      }
    }
  });
};

// Modal Logic
const modalVisible = ref(false);
const modalTitle = ref('新增客户');
const formData = reactive<CreateCustomerDto>({
  name: '',
  industry: '',
  contact: '',
  phone: '',
  level: 'C级',
  status: 'active',
  owner: ''
});
let currentId = '';

const handleAdd = () => {
  modalTitle.value = '新增客户';
  currentId = '';
  Object.assign(formData, { 
    name: '', 
    industry: '', 
    contact: '', 
    phone: '', 
    level: 'C级', 
    status: 'active', 
    owner: '' 
  });
  modalVisible.value = true;
};

const handleEdit = (record: CustomerDto) => {
  modalTitle.value = '编辑客户';
  currentId = record.id;
  Object.assign(formData, {
    name: record.name,
    industry: record.industry,
    contact: record.contact,
    phone: record.phone,
    level: record.level,
    status: record.status,
    owner: record.owner
  });
  modalVisible.value = true;
};

const handleModalOk = async () => {
  if (!formData.name) {
    message.warning('请输入客户名称');
    return;
  }
  try {
    if (currentId) {
      await updateCustomer(currentId, formData);
      message.success('更新成功');
    } else {
      await createCustomer(formData);
      message.success('创建成功');
    }
    modalVisible.value = false;
    loadData();
  } catch (error) {
    console.error(error);
    message.error('保存失败');
  }
};

const getStatusColor = (status: string) => {
  const map: Record<string, string> = {
    active: 'green',
    potential: 'blue',
    lost: 'red',
  };
  return map[status] || 'default';
};

const getStatusText = (status: string) => {
  const option = statusDictOptions.value.find(item => item.value === status);
  return option ? option.label : status;
};

const loadStatusDict = async () => {
  try {
    statusDictOptions.value = await getDictDataByCode('sales_customer_state');
  } catch (error) {
    console.error('加载客户状态字典失败:', error);
  }
};

const loadLevelDict = async () => {
  try {
    levelDictOptions.value = await getDictDataByCode('sales_customer_level');
  } catch (error) {
    console.error('加载客户等级字典失败:', error);
  }
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

.delete-btn {
  color: #ff4d4f;
}
</style>