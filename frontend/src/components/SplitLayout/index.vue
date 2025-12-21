<template>
  <div class="split-layout">
    <div class="split-pane-left" :style="{ width: leftWidth + 'px' }">
      <slot name="left"></slot>
    </div>
    <div 
      class="split-trigger" 
      :class="{ 'is-dragging': isDragging }"
      @mousedown="onMouseDown"
    >
      <div class="split-trigger-line"></div>
    </div>
    <div class="split-pane-right">
      <slot name="right"></slot>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onUnmounted } from 'vue';

const props = defineProps({
  initialLeftWidth: {
    type: Number,
    default: 280
  },
  minLeftWidth: {
    type: Number,
    default: 200
  },
  maxLeftWidth: {
    type: Number,
    default: 500
  }
});

const leftWidth = ref(props.initialLeftWidth);
const isDragging = ref(false);
let startX = 0;
let startWidth = 0;

const onMouseDown = (e: MouseEvent) => {
  isDragging.value = true;
  startX = e.clientX;
  startWidth = leftWidth.value;
  
  document.addEventListener('mousemove', onMouseMove);
  document.addEventListener('mouseup', onMouseUp);
  document.body.style.cursor = 'col-resize';
  document.body.style.userSelect = 'none';
};

const onMouseMove = (e: MouseEvent) => {
  if (!isDragging.value) return;
  
  const dx = e.clientX - startX;
  let newWidth = startWidth + dx;
  
  if (newWidth < props.minLeftWidth) newWidth = props.minLeftWidth;
  if (newWidth > props.maxLeftWidth) newWidth = props.maxLeftWidth;
  
  leftWidth.value = newWidth;
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

.split-pane-left {
  flex-shrink: 0;
  height: 100%;
  overflow: hidden;
  transition: width 0.1s ease-out; /* Smooth transition unless dragging */
}

/* Disable transition during drag for performance */
.split-trigger.is-dragging + .split-pane-right,
.split-trigger.is-dragging ~ .split-pane-left {
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

.split-pane-right {
  flex: 1;
  height: 100%;
  overflow: hidden; /* Scroll should be handled by children if needed */
  min-width: 0; /* Prevent flex overflow */
}
</style>
