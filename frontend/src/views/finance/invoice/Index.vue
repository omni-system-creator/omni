<template>
  <div class="finance-invoice-container">
    <SmartTable
      tableKey="finance_invoice_list"
      :columns="columns"
      :data-source="data"
      rowKey="id"
      :loading="loading"
      :pagination="pagination"
      @change="handleTableChange"
      :scroll="{ x: 'max-content' }"
      style="height: 100%"
    >
      <template #toolbar>
        <div class="toolbar-wrapper">
          <div class="toolbar-left">
            <a-button type="primary" @click="handleCreate">
              <template #icon><PlusOutlined /></template>
              新增发票
            </a-button>
          </div>
          <div class="toolbar-right">
            <a-form layout="inline" class="flex-nowrap">
              <a-form-item label="关键字">
                <a-input v-model:value="queryParam.keyword" placeholder="号码/代码/公司名" allow-clear />
              </a-form-item>
              <a-form-item label="收/开票">
                <a-select v-model:value="queryParam.direction" placeholder="全部" style="width: 100px" allow-clear>
                  <a-select-option value="input">收票</a-select-option>
                  <a-select-option value="output">开票</a-select-option>
                </a-select>
              </a-form-item>
              <a-form-item label="类型">
                <a-select v-model:value="queryParam.type" placeholder="全部" style="width: 140px" allow-clear>
                  <a-select-option v-for="item in typeOptions" :key="item.value" :value="item.value">
                    {{ item.label }}
                  </a-select-option>
                </a-select>
              </a-form-item>
              <a-form-item label="状态">
                <a-select v-model:value="queryParam.status" placeholder="全部" style="width: 100px" allow-clear>
                  <a-select-option v-for="item in statusOptions" :key="item.value" :value="item.value">
                    {{ item.label }}
                  </a-select-option>
                </a-select>
              </a-form-item>
              <a-form-item>
                <a-space>
                  <a-button type="primary" @click="fetchData">查询</a-button>
                  <a-button @click="handleReset">重置</a-button>
                </a-space>
              </a-form-item>
            </a-form>
          </div>
        </div>
      </template>

      <template #bodyCell="{ column, record, index }">
        <template v-if="column.key === 'serial'">
          {{ (pagination.current - 1) * pagination.pageSize + index + 1 }}
        </template>
        <template v-if="column.key === 'direction'">
          <a-tag :color="record.direction === 'input' ? 'blue' : 'green'">
            {{ record.direction === 'input' ? '收票' : '开票' }}
          </a-tag>
        </template>
        <template v-if="column.key === 'type'">
          <a-tag>{{ getTypeName(record.type) }}</a-tag>
        </template>
        <template v-if="column.key === 'amount'">
          <span>{{ record.amount.toLocaleString('zh-CN', { minimumFractionDigits: 2 }) }}</span>
        </template>
        <template v-if="column.key === 'taxAmount'">
          <span>{{ record.taxAmount.toLocaleString('zh-CN', { minimumFractionDigits: 2 }) }}</span>
        </template>
        <template v-if="column.key === 'totalAmount'">
          <strong>{{ record.totalAmount.toLocaleString('zh-CN', { minimumFractionDigits: 2 }) }}</strong>
        </template>
        <template v-if="column.key === 'invoiceDate'">
          <span>{{ record.invoiceDate ? record.invoiceDate.substring(0, 10) : '-' }}</span>
        </template>
        <template v-if="column.key === 'status'">
          <a-tag :color="getStatusColor(record.status)">{{ getStatusText(record.status) }}</a-tag>
        </template>
        <template v-if="column.key === 'action'">
          <a @click="handleEdit(record)">编辑</a>
          <a-divider type="vertical" />
          <a-popconfirm title="确定删除该发票吗？" @confirm="handleDelete(record.id)">
            <a class="danger-text">删除</a>
          </a-popconfirm>
        </template>
      </template>
    </SmartTable>

    <InvoiceForm ref="invoiceFormRef" @success="fetchData" />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue';
import { PlusOutlined } from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import type { TableColumnType } from 'ant-design-vue';
import SmartTable from '@/components/SmartTable/index.vue';
import InvoiceForm from './components/InvoiceForm.vue';
import { getInvoices, deleteInvoice, type FinanceInvoice } from '@/api/finance';
import { getDictDataByCode, type DictDataDto } from '@/api/dict';

const invoiceFormRef = ref();
const loading = ref(false);
const data = ref<FinanceInvoice[]>([]);
const statusOptions = ref<DictDataDto[]>([]);
const typeOptions = ref<DictDataDto[]>([]);

