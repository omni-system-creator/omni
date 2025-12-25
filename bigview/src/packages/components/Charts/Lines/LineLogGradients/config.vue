<template>
  <!-- Echarts 全局设置 -->
  <global-setting :optionData="optionData"></global-setting>
  <CollapseItem name="双对数曲线设置" :expanded="true">
    <SettingItemBox name="显示">
      <SettingItem name="X轴">
        <n-select
          v-model:value="xAxis.axisLabel"
          size="small"
          :options="axisConfig.axisLabel.formatter"
        ></n-select>
      </SettingItem>
    </SettingItemBox>
  </CollapseItem>
  <CollapseItem v-for="(item, index) in seriesList" :key="index" name="单折线面积图">
    <SettingItemBox name="线条">
      <SettingItem name="宽度">
        <n-input-number
          v-model:value="item.lineStyle.width"
          :min="1"
          size="small"
          placeholder="自动计算"
        ></n-input-number>
      </SettingItem>
      <SettingItem name="类型">
        <n-select v-model:value="item.lineStyle.type" size="small" :options="lineConf.lineStyle.type"></n-select>
      </SettingItem>
      <SettingItem name="颜色">
    <n-color-picker v-model:value="item.lineStyle.color" size="small"  :modes="['hex']" />
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
import { PropType, computed } from 'vue'
import { lineConf, axisConfig } from '@/packages/chartConfiguration/echarts/index'
import { GlobalThemeJsonType } from '@/settings/chartThemes/index'
import { GlobalSetting, CollapseItem, SettingItemBox, SettingItem } from '@/components/Pages/ChartItemSetting'

const props = defineProps({
  optionData: {
    type: Object as PropType<GlobalThemeJsonType>,
    required: true
  }
})

const xAxis = computed(() => {
  return props.optionData.xAxis as any
})

const seriesList = computed(() => {
  return props.optionData.series
})
</script>
