<template>
  <div class="pbom-container">
    <SplitLayout position="left" :initialWidth="300" :minWidth="220" :maxWidth="520">
      <template #sidebar>
        <a-card title="产品结构树 (EBOM)" class="tree-card" :bordered="false">
          <template #extra>
             <a-tag color="blue">V3.2</a-tag>
          </template>
          <div class="card-tools">
            <a-input-search style="margin-bottom: 8px" placeholder="搜索零部件" />
          </div>
          <div class="scroll-panel">
            <a-tree
              :tree-data="treeData"
              :default-expanded-keys="defaultExpandedKeys"
              :selected-keys="selectedKeys"
              block-node
              @select="onSelect"
            >
              <template #title="{ data }">
                 <span class="tree-node-title">
                   <component 
                     :is="data.children && data.children.length > 0 ? ApartmentOutlined : FileTextOutlined" 
                     style="margin-right: 6px; color: #1890ff"
                   />
                   <span class="node-name">{{ data.name }}</span>
                 </span>
              </template>
            </a-tree>
          </div>
        </a-card>
      </template>
      <template #main>
        <div class="main-content" v-if="currentNode">
          <!-- Top: Design Info -->
          <a-card title="设计属性" :bordered="false" size="small" style="margin-bottom: 10px; flex-shrink: 0;">
             <a-descriptions :column="4" size="small">
                <a-descriptions-item label="物料编码">{{ currentNode.key }}</a-descriptions-item>
                <a-descriptions-item label="物料名称">{{ currentNode.name }}</a-descriptions-item>
                <a-descriptions-item label="材料">{{ currentNode.designInfo?.material || '-' }}</a-descriptions-item>
                <a-descriptions-item label="重量">{{ currentNode.designInfo?.weight || '-' }}</a-descriptions-item>
                <a-descriptions-item label="图号">{{ currentNode.designInfo?.drawingNo || '-' }}</a-descriptions-item>
                <a-descriptions-item label="版本">{{ currentNode.designInfo?.version || '-' }}</a-descriptions-item>
                <a-descriptions-item label="规格">{{ currentNode.designInfo?.specs || '-' }}</a-descriptions-item>
             </a-descriptions>
          </a-card>

          <!-- Bottom: Process Design -->
          <a-card title="工艺路线设计 (Process Routing)" class="detail-card" :bordered="false">
            <template #extra>
              <a-space>
                <a-button type="primary">
                   <template #icon><SaveOutlined /></template>
                   保存设计
                </a-button>
                <a-button>
                   <template #icon><CopyOutlined /></template>
                   复制工艺
                </a-button>
              </a-space>
            </template>
            <div class="detail-split">
              <SplitLayout position="left" :initialWidth="240" :minWidth="200" :maxWidth="400">
                <template #sidebar>
                  <div class="step-list-header">
                     <span>工序列表</span>
                     <a-button type="link" size="small"><PlusOutlined /></a-button>
                  </div>
                  <div class="scroll-panel">
                    <a-steps :current="currentStepIndex" size="small" direction="vertical" class="process-steps" @change="onStepChange">
                      <a-step v-for="(step, index) in currentNode.processes" :key="index">
                         <template #title>
                            {{ step.name }}
                         </template>
                         <template #description>
                            <span style="font-size: 12px; color: #999;">Std: {{ step.standardTime }} min</span>
                         </template>
                      </a-step>
                    </a-steps>
                    <div v-if="!currentNode.processes || currentNode.processes.length === 0" class="empty-steps">
                       <a-empty description="暂无工序" image="simple" />
                    </div>
                  </div>
                </template>
                <template #main>
                  <div class="scroll-panel" v-if="currentProcess">
                    <div class="process-info">
                       <a-alert :message="currentProcess.name" type="info" show-icon style="margin-bottom: 16px">
                          <template #description>
                             {{ currentProcess.description || '暂无描述' }}
                          </template>
                       </a-alert>
                       
                       <a-row :gutter="16" style="margin-bottom: 16px">
                         <a-col :span="8">
                           <a-statistic title="标准工时" :value="currentProcess.standardTime" suffix="分钟" />
                         </a-col>
                         <a-col :span="8">
                           <a-statistic title="工序等级" value="关键工序" />
                         </a-col>
                         <a-col :span="8">
                           <a-statistic title="所需人数" :value="2" suffix="人" />
                         </a-col>
                       </a-row>
                    </div>
                    
                    <a-tabs>
                       <a-tab-pane key="1" tab="工艺参数 (Parameters)">
                          <a-table :columns="paramColumns" :data-source="currentProcess.parameters" :pagination="false" size="small">
                            <template #bodyCell="{ column }">
                               <template v-if="column.key === 'action'">
                                  <a type="link" danger>移除</a>
                               </template>
                            </template>
                          </a-table>
                          <a-button type="dashed" block style="margin-top: 8px">
                             <PlusOutlined /> 添加参数
                          </a-button>
                       </a-tab-pane>
                       
                       <a-tab-pane key="2" tab="物料清单 (BOM)">
                          <a-table :columns="resourceColumns" :data-source="currentMaterials" :pagination="false" size="small">
                             <template #bodyCell="{ column }">
                                <template v-if="column.key === 'action'">
                                   <a type="link" danger>移除</a>
                                </template>
                             </template>
                          </a-table>
                          <a-button type="dashed" block style="margin-top: 8px">
                             <PlusOutlined /> 添加物料
                          </a-button>
                       </a-tab-pane>
                       
                       <a-tab-pane key="3" tab="工装夹具 (Tools)">
                           <a-list item-layout="horizontal" :data-source="currentTools">
                            <template #renderItem="{ item }">
                              <a-list-item>
                                <template #actions>
                                   <a key="edit">编辑</a>
                                   <a key="delete" style="color: red">移除</a>
                                </template>
                                <a-list-item-meta :description="item.code">
                                  <template #title>
                                    <a>{{ item.name }}</a>
                                  </template>
                                  <template #avatar>
                                    <a-avatar style="background-color: #87d068" size="small">T</a-avatar>
                                  </template>
                                </a-list-item-meta>
                                <div>x {{ item.qty }}</div>
                              </a-list-item>
                            </template>
                          </a-list>
                          <a-button type="dashed" block style="margin-top: 8px">
                             <PlusOutlined /> 添加工具
                          </a-button>
                       </a-tab-pane>

                       <a-tab-pane key="4" tab="质量风险 (FMEA)">
                          <a-list item-layout="horizontal" :data-source="currentRisks">
                            <template #renderItem="{ item }">
                              <a-list-item>
                                <template #actions>
                                   <a key="edit">编辑</a>
                                   <a key="delete" style="color: red">移除</a>
                                </template>
                                <a-list-item-meta :description="item.content">
                                  <template #title>
                                    <span>
                                      <a-tag :color="item.level === 'high' ? 'red' : item.level === 'medium' ? 'orange' : 'blue'">
                                        {{ item.level === 'high' ? '高风险' : item.level === 'medium' ? '中风险' : '低风险' }}
                                      </a-tag>
                                      {{ item.type || '质量风险' }}
                                    </span>
                                  </template>
                                </a-list-item-meta>
                              </a-list-item>
                            </template>
                          </a-list>
                          <a-button type="dashed" block style="margin-top: 8px">
                             <PlusOutlined /> 添加风险项
                          </a-button>
                       </a-tab-pane>
                    </a-tabs>
                  </div>
                  <div v-else class="empty-selection">
                     <a-empty description="请选择工序查看详情" />
                  </div>
                </template>
              </SplitLayout>
            </div>
          </a-card>
        </div>
        <div v-else class="empty-selection">
           <a-empty description="请选择左侧零部件查看工艺设计" />
        </div>
      </template>
    </SplitLayout>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import SplitLayout from '@/components/SplitLayout/index.vue';
