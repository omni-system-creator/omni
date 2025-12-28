<template>
  <div 
    class="renderer-node"
    :class="{ 
      'selected': selectedId === node.id,
      'is-root': isRoot,
      'is-container': isContainer,
      'preview-mode': preview,
      'drag-over-inside': dropPosition === 'inside',
      'drag-over-top': dropPosition === 'top',
      'drag-over-bottom': dropPosition === 'bottom',
      'drag-over-left': dropPosition === 'left',
      'drag-over-right': dropPosition === 'right',
      ...wrapperClasses
    }"
    :style="wrapperStyle"
    :data-node-id="node.id"
    :draggable="!isRoot && !preview"
    @click.stop="onSelect"
    @dragstart.stop="onDragStart"
    @dragover="onDragOver"
    @dragleave="onDragLeave"
    @drop="onDrop"
  >
    <!-- Render the component -->
    <component 
      :is="resolvedComponent"
      v-bind="mergedProps"
      :style="node.style"
    >
      <!-- Text Content if any -->
      <template v-if="node.text">{{ node.text }}</template>

      <!-- Children -->
      <CanvasRenderer 
        v-for="child in node.children" 
        :key="child.id" 
        :node="child"
        :selectedId="selectedId"
        :preview="preview"
        @select="$emit('select', $event)"
        @node-drop="$emit('node-drop', $event)"
      />
    </component>
    
    <!-- Placeholder for empty containers -->
    <div v-if="!preview && isContainer && node.children.length === 0" class="empty-placeholder">
      Drop items here
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue';
import { type ComponentNode } from './types';
import { resolveComponent } from './ComponentRegistry';
// Recursive self-reference
import CanvasRenderer from './CanvasRenderer.vue';

const props = defineProps<{
  node: ComponentNode;
  selectedId?: string;
  isRoot?: boolean;
  preview?: boolean;
}>();

const emit = defineEmits(['select', 'node-drop']);

const isContainer = computed(() => {
  // Only specific types are containers that can accept children via drag-drop
  const containerTypes = [
    'div', 'span', 'p',
    'ARow', 'ACol', 'ACard', 'ASpace',
    'AForm', 'AFormItem',
    'ADescriptions', 'ADescriptionsItem'
  ];
  return containerTypes.includes(props.node.type) || props.isRoot;
});

const wrapperClasses = computed(() => {
  const classes: Record<string, boolean> = {};
  
  // ACol 特殊处理：将 Grid 类应用到 wrapper 上，使其能被 ARow 正确识别布局
  if (props.node.type === 'ACol') {
    classes['ant-col'] = true;
    if (props.node.props.span) classes[`ant-col-${props.node.props.span}`] = true;
    if (props.node.props.offset) classes[`ant-col-offset-${props.node.props.offset}`] = true;
    if (props.node.props.push) classes[`ant-col-push-${props.node.props.push}`] = true;
    if (props.node.props.pull) classes[`ant-col-pull-${props.node.props.pull}`] = true;
    if (props.node.props.order) classes[`ant-col-order-${props.node.props.order}`] = true;
  }
  
  return classes;
});

const wrapperStyle = computed(() => {
  if (props.node.type === 'ADescriptionsItem') {
    return { display: 'contents' };
  }
  return {};
});

const resolvedComponent = computed(() => {
  const comp = resolveComponent(props.node.type);
  if (typeof comp === 'string') return comp;
  return comp;
});

const mergedProps = computed(() => {
  const p = { ...props.node.props };
  
  // ACol 特殊处理：wrapper 承担了 Grid 布局，内部 ACol 应填满 wrapper
  if (props.node.type === 'ACol') {
    p.style = { 
      ...(p.style || {}),
      width: '100%', 
      maxWidth: '100%', 
      flex: '0 0 100%' 
    };
  }
  
  return p;
});

const onSelect = () => {
  emit('select', props.node.id);
};

const isDragOver = ref(false);
const dropPosition = ref<'inside' | 'top' | 'bottom' | 'left' | 'right' | null>(null);

const onDragStart = (e: DragEvent) => {
  if (props.preview || props.isRoot) {
    e.preventDefault();
    return;
  }
  console.log('Drag Start:', props.node.id);
  e.dataTransfer?.setData('nodeId', props.node.id);
  if (e.dataTransfer) {
    e.dataTransfer.effectAllowed = 'move';
  }
};

