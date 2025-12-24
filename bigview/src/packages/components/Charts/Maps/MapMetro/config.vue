<template>
  <collapse-item name="基础" :expanded="true">
    <!-- <setting-item-box name="选择城市" :alone="true">
      <setting-item>
        <n-select size="small" v-model:value="optionData.mapOptions.city" :options="cityOptions" />
      </setting-item>
    </setting-item-box> -->
    <setting-item-box name="加载方式" :alone="true">
      <setting-item name="加载所有线路">
        <n-space>
          <n-switch v-model:value="optionData.mapOptions.showAll" size="small"></n-switch>
        </n-space>
      </setting-item>
      <setting-item name="显示线路名称">
        <n-space>
          <n-switch v-model:value="optionData.maplibreglOptions.showLabel" size="small"></n-switch>
        </n-space>
      </setting-item>
    </setting-item-box>
    <setting-item-box name="选择线路" :alone="true">
      <setting-item>
        <n-select size="small" :disabled="optionData.mapOptions.showAll" v-model:value="optionData.maplibreglOptions.line" :options="lineOptions" />
      </setting-item>
    </setting-item-box>

    <template v-if="optionData.maplibreglOptions">
      <setting-item-box name="缩放" :alone="true">
        <setting-item>
          <n-input-number :disabled="optionData.mapOptions.showAll" v-model:value="optionData.maplibreglOptions.zoom" :min="0" size="small"></n-input-number>
        </setting-item>
      </setting-item-box>
      <setting-item-box name="中心点" :alone="true">
        <setting-item>
          <n-input-group>
            <n-input-number :disabled="optionData.mapOptions.showAll" v-model:value="optionData.maplibreglOptions.center[0]" :min="0" size="small" :style="{ width: '50%' }"></n-input-number>
            <n-input-number :disabled="optionData.mapOptions.showAll" v-model:value="optionData.maplibreglOptions.center[1]" :min="0" size="small" :style="{ width: '50%' }"></n-input-number>
          </n-input-group>
        </setting-item>
      </setting-item-box>
      <setting-item-box name="旋转角度" :alone="true">
        <setting-item>
          <n-input-number :disabled="optionData.mapOptions.showAll" v-model:value="optionData.maplibreglOptions.bearing" :min="-90" size="small"></n-input-number>
        </setting-item>
      </setting-item-box>
      <setting-item-box name="倾斜角度" :alone="true">
        <setting-item>
          <n-input-number :disabled="optionData.mapOptions.showAll" v-model:value="optionData.maplibreglOptions.pitch" :min="-100" size="small"></n-input-number>
        </setting-item>
      </setting-item-box>
      <setting-item-box name="线路宽度" :alone="true">
        <setting-item>
          <n-input-number v-model:value="optionData.maplibreglOptions.lineWidth" :min="0.1" size="small"></n-input-number>
        </setting-item>
      </setting-item-box>
      <setting-item-box name="铁轨间隔" :alone="true">
        <setting-item>
          <n-input-number v-model:value="optionData.maplibreglOptions.railwayWidth" :min="0.1" size="small"></n-input-number>
        </setting-item>
      </setting-item-box>
      <setting-item-box name="线路颜色" :alone="true">
        <setting-item>
          <n-color-picker v-model:value="optionData.maplibreglOptions.lineColor" size="small"  :modes="['hex']" />
        </setting-item>
        <setting-item>
          <n-color-picker v-model:value="optionData.maplibreglOptions.lineColor2" size="small"  :modes="['hex']" />
        </setting-item>
      </setting-item-box>
    </template>

  </collapse-item>
  <collapse-item name="Z轴热力图" :expanded="true">
    <!-- <setting-item-box name="选择类型" :alone="true">
      <setting-item>
        <n-select size="small" v-model:value="optionData.maplibreglOptions.hot_param" :options="hotParamOptions" />
      </setting-item>
    </setting-item-box> -->
    <setting-item-box name="透明度" :alone="true">
      <setting-item>
        <n-input-number v-model:value="optionData.maplibreglOptions.alpha" :min="10" :max="255" size="small"></n-input-number>
      </setting-item>
    </setting-item-box>
  </collapse-item>
</template>

<script setup lang="ts">
import { PropType } from 'vue'
import { option} from './config'
import { CollapseItem, SettingItemBox, SettingItem } from '@/components/Pages/ChartItemSetting'

defineProps({
  optionData: {
    type: Object as PropType<typeof option>,
    required: true
  }
})

const hotParamOptions = [
  {
    value: 'yingdian',
    label:'硬点',
  },
  {
    value: 'yali',
    label: '压力',
  },
  {
    value: 'rh_licheng',
    label:'燃弧里程',
  },
]

const hotSizeOptions = [
{
    value: '10',
    label:'10',
  },
  {
    value: '20',
    label:'20',
  },
  {
    value: '100',
    label: '100',
  },
  {
    value: '200',
    label:'200',
  },
]

const cityOptions = [
  {
    value: '台州',
    label: '台州'
  },
  {
    value: '福州',
    label: '福州'
  },
  {
    value: '天津',
    label: '天津'
  },
]

const lineOptions =[
  {
    value: 'geojson_tz',
    label: '台州S1'
  },
  {
    value: 'geojson_fz_f1',
    label: '福州F1号线'
  },
  {
    value: 'all',
    label: '所有'
  }
]

</script>
