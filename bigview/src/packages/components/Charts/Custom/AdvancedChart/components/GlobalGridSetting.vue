<template>
  <collapse-item name="容器">
    <template #header>
      <n-button type="primary" size="small" title="添加容器" @click="addGrid">添加容器</n-button>
    </template>
    <collapse-item :name="`容器 ${i + 1}`" v-for="(grid_item, i) in gridList" :key="i">
      <template #header>
        <n-input v-model:value="grid_item.name" size="small"></n-input>
      </template>
      <setting-item-box name="距离">
        <setting-item name="左侧距离">
          <n-input v-model:value="grid_item.left" size="small"></n-input>
        </setting-item>
        <setting-item name="右侧距离">
          <n-input v-model:value="grid_item.right" size="small"></n-input>
        </setting-item>
        <setting-item name="上侧距离">
          <n-input v-model:value="grid_item.top" size="small"></n-input>
        </setting-item>
        <setting-item name="高度">
          <n-input v-model:value="grid_item.height" size="small"></n-input>
        </setting-item>
      </setting-item-box>
    </collapse-item>
  </collapse-item>
</template>

<script setup lang="ts">
import { PropType, computed, watch } from 'vue'
import { CollapseItem, SettingItemBox, SettingItem, GlobalSettingPosition } from '@/components/Pages/ChartItemSetting'

const props = defineProps({
  optionData: {
    type: Object,
    required: true
  },
  inChart: {
    type: Boolean,
    required: false,
    default: false
  }
})
const gridItem = {
  left: '5%',
  right: '5%',
  height: '35%',
  top: '10%',
  bottom: '10%', // 添加 bottom 配置
  name: '-',
  backgroundColor: 'transparent',
  show: true,
  // 添加其他必要的网格属性
  containLabel: true // 确保标签包含在网格内
}
const addGrid = () => {
  props.optionData.grid.push(gridItem)
}

const gridList = computed(() => {
  return props.optionData.grid
})
</script>
