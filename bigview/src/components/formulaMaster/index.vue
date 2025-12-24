<template>
  <InputFormula ref="InputFormulaRef" v-bind="InputFormulaOptions" @confirm="handleConfirm">
    <Button type="primary">公式编辑</Button>
  </InputFormula>
</template>
<script setup lang="ts">
import { Button } from 'ant-design-vue';
import InputFormula from './components/InputFormula/index.vue';
import variableJson from "./conf/variable.json";
import funcJson from "./conf/func.json";
import { nextTick, ref } from "vue";

const InputFormulaRef = ref();
const InputFormulaOptions = {
  // 弹窗配置
  modalOptions: {
    title: '公式编辑',
  },
  // 表单变量配置
  formOptions: {
    title: '变量',
    treeData: variableJson,
    showParentByNameSpace: ['当前表单'],
    isSearch: true
  },
  // 函数配置
  funcOptions: {
    title: '函数',
    treeData: funcJson,
    isSearch: true
  },
  // 默认提示
  explainOptions: {
    text: '请输入公式', // 添加 text 属性
    list: [] // 可以提供一个空数组作为默认值
  },
  // 编辑器配置
  editorOptions: {
    docs: "IF({name}= \"刘德华\",\"18888888888\",{phone})"
  }
}

const handleConfirm = (formula: string) => {
  nextTick(() => {
    let result = InputFormulaRef.value.RunFormula({
      name: '李明',
      phone: '17732777485'
    }, formula);
    console.log(result);
  });
};
</script>
<style>
body {
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: pink;
}
</style>