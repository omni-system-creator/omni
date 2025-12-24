<template>
  <div class="go-chart-configurations-data" v-if="targetData">
    <!-- 如果支持多数据源 targetData.option.multiDatasource == true ，则显示多数据源配置 -->
    <chart-data-multi-datasource v-if="targetData.option.multiDatasource" />
    <template v-else>
      <setting-item-box name="请求方式" :alone="true">
        <n-select v-model:value="targetData.request.requestDataType" :disabled="isNotData" :options="selectOptions" />
      </setting-item-box>
      <!-- 静态 -->
      <chart-data-static v-if="targetData.request.requestDataType === RequestDataTypeEnum.STATIC" />
      <!-- 动态 -->
      <chart-data-ajax v-if="targetData.request.requestDataType === RequestDataTypeEnum.AJAX" />
      <!-- 数据池 -->
      <chart-data-pond v-if="targetData.request.requestDataType === RequestDataTypeEnum.Pond" />
    </template>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { loadAsyncComponent } from '@/utils'
import { SettingItemBox } from '@/components/Pages/ChartItemSetting'
import { RequestDataTypeEnum } from '@/enums/httpEnum'
import { ChartFrameEnum } from '@/packages/index.d'
import { useTargetData } from '../hooks/useTargetData.hook'
import { SelectCreateDataType, SelectCreateDataEnum } from './index.d'

const ChartDataMultiDatasource = loadAsyncComponent(() => import('./components/ChartDataMultiDatasource/index.vue'))
const ChartDataStatic = loadAsyncComponent(() => import('./components/ChartDataStatic/index.vue'))
const ChartDataAjax = loadAsyncComponent(() => import('./components/ChartDataAjax/index.vue'))
const ChartDataPond = loadAsyncComponent(() => import('./components/ChartDataPond/index.vue'))

const { targetData } = useTargetData()

console.log('targetData', targetData.value)
// 选项
const selectOptions: SelectCreateDataType[] = [
  {
    label: SelectCreateDataEnum.STATIC,
    value: RequestDataTypeEnum.STATIC
  },
  {
    label: SelectCreateDataEnum.AJAX,
    value: RequestDataTypeEnum.AJAX
  },
  {
    label: SelectCreateDataEnum.Pond,
    value: RequestDataTypeEnum.Pond
  }
]

// 无数据源
const isNotData = computed(() => {
  return (
    targetData.value.chartConfig?.chartFrame === ChartFrameEnum.STATIC ||
    typeof targetData.value?.option?.dataset === 'undefined'
  )
})
</script>
