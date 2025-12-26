<template>
  <Teleport to="body">
    <div v-if="visible" class="draggable-modal-mask" @click="handleMaskClick"></div>
    <div v-if="visible" class="draggable-modal-overlay" :class="{ maximized: isMaximized }" :style="!isMaximized ? { top: modalState.y + 'px', left: modalState.x + 'px', width: modalState.width + 'px', height: modalState.height + 'px' } : {}">
      <div class="draggable-modal-header" @mousedown="startDrag">
        <div class="modal-title">{{ title }}</div>
        <div class="modal-actions">
          <div class="modal-header-btn" @click="toggleMaximize">
            <CompressOutlined v-if="isMaximized" />
            <ExpandOutlined v-else />
          </div>
          <div class="modal-header-btn close" @click="close">
            <CloseOutlined />
          </div>
        </div>
      </div>
      <div class="draggable-modal-body" :style="{ padding: bodyPadding }">
        <slot></slot>
      </div>
      <div v-if="$slots.footer" class="draggable-modal-footer">
        <slot name="footer"></slot>
      </div>
      <div v-if="!isMaximized" class="draggable-modal-resize-handle" @mousedown="startResize"></div>
    </div>
  </Teleport>
</template>

<script setup lang="ts">
import { ref, watch, onUnmounted } from 'vue';
import { ExpandOutlined, CompressOutlined, CloseOutlined } from '@ant-design/icons-vue';

const props = defineProps({
  visible: {
    type: Boolean,
    default: false
  },
  title: {
    type: String,
    default: 'Modal'
  },
  width: {
    type: [Number, String],
    default: 800
  },
  height: {
    type: [Number, String],
    default: 600
  },
  maskClosable: {
    type: Boolean,
    default: false
  },
  bodyPadding: {
    type: String,
    default: '10px'
  }
});

const emit = defineEmits(['update:visible', 'close', 'cancel', 'ok']);

const isMaximized = ref(false);
const modalState = ref({
  x: 100,
  y: 100,
  width: 800,
  height: 600
});

watch(() => props.visible, (newVal) => {
  if (newVal) {
    // Initialize size and position
    const viewportWidth = window.innerWidth;
    const viewportHeight = window.innerHeight;
    
    // Parse width/height if they are percentages or numbers
    let targetWidth = 800;
    let targetHeight = 600;

    // Handle percentage strings like "80%"
    if (typeof props.width === 'string' && props.width.endsWith('%')) {
      targetWidth = viewportWidth * (parseFloat(props.width) / 100);
    } else {
      targetWidth = Number(props.width);
    }

    if (typeof props.height === 'string' && props.height.endsWith('%')) {
      targetHeight = viewportHeight * (parseFloat(props.height) / 100);
    } else {
      targetHeight = Number(props.height);
    }

    modalState.value.width = targetWidth;
    modalState.value.height = targetHeight;
    modalState.value.x = (viewportWidth - targetWidth) / 2;
    modalState.value.y = (viewportHeight - targetHeight) / 2;
  }
});

const handleMaskClick = () => {
  if (props.maskClosable) {
    close();
  }
};

const close = () => {
  emit('update:visible', false);
  emit('close');
  emit('cancel');
};

const toggleMaximize = () => {
  isMaximized.value = !isMaximized.value;
};

// Drag Logic
const isDragging = ref(false);
const dragOffset = ref({ x: 0, y: 0 });

const startDrag = (e: MouseEvent) => {
  if (isMaximized.value) return;
  // Only trigger if clicking the header itself, not buttons
  if ((e.target as HTMLElement).closest('.modal-header-btn')) return;
  
  isDragging.value = true;
  dragOffset.value = {
    x: e.clientX - modalState.value.x,
    y: e.clientY - modalState.value.y
  };
  document.addEventListener('mousemove', onDrag);
  document.addEventListener('mouseup', stopDrag);
};

const onDrag = (e: MouseEvent) => {
  if (!isDragging.value) return;
  modalState.value.x = e.clientX - dragOffset.value.x;
  modalState.value.y = e.clientY - dragOffset.value.y;
};

const stopDrag = () => {
  isDragging.value = false;
  document.removeEventListener('mousemove', onDrag);
  document.removeEventListener('mouseup', stopDrag);
};

// Resize Logic
const isResizing = ref(false);
const resizeStart = ref({ x: 0, y: 0, width: 0, height: 0 });

const startResize = (e: MouseEvent) => {
  if (isMaximized.value) return;
  e.stopPropagation();
  isResizing.value = true;
  resizeStart.value = {
    x: e.clientX,
    y: e.clientY,
    width: modalState.value.width,
    height: modalState.value.height
  };
  document.addEventListener('mousemove', onResize);
  document.addEventListener('mouseup', stopResize);
};

const onResize = (e: MouseEvent) => {
  if (!isResizing.value) return;
  const dx = e.clientX - resizeStart.value.x;
  const dy = e.clientY - resizeStart.value.y;
  modalState.value.width = Math.max(400, resizeStart.value.width + dx);
  modalState.value.height = Math.max(300, resizeStart.value.height + dy);
};

const stopResize = () => {
  isResizing.value = false;
  document.removeEventListener('mousemove', onResize);
  document.removeEventListener('mouseup', stopResize);
};

onUnmounted(() => {
  document.removeEventListener('mousemove', onDrag);
  document.removeEventListener('mouseup', stopDrag);
  document.removeEventListener('mousemove', onResize);
  document.removeEventListener('mouseup', stopResize);
});
</script>

<style scoped>
.draggable-modal-mask {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(0,0,0,0.3);
  z-index: 2000;
}

.draggable-modal-overlay {
  position: fixed;
  background: #fff;
  box-shadow: 0 0 20px rgba(0,0,0,0.2);
  border-radius: 4px;
  z-index: 2001;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  border: 1px solid #d9d9d9;
}

.draggable-modal-overlay.maximized {
  top: 0 !important;
  left: 0 !important;
  width: 100vw !important;
  height: 100vh !important;
  border-radius: 0;
}

.draggable-modal-header {
  height: 40px;
  background: #f0f0f0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 16px;
  cursor: move;
  border-bottom: 1px solid #d9d9d9;
  user-select: none;
  flex-shrink: 0;
}

.modal-title {
  font-weight: bold;
}

.modal-actions {
  display: flex;
  gap: 10px;
}

.modal-header-btn {
  cursor: pointer;
  padding: 4px;
  border-radius: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal-header-btn:hover {
  background: #d9d9d9;
}

.modal-header-btn.close:hover {
  background: #ff4d4f;
  color: #fff;
}

.draggable-modal-body {
  flex: 1;
  background: #fff;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.draggable-modal-footer {
  padding: 10px 16px;
  border-top: 1px solid #e8e8e8;
  text-align: right;
  background: #fff;
  flex-shrink: 0;
}

.draggable-modal-resize-handle {
  position: absolute;
  bottom: 0;
  right: 0;
  width: 15px;
  height: 15px;
  cursor: se-resize;
  background: linear-gradient(135deg, transparent 50%, #ccc 50%);
  z-index: 10;
}
</style>