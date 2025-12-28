<template>
  <div 
    class="renderer-node"
    :class="{ 
      'selected': selectedId === node.id,
      'is-root': isRoot,
      'is-container': isContainer,
      'preview-mode': preview
    }"
    :data-node-id="node.id"
    :draggable="!isRoot && !preview"
    @click.stop="onSelect"
    @dragstart.stop="onDragStart"
    @dragover.stop.prevent="onDragOver"
    @drop.stop="onDrop"
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
import { computed } from 'vue';
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
  // Simple heuristic: if it has children array, it's a container
  // Or check specific types like Div, Row, Col, Card, Layout
  return ['div', 'p', 'span', 'ARow', 'ACol', 'ACard', 'ASpace', 'AForm', 'AFormItem'].includes(props.node.type) || Array.isArray(props.node.children);
});

const resolvedComponent = computed(() => {
  const comp = resolveComponent(props.node.type);
  if (typeof comp === 'string') return comp;
  return comp;
});

const mergedProps = computed(() => {
  // In edit mode, we might want to disable some interactions or add dummy props
  return { ...props.node.props };
});

const onSelect = () => {
  emit('select', props.node.id);
};

const onDragStart = (e: DragEvent) => {
  if (props.preview || props.isRoot) {
    e.preventDefault();
    return;
  }
  e.dataTransfer?.setData('nodeId', props.node.id);
  // Optional: Set effectAllowed
  if (e.dataTransfer) {
    e.dataTransfer.effectAllowed = 'move';
  }
};

const onDragOver = (e: DragEvent) => {
  // Visual feedback could be added here
  e.dataTransfer!.dropEffect = 'copy';
};

const onDrop = (e: DragEvent) => {
  const type = e.dataTransfer?.getData('type');
  if (type) {
    emit('node-drop', { targetId: props.node.id, type });
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
</style>
