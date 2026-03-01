<template>
  <div class="pdf-viewer">
    <div class="pdf-controls">
      <a-space>
        <a-button @click="prevPage" :disabled="currentPage <= 1 || loading" size="small">
          <LeftOutlined /> 上一页
        </a-button>
        <span>{{ currentPage }} / {{ totalPages }}</span>
        <a-button @click="nextPage" :disabled="currentPage >= totalPages || loading" size="small">
          下一页 <RightOutlined />
        </a-button>
        <a-divider type="vertical" />
        <a-button @click="zoomOut" :disabled="scale <= 0.5 || loading" size="small">
          <MinusOutlined />
        </a-button>
        <span>{{ Math.round(scale * 100) }}%</span>
        <a-button @click="zoomIn" :disabled="scale >= 3.0 || loading" size="small">
          <PlusOutlined />
        </a-button>
      </a-space>
    </div>
    
    <div class="pdf-container">
      <a-spin :spinning="loading">
        <div class="canvas-wrapper">
          <canvas ref="canvasRef"></canvas>
        </div>
      </a-spin>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch, onUnmounted } from 'vue';
import { 
  LeftOutlined, 
  RightOutlined, 
  MinusOutlined, 
  PlusOutlined 
} from '@ant-design/icons-vue';
import { GlobalWorkerOptions, getDocument } from 'pdfjs-dist';

// Set worker source to static file in public directory
GlobalWorkerOptions.workerSrc = '/static/pdf.worker.min.mjs';

const props = defineProps<{
  url: string;
}>();

const currentPage = ref(1);
const totalPages = ref(0);
const scale = ref(1.0);
const loading = ref(false);
const canvasRef = ref<HTMLCanvasElement | null>(null);

let pdfDoc: any = null;
let renderTask: any = null;

const loadPdf = async () => {
  if (!props.url) return;
  
  loading.value = true;
  try {
    // Reset state
    if (pdfDoc) {
      pdfDoc.destroy();
      pdfDoc = null;
    }
    currentPage.value = 1;
    totalPages.value = 0;
    
    const loadingTask = getDocument(props.url);
    pdfDoc = await loadingTask.promise;
    totalPages.value = pdfDoc.numPages;
    
    await renderPage(currentPage.value);
  } catch (error) {
    console.error('Error loading PDF:', error);
  } finally {
    loading.value = false;
  }
};

const renderPage = async (num: number) => {
  if (!pdfDoc || !canvasRef.value) return;
  
  loading.value = true;
  
  try {
    // Cancel previous render if any
    if (renderTask) {
      await renderTask.cancel();
      renderTask = null;
    }

    const page = await pdfDoc.getPage(num);
    
    const viewport = page.getViewport({ scale: scale.value });
    const canvas = canvasRef.value;
    const context = canvas.getContext('2d');

    if (!context) return;

    canvas.height = viewport.height;
    canvas.width = viewport.width;

    const renderContext = {
      canvasContext: context,
      viewport: viewport,
    };
    
    renderTask = page.render(renderContext);
    await renderTask.promise;
    renderTask = null;
  } catch (error: any) {
    if (error.name !== 'RenderingCancelledException') {
      console.error('Error rendering page:', error);
    }
  } finally {
    loading.value = false;
  }
};

const prevPage = () => {
  if (currentPage.value <= 1) return;
  currentPage.value--;
  renderPage(currentPage.value);
};

const nextPage = () => {
  if (currentPage.value >= totalPages.value) return;
  currentPage.value++;
  renderPage(currentPage.value);
};

const zoomIn = () => {
  if (scale.value >= 3.0) return;
  scale.value += 0.1;
  renderPage(currentPage.value);
};

const zoomOut = () => {
  if (scale.value <= 0.5) return;
  scale.value -= 0.1;
  renderPage(currentPage.value);
};

watch(() => props.url, () => {
  loadPdf();
});

onMounted(() => {
  loadPdf();
});

onUnmounted(() => {
  if (renderTask) {
    renderTask.cancel();
  }
  if (pdfDoc) {
    pdfDoc.destroy();
  }
});
</script>

<style scoped>
.pdf-viewer {
  display: flex;
  flex-direction: column;
  height: 100%;
  background-color: #f0f2f5;
  overflow: hidden;
}

.pdf-controls {
  padding: 8px 16px;
  background-color: #fff;
  border-bottom: 1px solid #d9d9d9;
  display: flex;
  justify-content: center;
  align-items: center;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  z-index: 10;
  flex-shrink: 0;
}

.pdf-container {
  flex: 1;
  overflow: auto;
  display: flex;
  justify-content: center;
  padding: 24px;
}

.canvas-wrapper {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  background-color: #fff;
  line-height: 0; /* Remove extra space below canvas */
  height: fit-content; /* Ensure wrapper takes content height */
  width: fit-content; /* Ensure wrapper takes content width */
}
</style>