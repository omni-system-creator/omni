<template>
  <div class="finance-invoice-container">
    <a-card :bordered="false">
      <div class="table-page-search-wrapper">
        <a-form layout="inline">
          <a-form-item label="发票号码">
            <a-input v-model:value="queryParam.invoiceNo" placeholder="请输入" />
          </a-form-item>
          <a-form-item label="发票类型">
            <a-select v-model:value="queryParam.type" placeholder="请选择" style="width: 150px">
              <a-select-option value="all">全部</a-select-option>
              <a-select-option value="vat_special">增值税专用发票</a-select-option>
              <a-select-option value="vat_normal">增值税普通发票</a-select-option>
              <a-select-option value="electronic">电子发票</a-select-option>
            </a-select>
          </a-form-item>
          <a-form-item label="开票日期">
            <a-range-picker v-model:value="queryParam.dateRange" />
          </a-form-item>
          <a-form-item>
            <a-space>
              <a-button type="primary" @click="handleSearch">查询</a-button>
              <a-button @click="handleReset">重置</a-button>
            </a-space>
          </a-form-item>
        </a-form>
      </div>

      <div class="table-operator my-4">
        <a-button type="primary" @click="showModal">
          <template #icon><PlusOutlined /></template>
          开具发票
        </a-button>
        <a-button>
          <template #icon><DownloadOutlined /></template>
          发票登记
        </a-button>
         <a-button>
          <template #icon><ExportOutlined /></template>
          导出报表
        </a-button>
      </div>

      <a-table :columns="columns" :data-source="data" :pagination="pagination">
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'amount'">
            <span>¥{{ record.amount.toLocaleString() }}</span>
          </template>
           <template v-if="column.key === 'total'">
            <strong>¥{{ record.total.toLocaleString() }}</strong>
          </template>
          <template v-if="column.key === 'status'">
            <a-badge :status="getStatusBadge(record.status)" :text="record.status" />
          </template>
          <template v-if="column.key === 'action'">
            <a>详情</a>
            <a-divider type="vertical" />
            <a v-if="record.status === '草稿'">编辑</a>
            <a-divider type="vertical" v-if="record.status === '草稿'" />
            <a-popconfirm title="确定作废该发票吗？" v-if="record.status === '已开票'">
               <a class="danger-text">作废</a>
            </a-popconfirm>
          </template>
        </template>
      </a-table>
    </a-card>

    <a-modal
      v-model:open="visible"
      title="开具发票"
      width="800px"
      @ok="handleOk"
    >
      <a-form :model="formState" layout="vertical" ref="formRef">
        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="购方名称" name="buyer" :rules="[{ required: true }]">
              <a-input v-model:value="formState.buyer" placeholder="请输入购方名称" />
            </a-form-item>
          </a-col>
           <a-col :span="12">
            <a-form-item label="税号" name="taxId" :rules="[{ required: true }]">
              <a-input v-model:value="formState.taxId" placeholder="请输入纳税人识别号" />
            </a-form-item>
          </a-col>
        </a-row>
         <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="发票类型" name="type" :rules="[{ required: true }]">
               <a-select v-model:value="formState.type">
                  <a-select-option value="vat_special">增值税专用发票</a-select-option>
                  <a-select-option value="vat_normal">增值税普通发票</a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
           <a-col :span="12">
            <a-form-item label="金额(不含税)" name="amount" :rules="[{ required: true }]">
              <a-input-number v-model:value="formState.amount" style="width: 100%" :min="0" />
            </a-form-item>
          </a-col>
        </a-row>
        <a-form-item label="备注" name="remark">
          <a-textarea v-model:value="formState.remark" :rows="3" />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue';
import { PlusOutlined, DownloadOutlined, ExportOutlined } from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import type { PresetStatusColorType } from 'ant-design-vue/es/_util/colors';

const queryParam = reactive({
  invoiceNo: '',
  type: undefined,
  dateRange: [] as any
});

const visible = ref(false);
const formRef = ref();
const formState = reactive({
  buyer: '',
  taxId: '',
  type: 'vat_special',
  amount: 0,
  remark: ''
});

const columns: ColumnType[] = [
  { title: '发票号码', dataIndex: 'invoiceNo', key: 'invoiceNo' },
  { title: '发票代码', dataIndex: 'invoiceCode', key: 'invoiceCode' },
  { title: '购方名称', dataIndex: 'buyer', key: 'buyer', width: 200 },
  { title: '类型', dataIndex: 'type', key: 'type' },
  { title: '金额(不含税)', dataIndex: 'amount', key: 'amount', align: 'right' as const },
  { title: '税额', dataIndex: 'tax', key: 'tax', align: 'right' as const },
  { title: '价税合计', dataIndex: 'total', key: 'total', align: 'right' as const },
  { title: '开票日期', dataIndex: 'date', key: 'date' },
  { title: '状态', dataIndex: 'status', key: 'status' },
  { title: '操作', key: 'action', width: 150 }
];

const data = ref([
  { id: 1, invoiceNo: '12345678', invoiceCode: '3100201130', buyer: '上海某某科技有限公司', type: '增值税专用发票', amount: 10000, tax: 600, total: 10600, date: '2024-12-20', status: '已开票' },
  { id: 2, invoiceNo: '87654321', invoiceCode: '3100201130', buyer: '北京某某贸易公司', type: '增值税普通发票', amount: 5000, tax: 150, total: 5150, date: '2024-12-18', status: '草稿' },
  { id: 3, invoiceNo: '11223344', invoiceCode: '3100201130', buyer: '广州个人客户', type: '电子发票', amount: 200, tax: 0, total: 200, date: '2024-12-15', status: '已红冲' },
]);

const pagination = {
  total: 50,
  current: 1,
  pageSize: 10
};

const getStatusBadge = (status: string): PresetStatusColorType => {
  switch (status) {
    case '已开票': return 'success';
    case '草稿': return 'default';
    case '已红冲': return 'error';
    default: return 'processing';
  }
};

const handleSearch = () => {
  message.loading('查询中...');
};

const handleReset = () => {
  queryParam.invoiceNo = '';
  queryParam.type = undefined;
};

const showModal = () => {
  visible.value = true;
};

const handleOk = () => {
  formRef.value.validate().then(() => {
    message.success('开票申请已提交');
    visible.value = false;
  }).catch(() => {});
};
</script>

<style scoped>
.finance-invoice-container {
  padding: 16px;
  flex: 1;
}
.my-4 {
  margin-top: 16px;
  margin-bottom: 16px;
}
.danger-text {
  color: #ff4d4f;
}
</style>
