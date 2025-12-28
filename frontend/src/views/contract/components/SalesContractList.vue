<template>
  <div class="sales-contract-list">
    <a-table
      :columns="columns"
      :data-source="data"
      :pagination="pagination"
      :scroll="{ x: 'max-content', y: true }"
      @change="handleTableChange"
    >
      <template #customFilterDropdown="{ setSelectedKeys, selectedKeys, confirm, clearFilters, column }">
        <div style="padding: 8px">
          <template v-if="column.key === 'totalAmount' || column.key === 'receivedAmount'">
            <div style="margin-bottom: 8px; display: flex; align-items: center">
              <a-input-number
                :value="selectedKeys[0]"
                placeholder="Min"
                style="width: 100px; text-align: center"
                @change="(val: any) => setSelectedKeys([val, selectedKeys[1]])"
            />
            <span style="padding: 0 4px">~</span>
            <a-input-number
              :value="selectedKeys[1]"
              placeholder="Max"
              style="width: 100px; text-align: center"
              @change="(val: any) => setSelectedKeys([selectedKeys[0], val])"
            />
            </div>
          </template>
          <template v-else-if="column.key === 'signDate' || column.key === 'latestCollectionDate'">
            <a-range-picker
              :value="selectedKeys"
              style="margin-bottom: 8px; display: block; width: 250px"
              @change="(_dates: any, dateStrings: any) => setSelectedKeys(dateStrings)"
            />
          </template>
          <template v-else>
            <a-input
              ref="searchInput"
              :placeholder="`搜索 ${column.title}`"
              :value="selectedKeys[0]"
              style="width: 188px; margin-bottom: 8px; display: block"
              @change="(e: any) => setSelectedKeys(e.target.value ? [e.target.value] : [])"
              @pressEnter="handleSearch(selectedKeys, confirm, column.dataIndex)"
            />
          </template>
          <a-space>
            <a-button
              type="primary"
              size="small"
              style="width: 90px"
              @click="handleSearch(selectedKeys, confirm, column.dataIndex)"
            >
              <template #icon><SearchOutlined /></template>
              搜索
            </a-button>
            <a-button size="small" style="width: 90px" @click="handleReset(clearFilters)">
              重置
            </a-button>
          </a-space>
        </div>
      </template>
      <template #customFilterIcon="{ filtered }">
        <filter-filled :style="{ color: filtered ? '#108ee9' : undefined }" />
      </template>
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'status'">
          <a-tag :color="getStatusColor(record.status)">
            {{ getStatusText(record.status) }}
          </a-tag>
        </template>
        <template v-if="column.key === 'action'">
          <a-dropdown trigger="click">
            <a-button type="text" size="small" @click.prevent>
              <template #icon><MoreOutlined style="font-size: 16px; font-weight: bold; transform: rotate(90deg);" /></template>
            </a-button>
            <template #overlay>
            <a-menu @click="({ key }: { key: any }) => handleMenuClick(key as string, record)">
              <a-menu-item key="view">查看</a-menu-item>
                <a-menu-item key="edit">变更</a-menu-item>
                <a-menu-item key="collection">收款</a-menu-item>
                <a-menu-divider />
                <a-menu-item key="delete" danger>删除</a-menu-item>
              </a-menu>
            </template>
          </a-dropdown>
        </template>
      </template>
    </a-table>

    <!-- 合同详情抽屉 -->
    <ContractDetail
    v-model:open="detailVisible"
    :contract-data="currentContract as unknown as ContractDetailDto"
  />
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted } from 'vue';
import { SearchOutlined, FilterFilled, MoreOutlined } from '@ant-design/icons-vue';
import ContractDetail from './ContractDetail.vue';
import { getContracts, type ContractDto, type ContractDetailDto } from '@/api/contract';

// Types
interface SalesContract {
  key: string;
  contractNo: string;
  contractName: string;
  customerName: string;
  signDate: string;
  totalAmount: string;
  receivedAmount: string;
  latestCollectionDate: string;
  status: string;
  remark: string;
}

