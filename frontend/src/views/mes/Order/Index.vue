<template>
  <div class="order-tracking-container">
    <SplitLayout>
      <template #left>
        <a-card :bordered="false" class="left-card" :body-style="{ padding: '10px', height: 'calc(100% - 40px)', overflow: 'hidden' }">
          <template #title>
            <span><ProfileOutlined /> 订单导航</span>
          </template>
          <div class="search-box">
             <a-input-search v-model:value="searchValue" placeholder="搜索订单号/客户" style="margin-bottom: 8px" />
          </div>
          <div class="tree-container">
            <a-tree
              v-if="treeData.length > 0"
              :tree-data="treeData"
              :field-names="{ children: 'children', title: 'name', key: 'key' }"
              default-expand-all
              v-model:selectedKeys="selectedKeys"
              @select="onSelectOrder"
              block-node
            >
              <template #title="{ name, type, status }">
                <span v-if="type === 'category'">
                  <FolderOpenOutlined style="margin-right: 4px; color: #1890ff" />
                  {{ name }}
                </span>
                <span v-else>
                  <FileTextOutlined style="margin-right: 4px" />
                  {{ name }}
                  <a-tag v-if="status" :color="getStatusColor(status)" style="margin-left: 5px; font-size: 10px; line-height: 16px; height: 18px; padding: 0 4px;">{{ status }}</a-tag>
                </span>
              </template>
            </a-tree>
          </div>
        </a-card>
      </template>

      <template #right>
        <div class="right-content" v-if="currentOrder">
          <!-- 顶部概览卡片 -->
          <a-card :bordered="false" class="overview-card">
            <template #title>
              <div class="order-header">
                <span class="order-title">订单 #{{ currentOrder.code }}</span>
                <a-tag :color="getStatusColor(currentOrder.status)" class="order-status">{{ currentOrder.status }}</a-tag>
                <div class="order-actions">
                   <a-button type="primary" ghost size="small">查看详情</a-button>
                </div>
              </div>
            </template>
            <a-descriptions :column="4" size="small">
              <a-descriptions-item label="客户名称">{{ currentOrder.customer }}</a-descriptions-item>
              <a-descriptions-item label="产品名称">{{ currentOrder.product }}</a-descriptions-item>
              <a-descriptions-item label="订单数量">{{ currentOrder.quantity }} {{ currentOrder.unit }}</a-descriptions-item>
              <a-descriptions-item label="下单日期">{{ currentOrder.orderDate }}</a-descriptions-item>
              <a-descriptions-item label="计划开始">{{ currentOrder.planStartDate }}</a-descriptions-item>
              <a-descriptions-item label="计划完成">{{ currentOrder.planEndDate }}</a-descriptions-item>
              <a-descriptions-item label="实际开始">{{ currentOrder.actualStartDate || '-' }}</a-descriptions-item>
              <a-descriptions-item label="预测完成">
                 <span :class="{'text-danger': isDelayed(currentOrder), 'text-success': !isDelayed(currentOrder)}">
                   {{ currentOrder.predictedEndDate }}
                   <span v-if="isDelayed(currentOrder)">(延期)</span>
                   <span v-else>(正常)</span>
                 </span>
              </a-descriptions-item>
            </a-descriptions>
            
            <div class="progress-section">
              <div class="progress-info">
                <span>总体进度: {{ currentOrder.progress }}%</span>
                <span>预计剩余时间: {{ currentOrder.remainingDays }} 天</span>
              </div>
              <a-progress :percent="currentOrder.progress" :status="currentOrder.status === '异常' ? 'exception' : 'active'" />
            </div>
          </a-card>

          <!-- 详细进度跟踪 -->
          <div class="detail-section">
            <a-row :gutter="16" style="height: 100%">
              <a-col :span="16" style="height: 100%">
                 <a-card title="生产步骤跟踪" :bordered="false" class="step-card">
                    <div class="steps-container">
                      <a-steps :current="currentStepIndex" status="process" direction="vertical">
                        <a-step v-for="(step, index) in currentOrder.steps" :key="index" :title="step.name" :sub-title="step.status">
                          <template #description>
                            <div class="step-desc">
                              <div v-if="step.startTime">开始: {{ step.startTime }}</div>
                              <div v-if="step.endTime">结束: {{ step.endTime }}</div>
                              <div v-if="step.operator">操作人: {{ step.operator }}</div>
                              <div v-if="step.remark" class="step-remark">备注: {{ step.remark }}</div>
                            </div>
                          </template>
                        </a-step>
                      </a-steps>
                    </div>
                 </a-card>
              </a-col>
              <a-col :span="8" style="height: 100%">
                <a-card title="智能预测与分析" :bordered="false" class="analysis-card">
                   <div class="analysis-content">
                      <div class="prediction-item">
                        <div class="label">完工预测</div>
                        <div class="value" :class="isDelayed(currentOrder) ? 'danger' : 'success'">
                          {{ isDelayed(currentOrder) ? '风险高' : '按期交付' }}
                        </div>
                        <div class="desc">根据当前生产速率，预计 {{ currentOrder.predictedEndDate }} 完成。</div>
                      </div>

                      <a-divider />

                      <div class="prediction-item">
                        <div class="label">当前瓶颈</div>
                        <div class="value warning" v-if="currentOrder.bottleneck">{{ currentOrder.bottleneck }}</div>
                        <div class="value success" v-else>无明显瓶颈</div>
                        <div class="desc" v-if="currentOrder.bottleneck">该工序平均耗时超出标准 20%。</div>
                      </div>

                      <a-divider />

                      <div class="prediction-item">
                         <div class="label">质量概览</div>
                         <div class="chart-placeholder">
                            <div style="text-align: center">
                              <a-progress type="circle" :percent="98" :width="80" />
                              <div style="margin-top: 8px">合格率</div>
                            </div>
                         </div>
                      </div>
                   </div>
                </a-card>
              </a-col>
            </a-row>
          </div>
        </div>
        <div v-else class="empty-state">
           <a-empty description="请选择左侧订单查看详情" />
        </div>
      </template>
    </SplitLayout>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import SplitLayout from '@/components/SplitLayout/index.vue';
