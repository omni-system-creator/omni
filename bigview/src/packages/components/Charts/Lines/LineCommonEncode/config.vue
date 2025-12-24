<template>
  <!-- Echarts 全局设置 -->
  <global-setting :optionData="optionData"></global-setting>
  <CollapseItem name="序列数量配置" :expanded="true">
    <SettingItemBox name="类型">
      <SettingItem>
        <n-input-number
          v-model:value="series_count"
          :min="1"
          :max="100"
          size="small"
          @update:value="handleChange"
          placeholder="序列个数，请根据数据填写"
        ></n-input-number>
      </SettingItem>
    </SettingItemBox>
  </CollapseItem>
  <CollapseItem v-for="(item, index) in seriesList" :key="index" :name="`折线图-${index + 1}`" :expanded="true">    
    <SettingItemBox name="名称">
      <SettingItem name="name">
        <n-input v-model:value="item.name" size="small"></n-input>
      </SettingItem>
    </SettingItemBox>
    <SettingItemBox name="数据">
      <SettingItem name="X轴">
        <n-input-number
          v-model:value="item.encode.x"
          :min="0"
          :max="100"
          size="small"
          placeholder="数据index"
        ></n-input-number>
      </SettingItem>
      <SettingItem name="Y轴">
        <n-input-number
          v-model:value="item.encode.y"
          :min="0"
          :max="100"
          size="small"
          placeholder="数据index"
        ></n-input-number>
      </SettingItem>
    </SettingItemBox>
    <SettingItemBox name="线条">
      <SettingItem name="宽度">
        <n-input-number
          v-model:value="item.lineStyle.width"
          :min="1"
          :max="100"
          size="small"
          placeholder="自动计算"
        ></n-input-number>
      </SettingItem>
      <SettingItem name="类型">
        <n-select v-model:value="item.lineStyle.type" size="small" :options="lineConf.lineStyle.type"></n-select>
      </SettingItem>
    </SettingItemBox>
    <SettingItemBox name="实心点">
      <SettingItem name="大小">
        <n-input-number
          v-model:value="item.symbolSize"
          :min="1"
          :max="100"
          size="small"
          placeholder="自动计算"
        ></n-input-number>
      </SettingItem>
    </SettingItemBox>
    <setting-item-box name="标签">
      <setting-item>
        <n-space>
          <n-switch v-model:value="item.label.show" size="small" />
          <n-text>展示标签</n-text>
        </n-space>
      </setting-item>
      <setting-item name="大小">
        <n-input-number v-model:value="item.label.fontSize" size="small" :min="1"></n-input-number>
      </setting-item>
      <setting-item name="颜色">
        <n-color-picker size="small" :modes="['hex']" v-model:value="item.label.color"></n-color-picker>
      </setting-item>
      <setting-item name="位置">
        <n-select
          v-model:value="item.label.position"
          :options="[
            { label: 'top', value: 'top' },
            { label: 'left', value: 'left' },
            { label: 'right', value: 'right' },
            { label: 'bottom', value: 'bottom' }
          ]"
        />
      </setting-item>
    </setting-item-box>
  </CollapseItem>
</template>

<script setup lang="ts">
import { PropType, computed, ref } from 'vue'
import { lineConf } from '@/packages/chartConfiguration/echarts/index'
import { GlobalThemeJsonType } from '@/settings/chartThemes/index'
import { GlobalSetting, CollapseItem, SettingItemBox, SettingItem } from '@/components/Pages/ChartItemSetting'
import cloneDeep from 'lodash/cloneDeep'

const series_count = computed(() => {
  return props.optionData.series.length
})
const handleChange = (v: number | null) => {
  const serie = props.optionData.series[0]
  const arr = []
  for (var i = 0; i < (v ? v : 1); i++) {
    arr.push(cloneDeep(serie))
  }
  props.optionData.series = arr
}
const props = defineProps({
  optionData: {
    type: Object as PropType<GlobalThemeJsonType>,
    required: true
  }
})

const seriesList = computed(() => {
  const a =  props.optionData.series
  return props.optionData.series
})
</script>
