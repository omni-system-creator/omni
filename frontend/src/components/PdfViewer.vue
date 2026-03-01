<template>
  <div class="pdf-viewer">
    <div class="pdf-controls">
      <a-space>
        <a-button @click="toggleSidebar" size="small">
          <MenuUnfoldOutlined v-if="!showSidebar" />
          <MenuFoldOutlined v-else />
        </a-button>
        <a-divider type="vertical" />
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
    
    <div class="pdf-main">
      <div class="pdf-sidebar" v-if="showSidebar">
        <a-tabs v-model:activeKey="activeTab" size="small" :tabBarStyle="{ margin: 0, padding: '0 8px' }">
          <a-tab-pane key="thumbnails" tab="缩略图">
            <div class="sidebar-content thumbnails-list">
              <PdfThumbnail
                v-for="page in totalPages"
                :key="page"
                :pageNumber="page"
                :pdfDoc="pdfDoc"
                :scale="0.2"
                :active="currentPage === page"
                @click="goToPage(page)"
              />
            </div>
          </a-tab-pane>
          <a-tab-pane key="outline" tab="大纲">
            <div class="sidebar-content outline-tree">
              <a-tree
                v-if="outline.length > 0"
                :treeData="outline"
                :fieldNames="{ title: 'title', key: 'key', children: 'items' }"
                @select="onOutlineSelect"
                blockNode
              />
              <a-empty v-else description="暂无大纲" :image="Empty.PRESENTED_IMAGE_SIMPLE" />
            </div>
          </a-tab-pane>
        </a-tabs>
      </div>
      
      <div class="pdf-container">
        <a-spin :spinning="loading">
          <div class="canvas-wrapper">
            <canvas ref="canvasRef"></canvas>
          </div>
        </a-spin>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch, onUnmounted } from 'vue';
import { 
  LeftOutlined, 
  RightOutlined, 
  MinusOutlined, 
  PlusOutlined,
  MenuFoldOutlined,
  MenuUnfoldOutlined
} from '@ant-design/icons-vue';
import { Empty } from 'ant-design-vue';
import { GlobalWorkerOptions, getDocument } from 'pdfjs-dist';
import PdfThumbnail from './PdfThumbnail.vue';

// Set worker source to static file in public directory
GlobalWorkerOptions.workerSrc = '/static/pdf.worker.min.js';

const props = defineProps<{
  url: string;
}>();

const currentPage = ref(1);
const totalPages = ref(0);
const scale = ref(1.0);
const loading = ref(false);
const canvasRef = ref<HTMLCanvasElement | null>(null);

// Sidebar state
const showSidebar = ref(true);
const activeTab = ref('thumbnails');
const outline = ref<any[]>([]);

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
    outline.value = [];
    
    const loadingTask = getDocument(props.url);
    pdfDoc = await loadingTask.promise;
    totalPages.value = pdfDoc.numPages;
    
    // Load outline
    const rawOutline = await pdfDoc.getOutline();
    if (rawOutline) {
      outline.value = await processOutline(rawOutline);
    }
    
    await renderPage(currentPage.value);
  } catch (error) {
    console.error('Error loading PDF:', error);
  } finally {
    loading.value = false;
  }
};

const processOutline = async (items: any[]): Promise<any[]> => {
  const result = [];
  for (let i = 0; i < items.length; i++) {
    const item = items[i];
    const node: any = {
      title: item.title,
      key: `outline-${i}-${Math.random()}`,
      dest: item.dest
    };
    
    if (item.items && item.items.length > 0) {
      node.items = await processOutline(item.items);
    } else {
      node.isLeaf = true;
    }
    
    result.push(node);
  }
  return result;
};

const onOutlineSelect = async (_selectedKeys: any[], { node }: any) => {
  if (!node.dest) return;
  
  try {
    let dest = node.dest;
    if (typeof dest === 'string') {
      dest = await pdfDoc.getDestination(dest);
    }
    
    if (dest) {
      const pageIndex = await pdfDoc.getPageIndex(dest[0]);
      goToPage(pageIndex + 1);
    }
  } catch (error) {
    console.error('Error navigating to outline destination:', error);
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

const goToPage = (page: number) => {
  if (page < 1 || page > totalPages.value) return;
  currentPage.value = page;
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

const toggleSidebar = () => {
  showSidebar.value = !showSidebar.value;
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
  align-items: center;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  z-index: 10;
  flex-shrink: 0;
}

.pdf-main {
  flex: 1;
  display: flex;
  overflow: hidden;
}

.pdf-sidebar {
  width: 240px;
  background: #fff;
  border-right: 1px solid #e8e8e8;
  display: flex;
  flex-direction: column;
  flex-shrink: 0;
}

.sidebar-content {
  flex: 1;
  overflow-y: auto;
  padding: 12px;
  height: calc(100vh - 150px); /* Approximate height minus headers */
}

.thumbnails-list {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.pdf-container {
  flex: 1;
  overflow: auto;
  display: flex;
  justify-content: center;
  padding: 24px;
  background-color: #f0f2f5;
}

.canvas-wrapper {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  background-color: #fff;
  line-height: 0; /* Remove extra space below canvas */
  height: fit-content; /* Ensure wrapper takes content height */
  width: fit-content; /* Ensure wrapper takes content width */
}

:deep(.ant-tabs-content) {
  height: 100%;
}
</style>