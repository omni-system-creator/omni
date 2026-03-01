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
        <a-dropdown :trigger="['click']">
          <a-button size="small">
            {{ isFitWidth ? '适应页宽' : `${Math.round(scale * 100)}%` }} <DownOutlined />
          </a-button>
          <template #overlay>
            <a-menu>
              <a-menu-item v-for="option in zoomOptions" :key="option.value" @click="handleZoomChange(option.value)">
                {{ option.label }}
              </a-menu-item>
            </a-menu>
          </template>
        </a-dropdown>
        <a-button @click="zoomIn" :disabled="scale >= 3.0 || loading" size="small">
          <PlusOutlined />
        </a-button>
        <a-divider type="vertical" />
        <a-dropdown :trigger="['click']">
          <a-button size="small">
            {{ isContinuous ? '连续滚动' : '单页视图' }} <DownOutlined />
          </a-button>
          <template #overlay>
            <a-menu>
              <a-menu-item key="continuous" @click="setContinuous(true)">
                连续滚动
              </a-menu-item>
              <a-menu-item key="single" @click="setContinuous(false)">
                单页视图
              </a-menu-item>
            </a-menu>
          </template>
        </a-dropdown>
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
                @click="scrollToPage(page)"
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
      
      <div class="pdf-container" ref="containerRef" @wheel="onWheel">
         <a-spin :spinning="loading">
           <div class="pages-wrapper" :class="{ 'single-page-mode': !isContinuous }">
             <template v-if="isContinuous">
               <PdfPage
                 v-for="page in totalPages"
                 :key="page"
                 :pageNumber="page"
                 :pdfDoc="pdfDoc"
                 :scale="scale"
                 @update:visible="onPageVisible"
               />
             </template>
             <template v-else>
               <PdfPage
                 v-if="currentPage > 0"
                 :key="currentPage"
                 :pageNumber="currentPage"
                 :pdfDoc="pdfDoc"
                 :scale="scale"
                 @loaded="onSinglePageLoaded"
               />
             </template>
           </div>
         </a-spin>
       </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch, onUnmounted, nextTick } from 'vue';
import { 
  LeftOutlined, 
  RightOutlined, 
  MinusOutlined, 
  PlusOutlined,
  MenuFoldOutlined,
  MenuUnfoldOutlined,
  ExpandOutlined,
  CompressOutlined,
  DownOutlined
} from '@ant-design/icons-vue';
import { Empty } from 'ant-design-vue';
import { GlobalWorkerOptions, getDocument } from 'pdfjs-dist';
// @ts-ignore
import * as pdfjsLib from 'pdfjs-dist';
import 'pdfjs-dist/web/pdf_viewer.css'; // Import PDF.js viewer CSS for text layer

import PdfThumbnail from './PdfThumbnail.vue';
import PdfPage from './PdfPage.vue';

// Set worker source to static file in public directory
GlobalWorkerOptions.workerSrc = '/static/pdf.worker.min.js';

const props = defineProps<{
  url: string;
}>();

const currentPage = ref(1);
const totalPages = ref(0);
const scale = ref(1.0);
const loading = ref(false);
const containerRef = ref<HTMLDivElement | null>(null);
const isFitWidth = ref(false);
const isContinuous = ref(true);

const zoomOptions = [
  { label: '50%', value: 0.5 },
  { label: '75%', value: 0.75 },
  { label: '100%', value: 1.0 },
  { label: '125%', value: 1.25 },
  { label: '150%', value: 1.5 },
  { label: '200%', value: 2.0 },
  { label: '适应页宽', value: 'fit-width' }
];

// Sidebar state
const showSidebar = ref(true);
const activeTab = ref('thumbnails');
const outline = ref<any[]>([]);

let pdfDoc: any = null;

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
      scrollToPage(pageIndex + 1);
    }
  } catch (error) {
    console.error('Error navigating to outline destination:', error);
  }
};

const setContinuous = (value: boolean) => {
  if (isContinuous.value === value) return;
  
  isContinuous.value = value;
  // If switching to continuous mode, ensure we scroll to current page
  if (value) {
    nextTick(() => {
      scrollToPage(currentPage.value);
    });
  }
};

const handleZoomChange = (value: number | string) => {
  if (value === 'fit-width') {
    if (!isFitWidth.value) {
      toggleFitWidth();
    }
  } else {
    isFitWidth.value = false;
    scale.value = Number(value);
  }
};

