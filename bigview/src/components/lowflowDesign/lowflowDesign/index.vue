<template>
    <el-config-provider >
    <FlowDesign :process="process" :fields="fields"/>
  </el-config-provider>
</template>
<script setup lang="ts">
import FlowDesign from './views/flowDesign/index.vue'
import {FlowNode} from "./views/flowDesign/nodes/Node/index";
import {ref} from "vue";
import {Field} from "./components/Render/interface";
import {StartNode} from "./views/flowDesign/nodes/Start/index";
import {EndNode} from "./views/flowDesign/nodes/End/index";
import { ElConfigProvider } from 'element-plus';

// 流程节点
const isDark = ref(true);
const process = ref<FlowNode>({
  id: 'root',
  pid: null,
  type: 'start',
  name: '开始',
  formProperties: [],
  child: {
    id: 'end',
    pid: 'root',
    type: 'end',
    name: '结束',
    child: null
  } as EndNode
} as StartNode)
// 表单字段
const fields = ref<Field[]>([
  
])

</script>
<style>
</style>
