<template>
  <div class="page-container">
    <div class="filter-bar">
      <a-input-search placeholder="搜索物品编码/名称" style="width: 250px" />
      <a-select v-model:value="typeFilter" style="width: 150px; margin-left: 16px" placeholder="物品类型">
        <a-select-option value="all">全部类型</a-select-option>
        <a-select-option value="raw_material">原材料</a-select-option>
        <a-select-option value="semi_finished">半成品</a-select-option>
        <a-select-option value="finished">成品</a-select-option>
        <a-select-option value="consumable">耗材</a-select-option>
        <a-select-option value="tool">工治具</a-select-option>
      </a-select>
      <a-button type="primary" style="margin-left: 16px">新增物品</a-button>
    </div>

    <a-table :columns="columns" :data-source="filteredData" style="margin-top: 16px">
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'type'">
          <a-tag :color="getTypeColor(record.type)">{{ getTypeLabel(record.type) }}</a-tag>
        </template>
        <template v-else-if="column.key === 'status'">
          <a-badge :status="record.status === 'active' ? 'success' : 'default'" :text="record.status === 'active' ? '启用' : '停用'" />
        </template>
        <template v-else-if="column.key === 'action'">
          <a-space>
            <a>编辑</a>
            <a>查看库存</a>
          </a-space>
        </template>
      </template>
    </a-table>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';

const typeFilter = ref('all');

const columns = [
  { title: '物品编码', dataIndex: 'code', key: 'code' },
  { title: '物品名称', dataIndex: 'name', key: 'name' },
  { title: '规格型号', dataIndex: 'spec', key: 'spec' },
  { title: '物品类型', dataIndex: 'type', key: 'type' },
  { title: '单位', dataIndex: 'unit', key: 'unit' },
  { title: '状态', dataIndex: 'status', key: 'status' },
  { title: '操作', key: 'action' },
];

const data = [
  { code: 'M001', name: '304不锈钢板', spec: '2mm*1000mm*2000mm', type: 'raw_material', unit: '张', status: 'active' },
  { code: 'P001', name: '智能控制器', spec: 'V2.0', type: 'finished', unit: '台', status: 'active' },
  { code: 'S001', name: 'PCB主板', spec: 'Revision A', type: 'semi_finished', unit: '块', status: 'active' },
  { code: 'C001', name: '包装纸箱', spec: '500*400*300', type: 'consumable', unit: '个', status: 'active' },
  { code: 'T001', name: '电动螺丝刀', spec: '24V', type: 'tool', unit: '把', status: 'active' },
];

const filteredData = computed(() => {
  if (typeFilter.value === 'all') return data;
  return data.filter(item => item.type === typeFilter.value);
});

const getTypeLabel = (type: string) => {
  const map: Record<string, string> = {
    raw_material: '原材料',
    semi_finished: '半成品',
    finished: '成品',
    consumable: '耗材',
    tool: '工治具',
  };
  return map[type] || type;
};

const getTypeColor = (type: string) => {
  const map: Record<string, string> = {
    raw_material: 'blue',
    semi_finished: 'cyan',
    finished: 'green',
    consumable: 'orange',
    tool: 'purple',
  };
  return map[type] || 'default';
};
</script>

<style scoped>
.page-container {
  padding: 24px;
  background: #fff;
  min-height: 100%;
}
.filter-bar {
  display: flex;
  align-items: center;
}
</style>