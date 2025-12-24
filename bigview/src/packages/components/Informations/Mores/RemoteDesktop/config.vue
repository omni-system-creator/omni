<template>
  <collapse-item name="属性" :expanded="true">
    <setting-item-box name="路径" :alone="true">
      <setting-item name="请填写 https 协议的网址">
        <n-input v-model:value="optionData.dataset" size="small"></n-input>
      </setting-item>
    </setting-item-box>

    <!-- 以下是详细设置 -->
    <!-- <setting-item-box name="基础URL" :alone="true">
      <setting-item>
        <n-input v-model:value="optionData.baseUrl" size="small"></n-input>
      </setting-item>
    </setting-item-box>
    <setting-item-box name="服务器IP地址" :alone="true">
      <setting-item>
        <n-input v-model:value="optionData.ipAddress" size="small"></n-input>
      </setting-item>
    </setting-item-box>
    <setting-item-box name="服务器端口" :alone="true">
      <setting-item>
        <n-input v-model:value="optionData.port" size="small"></n-input>
      </setting-item>
    </setting-item-box>
    <setting-item-box name="用户名" :alone="true">
      <setting-item>
        <n-input v-model:value="optionData.username" size="small"></n-input>
      </setting-item>
    </setting-item-box>
    <setting-item-box name="密码" :alone="true">
      <setting-item>
        <n-input v-model:value="optionData.password" size="small"></n-input>
      </setting-item>
    </setting-item-box>
    <setting-item-box name="宽高" :alone="true">
      <setting-item name="宽">
        <n-input-number v-model:value="optionData.width" size="small"></n-input-number>
      </setting-item>
      <setting-item name="高">
        <n-input-number v-model:value="optionData.height" size="small"></n-input-number>
      </setting-item>
    </setting-item-box> -->

    <setting-item-box name="样式">
      <setting-item name="圆角">
        <n-input-number
          v-model:value="optionData.borderRadius"
          size="small"
          :min="0"
          placeholder="圆角"
        ></n-input-number>
      </setting-item>
    </setting-item-box>
  </collapse-item>
</template>

<script setup lang="ts">
import { PropType } from "vue";
import { option } from "./config";
import {
  CollapseItem,
  SettingItemBox,
  SettingItem,
} from "@/components/Pages/ChartItemSetting";

const props = defineProps({
  optionData: {
    type: Object as PropType<typeof option>,
    required: true,
  },
});
</script>