// Helpers
const parseAmount = (amountStr: string) => {
  return parseFloat(amountStr.replace(/,/g, ''));
};
const getStatusColor = (status: string) => {
  switch (status) {
    case 'executing': return 'processing';
    case 'completed': return 'success';
    case 'abnormal': return 'error';
    default: return 'default';
  }
};

const getStatusText = (status: string) => {
  switch (status) {
    case 'executing': return '执行中';
    case 'completed': return '已完成';
    case 'abnormal': return '异常';
    default: return '未知';
  }
};

const handleSearch = (_selectedKeys: string[], confirm: () => void, _dataIndex: string) => {
  confirm();
};

const handleReset = (clearFilters: (config?: any) => void) => {
  if (clearFilters) {
    clearFilters({ confirm: true });
  }
};

const handleTableChange = (pag: any) => {
  console.log('Table changed:', pag);
};

// Columns
const columns = [
  {
    title: '序号',
    key: 'index',
    width: 60,
    align: 'center',
    fixed: 'left',
    customRender: ({ index }: { index: number }) => index + 1,
  },
  {
    title: '合同编号',
    dataIndex: 'contractNo',
    key: 'contractNo',
    customFilterDropdown: true,
    onFilter: (value: string, record: SalesContract) => record.contractNo.toString().toLowerCase().includes(value.toLowerCase()),
    sorter: (a: SalesContract, b: SalesContract) => a.contractNo.localeCompare(b.contractNo),
    width: 150,
  },
  {
    title: '合同名称',
    dataIndex: 'contractName',
    key: 'contractName',
    customFilterDropdown: true,
    onFilter: (value: string, record: SalesContract) => record.contractName.toString().toLowerCase().includes(value.toLowerCase()),
    sorter: (a: SalesContract, b: SalesContract) => a.contractName.localeCompare(b.contractName),
    width: 200,
  },
  {
    title: '客户名称',
    dataIndex: 'customerName',
    key: 'customerName',
    customFilterDropdown: true,
    onFilter: (value: string, record: SalesContract) => record.customerName.toString().toLowerCase().includes(value.toLowerCase()),
    sorter: (a: SalesContract, b: SalesContract) => a.customerName.localeCompare(b.customerName),
    width: 200,
  },
  {
    title: '签定时间',
    dataIndex: 'signDate',
    key: 'signDate',
    sorter: (a: SalesContract, b: SalesContract) => new Date(a.signDate).getTime() - new Date(b.signDate).getTime(),
    customFilterDropdown: true,
    onFilter: (value: string[], record: SalesContract) => {
      const date = new Date(record.signDate).getTime();
      const [start, end] = value;
      if (start && date < new Date(start).getTime()) return false;
      if (end && date > new Date(end).getTime()) return false;
      return true;
    },
    width: 120,
  },
  {
    title: '总金额 (¥)',
    dataIndex: 'totalAmount',
    key: 'totalAmount',
    align: 'right',
    sorter: (a: SalesContract, b: SalesContract) => parseAmount(a.totalAmount) - parseAmount(b.totalAmount),
    customFilterDropdown: true,
    onFilter: (value: number[], record: SalesContract) => {
      const amount = parseAmount(record.totalAmount);
      const [min, max] = value;
      if (min !== undefined && min !== null && amount < min) return false;
      if (max !== undefined && max !== null && amount > max) return false;
      return true;
    },
    width: 150,
  },
  {
    title: '已收款 (¥)',
    dataIndex: 'receivedAmount',
    key: 'receivedAmount',
    align: 'right',
    sorter: (a: SalesContract, b: SalesContract) => parseAmount(a.receivedAmount) - parseAmount(b.receivedAmount),
    customFilterDropdown: true,
    onFilter: (value: number[], record: SalesContract) => {
      const amount = parseAmount(record.receivedAmount);
      const [min, max] = value;
      if (min !== undefined && min !== null && amount < min) return false;
      if (max !== undefined && max !== null && amount > max) return false;
      return true;
    },
    width: 150,
  },
  {
    title: '最新收款时间',
    dataIndex: 'latestCollectionDate',
    key: 'latestCollectionDate',
    sorter: (a: SalesContract, b: SalesContract) => {
      const dateA = a.latestCollectionDate ? new Date(a.latestCollectionDate).getTime() : 0;
      const dateB = b.latestCollectionDate ? new Date(b.latestCollectionDate).getTime() : 0;
      return dateA - dateB;
    },
    customFilterDropdown: true,
    onFilter: (value: string[], record: SalesContract) => {
      if (!record.latestCollectionDate) return false;
      const date = new Date(record.latestCollectionDate).getTime();
      const [start, end] = value;
      if (start && date < new Date(start).getTime()) return false;
      if (end && date > new Date(end).getTime()) return false;
      return true;
    },
    width: 200,
  },
  {
    title: '状态',
    dataIndex: 'status',
    key: 'status',
    filters: [
      { text: '执行中', value: 'executing' },
      { text: '已完成', value: 'completed' },
      { text: '异常', value: 'abnormal' },
    ],
    onFilter: (value: string, record: SalesContract) => record.status.indexOf(value) === 0,
    width: 100,
  },
  {
    title: '备注',
    dataIndex: 'remark',
    key: 'remark',
    ellipsis: true,
  },
  {
    title: '操作',
    key: 'action',
    width: 60,
    fixed: 'right',
    align: 'center',
  },
];

