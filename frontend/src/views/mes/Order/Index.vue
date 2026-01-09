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
              <a-descriptions-item label="下单日期">{{ currentOrder.orderDate }}</a-descriptions-item>
              <a-descriptions-item label="计划开始">{{ currentOrder.planStartDate }}</a-descriptions-item>
              <a-descriptions-item label="计划完成">{{ currentOrder.planEndDate }}</a-descriptions-item>
            </a-descriptions>
            
            <!-- 控制与进度栏 (合并显示) -->
            <div class="control-bar" style="display: flex; justify-content: space-between; align-items: center; margin-top: 16px; padding-top: 16px; border-top: 1px dashed #f0f0f0;">
               <!-- 左侧：批次选择 -->
               <div class="batch-selector-wrapper" style="display: flex; align-items: center; flex: 1;">
                 <span style="margin-right: 12px; font-weight: bold; color: #333; white-space: nowrap;">跟踪维度：</span>
                 <a-select 
                    v-model:value="currentBatchId" 
                    style="width: 320px" 
                    placeholder="请选择要跟踪的生产批次"
                 >
                    <a-select-opt-group v-for="prod in currentOrder.products" :key="prod.productId" :label="prod.productName">
                       <a-select-option v-for="batch in prod.batches" :key="batch.batchId" :value="batch.batchId">
                          {{ batch.batchNo }} ({{ batch.quantity }} {{ prod.unit }})
                       </a-select-option>
                    </a-select-opt-group>
                 </a-select>
                 
                 <span v-if="currentBatch" style="margin-left: 16px; display: flex; align-items: center; gap: 8px;">
                    <a-tag :color="currentBatch.priority === 'High' ? 'red' : 'blue'">{{ currentBatch.priority === 'High' ? '高优先级' : '普通' }}</a-tag>
                    <span style="color: #999; font-size: 12px;">预计: {{ currentBatch.predictedEndDate }}</span>
                 </span>
               </div>

               <!-- 右侧：订单总体进度 -->
               <div class="order-progress-wrapper" style="width: 25%; margin-left: 24px;">
                  <div style="display: flex; justify-content: space-between; margin-bottom: 4px; font-size: 12px; color: #666;">
                    <span>订单总体进度</span>
                    <span>{{ currentOrder.overallProgress }}%</span>
                  </div>
                  <a-progress :percent="currentOrder.overallProgress" :status="currentOrder.status === '异常' ? 'exception' : 'active'" :stroke-width="8" :show-info="false" />
               </div>
            </div>
          </a-card>

          <!-- 详细进度跟踪 -->
          <div class="detail-section" v-if="currentBatch">
            <a-row :gutter="16" style="height: 100%">
              <a-col :span="16" style="height: 100%">
                 <a-card title="生产步骤跟踪" :bordered="false" class="step-card">
                    <template #extra>
                       <span>当前批次: {{ currentBatch.batchNo }}</span>
                    </template>
                    <!-- BOM Tree View -->
                    <div class="bom-layout">
                       <div class="bom-tree-side">
                          <div class="bom-header">BOM 结构与状态</div>
                          <div class="bom-tree-wrapper">
                            <a-tree
                               v-if="currentBatch.bomTree && currentBatch.bomTree.length > 0"
                               :tree-data="currentBatch.bomTree"
                               :field-names="{ children: 'children', title: 'name', key: 'key' }"
                               default-expand-all
                               v-model:selectedKeys="selectedBomKeys"
                               @select="onSelectBomNode"
                               block-node
                            >
                              <template #title="{ name, status, progress }">
                                 <div class="bom-node-row">
                                   <span class="bom-name">{{ name }}</span>
                                   <div class="bom-status-group">
                                      <a-progress 
                                        :percent="progress" 
                                        size="small" 
                                        :show-info="false" 
                                        :stroke-color="getStatusColor(status) === 'blue' ? '#1890ff' : getStatusColor(status) === 'green' ? '#52c41a' : '#faad14'"
                                        style="width: 30px; margin-right: 5px" 
                                      />
                                      <a-tag :color="getStatusColor(status)" style="margin: 0; font-size: 10px; line-height: 16px; height: 18px; padding: 0 2px;">{{ status }}</a-tag>
                                   </div>
                                 </div>
                              </template>
                              <template #icon>
                                <ApartmentOutlined />
                              </template>
                            </a-tree>
                            <a-empty v-else description="该批次暂无BOM数据" image="simple" style="margin-top: 50px" />
                          </div>
                       </div>
                       <div class="bom-divider"></div>
                       <div class="bom-steps-side">
                          <div class="bom-header">
                             {{ currentBomNode?.name || '工序详情' }}
                             <span class="bom-subtitle" v-if="currentBomNode">当前进度: {{ currentBomNode.progress }}%</span>
                          </div>
                          <div class="bom-steps-wrapper" v-if="currentBomNode">
                              <a-steps :current="currentStepActiveIndex" status="process" direction="vertical" size="small">
                                <a-step v-for="(step, index) in currentStepSteps" :key="index" :title="step.name" :sub-title="step.status">
                                  <template #description>
                                    <div class="step-desc">
                                      <div v-if="step.startTime">开始: {{ step.startTime }}</div>
                                      <div v-if="step.endTime">结束: {{ step.endTime }}</div>
                                      <div v-if="step.operator">操作人: {{ step.operator }}</div>
                                      <div v-if="step.remark" class="step-remark">备注: {{ step.remark }}</div>
                                      
                                      <!-- Parameters Table -->
                                      <div v-if="step.parameters && step.parameters.length > 0" class="step-params">
                                        <div class="param-header">
                                          <span class="col-name">参数项</span>
                                          <span class="col-std">标准值</span>
                                          <span class="col-act">实际值</span>
                                          <span class="col-res">结果</span>
                                        </div>
                                        <div v-for="(param, pIndex) in step.parameters" :key="pIndex" class="param-row">
                                          <span class="col-name">{{ param.name }}</span>
                                          <span class="col-std">{{ param.standard }} {{ param.unit }}</span>
                                          <span class="col-act" :class="{ 'text-error': param.result === 'fail' }">
                                             {{ param.actual }} {{ param.unit }}
                                          </span>
                                          <span class="col-res">
                                            <CheckCircleOutlined v-if="param.result === 'pass'" style="color: #52c41a"/>
                                            <CloseCircleOutlined v-else style="color: #ff4d4f"/>
                                          </span>
                                        </div>
                                      </div>
                                    </div>
                                  </template>
                                </a-step>
                              </a-steps>
                          </div>
                          <div class="empty-bom-select" v-else>
                            <a-empty description="请选择左侧零件查看工序" image="simple" />
                          </div>
                       </div>
                    </div>
                 </a-card>
              </a-col>
              <a-col :span="8" style="height: 100%; display: flex; flex-direction: column; gap: 16px;">
                   <!-- Design Info Card -->
                   <a-card title="零部件设计档案" class="design-card" :bordered="false">
                      <div v-if="currentBomNode && currentBomNode.designInfo" class="design-info-content">
                         <a-descriptions :column="1" size="small" bordered>
                           <a-descriptions-item label="设计图号">{{ currentBomNode.designInfo.drawingNo }}</a-descriptions-item>
                           <a-descriptions-item label="版本号">{{ currentBomNode.designInfo.version }}</a-descriptions-item>
                           <a-descriptions-item label="材料牌号">{{ currentBomNode.designInfo.material }}</a-descriptions-item>
                           <a-descriptions-item label="理论重量">{{ currentBomNode.designInfo.weight }}</a-descriptions-item>
                           <a-descriptions-item label="规格尺寸">{{ currentBomNode.designInfo.specs }}</a-descriptions-item>
                         </a-descriptions>
                         <div class="design-actions">
                            <a-button type="primary" ghost size="small">查看3D模型</a-button>
                            <a-button size="small">下载图纸</a-button>
                         </div>
                      </div>
                      <div v-else class="empty-design">
                         <a-empty description="请选择零部件查看设计信息" image="simple" />
                      </div>
                   </a-card>

                   <!-- Analysis Card -->
                    <a-card title="智能预测与分析" :bordered="false" class="analysis-card">
                       <div class="analysis-content">
                         <!-- Merged Row: Prediction & Bottleneck -->
                         <div class="compact-row">
                            <div class="half-item">
                               <div class="label">预计完工</div>
                               <div class="value">{{ currentBatch.predictedEndDate }}</div>
                               <div class="sub-status" :class="isDelayed(currentBatch) ? 'text-danger' : 'text-success'">
                                  {{ isDelayed(currentBatch) ? `延期 ${currentBatch.remainingDays} 天` : '按期交付' }}
                               </div>
                            </div>
                            <div class="v-divider"></div>
                            <div class="half-item">
                               <div class="label">瓶颈工序</div>
                               <div class="value warning" :title="currentBatch.bottleneck">{{ currentBatch.bottleneck || '无' }}</div>
                               <div class="sub-status">负荷率 120%</div>
                            </div>
                         </div>

                         <!-- New Row: Key Resources -->
                         <div class="compact-item resource-section">
                            <div class="item-header">
                               <span class="label">关键资源监控</span>
                            </div>
                            <div class="resource-grid">
                               <div class="res-item">
                                  <span class="res-label">设备OEE</span>
                                  <a-progress :percent="85" size="small" :stroke-color="{ '0%': '#108ee9', '100%': '#87d068' }"/>
                               </div>
                               <div class="res-item">
                                  <span class="res-label">物料齐套</span>
                                  <a-progress :percent="98" size="small" status="active"/>
                               </div>
                            </div>
                         </div>

                         <!-- Existing Row: Risk -->
                         <div class="compact-item risk-section">
                            <div class="item-header" style="margin-bottom: 6px;">
                               <span class="label">质量风险提示</span>
                            </div>
                            <div class="risk-list compact">
                               <template v-if="currentBatch.risks && currentBatch.risks.length > 0">
                                  <div class="risk-item" v-for="(risk, rIdx) in currentBatch.risks" :key="rIdx">
                                     <span class="risk-dot" :class="risk.level === 'high' ? 'red' : 'orange'"></span>
                                     <span>{{ risk.content }}</span>
                                  </div>
                               </template>
                               <div v-else class="risk-item">
                                  <span class="risk-dot green"></span>
                                  <span>暂无风险提示</span>
                               </div>
                            </div>
                         </div>

                         <!-- 智能优化建议 -->
                         <div class="compact-item suggestion-section">
                            <div class="item-header">
                               <span class="label">智能优化建议</span>
                               <a-button type="link" size="small" style="padding: 0; height: auto; font-size: 12px;">应用全部</a-button>
                            </div>
                            <div class="suggestion-list">
                               <div class="suggestion-item">
                                  <CheckCircleOutlined class="success-icon" />
                                  <span>建议调高[SPR铆接]压力参数 2%</span>
                               </div>
                               <div class="suggestion-item">
                                  <InfoCircleOutlined class="info-icon" />
                                  <span>建议[总装]工位增加临时缓冲库存</span>
                               </div>
                            </div>
                         </div>

                         <!-- 实时成本追踪 -->
                         <div class="compact-item cost-section">
                            <div class="item-header">
                               <span class="label">实时成本追踪</span>
                               <span class="value warning">+1.2%</span>
                            </div>
                            <div class="cost-bar-wrapper">
                               <div class="cost-labels">
                                  <span>实际: ¥12,450</span>
                                  <span class="standard">标准: ¥12,300</span>
                               </div>
                               <a-progress :percent="101.2" status="exception" :show-info="false" :stroke-width="6" />
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
import { ref, computed, onMounted, watch } from 'vue';
import type { TreeProps } from 'ant-design-vue';
import SplitLayout from '@/components/SplitLayout/index.vue';
import { 
  ProfileOutlined, 
  FolderOpenOutlined, 
  FileTextOutlined,
  ApartmentOutlined,
  CheckCircleOutlined,
  CloseCircleOutlined,
  InfoCircleOutlined
} from '@ant-design/icons-vue';

