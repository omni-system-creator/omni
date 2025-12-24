<template>
  <div v-if="targetData.option.datasources && targetData.option.datasources.length > 0">
    <div v-for="(item, index) in targetData.option.datasources" :key="index">
      {{ item.name }}

      <n-button type="primary" ghost @click="removeDatasource(index)">移除</n-button>
    </div>
  </div>
  <div v-else>未配置数据源</div>
  <n-button type="primary" ghost @click="addDatasource">添加</n-button>
</template>
<script setup lang="ts">
import { useTargetData } from '../../../hooks/useTargetData.hook'
const { targetData, chartEditStore } = useTargetData()

const addDatasource = () => {
  if (!targetData.value.option.datasources) {
    targetData.value.option.datasources = []
  }
  targetData.value.option.datasources.push({
    name: '静态数据' + targetData.value.option.datasources.length,
    type: 'sql'
  })
}

const removeDatasource = (index: number) => {
  targetData.value.option.datasources.splice(index, 1)
}
</script>
<style lang="scss" scoped></style>
