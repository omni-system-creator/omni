<template>
  <div class="dwg-preview-container">
    <div class="toolbar">
      <div class="toolbar-left" style="display: flex; gap: 16px; align-items: center;">
        <a-radio-group v-model:value="viewMode" button-style="solid">
          <a-radio-button value="pdf">PDF 预览</a-radio-button>
          <a-radio-button value="svg">SVG 预览</a-radio-button>
        </a-radio-group>
        <div v-if="viewMode === 'pdf'" style="display: flex; align-items: center; gap: 8px;">
          <span>纸张大小:</span>
          <a-select v-model:value="paperSize" style="width: 120px" @change="refreshPdf">
            <a-select-option value="A0">A0</a-select-option>
            <a-select-option value="A1">A1</a-select-option>
            <a-select-option value="A2">A2</a-select-option>
            <a-select-option value="A3">A3 (默认)</a-select-option>
            <a-select-option value="A4">A4</a-select-option>
            <a-select-option value="A5">A5</a-select-option>
            <a-select-option value="A6">A6</a-select-option>
            <a-select-option value="B0">B0</a-select-option>
            <a-select-option value="B1">B1</a-select-option>
            <a-select-option value="B2">B2</a-select-option>
            <a-select-option value="B3">B3</a-select-option>
            <a-select-option value="B4">B4</a-select-option>
            <a-select-option value="B5">B5</a-select-option>
            <a-select-option value="B6">B6</a-select-option>
          </a-select>
          <span>方向:</span>
          <a-select v-model:value="orientation" style="width: 100px" @change="refreshPdf">
            <a-select-option value="portrait">纵向</a-select-option>
            <a-select-option value="landscape">横向</a-select-option>
          </a-select>
        </div>
      </div>
      <div class="controls" v-if="viewMode === 'svg'">
        <a-button size="small" @click="resetView">重置</a-button>
        <a-button size="small" @click="zoomIn">放大</a-button>
        <a-button size="small" @click="zoomOut">缩小</a-button>
      </div>
    </div>

    <div class="content-area">
      <!-- PDF View -->
      <div v-if="viewMode === 'pdf'" class="pdf-container">
        <div v-if="pdfLoading" class="loading-state">
          <a-spin tip="正在生成 PDF 预览..." />
        </div>
        <iframe
          v-if="pdfUrl"
          v-show="!pdfLoading"
          :src="pdfUrl"
          class="pdf-iframe"
          frameborder="0"
          @load="onPdfLoaded"
        />
      </div>

      <!-- SVG View -->
      <div v-else class="svg-container" ref="viewerContainer">
        <div class="svg-wrapper" ref="svgWrapper" 
             @mousedown="startPan" 
             @mousemove="pan" 
             @mouseup="endPan" 
             @mouseleave="endPan"
             @wheel="zoom">
          <object v-if="svgUrl" ref="svgObject" :data="svgUrl" type="image/svg+xml" class="svg-content" :style="svgContentStyle"></object>
          <div v-else class="loading-state">
              <a-spin tip="正在生成 SVG 预览..." />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed, watch } from 'vue';
import { useRoute } from 'vue-router';

const route = useRoute();
const docId = ref('');
const viewMode = ref('pdf'); // Default to PDF
const paperSize = ref('A3');
const orientation = ref<'portrait' | 'landscape'>('portrait');
const pdfRefreshTrigger = ref(0);
const pdfLoading = ref(true);

// URLs
const pdfUrl = computed(() => {
  if (!docId.value) return '';
  return `/api/pdm/preview/dwg/${docId.value}/pdf?paperSize=${paperSize.value}&orientation=${orientation.value}&t=${pdfRefreshTrigger.value}`;
});
const svgUrl = computed(() => docId.value ? `/api/pdm/preview/dwg/${docId.value}/svg` : '');

const refreshPdf = () => {
  pdfLoading.value = true;
  pdfRefreshTrigger.value++;
};

const onPdfLoaded = () => {
  pdfLoading.value = false;
};

