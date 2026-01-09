<template>
  <div class="ebom-container">
    <SplitLayout position="left" :initialWidth="280" :minWidth="220" :maxWidth="520">
      <template #sidebar>
        <a-card title="产品结构树" class="tree-card" :bordered="false">
          <div class="card-tools">
            <a-input-search style="margin-bottom: 8px" placeholder="搜索零部件" />
          </div>
          <div class="scroll-panel">
            <a-tree
              :tree-data="(treeData as unknown as TreeProps['treeData'])"
              :default-expanded-keys="defaultExpandedKeys"
              :selected-keys="selectedKeys"
              @select="onSelect"
            >
              <template #title="{ title, key }">
                <span v-if="key === '0-0'">{{ title }} <a-tag color="blue">V1.0</a-tag></span>
                <span v-else>{{ title }}</span>
              </template>
            </a-tree>
          </div>
        </a-card>
      </template>
      <template #main>
        <a-card title="零部件详情" class="detail-card" :bordered="false">
          <template #extra>
            <a-space>
              <a-button type="primary">新增子件</a-button>
              <a-button>导入EBOM</a-button>
              <a-button>比较差异</a-button>
            </a-space>
          </template>
          <div class="scroll-panel">
            <a-descriptions title="当前节点信息" bordered size="small" style="margin-bottom: 24px">
              <a-descriptions-item label="物料编码">{{ currentNode.key || '-' }}</a-descriptions-item>
              <a-descriptions-item label="物料名称">{{ currentNode.title || '-' }}</a-descriptions-item>
              <a-descriptions-item label="版本">V1.0</a-descriptions-item>
              <a-descriptions-item label="设计者">工程师A</a-descriptions-item>
              <a-descriptions-item label="状态"><a-badge status="processing" text="设计中" /></a-descriptions-item>
              <a-descriptions-item label="关联文档"><a>设计图纸.pdf</a></a-descriptions-item>
            </a-descriptions>

            <a-table :columns="columns" :data-source="currentNodeChildren" :pagination="false" size="middle">
              <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'status'">
                  <a-tag :color="record.status === '已归档' ? 'green' : 'blue'">{{ record.status }}</a-tag>
                </template>
                <template v-else-if="column.key === 'action'">
                  <a>编辑</a>
                  <a-divider type="vertical" />
                  <a>查看图纸</a>
                </template>
              </template>
            </a-table>
          </div>
        </a-card>
      </template>
    </SplitLayout>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import type { TreeProps } from 'ant-design-vue';
import type { Key } from 'ant-design-vue/es/table/interface';
import SplitLayout from '@/components/SplitLayout/index.vue';

const selectedKeys = ref<Key[]>(['0-0']);