import { 
  ApartmentOutlined, 
  FileTextOutlined, 
  SaveOutlined, 
  CopyOutlined,
  PlusOutlined
} from '@ant-design/icons-vue';

// --- Types ---
interface DesignInfo {
  material: string;
  weight: string;
  drawingNo: string;
  version: string;
  specs: string;
  taktTime?: string; // e.g. "50s"
}

interface ParameterDef {
  name: string;
  standard: string;
  unit: string;
}

interface ProcessResource {
  code: string;
  name: string;
  qty: number;
  unit?: string;
  type: 'Material' | 'Tool';
}

interface RiskDef {
  content: string;
  level: 'high' | 'medium' | 'low';
  type?: string;
}

interface ProcessStep {
  name: string;
  description?: string;
  standardTime: number; // minutes
  parameters: ParameterDef[];
  resources: ProcessResource[];
  risks?: RiskDef[];
}

interface PbomNode {
  key: string;
  name: string;
  designInfo?: DesignInfo;
  processes: ProcessStep[];
  children?: PbomNode[];
}

// --- State ---
const currentStepIndex = ref(0);
const selectedKeys = ref<string[]>([]);
const currentNode = ref<PbomNode | null>(null);

// --- Mock Data (Based on Model Y from Order View) ---
const treeData: PbomNode[] = [
  {
    key: 'part-001',
    name: 'Model Y 后底板总成',
    designInfo: { material: '多材料混合', weight: '65.5kg', drawingNo: 'ASY-MDY-RB-001', version: 'V3.2', specs: '1650x1400x450mm' },
    processes: [
       { 
         name: 'OP10-总成拼装', 
         description: '将左/右纵梁与后横梁进行初步拼装定位',
         standardTime: 45,
         parameters: [
           { name: '夹具定位精度', standard: '±0.05', unit: 'mm' },
           { name: '上料节拍', standard: '≤45', unit: 's' }
         ],
         resources: [
            { code: 'part-001-01', name: '左后纵梁分总成', qty: 1, unit: 'SET', type: 'Material' },
            { code: 'part-001-02', name: '右后纵梁分总成', qty: 1, unit: 'SET', type: 'Material' },
            { code: 'FIX-001', name: '总成拼装夹具', qty: 1, unit: 'SET', type: 'Tool' }
         ]
       },
       { 
         name: 'OP20-机器人焊接(Laser)', 
         description: '使用高功率激光焊接机器人进行主焊缝焊接',
         standardTime: 60,
         parameters: [
           { name: '激光功率', standard: '4000±100', unit: 'W' },
           { name: '焊接速度', standard: '80-100', unit: 'mm/s' },
           { name: '保护气(Ar)流量', standard: '15-20', unit: 'L/min' },
           { name: '离焦量', standard: '0±1', unit: 'mm' }
         ],
         resources: [
            { code: 'ROBOT-L1', name: '激光焊接机器人', qty: 2, unit: '台', type: 'Tool' },
            { code: 'MAT-WIRE', name: '焊丝 ER4043', qty: 0.5, unit: 'kg', type: 'Material' }
         ]
       },
       { 
         name: 'OP30-涂胶与固化', 
         description: '结构胶涂布及红外加热固化',
         standardTime: 30,
         parameters: [
           { name: '胶条直径', standard: '3.0±0.5', unit: 'mm' },
           { name: '固化炉温', standard: '160±5', unit: '°C' }
         ],
         resources: [
            { code: 'GLUE-001', name: '结构胶 3M-DP420', qty: 200, unit: 'ml', type: 'Material' }
         ]
       },
       { name: 'OP40-FDS流钻螺钉连接', standardTime: 20, parameters: [], resources: [] },
       { name: 'OP50-在线测量(Perceptron)', standardTime: 15, parameters: [], resources: [] }
    ],
    children: [
      {
        key: 'part-001-01',
        name: '左后纵梁分总成',
        designInfo: { material: 'Al-Si10MnMg / DP980', weight: '18.2kg', drawingNo: 'SUB-L-001', version: 'V3.0', specs: '1200x400x300mm' },
        processes: [
           { 
             name: 'OP10-SPR铆接', 
             standardTime: 25,
             parameters: [
              { name: '铆接压力', standard: '50-60', unit: 'kN' },
              { name: '铆点高度', standard: '2.5±0.2', unit: 'mm' }
             ],
             resources: [
                { code: 'RIVET-001', name: 'SPR铆钉 5x5', qty: 24, unit: 'PCS', type: 'Material' }
             ]
           },
           { 
             name: 'OP20-CMT焊接', 
             standardTime: 35,
             parameters: [
              { name: '送丝速度', standard: '8.0-9.0', unit: 'm/min' },
              { name: '焊接电流', standard: '180±10', unit: 'A' }
             ],
             resources: []
           }
        ],
        children: [
          {
            key: 'part-001-01-01',
            name: '左前纵梁 (一体化压铸铝)',
            designInfo: { material: 'Tesla自研铝合金', weight: '12.5kg', drawingNo: 'CST-L-F-01', version: 'V4.1', specs: '一体成型' },
            processes: [
              { name: 'OP10-熔炼', standardTime: 120, parameters: [{ name: '铝液温度', standard: '680±10', unit: '°C' }], resources: [] },
              { name: 'OP20-6000T压铸', standardTime: 5, parameters: [{ name: '压射速度', standard: '5.5-6.5', unit: 'm/s' }], resources: [] },
              { name: 'OP30-X-Ray探伤', standardTime: 10, parameters: [{ name: '气孔等级', standard: '≤Level 2', unit: '' }], resources: [] },
              { name: 'OP40-CNC加工', standardTime: 45, parameters: [{ name: '位置度', standard: '0.5', unit: 'mm' }], resources: [] }
            ]
          },
          {
             key: 'part-001-01-02',
             name: '左后轮罩板',
             designInfo: { material: 'DC06', weight: '4.5kg', drawingNo: 'STP-002', version: 'V1.0', specs: '冲压件' },
             processes: [
                { name: 'OP10-拉延', standardTime: 10, parameters: [{ name: '冲压力', standard: '2000±100', unit: 'kN' }], resources: [] },
                { name: 'OP20-修边冲孔', standardTime: 8, parameters: [], resources: [] }
             ]
          }
        ]
      },
      {
        key: 'part-001-02',
        name: '右后纵梁分总成',
        designInfo: { material: 'Al-Si10MnMg / DP980', weight: '18.2kg', drawingNo: 'SUB-R-001', version: 'V3.0', specs: '对称件' },
        processes: [
           { name: 'OP10-SPR铆接', standardTime: 25, parameters: [], resources: [] },
           { name: 'OP20-CMT焊接', standardTime: 35, parameters: [], resources: [] }
        ]
      }
    ]
  }
];

