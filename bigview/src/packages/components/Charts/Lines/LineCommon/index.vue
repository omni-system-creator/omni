<template>
  <v-chart
    ref="vChartRef"
    :init-options="initOptions"
    :theme="themeColor"
    :option="option"
    :update-options="{
      replaceMerge: replaceMergeArr
    }"
    autoresize
  >
  </v-chart>
<!--  {{option}}{{replaceMergeArr}}-->
</template>

<script setup lang="ts">
import { PropType, computed, watch, ref, nextTick } from 'vue'
import VChart from 'vue-echarts'
import { useCanvasInitOptions } from '@/hooks/useCanvasInitOptions.hook'
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { LineChart } from 'echarts/charts'
import { mergeTheme } from '@/packages/public/chart'
import { useChartEditStore } from '@/store/modules/chartEditStore/chartEditStore'
import { useChartDataFetch } from '@/hooks'
import { isPreview } from '@/utils'
import { DatasetComponent, GridComponent, TooltipComponent, LegendComponent } from 'echarts/components'
import isObject from 'lodash/isObject'
import { json } from 'stream/consumers'
import { CreateComponentType } from '@/packages/index.d'

const includes = ['legend', 'xAxis', 'yAxis', 'grid']
const seriesItem = {
  type: 'line',
  label: {
    show: true,
    position: 'top',
    color: '#fff',
    fontSize: 12
  },
  symbolSize: 5, //设定实心点的大小
  itemStyle: {
    color: null,
    borderRadius: 0
  },
  lineStyle: {
    type: 'solid',
    width: 3,
    color: null
  }
}

const props = defineProps({
  themeSetting: {
    type: Object,
    required: true
  },
  themeColor: {
    type: Object,
    required: true
  },
  chartConfig: {
    type: Object as PropType<CreateComponentType>,
    required: true
  }
})

const initOptions = useCanvasInitOptions(props.chartConfig.option, props.themeSetting)

use([DatasetComponent, CanvasRenderer, LineChart, GridComponent, TooltipComponent, LegendComponent])

const replaceMergeArr = ref<string[]>()

const option = computed(() => {
  const a = mergeTheme(props.chartConfig.option, props.themeSetting, includes).series.map((series: any)  =>({
    ...series,
    smooth: true, // 添加平滑处理
  }))
  const b =mergeTheme(props.chartConfig.option, props.themeSetting, includes)
  b.series= a
  const X =b.dataset.dimensions[0]
  const seen = new Set();
  const uniqueItems: any[] = [];
  b.dataset.source.forEach((item: any) => {
    if (!seen.has(item[X])) {
    seen.add(item[X]);
    uniqueItems.push(item);
  }
  })
  // 对 uniqueItems 按照 x 轴数据进行排序
  uniqueItems.sort((item1: any, item2: any) => {
    // 假设 x 轴数据是数值类型，如果是字符串类型请使用合适的比较方法
    return item1[X] - item2[X];
  });
  
  b.dataset.source = uniqueItems;
  
  return b 
})

// dataset 无法变更条数的补丁
watch(
  () => props.chartConfig.option.dataset,
  (newData: { dimensions: any }, oldData) => {
    try {
      if (!isObject(newData) || !('dimensions' in newData)) return
      if (Array.isArray(newData?.dimensions)) {
        const seriesArr = []
        for (let i = 0; i < newData.dimensions.length - 1; i++) {
          seriesArr.push(seriesItem)
          console.log(seriesItem,'折线图')
        }
        replaceMergeArr.value = ['series']
        props.chartConfig.option.series = seriesArr
        console.log(props.chartConfig.option,'折线图SEEEEEE')
        nextTick(() => {
          replaceMergeArr.value = []
        })
      }
    } catch (error) {
      console.log(error)
    }
  },
  {
    deep: false
  }
)

const { vChartRef } = useChartDataFetch(props.chartConfig, useChartEditStore, (newData: any) => {
  props.chartConfig.option.dataset = newData
})
</script>