// --- Types ---
interface StepParameter {
  name: string;
  standard: string;
  actual: string;
  unit: string;
  result: 'pass' | 'fail';
}

interface Step {
  name: string;
  status: '待开始' | '进行中' | '已完成';
  startTime?: string;
  endTime?: string;
  operator?: string;
  remark?: string;
  parameters?: StepParameter[];
}

interface DesignInfo {
  material: string;
  weight: string;
  drawingNo: string;
  version: string;
  specs: string;
}

interface BomNode {
  key: string;
  name: string;
  status: '待开始' | '进行中' | '已完成' | '异常';
  progress: number;
  children?: BomNode[];
  steps?: Step[];
  designInfo?: DesignInfo;
}

interface Batch {
  batchId: string;
  batchNo: string; // 批次号或序列号
  quantity: number;
  status: '待开始' | '进行中' | '已完成' | '异常';
  progress: number;
  priority: 'Normal' | 'High';
  bomTree: BomNode[];
  predictedEndDate: string;
  remainingDays: number;
  bottleneck?: string;
  risks?: { level: 'high' | 'medium' | 'low', content: string }[];
}

interface OrderProduct {
  productId: string;
  productCode: string;
  productName: string;
  totalQuantity: number;
  unit: string;
  batches: Batch[];
}

