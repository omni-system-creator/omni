<template>
  <div class="purchase-contract-list">
    <a-table
      :columns="columns"
      :data-source="data"
      :pagination="pagination"
      :scroll="{ x: 'max-content', y: 600 }"
      @change="handleTableChange"
    >
      <template #customFilterDropdown="{ setSelectedKeys, selectedKeys, confirm, clearFilters, column }">
        <div style="padding: 8px">
          <template v-if="column.key === 'totalAmount' || column.key === 'paidAmount'">
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
          <template v-else-if="column.key === 'signDate' || column.key === 'latestPaymentDate'">
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
          <a-dropdown trigger="hover">
            <a-button type="text" size="small" @click.prevent>
              <template #icon><MoreOutlined style="font-size: 16px; font-weight: bold; transform: rotate(90deg);" /></template>
            </a-button>
            <template #overlay>
                <a-menu @click="(e: any) => handleMenuClick(e.key as string, record as PurchaseContract)">
                  <a-menu-item key="view">查看</a-menu-item>
                  <a-menu-item key="edit">变更</a-menu-item>
                <a-menu-item key="payment">付款</a-menu-item>
                <a-menu-divider />
                <a-menu-item key="delete" danger>删除</a-menu-item>
              </a-menu>
            </template>
          </a-dropdown>
        </template>
      </template>
    </a-table>
    <ContractDetail
      v-model:open="detailVisible"
      :contract-data="currentContract as unknown as ContractDetailDto"
    />
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted, reactive } from 'vue';
import { SearchOutlined, FilterFilled, MoreOutlined } from '@ant-design/icons-vue';
import { getContracts } from '@/api/contract';
import type { ContractDto, ContractDetailDto } from '@/api/contract';

