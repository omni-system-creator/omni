<template>
  <div class="app-container">
    <SplitLayout position="left" :initialWidth="280" :minWidth="220" :maxWidth="400">
      <template #sidebar>
        <a-card title="区域导航" class="tree-card" :bordered="false">
          <div class="scroll-panel">
            <a-tree
              :tree-data="areaTreeData"
              :default-expanded-keys="defaultExpandedKeys"
              :selected-keys="selectedKeys"
              @select="onSelect"
            />
          </div>
        </a-card>
      </template>
      <template #main>
        <div class="main-content">
          <a-card class="stat-card" :bordered="false">
            <a-row :gutter="16">
              <a-col :span="6">
                <a-statistic title="设备总数" :value="48" />
              </a-col>
              <a-col :span="6">
                <a-statistic title="运行中" :value="42" :value-style="{ color: '#3f8600' }" />
              </a-col>
              <a-col :span="6">
                <a-statistic title="故障/维护" :value="2" :value-style="{ color: '#cf1322' }" />
              </a-col>
              <a-col :span="6">
                <a-statistic title="综合效率 (OEE)" :value="88.5" suffix="%" :precision="1" />
              </a-col>
            </a-row>
          </a-card>

          <a-card title="设备列表" class="list-card" :bordered="false">
            <template #extra>
              <a-radio-group v-model:value="viewMode" button-style="solid">
                <a-radio-button value="grid">视图</a-radio-button>
                <a-radio-button value="list">列表</a-radio-button>
              </a-radio-group>
            </template>

            <div class="scroll-panel">
              <div v-if="viewMode === 'grid'">
                <a-row :gutter="[16, 16]">
                  <a-col :span="6" v-for="device in devices" :key="device.id">
                    <a-card hoverable class="device-card">
                      <template #actions>
                        <span key="setting">详情</span>
                        <span key="edit">维保</span>
                      </template>
                      <a-card-meta :title="device.name" :description="device.code">
                        <template #avatar>
                          <div class="device-status" :class="device.status">
                            {{ device.status === 'Running' ? '运行' : (device.status === 'Stopped' ? '停机' : '故障') }}
                          </div>
                        </template>
                      </a-card-meta>
                      <div style="margin-top: 16px">
                        <div class="device-info-item">
                          <span>负荷率</span>
                          <a-progress :percent="device.load" size="small" :status="device.load > 90 ? 'exception' : 'normal'" />
                        </div>
                        <div class="device-info-item">
                          <span>当前工单</span>
                          <span>{{ device.order || '-' }}</span>
                        </div>
                      </div>
                    </a-card>
                  </a-col>
                </a-row>
              </div>

              <a-table v-else :columns="columns" :data-source="devices" :pagination="false" />
            </div>
          </a-card>
        </div>
      </template>
    </SplitLayout>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import type { TreeProps } from 'ant-design-vue';
import SplitLayout from '@/components/SplitLayout/index.vue';

const viewMode = ref('grid');
const selectedKeys = ref(['WORKSHOP-001']);

const areaTreeData = [
  {
    title: '华东生产基地',
    key: 'SITE-001',
    children: [
      {
        title: '一号厂房 (电子组装)',
        key: 'PLANT-001',
        children: [
          { title: 'SMT车间', key: 'WORKSHOP-001', isLeaf: true },
          { title: 'DIP车间', key: 'WORKSHOP-002', isLeaf: true },
          { title: '组装车间', key: 'WORKSHOP-003', isLeaf: true },
        ],
      },
      {
        title: '二号厂房 (精密加工)',
        key: 'PLANT-002',
        children: [
          { title: 'CNC车间', key: 'WORKSHOP-004', isLeaf: true },
          { title: '注塑车间', key: 'WORKSHOP-005', isLeaf: true },
        ],
      },
    ],
  },
];

const defaultExpandedKeys = [
  ...areaTreeData.map(n => n.key),
  ...(areaTreeData[0]?.children?.map(n => n.key) || [])
];

const onSelect: TreeProps['onSelect'] = (keys) => {
  if (keys && keys.length > 0) {
    selectedKeys.value = keys as string[];
  }
};



const columns: ColumnType[] = [
  { title: '设备编号', dataIndex: 'code', key: 'code' },
  { title: '设备名称', dataIndex: 'name', key: 'name' },
  { title: '状态', dataIndex: 'status', key: 'status' },
  { title: '负荷率', dataIndex: 'load', key: 'load' },
  { title: '当前工单', dataIndex: 'order', key: 'order' },
  { title: '位置', dataIndex: 'location', key: 'location' },
];

const devices = ref([
  { id: 1, name: '高速贴片机 A1', code: 'SMT-001', status: 'Running', load: 85, order: 'WO-20240108-01', location: '一号厂房/SMT车间' },
  { id: 2, name: '高速贴片机 A2', code: 'SMT-002', status: 'Running', load: 92, order: 'WO-20240108-01', location: '一号厂房/SMT车间' },
  { id: 3, name: '回流焊炉 R1', code: 'RFW-001', status: 'Running', load: 60, order: 'WO-20240108-01', location: '一号厂房/SMT车间' },
  { id: 4, name: 'AOI 检测机', code: 'AOI-001', status: 'Running', load: 75, order: 'WO-20240108-01', location: '一号厂房/SMT车间' },
  { id: 5, name: '波峰焊机 W1', code: 'WAVE-001', status: 'Error', load: 0, order: 'WO-20240108-02', location: '一号厂房/DIP车间' },
  { id: 6, name: '自动螺丝机', code: 'SCR-001', status: 'Stopped', load: 0, order: '-', location: '一号厂房/组装车间' },
  { id: 7, name: '包装流水线', code: 'PACK-001', status: 'Running', load: 40, order: 'WO-20240108-03', location: '一号厂房/组装车间' },
  { id: 8, name: '激光打标机', code: 'MARK-001', status: 'Running', load: 30, order: 'WO-20240108-03', location: '一号厂房/组装车间' },
]);
</script>

<style scoped>
.app-container {
  padding: 10px;
  flex: 1;
  overflow: hidden;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
}
.app-container :deep(.split-layout) {
  flex: 1;
  width: 100%;
  height: 100%;
  overflow: hidden;
}

.tree-card {
  height: 100%;
  display: flex;
  flex-direction: column;
}
.tree-card :deep(.ant-card-body) {
  flex: 1;
  min-height: 0;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  padding: 16px 0 0 16px;
}

.main-content {
  height: 100%;
  display: flex;
  flex-direction: column;
  gap: 10px;
  overflow: hidden;
}

.stat-card {
  flex-shrink: 0;
}

.list-card {
  flex: 1;
  min-height: 0;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
.list-card :deep(.ant-card-body) {
  flex: 1;
  min-height: 0;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  padding: 16px;
}

.scroll-panel {
  flex: 1;
  min-height: 0;
  overflow-y: auto;
  overflow-x: hidden;
}

.device-status {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 12px;
}
.device-status.Running {
  background-color: #52c41a;
}
.device-status.Stopped {
  background-color: #d9d9d9;
  color: #666;
}
.device-status.Error {
  background-color: #ff4d4f;
}
.device-info-item {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
  font-size: 12px;
  color: #666;
}
</style>
