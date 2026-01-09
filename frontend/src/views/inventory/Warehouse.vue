<template>
  <div class="page-container">
    <a-tabs v-model:activeKey="activeTab">
      <a-tab-pane key="info" tab="仓库信息">
        <div class="action-bar">
          <a-button type="primary"><PlusOutlined /> 新增仓库</a-button>
        </div>
        <a-table :columns="warehouseColumns" :data-source="warehouseData" style="margin-top: 16px">
          <template #bodyCell="{ column, record }">
            <template v-if="column.key === 'status'">
              <a-badge :status="record.status === 'active' ? 'success' : 'error'" :text="record.status === 'active' ? '启用' : '停用'" />
            </template>
          </template>
        </a-table>
      </a-tab-pane>
      
      <a-tab-pane key="zone" tab="库区库位">
        <div class="filter-bar">
          <a-select placeholder="选择仓库" style="width: 200px">
            <a-select-option value="1">主仓库</a-select-option>
            <a-select-option value="2">冷链仓</a-select-option>
          </a-select>
          <a-button type="primary" style="margin-left: 16px"><PlusOutlined /> 新增库位</a-button>
        </div>
        <a-table :columns="binColumns" :data-source="binData" style="margin-top: 16px" />
      </a-tab-pane>
      
      <a-tab-pane key="env" tab="库存环境">
        <a-row :gutter="16">
          <a-col :span="8" v-for="item in envData" :key="item.id">
            <a-card :title="item.warehouse" style="margin-bottom: 16px">
              <template #extra>
                <a-tag :color="item.status === 'normal' ? 'green' : 'red'">{{ item.status === 'normal' ? '正常' : '异常' }}</a-tag>
              </template>
              <a-statistic title="温度" :value="item.temp" suffix="°C" :value-style="{ color: item.temp > 30 ? '#cf1322' : '#3f8600' }" />
              <a-statistic title="湿度" :value="item.humidity" suffix="%" style="margin-top: 16px" />
            </a-card>
          </a-col>
        </a-row>
      </a-tab-pane>
    </a-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { PlusOutlined } from '@ant-design/icons-vue'
const activeTab = ref('info');

const warehouseColumns: ColumnType[] = [
  { title: '仓库编号', dataIndex: 'code', key: 'code' },
  { title: '仓库名称', dataIndex: 'name', key: 'name' },
  { title: '类型', dataIndex: 'type', key: 'type' },
  { title: '负责人', dataIndex: 'manager', key: 'manager' },
  { title: '地址', dataIndex: 'address', key: 'address' },
  { title: '状态', dataIndex: 'status', key: 'status' },
  { title: '操作', key: 'action' },
];

const warehouseData = [
  { code: 'WH001', name: '上海主仓库', type: '普通仓', manager: '张三', address: '上海市浦东新区XX路', status: 'active' },
  { code: 'WH002', name: '北京分仓', type: '普通仓', manager: '李四', address: '北京市朝阳区XX路', status: 'active' },
  { code: 'WH003', name: '广州冷链仓', type: '冷库', manager: '王五', address: '广州市白云区XX路', status: 'active' },
  { code: 'WH004', name: '生产线边仓', type: '线边仓', manager: '赵六', address: '上海工厂A区', status: 'active' },
  { code: 'WH005', name: '虚拟退货仓', type: '虚拟仓', manager: '售后部', address: '-', status: 'active' },
];

const binColumns = [
  { title: '库区编号', dataIndex: 'zoneCode', key: 'zoneCode' },
  { title: '库区名称', dataIndex: 'zoneName', key: 'zoneName' },
  { title: '货架号', dataIndex: 'shelf', key: 'shelf' },
  { title: '层号', dataIndex: 'level', key: 'level' },
  { title: '位号', dataIndex: 'position', key: 'position' },
  { title: '存储类型', dataIndex: 'type', key: 'type' },
];

const binData = [
  { zoneCode: 'Z01', zoneName: '电子产品区', shelf: 'A01', level: '1', position: '01', type: '货架' },
  { zoneCode: 'Z01', zoneName: '电子产品区', shelf: 'A01', level: '1', position: '02', type: '货架' },
  { zoneCode: 'Z02', zoneName: '大件存储区', shelf: 'B01', level: '-', position: '01', type: '地堆' },
];

const envData = [
  { id: 1, warehouse: '上海主仓库', temp: 24, humidity: 45, status: 'normal' },
  { id: 2, warehouse: '广州冷链仓', temp: -18, humidity: 60, status: 'normal' },
  { id: 3, warehouse: '药品恒温仓', temp: 28, humidity: 80, status: 'warning' },
];
</script>

<style scoped>
.page-container {
  padding: 24px;
  background: #fff;
  min-height: 100%;
}
.action-bar, .filter-bar {
  margin-bottom: 16px;
}
</style>