import { 
  ProfileOutlined, 
  FolderOpenOutlined, 
  FileTextOutlined 
} from '@ant-design/icons-vue';

// --- Types ---
interface Step {
  name: string;
  status: '待开始' | '进行中' | '已完成';
  startTime?: string;
  endTime?: string;
  operator?: string;
  remark?: string;
}

interface Order {
  key: string;
  code: string;
  customer: string;
  product: string;
  quantity: number;
  unit: string;
  status: '生产中' | '已完成' | '待生产' | '异常';
  orderDate: string;
  planStartDate: string;
  planEndDate: string;
  actualStartDate?: string;
  predictedEndDate: string;
  progress: number;
  remainingDays: number;
  bottleneck?: string;
  steps: Step[];
}

// --- State ---
const searchValue = ref('');
const selectedKeys = ref<string[]>([]);
const currentOrder = ref<Order | null>(null);

// Mock Data
const mockOrders: Order[] = [
  {
    key: 'ORD-20231001-001',
    code: 'ORD-20231001-001',
    customer: '特斯拉上海超级工厂',
    product: 'Model Y 后底板总成',
    quantity: 500,
    unit: '套',
    status: '生产中',
    orderDate: '2023-10-01',
    planStartDate: '2023-10-05',
    planEndDate: '2023-10-20',
    actualStartDate: '2023-10-05 08:30',
    predictedEndDate: '2023-10-21',
    progress: 65,
    remainingDays: 2,
    bottleneck: '焊接工序',
    steps: [
      { name: '原材料准备', status: '已完成', startTime: '2023-10-05 09:00', endTime: '2023-10-06 14:00', operator: '张三' },
      { name: '冲压加工', status: '已完成', startTime: '2023-10-07 08:00', endTime: '2023-10-10 18:00', operator: '李四' },
      { name: '焊接组装', status: '进行中', startTime: '2023-10-11 08:00', operator: '王五', remark: '设备偶尔报警，需关注' },
      { name: '表面处理', status: '待开始' },
      { name: '质量检测', status: '待开始' },
      { name: '包装入库', status: '待开始' }
    ]
  },
  {
    key: 'ORD-20231002-005',
    code: 'ORD-20231002-005',
    customer: '比亚迪汽车',
    product: '电池包壳体',
    quantity: 200,
    unit: '件',
    status: '已完成',
    orderDate: '2023-09-20',
    planStartDate: '2023-09-25',
    planEndDate: '2023-10-05',
    actualStartDate: '2023-09-25 09:00',
    predictedEndDate: '2023-10-04',
    progress: 100,
    remainingDays: 0,
    steps: [
      { name: '原材料准备', status: '已完成', startTime: '2023-09-25', endTime: '2023-09-26' },
      { name: 'CNC加工', status: '已完成', startTime: '2023-09-27', endTime: '2023-09-30' },
      { name: '清洗', status: '已完成', startTime: '2023-10-01', endTime: '2023-10-02' },
      { name: '质检', status: '已完成', startTime: '2023-10-03', endTime: '2023-10-04' }
    ]
  },
    {
    key: 'ORD-20231005-012',
    code: 'ORD-20231005-012',
    customer: '蔚来汽车',
    product: '座椅支架',
    quantity: 1000,
    unit: '件',
    status: '待生产',
    orderDate: '2023-10-05',
    planStartDate: '2023-10-15',
    planEndDate: '2023-10-30',
    predictedEndDate: '2023-10-30',
    progress: 0,
    remainingDays: 15,
    steps: [
      { name: '原材料准备', status: '待开始' },
      { name: '切割', status: '待开始' },
      { name: '折弯', status: '待开始' },
      { name: '焊接', status: '待开始' }
    ]
  },
  {
    key: 'ORD-20231008-020',
    code: 'ORD-20231008-020',
    customer: '理想汽车',
    product: 'L9 前防撞梁',
    quantity: 800,
    unit: '件',
    status: '生产中',
    orderDate: '2023-10-08',
    planStartDate: '2023-10-10',
    planEndDate: '2023-10-25',
    actualStartDate: '2023-10-10 09:00',
    predictedEndDate: '2023-10-26',
    progress: 45,
    remainingDays: 10,
    bottleneck: '热处理',
    steps: [
      { name: '原材料准备', status: '已完成', startTime: '2023-10-10', endTime: '2023-10-11' },
      { name: '成型', status: '已完成', startTime: '2023-10-12', endTime: '2023-10-14' },
      { name: '热处理', status: '进行中', startTime: '2023-10-15', remark: '炉温波动较大' },
      { name: '喷涂', status: '待开始' },
      { name: '质检', status: '待开始' }
    ]
  },
  {
    key: 'ORD-20231010-033',
    code: 'ORD-20231010-033',
    customer: '小鹏汽车',
    product: 'G9 电池盒盖',
    quantity: 300,
    unit: '套',
    status: '异常',
    orderDate: '2023-10-01',
    planStartDate: '2023-10-05',
    planEndDate: '2023-10-15',
    actualStartDate: '2023-10-05',
    predictedEndDate: '2023-10-20',
    progress: 30,
    remainingDays: 5,
    bottleneck: '缺料',
    steps: [
      { name: '原材料准备', status: '已完成' },
      { name: '冲压', status: '进行中', remark: '原材料供应不足，暂停中' },
      { name: '焊接', status: '待开始' }
    ]
  },
  {
    key: 'ORD-20230915-008',
    code: 'ORD-20230915-008',
    customer: '吉利汽车',
    product: '星越L 仪表盘支架',
    quantity: 1200,
    unit: '件',
    status: '已完成',
    orderDate: '2023-09-15',
    planStartDate: '2023-09-18',
    planEndDate: '2023-09-30',
    actualStartDate: '2023-09-18',
    predictedEndDate: '2023-09-29',
    progress: 100,
    remainingDays: 0,
    steps: [
      { name: '全部工序', status: '已完成', endTime: '2023-09-29' }
    ]
  },
  {
    key: 'ORD-20231012-045',
    code: 'ORD-20231012-045',
    customer: '长城汽车',
    product: '坦克300 悬挂臂',
    quantity: 600,
    unit: '件',
    status: '待生产',
    orderDate: '2023-10-12',
    planStartDate: '2023-10-20',
    planEndDate: '2023-11-05',
    predictedEndDate: '2023-11-05',
    progress: 0,
    remainingDays: 16,
    steps: [
      { name: '备料', status: '待开始' },
      { name: '锻造', status: '待开始' },
      { name: '机加工', status: '待开始' }
    ]
  },
  {
    key: 'ORD-20231011-042',
    code: 'ORD-20231011-042',
    customer: '大众安徽',
    product: 'ID.3 车门内板',
    quantity: 2000,
    unit: '件',
    status: '生产中',
    orderDate: '2023-10-05',
    planStartDate: '2023-10-08',
    planEndDate: '2023-10-25',
    actualStartDate: '2023-10-08',
    predictedEndDate: '2023-10-24',
    progress: 70,
    remainingDays: 5,
    steps: [
      { name: '冲压', status: '已完成' },
      { name: '焊接', status: '进行中' },
      { name: '涂装', status: '待开始' }
    ]
  }
];

