<template>
   <collapse-item v-if="series" name="系列">
    <setting-item-box v-for="(seriesItem, index) in series" :key="index" :name="`系列 ${index + 1}`">
      <setting-item name="名称">
        <n-input v-model:value="seriesItem.name" size="small"></n-input>
      </setting-item> 
      <!-- <setting-item name="绑定容器">
          <n-select v-model:value="seriesItem.gridIndex" size="small" :options="gridsListOption"></n-select>
        </setting-item> -->
      <!-- <setting-item name="绑定X轴">
        <n-select v-model:value="seriesItem.xAxisIndex" size="small" :options="gridList"></n-select>
      </setting-item> -->
      <setting-item name="绑定Y轴">
        <n-select v-model:value="seriesItem.yAxisIndex" size="small" :options="yAxisList.filter(item => item.gridIndex == seriesItem.gridIndex)"></n-select>
      </setting-item>
      <!-- 可以在这里添加更多 series 相关的设置项 -->
    </setting-item-box>
  </collapse-item>
</template>

<script setup lang="ts">
import { PropType, computed, watch } from 'vue'
import { CollapseItem, SettingItemBox, SettingItem, GlobalSettingPosition } from '@/components/Pages/ChartItemSetting'


const props = defineProps({
  optionData: {
    type: Object ,
    required: true
  },
  inChart: {
    type: Boolean,
    required: false,
    default: false
  }
}) 

const yAxisList = computed(() => {
  const arr: any[] = []
   props.optionData.yAxis.forEach((item:any, i: number) => {
    const obj = {
      label: item.name,
      value: i,
      gridIndex: item.gridIndex
    }
    arr.push(obj)
  }); 
  return arr
})
const gridList = computed(() => {
  const arr: any[] = []
   props.optionData.grid.forEach((item:any, i: number) => {
    const obj = {
      label: item.name,
      value: i,
    }
    arr.push(obj)
  }); 
  return arr
})
 
const series = computed(() => {
  return props.optionData.series
})
// watch()


</script>