interface Order {
  key: string;
  code: string;
  customer: string;
  // product: string; // Removed, moved to OrderProduct
  // quantity: number; // Removed
  // unit: string; // Removed
  status: '生产中' | '已完成' | '待生产' | '异常';
  orderDate: string;
  planStartDate: string;
  planEndDate: string;
  actualStartDate?: string;
  overallProgress: number; // 订单总进度
  products: OrderProduct[]; // 新增：包含多种产品
}

// --- State ---
const searchValue = ref('');
const selectedKeys = ref<string[]>([]);
const currentOrder = ref<Order | null>(null);
const currentProduct = ref<OrderProduct | null>(null);
const currentBatch = ref<Batch | null>(null);
const currentBatchId = ref<string>(''); // 用于 Select 绑定

const currentBomNode = ref<BomNode | null>(null);
const selectedBomKeys = ref<string[]>([]);

// Helper to find batch by ID
const findBatchById = (order: Order, batchId: string): { product: OrderProduct, batch: Batch } | null => {
  for (const prod of order.products) {
    const batch = prod.batches.find(b => b.batchId === batchId);
    if (batch) return { product: prod, batch };
  }
  return null;
};

// 监听当前订单变化，默认选中第一个批次
watch(currentOrder, (newVal) => {
  const firstProduct = newVal?.products?.[0];
  const firstBatch = firstProduct?.batches?.[0];

  if (firstBatch) {
    currentBatchId.value = firstBatch.batchId;
    // 触发 currentBatchId 的 watch 逻辑
  } else {
    currentBatchId.value = '';
    currentProduct.value = null;
    currentBatch.value = null;
  }
});

// 监听批次选择变化
watch(currentBatchId, (newVal) => {
  if (currentOrder.value && newVal) {
    const result = findBatchById(currentOrder.value, newVal);
    if (result) {
      currentProduct.value = result.product;
      currentBatch.value = result.batch;
      
      // Reset BOM selection
      if (result.batch.bomTree && result.batch.bomTree.length > 0) {
        const firstNode = result.batch.bomTree[0];
        if (firstNode) {
          currentBomNode.value = firstNode;
          selectedBomKeys.value = [firstNode.key];
        }
      } else {
        currentBomNode.value = null;
        selectedBomKeys.value = [];
      }
    }
  }
});

const onSelectBomNode: TreeProps['onSelect'] = (keys, _info) => {
  if (keys.length > 0 && currentBatch.value?.bomTree) {
    const findNode = (nodes: BomNode[], key: string): BomNode | undefined => {
      for (const node of nodes) {
        if (node.key === key) return node;
        if (node.children) {
          const found = findNode(node.children, key);
          if (found) return found;
        }
      }
      return undefined;
    };
    const key = keys[0] as string;
    if (key) {
      const node = findNode(currentBatch.value.bomTree, key);
      if (node) {
        currentBomNode.value = node;
      }
    }
  }
};