const toggleFitWidth = async () => {
  // Always enable fit width when toggled from this function context if not already
  if (!isFitWidth.value) isFitWidth.value = true;
  
  if (isFitWidth.value && pdfDoc && containerRef.value) {
    try {
      const page = await pdfDoc.getPage(currentPage.value);
      const viewport = page.getViewport({ scale: 1.0 });
      const containerWidth = containerRef.value.clientWidth - 48; // Subtract padding
      scale.value = containerWidth / viewport.width;
    } catch (error) {
      console.error('Error fitting width:', error);
    }
  } else {
    // Reset to default scale if turning off
    scale.value = 1.0;
  }
};

const onSinglePageLoaded = () => {
  if (isFitWidth.value) {
    // Re-calculate fit width on load if needed
    toggleFitWidth();
    // Toggle back since we just want to recalculate
    isFitWidth.value = true;
  }
};

const scrollToPage = (page: number) => {
  if (page < 1 || page > totalPages.value) return;
  
  if (isContinuous.value) {
    const pageElement = containerRef.value?.querySelector(`[data-page-number="${page}"]`);
    if (pageElement) {
      pageElement.scrollIntoView({ behavior: 'auto' });
      currentPage.value = page;
    }
  } else {
    currentPage.value = page;
  }
};

const onPageVisible = ({ pageNumber, isIntersecting }: { pageNumber: number, isIntersecting: boolean }) => {
  if (isContinuous.value && isIntersecting) {
    currentPage.value = pageNumber;
  }
};

const prevPage = () => {
  if (currentPage.value <= 1) return;
  scrollToPage(currentPage.value - 1);
};

const nextPage = () => {
  if (currentPage.value >= totalPages.value) return;
  scrollToPage(currentPage.value + 1);
};

const zoomIn = () => {
  if (scale.value >= 3.0) return;
  scale.value += 0.1;
  isFitWidth.value = false; // Disable fit width on manual zoom
};

const zoomOut = () => {
  if (scale.value <= 0.5) return;
  scale.value -= 0.1;
  isFitWidth.value = false; // Disable fit width on manual zoom
};

const toggleSidebar = () => {
  showSidebar.value = !showSidebar.value;
};

const onWheel = (e: WheelEvent) => {
  if (e.ctrlKey) {
    e.preventDefault();
    if (e.deltaY < 0) {
      zoomIn();
    } else {
      zoomOut();
    }
  }
};

watch(() => props.url, () => {
  loadPdf();
});

onMounted(() => {
  loadPdf();
});

onUnmounted(() => {
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
  height: 100%;
}

:deep(.ant-tabs) {
  height: 100%;
  display: flex;
  flex-direction: column;
}

:deep(.ant-tabs-content) {
  height: 100%;
  flex: 1;
  display: flex;
  flex-direction: column;
}

:deep(.ant-tabs-tabpane) {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.sidebar-content {
  flex: 1;
  overflow-y: auto;
  padding: 12px;
  height: 0; /* Important for flex child scrolling */
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
  /* Ensure container takes full height */
  height: 100%;
}

:deep(.ant-spin-nested-loading) {
  width: 100%;
  height: 100%;
}

:deep(.ant-spin-container) {
  height: 100%;
  display: flex;
  justify-content: center;
}

.canvas-wrapper {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  background-color: #fff;
  line-height: 0; /* Remove extra space below canvas */
  height: fit-content; /* Ensure wrapper takes content height */
  width: fit-content; /* Ensure wrapper takes content width */
  position: relative; /* For text layer positioning */
}

/* Ensure text layer is positioned correctly over canvas */
.textLayer {
  position: absolute;
  left: 0;
  top: 0;
  right: 0;
  bottom: 0;
  overflow: hidden;
  opacity: 0.2; /* Make text selection visible but subtle */
  line-height: 1.0;
  transform-origin: 0 0; /* Ensure transforms start from top-left */
  letter-spacing: normal;
  word-spacing: normal;
}

/* Ensure text spans inside TextLayer are positioned absolutely */
:deep(.textLayer span) {
  color: transparent;
  position: absolute;
  white-space: pre;
  cursor: text;
  transform-origin: 0% 0%;
}

:deep(.ant-tabs-content) {
  height: 100%;
}
</style>