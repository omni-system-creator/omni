<template>
  <div class="app-container">
    <a-card title="成本控制 (Cost Control)" :bordered="false">
      <template #extra>
        <a-date-picker picker="month" placeholder="选择月份" />
      </template>
      
      <a-row :gutter="24" style="margin-bottom: 24px;">
        <a-col :span="6">
          <a-card :bordered="true" size="small">
            <template #title>总生产成本</template>
            <div class="cost-value">¥ 1,245,000</div>
            <div class="cost-trend up">
              环比 +5.2%
            </div>
          </a-card>
        </a-col>
        <a-col :span="6">
          <a-card :bordered="true" size="small">
            <template #title>材料成本 (65%)</template>
            <div class="cost-value">¥ 809,250</div>
            <div class="cost-trend down">
              环比 -1.2%
            </div>
          </a-card>
        </a-col>
        <a-col :span="6">
          <a-card :bordered="true" size="small">
            <template #title>人工成本 (20%)</template>
            <div class="cost-value">¥ 249,000</div>
            <div class="cost-trend up">
              环比 +2.0%
            </div>
          </a-card>
        </a-col>
        <a-col :span="6">
          <a-card :bordered="true" size="small">
            <template #title>制造费用 (15%)</template>
            <div class="cost-value">¥ 186,750</div>
            <div class="cost-trend up">
              环比 +12.5%
            </div>
          </a-card>
        </a-col>
      </a-row>

      <a-table :columns="columns" :data-source="costDetails" :pagination="false">
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'variance'">
            <span :style="{ color: record.variance > 0 ? '#ff4d4f' : '#52c41a' }">
              {{ record.variance > 0 ? '+' : '' }}{{ record.variance }}%
            </span>
          </template>
           <template v-if="column.key === 'amount'">
            ¥ {{ record.amount.toLocaleString() }}
          </template>
        </template>
      </a-table>
    </a-card>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';

const columns: ColumnType[] = [
  { title: '成本项目', dataIndex: 'item', key: 'item' },
  { title: '预算金额', dataIndex: 'budget', key: 'budget' },
  { title: '实际金额', dataIndex: 'amount', key: 'amount' },
  { title: '差异率', dataIndex: 'variance', key: 'variance' },
  { title: '说明', dataIndex: 'note', key: 'note' },
];

const costDetails = ref([
  { key: '1', item: '直接材料', budget: '820,000', amount: 809250, variance: -1.3, note: '大宗采购折扣' },
  { key: '2', item: '直接人工', budget: '240,000', amount: 249000, variance: 3.75, note: '加班费增加' },
  { key: '3', item: '水电能耗', budget: '50,000', amount: 58000, variance: 16.0, note: '设备利用率提升' },
  { key: '4', item: '设备折旧', budget: '80,000', amount: 80000, variance: 0, note: '-' },
  { key: '5', item: '维修费用', budget: '20,000', amount: 48750, variance: 143.75, note: 'WAVE-001 突发故障维修' },
]);
</script>

<style scoped>
.app-container {
  padding: 10px;
}
.cost-value {
  font-size: 24px;
  font-weight: bold;
  color: #333;
  margin: 8px 0;
}
.cost-trend {
  font-size: 12px;
}
.cost-trend.up {
  color: #ff4d4f;
}
.cost-trend.down {
  color: #52c41a;
}
</style>
