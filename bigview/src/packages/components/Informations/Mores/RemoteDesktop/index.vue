<template>
  <div :style="getStyle(borderRadius)">
    <iframe :src="option.dataset" :width="w" :height="h" style="border-width: 0"></iframe>
  </div>
</template>

<script setup lang="ts">
import { PropType, shallowReactive, watch, toRefs } from 'vue'
import { useChartDataFetch } from '@/hooks'
import { CreateComponentType } from '@/packages/index.d'
import { useChartEditStore } from '@/store/modules/chartEditStore/chartEditStore'

const props = defineProps({
  chartConfig: {
    type: Object as PropType<CreateComponentType>,
    required: true
  }
})

const { w, h } = toRefs(props.chartConfig.attr)
const { borderRadius } = toRefs(props.chartConfig.option)

const option = shallowReactive({
  dataset: ''
})

const getStyle = (radius: number) => {
  return {
    borderRadius: `${radius}px`,
    overflow: 'hidden'
  }
}

// 编辑更新
watch(
  () => props.chartConfig.option,
  (newData) => {
    // console.log('newData', newData)
    // option = newData
    console.log(newData)
    option.dataset = newData.baseUrl + '?username=' + newData.username + '&width=' + newData.width + '&height=' + newData.height + '&random=0.12455583381808921'
  },
  {
    immediate: true,
    deep: true
  }
)

// 预览更新
useChartDataFetch(props.chartConfig, useChartEditStore, (newData: string) => {
  console.log('newData', newData)
  option.dataset = newData
})
</script>