const treeData = [
  {
    title: '高性能服务器主机 A1',
    key: 'PRD-2024001',
    children: [
      {
        title: '机箱组件',
        key: 'ASM-001',
        children: [
          { title: '前面板', key: 'PRT-101', isLeaf: true },
          { title: '侧板', key: 'PRT-102', isLeaf: true },
          { title: '机架', key: 'PRT-103', isLeaf: true },
        ],
      },
      {
        title: '主板模组',
        key: 'ASM-002',
        children: [
          { title: 'PCB主板', key: 'PRT-201', isLeaf: true },
          { title: 'CPU插槽', key: 'PRT-202', isLeaf: true },
          { title: '散热器', key: 'PRT-203', isLeaf: true },
        ],
      },
      {
        title: '电源模块',
        key: 'ASM-003',
        isLeaf: true,
      },
    ],
  },
  {
    title: '地铁车辆 S1',
    key: 'SUB-0001',
    children: [
      {
        title: '车体系统',
        key: 'SYS-SUB-001',
        children: [
          {
            title: '车体结构',
            key: 'ASM-SUB-001-01',
            children: [
              {
                title: '底架组件',
                key: 'ASM-SUB-001-01-01',
                children: [
                  {
                    title: '左主梁',
                    key: 'PRT-SUB-001-01-01-01',
                    children: [
                      { title: '加强板', key: 'PRT-SUB-001-01-01-01-01', isLeaf: true },
                    ],
                  },
                ],
              },
            ],
          },
          {
            title: '内装系统',
            key: 'ASM-SUB-001-02',
            children: [
              {
                title: '座椅组件',
                key: 'ASM-SUB-001-02-01',
                children: [
                  {
                    title: '座椅骨架',
                    key: 'PRT-SUB-001-02-01-01',
                    children: [
                      { title: '连接件', key: 'PRT-SUB-001-02-01-01-01', isLeaf: true },
                    ],
                  },
                ],
              },
            ],
          },
        ],
      },
      {
        title: '牵引系统',
        key: 'SYS-SUB-002',
        children: [
          {
            title: '电机总成',
            key: 'ASM-SUB-002-01',
            children: [
              {
                title: '转子组件',
                key: 'ASM-SUB-002-01-01',
                children: [
                  {
                    title: '轴心',
                    key: 'PRT-SUB-002-01-01-01',
                    children: [
                      { title: '轴承', key: 'PRT-SUB-002-01-01-01-01', isLeaf: true },
                    ],
                  },
                ],
              },
            ],
          },
        ],
      },
    ],
  },
  {
    title: '飞机发动机 E1',
    key: 'ENG-0001',
    children: [
      {
        title: '高压压气机系统',
        key: 'SYS-ENG-001',
        children: [
          {
            title: '压气机总成',
            key: 'ASM-ENG-001-01',
            children: [
              {
                title: '叶片组件',
                key: 'ASM-ENG-001-01-01',
                children: [
                  {
                    title: '第一级叶片',
                    key: 'PRT-ENG-001-01-01-01',
                    children: [
                      { title: '叶片根部嵌件', key: 'PRT-ENG-001-01-01-01-01', isLeaf: true },
                    ],
                  },
                ],
              },
            ],
          },
        ],
      },
      {
        title: '燃烧室系统',
        key: 'SYS-ENG-002',
        children: [
          {
            title: '喷嘴总成',
            key: 'ASM-ENG-002-01',
            children: [
              {
                title: '内喷管',
                key: 'PRT-ENG-002-01-01',
                children: [
                  {
                    title: '密封圈',
                    key: 'PRT-ENG-002-01-01-01',
                    children: [
                      { title: '扣件', key: 'PRT-ENG-002-01-01-01-01', isLeaf: true },
                    ],
                  },
                ],
              },
            ],
          },
        ],
      },
    ],
  },
  {
    title: '汽车 M1',
    key: 'CAR-0001',
    children: [
      {
        title: '发动机系统',
        key: 'SYS-CAR-001',
        children: [
          {
            title: '发动机总成',
            key: 'ASM-CAR-001-01',
            children: [
              {
                title: '缸盖组件',
                key: 'ASM-CAR-001-01-01',
                children: [
                  {
                    title: '气门总成',
                    key: 'ASM-CAR-001-01-01-01',
                    children: [
                      { title: '进气门', key: 'PRT-CAR-001-01-01-01-01', isLeaf: true },
                    ],
                  },
                ],
              },
            ],
          },
        ],
      },
      {
        title: '底盘系统',
        key: 'SYS-CAR-002',
        children: [
          {
            title: '悬架总成',
            key: 'ASM-CAR-002-01',
            children: [
              {
                title: '减震器组件',
                key: 'ASM-CAR-002-01-01',
                children: [
                  {
                    title: '活塞杆',
                    key: 'PRT-CAR-002-01-01-01',
                    children: [
                      { title: '密封件', key: 'PRT-CAR-002-01-01-01-01', isLeaf: true },
                    ],
                  },
                ],
              },
            ],
          },
        ],
      },
    ],
  },
];

const defaultExpandedKeys = treeData.map(node => node.key);

const columns: ColumnType[] = [
  { title: '物料编码', dataIndex: 'key', key: 'key' },
  { title: '物料名称', dataIndex: 'title', key: 'title' },
  { title: '规格型号', dataIndex: 'spec', key: 'spec' },
  { title: '数量', dataIndex: 'qty', key: 'qty' },
  { title: '单位', dataIndex: 'unit', key: 'unit' },
  { title: '状态', dataIndex: 'status', key: 'status' },
  { title: '操作', key: 'action' },
];

const flattenData = (data: any[]): any[] => {
  let result: any[] = [];
  data.forEach(item => {
    result.push(item);
    if (item.children) {
      result = result.concat(flattenData(item.children));
    }
  });
  return result;
};

const allNodes = flattenData(treeData);

const currentNode = computed(() => {
  const key = selectedKeys.value[0];
  return allNodes.find(item => item.key === key) || treeData[0];
});

const currentNodeChildren = computed(() => {
  const node = currentNode.value;
  if (!node || !node.children) return [];
  return node.children.map((child: any) => ({
    ...child,
    spec: 'Standard',
    qty: 1,
    unit: 'PCS',
    status: '设计中'
  }));
});

const onSelect: TreeProps['onSelect'] = (keys, _info) => {
  if (keys.length > 0) {
    selectedKeys.value = keys;
  }
};
</script>

<style scoped>
.ebom-container {
  padding: 10px;
  flex: 1;
  overflow: hidden;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
}
.ebom-container :deep(.split-layout) {
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
.scroll-panel {
  flex: 1;
  min-height: 0;
  overflow: auto;
}
.card-tools {
  padding-right: 16px;
}
</style>
