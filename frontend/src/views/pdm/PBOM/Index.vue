<template>
  <div class="pbom-container">
    <SplitLayout position="left" :initialWidth="280" :minWidth="220" :maxWidth="520">
      <template #sidebar>
        <a-card title="产品结构树" class="tree-card" :bordered="false">
          <div class="card-tools">
            <a-input-search style="margin-bottom: 8px" placeholder="搜索零部件" />
          </div>
          <div class="scroll-panel">
            <a-tree
              :tree-data="treeData"
              :default-expanded-keys="defaultExpandedKeys"
              :selected-keys="selectedKeys"
              @select="onSelect"
            />
          </div>
        </a-card>
      </template>
      <template #main>
        <a-card title="工序物料分配" class="detail-card" :bordered="false">
          <template #extra>
            <a-space>
              <a-button type="primary">保存分配</a-button>
              <a-button>自动匹配</a-button>
            </a-space>
          </template>
          <div class="detail-split">
            <SplitLayout position="left" :initialWidth="220" :minWidth="220" :maxWidth="600">
              <template #sidebar>
                <div class="scroll-panel">
                  <a-steps :current="currentStep" size="small" direction="vertical" class="process-steps" @change="onStepChange">
                    <a-step title="OP10 机箱预装" />
                    <a-step title="OP20 主板安装" />
                    <a-step title="OP30 内部连线" />
                    <a-step title="OP40 整机测试" />
                    <a-step title="OP50 包装入库" />
                  </a-steps>
                </div>
              </template>
              <template #main>
                <div class="scroll-panel">
                  <div class="process-info">
                     <a-alert :message="currentProcessTitle" type="info" show-icon style="margin-bottom: 16px" />
                     <a-row :gutter="16" style="margin-bottom: 16px">
                       <a-col :span="12">
                         <a-statistic title="工时定额" :value="15" suffix="分钟" />
                       </a-col>
                       <a-col :span="12">
                         <a-statistic title="所需人数" :value="2" suffix="人" />
                       </a-col>
                     </a-row>
                  </div>
                  
                  <a-divider orientation="left">消耗物料清单</a-divider>
                  <a-table :columns="columns" :data-source="currentMaterials" :pagination="false" size="middle">
                    <template #bodyCell="{ column }">
                      <template v-if="column.key === 'action'">
                        <a>移除</a>
                      </template>
                    </template>
                  </a-table>

                  <a-divider orientation="left">所需工装夹具</a-divider>
                   <a-list item-layout="horizontal" :data-source="currentTools">
                    <template #renderItem="{ item }">
                      <a-list-item>
                        <a-list-item-meta :description="item.code">
                          <template #title>
                            <a>{{ item.name }}</a>
                          </template>
                          <template #avatar>
                            <a-avatar style="background-color: #87d068">T</a-avatar>
                          </template>
                        </a-list-item-meta>
                        <div>数量: {{ item.qty }}</div>
                      </a-list-item>
                    </template>
                  </a-list>
                </div>
              </template>
            </SplitLayout>
          </div>
        </a-card>
      </template>
    </SplitLayout>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import SplitLayout from '@/components/SplitLayout/index.vue';

const currentStep = ref(0);

const selectedKeys = ref(['PRD-2024001']);
const treeData = [
  {
    title: '高性能服务器主机 A1',
    key: 'PRD-2024001',
    children: [
      { title: '机箱组件', key: 'ASM-001' },
      { title: '主板模组', key: 'ASM-002' },
      { title: '电源模块', key: 'ASM-003' },
    ],
  },
  {
    title: '地铁车辆 S1',
    key: 'SUB-0001',
    children: [
      { title: '车体系统', key: 'SYS-SUB-001' },
      { title: '牵引系统', key: 'SYS-SUB-002' },
    ],
  },
  {
    title: '飞机发动机 E1',
    key: 'ENG-0001',
    children: [
      { title: '高压压气机系统', key: 'SYS-ENG-001' },
      { title: '燃烧室系统', key: 'SYS-ENG-002' },
    ],
  },
  {
    title: '汽车 M1',
    key: 'CAR-0001',
    children: [
      { title: '发动机系统', key: 'SYS-CAR-001' },
      { title: '底盘系统', key: 'SYS-CAR-002' },
    ],
  },
];
const defaultExpandedKeys = treeData.map(n => n.key);