const onDragOver = (e: DragEvent) => {
  // Always allow dropping on components in edit mode to support insertion
  if (props.preview) return;

  e.preventDefault();
  e.stopPropagation();
  
  if (e.dataTransfer) {
    e.dataTransfer.dropEffect = 'move';
  }
  isDragOver.value = true;
  
  // Calculate potential drop position
  const rect = (e.currentTarget as HTMLElement).getBoundingClientRect();
  const relX = e.clientX - rect.left;
  const relY = e.clientY - rect.top;
  const width = rect.width;
  const height = rect.height;
  
  if (props.isRoot) {
    dropPosition.value = 'inside';
    return;
  }
  
  // Determine closest edge
  const distTop = relY;
  const distBottom = height - relY;
  const distLeft = relX;
  const distRight = width - relX;
  
  const min = Math.min(distTop, distBottom, distLeft, distRight);
  const threshold = Math.min(width, height) * 0.25; // 25% zone

  if (min < threshold) {
    if (min === distTop) dropPosition.value = 'top';
    else if (min === distBottom) dropPosition.value = 'bottom';
    else if (min === distLeft) dropPosition.value = 'left';
    else if (min === distRight) dropPosition.value = 'right';
  } else {
    if (isContainer.value) {
      dropPosition.value = 'inside';
    } else {
      // If not container, force closest edge
      if (min === distTop) dropPosition.value = 'top';
      else if (min === distBottom) dropPosition.value = 'bottom';
      else if (min === distLeft) dropPosition.value = 'left';
      else if (min === distRight) dropPosition.value = 'right';
    }
  }
};

const onDragLeave = (_e: DragEvent) => {
  isDragOver.value = false;
  dropPosition.value = null;
};

const onDrop = (e: DragEvent) => {
  isDragOver.value = false;
  const pos = dropPosition.value || 'inside';
  dropPosition.value = null;
  
  if (props.preview) return;
  
  e.stopPropagation();

  const type = e.dataTransfer?.getData('type');
  const nodeId = e.dataTransfer?.getData('nodeId');
  
  console.log('Drop on:', props.node.id, 'Type:', type, 'NodeID:', nodeId, 'Pos:', pos);

  if (type || nodeId) {
    emit('node-drop', { targetId: props.node.id, type, nodeId, position: pos });
  }
};
</script>

<style scoped>
.renderer-node {
  position: relative;
  /* border: 1px dashed transparent; */
}

.renderer-node:not(.preview-mode).selected {
  outline: 2px solid #1890ff;
  z-index: 1;
}

.renderer-node:not(.preview-mode):hover {
  outline: 1px dashed #1890ff;
}

.renderer-node.drag-over-inside {
  outline: 2px solid #52c41a !important;
  background-color: rgba(82, 196, 26, 0.1);
}

.renderer-node.drag-over-top::before {
  content: '';
  position: absolute;
  top: -2px;
  left: 0;
  right: 0;
  height: 4px;
  background-color: #52c41a;
  z-index: 100;
  pointer-events: none;
}

.renderer-node.drag-over-bottom::after {
  content: '';
  position: absolute;
  bottom: -2px;
  left: 0;
  right: 0;
  height: 4px;
  background-color: #52c41a;
  z-index: 100;
  pointer-events: none;
}

.renderer-node.drag-over-left::before {
  content: '';
  position: absolute;
  top: 0;
  bottom: 0;
  left: -2px;
  width: 4px;
  background-color: #52c41a;
  z-index: 100;
  pointer-events: none;
}

.renderer-node.drag-over-right::after {
  content: '';
  position: absolute;
  top: 0;
  bottom: 0;
  right: -2px;
  width: 4px;
  background-color: #52c41a;
  z-index: 100;
  pointer-events: none;
}

.is-root {
  min-height: 100%;
}

.empty-placeholder {
  padding: 20px;
  background: #f0f0f0;
  border: 1px dashed #ccc;
  text-align: center;
  color: #999;
  font-size: 12px;
  margin: 5px;
}

/* 修复 Label 换行和截断问题，强制在设计器中自适应显示 */
:deep(.ant-form-item-row) {
  flex-wrap: nowrap !important;
}

:deep(.ant-form-item-label) {
  flex: 0 0 auto !important;
  width: auto !important;
  max-width: none !important;
  white-space: nowrap;
  padding-right: 8px;
}

:deep(.ant-form-item-control) {
  flex: 1 1 auto !important;
  width: auto !important;
  max-width: none !important;
  min-width: 0;
}

:deep(.ant-descriptions-item-label) {
  white-space: nowrap;
  width: auto !important;
}
</style>