const defaultExpandedKeys = ['part-001', 'part-001-01'];

// --- Columns ---
const paramColumns = [
  { title: '参数名称', dataIndex: 'name', key: 'name' },
  { title: '标准值', dataIndex: 'standard', key: 'standard' },
  { title: '单位', dataIndex: 'unit', key: 'unit', width: 80 },
  { title: '操作', key: 'action', width: 80 },
];

const resourceColumns = [
  { title: '物料/资源编码', dataIndex: 'code', key: 'code' },
  { title: '名称', dataIndex: 'name', key: 'name' },
  { title: '定额数量', dataIndex: 'qty', key: 'qty' },
  { title: '单位', dataIndex: 'unit', key: 'unit', width: 80 },
  { title: '操作', key: 'action', width: 80 },
];

// --- Computeds ---
const currentProcess = computed(() => {
  if (!currentNode.value || !currentNode.value.processes) return null;
  return currentNode.value.processes[currentStepIndex.value];
});

const currentMaterials = computed(() => {
  if (!currentProcess.value) return [];
  return currentProcess.value.resources.filter(r => r.type === 'Material');
});

const currentTools = computed(() => {
  if (!currentProcess.value) return [];
  return currentProcess.value.resources.filter(r => r.type === 'Tool');
});

const currentRisks = computed(() => {
  if (!currentProcess.value || !currentProcess.value.risks) return [];
  return currentProcess.value.risks;
});