const queryParam = reactive({
  keyword: '',
  direction: undefined,
  type: undefined,
  status: undefined
});

const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0,
  showSizeChanger: true,
  showQuickJumper: true
});

const columns: TableColumnType[] = [
  { title: '序号', key: 'serial', width: 60, fixed: 'left', align: 'center' },
  { title: '发票号码', dataIndex: 'invoiceNo', key: 'invoiceNo', width: 120, fixed: 'left' },
  { title: '发票代码', dataIndex: 'invoiceCode', key: 'invoiceCode', width: 180, ellipsis: true },
  { title: '收/开票', dataIndex: 'direction', key: 'direction', width: 80 },
  { title: '类型', dataIndex: 'type', key: 'type', width: 140 },
  { title: '金额', dataIndex: 'amount', key: 'amount', align: 'right', width: 120 },
  { title: '税额', dataIndex: 'taxAmount', key: 'taxAmount', align: 'right', width: 100 },
  { title: '价税合计', dataIndex: 'totalAmount', key: 'totalAmount', align: 'right', width: 120 },
  { title: '开票日期', dataIndex: 'invoiceDate', key: 'invoiceDate', width: 120 },
  { title: '购买方', dataIndex: 'purchaserName', key: 'purchaserName', width: 200, ellipsis: true },
  { title: '销售方', dataIndex: 'sellerName', key: 'sellerName', width: 200, ellipsis: true },
  { title: '状态', dataIndex: 'status', key: 'status', width: 100 },
  { title: '操作', key: 'action', width: 120, fixed: 'right' }
];

const fetchData = async () => {
  loading.value = true;
  try {
    // Note: Backend currently returns List<FinanceInvoiceDto> without pagination wrapper in response?
    // Checking controller: 
    // public async Task<ApiResponse<List<FinanceInvoiceDto>>> GetInvoices(...)
    // It returns a list directly. So we simulate pagination frontend-side or accept all data.
    // Ideally backend should support pagination. For now assuming list.
    
    const res = await getInvoices({
      keyword: queryParam.keyword,
      direction: queryParam.direction,
      type: queryParam.type,
      status: queryParam.status
    });
    
    // Frontend pagination simulation if backend doesn't support it yet
    // Or if backend returns all data (which seems to be the case based on controller code)
    data.value = res;
    pagination.total = res.length;
    
  } catch (error) {
    console.error(error);
    message.error('获取发票列表失败');
  } finally {
    loading.value = false;
  }
};

const handleTableChange = (pag: any) => {
  pagination.current = pag.current;
  pagination.pageSize = pag.pageSize;
  // If doing frontend pagination, we would slice data here. 
  // But SmartTable might just display what's given. 
  // Since we don't have server-side pagination yet, we can just rely on table to paginate or ignore.
  // Actually SmartTable wrapper passes pagination to Ant Table.
};

const handleCreate = () => {
  invoiceFormRef.value.open();
};

const handleEdit = (record: FinanceInvoice) => {
  invoiceFormRef.value.open(record);
};

const handleDelete = async (id: number) => {
  try {
    await deleteInvoice(id);
    message.success('删除成功');
    fetchData();
  } catch (error) {
    message.error('删除失败');
  }
};

const handleReset = () => {
  queryParam.keyword = '';
  queryParam.direction = undefined;
  queryParam.type = undefined;
  queryParam.status = undefined;
  fetchData();
};

const getTypeName = (type: string) => {
  if (!type) return '';
  const found = typeOptions.value.find(item => item.value === type);
  return found ? found.label : type;
};

const getStatusColor = (status: string): string => {
  if (!status) return 'default';
  
  // Try to find in dictionary first
  const found = statusOptions.value.find(item => item.value === status || item.value.toLowerCase() === status.toLowerCase());
  if (found && found.listClass) {
    return found.listClass;
  }

  return 'default';
};

const getStatusText = (status: string) => {
  if (!status) return '';
  const found = statusOptions.value.find(item => item.value === status || item.value.toLowerCase() === status.toLowerCase());
  return found ? found.label : status;
};

onMounted(async () => {
  try {
    statusOptions.value = await getDictDataByCode('finance_invoice_status');
    typeOptions.value = await getDictDataByCode('finance_invoice_type');
  } catch (error) {
    console.error('Failed to load dicts', error);
  }
  fetchData();
});
</script>

<style scoped>
.finance-invoice-container {
  flex: 1;
  padding: 0;
  display: flex;
  flex-direction: column;
  background-color: #ffffff;
}

.toolbar-wrapper {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
}

.flex-nowrap {
  flex-wrap: nowrap;
}

.danger-text {
  color: #ff4d4f;
}
</style>
