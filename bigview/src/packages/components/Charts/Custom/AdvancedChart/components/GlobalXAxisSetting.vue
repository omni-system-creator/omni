<template>
  <collapse-item name="X轴">
    <template #header> 
      <n-button type="primary" size="small"  title="添加X轴" @click="addXaxis">添加X轴</n-button>
    </template>
  <collapse-item v-if="xAxisList.length > 0 " :name="`X轴 ${xAxis.name}`" v-for="(xAxis, i) in xAxisList">
    <template #header>
      <n-switch v-model:value="xAxis.show" size="small"></n-switch>
    </template>
    <setting-item-box v-if="xAxis.type === 'value' || xAxis.type === 'log'">
      <template #name>
        <n-text>最大值</n-text>
        <n-tooltip trigger="hover">
          <template #trigger>
            <n-icon size="21" :depth="3">
              <help-outline-icon></help-outline-icon>
            </n-icon>
          </template>
          <n-text>只有value类型可以设置</n-text>
        </n-tooltip>
      </template>
      <n-input-number v-model:value="xAxis.max" size="small"></n-input-number>
    </setting-item-box>
    <setting-item-box name="单位">
      <setting-item name="名称">
        <n-input v-model:value="xAxis.name" size="small"></n-input>
      </setting-item>
      <setting-item name="颜色">
        <n-color-picker size="small" v-model:value="xAxis.nameTextStyle.color"></n-color-picker>
      </setting-item>
      <setting-item name="大小">
        <n-input-number v-model:value="xAxis.nameTextStyle.fontSize" :min="12" size="small"></n-input-number>
      </setting-item>
      <setting-item name="偏移量">
        <n-input-number v-model:value="xAxis.nameGap" :min="5" size="small"></n-input-number>
      </setting-item>
    </setting-item-box>
    <setting-item-box name="标签">
      <setting-item name="展示">
        <n-space>
          <n-switch v-model:value="xAxis.axisLabel.show" size="small"></n-switch>
        </n-space>
      </setting-item>
      <setting-item name="颜色">
        <n-color-picker size="small" v-model:value="xAxis.axisLabel.color"></n-color-picker>
      </setting-item>
      <setting-item name="大小">
        <n-input-number v-model:value="xAxis.axisLabel.fontSize" :min="8" size="small"></n-input-number>
      </setting-item>
      <setting-item name="偏移量">
        <n-input-number v-model:value="xAxis.axisLabel.rotate" :min="-90" :max="90" size="small"></n-input-number>
      </setting-item>
    </setting-item-box>
    <setting-item-box > 
      <setting-item name="绑定容器">
          <n-select v-model:value="xAxis.gridIndex" size="small" :options="gridsListOption"></n-select>
        </setting-item>
    </setting-item-box>
    <!-- <setting-item-box name="轴线">
      <setting-item name="展示">
        <n-space>
          <n-switch v-model:value="xAxis.axisLine.show" size="small"></n-switch>
        </n-space>
      </setting-item>
      <setting-item name="颜色">
        <n-color-picker v-model:value="xAxis.axisLine.lineStyle.color" size="small"></n-color-picker>
      </setting-item>
      <setting-item name="粗细">
        <n-input-number v-model:value="xAxis.axisLine.lineStyle.width" :min="1" size="small"></n-input-number>
      </setting-item>
      <setting-item name="位置">
        <n-select v-model:value="xAxis.position" size="small" :options="axisConfig.xposition"></n-select>
      </setting-item>
      <setting-item name="对齐零">
        <n-space>
          <n-switch v-model:value="xAxis.axisLine.onZero" size="small"></n-switch>
        </n-space>
      </setting-item>
      <setting-item name="反向">
        <n-space>
          <n-switch v-model:value="xAxis.inverse" size="small"></n-switch>
        </n-space>
      </setting-item>
    </setting-item-box>
    <setting-item-box name="刻度">
      <setting-item name="展示">
        <n-space>
          <n-switch v-model:value="xAxis.axisTick.show" size="small"></n-switch>
        </n-space>
      </setting-item>
      <setting-item name="长度">
        <n-input-number v-model:value="xAxis.axisTick.length" :min="1" size="small"></n-input-number>
      </setting-item>
    </setting-item-box>
    <setting-item-box name="分割线">
      <setting-item name="展示">
        <n-space>
          <n-switch v-model:value="xAxis.splitLine.show" size="small"></n-switch>
        </n-space>
      </setting-item>
      <setting-item name="颜色">
        <n-color-picker v-model:value="xAxis.splitLine.lineStyle.color" size="small"></n-color-picker>
      </setting-item>
      <setting-item name="粗细">
        <n-input-number v-model:value="xAxis.splitLine.lineStyle.width" :min="1" size="small"></n-input-number>
      </setting-item>
      <setting-item name="类型">
        <n-select
          v-model:value="xAxis.splitLine.lineStyle.type"
          size="small"
          :options="axisConfig.splitLint.lineStyle.type"
        ></n-select>
      </setting-item>
    </setting-item-box> -->
  </collapse-item> 
  </collapse-item>
</template>

<script setup lang="ts">
import { PropType, computed, watch } from 'vue'
import { CollapseItem, SettingItemBox, SettingItem, GlobalSettingPosition } from '@/components/Pages/ChartItemSetting'
import { icon } from '@/plugins'

const { HelpOutlineIcon } = icon.ionicons5

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
 const xAxisItem = {
  type: 'value',
  name: '-',
  boundaryGap: false,
  splitLine: {
    show: true,
    lineStyle: {
      color: '#ccc',
      width: 1 // 改为 1 而不是 12
    }
  },
  nameGap: 6,
  show: true,
  axisTick: {
    show: false,
  },
  nameTextStyle: {
    color: '#ccc',
    fontSize: 12
  },
  axisLine: {
    show: true,
    lineStyle: {
      color: '#ccc',
      width: 1
    }
    // 完全移除 onZero 配置
  },
  axisLabel: {
    formatter: '{value} m',
    show: true,
    color: '#ccc',
    rotate: 0
  }, 
  interval: 10,
  min: 0,
  max: 110,
  gridIndex: 0,
  // 添加 position 配置
  position: 'bottom',
  // 添加其他必要的默认配置
  axisPointer: {
    type: 'shadow'
  }
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
const addXaxis = () => {
  props.optionData.xAxis.push(xAxisItem)
}
const xAxisList = computed(() => {
  return props.optionData.xAxis
})

// 在设置网格索引之前验证网格是否存在
// watch(() => props.optionData.grid, (newGrids) => {
//   // 更新网格选项
//   gridsListOption.value = newGrids.map((item, i) => ({
//     label: item.name,
//     value: i,
//   }));
  
//   // 确保所有坐标轴的 gridIndex 不超出范围
//   props.optionData.xAxis.forEach((axis, index) => {
//     if (axis.gridIndex >= newGrids.length) {
//       axis.gridIndex = 0; // 重置为第一个网格
//     }
//   });
  
//   props.optionData.yAxis.forEach((axis, index) => {
//     if (axis.gridIndex >= newGrids.length) {
//       axis.gridIndex = 0; // 重置为第一个网格
//     }
//   });
// }, { deep: true });
</script>
