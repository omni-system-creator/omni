<template>
  <div class="mbom-container">
    <SplitLayout position="left" :initialWidth="280" :minWidth="220" :maxWidth="520">
      <template #sidebar>
        <a-card title="制造BOM结构" class="tree-card" :bordered="false">
          <div class="card-tools">
            <a-input-search style="margin-bottom: 8px" placeholder="搜索制造件" />
          </div>
          <div class="scroll-panel">
            <a-tree
              :tree-data="treeData"
              :default-expanded-keys="defaultExpandedKeys"
              :selected-keys="selectedKeys"
              @select="onSelect"
            >
              <template #title="{ title, key }">
                <span v-if="key === 'PRD-2024001'">{{ title }} <a-tag color="orange">生产中</a-tag></span>
                <span v-else>{{ title }}</span>
              </template>
            </a-tree>
          </div>
        </a-card>
      </template>
      <template #main>
        <a-card title="制造清单详情" class="detail-card" :bordered="false">
          <template #extra>
            <a-space>
              <a-button type="primary">同步EBOM</a-button>
              <a-button>添加辅料</a-button>
              <a-button>发布MBOM</a-button>
            </a-space>
          </template>
          <div class="scroll-panel">
            <a-descriptions title="生产节点属性" bordered size="small" style="margin-bottom: 24px">
              <a-descriptions-item label="物料编码">{{ currentNode.key || '-' }}</a-descriptions-item>
              <a-descriptions-item label="物料名称">{{ currentNode.title || '-' }}</a-descriptions-item>
              <a-descriptions-item label="工艺路线">Route-001 (总装)</a-descriptions-item>
              <a-descriptions-item label="生产车间">总装车间</a-descriptions-item>
              <a-descriptions-item label="生效日期">2024-01-01</a-descriptions-item>
              <a-descriptions-item label="虚拟件">否</a-descriptions-item>
            </a-descriptions>

            <a-table :columns="columns" :data-source="currentNodeChildren" :pagination="false" size="middle">
              <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'type'">
                  <a-tag :color="record.type === '辅料' ? 'cyan' : 'blue'">{{ record.type }}</a-tag>
                </template>
                <template v-else-if="column.key === 'action'">
                  <a>替代料</a>
                  <a-divider type="vertical" />
                  <a>定额</a>
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

const selectedKeys = ref<Key[]>(['PRD-2024001']);

const treeData = [
  {
    title: '高性能服务器主机 A1',
    key: 'PRD-2024001',
    children: [
      {
        title: '机箱装配组件',
        key: 'ASM-001',
        children: [
          { title: '前面板', key: 'PRT-101', isLeaf: true },
          { title: '侧板', key: 'PRT-102', isLeaf: true },
          { title: '机架', key: 'PRT-103', isLeaf: true },
          { title: '装配螺丝包', key: 'AUX-001', isLeaf: true, type: '辅料' }, 
        ],
      },
      {
        title: '主板模组',
        key: 'ASM-002',
        children: [
          { title: 'PCB主板', key: 'PRT-201', isLeaf: true },
          { title: 'CPU插槽', key: 'PRT-202', isLeaf: true },
          { title: '导热硅脂', key: 'AUX-002', isLeaf: true, type: '辅料' },
        ],
      },
    ],
  },
];

const defaultExpandedKeys = treeData.map(n => n.key);

const columns: ColumnType[] = [
  { title: '物料编码', dataIndex: 'key', key: 'key' },
  { title: '物料名称', dataIndex: 'title', key: 'title' },
  { title: '类型', dataIndex: 'type', key: 'type' },
  { title: '基本用量', dataIndex: 'qty', key: 'qty' },
  { title: '损耗率', dataIndex: 'loss', key: 'loss' },
  { title: '发料方式', dataIndex: 'issueMethod', key: 'issueMethod' },
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
    type: child.type || '标准件',
    qty: 1,
    loss: '0.5%',
    issueMethod: '领料'
  }));
});

const onSelect: TreeProps['onSelect'] = (keys, _info) => {
  if (keys.length > 0) {
    selectedKeys.value = keys;
  }
};
</script>

<style scoped>
.mbom-container {
  padding: 10px;
  flex: 1;
  overflow: hidden;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
}
.mbom-container :deep(.split-layout) {
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
