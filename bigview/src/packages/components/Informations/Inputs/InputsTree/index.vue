<template>
  <n-tree
    block-line
    expand-on-click
    default-expand-all
    :data="option.value.dataset"
    :style="`width:${w}px;`"
    :node-props="nodeProps"
    @update:value="onChange"
  />
</template>

<script setup lang="ts">
import { PropType, toRefs, ref, shallowReactive, watch } from 'vue'
import { CreateComponentType } from '@/packages/index.d'
import { useChartEditStore } from '@/store/modules/chartEditStore/chartEditStore'
import {generateBaseFunc,generateFunc, useChartInteract} from '@/hooks'
import { InteractEventOn } from '@/enums/eventEnum'
import { ComponentInteractParamsEnum } from './interact'
import {TreeOption} from "naive-ui";

const props = defineProps({
  chartConfig: {
    type: Object as PropType<CreateComponentType>,
    required: true
  }
})

const { w, h } = toRefs(props.chartConfig.attr)
const option = shallowReactive({
  value: {
    selectValue: props.chartConfig.option.selectValue,
    dataset: props.chartConfig.option.dataset,
    nodeProps:props.chartConfig?.option.nodeProps
  }
})

// 监听事件改变
const onChange = (v: string) => {
  console.log(v,props.chartConfig,useChartEditStore)
  // 存储到联动数据
  useChartInteract(
    props.chartConfig,
    useChartEditStore,
    { [ComponentInteractParamsEnum.DATA]: v },
    InteractEventOn.CHANGE
  )
}



const nodeProps = ({ option:treeOption }: { option: TreeOption }) => {
  return{
    onClick:()=>{
      console.log(option.value.nodeProps.onClick)
      const fnStr = option.value.nodeProps.onClick;
      generateFunc(fnStr,treeOption);
    }
  }
}
/*
* console.log(components,'选项改变');
// 调用组件函数
components.id_2gj8cbwqih3400.exposed.handleUpdateValue();
* */

// 手动更新
watch(
  () => props.chartConfig.option,
  (newData: any) => {
    option.value = newData
    onChange(newData.selectValue)
  },
  {
    immediate: true,
    deep: true
  }
)
</script>

<style lang="scss" scoped>
@include deep() {
  .n-base-selection-label {
    height: v-bind('h + "px"');
    display: flex;
    align-items: center;
  }
}
</style>