// Mock Data
// Reusing previous BOM structure for Batch A
const batchABomTree: BomNode[] = [
  {
    key: 'part-001',
    name: 'Model Y 后底板总成 (Level 1)',
    status: '进行中',
    progress: 65,
    designInfo: { material: '多材料混合', weight: '65.5kg', drawingNo: 'ASY-MDY-RB-001', version: 'V3.2', specs: '1650x1400x450mm' },
    steps: [
       { 
         name: 'OP10-总成拼装', 
         status: '已完成', 
         startTime: '2023-10-15 08:30', 
         endTime: '2023-10-15 09:15',
         operator: '班组A',
         parameters: [
           { name: '夹具定位精度', standard: '±0.05', actual: '0.03', unit: 'mm', result: 'pass' },
           { name: '上料节拍', standard: '≤45', actual: '42', unit: 's', result: 'pass' }
         ]
       },
       { 
         name: 'OP20-机器人焊接(Laser)', 
         status: '进行中', 
         startTime: '2023-10-15 09:20', 
         operator: 'Robot-L1',
         parameters: [
           { name: '激光功率', standard: '4000±100', actual: '3980', unit: 'W', result: 'pass' },
           { name: '焊接速度', standard: '80-100', actual: '92', unit: 'mm/s', result: 'pass' },
           { name: '保护气(Ar)流量', standard: '15-20', actual: '18', unit: 'L/min', result: 'pass' },
           { name: '离焦量', standard: '0±1', actual: '0.5', unit: 'mm', result: 'pass' }
         ]
       },
       { 
         name: 'OP30-涂胶与固化', 
         status: '待开始',
         parameters: [
           { name: '胶条直径', standard: '3.0±0.5', actual: '-', unit: 'mm', result: 'pass' },
           { name: '固化炉温', standard: '160±5', actual: '-', unit: '°C', result: 'pass' }
         ]
       },
       { name: 'OP40-FDS流钻螺钉连接', status: '待开始' },
       { name: 'OP50-在线测量(Perceptron)', status: '待开始' }
    ],
    children: [
      // === 左侧分总成 ===
      {
        key: 'part-001-01',
        name: '左后纵梁分总成 (Level 2)',
        status: '已完成',
        progress: 100,
        designInfo: { material: 'Al-Si10MnMg / DP980', weight: '18.2kg', drawingNo: 'SUB-L-001', version: 'V3.0', specs: '1200x400x300mm' },
        steps: [
           { name: 'SPR铆接', status: '已完成', startTime: '2023-10-13', endTime: '2023-10-13', parameters: [
              { name: '铆接压力', standard: '50-60', actual: '55', unit: 'kN', result: 'pass' },
              { name: '铆点高度', standard: '2.5±0.2', actual: '2.45', unit: 'mm', result: 'pass' }
           ]},
           { name: 'CMT焊接', status: '已完成', startTime: '2023-10-13', endTime: '2023-10-13', parameters: [
              { name: '送丝速度', standard: '8.0-9.0', actual: '8.5', unit: 'm/min', result: 'pass' },
              { name: '焊接电流', standard: '180±10', actual: '185', unit: 'A', result: 'pass' }
           ]}
        ],
        children: [
          {
            key: 'part-001-01-01',
            name: '左前纵梁 (一体化压铸铝)',
            status: '已完成',
            progress: 100,
            designInfo: { material: 'Tesla自研铝合金', weight: '12.5kg', drawingNo: 'CST-L-F-01', version: 'V4.1', specs: '一体成型' },
            steps: [
              { name: '熔炼', status: '已完成', startTime: '2023-10-10 08:00', endTime: '2023-10-10 10:00', parameters: [
                { name: '铝液温度', standard: '680±10', actual: '682', unit: '°C', result: 'pass' },
                { name: '除气时间', standard: '≥15', actual: '18', unit: 'min', result: 'pass' }
              ]},
              { name: '6000T压铸', status: '已完成', startTime: '2023-10-10 10:30', endTime: '2023-10-10 10:35', operator: 'Giga-Press-01', parameters: [
                { name: '压射速度(高速)', standard: '5.5-6.5', actual: '6.2', unit: 'm/s', result: 'pass' },
                { name: '增压压力', standard: '90-110', actual: '98', unit: 'MPa', result: 'pass' },
                { name: '模具温度(动模)', standard: '220±20', actual: '235', unit: '°C', result: 'pass' },
                { name: '真空度', standard: '≤5', actual: '3', unit: 'kPa', result: 'pass' }
              ]},
              { name: 'X-Ray探伤', status: '已完成', startTime: '2023-10-11', endTime: '2023-10-11', parameters: [
                { name: '气孔等级(ASTM)', standard: '≤Level 2', actual: 'Level 1', unit: '', result: 'pass' },
                { name: '缺陷最大直径', standard: '≤1.0', actual: '0.6', unit: 'mm', result: 'pass' }
              ]},
              { name: 'CNC加工', status: '已完成', startTime: '2023-10-11', parameters: [
                { name: '安装孔位置度', standard: '0.5', actual: '0.2', unit: 'mm', result: 'pass' },
                { name: '平面度', standard: '0.3', actual: '0.15', unit: 'mm', result: 'pass' }
              ]}
            ]
          },
          {
            key: 'part-001-01-02',
            name: '左后轮罩板 (冲压件)',
            status: '已完成',
            progress: 100,
            steps: [
              { name: 'OP10-拉延', status: '已完成', startTime: '2023-10-10', parameters: [
                 { name: '冲压力', standard: '2000±100', actual: '1980', unit: 'kN', result: 'pass' },
                 { name: '板料减薄率', standard: '≤20%', actual: '15%', unit: '', result: 'pass' }
              ]},
              { name: 'OP20-修边冲孔', status: '已完成', startTime: '2023-10-10', parameters: [
                 { name: '毛刺高度', standard: '≤0.1', actual: '0.05', unit: 'mm', result: 'pass' }
              ]}
            ]
          },
          {
             key: 'part-001-01-03',
             name: '纵梁加强板 (热成型)',
             status: '已完成',
             progress: 100,
             steps: [
                { name: '加热炉', status: '已完成', parameters: [
                   { name: '加热温度', standard: '930±10', actual: '932', unit: '°C', result: 'pass' },
                   { name: '保温时间', standard: '240-300', actual: '260', unit: 's', result: 'pass' }
                ]},
                { name: '冲压淬火', status: '已完成', parameters: [
                   { name: '保压冷却时间', standard: '8-10', actual: '9', unit: 's', result: 'pass' },
                   { name: '出模温度', standard: '≤150', actual: '130', unit: '°C', result: 'pass' }
                ]},
                { name: '硬度检测', status: '已完成', parameters: [
                   { name: '抗拉强度', standard: '≥1500', actual: '1580', unit: 'MPa', result: 'pass' }
                ]}
             ]
          }
        ]
      },
      // === 右侧分总成 (模拟异常) ===
      {
        key: 'part-001-02',
        name: '右后纵梁分总成 (Level 2)',
        status: '异常', // 状态异常
        progress: 40,
        steps: [
           { name: 'SPR铆接', status: '进行中', startTime: '2023-10-15', operator: '张三', parameters: [
             { name: '铆接压力', standard: '50-60', actual: '42', unit: 'kN', result: 'fail' }, // 压力不足
             { name: '铆钉长度', standard: '5.0', actual: '5.0', unit: 'mm', result: 'pass' },
             { name: '底厚互锁值', standard: '0.2-0.4', actual: '0.1', unit: 'mm', result: 'fail' } // 互锁不够
           ]},
           { name: 'CMT焊接', status: '待开始' }
        ],
        children: [
           {
            key: 'part-001-02-01',
            name: '右前纵梁 (一体化压铸铝)',
            status: '已完成',
            progress: 100,
            steps: [
              { name: '6000T压铸', status: '已完成', startTime: '2023-10-12', endTime: '2023-10-12', parameters: [
                 { name: '压射速度', standard: '5.5-6.5', actual: '6.0', unit: 'm/s', result: 'pass' }
              ]},
              { name: 'CNC加工', status: '已完成', startTime: '2023-10-13', parameters: [
                 { name: '安装孔孔径', standard: '12.0+0.1', actual: '12.05', unit: 'mm', result: 'pass' }
              ]}
            ]
          },
          {
             key: 'part-001-02-02',
             name: '右后轮罩板 (冲压件)',
             status: '已完成',
             progress: 100,
             steps: [{ name: 'OP10-拉延', status: '已完成' }, { name: 'OP20-修边冲孔', status: '已完成' }]
          }
        ]
      },
      // === 后横梁分总成 (深层嵌套) ===
      {
        key: 'part-001-03',
        name: '后横梁分总成 (Level 2)',
        status: '进行中',
        progress: 30,
        steps: [
           { name: '机器人焊接', status: '进行中', parameters: [
              { name: '电流', standard: '220', actual: '220', unit: 'A', result: 'pass' }
           ]}
        ],
        children: [
           {
              key: 'part-001-03-01',
              name: '拖车钩安装支架总成 (Level 3)',
              status: '已完成',
              progress: 100,
              children: [
                 {
                    key: 'part-001-03-01-01',
                    name: '支架本体 (高强钢)',
                    status: '已完成',
                    progress: 100,
                    steps: [
                       { name: '激光切割', status: '已完成', parameters: [
                          { name: '切缝宽度', standard: '0.2', actual: '0.22', unit: 'mm', result: 'pass' }
                       ]},
                       { name: '折弯成型', status: '已完成', parameters: [
                          { name: '折弯角度', standard: '90±0.5', actual: '90.2', unit: 'deg', result: 'pass' }
                       ]}
                    ]
                 },
                 {
                    key: 'part-001-03-01-02',
                    name: 'M12焊接螺母 (Level 4)',
                    status: '已完成',
                    progress: 100,
                    steps: [
                       { name: '凸焊', status: '已完成', parameters: [
                          { name: '焊接时间', standard: '100', actual: '102', unit: 'ms', result: 'pass' },
                          { name: '顶锻力', standard: '5.0', actual: '5.1', unit: 'kN', result: 'pass' },
                          { name: '扭矩破坏测试', standard: '≥80', actual: '95', unit: 'N·m', result: 'pass' }
                       ]}
                    ]
                 },
                 {
                    key: 'part-001-03-01-03',
                    name: '加强筋板',
                    status: '已完成',
                    progress: 100,
                    steps: [{name: '冲压', status: '已完成'}]
                 }
              ]
           },
           {
              key: 'part-001-03-02',
              name: '横梁外板',
              status: '已完成',
              progress: 100,
              steps: [{name: '冲压', status: '已完成'}]
           }
        ]
      },
      // === 座椅横梁组件 ===
      {
         key: 'part-001-04',
         name: '后排座椅横梁组件 (Level 2)',
         status: '待开始',
         progress: 0,
         steps: [
            { name: '点焊', status: '待开始' },
            { name: '涂装电泳', status: '待开始' }
         ],
         children: [
            {
               key: 'part-001-04-01',
               name: '座椅安装支架-左',
               status: '已完成',
               progress: 100,
               steps: [{ name: '级进模冲压', status: '已完成', parameters: [{name: '步距', standard: '120', actual: '120.05', unit: 'mm', result: 'pass'}] }]
            },
            {
               key: 'part-001-04-02',
               name: '座椅安装支架-右',
               status: '已完成',
               progress: 100,
               steps: [{ name: '级进模冲压', status: '已完成' }]
            },
            {
               key: 'part-001-04-03',
               name: 'ISOFIX固定环',
               status: '已完成',
               progress: 100,
               steps: [{ name: '冷镦成型', status: '已完成' }]
            }
         ]
      }
    ]
  }
];