// --- Methods ---
const onSelect = (keys: string[]) => {
  if (keys.length > 0 && keys[0]) {
    selectedKeys.value = keys;
    // Find node logic (recursive)
    const findNode = (nodes: PbomNode[], key: string): PbomNode | undefined => {
      for (const node of nodes) {
        if (node.key === key) return node;
        if (node.children) {
          const found = findNode(node.children, key);
          if (found) return found;
        }
      }
      return undefined;
    };
    
    const node = findNode(treeData, keys[0]);
    if (node) {
      currentNode.value = node;
      currentStepIndex.value = 0; // Reset step selection
    }
  }
};

const onStepChange = (current: number) => {
  currentStepIndex.value = current;
};

// --- Init ---
onMounted(() => {
   // Select root by default
   selectedKeys.value = ['part-001'];
   if (treeData.length > 0) {
      const rootNode = treeData[0];
      if (rootNode) {
        currentNode.value = rootNode;
      }
   }
});

</script>

<style scoped>
.pbom-container {
  padding: 10px;
  flex: 1;
  overflow: hidden;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
}
.main-content {
  height: 100%;
  display: flex;
  flex-direction: column;
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
.detail-card {
  flex: 1;
  min-height: 0;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
.detail-card :deep(.ant-card-body) {
  flex: 1;
  min-height: 0;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  padding: 16px 0 0 16px;
}
.detail-split {
  flex: 1;
  min-height: 0;
  display: flex;
  flex-direction: column;
}
.detail-split :deep(.split-layout) {
  flex: 1;
  width: 100%;
  height: 100%;
  overflow: hidden;
}
.scroll-panel {
  flex: 1;
  min-height: 0;
  overflow-y: auto;
  overflow-x: hidden;
  padding: 8px;
}
.card-tools {
  padding-right: 16px;
}
.step-list-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 16px 8px 0;
  border-bottom: 1px solid #f0f0f0;
  margin-bottom: 12px;
  font-weight: 500;
}
.process-info {
  margin-bottom: 8px;
}
.process-steps {
  margin-bottom: 16px;
}
.process-steps :deep(.ant-steps-item) {
  cursor: pointer;
}
.process-steps :deep(.ant-steps-item-content) {
  padding: 0 8px;
  border-radius: 4px;
  transition: background-color 0.3s;
  min-height: 24px; /* 修正：匹配 small 尺寸图标高度 (24px) */
}
.process-steps :deep(.ant-steps-item-title) {
  line-height: 24px; /* 修正：匹配 small 尺寸图标高度 (24px) */
  margin-bottom: 0;
  font-size: 14px; /* 确保字体大小合适 */
}
.process-steps :deep(.ant-steps-item-container) {
  border-radius: 4px;
  transition: background-color 0.3s;
  padding: 4px;
}
.process-steps :deep(.ant-steps-item-tail) {
  left: 16px !important; /* 修正：4px padding + 12px half icon = 16px */
  top: 4px !important;
  padding-bottom: 4px !important;
}
.process-steps :deep(.ant-steps-item-icon) {
  margin-right: 0 !important; /* 移除图标右边距 */
}
.process-steps :deep(.ant-steps-item-container:hover) {
  background-color: #fafafa;
}
.process-steps :deep(.ant-steps-item-process .ant-steps-item-container) {
  background-color: #e6f7ff;
}
.process-steps :deep(.ant-steps-item-content:hover) {
  color: #1890ff;
}
.process-steps :deep(.ant-steps-item-process .ant-steps-item-content) {
  font-weight: 500;
}
.empty-selection {
   display: flex;
   align-items: center;
   justify-content: center;
   height: 100%;
   color: #999;
}
.empty-steps {
   margin-top: 40px;
}
.tree-node-title {
  display: flex;
  align-items: center;
}
.node-name {
  font-weight: normal;
  color: #333;
}
</style>
