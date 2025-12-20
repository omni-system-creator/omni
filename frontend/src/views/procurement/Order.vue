<template>
  <div class="page-container">
    <div class="filter-bar">
      <a-form layout="inline">
        <a-form-item label="订单号">
          <a-input placeholder="请输入" />
        </a-form-item>
        <a-form-item label="供应商">
          <a-input placeholder="请输入" />
        </a-form-item>
        <a-form-item label="订单状态">
          <a-select placeholder="请选择" style="width: 120px">
            <a-select-option value="all">全部</a-select-option>
            <a-select-option value="created">已下单</a-select-option>
            <a-select-option value="shipping">发货中</a-select-option>
            <a-select-option value="received">已入库</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item>
          <a-button type="primary">查询</a-button>
          <a-button style="margin-left: 8px">重置</a-button>
        </a-form-item>
      </a-form>
    </div>

    <div class="table-content">
      <a-table :columns="columns" :data-source="orderList" :pagination="pagination">
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'status'">
            <a-badge :status="getStatusBadge(record.status)" :text="getStatusText(record.status)" />
          </template>
          <template v-else-if="column.key === 'amount'">
            <span style="font-weight: bold">{{ record.amount }}</span>
          </template>
          <template v-else-if="column.key === 'action'">
            <a-space>
              <a>查看</a>
              <a v-if="record.status === 'created'">发货跟踪</a>
              <a v-if="record.status === 'shipping'">入库</a>
            </a-space>
          </template>
        </template>
      </a-table>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';

const columns = [
  { title: '订单号', dataIndex: 'id', key: 'id' },
  { title: '关联需求单', dataIndex: 'requestId', key: 'requestId' },
  { title: '供应商', dataIndex: 'supplier', key: 'supplier' },
  { title: '采购总额', dataIndex: 'amount', key: 'amount' },
  { title: '下单日期', dataIndex: 'date', key: 'date' },
  { title: '采购员', dataIndex: 'purchaser', key: 'purchaser' },
  { title: '状态', dataIndex: 'status', key: 'status' },
  { title: '操作', key: 'action', width: 200 },
];

const orderList = ref([
  { id: 'PO20251205001', requestId: 'PR20251201001', supplier: 'XX电子元器件有限公司', amount: '¥ 118,000', date: '2025-12-05', purchaser: '赵六', status: 'shipping' },
  { id: 'PO20251210002', requestId: 'PR20251202005', supplier: 'YY办公设备有限公司', amount: '¥ 4,800', date: '2025-12-10', purchaser: '赵六', status: 'received' },
]);

const pagination = {
  total: 10,
  showSizeChanger: true,
  showQuickJumper: true,
};

const getStatusBadge = (status: string) => {
  const map: Record<string, string> = {
    created: 'default',
    shipping: 'processing',
    received: 'success',
    cancelled: 'error',
  };
  return map[status] || 'default';
};

const getStatusText = (status: string) => {
  const map: Record<string, string> = {
    created: '已下单',
    shipping: '运输中',
    received: '已入库',
    cancelled: '已取消',
  };
  return map[status] || status;
};
</script>

<style scoped>
.page-container {
  padding: 24px;
  background: #fff;
  min-height: 100%;
}

.filter-bar {
  margin-bottom: 24px;
  padding: 24px;
  background: #fbfbfb;
  border-radius: 4px;
  border: 1px solid #f0f0f0;
}
</style>