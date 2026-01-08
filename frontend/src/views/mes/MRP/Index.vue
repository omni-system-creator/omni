<template>
  <div class="app-container">
    <a-card title="物料需求计划 (MRP)" :bordered="false">
      <template #extra>
        <a-space>
          <a-button type="primary">运算MRP</a-button>
          <a-button>缺料分析</a-button>
        </a-space>
      </template>

      <a-alert
        message="缺料预警"
        description="检测到 3 项物料库存不足，可能影响 MPS-202401-002 生产计划，请及时处理。"
        type="warning"
        show-icon
        style="margin-bottom: 24px"
      />

      <a-table :columns="columns" :data-source="data" :pagination="false">
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'shortage'">
            <span v-if="record.shortage > 0" style="color: #ff4d4f; font-weight: bold;">
              -{{ record.shortage }}
            </span>
            <span v-else style="color: #52c41a">充足</span>
          </template>
          <template v-else-if="column.key === 'source'">
            <a-tag color="purple">{{ record.source }}</a-tag>
          </template>
          <template v-else-if="column.key === 'action'">
            <a-space size="small">
              <a v-if="record.shortage > 0">生成采购申请</a>
              <a v-else>查看库存</a>
            </a-space>
          </template>
        </template>
      </a-table>
    </a-card>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';

const columns = [
  { title: '物料编码', dataIndex: 'code', key: 'code' },
  { title: '物料名称', dataIndex: 'name', key: 'name' },
  { title: '关联计划', dataIndex: 'source', key: 'source' },
  { title: '需求日期', dataIndex: 'date', key: 'date' },
  { title: '需求数量', dataIndex: 'required', key: 'required' },
  { title: '当前库存', dataIndex: 'stock', key: 'stock' },
  { title: '缺口', dataIndex: 'shortage', key: 'shortage' },
  { title: '操作', key: 'action' },
];

const data = ref([
  {
    key: '1',
    code: 'MT-CPU-001',
    name: '高性能处理器 i7',
    source: 'MPS-202401-001',
    date: '2024-01-12',
    required: 500,
    stock: 200,
    shortage: 300,
  },
  {
    key: '2',
    code: 'MT-CASE-A1',
    name: '服务器机箱 A1型',
    source: 'MPS-202401-001',
    date: '2024-01-10',
    required: 500,
    stock: 550,
    shortage: 0,
  },
  {
    key: '3',
    code: 'MT-PANEL-X5',
    name: 'LCD 显示屏 10寸',
    source: 'MPS-202401-002',
    date: '2024-01-16',
    required: 1200,
    stock: 800,
    shortage: 400,
  },
  {
    key: '4',
    code: 'MT-PCB-MAIN',
    name: '主控电路板',
    source: 'MPS-202401-002',
    date: '2024-01-16',
    required: 1200,
    stock: 1200,
    shortage: 0,
  },
  {
    key: '5',
    code: 'MT-SCREW-M3',
    name: 'M3 螺丝包',
    source: '通用库存',
    date: '2024-01-15',
    required: 10000,
    stock: 5000,
    shortage: 5000,
  },
]);
</script>

<style scoped>
.app-container {
  padding: 20px;
}
</style>
