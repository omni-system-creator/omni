<template>
  <div class="pdf-page" ref="pageRef" :data-page-number="pageNumber">
    <div class="page-container" ref="containerRef">
      <div class="page-number-indicator" :class="{ 'inside': isInside }">{{ pageNumber }} / {{ pdfDoc.numPages }}</div>
      <a-spin :spinning="loading">
        <div class="canvas-wrapper" :style="wrapperStyle">
          <canvas ref="canvasRef"></canvas>
          <div ref="textLayerRef" class="textLayer"></div>
        </div>
      </a-spin>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch, computed, onUnmounted } from 'vue';
import * as pdfjsLib from 'pdfjs-dist';

// Destructure TextLayer from the default export or the module itself
// @ts-ignore
const TextLayer = pdfjsLib.TextLayer || (pdfjsLib.default && pdfjsLib.default.TextLayer);

const props = defineProps<{
  pageNumber: number;
  pdfDoc: any;
  scale: number;
}>();

const emit = defineEmits(['loaded', 'update:visible']);

const loading = ref(true);
const rendered = ref(false);
const pageRef = ref<HTMLDivElement | null>(null);
const containerRef = ref<HTMLDivElement | null>(null);
const canvasRef = ref<HTMLCanvasElement | null>(null);
const textLayerRef = ref<HTMLDivElement | null>(null);
const viewport = ref<any>(null);
const isInside = ref(false);

let renderTask: any = null;
let observer: IntersectionObserver | null = null;
let resizeObserver: ResizeObserver | null = null;

const wrapperStyle = computed(() => {
  if (!viewport.value) {
    // If viewport is not ready, try to estimate dimensions based on the first page or defaults
    // This helps avoid layout shifts or 0 height containers
    return {
      minHeight: '200px',
      minWidth: '200px'
    };
  }
  return {
    width: `${viewport.value.width}px`,
    height: `${viewport.value.height}px`,
  };
});

const renderPage = async () => {
  if (!props.pdfDoc || !canvasRef.value || rendered.value) return;
  
  loading.value = true;
  
  try {
    const page = await props.pdfDoc.getPage(props.pageNumber);
    const scaledViewport = page.getViewport({ scale: props.scale });
    viewport.value = scaledViewport;
    
    const canvas = canvasRef.value;
    const context = canvas.getContext('2d');

    if (!context) return;

    // Fix high DPI screens blurriness
    const outputScale = window.devicePixelRatio || 1;
    
    canvas.height = Math.floor(scaledViewport.height * outputScale);
    canvas.width = Math.floor(scaledViewport.width * outputScale);
    
    // Set CSS dimensions
    canvas.style.width = `${scaledViewport.width}px`;
    canvas.style.height = `${scaledViewport.height}px`;

    const transform = outputScale !== 1 
      ? [outputScale, 0, 0, outputScale, 0, 0] 
      : null;

    const renderContext = {
      canvasContext: context,
      transform: transform,
      viewport: scaledViewport,
    };
    
    renderTask = page.render(renderContext);
    await renderTask.promise;
    renderTask = null;

    // Render text layer
    if (textLayerRef.value) {
      textLayerRef.value.innerHTML = '';
      textLayerRef.value.style.height = `${scaledViewport.height}px`;
      textLayerRef.value.style.width = `${scaledViewport.width}px`;
      // Use CSS property for scaling
      // Correction factor adjusted based on visual alignment
      textLayerRef.value.style.setProperty('--scale-factor', `${props.scale * 0.76}`);
      
      // Clear any existing transforms that might affect scaling or positioning
      textLayerRef.value.style.transform = '';
      textLayerRef.value.style.transformOrigin = '';
      
      const textContent = await page.getTextContent();
      
      if (TextLayer) {
        try {
          const textLayer = new TextLayer({
            textContentSource: textContent,
            container: textLayerRef.value,
            viewport: scaledViewport
          });
          await textLayer.render();
        } catch (e) {
          console.warn('Text layer rendering failed:', e);
        }
      }
    }
    
    rendered.value = true;
    emit('loaded', { pageNumber: props.pageNumber, width: scaledViewport.width, height: scaledViewport.height });
  } catch (error: any) {
    if (error.name !== 'RenderingCancelledException') {
      console.error(`Error rendering page ${props.pageNumber}:`, error);
    }
  } finally {
    loading.value = false;
  }
};

