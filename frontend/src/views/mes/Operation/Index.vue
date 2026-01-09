<template>
  <div class="app-container">
    <a-row :gutter="16">
      <a-col :span="16">
        <a-card title="车间作业监控 (Operation)" :bordered="false" style="margin-bottom: 16px;">
          <a-table :columns="columns" :data-source="activeOrders" :pagination="false">
            <template #bodyCell="{ column, record }">
              <template v-if="column.key === 'status'">
                <a-badge :status="getBadgeStatus(record.status)" :text="record.status" />
              </template>
              <template v-else-if="column.key === 'progress'">
                <a-progress :percent="record.progress" :steps="5" size="small" :stroke-color="record.status === '异常' ? '#ff4d4f' : '#1890ff'" />
              </template>
              <template v-else-if="column.key === 'action'">
                <a-space>
                  <a>报工</a>
                  <a>暂停</a>
                </a-space>
              </template>
            </template>
          </a-table>
        </a-card>
      </a-col>
      <a-col :span="8">
        <a-card title="产线状态" :bordered="false" style="margin-bottom: 16px;">
          <a-list item-layout="horizontal" :data-source="lines">
            <template #renderItem="{ item }">
              <a-list-item>
                <a-list-item-meta
                  :description="item.currentOrder ? `当前生产: ${item.currentOrder}` : '空闲'"
                >
                  <template #title>
                    <span>{{ item.name }}</span>
                    <a-tag :color="item.status === '运行中' ? 'green' : 'orange'" style="margin-left: 8px">{{ item.status }}</a-tag>
                  </template>
                  <template #avatar>
                    <div class="line-avatar" :class="{ running: item.status === '运行中' }">
                      {{ item.code }}
                    </div>
                  </template>
                </a-list-item-meta>
              </a-list-item>
            </template>
          </a-list>
        </a-card>

        <a-card title="今日产量" :bordered="false">
          <div style="text-align: center; padding: 20px 0;">
            <a-progress type="dashboard" :percent="75" :gap-degree="60">
              <template #format="{ percent }">
                <div style="font-size: 24px">{{ percent }}%</div>
                <div style="font-size: 12px; color: #999">目标达成</div>
              </template>
            </a-progress>
            <div style="display: flex; justify-content: space-around; margin-top: 16px;">
              <div>
                <div style="color: #999">计划</div>
                <div style="font-size: 18px; font-weight: bold">2000</div>
              </div>
              <div>
                <div style="color: #999">实产</div>
                <div style="font-size: 18px; font-weight: bold; color: #1890ff">1500</div>
              </div>
            </div>
          </div>
        </a-card>
      </a-col>
    </a-row>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';


const columns: ColumnType[] = [
  { title: '工单号', dataIndex: 'id', key: 'id' },
  { title: '工序', dataIndex: 'process', key: 'process' },
  { title: '设备/工位', dataIndex: 'station', key: 'station' },
  { title: '操作员', dataIndex: 'operator', key: 'operator' },
  { title: '进度', dataIndex: 'progress', key: 'progress' },
  { title: '状态', dataIndex: 'status', key: 'status' },
  { title: '操作', key: 'action' },
];



const getBadgeStatus = (status: string): PresetStatusColorType => {
  switch (status) {
    case '运行中':
      return 'processing';
    case '异常':
      return 'error';
    case '等待':
      return 'default';
    case '完成':
      return 'success';
    default:
      return 'default';
  }
};

const activeOrders = ref([
  {
    key: '1',
    id: 'WO-20240108-01',
    process: 'SMT贴片',
    station: 'SMT-L01',
    operator: '张三',
    progress: 80,
    status: '运行中',
  },
  {
    key: '2',
    id: 'WO-20240108-02',
    process: 'DIP插件',
    station: 'DIP-L02',
    operator: '李四',
    progress: 45,
    status: '运行中',
  },
  {
    key: '3',
    id: 'WO-20240108-03',
    process: '组装测试',
    station: 'ASSY-05',
    operator: '王五',
    progress: 20,
    status: '异常',
  },
  {
    key: '4',
    id: 'WO-20240108-04',
    process: '包装',
    station: 'PACK-01',
    operator: '赵六',
    progress: 0,
    status: '等待',
  },
]);

const lines = ref([
  { name: 'SMT 自动化线', code: 'L1', status: '运行中', currentOrder: 'WO-20240108-01' },
  { name: 'DIP 波峰焊线', code: 'L2', status: '运行中', currentOrder: 'WO-20240108-02' },
  { name: '总装线 A', code: 'L3', status: '维护中', currentOrder: null },
  { name: '总装线 B', code: 'L4', status: '运行中', currentOrder: 'WO-20240108-03' },
]);


</script>

<style scoped>
.app-container {
  padding: 20px;
}
.line-avatar {
  width: 40px;
  height: 40px;
  background: #f0f0f0;
  border-radius: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  color: #666;
}
.line-avatar.running {
  background: #e6f7ff;
  color: #1890ff;
}
</style>
