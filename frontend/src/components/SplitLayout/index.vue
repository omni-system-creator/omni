<template>
  <div class="split-layout" :class="{ 'is-right': position === 'right' }">
    <!-- Left Mode: Sidebar (Fixed) -> Trigger -> Main (Adaptive) -->
    <template v-if="position === 'left'">
      <div class="split-pane-sidebar" :style="{ width: sidebarWidth + 'px' }">
        <slot name="sidebar"></slot>
        <!-- Backward compatibility for 'left' slot if sidebar not provided -->
        <slot v-if="!$slots.sidebar" name="left"></slot>
      </div>
      <div 
        class="split-trigger" 
        :class="{ 'is-dragging': isDragging }"
        @mousedown="onMouseDown"
      >
        <div class="split-trigger-line"></div>
      </div>
      <div class="split-pane-main">
        <slot name="main"></slot>
        <!-- Backward compatibility for 'right' slot if main not provided -->
        <slot v-if="!$slots.main" name="right"></slot>
      </div>
    </template>

    <!-- Right Mode: Main (Adaptive) -> Trigger -> Sidebar (Fixed) -->
    <template v-else>
      <div class="split-pane-main">
        <slot name="main"></slot>
        <slot v-if="!$slots.main" name="left"></slot>
      </div>
      <div 
        class="split-trigger" 
        :class="{ 'is-dragging': isDragging }"
        @mousedown="onMouseDown"
      >
        <div class="split-trigger-line"></div>
      </div>
      <div class="split-pane-sidebar" :style="{ width: sidebarWidth + 'px' }">
        <slot name="sidebar"></slot>
        <slot v-if="!$slots.sidebar" name="right"></slot>
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
import { ref, onUnmounted } from 'vue';

const props = defineProps({
  initialWidth: {
    type: Number,
    default: 280
  },
  minWidth: {
    type: Number,
    default: 200
  },
  maxWidth: {
    type: Number,
    default: 500
  },
  position: {
    type: String,
    default: 'left', // 'left' or 'right'
    validator: (val: string) => ['left', 'right'].includes(val)
  },
  // Legacy props support
  initialLeftWidth: { type: Number, default: undefined },
  minLeftWidth: { type: Number, default: undefined },
  maxLeftWidth: { type: Number, default: undefined }
});

// Normalize props
const initW = props.initialLeftWidth !== undefined ? props.initialLeftWidth : props.initialWidth;
const minW = props.minLeftWidth !== undefined ? props.minLeftWidth : props.minWidth;
const maxW = props.maxLeftWidth !== undefined ? props.maxLeftWidth : props.maxWidth;

const sidebarWidth = ref(initW);
const isDragging = ref(false);
let startX = 0;
let startWidth = 0;

const onMouseDown = (e: MouseEvent) => {
  isDragging.value = true;
  startX = e.clientX;
  startWidth = sidebarWidth.value;
  
  document.addEventListener('mousemove', onMouseMove);
  document.addEventListener('mouseup', onMouseUp);
  document.body.style.cursor = 'col-resize';
  document.body.style.userSelect = 'none';
};

const onMouseMove = (e: MouseEvent) => {
  if (!isDragging.value) return;
  
  const dx = e.clientX - startX;
  // If position is left, dragging right increases width.
  // If position is right, dragging right decreases width (because sidebar is on right).
  const delta = props.position === 'left' ? dx : -dx;
  
  let newWidth = startWidth + delta;
  
  if (newWidth < minW) newWidth = minW;
  if (newWidth > maxW) newWidth = maxW;
  
  sidebarWidth.value = newWidth;
};

const onMouseUp = () => {
  isDragging.value = false;
  document.removeEventListener('mousemove', onMouseMove);
  document.removeEventListener('mouseup', onMouseUp);
  document.body.style.cursor = '';
  document.body.style.userSelect = '';
};

onUnmounted(() => {
  document.removeEventListener('mousemove', onMouseMove);
  document.removeEventListener('mouseup', onMouseUp);
});
</script>

<style scoped>
.split-layout {
  display: flex;
  width: 100%;
  height: 100%;
  overflow: hidden;
}

.split-pane-sidebar {
  flex-shrink: 0;
  height: 100%;
  overflow: hidden;
  transition: width 0.1s ease-out;
}

.split-pane-main {
  flex: 1;
  height: 100%;
  overflow: hidden;
  min-width: 0;
}

/* Disable transition during drag */
.split-trigger.is-dragging + .split-pane-main,
.split-trigger.is-dragging + .split-pane-sidebar,
.split-trigger.is-dragging ~ .split-pane-sidebar,
.split-trigger.is-dragging ~ .split-pane-main {
  transition: none;
}

.split-trigger {
  width: 10px;
  cursor: col-resize;
  background-color: #f0f2f5;
  display: flex;
  justify-content: center;
  align-items: center;
  flex-shrink: 0;
  position: relative;
  z-index: 10;
}

.split-trigger:hover,
.split-trigger.is-dragging {
  background-color: #e6f7ff;
}

.split-trigger-line {
  width: 2px;
  height: 20px;
  background-color: #d9d9d9;
}

.split-trigger:hover .split-trigger-line,
.split-trigger.is-dragging .split-trigger-line {
  background-color: #1890ff;
}
</style>