const mockOrders: Order[] = [
  {
    key: 'ORD-20231001-001',
    code: 'ORD-20231001-001',
    customer: '特斯拉上海超级工厂',
    status: '生产中',
    orderDate: '2023-10-01',
    planStartDate: '2023-10-05',
    planEndDate: '2023-10-20',
    actualStartDate: '2023-10-05 08:30',
    overallProgress: 65,
    products: [
      {
        productId: 'PROD-001',
        productCode: 'MDY-RB-001',
        productName: 'Model Y 后底板总成',
        totalQuantity: 500,
        unit: '套',
        batches: [
          {
            batchId: 'BATCH-001-A',
            batchNo: 'BATCH-20231005-A',
            quantity: 300,
            status: '进行中',
            progress: 65,
            priority: 'Normal',
            predictedEndDate: '2023-10-21',
            remainingDays: 2,
            bottleneck: '总成焊接工位-Robot3',
            bomTree: batchABomTree,
            risks: [
               { level: 'high', content: '右后纵梁铆接压力异常 (P<0.05)' },
               { level: 'medium', content: '机器人焊接飞溅率呈上升趋势' }
            ]
          },
          {
            batchId: 'BATCH-001-B',
            batchNo: 'BATCH-20231010-B',
            quantity: 200,
            status: '待开始',
            progress: 0,
            priority: 'Normal',
            predictedEndDate: '2023-10-25',
            remainingDays: 6,
            bomTree: [], // 简略
            risks: []
          }
        ]
      },
      {
        productId: 'PROD-002',
        productCode: 'MDY-FB-002',
        productName: 'Model Y 前底板总成',
        totalQuantity: 200,
        unit: '套',
        batches: [
           {
             batchId: 'BATCH-002-A',
             batchNo: 'BATCH-20231012-A',
             quantity: 200,
             status: '待开始',
             progress: 0,
             priority: 'High',
             predictedEndDate: '2023-10-28',
             remainingDays: 10,
             bomTree: [],
             risks: []
           }
        ]
      }
    ]
  },
  {
    key: 'ORD-20231002-005',
    code: 'ORD-20231002-005',
    customer: '比亚迪汽车',
    status: '已完成',
    orderDate: '2023-09-20',
    planStartDate: '2023-09-25',
    planEndDate: '2023-10-05',
    actualStartDate: '2023-09-25 09:00',
    overallProgress: 100,
    products: [
       {
         productId: 'PROD-BYD-001',
         productCode: 'BYD-PACK-001',
         productName: '电池包壳体',
         totalQuantity: 200,
         unit: '件',
         batches: [
            {
               batchId: 'BATCH-BYD-A',
               batchNo: 'BATCH-BYD-001',
               quantity: 200,
               status: '已完成',
               progress: 100,
               priority: 'Normal',
               predictedEndDate: '2023-10-04',
               remainingDays: 0,
               bomTree: [{
                  key: 'root-byd',
                  name: '电池包壳体',
                  status: '已完成',
                  progress: 100,
                  steps: [
                    { name: '原材料准备', status: '已完成', startTime: '2023-09-25', endTime: '2023-09-26' }
                  ]
               }]
            }
         ]
       }
    ]
  },
  {
    key: 'ORD-20231005-012',
    code: 'ORD-20231005-012',
    customer: '蔚来汽车',
    status: '待生产',
    orderDate: '2023-10-05',
    planStartDate: '2023-10-15',
    planEndDate: '2023-10-30',
    actualStartDate: undefined,
    overallProgress: 0,
    products: [
      {
        productId: 'PROD-NIO-001',
        productCode: 'NIO-ST-001',
        productName: '座椅支架',
        totalQuantity: 1000,
        unit: '件',
        batches: [
          {
            batchId: 'BATCH-NIO-001',
            batchNo: 'BATCH-NIO-20231005',
            quantity: 1000,
            status: '待开始',
            progress: 0,
            priority: 'Normal',
            predictedEndDate: '2023-10-30',
            remainingDays: 15,
            bomTree: [{
               key: 'root-nio',
               name: '座椅支架',
               status: '待开始',
               progress: 0,
               steps: [
                 { name: '原材料准备', status: '待开始' },
                 { name: '切割', status: '待开始' },
                 { name: '折弯', status: '待开始' },
                 { name: '焊接', status: '待开始' }
               ]
            }]
          }
        ]
      }
    ]
  },
  {
    key: 'ORD-20231008-020',
    code: 'ORD-20231008-020',
    customer: '理想汽车',
    status: '生产中',
    orderDate: '2023-10-08',
    planStartDate: '2023-10-10',
    planEndDate: '2023-10-25',
    actualStartDate: '2023-10-10 09:00',
    overallProgress: 45,
    products: [
      {
        productId: 'PROD-LI-001',
        productCode: 'LI-L9-001',
        productName: 'L9 前防撞梁',
        totalQuantity: 800,
        unit: '件',
        batches: [
           {
             batchId: 'BATCH-LI-001',
             batchNo: 'BATCH-LI-20231010',
             quantity: 800,
             status: '进行中',
             progress: 45,
             priority: 'High',
             predictedEndDate: '2023-10-26',
             remainingDays: 10,
             bottleneck: '热处理',
             bomTree: [{
                key: 'root-li',
                name: 'L9 前防撞梁',
                status: '进行中',
                progress: 45,
                steps: [
                  { name: '原材料准备', status: '已完成', startTime: '2023-10-10', endTime: '2023-10-11' },
                  { name: '成型', status: '已完成', startTime: '2023-10-12', endTime: '2023-10-14' },
                  { name: '热处理', status: '进行中', startTime: '2023-10-15', remark: '炉温波动较大' },
                  { name: '喷涂', status: '待开始' },
                  { name: '质检', status: '待开始' }
                ]
             }]
           }
        ]
      }
    ]
  },
  {
    key: 'ORD-20231010-033',
    code: 'ORD-20231010-033',
    customer: '小鹏汽车',
    status: '异常',
    orderDate: '2023-10-01',
    planStartDate: '2023-10-05',
    planEndDate: '2023-10-15',
    actualStartDate: '2023-10-05',
    overallProgress: 30,
    products: [
      {
        productId: 'PROD-XP-001',
        productCode: 'XP-G9-001',
        productName: 'G9 电池盒盖',
        totalQuantity: 300,
        unit: '套',
        batches: [
           {
             batchId: 'BATCH-XP-001',
             batchNo: 'BATCH-XP-20231005',
             quantity: 300,
             status: '异常',
             progress: 30,
             priority: 'High',
             predictedEndDate: '2023-10-20',
             remainingDays: 5,
             bottleneck: '缺料',
             bomTree: [{
                key: 'root-xp',
                name: 'G9 电池盒盖',
                status: '异常',
                progress: 30,
                steps: [
                  { name: '原材料准备', status: '已完成' },
                  { name: '冲压', status: '进行中', remark: '原材料供应不足，暂停中' },
                  { name: '焊接', status: '待开始' }
                ]
             }]
           }
        ]
      }
    ]
  },
  {
    key: 'ORD-20230915-008',
    code: 'ORD-20230915-008',
    customer: '吉利汽车',
    status: '已完成',
    orderDate: '2023-09-15',
    planStartDate: '2023-09-18',
    planEndDate: '2023-09-30',
    actualStartDate: '2023-09-18',
    overallProgress: 100,
    products: [
      {
        productId: 'PROD-GEELY-001',
        productCode: 'GEELY-XY-001',
        productName: '星越L 仪表盘支架',
        totalQuantity: 1200,
        unit: '件',
        batches: [
           {
             batchId: 'BATCH-GEELY-001',
             batchNo: 'BATCH-GEELY-20230918',
             quantity: 1200,
             status: '已完成',
             progress: 100,
             priority: 'Normal',
             predictedEndDate: '2023-09-29',
             remainingDays: 0,
             bomTree: [{
                key: 'root-geely',
                name: '星越L 仪表盘支架',
                status: '已完成',
                progress: 100,
                steps: [
                  { name: '全部工序', status: '已完成', endTime: '2023-09-29' }
                ]
             }]
           }
        ]
      }
    ]
  },
  {
    key: 'ORD-20231012-045',
    code: 'ORD-20231012-045',
    customer: '长城汽车',
    status: '待生产',
    orderDate: '2023-10-12',
    planStartDate: '2023-10-20',
    planEndDate: '2023-11-05',
    actualStartDate: undefined,
    overallProgress: 0,
    products: [
      {
        productId: 'PROD-GWM-001',
        productCode: 'GWM-TK-001',
        productName: '坦克300 悬挂臂',
        totalQuantity: 600,
        unit: '件',
        batches: [
           {
             batchId: 'BATCH-GWM-001',
             batchNo: 'BATCH-GWM-20231020',
             quantity: 600,
             status: '待开始',
             progress: 0,
             priority: 'Normal',
             predictedEndDate: '2023-11-05',
             remainingDays: 16,
             bomTree: [{
                key: 'root-gwm',
                name: '坦克300 悬挂臂',
                status: '待开始',
                progress: 0,
                steps: [
                  { name: '备料', status: '待开始' },
                  { name: '锻造', status: '待开始' },
                  { name: '机加工', status: '待开始' }
                ]
             }]
           }
        ]
      }
    ]
  },
  {
    key: 'ORD-20231011-042',
    code: 'ORD-20231011-042',
    customer: '大众安徽',
    status: '生产中',
    orderDate: '2023-10-05',
    planStartDate: '2023-10-08',
    planEndDate: '2023-10-25',
    actualStartDate: '2023-10-08',
    overallProgress: 70,
    products: [
       {
         productId: 'PROD-VW-001',
         productCode: 'VW-ID3-001',
         productName: 'ID.3 车门内板',
         totalQuantity: 2000,
         unit: '件',
         batches: [
            {
              batchId: 'BATCH-VW-001',
              batchNo: 'BATCH-VW-20231008',
              quantity: 2000,
              status: '进行中',
              progress: 70,
              priority: 'Normal',
              predictedEndDate: '2023-10-24',
              remainingDays: 5,
              bomTree: [{
                 key: 'root-vw',
                 name: 'ID.3 车门内板',
                 status: '进行中',
                 progress: 70,
                 steps: [
                    { name: '冲压', status: '已完成' },
                    { name: '焊接', status: '进行中' },
                    { name: '涂装', status: '待开始' }
                 ]
              }]
            }
         ]
       }
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
const currentStepSteps = computed(() => {
  if (currentBomNode.value) return currentBomNode.value.steps || [];
  return [];
});

const currentStepActiveIndex = computed(() => {
  const steps = currentStepSteps.value;
  if (!steps.length) return 0;
  const index = steps.findIndex(s => s.status === '进行中');
  if (index !== -1) return index;
  if (steps.every(s => s.status === '已完成')) return steps.length;
  return 0;
});

// --- Methods ---
const onSelectOrder: TreeProps['onSelect'] = (keys, _info) => {
  if (keys.length > 0) {
    const key = keys[0] as string;
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

const isDelayed = (batch: Batch | null) => {
  if (!batch || !currentOrder.value) return false;
  // If batch doesn't have a specific plan date, compare with order plan date
  // For now, assuming batch should finish by order plan end date
  return new Date(batch.predictedEndDate) > new Date(currentOrder.value.planEndDate);
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
  overflow: hidden;
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

.detail-section {
  flex: 1;
  min-height: 0; // for flex scroll
  
  .step-card {
    height: 100%;
    display: flex;
    flex-direction: column;
    overflow: hidden;
    
    :deep(.ant-card-body) {
      flex: 1;
      overflow: hidden;
      padding: 12px;
      height: 0; /* 关键：配合 flex:1 限制高度，使内部子容器可滚动 */
    }
  }

  .steps-container {
    padding: 10px;
    height: 100%;
    overflow-y: auto;
  }
  
  .analysis-card {
    flex: 1;
    min-height: 0;
    display: flex;
    flex-direction: column;
    overflow: hidden;
    
    :deep(.ant-card-body) {
      flex: 1;
      overflow-y: auto;
      padding: 12px;
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
    display: flex;
    flex-direction: column;
    gap: 12px;

    .compact-row {
      display: flex;
      background: #f9f9f9;
      border-radius: 4px;
      border: 1px solid #f0f0f0;
      padding: 10px 0;
      
      .half-item {
        flex: 1;
        padding: 0 12px;
        display: flex;
        flex-direction: column;
        justify-content: center;
        overflow: hidden; 
        
        .label { font-size: 12px; color: #999; margin-bottom: 2px; }
        .value { 
          font-size: 14px; 
          font-weight: bold; 
          white-space: nowrap; 
          overflow: hidden; 
          text-overflow: ellipsis; 
          
          &.warning { color: #faad14; }
        }
        .sub-status { font-size: 11px; margin-top: 2px; color: #666; }
      }
      
      .v-divider {
        width: 1px;
        background: #e8e8e8;
        margin: 2px 0;
      }
    }

    .compact-item {
      background: #f9f9f9;
      padding: 8px 10px;
      border-radius: 4px;
      border: 1px solid #f0f0f0;
      
      .item-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 2px;
        
        .label {
          font-size: 13px;
          color: #666;
          font-weight: 500;
        }
        
        .value {
          font-size: 13px;
          font-weight: bold;
          
          &.warning { color: #faad14; }
        }
      }
      
      .item-sub {
        font-size: 12px;
        
        &.text-right { text-align: right; }
      }
      
      &.risk-section {
        border-left: 3px solid #faad14;
      }

      &.resource-section {
        .resource-grid {
          display: flex;
          flex-direction: column;
          gap: 8px;
          margin-top: 6px;
          
          .res-item {
            display: flex;
            align-items: center;
            font-size: 12px;
            
            .res-label { width: 60px; color: #666; }
            :deep(.ant-progress) { flex: 1; margin-bottom: 0; .ant-progress-text { font-size: 12px; } }
          }
        }
      }

      &.suggestion-section {
        border-left: 3px solid #52c41a;

        .suggestion-list {
          margin-top: 6px;
          display: flex;
          flex-direction: column;
          gap: 6px;

          .suggestion-item {
            display: flex;
            align-items: flex-start;
            font-size: 12px;
            color: #666;
            line-height: 1.4;

            .success-icon { color: #52c41a; margin-right: 6px; margin-top: 2px; }
            .info-icon { color: #1890ff; margin-right: 6px; margin-top: 2px; }
          }
        }
      }

      &.cost-section {
        .cost-bar-wrapper {
          margin-top: 6px;

          .cost-labels {
            display: flex;
            justify-content: space-between;
            font-size: 11px;
            color: #666;
            margin-bottom: 2px;

            .standard { color: #999; }
          }
        }
      }
    }
  }

.risk-list.compact {
  margin-top: 4px;
  
  .risk-item {
    font-size: 12px;
    margin-bottom: 4px;
    line-height: 1.4;
    
    &:last-child { margin-bottom: 0; }
  }
}

.bom-layout {
  display: flex;
  height: 100%;
  
  .bom-tree-side {
    flex: 0 0 50%;
    display: flex;
    flex-direction: column;
    overflow: hidden;
    padding-right: 10px;
    
    .bom-tree-wrapper {
      flex: 1;
      overflow-y: auto;
    }
  }
  
  .bom-divider {
    width: 1px;
    background-color: #f0f0f0;
    margin: 0 5px;
  }
  
  .bom-steps-side {
    flex: 1;
    display: flex;
    flex-direction: column;
    overflow: hidden;
    padding-left: 5px;
    
    .bom-steps-wrapper {
      flex: 1;
      overflow-y: auto;
      padding-right: 5px;
    }
  }
  
  .bom-header {
    font-weight: bold;
    margin-bottom: 12px;
    padding-bottom: 8px;
    border-bottom: 1px dashed #f0f0f0;
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-size: 14px;
    color: #333;
  }
  
  .bom-subtitle {
    font-size: 12px;
    color: #999;
    font-weight: normal;
  }
}

.bom-node-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
  
  .bom-name {
    flex: 1;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    margin-right: 8px;
    font-size: 13px;
  }
  
  .bom-status-group {
    display: flex;
    align-items: center;
    flex-shrink: 0;
  }
}

.empty-bom-select {
  flex: 1;
  display: flex;
  justify-content: center;
  align-items: center;
}

.step-params {
  margin-top: 8px;
  background-color: #fafafa;
  border-radius: 4px;
  padding: 8px;
  font-size: 12px;
  border: 1px solid #f0f0f0;

  .param-header {
    display: flex;
    font-weight: bold;
    color: #666;
    border-bottom: 1px solid #e8e8e8;
    padding-bottom: 4px;
    margin-bottom: 4px;
  }

  .param-row {
    display: flex;
    padding: 2px 0;
    
    &:hover {
      background-color: #e6f7ff;
    }
  }

  .col-name { flex: 2; color: #333; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
  .col-std { flex: 2; color: #666; }
  .col-act { flex: 2; font-weight: 500; }
  .col-res { flex: 1; text-align: center; }

  .text-error { color: #ff4d4f; }
}

.design-card {
  flex: 0 0 auto;
  
  .design-info-content {
    padding: 0 4px;
  }
  
  .design-actions {
    margin-top: 16px;
    display: flex;
    justify-content: center;
    gap: 12px;
  }
  
  .empty-design {
    padding: 20px 0;
    text-align: center;
  }
}

.risk-list {
  margin-top: 8px;
  
  .risk-item {
    display: flex;
    align-items: center;
    font-size: 12px;
    color: #666;
    margin-bottom: 6px;
    
    .risk-dot {
      width: 6px;
      height: 6px;
      border-radius: 50%;
      margin-right: 8px;
      flex-shrink: 0;
      
      &.red { background-color: #ff4d4f; }
      &.orange { background-color: #faad14; }
    }
  }
}
</style>
