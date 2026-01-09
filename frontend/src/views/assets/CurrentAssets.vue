<template>
  <div class="current-assets-container">
    <a-card :bordered="false">
      <!-- Search -->
      <a-form layout="inline" :model="searchForm" class="search-form">
        <a-form-item label="名称/厂商">
          <a-input v-model:value="searchForm.keyword" placeholder="请输入" allow-clear />
        </a-form-item>
        <a-form-item label="资产类型">
          <a-select v-model:value="searchForm.type" placeholder="请选择" style="width: 150px" allow-clear>
            <a-select-option value="software">软件授权</a-select-option>
            <a-select-option value="subscription">云服务订阅</a-select-option>
            <a-select-option value="test_device">测试设备</a-select-option>
            <a-select-option value="low_value">低值易耗品</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="状态">
          <a-select v-model:value="searchForm.status" placeholder="请选择" style="width: 120px" allow-clear>
            <a-select-option value="active">正常</a-select-option>
            <a-select-option value="expiring">即将过期</a-select-option>
            <a-select-option value="expired">已过期</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item>
          <a-button type="primary" @click="handleSearch">
            <template #icon><SearchOutlined /></template>
            查询
          </a-button>
        </a-form-item>
      </a-form>

      <!-- Toolbar -->
      <div class="table-operations">
        <a-button type="primary" @click="handleAdd">
          <template #icon><PlusOutlined /></template>
          新增记录
        </a-button>
        <a-button>
          <template #icon><BellOutlined /></template>
          设置提醒
        </a-button>
      </div>

      <!-- Table -->
      <a-table 
        :columns="columns" 
        :data-source="data" 
        :pagination="pagination"
        :loading="loading"
        row-key="id"
      >
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'type'">
            <a-tag color="blue" v-if="record.type === 'software'">软件授权</a-tag>
            <a-tag color="cyan" v-else-if="record.type === 'subscription'">云订阅</a-tag>
            <a-tag color="purple" v-else-if="record.type === 'test_device'">测试设备</a-tag>
            <a-tag v-else>其他</a-tag>
          </template>
          
          <template v-if="column.key === 'expiryDate'">
            <span :style="getExpiryStyle(record.expiryDate)">{{ record.expiryDate }}</span>
          </template>

          <template v-if="column.key === 'cost'">
            ¥ {{ record.cost.toLocaleString() }}
          </template>

          <template v-if="column.key === 'status'">
            <a-badge :status="getStatusBadge(record.status)" :text="getStatusText(record.status)" />
          </template>

          <template v-if="column.key === 'action'">
            <a-space>
              <a @click="handleEdit(record)">编辑</a>
              <a @click="handleRenew(record)" v-if="record.status !== 'active'">续费</a>
              <a-popconfirm title="确定删除吗?" @confirm="handleDelete(record)">
                <a style="color: red">删除</a>
              </a-popconfirm>
            </a-space>
          </template>
        </template>
      </a-table>
    </a-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue';
import { 
  SearchOutlined, 
  PlusOutlined, 
  BellOutlined 
} from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import dayjs from 'dayjs';

const loading = ref(false);

const searchForm = reactive({
  keyword: '',
  type: undefined,
  status: undefined
});

const columns: ColumnType[] = [
  { title: '资产名称', dataIndex: 'name', key: 'name' },
  { title: '类型', dataIndex: 'type', key: 'type', width: 120 },
  { title: '供应商/品牌', dataIndex: 'vendor', key: 'vendor', width: 150 },
  { title: '数量/席位', dataIndex: 'quantity', key: 'quantity', width: 100 },
  { title: '购买日期', dataIndex: 'purchaseDate', key: 'purchaseDate', width: 120 },
  { title: '到期日期', dataIndex: 'expiryDate', key: 'expiryDate', width: 120 },
  { title: '金额(年)', dataIndex: 'cost', key: 'cost', width: 120, align: 'right' },
  { title: '状态', dataIndex: 'status', key: 'status', width: 120 },
  { title: '操作', key: 'action', width: 150, fixed: 'right' }
];

const data = ref([
  {
    id: 1,
    name: 'IntelliJ IDEA All Products Pack',
    type: 'software',
    vendor: 'JetBrains',
    quantity: '20 Seats',
    purchaseDate: '2024-01-01',
    expiryDate: '2025-01-01',
    cost: 120000,
    status: 'active'
  },
  {
    id: 2,
    name: 'Jira Software Cloud Standard',
    type: 'subscription',
    vendor: 'Atlassian',
    quantity: '50 Users',
    purchaseDate: '2024-03-15',
    expiryDate: '2025-03-15',
    cost: 50000,
    status: 'active'
  },
  {
    id: 3,
    name: 'Aliyun ECS Credits',
    type: 'subscription',
    vendor: 'Aliyun',
    quantity: 'Account',
    purchaseDate: '2024-01-01',
    expiryDate: '2024-12-31',
    cost: 200000,
    status: 'expiring'
  },
  {
    id: 4,
    name: 'Google Pixel 8 Pro',
    type: 'test_device',
    vendor: 'Google',
    quantity: '2 Units',
    purchaseDate: '2023-11-01',
    expiryDate: '-',
    cost: 14000,
    status: 'active'
  },
  {
    id: 5,
    name: 'Adobe Creative Cloud',
    type: 'software',
    vendor: 'Adobe',
    quantity: '5 Seats',
    purchaseDate: '2023-05-20',
    expiryDate: '2024-05-20',
    cost: 35000,
    status: 'expired'
  }
]);

const pagination = {
  total: data.value.length,
  pageSize: 10
};

const getStatusBadge = (status: string) => {
  const map: Record<string, any> = {
    active: 'success',
    expiring: 'warning',
    expired: 'error'
  };
  return map[status] || 'default';
};

const getStatusText = (status: string) => {
  const map: Record<string, string> = {
    active: '正常',
    expiring: '即将过期',
    expired: '已过期'
  };
  return map[status] || status;
};

const getExpiryStyle = (dateStr: string) => {
  if (dateStr === '-') return {};
  const days = dayjs(dateStr).diff(dayjs(), 'day');
  if (days < 0) return { color: 'red', fontWeight: 'bold' };
  if (days < 30) return { color: '#faad14', fontWeight: 'bold' };
  return {};
};

const handleSearch = () => {
  loading.value = true;
  setTimeout(() => loading.value = false, 500);
};

const handleAdd = () => message.info('新增流动资产');
const handleEdit = (record: any) => message.info(`编辑: ${record.name}`);
const handleRenew = (record: any) => message.info(`续费: ${record.name}`);
const handleDelete = (record: any) => message.success(`删除成功: ${record.name}`);
</script>

<style scoped>
.current-assets-container {
  padding: 16px;
  background-color: #f0f2f5;
  min-height: 100%;
}
.search-form {
  margin-bottom: 24px;
}
.table-operations {
  margin-bottom: 16px;
}
.table-operations > button {
  margin-right: 8px;
}
</style>