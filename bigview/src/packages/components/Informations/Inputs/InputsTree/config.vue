<template>
  <collapse-item name="数据配置" :expanded="true">
    <setting-item-box name="默认值" :alone="true">
      <n-select size="small" v-model:value="optionData.selectValue" :options="optionData.dataset" />
    </setting-item-box>
    <setting-item-box name="节点配置" :alone="true">
      <n-button type="primary" tertiary size="small" @click.stop="showModal = true">
        <template #icon>
          <n-icon>
            <pencil-icon />
          </n-icon>
        </template>
        编辑
      </n-button>
      <n-card class="collapse-show-box">
        <!-- 函数体 -->
        <p>
          <span class="func-keyword">
         async function onClick</span>(e,components) {
        </p>
        <p class="go-ml-4">
          <n-code :code="optionData.nodeProps.onClick" language="typescript"></n-code>
        </p>
        <p>}<span>,</span></p>
      </n-card>
    </setting-item-box>

  </collapse-item>

  <!-- 弹窗 -->
  <n-modal class="go-chart-data-monaco-editor" v-model:show="showModal" :mask-closable="false">
    <n-card :bordered="false" role="dialog" size="small" aria-modal="true" style="width: 1200px; height: 700px">
      <n-layout has-sider sider-placement="right">
        <n-layout style="height: 580px; padding-right: 20px">
          <!-- 函数名称 -->
          <p class="go-pl-3">
            <span class="func-keyword">async function &nbsp;&nbsp;</span>
            <span class="func-keyNameWord">onClick(e,components)&nbsp;&nbsp;{</span>
          </p>
          <!-- 编辑主体 -->
          <monaco-editor v-model:modelValue="optionData.nodeProps.onClick" height="480px" language="javascript" />
          <!-- 函数结束 -->
          <p class="go-pl-3 func-keyNameWord">}</p>
        </n-layout>
      </n-layout>

      <template #action>
        <n-space justify="space-between">
          <n-space>
            <n-button size="medium" @click="closeEvents">取消</n-button>
            <n-button size="medium" type="primary" @click="saveEvents">保存</n-button>
          </n-space>
        </n-space>
      </template>
    </n-card>


  </n-modal>
</template>

<script lang="ts" setup>
import { PropType,ref } from 'vue'
import { CollapseItem, SettingItemBox } from '@/components/Pages/ChartItemSetting'
import { option } from './config'
import { icon } from '@/plugins'
import { MonacoEditor } from '@/components/Pages/MonacoEditor'
import {BaseEvent} from "@/enums/eventEnum";

// 受控弹窗
const showModal = ref(false)

// 关闭事件
const closeEvents = () => {
  showModal.value = false
}

const saveEvents = () => {

  closeEvents()
}

defineProps({
  optionData: {
    type: Object as PropType<typeof option>,
    required: true
  }
})
</script>
<style scoped lang="scss">
@use '../../../../../views/chart/ContentConfigurations/components/ChartEvent/components/index.scss';
</style>
