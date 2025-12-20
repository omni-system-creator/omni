<template>
  <div class="page-container">
    <a-tabs v-model:activeKey="activeTab">
      <a-tab-pane key="transfer" tab="调拨记录">
        <a-button type="primary" style="margin-bottom: 16px">新增调拨</a-button>
        <a-table :columns="transferColumns" :data-source="transferData" />
      </a-tab-pane>
      <a-tab-pane key="shelving" tab="上架记录">
        <a-table :columns="shelvingColumns" :data-source="shelvingData" />
      </a-tab-pane>
      <a-tab-pane key="unshelving" tab="下架记录">
        <a-table :columns="shelvingColumns" :data-source="unshelvingData" />
      </a-tab-pane>
      <a-tab-pane key="packing" tab="装箱/拆箱">
        <div class="filter-bar" style="margin-bottom: 16px">
          <a-radio-group v-model:value="packType" button-style="solid">
            <a-radio-button value="pack">装箱记录</a-radio-button>
            <a-radio-button value="unpack">拆箱记录</a-radio-button>
          </a-radio-group>
        </div>
        <a-table :columns="packColumns" :data-source="packType === 'pack' ? packData : unpackData" />
      </a-tab-pane>
    </a-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';

const activeTab = ref('transfer');
const packType = ref('pack');

const transferColumns = [
  { title: '调拨单号', dataIndex: 'id', key: 'id' },
  { title: '调出仓库', dataIndex: 'from', key: 'from' },
  { title: '调入仓库', dataIndex: 'to', key: 'to' },
  { title: '物品', dataIndex: 'product', key: 'product' },
  { title: '数量', dataIndex: 'qty', key: 'qty' },
  { title: '日期', dataIndex: 'date', key: 'date' },
  { title: '状态', dataIndex: 'status', key: 'status' },
];

const transferData = [
  { id: 'TR20251215001', from: '上海主仓库', to: '北京分仓', product: '物品A', qty: 100, date: '2025-12-15', status: '已完成' },
];

const shelvingColumns = [
  { title: '任务单号', dataIndex: 'id', key: 'id' },
  { title: '物品', dataIndex: 'product', key: 'product' },
  { title: '数量', dataIndex: 'qty', key: 'qty' },
  { title: '库位', dataIndex: 'location', key: 'location' },
  { title: '操作人', dataIndex: 'operator', key: 'operator' },
  { title: '时间', dataIndex: 'time', key: 'time' },
];

const shelvingData = [
  { id: 'SH20251220001', product: '物品B', qty: 50, location: 'A-01-01', operator: '张三', time: '2025-12-20 10:00' },
];

const unshelvingData = [
  { id: 'UN20251220002', product: '物品C', qty: 20, location: 'B-02-01', operator: '李四', time: '2025-12-20 11:30' },
];

const packColumns = [
  { title: '作业单号', dataIndex: 'id', key: 'id' },
  { title: '物品内容', dataIndex: 'content', key: 'content' },
  { title: '箱号', dataIndex: 'boxNo', key: 'boxNo' },
  { title: '操作人', dataIndex: 'operator', key: 'operator' },
  { title: '时间', dataIndex: 'time', key: 'time' },
];

const packData = [
  { id: 'PK20251220001', content: '物品A*10, 物品B*5', boxNo: 'BOX001', operator: '王五', time: '2025-12-20 14:00' },
];

const unpackData = [
  { id: 'UP20251220002', content: '原料X*50', boxNo: 'SUP_BOX_99', operator: '赵六', time: '2025-12-20 09:00' },
];
</script>

<style scoped>
.page-container {
  padding: 24px;
  background: #fff;
  min-height: 100%;
}
</style>