<template>
  <div class="app-container">
    <a-row :gutter="16">
      <a-col :span="16">
        <a-card title="质量管理 (QMS)" :bordered="false" style="margin-bottom: 16px;">
          <template #extra>
            <a-button type="primary" danger>登记缺陷</a-button>
          </template>
          <a-table :columns="columns" :data-source="inspections" :pagination="false">
             <template #bodyCell="{ column, record }">
              <template v-if="column.key === 'result'">
                <a-tag :color="record.result === 'PASS' ? 'green' : 'red'">{{ record.result }}</a-tag>
              </template>
            </template>
          </a-table>
        </a-card>
      </a-col>
      <a-col :span="8">
        <a-card title="质量概览" :bordered="false" style="margin-bottom: 16px;">
          <div class="stat-item">
            <div class="stat-label">直通率 (FPY)</div>
            <a-progress :percent="98.5" status="active" />
          </div>
          <div class="stat-item">
            <div class="stat-label">不良率 (Defect Rate)</div>
            <a-progress :percent="1.5" status="exception" />
          </div>
          <div class="stat-item">
            <div class="stat-label">客户投诉</div>
            <div style="font-size: 24px; font-weight: bold; margin-top: 4px;">0</div>
          </div>
        </a-card>

        <a-card title="缺陷分布 (Top 5)" :bordered="false">
          <div v-for="item in defects" :key="item.name" style="margin-bottom: 12px;">
            <div style="display: flex; justify-content: space-between;">
              <span>{{ item.name }}</span>
              <span>{{ item.count }}</span>
            </div>
            <a-progress :percent="item.percent" size="small" :show-info="false" stroke-color="orange" />
          </div>
        </a-card>
      </a-col>
    </a-row>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';

const columns = [
  { title: '检验单号', dataIndex: 'id', key: 'id' },
  { title: '关联工单', dataIndex: 'order', key: 'order' },
  { title: '检验项目', dataIndex: 'item', key: 'item' },
  { title: '检验时间', dataIndex: 'time', key: 'time' },
  { title: '检验员', dataIndex: 'inspector', key: 'inspector' },
  { title: '结果', dataIndex: 'result', key: 'result' },
];

const inspections = ref([
  { key: '1', id: 'QC-20240108-001', order: 'WO-20240108-01', item: '首件检验', time: '09:00', inspector: 'Q01', result: 'PASS' },
  { key: '2', id: 'QC-20240108-002', order: 'WO-20240108-01', item: '过程巡检', time: '11:00', inspector: 'Q01', result: 'PASS' },
  { key: '3', id: 'QC-20240108-003', order: 'WO-20240108-02', item: '首件检验', time: '09:30', inspector: 'Q02', result: 'PASS' },
  { key: '4', id: 'QC-20240108-004', order: 'WO-20240108-03', item: '入库抽检', time: '14:00', inspector: 'Q03', result: 'FAIL' },
]);

const defects = ref([
  { name: '虚焊', count: 12, percent: 40 },
  { name: '划痕', count: 8, percent: 25 },
  { name: '元件错件', count: 5, percent: 15 },
  { name: '异色', count: 3, percent: 10 },
  { name: '其他', count: 2, percent: 10 },
]);
</script>

<style scoped>
.app-container {
  padding: 20px;
}
.stat-item {
  margin-bottom: 24px;
}
.stat-label {
  color: #666;
  margin-bottom: 8px;
}
</style>
