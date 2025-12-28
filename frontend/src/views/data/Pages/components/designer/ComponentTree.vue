<template>
  <div class="component-tree">
    <a-tree
      blockNode
      draggable
      :allow-drop="allowDrop"
      :tree-data="treeData"
      :selectedKeys="selectedId ? [selectedId] : []"
      :expandedKeys="expandedKeys"
      @select="onSelect"
      @expand="onExpand"
      @drop="onDrop"
    >
      <template #title="{ dataRef }">
        <span class="tree-node-title">
          <span class="node-type">{{ dataRef.type }}</span>
          <span v-if="dataRef.text || dataRef.props.label" class="node-label">
            ({{ dataRef.text || dataRef.props.label }})
          </span>
        </span>
      </template>
    </a-tree>
  </div>
</template>

<script setup lang="ts">
import { computed, ref, watch } from 'vue';
import { type ComponentNode } from './types';
import type { AntTreeNodeDropEvent } from 'ant-design-vue/es/tree';

const props = defineProps<{
  root: ComponentNode;
  selectedId?: string;
}>();

const emit = defineEmits(['select', 'node-drop']);

const expandedKeys = ref<string[]>([]);

const containerTypes = [
  'div', 'span', 'p',
  'ARow', 'ACol', 'ACard', 'ASpace',
  'AForm', 'AFormItem'
];

const isContainer = (type: string) => containerTypes.includes(type);

// Convert ComponentNode structure to Ant Design Tree Data structure
const transformToTreeData = (node: ComponentNode): any => {
  return {
    key: node.id,
    title: node.type,
    type: node.type,
    text: node.text,
    props: node.props,
    children: node.children ? node.children.map(transformToTreeData) : [],
    dataRef: node,
    isLeaf: !isContainer(node.type) && (!node.children || node.children.length === 0)
  };
};

const treeData = computed(() => {
  return [transformToTreeData(props.root)];
});

const allowDrop = ({ dropNode, dropPosition }: any) => {
  // dropPosition: -1 (before), 0 (inside), 1 (after)
  if (dropPosition === 0) {
    return isContainer(dropNode.dataRef.type);
  }
  return true;
};

const findPath = (node: ComponentNode, targetId: string, path: string[] = []): string[] | null => {
  if (node.id === targetId) {
    return path;
  }
  if (node.children) {
    for (const child of node.children) {
      const result = findPath(child, targetId, [...path, node.id]);
      if (result) return result;
    }
  }
  return null;
};

// Auto expand path to selected node
watch(() => props.selectedId, (newId) => {
  if (newId) {
    const path = findPath(props.root, newId);
    if (path) {
      const newKeys = new Set([...expandedKeys.value, ...path]);
      expandedKeys.value = Array.from(newKeys);
    }
  }
}, { immediate: true });

const onSelect = (selectedKeys: string[]) => {
  if (selectedKeys.length > 0) {
    emit('select', selectedKeys[0]);
  }
};

const onExpand = (keys: string[]) => {
  expandedKeys.value = keys;
};

const onDrop = (info: AntTreeNodeDropEvent) => {
  const dropKey = info.node.key as string;
  const dragKey = info.dragNode.key as string;
  const dropPos = info.node.pos?.split('-');
  const dropPosition = info.dropPosition - Number(dropPos![dropPos!.length - 1]);

  // info.dropToGap: boolean - true if dropped between nodes, false if dropped on node
  // dropPosition: -1 (before), 0 (on/inside), 1 (after)

  let position = 'inside';
  if (info.dropToGap) {
    position = dropPosition === -1 ? 'before' : 'after';
  } else {
    position = 'inside';
  }
  
  // Mapping 'before'/'after' to our internal 'top'/'bottom' or just reuse 'before'/'after'
  // The PageDesigner logic handles 'before'/'after' now (mapped from top/bottom/left/right)
  // Let's pass 'before'/'after' directly as they are supported by handleNodeDrop logic

  emit('node-drop', {
    targetId: dropKey,
    nodeId: dragKey,
    position: position
  });
};
</script>

<style scoped>
.component-tree {
  /* height: 100%;  Let the parent tabpane handle scrolling */
  /* overflow-y: auto; */
  padding: 8px;
}

.component-tree :deep(.ant-tree-node-content-wrapper) {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.tree-node-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.node-type {
  font-weight: 500;
  color: #1890ff;
  flex-shrink: 0;
}

.node-label {
  color: #999;
  overflow: hidden;
  text-overflow: ellipsis;
}
</style>