const treeData = ref([
  {
    name: '进行中订单',
    key: 'running',
    type: 'category',
    selectable: false,
    children: mockOrders.filter(o => o.status === '生产中').map(o => ({ title: o.code, key: o.key, name: o.code, type: 'order', status: o.status }))
  },
  {
    name: '待生产订单',
    key: 'pending',
    type: 'category',
    selectable: false,
    children: mockOrders.filter(o => o.status === '待生产').map(o => ({ title: o.code, key: o.key, name: o.code, type: 'order', status: o.status }))
  },
  {
    name: '已完成订单',
    key: 'completed',
    type: 'category',
    selectable: false,
    children: mockOrders.filter(o => o.status === '已完成').map(o => ({ title: o.code, key: o.key, name: o.code, type: 'order', status: o.status }))
  }
]);

// --- Computed ---
const currentStepIndex = computed(() => {
  if (!currentOrder.value) return 0;
  const index = currentOrder.value.steps.findIndex(s => s.status === '进行中');
  if (index !== -1) return index;
  // If all completed, return length
  if (currentOrder.value.steps.every(s => s.status === '已完成')) return currentOrder.value.steps.length;
  // If all pending, return 0
  return 0;
});

// --- Methods ---
const onSelectOrder = (keys: string[], _info: any) => {
  if (keys.length > 0) {
    const key = keys[0];
    const order = mockOrders.find(o => o.key === key);
    if (order) {
      currentOrder.value = order;
    }
  }
};

