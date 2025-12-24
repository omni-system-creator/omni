<template>
  <collapse-item name="信息" :expanded="true">
    <setting-item-box name="classv" :alone="true">
      <setting-item>
        <n-input v-model:value="optionData.classv" type="text" size="small"></n-input>
      </setting-item>
    </setting-item-box>
    <setting-item-box name="通道号" :alone="true">
      <setting-item>
        <n-input v-model:value="optionData.channel" type="text" size="small"></n-input>
      </setting-item>
    </setting-item-box>
    <setting-item-box name="值" :alone="true">
      <setting-item>
        <n-input-number v-model:value="optionData.value" size="small"></n-input-number>
      </setting-item>
    </setting-item-box>
    <setting-item-box name="字体">
      <SettingItem name="颜色">
        <n-color-picker size="small" :modes="['hex']" v-model:value="optionData.fontColor"></n-color-picker>
      </SettingItem>
      <setting-item name="大小">
        <n-input-number v-model:value="optionData.fontSize" size="small"></n-input-number>
      </setting-item>
    </setting-item-box>
    <setting-item-box name="色域">
      <SettingItem name="上限值">
        <n-input-number
            size="small"
            v-model:value="optionData.maxValue"
        ></n-input-number>
      </SettingItem>
      <SettingItem name="下限值">
        <n-input-number
            size="small"
            v-model:value="optionData.minValue"
        ></n-input-number>
      </SettingItem>
      <SettingItem name="上限颜色">
        <n-color-picker size="small" :modes="['hex']" v-model:value="optionData.maxValueColor"></n-color-picker>
      </SettingItem>
      <SettingItem name="中值颜色">
        <n-color-picker size="small" :modes="['hex']" v-model:value="optionData.midValueColor"></n-color-picker>
      </SettingItem>
      <SettingItem name="下限颜色">
        <n-color-picker size="small" :modes="['hex']" v-model:value="optionData.minValueColor"></n-color-picker>
      </SettingItem>
    </setting-item-box>
  </collapse-item>
  <CollapseItem name="圆点" :expanded="true">
    <SettingItemBox name="具体">
      <SettingItem name="半径">
        <n-input-number
            size="small"
            v-model:value="optionData.outCircle"
        ></n-input-number>
      </SettingItem>
    </SettingItemBox>

  </CollapseItem>

</template>

<script setup lang="ts">
import { PropType } from 'vue'
import {
  CollapseItem,
  SettingItemBox,
  SettingItem
} from '@/components/Pages/ChartItemSetting'
import { option } from './config'

const props = defineProps({
  optionData: {
    type: Object as PropType<typeof option>,
    required: true
  }
})

</script>
