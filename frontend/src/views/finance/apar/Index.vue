<template>
  <div class="finance-apar-container">
    <a-card :bordered="false" class="mb-4">
      <a-row :gutter="24">
        <a-col :span="6">
          <a-statistic title="应收总额" :value="1250000" prefix="¥" :precision="2">
            <template #suffix>
              <small class="text-success">
                <ArrowUpOutlined /> 5.2%
              </small>
            </template>
          </a-statistic>
        </a-col>
        <a-col :span="6">
          <a-statistic title="应收逾期" :value="45000" prefix="¥" :precision="2" :value-style="{ color: '#cf1322' }" />
        </a-col>
        <a-col :span="6">
          <a-statistic title="应付总额" :value="860000" prefix="¥" :precision="2" />
        </a-col>
        <a-col :span="6">
          <a-statistic title="本月净现金流" :value="390000" prefix="¥" :precision="2" :value-style="{ color: '#3f8600' }" />
        </a-col>
      </a-row>
    </a-card>

    <a-card :bordered="false">
      <a-tabs v-model:activeKey="activeTab">
        <a-tab-pane key="ar" tab="应收账款 (AR)">
          <div class="table-page-search-wrapper">
            <a-form layout="inline">
              <a-form-item label="客户名称">
                <a-input v-model:value="queryParam.customer" placeholder="请输入" />
              </a-form-item>
              <a-form-item label="状态">
                <a-select v-model:value="queryParam.status" placeholder="请选择" style="width: 120px">
                  <a-select-option value="0">全部</a-select-option>
                  <a-select-option value="1">未收款</a-select-option>
                  <a-select-option value="2">已逾期</a-select-option>
                  <a-select-option value="3">已完成</a-select-option>
                </a-select>
              </a-form-item>
              <a-form-item>
                <a-space>
                  <a-button type="primary" @click="refreshTable">查询</a-button>
                  <a-button @click="resetQuery">重置</a-button>
                </a-space>
              </a-form-item>
            </a-form>
          </div>

          <div class="table-operator my-4">
            <a-button type="primary">
              <template #icon><PlusOutlined /></template>
              新增应收单
            </a-button>
            <a-button>
              <template #icon><ExportOutlined /></template>
              导出
            </a-button>
          </div>

          <a-table :columns="arColumns" :data-source="arData" rowKey="id">
            <template #bodyCell="{ column, record }">
              <template v-if="column.key === 'amount'">
                <span>¥{{ record.amount.toLocaleString() }}</span>
              </template>
              <template v-if="column.key === 'status'">
                <a-tag :color="getArStatusColor(record.status)">{{ record.status }}</a-tag>
              </template>
              <template v-if="column.key === 'action'">
                <a>详情</a>
                <a-divider type="vertical" />
                <a v-if="record.status !== '已完成'">核销</a>
                <a-divider type="vertical" v-if="record.status !== '已完成'" />
                <a v-if="record.status !== '已完成'">催收</a>
              </template>
            </template>
          </a-table>
        </a-tab-pane>

        <a-tab-pane key="ap" tab="应付账款 (AP)">
           <div class="table-page-search-wrapper">
            <a-form layout="inline">
              <a-form-item label="供应商">
                <a-input v-model:value="queryParam.supplier" placeholder="请输入" />
              </a-form-item>
               <a-form-item>
                <a-space>
                  <a-button type="primary" @click="refreshTable">查询</a-button>
                  <a-button @click="resetQuery">重置</a-button>
                </a-space>
              </a-form-item>
            </a-form>
          </div>
           <div class="table-operator my-4">
            <a-button type="primary">
              <template #icon><PlusOutlined /></template>
              新增应付单
            </a-button>
          </div>
          <a-table :columns="apColumns" :data-source="apData" rowKey="id">
             <template #bodyCell="{ column, record }">
              <template v-if="column.key === 'amount'">
                <span>¥{{ record.amount.toLocaleString() }}</span>
              </template>
              <template v-if="column.key === 'status'">
                <a-tag :color="getApStatusColor(record.status)">{{ record.status }}</a-tag>
              </template>
              <template v-if="column.key === 'action'">
                <a>详情</a>
                <a-divider type="vertical" />
                <a v-if="record.status !== '已付款'">付款</a>
              </template>
            </template>
          </a-table>
        </a-tab-pane>
      </a-tabs>
    </a-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue';
import { ArrowUpOutlined, PlusOutlined, ExportOutlined } from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';

const activeTab = ref('ar');
const queryParam = reactive({
  customer: '',
  supplier: '',
  status: '0'
});

const arColumns: ColumnType[] = [
  { title: '单据编号', dataIndex: 'no', key: 'no' },
  { title: '客户名称', dataIndex: 'customer', key: 'customer' },
  { title: '应收金额', dataIndex: 'amount', key: 'amount', align: 'right' as const },
  { title: '应收日期', dataIndex: 'dueDate', key: 'dueDate' },
  { title: '逾期天数', dataIndex: 'overdueDays', key: 'overdueDays', align: 'center' as const },
  { title: '状态', dataIndex: 'status', key: 'status' },
  { title: '操作', key: 'action', width: 200 }
];

const arData = ref([
  { id: 1, no: 'AR20241201001', customer: '上海科技有限公司', amount: 50000, dueDate: '2024-12-31', overdueDays: 0, status: '未收款' },
  { id: 2, no: 'AR20241115003', customer: '北京贸易有限公司', amount: 12000, dueDate: '2024-11-30', overdueDays: 22, status: '已逾期' },
  { id: 3, no: 'AR20241020005', customer: '广州电子集团', amount: 85000, dueDate: '2024-10-30', overdueDays: 0, status: '已完成' },
]);

const apColumns: ColumnType[] = [
  { title: '单据编号', dataIndex: 'no', key: 'no' },
  { title: '供应商名称', dataIndex: 'supplier', key: 'supplier' },
  { title: '应付金额', dataIndex: 'amount', key: 'amount', align: 'right' as const },
  { title: '应付日期', dataIndex: 'dueDate', key: 'dueDate' },
  { title: '状态', dataIndex: 'status', key: 'status' },
  { title: '操作', key: 'action', width: 150 }
];

const apData = ref([
  { id: 1, no: 'AP20241205002', supplier: '阿里云计算有限公司', amount: 3500, dueDate: '2025-01-10', status: '待付款' },
  { id: 2, no: 'AP20241201004', supplier: '顺丰速运', amount: 850, dueDate: '2024-12-25', status: '待付款' },
  { id: 3, no: 'AP20241101009', supplier: '联想集团', amount: 45000, dueDate: '2024-11-20', status: '已付款' },
]);

const getArStatusColor = (status: string) => {
  if (status === '已完成') return 'green';
  if (status === '已逾期') return 'red';
  return 'blue';
};

const getApStatusColor = (status: string) => {
  if (status === '已付款') return 'green';
  return 'orange';
};

const refreshTable = () => {
  message.loading('加载中...', 1);
};

const resetQuery = () => {
  queryParam.customer = '';
  queryParam.supplier = '';
  queryParam.status = '0';
};
</script>

<style scoped>
.finance-apar-container {
  padding: 16px;
  flex: 1;
}
.mb-4 {
  margin-bottom: 16px;
}
.my-4 {
  margin-top: 16px;
  margin-bottom: 16px;
}
.text-success {
  color: #3f8600;
}
</style>
