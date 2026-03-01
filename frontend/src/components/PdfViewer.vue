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
            {{ getViewModeLabel(viewMode) }} <DownOutlined />
          </a-button>
          <template #overlay>
            <a-menu>
              <a-menu-item key="single" @click="setViewMode('single')">
                单页视图
              </a-menu-item>
              <a-menu-item key="continuous" @click="setViewMode('continuous')">
                单页连续
              </a-menu-item>
              <a-menu-item key="double" @click="setViewMode('double')">
                双页视图
              </a-menu-item>
              <a-menu-item key="double-continuous" @click="setViewMode('double-continuous')">
                双页连续
              </a-menu-item>
              <a-menu-item key="multi-continuous" @click="setViewMode('multi-continuous')">
                多页视图
              </a-menu-item>
            </a-menu>
          </template>
        </a-dropdown>
        <a-divider type="vertical" />
        <a-dropdown :trigger="['click']">
          <a-button size="small">
            <RotateRightOutlined /> {{ rotateOptions.find(opt => opt.value === rotation)?.label || `${rotation}°` }} <DownOutlined />
          </a-button>
          <template #overlay>
            <a-menu>
              <a-menu-item v-for="option in rotateOptions" :key="option.value" @click="rotatePage(option.value)">
                {{ option.label }}
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
           <div class="pages-wrapper" :class="{ 
             'single-page-mode': viewMode === 'single',
             'double-page-mode': viewMode === 'double',
             'double-continuous-mode': viewMode === 'double-continuous',
             'multi-continuous-mode': viewMode === 'multi-continuous'
           }">
             <template v-if="viewMode.includes('continuous')">
               <PdfPage
                 v-for="page in totalPages"
                 :key="page"
                 :pageNumber="page"
                 :pdfDoc="pdfDoc"
                 :scale="scale"
                 :rotation="rotation"
                 @update:visible="onPageVisible"
               />
             </template>
             <template v-else>
               <template v-if="viewMode === 'single'">
                 <PdfPage
                   v-if="currentPage > 0"
                   :key="currentPage"
                   :pageNumber="currentPage"
                   :pdfDoc="pdfDoc"
                   :scale="scale"
                   :rotation="rotation"
                   @loaded="onSinglePageLoaded"
                 />
               </template>
               <template v-else-if="viewMode === 'double'">
                 <!-- Display two pages side by side -->
                 <div class="double-page-container">
                   <PdfPage
                     v-if="currentPage > 0"
                     :key="currentPage"
                     :pageNumber="currentPage"
                     :pdfDoc="pdfDoc"
                     :scale="scale"
                     :rotation="rotation"
                     @loaded="onSinglePageLoaded"
                   />
                   <PdfPage
                     v-if="currentPage + 1 <= totalPages"
                     :key="currentPage + 1"
                     :pageNumber="currentPage + 1"
                     :pdfDoc="pdfDoc"
                     :scale="scale"
                     :rotation="rotation"
                   />
                 </div>
               </template>
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
  DownOutlined,
  RotateRightOutlined
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
const rotation = ref(0);
const loading = ref(false);
const containerRef = ref<HTMLDivElement | null>(null);
const isFitWidth = ref(false);
type ViewMode = 'single' | 'continuous' | 'double' | 'double-continuous' | 'multi-continuous';
const viewMode = ref<ViewMode>('continuous');

const zoomOptions = [
  { label: '50%', value: 0.5 },
  { label: '75%', value: 0.75 },
  { label: '100%', value: 1.0 },
  { label: '125%', value: 1.25 },
  { label: '150%', value: 1.5 },
  { label: '200%', value: 2.0 },
  { label: '适应页宽', value: 'fit-width' }
];

const rotateOptions = [
  { label: '不旋转', value: 0 },
  { label: '顺时针旋转90°', value: 90 },
  { label: '旋转180°', value: 180 },
  { label: '逆时针旋转90°', value: 270 }
];

// Sidebar state
const showSidebar = ref(true);
const activeTab = ref('thumbnails');
const outline = ref<any[]>([]);

let pdfDoc: any = null;
let resizeObserver: ResizeObserver | null = null;

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

const setViewMode = (mode: ViewMode) => {
  if (viewMode.value === mode) return;
  
  viewMode.value = mode;
  
  // If switching to any continuous mode, ensure we scroll to current page
  if (mode.includes('continuous')) {
    nextTick(() => {
      scrollToPage(currentPage.value);
    });
  }
  
  // Re-calculate fit width if enabled
  if (isFitWidth.value) {
    nextTick(() => {
      toggleFitWidth();
    });
  }
};