const processes = [
  {
    title: 'OP10 机箱预装',
    materials: [
      { code: 'ASM-001', name: '机箱组件', qty: 1, unit: 'SET' },
      { code: 'ASM-003', name: '电源模块', qty: 1, unit: 'PCS' },
    ],
    tools: [
       { code: 'TOOL-001', name: '电动螺丝刀', qty: 1 },
    ]
  },
  {
    title: 'OP20 主板安装',
    materials: [
      { code: 'ASM-002', name: '主板模组', qty: 1, unit: 'SET' },
      { code: 'AUX-001', name: '装配螺丝包', qty: 1, unit: 'PKG' },
    ],
    tools: [
       { code: 'TOOL-002', name: '防静电手环', qty: 1 },
       { code: 'TOOL-001', name: '电动螺丝刀', qty: 1 },
    ]
  },
  {
    title: 'OP30 内部连线',
    materials: [
      { code: 'CBL-001', name: 'SATA数据线', qty: 2, unit: 'PCS' },
      { code: 'CBL-002', name: '电源转接线', qty: 1, unit: 'PCS' },
    ],
    tools: []
  },
  {
    title: 'OP40 整机测试',
    materials: [],
    tools: [
       { code: 'EQP-101', name: '自动测试台', qty: 1 },
    ]
  },
  {
    title: 'OP50 包装入库',
    materials: [
       { code: 'PKG-001', name: '包装箱', qty: 1, unit: 'PCS' },
       { code: 'PKG-002', name: '泡沫缓冲垫', qty: 2, unit: 'PCS' },
    ],
    tools: [
        { code: 'TOOL-003', name: '封箱机', qty: 1 },
    ]
  },
];

const columns = [
  { title: '物料编码', dataIndex: 'code', key: 'code' },
  { title: '物料名称', dataIndex: 'name', key: 'name' },
  { title: '定额数量', dataIndex: 'qty', key: 'qty' },
  { title: '单位', dataIndex: 'unit', key: 'unit' },
  { title: '操作', key: 'action' },
];

const onSelect = (keys: string[]) => {
  if (keys.length > 0) selectedKeys.value = keys;
};

const currentProcessTitle = computed(() => {
  const process = processes[currentStep.value];
  return process ? process.title : '';
});

const currentMaterials = computed(() => {
  const process = processes[currentStep.value];
  return process ? process.materials : [];
});

const currentTools = computed(() => {
  const process = processes[currentStep.value];
  return process ? process.tools : [];
});

const onStepChange = (current: number) => {
  currentStep.value = current;
};
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
.full-row {
  flex: 1;
  min-height: 0;
  overflow: hidden;
  height: 100%;
}
.col-wrap {
  height: 100%;
  display: flex;
  flex-direction: column;
  min-height: 0;
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
  height: 100%;
  display: flex;
  flex-direction: column;
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
}
.card-tools {
  padding-right: 16px;
}
.process-info {
  margin-bottom: 8px;
}
.process-steps {
  margin-bottom: 16px;
}
.process-steps :deep(.ant-steps) {
  width: 100%;
  overflow: hidden;
}
.process-steps :deep(.ant-steps-item-title) {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.process-steps :deep(.ant-steps-item-description) {
  white-space: normal;
  word-break: break-word;
}
.process-steps :deep(.ant-steps-item) {
  max-width: 100%;
}
.process-steps :deep(.ant-steps-item-container) {
  width: 100%;
}
.process-steps :deep(.ant-steps-item-icon) {
  display: flex;
  align-items: center;
  justify-content: center;
}
.process-steps :deep(.ant-steps-item-content) {
  display: flex;
  align-items: center;
}
</style>
