<script setup lang="ts">
import {ConditionNode} from './index'
import {computed} from "vue";

export interface ConditionContentProps {
  node: ConditionNode
}

const props = withDefaults(defineProps<ConditionContentProps>(), {})

const contentText = computed(() => {
  if (props.node.def) {
    return '不满足条件时，进入默认条件'
  } else if (props.node.conditions.conditions.length > 0 || props.node.conditions.groups.length > 0) {
    const count = props.node.conditions.conditions.length + props.node.conditions.groups.length
    return `已设置（${count}）个条件`
  } else {
    return '未设置条件'
  }
})

</script>

<template>
  <el-text>
    {{ contentText }}
  </el-text>
</template>

<style scoped lang="scss">

</style>