const getViewModeLabel = (mode: ViewMode) => {
  const map: Record<ViewMode, string> = {
    'single': '单页视图',
    'continuous': '多页连续',
    'double': '双页视图',
    'double-continuous': '双页连续',
    'multi-continuous': '多页视图'
  };
  return map[mode];
};

const rotatePage = (deg: number) => {
  rotation.value = deg;
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
      // Use props.rotation if provided, otherwise default to 0
      const currentRotation = (page.rotate + (rotation.value || 0)) % 360;
      const viewport = page.getViewport({ 
        scale: 1.0,
        rotation: currentRotation
      });
      const containerWidth = containerRef.value.clientWidth - 48; // Subtract padding
      
      let targetWidth = containerWidth;
      
      // If in double page mode (double or double-continuous), we need to fit two pages
      if (viewMode.value === 'double' || viewMode.value === 'double-continuous') {
        // Subtract gap between pages (20px) and divide by 2
        targetWidth = (containerWidth - 20) / 2;
      }
      // Note: multi-continuous mode logic is tricky because it flows. 
      // Standard fit-width usually means "fit one page width to container" for reflowable,
      // or we could treat it same as single page fit width (pages become huge and stack vertically).
      // For now, let's keep multi-continuous same as standard continuous (fit one page).
      
      scale.value = targetWidth / viewport.width;
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
  
  // Ensure page is within valid range
  let targetPage = page;
  
  if (viewMode.value === 'double') {
    // In double mode, ensure we land on the first page of the pair if needed
    // Usually odd pages are on left (1-2, 3-4) or right? 
    // Standard PDF reader: 1 (cover), 2-3, 4-5.
    // Simplified logic: 1-2, 3-4.
    // If user requests page 2, we show 1-2.
    // So normalize to odd number: 
    if (targetPage % 2 === 0) targetPage -= 1;
  }

  if (viewMode.value.includes('continuous')) {
    const pageElement = containerRef.value?.querySelector(`[data-page-number="${targetPage}"]`);
    if (pageElement) {
      pageElement.scrollIntoView({ behavior: 'auto' });
      currentPage.value = targetPage;
    }
  } else {
    currentPage.value = targetPage;
  }
};

const onPageVisible = ({ pageNumber, isIntersecting }: { pageNumber: number, isIntersecting: boolean }) => {
  if (viewMode.value.includes('continuous') && isIntersecting) {
    currentPage.value = pageNumber;
  }
};

const prevPage = () => {
  if (currentPage.value <= 1) return;
  const step = viewMode.value === 'double' ? 2 : 1;
  scrollToPage(currentPage.value - step);
};

const nextPage = () => {
  if (currentPage.value >= totalPages.value) return;
  const step = viewMode.value === 'double' ? 2 : 1;
  scrollToPage(currentPage.value + step);
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
  
  // Observe container resize to auto-fit width
  if (containerRef.value) {
    resizeObserver = new ResizeObserver(() => {
      if (isFitWidth.value) {
        // Use requestAnimationFrame to avoid "ResizeObserver loop limit exceeded" error
        requestAnimationFrame(() => {
          toggleFitWidth();
        });
      }
    });
    resizeObserver.observe(containerRef.value);
  }
});

onUnmounted(() => {
  if (resizeObserver) {
    resizeObserver.disconnect();
  }
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
  position: relative;
  background-color: #f0f2f5;
}

:deep(.ant-spin-nested-loading) {
  width: 100%;
  min-height: 100%;
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

:deep(.ant-spin-nested-loading), :deep(.ant-spin-container) {
  min-height: 100%;
}

.pages-wrapper {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20px;
  padding: 20px 20px 40px 20px;
}

.pages-wrapper.single-page-mode {
  /* Center single page vertically if needed */
  justify-content: center;
  min-height: 100%;
}

.pages-wrapper.double-page-mode {
  justify-content: center;
  min-height: 100%;
}

.double-page-container {
  display: flex;
  flex-direction: row;
  justify-content: center;
  gap: 20px;
}

.pages-wrapper.double-continuous-mode {
  display: grid;
  grid-template-columns: repeat(2, min-content);
  justify-content: center;
  gap: 20px;
}

.pages-wrapper.multi-continuous-mode {
  flex-direction: row;
  flex-wrap: wrap;
  justify-content: center;
  align-content: flex-start;
}

/* Ensure pages in double continuous mode don't stretch too wide */
/* We might need a wrapper around PdfPage for margins if not using gap */
</style>