<template>
  <div class="pdf-thumbnail" :class="{ active: active }" @click="$emit('click')">
    <div class="thumbnail-canvas-wrapper" ref="wrapperRef">
      <canvas ref="canvasRef"></canvas>
    </div>
    <div class="page-number">{{ pageNumber }}</div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue';

const props = defineProps<{
  pageNumber: number;
  pdfDoc: any;
  scale: number;
  active: boolean;
}>();

const emit = defineEmits(['click']);

const canvasRef = ref<HTMLCanvasElement | null>(null);
const wrapperRef = ref<HTMLDivElement | null>(null);
const rendered = ref(false);

const renderThumbnail = async () => {
  if (!props.pdfDoc || !canvasRef.value || rendered.value) return;

  try {
    const page = await props.pdfDoc.getPage(props.pageNumber);
    const viewport = page.getViewport({ scale: props.scale });
    const canvas = canvasRef.value;
    const context = canvas.getContext('2d');

    if (!context) return;

    canvas.height = viewport.height;
    canvas.width = viewport.width;

    const renderContext = {
      canvasContext: context,
      viewport: viewport,
    };

    await page.render(renderContext).promise;
    rendered.value = true;
  } catch (error) {
    console.error(`Error rendering thumbnail for page ${props.pageNumber}:`, error);
  }
};

// Intersection Observer to lazy load thumbnails
onMounted(() => {
  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        renderThumbnail();
        observer.disconnect();
      }
    });
  });

  if (wrapperRef.value) {
    observer.observe(wrapperRef.value);
  }
});

watch(() => props.pdfDoc, () => {
  rendered.value = false;
  // Re-observe if needed, but usually pdfDoc changes means component re-mount or list refresh
});
</script>

<style scoped>
.pdf-thumbnail {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 16px;
  cursor: pointer;
  padding: 8px;
  border-radius: 4px;
  transition: background-color 0.2s;
}

.pdf-thumbnail:hover {
  background-color: rgba(0, 0, 0, 0.05);
}

.pdf-thumbnail.active {
  background-color: rgba(24, 144, 255, 0.1);
}

.thumbnail-canvas-wrapper {
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  background-color: #fff;
  line-height: 0;
  border: 1px solid #f0f0f0;
  min-height: 100px; /* Placeholder height */
  min-width: 80px;  /* Placeholder width */
  transition: all 0.2s;
}

.pdf-thumbnail.active .thumbnail-canvas-wrapper {
  border-color: #1890ff;
  box-shadow: 0 0 0 2px rgba(24, 144, 255, 0.2);
}

.page-number {
  margin-top: 4px;
  font-size: 12px;
  color: #666;
}

canvas {
  max-width: 100%;
  height: auto;
  display: block;
}
</style>