// Types
interface PurchaseContract {
  key: string;
  contractNo: string;
  contractName: string;
  supplierName: string;
  signDate: string;
  totalAmount: string;
  paidAmount: string;
  latestPaymentDate: string;
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

const handleReset = (clearFilters: any) => {
  if (clearFilters) {
    clearFilters();
  }
};

const handleTableChange = (pag: any) => {
  console.log('Table changed:', pag);
};

// Pagination
const pagination = reactive({
  total: 0,
  current: 1,
  pageSize: 10,
  showSizeChanger: true,
  showQuickJumper: true,
  showTotal: (total: number) => `共 ${total} 条`,
});

// Columns
const columns: ColumnType<PurchaseContract>[] = [
  {
    title: '序号',
    key: 'index',
    width: 60,
    align: 'center' as const,
    fixed: 'left' as const,
    customRender: ({ index }: { index: number }) => index + 1,
  },
  {
    title: '合同编号',
    dataIndex: 'contractNo',
    key: 'contractNo',
    customFilterDropdown: true,
    onFilter: (value: any, record: PurchaseContract) => record.contractNo.toString().toLowerCase().includes(String(value).toLowerCase()),
    sorter: (a: PurchaseContract, b: PurchaseContract) => a.contractNo.localeCompare(b.contractNo),
    width: 150,
  },
  {
    title: '合同名称',
    dataIndex: 'contractName',
    key: 'contractName',
    customFilterDropdown: true,
    onFilter: (value: any, record: PurchaseContract) => record.contractName.toString().toLowerCase().includes(String(value).toLowerCase()),
    sorter: (a: PurchaseContract, b: PurchaseContract) => a.contractName.localeCompare(b.contractName),
    width: 200,
  },
  {
    title: '供应商名称',
    dataIndex: 'supplierName',
    key: 'supplierName',
    customFilterDropdown: true,
    onFilter: (value: any, record: PurchaseContract) => record.supplierName.toString().toLowerCase().includes(String(value).toLowerCase()),
    sorter: (a: PurchaseContract, b: PurchaseContract) => a.supplierName.localeCompare(b.supplierName),
    width: 200,
  },
  {
    title: '签定时间',
    dataIndex: 'signDate',
    key: 'signDate',
    sorter: (a: PurchaseContract, b: PurchaseContract) => new Date(a.signDate).getTime() - new Date(b.signDate).getTime(),
    customFilterDropdown: true,
    onFilter: (value: any, record: PurchaseContract) => {
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
    sorter: (a: PurchaseContract, b: PurchaseContract) => parseAmount(a.totalAmount) - parseAmount(b.totalAmount),
    customFilterDropdown: true,
    onFilter: (value: any, record: PurchaseContract) => {
      const amount = parseAmount(record.totalAmount);
      const [min, max] = value;
      if (min !== undefined && min !== null && amount < min) return false;
      if (max !== undefined && max !== null && amount > max) return false;
      return true;
    },
    width: 150,
  },
  {
    title: '已付款 (¥)',
    dataIndex: 'paidAmount',
    key: 'paidAmount',
    align: 'right',
    sorter: (a: PurchaseContract, b: PurchaseContract) => parseAmount(a.paidAmount) - parseAmount(b.paidAmount),
    customFilterDropdown: true,
    onFilter: (value: any, record: PurchaseContract) => {
      const amount = parseAmount(record.paidAmount);
      const [min, max] = value;
      if (min !== undefined && min !== null && amount < min) return false;
      if (max !== undefined && max !== null && amount > max) return false;
      return true;
    },
    width: 150,
  },
  {
    title: '最新付款时间',
    dataIndex: 'latestPaymentDate',
    key: 'latestPaymentDate',
    sorter: (a: PurchaseContract, b: PurchaseContract) => {
      const dateA = a.latestPaymentDate ? new Date(a.latestPaymentDate).getTime() : 0;
      const dateB = b.latestPaymentDate ? new Date(b.latestPaymentDate).getTime() : 0;
      return dateA - dateB;
    },
    customFilterDropdown: true,
    onFilter: (value: any, record: PurchaseContract) => {
      if (!record.latestPaymentDate) return false;
      const date = new Date(record.latestPaymentDate).getTime();
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
    onFilter: (value: any, record: PurchaseContract) => record.status.indexOf(String(value)) === 0,
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
    fixed: 'right',
    width: 150,
  },
];

const detailVisible = ref(false);
const currentContract = ref<PurchaseContract | null>(null);

const handleMenuClick = (key: string, record: PurchaseContract) => {
  if (key === 'view') {
    currentContract.value = record;
    detailVisible.value = true;
  }
};

const data = ref<PurchaseContract[]>([]);

const fetchContracts = async () => {
  try {
    const res = await getContracts('purchase');
    if (res && res.length > 0) {
      data.value = res.map((item: ContractDto) => ({
        key: item.id.toString(),
        contractNo: item.contractNo,
        contractName: item.contractName,
        supplierName: item.partnerName,
        signDate: item.signDate ? new Date(item.signDate).toISOString().split('T')[0] : '',
        totalAmount: item.totalAmount.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
        paidAmount: item.paidAmount.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
        latestPaymentDate: item.latestTransactionDate ? new Date(item.latestTransactionDate).toISOString().split('T')[0] : '',
        status: item.status,
        remark: item.description || '',
      })) as PurchaseContract[];
      pagination.total = res.length;
    } else {
      throw new Error('No data from API');
    }
  } catch (error) {
    console.error('Failed to fetch purchase contracts, using mock data:', error);
    // Fallback to mock data
    data.value = [
      {
        key: '1',
        contractNo: 'CG2025120101',
        contractName: '智慧城市二期项目采购合同',
        supplierName: 'XX市政集团',
        signDate: '2025-12-01',
        totalAmount: '1,200,000.00',
        paidAmount: '400,000.00',
        latestPaymentDate: '2025-12-05',
        status: 'executing',
        remark: '预付款已付',
      },
      {
        key: '2',
        contractNo: 'CG2025111505',
        contractName: '服务器集群采购',
        supplierName: 'Dell供应商',
        signDate: '2025-11-15',
        totalAmount: '500,000.00',
        paidAmount: '500,000.00',
        latestPaymentDate: '2025-11-20',
        status: 'completed',
        remark: '设备已验收',
      },
      {
        key: '3',
        contractNo: 'CG2025121008',
        contractName: '办公设备采购协议',
        supplierName: 'AA贸易公司',
        signDate: '2025-12-10',
        totalAmount: '120,000.00',
        paidAmount: '12,000.00',
        latestPaymentDate: '2025-12-11',
        status: 'executing',
        remark: '定金已付',
      },
    ];
    pagination.total = 3;
  }
};

onMounted(() => {
  fetchContracts();
});

defineExpose({
  refresh: fetchContracts
});
</script>

<style scoped>
.purchase-contract-list {
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