// SVG Interaction State
const svgWrapper = ref<HTMLDivElement | null>(null);
const isPanning = ref(false);
const lastMouseX = ref(0);
const lastMouseY = ref(0);
const scale = ref(1);
const translateX = ref(0);
const translateY = ref(0);

const svgContentStyle = computed(() => ({
  transform: `translate(${translateX.value}px, ${translateY.value}px) scale(${scale.value})`,
  transformOrigin: '0 0',
  width: '100%',
  height: '100%'
}));

onMounted(() => {
  docId.value = route.params.id as string || '';
  pdfLoading.value = true;
});

watch(viewMode, value => {
  if (value === 'pdf') {
    pdfLoading.value = true;
    pdfRefreshTrigger.value++;
  }
});

// SVG Logic
const startPan = (e: MouseEvent) => {
  if (e.button !== 0) return; 
  isPanning.value = true;
  lastMouseX.value = e.clientX;
  lastMouseY.value = e.clientY;
  if (svgWrapper.value) svgWrapper.value.style.cursor = 'grabbing';
};

const pan = (e: MouseEvent) => {
  if (!isPanning.value) return;
  const deltaX = e.clientX - lastMouseX.value;
  const deltaY = e.clientY - lastMouseY.value;
  translateX.value += deltaX;
  translateY.value += deltaY;
  lastMouseX.value = e.clientX;
  lastMouseY.value = e.clientY;
};

const endPan = () => {
  isPanning.value = false;
  if (svgWrapper.value) svgWrapper.value.style.cursor = 'grab';
};

const zoom = (e: WheelEvent) => {
  e.preventDefault();
  if (!svgWrapper.value) return;

  const rect = svgWrapper.value.getBoundingClientRect();
  const mouseX = e.clientX - rect.left;
  const mouseY = e.clientY - rect.top;

  // Calculate mouse position relative to content (unscaled)
  // mouseX = translateX + contentX * scale
  // contentX = (mouseX - translateX) / scale
  const contentX = (mouseX - translateX.value) / scale.value;
  const contentY = (mouseY - translateY.value) / scale.value;

  const zoomFactor = e.deltaY > 0 ? 0.9 : 1.1;
  const newScale = scale.value * zoomFactor;

  // Constrain scale if needed (e.g., 0.1 to 10)
  if (newScale < 0.1 || newScale > 20) return;

  // Calculate new translate to keep contentX at mouseX
  // mouseX = newTranslateX + contentX * newScale
  // newTranslateX = mouseX - contentX * newScale
  translateX.value = mouseX - contentX * newScale;
  translateY.value = mouseY - contentY * newScale;
  
  scale.value = newScale;
};

const zoomIn = () => { scale.value *= 1.2; };
const zoomOut = () => { scale.value *= 0.8; };
const resetView = () => {
  scale.value = 1;
  translateX.value = 0;
  translateY.value = 0;
};
</script>

<style scoped>
.dwg-preview-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  overflow: hidden;
  background-color: #f0f0f0;
}

.toolbar {
  padding: 10px 20px;
  background-color: #fff;
  border-bottom: 1px solid #e8e8e8;
  display: flex;
  align-items: center;
  justify-content: space-between;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
  z-index: 10;
}

.controls {
  display: flex;
  gap: 8px;
}

.content-area {
  flex: 1;
  overflow: hidden;
  position: relative;
  background-color: #525659; /* Standard PDF viewer background color */
}

/* PDF Styles */
.pdf-container {
  width: 100%;
  height: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
}

.pdf-iframe {
  width: 100%;
  height: 100%;
  border: none;
  background-color: #fff;
}

/* SVG Styles */
.svg-container {
  width: 100%;
  height: 100%;
  background-color: #fff;
  overflow: hidden;
  display: flex;
  justify-content: center;
  align-items: center;
}

.svg-wrapper {
  width: 100%;
  height: 100%;
  cursor: grab;
  position: relative;
  overflow: hidden;
}

.svg-content {
  position: absolute;
  left: 0;
  top: 0;
  pointer-events: none;
}

.loading-state {
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100%;
    width: 100%;
    color: #fff;
}
</style>
