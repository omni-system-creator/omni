<template>
  <div class="go-tables-basic">
    <!-- 使用 Ant Design Vue 的 Input 组件
    <a-input
      v-model:value="inputData"
      placeholder="请输入信息"
      :style="`display: ${inputShow}`"
      style="margin-bottom: 5px; float: right; width: 240px"
    >
      <template #prefix>
        <SearchOutlined />
      </template>
    </a-input> -->

    <!-- 使用 Ant Design Vue 的 Table 组件 -->
    <a-table
      ref="tableRef"
      :style="`
        width: ${w}px;
        height: ${h}px;
        font-size: ${option.style.fontSize}px;
        border-width: ${option.style.border === 'on' ? option.style.borderWidth : 0}px;
        border-color: ${option.style.borderColor};
        border-style: ${option.style.borderStyle}
      `"
      :bordered="option.style.border === 'on'"
      :row-key="record => record.key"
      :columns="option.dataset.dimensions"
      :data-source="filterData"
      :pagination="false"
      :scroll="{ x: 'max-content', y: h }"
      class="auto-scroll-table carousel-table"
      @mouseenter="handleMouseEnter"
      @mouseleave="handleMouseLeave"
      @scroll="handleTableScroll"
    />
  </div>
</template>

<script setup lang="ts">
import { computed, PropType, toRefs, watch, reactive, ref, onMounted, onUnmounted } from 'vue'
import { CreateComponentType } from '@/packages/index.d'
import { SearchOutlined } from '@ant-design/icons-vue'

const props = defineProps({
  chartConfig: {
    type: Object as PropType<CreateComponentType>,
    required: true
  }
})

const { chartConfig } = toRefs(props)

// 查询字段
const inputData = ref('')

// 前台过滤
const filterData = computed(() => {
  return chartConfig.value.option.dataset.source.filter((item: any) => {
    return Object.values(item).some(val => {
      return String(val).toLowerCase().includes(inputData.value.toLowerCase())
    })
  })
})

const { align, pagination, inputShow } = toRefs(chartConfig.value.option)

pagination.value.onChange = (page: number) => {
  pagination.value.page = page
}

const { w, h } = toRefs(chartConfig.value.attr)

const option = reactive({
  dataset: chartConfig.value.option.dataset,
  style: chartConfig.value.option.style
})

watch(
  () => chartConfig.value.option.dataset,
  (newData: any) => {
    option.dataset = newData
    option.dataset.dimensions.forEach((header: any) => {
      header.align = align.value
    })
  },
  {
    immediate: true,
    deep: true
  }
)

const tableRef = ref(null)
let intervalId: any = null

const startCarousel = () => {
  const tableBody = tableRef.value.$el.querySelector('.ant-table-body')
  let scrollLeft = 0
  // 计算滚动条的实际长度
  const scrollbarWidth = tableBody.scrollWidth - tableBody.clientWidth
  intervalId = setInterval(() => {
    if (scrollLeft >= scrollbarWidth) {
      scrollLeft = 0
    }
    tableBody.scrollLeft = scrollLeft
    scrollLeft += 0.5 // 调整滚动速度
  }, 50) // 调整间隔时间
}

const stopCarousel = () => {
  if (intervalId) {
    clearInterval(intervalId)
    intervalId = null
  }
}

const handleTableScroll = () => {
  console.log('Table scrolled');
  stopCarousel()
}

const handleMouseEnter = () => {
  console.log('Mouse entered');
  stopCarousel()
}

const handleMouseLeave = () => {
  startCarousel()
}

onMounted(() => {
  startCarousel()
})

onUnmounted(() => {
  stopCarousel()
})
</script>

<style lang="scss" scoped>
$theme-dark: (
  background-color: #b82525,
  text-color: #ffffff,
  border-color: #333333,
  scrollbar-track-background: #333333,
  scrollbar-thumb-background: #555555,
  scrollbar-thumb-hover-background: #777777,
  ant-table-color: #ffffff,
  ant-table-thead-color: #ffffff,
  ant-table-thead-background: #2c2c2c
);

:root {
  --background-color: map.get($theme-dark, background-color);
  --text-color: map.get($theme-dark, text-color);
  --border-color: map.get($theme-dark, border-color);
  --scrollbar-track-background: map.get($theme-dark, scrollbar-track-background);
  --scrollbar-thumb-background: map.get($theme-dark, scrollbar-thumb-background);
  --scrollbar-thumb-hover-background: map.get($theme-dark, scrollbar-thumb-hover-background);
  --ant-table-color: map.get($theme-dark, ant-table-color);
  --ant-table-thead-color: map.get($theme-dark, ant-table-thead-color);
  --ant-table-thead-background: map.get($theme-dark, ant-table-thead-background);
}

@include go('tables-basic') {
  display: flex;
  flex-direction: column;
  gap: 15px;
  align-items: flex-end;
}

.carousel-table {
  overflow-x: auto;
  white-space: nowrap;
  background-color: var(--background-color);
  color: var(--text-color);
}

.carousel-table .ant-table-body {
  display: inline-block;
  vertical-align: top;
  margin: 0;
  padding: 0;
  border: none;
}

/* 自定义滚动条样式 */
:deep(.carousel-table::-webkit-scrollbar) {
  width: 20px; /* 滚动条宽度 */
}

.carousel-table::-webkit-scrollbar-track {
  background: var(--scrollbar-track-background); /* 滚动条轨道背景色 */
}

.carousel-table::-webkit-scrollbar-thumb {
  background: var(--scrollbar-thumb-background); /* 滚动条滑块背景色 */
  border-radius: 4px; /* 滑块边角圆滑度 */
}

.carousel-table::-webkit-scrollbar-thumb:hover {
  background: var(--scrollbar-thumb-hover-background); /* 滑块悬停时的背景色 */
}

.carousel-table {
  -ms-overflow-style: none;  /* IE 和 Edge */
  scrollbar-width: none;  /* Firefox */
}

/* 隐藏分页相关的样式 */
.go-tables-basic .carousel-table .ant-pagination {
  display: none !important;
}

:deep(.ant-table) {
  color: var(--ant-table-color);
  background-color: var(--background-color) !important;
}

:deep(.ant-table-thead) {
  color: var(--ant-table-thead-color);
  background-color: var(--ant-table-thead-background) !important;
}
@include go('tables-basic') {
  display: flex;
  flex-direction: column;
  gap: 15px;
  align-items: flex-end;
}

.carousel-table {

  // background-color: black; /* 设置表格背景颜色为黑色 */
  color: white; /* 设置表格字体颜色为白色 */
}
</style>