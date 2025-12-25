<template>
  <!-- Echarts 全局设置 -->
  <global-setting :optionData="optionData"></global-setting>
  <CollapseItem v-for="(item, index) in seriesList" :key="index" :name="`折线图-${index + 1}`" :expanded="true">
    <SettingItemBox name="线条">
      <SettingItem name="名称">
        <n-input v-model:value="item.name" size="small" placeholder="请输入名称"></n-input>
      </SettingItem>
      <SettingItem name="颜色">
        <n-color-picker size="small" :modes="['hex']" v-model:value="item.lineStyle.color"></n-color-picker>
      </SettingItem>
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
  <CollapseItem v-for="(xAxis, xAxisIndex) in optionData.xAxis" :key="xAxisIndex" :name="`X轴-${xAxisIndex + 1}`" :expanded="true">
    <SettingItemBox name="基本设置">
      <SettingItem name="显示">
        <n-switch v-model:value="xAxis.show" size="small" />
      </SettingItem>
      <SettingItem name="类型">
        <n-input v-model:value="xAxis.type" size="small" placeholder="value" />
      </SettingItem>
      <SettingItem name="名称">
        <n-input v-model:value="xAxis.name" size="small" placeholder="请输入名称" />
      </SettingItem>
      <SettingItem name="边界间距">
        <n-switch v-model:value="xAxis.boundaryGap" size="small" />
      </SettingItem>
      <SettingItem name="分割线">
        <n-switch v-model:value="xAxis.splitLine" size="small" />
      </SettingItem>
    </SettingItemBox>
    <SettingItemBox name="刻度标签">
      <SettingItem name="间隔">
        <n-input-number v-model:value="xAxis.axisLabel.interval" size="small" :min="1" />
      </SettingItem>
      <SettingItem name="格式化">
        <n-input v-model:value="xAxis.axisLabel.formatter" size="small" placeholder="formatter 函数" />
      </SettingItem>
    </SettingItemBox>
    <SettingItemBox name="范围">
      <SettingItem name="最小值">
        <n-input-number v-model:value="xAxis.min" size="small" :min="0" />
      </SettingItem>
      <SettingItem name="最大值">
        <n-input-number v-model:value="xAxis.max" size="small" :min="0" />
      </SettingItem>
    </SettingItemBox>
    <SettingItemBox name="网格索引">
      <n-input-number v-model:value="xAxis.gridIndex" size="small" :min="0" />
    </SettingItemBox>
  </CollapseItem>
   <!-- Y轴配置 -->
   <CollapseItem v-for="(yAxis, yAxisIndex) in optionData.yAxis" :key="yAxisIndex" :name="`Y轴-${yAxisIndex + 1}`" :expanded="true">
    <SettingItemBox name="基本设置">
      <SettingItem name="显示">
        <n-switch v-model:value="yAxis.show" size="small" />
      </SettingItem>
      <SettingItem name="类型">
        <n-input v-model:value="yAxis.type" size="small" placeholder="value" />
      </SettingItem>
      <SettingItem name="名称">
        <n-input v-model:value="yAxis.name" size="small" placeholder="请输入名称" />
      </SettingItem>
      <SettingItem name="边界间距">
        <n-switch v-model:value="yAxis.boundaryGap" size="small" />
      </SettingItem>
      <SettingItem name="分割线">
        <n-switch v-model:value="yAxis.splitLine" size="small" />
      </SettingItem>
    </SettingItemBox>
    <SettingItemBox name="刻度标签">
      <SettingItem name="间隔">
        <n-input-number v-model:value="yAxis.axisLabel.interval" size="small" :min="1" />
      </SettingItem>
      <SettingItem name="格式化">
        <n-input v-model:value="yAxis.axisLabel.formatter" size="small" placeholder="formatter 函数" />
      </SettingItem>
    </SettingItemBox>
    <SettingItemBox name="范围">
      <SettingItem name="最小值">
        <n-input-number v-model:value="yAxis.min" size="small" :min="0" />
      </SettingItem>
      <SettingItem name="最大值">
        <n-input-number v-model:value="yAxis.max" size="small" :min="0" />
      </SettingItem>
    </SettingItemBox>
    <SettingItemBox name="网格索引">
      <n-input-number v-model:value="yAxis.gridIndex" size="small" :min="0" />
    </SettingItemBox>
  </CollapseItem>
</template>

<script setup lang="ts">
import { PropType, computed } from 'vue'
import { lineConf } from '@/packages/chartConfiguration/echarts/index'
import { GlobalThemeJsonType } from '@/settings/chartThemes/index'
import { GlobalSetting, CollapseItem, SettingItemBox, SettingItem } from '@/components/Pages/ChartItemSetting'

const props = defineProps({
  optionData: {
    type: Object as PropType<any>,
    required: true
  }
})

const seriesList = computed(() => {
  const a = props.optionData.series
  const b = props.optionData.xAxis
  const c = props.optionData
  return props.optionData.series
})
</script>
