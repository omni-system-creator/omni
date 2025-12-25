<template>
   <collapse-item name="Y轴">
    <template #header> 
      <n-button type="primary" size="small"  title="添加X轴" @click="addYaxis">添加Y轴</n-button>
    </template>
    <template v-if="yAxisList.length">
    <collapse-item :key="i" :name="`Y轴 ${yAxis.name}`" v-for="(yAxis, i) in yAxisList">
    <template #header>
      <n-switch v-model:value="yAxis.show" size="small"></n-switch>
    </template>
    <setting-item-box name="刻度范围">
    <setting-item name="最大值">
      <n-input-number v-model:value="yAxis.max" size="small" placeholder="最大值"></n-input-number>
    </setting-item>
    <setting-item name="最小值">
      <n-input-number v-model:value="yAxis.min" size="small" placeholder="最小值"></n-input-number>
    </setting-item>
  </setting-item-box>
    <setting-item-box name="单位">
      <setting-item name="名称">
        <n-input v-model:value="yAxis.name" size="small"></n-input>
      </setting-item>
      <setting-item name="颜色">
        <n-color-picker size="small" v-model:value="yAxis.nameTextStyle.color"></n-color-picker>
      </setting-item>
      <setting-item name="大小">
        <n-input-number v-model:value="yAxis.nameTextStyle.fontSize" :min="8" size="small"></n-input-number>
      </setting-item>
      <setting-item name="偏移量">
        <n-input-number v-model:value="yAxis.nameGap" :min="5" size="small"></n-input-number>
      </setting-item>
    </setting-item-box>
    <setting-item-box name="标签">
      <setting-item name="展示">
        <n-space>
          <n-switch v-model:value="yAxis.axisLabel.show" size="small"></n-switch>
        </n-space>
      </setting-item>
      <setting-item name="颜色">
        <n-color-picker size="small" v-model:value="yAxis.axisLabel.color"></n-color-picker>
      </setting-item>
      <setting-item name="大小">
        <n-input-number v-model:value="yAxis.axisLabel.fontSize" :min="8" size="small"></n-input-number>
      </setting-item>
      <setting-item name="偏移量">
        <n-input-number v-model:value="yAxis.axisLabel.rotate" :min="-90" :max="90" size="small"></n-input-number>
      </setting-item>
    </setting-item-box>
    <setting-item-box name="轴线">
      <setting-item name="展示">
        <n-space>
          <n-switch v-model:value="yAxis.axisLine.show" size="small"></n-switch>
        </n-space>
      </setting-item>
      <setting-item name="颜色">
        <n-color-picker v-model:value="yAxis.axisLine.lineStyle.color" size="small"></n-color-picker>
      </setting-item>
      <setting-item name="粗细">
        <n-input-number v-model:value="yAxis.axisLine.lineStyle.width" :min="1" size="small"></n-input-number>
      </setting-item>
      <setting-item name="位置">
        <n-select v-model:value="yAxis.position" size="small" :options="axisConfig.yposition"></n-select>
      </setting-item>
      <!-- <setting-item name="对齐零">
        <n-space>
          <n-switch v-model:value="yAxis.axisLine.onZero" size="small"></n-switch>
        </n-space>
      </setting-item> -->
      <!-- <setting-item name="反向">
        <n-space>
          <n-switch v-model:value="yAxis.inverse" size="small"></n-switch>
        </n-space>
      </setting-item> -->
    </setting-item-box>
    <setting-item-box>
      <setting-item name="绑定容器">
          <n-select v-model:value="yAxis.gridIndex" size="small" :options="gridsListOption"></n-select>
        </setting-item>
    </setting-item-box>
    <!-- <setting-item-box name="刻度">
      <setting-item name="展示">
        <n-space>
          <n-switch v-model:value="yAxis.axisTick.show" size="small"></n-switch>
        </n-space>
      </setting-item>
      <setting-item name="长度">
        <n-input-number v-model:value="yAxis.axisTick.length" :min="1" size="small"></n-input-number>
      </setting-item>
    </setting-item-box>
    <setting-item-box name="分割线">
      <setting-item name="展示">
        <n-space>
          <n-switch v-model:value="yAxis.splitLine.show" size="small"></n-switch>
        </n-space>
      </setting-item>
      <setting-item name="颜色">
        <n-color-picker v-model:value="yAxis.splitLine.lineStyle.color" size="small"></n-color-picker>
      </setting-item>
      <setting-item name="粗细">
        <n-input-number v-model:value="yAxis.splitLine.lineStyle.width" :min="1" size="small"></n-input-number>
      </setting-item>
      <setting-item name="类型">
        <n-select
          v-model:value="yAxis.splitLine.lineStyle.type"
          size="small"
          :options="axisConfig.splitLint.lineStyle.type"
        ></n-select>
      </setting-item>
    </setting-item-box> -->
  </collapse-item>
  </template>
  </collapse-item>
</template>

<script setup lang="ts">
import { PropType, computed, watch } from 'vue'
import { GlobalThemeJsonType } from '@/settings/chartThemes/index'
import { axisConfig, legendConfig } from '@/packages/chartConfiguration/echarts/index'
import { CollapseItem, SettingItemBox, SettingItem, GlobalSettingPosition } from '@/components/Pages/ChartItemSetting'
import { icon } from '@/plugins'

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
const yaxisItem = {
      show: true, 
      type: 'value',
      name: '-',
      position: 'left',
      max: 1000,
      min: 0,
      axisLine: {
        show: true,
        lineStyle: {
          color: '#ccc',
          width: 1
        },
        
      },
      nameTextStyle: {
        color: '#ccc',
        fontSize: 12,
      },
      splitLine: {
        show: false
      },
      axisLabel:{
        show: true,
        formatter: '{value} ',
        color: '#ccc',
        fontSize: 12,
        rotate: 0,

      },
      nameGap: 5,
      lineStyle: {
        color: '#ccc'
      },
      gridIndex: 0
    }
const gridsListOption = computed(() => {
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
 const addYaxis = () => {
  props.optionData.yAxis.push(yaxisItem) 
 }
const yAxisList = computed(() => {
  return props.optionData.yAxis
})



</script>
