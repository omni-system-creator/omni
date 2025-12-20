<template>
  <div class="page-container">
    <div class="action-header">
      <div class="left-actions">
        <a-radio-group v-model:value="viewMode" button-style="solid">
          <a-radio-button value="kanban"><AppstoreOutlined /> 看板</a-radio-button>
          <a-radio-button value="list"><BarsOutlined /> 列表</a-radio-button>
        </a-radio-group>
      </div>
      <div class="right-actions">
        <a-button type="primary">
          <template #icon><PlusOutlined /></template>
          新建商机
        </a-button>
      </div>
    </div>

    <div v-if="viewMode === 'kanban'" class="kanban-board">
      <div class="kanban-column" v-for="stage in stages" :key="stage.key">
        <div class="column-header">
          <span class="stage-name">{{ stage.name }}</span>
          <span class="stage-count">{{ getOpportunitiesByStage(stage.key).length }}</span>
        </div>
        <div class="column-content">
          <div class="opportunity-card" v-for="opp in getOpportunitiesByStage(stage.key)" :key="opp.id">
            <div class="card-title">{{ opp.title }}</div>
            <div class="card-customer">{{ opp.customer }}</div>
            <div class="card-amount">¥ {{ opp.amount.toLocaleString() }}</div>
            <div class="card-footer">
              <a-avatar size="small" style="background-color: #87d068">{{ opp.owner[0] }}</a-avatar>
              <span class="date">{{ opp.date }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-else class="list-view">
      <a-table :columns="columns" :data-source="opportunities">
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'stage'">
            <a-tag :color="getStageColor(record.stage)">{{ getStageName(record.stage) }}</a-tag>
          </template>
        </template>
      </a-table>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { AppstoreOutlined, BarsOutlined, PlusOutlined } from '@ant-design/icons-vue';

const viewMode = ref('kanban');

const stages = [
  { key: 'new', name: '初步接洽', color: 'blue' },
  { key: 'proposition', name: '方案报价', color: 'cyan' },
  { key: 'negotiation', name: '商务谈判', color: 'orange' },
  { key: 'won', name: '赢单', color: 'green' },
  { key: 'lost', name: '输单', color: 'red' },
];

const opportunities = ref([
  { id: 1, title: 'XX系统采购项目', customer: '某某科技', amount: 500000, stage: 'new', owner: '张三', date: '2025-12-01' },
  { id: 2, title: '年度维保服务', customer: '上海贸易', amount: 120000, stage: 'proposition', owner: '李四', date: '2025-12-05' },
  { id: 3, title: '私有云部署', customer: '北京咨询', amount: 800000, stage: 'negotiation', owner: '王五', date: '2025-12-10' },
  { id: 4, title: '硬件设备采购', customer: '广州制造', amount: 300000, stage: 'won', owner: '赵六', date: '2025-11-20' },
]);

const columns = [
  { title: '商机名称', dataIndex: 'title', key: 'title' },
  { title: '客户', dataIndex: 'customer', key: 'customer' },
  { title: '预计金额', dataIndex: 'amount', key: 'amount' },
  { title: '阶段', dataIndex: 'stage', key: 'stage' },
  { title: '负责人', dataIndex: 'owner', key: 'owner' },
  { title: '预计成交日期', dataIndex: 'date', key: 'date' },
];

const getOpportunitiesByStage = (stageKey: string) => {
  return opportunities.value.filter(o => o.stage === stageKey);
};

const getStageColor = (key: string) => {
  return stages.find(s => s.key === key)?.color || 'default';
};

const getStageName = (key: string) => {
  return stages.find(s => s.key === key)?.name || key;
};
</script>

<style scoped>
.page-container {
  padding: 24px;
  background: #fff;
  height: 100%;
  display: flex;
  flex-direction: column;
}

.action-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 24px;
}

.kanban-board {
  flex: 1;
  display: flex;
  gap: 16px;
  overflow-x: auto;
  padding-bottom: 16px;
}

.kanban-column {
  width: 280px;
  flex-shrink: 0;
  background: #f5f5f5;
  border-radius: 4px;
  display: flex;
  flex-direction: column;
  padding: 12px;
}

.column-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 12px;
  font-weight: bold;
  color: #333;
}

.column-content {
  flex: 1;
  overflow-y: auto;
}

.opportunity-card {
  background: #fff;
  padding: 12px;
  border-radius: 4px;
  margin-bottom: 12px;
  box-shadow: 0 1px 2px rgba(0,0,0,0.05);
  cursor: pointer;
  transition: all 0.3s;
}

.opportunity-card:hover {
  box-shadow: 0 4px 8px rgba(0,0,0,0.1);
}

.card-title {
  font-weight: 500;
  margin-bottom: 8px;
}

.card-customer {
  font-size: 12px;
  color: #666;
  margin-bottom: 4px;
}

.card-amount {
  font-weight: bold;
  color: #faad14;
  margin-bottom: 8px;
}

.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 12px;
  color: #999;
}
</style>