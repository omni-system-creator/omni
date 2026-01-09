<template>
  <div class="warehouse-container">
    <a-row :gutter="16">
      <a-col :span="8" v-for="room in rooms" :key="room.id">
        <a-card :title="room.name" :bordered="false" class="room-card">
          <template #extra>
            <a-tag color="blue">{{ room.status }}</a-tag>
          </template>
          <div class="room-info">
            <p>
              <span>容量使用率：</span>
              <a-progress :percent="room.usage" :status="getUsageStatus(room.usage)" />
            </p>
            <p>总架数：{{ room.racks }} 架</p>
            <p>在库档案盒：{{ room.boxes }} 盒</p>
            <p>环境监控：
              <a-tag color="green">温度 {{ room.temp }}°C</a-tag>
              <a-tag color="cyan">湿度 {{ room.humidity }}%</a-tag>
            </p>
          </div>
        </a-card>
      </a-col>
    </a-row>

    <a-card title="密集架/档案盒管理" :bordered="false" style="margin-top: 16px">
      <template #extra>
        <a-button type="primary">
          <template #icon><PlusOutlined /></template>
          新增库房/架
        </a-button>
      </template>
      
      <a-table :columns="columns" :data-source="boxes">
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'action'">
            <a-space>
              <a-tooltip title="编辑">
                <a-button type="text" size="small" @click="handleEdit(record)">
                  <template #icon><EditOutlined /></template>
                </a-button>
              </a-tooltip>
              <a-tooltip title="查看详情">
                <a-button type="text" size="small" @click="handleView(record)">
                  <template #icon><EyeOutlined /></template>
                </a-button>
              </a-tooltip>
            </a-space>
          </template>
        </template>
      </a-table>
    </a-card>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { PlusOutlined, EditOutlined, EyeOutlined } from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';

const rooms = ref([
  { id: 1, name: '1号库房 (文书)', status: '正常', usage: 85, racks: 20, boxes: 3500, temp: 22, humidity: 45 },
  { id: 2, name: '2号库房 (实物)', status: '正常', usage: 45, racks: 15, boxes: 1200, temp: 21, humidity: 40 },
  { id: 3, name: '3号库房 (机密)', status: '预警', usage: 92, racks: 10, boxes: 1800, temp: 23, humidity: 50 },
]);

const getUsageStatus = (usage: number) => {
  if (usage >= 90) return 'exception';
  if (usage >= 80) return 'active';
  return 'success';
};

const columns: ColumnType[] = [
  { title: '编号', dataIndex: 'code', key: 'code' },
  { title: '名称', dataIndex: 'name', key: 'name' },
  { title: '所属库房', dataIndex: 'room', key: 'room' },
  { title: '层数', dataIndex: 'layers', key: 'layers' },
  { title: '容量 (盒)', dataIndex: 'capacity', key: 'capacity' },
  { title: '当前存量', dataIndex: 'current', key: 'current' },
  { title: '操作', key: 'action', width: 200 }
];

const boxes = ref([
  { key: '1', code: 'R-01-A', name: 'A区01号密集架', room: '1号库房', layers: 6, capacity: 600, current: 520 },
  { key: '2', code: 'R-01-B', name: 'A区02号密集架', room: '1号库房', layers: 6, capacity: 600, current: 480 },
  { key: '3', code: 'R-02-A', name: 'B区01号货架', room: '2号库房', layers: 5, capacity: 200, current: 150 },
]);

const handleEdit = (record: any) => {
  message.info(`编辑架体：${record.name}`);
};

const handleView = (record: any) => {
  message.info(`查看详情：${record.name}`);
};
</script>

<style scoped>
.warehouse-container {
  padding: 24px;
}
.room-card {
  margin-bottom: 16px;
}
.room-info p {
  margin-bottom: 8px;
}
</style>