// Mock Data (replaced by API)
const data = ref<SalesContract[]>([]);

const fetchContracts = async () => {
  try {
    const res = await getContracts('sales');
    if (res) {
      data.value = res.map((item: ContractDto) => ({
        key: item.id.toString(),
        contractNo: item.contractNo,
        contractName: item.contractName,
        customerName: item.partnerName,
        signDate: item.signDate ? new Date(item.signDate).toISOString().split('T')[0] : '',
        totalAmount: item.totalAmount.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
        receivedAmount: item.paidAmount.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
        latestCollectionDate: item.latestTransactionDate ? new Date(item.latestTransactionDate).toISOString().split('T')[0] : '',
        status: item.status,
        remark: item.description || '',
      })) as SalesContract[];
    }
  } catch (error) {
    console.error('Failed to fetch sales contracts:', error);
  }
};

onMounted(() => {
  fetchContracts();
});

const pagination = {
  total: 50, // Should be updated from API if paginated
  current: 1,
  pageSize: 10,
};

// Detail Drawer Logic
const detailVisible = ref(false);
const currentContract = ref<SalesContract | null>(null);

const handleMenuClick = (key: string, record: SalesContract) => {
  if (key === 'view') {
    currentContract.value = record;
    detailVisible.value = true;
  }
};

defineExpose({
  refresh: fetchContracts
});
</script>

<style scoped>
.sales-contract-list {
  display: flex;
  flex-direction: column;
  flex: 1;
  overflow: hidden;
  height: 100%;
}
:deep(.ant-table-wrapper) {
  height: 100%;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

:deep(.ant-spin-nested-loading) {
  height: 100%;
  flex: 1;
  overflow: hidden;
}

:deep(.ant-spin-container) {
  height: 100%;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

:deep(.ant-table) {
  flex: 1;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

:deep(.ant-table-container) {
  height: 100%;
  display: flex;
  flex-direction: column;
}

:deep(.ant-table-header) {
  flex-shrink: 0;
  overflow: hidden !important;
}

:deep(.ant-table-body) {
  flex: 1;
  overflow-y: auto !important;
  max-height: none !important;
}

:deep(.ant-table-pagination.ant-pagination) {
  margin: 16px !important;
  flex-shrink: 0;
}
</style>