const getStatusColor = (status: string) => {
  switch (status) {
    case '生产中': return 'blue';
    case '已完成': return 'green';
    case '待生产': return 'orange';
    case '异常': return 'red';
    default: return 'default';
  }
};

const isDelayed = (order: Order) => {
  if (!order) return false;
  return new Date(order.predictedEndDate) > new Date(order.planEndDate);
};

onMounted(() => {
  // Default select first running order
  const firstRunning = mockOrders.find(o => o.status === '生产中');
  if (firstRunning) {
    selectedKeys.value = [firstRunning.key];
    currentOrder.value = firstRunning;
  }
});
</script>

<style lang="scss" scoped>
.order-tracking-container {
  flex: 1;
  padding: 10px;
  background-color: #f0f2f5;
}

.left-card {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.tree-container {
  flex: 1;
  overflow-y: auto;
}

.right-content {
  height: 100%;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.empty-state {
  height: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
  background: #fff;
  border-radius: 4px;
}

.order-header {
  display: flex;
  align-items: center;
  
  .order-title {
    font-size: 18px;
    font-weight: bold;
    margin-right: 12px;
  }
  
  .order-actions {
    margin-left: auto;
  }
}

.progress-section {
  margin-top: 24px;
  
  .progress-info {
    display: flex;
    justify-content: space-between;
    margin-bottom: 8px;
    color: #666;
  }
}

.detail-section {
  flex: 1;
  min-height: 0; // for flex scroll
  
  .step-card {
    height: 100%;
    display: flex;
    flex-direction: column;
    
    :deep(.ant-card-body) {
      flex: 1;
      overflow-y: auto;
    }
  }
  
  .analysis-card {
    height: 100%;
    
    :deep(.ant-card-body) {
      height: 100%;
    }
  }
}

.step-desc {
  font-size: 12px;
  color: #8c8c8c;
  
  .step-remark {
    color: #faad14;
    margin-top: 4px;
  }
}

.text-danger {
  color: #ff4d4f;
}
.text-success {
  color: #52c41a;
}

.analysis-content {
  .prediction-item {
    padding: 12px 0;
    
    .label {
      font-size: 14px;
      color: #666;
      margin-bottom: 4px;
    }
    
    .value {
      font-size: 20px;
      font-weight: bold;
      margin-bottom: 4px;
      
      &.danger { color: #ff4d4f; }
      &.success { color: #52c41a; }
      &.warning { color: #faad14; }
    }
    
    .desc {
      font-size: 12px;
      color: #999;
    }
  }
  
  .chart-placeholder {
    display: flex;
    justify-content: center;
    padding: 20px 0;
  }
}
</style>
