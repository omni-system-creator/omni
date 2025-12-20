<template>
  <div class="page-container">
    <a-tabs v-model:activeKey="activeTab">
      <a-tab-pane key="inbound" tab="入库记录">
        <div class="filter-bar">
          <a-input-search placeholder="入库单号/供应商" style="width: 250px" />
          <a-range-picker style="margin-left: 16px" />
          <a-button type="primary" style="margin-left: 16px">添加入库单</a-button>
        </div>
        <a-table :columns="inboundColumns" :data-source="inboundData" style="margin-top: 16px">
          <template #bodyCell="{ column, record }">
            <template v-if="column.key === 'status'">
              <a-tag :color="record.status === 'completed' ? 'green' : 'blue'">{{ record.status === 'completed' ? '已完成' : '入库中' }}</a-tag>
            </template>
          </template>
        </a-table>
      </a-tab-pane>
      
      <a-tab-pane key="outbound" tab="出库记录">
        <div class="filter-bar">
          <a-input-search placeholder="出库单号/客户" style="width: 250px" />
          <a-range-picker style="margin-left: 16px" />
          <a-button type="primary" style="margin-left: 16px">添加出库单</a-button>
        </div>
        <a-table :columns="outboundColumns" :data-source="outboundData" style="margin-top: 16px">
          <template #bodyCell="{ column, record }">
            <template v-if="column.key === 'status'">
              <a-tag :color="record.status === 'shipped' ? 'green' : 'orange'">{{ record.status === 'shipped' ? '已发货' : '拣货中' }}</a-tag>
            </template>
          </template>
        </a-table>
      </a-tab-pane>
    </a-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';

const activeTab = ref('inbound');

const inboundColumns = [
  { title: '入库单号', dataIndex: 'id', key: 'id' },
  { title: '来源', dataIndex: 'source', key: 'source' },
  { title: '入库类型', dataIndex: 'type', key: 'type' },
  { title: '数量', dataIndex: 'qty', key: 'qty' },
  { title: '入库日期', dataIndex: 'date', key: 'date' },
  { title: '操作人', dataIndex: 'operator', key: 'operator' },
  { title: '状态', dataIndex: 'status', key: 'status' },
];

const inboundData = [
  { id: 'IN20251220001', source: 'XX供应商', type: '采购入库', qty: 500, date: '2025-12-20', operator: '张三', status: 'completed' },
  { id: 'IN20251220002', source: '退货', type: '销售退货', qty: 10, date: '2025-12-20', operator: '李四', status: 'processing' },
];

const outboundColumns = [
  { title: '出库单号', dataIndex: 'id', key: 'id' },
  { title: '去向', dataIndex: 'target', key: 'target' },
  { title: '出库类型', dataIndex: 'type', key: 'type' },
  { title: '数量', dataIndex: 'qty', key: 'qty' },
  { title: '出库日期', dataIndex: 'date', key: 'date' },
  { title: '操作人', dataIndex: 'operator', key: 'operator' },
  { title: '状态', dataIndex: 'status', key: 'status' },
];

const outboundData = [
  { id: 'OUT20251220001', target: 'XX客户', type: '销售出库', qty: 200, date: '2025-12-20', operator: '王五', status: 'shipped' },
  { id: 'OUT20251220002', target: '生产线', type: '领料出库', qty: 50, date: '2025-12-20', operator: '赵六', status: 'picking' },
];
</script>

<style scoped>
.page-container {
  padding: 24px;
  background: #fff;
  min-height: 100%;
}
.filter-bar {
  margin-bottom: 16px;
}
</style>