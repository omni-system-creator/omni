<template>
  <div class="pdf-page" ref="pageRef" :data-page-number="pageNumber">
    <div class="page-container" ref="containerRef">
      <div class="page-number-indicator">{{ pageNumber }} / {{ pdfDoc.numPages }}</div>
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
  rotation?: number;
}>();

const emit = defineEmits(['loaded', 'update:visible']);

const loading = ref(true);
const rendered = ref(false);
const pageRef = ref<HTMLDivElement | null>(null);
const containerRef = ref<HTMLDivElement | null>(null);
const canvasRef = ref<HTMLCanvasElement | null>(null);
const textLayerRef = ref<HTMLDivElement | null>(null);
const viewport = ref<any>(null);

let renderTask: any = null;
let observer: IntersectionObserver | null = null;

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
    // Use props.rotation if provided, otherwise default to 0
    const currentRotation = (page.rotate + (props.rotation || 0)) % 360;
    const scaledViewport = page.getViewport({ 
      scale: props.scale,
      rotation: currentRotation
    });
    viewport.value = scaledViewport;
    
    const canvas = canvasRef.value;
    const context = canvas.getContext('2d');

    if (!context) return;

    // Fix high DPI screens blurriness
    const outputScale = window.devicePixelRatio || 1;
    
    // When rotated 90 or 270 degrees, the viewport dimensions are already swapped by getViewport
    // But we need to ensure the canvas dimensions match
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
      
      // Check if we need to swap width/height for text layer based on rotation
      // Although getViewport swaps dimensions, sometimes text layer container needs explicit handling
      // especially when combined with our CSS scaling correction
      const isRotated = currentRotation % 180 !== 0;
      
      // For TextLayer, we use the viewport dimensions directly
      // But we need to account for our CSS correction factor
      const correction = 0.76;
      
      if (isRotated) {
        textLayerRef.value.style.width = `${scaledViewport.height / correction}px`;
        textLayerRef.value.style.height = `${scaledViewport.width / correction}px`;
      } else {
        textLayerRef.value.style.width = `${scaledViewport.width / correction}px`;
        textLayerRef.value.style.height = `${scaledViewport.height / correction}px`;
      }
      
      textLayerRef.value.style.setProperty('--scale-factor', `${correction}`);
      
      const textContent = await page.getTextContent();
      
      if (TextLayer) {
        try {
          const textLayer = new TextLayer({
            textContentSource: textContent,
            container: textLayerRef.value,
            viewport: scaledViewport
          });
          await textLayer.render();

          // textLayer在这里判断旋转是90度或者270度交换textLayer的宽高
          if (isRotated) {
            // Force reflow to ensure styles are applied
            // Using getComputedStyle to get the actual rendered dimensions if style is not set or relative
            const style = window.getComputedStyle(textLayerRef.value);
            const currentWidth = style.width;
            const currentHeight = style.height;
            
            // Apply swapped dimensions
            textLayerRef.value.style.width = currentHeight;
            textLayerRef.value.style.height = currentWidth;
          }
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

watch(() => [props.scale, props.rotation], () => {
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

onMounted(() => {
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
  top: 10px;
  left: 10px;
  background-color: rgba(0, 0, 0, 0.6);
  color: white;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  pointer-events: none;
  z-index: 10;
  transition: all 0.3s ease;
}
</style>