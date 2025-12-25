<template>
  <el-tooltip
    effect="dark"
    :content="title"
    placement="top"
  >
    <svg :width="w" :height="h" @mouseenter="onMouseEnter" @mouseleave="onMouseLeave" style="overflow:visible;" :class="classv">
      <!-- <defs>
        <filter id="blurFilter" x="-20%" y="-20%" width="140%" height="140%">
          <feGaussianBlur in="SourceGraphic" stdDeviation="1" />
        </filter>
      </defs> -->
      <!--  filter="url(#blurFilter)" -->
      <circle :cx="w / 2 " :cy="h / 2" :r="outCircle" :fill="color"/>
      <!-- 文字 -->
      <text :x="w/2" :y="h/2-outCircle-3" text-anchor="middle" :font-size="hover ? fontSize * 1.2 : fontSize" :font-weight="hover?'bold':'normal'" :fill="fontColor == '#00000000' ? color : fontColor">{{ option.value }}</text>
    </svg>
  </el-tooltip>
</template>

<script setup lang="ts">
import { PropType, toRefs, shallowReactive, watch, ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { CreateComponentType } from '@/packages/index.d'
import { useChartDataFetch } from '@/hooks'
import { useChartEditStore } from '@/store/modules/chartEditStore/chartEditStore'

const option = shallowReactive({
  value: 0,
  maxValue: 30,
  minValue: 25,
  maxValueColor: '#ff0000ff',
  midValueColor: '#ffff00ff',
  minValueColor: '#00ff00ff',
})
const props = defineProps({
  chartConfig: {
    type: Object as PropType<CreateComponentType>,
    required: true,
  },
})

const color = computed(() => {
  const maxValue = props.chartConfig.option.maxValue
  const minValue = props.chartConfig.option.minValue
  const midValue = (minValue + maxValue) / 2
  const value = props.chartConfig.option.value
  const maxValueColor = props.chartConfig.option.maxValueColor
  const midValueColor = props.chartConfig.option.midValueColor
  const minValueColor = props.chartConfig.option.minValueColor
  console.log(minValue, midValue, maxValue, value, 'xxx')
  // 边界检查
  if (value >= maxValue) return maxValueColor
  if (value <= minValue) return minValueColor
  
  let ratio
  let startColor, endColor
  
  if (value <= midValue) {
    // 在最小值和中间值之间插值
    ratio = (value - minValue) / (midValue - minValue)
    startColor = minValueColor
    endColor = midValueColor
  } else {
    // 在中间值和最大值之间插值
    ratio = (value - midValue) / (maxValue - midValue)
    startColor = midValueColor
    endColor = maxValueColor
  }
  
  // 提取颜色分量
  const startR = parseInt(startColor.substring(1, 3), 16)
  const startG = parseInt(startColor.substring(3, 5), 16)
  const startB = parseInt(startColor.substring(5, 7), 16)
  
  const endR = parseInt(endColor.substring(1, 3), 16)
  const endG = parseInt(endColor.substring(3, 5), 16)
  const endB = parseInt(endColor.substring(5, 7), 16)
  
  // 线性插值计算
  const r = Math.round(startR + (endR - startR) * ratio)
  const g = Math.round(startG + (endG - startG) * ratio)
  const b = Math.round(startB + (endB - startB) * ratio)
  
  const colorVal = `#${r.toString(16).padStart(2, '0').toUpperCase()}${g.toString(16).padStart(2, '0').toUpperCase()}${b.toString(16).padStart(2, '0').toUpperCase()}FF`
  
  return colorVal
})

const title = computed(() => {
  let str = props.chartConfig.chartConfig.title
  if (props.chartConfig.option.channel && props.chartConfig.option.channel !== str) {
    str += "("+props.chartConfig.option.channel+")"
  }
  if (props.chartConfig.option.value !== undefined && props.chartConfig.option.value !== null && props.chartConfig.option.value !== '') {
    str += "：" + props.chartConfig.option.value
  }
  return str
})

const classv = computed(() => {
  return props.chartConfig.option.classv
})

const hover = ref(false)
const onMouseEnter = ()=>{
  hover.value = true
  const channel = props.chartConfig.option.channel || props.chartConfig.chartConfig.title
  window.postMessage({
    type: "enterChannel",
    data: channel
  })
}
const onMouseLeave = ()=>{
  hover.value = false
  const channel = props.chartConfig.option.channel || props.chartConfig.chartConfig.title
  window.postMessage({
    type: "leaveChannel",
    data: channel
  })
}

function onWindowMessage(e: MessageEvent) {
    const channel = props.chartConfig.option.channel || props.chartConfig.chartConfig.title
    if (e.data.type === "leaveChannel" && e.data.data === channel) {
      hover.value = false
    }
    if (e.data.type === "enterChannel" && e.data.data === channel) {
      hover.value = true
    }
}

onMounted(()=>{
  window.addEventListener("message", onWindowMessage)
})

onBeforeUnmount(()=>{
  window.removeEventListener("message", onWindowMessage)
})


// 监听所有选项的变化
watch(
  () => props.chartConfig.option,
  (newOption) => {
    Object.assign(option, newOption)
  },
  {
    immediate: true,
    deep: true
  }
)

useChartDataFetch(props.chartConfig, useChartEditStore, (newData: any) => {
  option.value = newData
})

const { w, h } = toRefs(props.chartConfig.attr)
const { outCircle, fontSize, fontColor } = toRefs(props.chartConfig.option)

</script>

