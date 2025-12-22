<template>
  <div class="vehicles-container">
    <!-- Stats Dashboard -->
    <a-row :gutter="16" class="stats-dashboard">
      <a-col :span="6">
        <a-card hoverable class="stat-card">
          <a-statistic title="车辆总数" :value="45" style="margin-right: 50px">
            <template #prefix><CarOutlined /></template>
          </a-statistic>
          <div class="stat-footer">公务轿车: 20 | 商务车: 15 | 大巴: 10</div>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card hoverable class="stat-card">
          <a-statistic title="今日出勤率" :value="78.5" suffix="%" :precision="1">
            <template #prefix><DashboardOutlined /></template>
          </a-statistic>
          <a-progress :percent="78.5" :show-info="false" size="small" status="active" />
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card hoverable class="stat-card">
          <a-statistic title="待审批用车申请" :value="5" value-style="color: #faad14">
            <template #prefix><FileProtectOutlined /></template>
          </a-statistic>
          <div class="stat-footer">紧急申请: 1</div>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card hoverable class="stat-card">
          <a-statistic title="本月维修保养" :value="3">
            <template #prefix><ToolOutlined /></template>
          </a-statistic>
          <div class="stat-footer">即将年检: 2</div>
        </a-card>
      </a-col>
    </a-row>

    <!-- Main Operations Area -->
    <a-card :bordered="false" title="车辆调度管理平台">
      <template #extra>
        <a-space>
          <a-radio-group v-model:value="viewMode" button-style="solid">
            <a-radio-button value="list">列表视图</a-radio-button>
            <a-radio-button value="map">分布地图</a-radio-button>
          </a-radio-group>
          <a-button type="primary">
            <template #icon><PlusOutlined /></template> 新增车辆
          </a-button>
        </a-space>
      </template>

      <!-- Search Filters -->
      <a-form layout="inline" class="table-search">
        <a-form-item label="车牌号">
          <a-input placeholder="请输入车牌号" />
        </a-form-item>
        <a-form-item label="车辆状态">
          <a-select style="width: 120px" placeholder="全部">
            <a-select-option value="all">全部</a-select-option>
            <a-select-option value="available">空闲</a-select-option>
            <a-select-option value="using">使用中</a-select-option>
            <a-select-option value="maintenance">维修中</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item>
          <a-button type="primary">查询</a-button>
        </a-form-item>
      </a-form>

      <!-- Vehicle Table -->
      <a-table :columns="columns" :data-source="data" style="margin-top: 16px">
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'plate'">
            <a-space>
              <div class="plate-number">{{ record.plate }}</div>
              <a-tag v-if="record.type === 'EV'" color="green">新能源</a-tag>
            </a-space>
          </template>
          
          <template v-else-if="column.key === 'status'">
            <a-badge :status="getStatusBadge(record.status)" :text="getStatusText(record.status)" />
          </template>

          <template v-else-if="column.key === 'driver'">
            <a-avatar size="small" style="background-color: #87d068" v-if="record.driver">{{ record.driver.charAt(0) }}</a-avatar>
            <span style="margin-left: 8px">{{ record.driver || '-' }}</span>
          </template>

          <template v-else-if="column.key === 'mileage'">
            {{ record.mileage.toLocaleString() }} km
          </template>

          <template v-else-if="column.key === 'action'">
            <a-space>
              <a v-if="record.status === 'available'">派车</a>
              <a v-if="record.status === 'using'">还车</a>
              <a-divider type="vertical" />
              <a>轨迹</a>
              <a-divider type="vertical" />
              <a>档案</a>
            </a-space>
          </template>
        </template>
      </a-table>
    </a-card>

    <!-- Dispatch Modal (Simplified Visual) -->
    <a-row :gutter="24" style="margin-top: 24px">
      <a-col :span="12">
        <a-card title="今日用车动态" :bordered="false">
          <a-steps direction="vertical" size="small" :current="1">
            <a-step title="已出发" description="粤B·12345 | 张师傅 | 前往市政府送文件 (09:30)" />
            <a-step title="进行中" description="粤B·67890 | 李师傅 | 机场接送贵宾 (10:15)" />
            <a-step title="待出发" description="粤B·54321 | 王师傅 | 研发中心设备运输 (14:00)" />
          </a-steps>
        </a-card>
      </a-col>
      <a-col :span="12">
        <a-card title="油耗/电耗统计" :bordered="false">
           <div style="height: 200px; display: flex; justify-content: center; align-items: center; background: #fafafa; color: #999;">
             图表区域 (ECharts Placeholder)
           </div>
        </a-card>
      </a-col>
    </a-row>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import {
  CarOutlined,
  DashboardOutlined,
  FileProtectOutlined,
  ToolOutlined,
  PlusOutlined
} from '@ant-design/icons-vue';

const viewMode = ref('list');

const columns = [
  { title: '车牌号', dataIndex: 'plate', key: 'plate' },
  { title: '品牌型号', dataIndex: 'model', key: 'model' },
  { title: '类型', dataIndex: 'category', key: 'category' },
  { title: '当前驾驶员', dataIndex: 'driver', key: 'driver' },
  { title: '当前状态', dataIndex: 'status', key: 'status' },
  { title: '当前位置', dataIndex: 'location', key: 'location' },
  { title: '总里程', dataIndex: 'mileage', key: 'mileage', sorter: true },
  { title: '操作', key: 'action' },
];

const data = [
  { key: 1, plate: '京A·00001', model: '奥迪 A6L', category: '公务轿车', type: 'Fuel', driver: '张伟', status: 'using', location: '朝阳区·国贸三期', mileage: 58000 },
  { key: 2, plate: '京A·88888', model: '丰田 考斯特', category: '商务大巴', type: 'Fuel', driver: null, status: 'available', location: '总部地库 B2-A01', mileage: 120000 },
  { key: 3, plate: '京A·D1234', model: '比亚迪 汉', category: '公务轿车', type: 'EV', driver: '李强', status: 'maintenance', location: '4S店维修中心', mileage: 25000 },
  { key: 4, plate: '京A·D5678', model: '别克 GL8', category: '商务车', type: 'EV', driver: null, status: 'available', location: '总部地库 B2-A02', mileage: 45000 },
  { key: 5, plate: '京A·99999', model: '帕萨特', category: '公务轿车', type: 'Fuel', driver: '王建国', status: 'using', location: '海淀区·中关村', mileage: 89000 },
];

const getStatusBadge = (status: string) => {
  const map: Record<string, string> = {
    available: 'success',
    using: 'processing',
    maintenance: 'error',
    scrapped: 'default',
  };
  return map[status] || 'default';
};

const getStatusText = (status: string) => {
  const map: Record<string, string> = {
    available: '空闲待命',
    using: '执行任务',
    maintenance: '维修保养',
    scrapped: '已报废',
  };
  return map[status] || status;
};
</script>

<style scoped>
.vehicles-container {
  padding: 16px;
  flex: 1;
}
.stats-dashboard {
  margin-bottom: 24px;
}
.stat-card {
  height: 100%;
}
.stat-footer {
  margin-top: 8px;
  font-size: 12px;
  color: #8c8c8c;
}
.table-search {
  margin-bottom: 16px;
}
.plate-number {
  font-family: 'Consolas', monospace;
  background-color: #1890ff;
  color: white;
  padding: 2px 6px;
  border-radius: 2px;
  font-weight: bold;
}
</style>