const resetRender = () => {
  rendered.value = false;
  loading.value = true;
  if (renderTask) {
    renderTask.cancel();
    renderTask = null;
  }
};

watch(() => props.scale, () => {
  resetRender();
  // If visible, re-render immediately
  if (pageRef.value && isElementInViewport(pageRef.value)) {
    renderPage();
  }
});

watch(() => props.pdfDoc, () => {
  resetRender();
  // Wait for new doc to settle? Usually parent handles this.
});

// Check if element is in viewport (simple check)
const isElementInViewport = (el: HTMLElement) => {
  const rect = el.getBoundingClientRect();
  return (
    rect.top < (window.innerHeight || document.documentElement.clientHeight) &&
    rect.bottom > 0
  );
};

const checkPosition = () => {
  if (!containerRef.value || !pageRef.value) return;
  
  const containerRect = containerRef.value.getBoundingClientRect();
  const pageRect = pageRef.value.getBoundingClientRect();
  const parentRect = pageRef.value.parentElement?.getBoundingClientRect();
  
  if (!parentRect) return;
  
  // Calculate available space on the left
  const spaceLeft = containerRect.left - parentRect.left;
  
  // If space on left is less than 70px (indicator width + margin), move inside
  isInside.value = spaceLeft < 70;
};

onMounted(() => {
  // Initial check
  checkPosition();
  
  // Watch for resize to adjust position
  resizeObserver = new ResizeObserver(() => {
    checkPosition();
  });
  
  if (pageRef.value) {
    resizeObserver.observe(pageRef.value);
    // Also observe parent to detect container changes
    if (pageRef.value.parentElement) {
      resizeObserver.observe(pageRef.value.parentElement);
    }
  }

  observer = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        renderPage();
        emit('update:visible', { pageNumber: props.pageNumber, isIntersecting: true });
      } else {
        emit('update:visible', { pageNumber: props.pageNumber, isIntersecting: false });
      }
    });
  }, {
    root: null, // viewport
    rootMargin: '200px', // Pre-render margin
    threshold: 0.1
  });

  if (pageRef.value) {
    observer.observe(pageRef.value);
  }
});

onUnmounted(() => {
  if (resizeObserver) {
    resizeObserver.disconnect();
  }
  if (observer) {
    observer.disconnect();
  }
  if (renderTask) {
    renderTask.cancel();
  }
});
</script>

<style scoped>
.pdf-page {
  margin-bottom: 24px;
  display: flex;
  justify-content: center;
  position: relative;
}

.canvas-wrapper {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  background-color: #fff;
  line-height: 0;
  position: relative;
}

/* Ensure text layer is positioned correctly over canvas */
.textLayer {
  position: absolute;
  left: 0;
  top: 0;
  right: 0;
  bottom: 0;
  overflow: hidden;
  opacity: 0.2;
  line-height: 1.0;
  transform-origin: 0 0;
  letter-spacing: normal;
  word-spacing: normal;
}

/* Ensure text spans inside TextLayer are positioned absolutely and scaled correctly */
:deep(.textLayer span) {
  color: transparent;
  position: absolute;
  white-space: pre;
  cursor: text;
  transform-origin: 0% 0%;
  transform: scale(var(--scale-factor));
}

.page-container {
  position: relative;
}

.page-number-indicator {
  position: absolute;
  top: 0;
  left: -60px; /* Position to the left of the page */
  background-color: rgba(0, 0, 0, 0.6);
  color: white;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  pointer-events: none;
  z-index: 10;
  transition: all 0.3s ease;
}

.page-number-indicator.inside {
  left: 10px;
  top: 10px;
}
</style>