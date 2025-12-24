<template>
  <CollapseItem name="标题" :expanded="true">
    <SettingItemBox name="内容" :alone="true">
      <n-input
        size="small"
        v-model:value="optionData.borderTitle"
        :minlength="1"
        type="text"
        placeholder="请输入标题内容"
      />
    </SettingItemBox>

    <SettingItemBox name="样式">
      <SettingItem name="文字颜色">
        <n-color-picker
          size="small"
          :modes="['hex']"
          v-model:value="optionData.borderTitleColor"
        ></n-color-picker>
      </SettingItem>
      <SettingItem name="文字大小">
        <n-input-number
          size="small"
          v-model:value="optionData.borderTitleSize"
          :min="12"
        />
      </SettingItem>
      <SettingItem name="文字左边距">
        <n-input-number
          size="small"
          v-model:value="optionData.borderTitleLeft"
          :min="0"
        />
      </SettingItem>
      <SettingItem name="高度">
        <n-input-number
          size="small"
          v-model:value="optionData.borderTitleHeight"
          :min="24"
        />
      </SettingItem>
      <SettingItem name="宽度">
        <n-input-number
          size="small"
          v-model:value="optionData.borderTitleWidth"
          :min="50"
          :step="10"
        />
      </SettingItem>
    </SettingItemBox>
  </CollapseItem>
  <CollapseItem name="光晕" :expanded="true">
    <SettingItemBox
      :name="`颜色`"
    >
      <SettingItem>
        <n-color-picker
          size="small"
          :modes="['hex']"
          v-model:value="optionData.borderShadowColor"
        ></n-color-picker>
      </SettingItem>
      <SettingItem>
        <n-button
          size="small"
          @click="optionData.borderShadowColor = option.borderShadowColor"
        >
          恢复默认
        </n-button>
      </SettingItem>
    </SettingItemBox>
    <SettingItemBox name="宽度" :expanded="true">
      <SettingItem>
        <n-input-number
          size="small"
          v-model:value="optionData.borderShadowWidth"
          :minlength="1"
          type="number"
          placeholder="请输入光晕宽度"
        />
      </SettingItem>
      <SettingItem>
        <n-button
          size="small"
          @click="optionData.borderShadowWidth = option.borderShadowWidth"
        >
          恢复默认
        </n-button>
      </SettingItem>
    </SettingItemBox>
  </CollapseItem>
  <CollapseItem name="底部" :expanded="true">
    <SettingItemBox name="样式">
      <SettingItem name="高度">
        <n-input-number
          size="small"
          v-model:value="optionData.borderBottomHeight"
          :min="0"
        />
      </SettingItem>
    </SettingItemBox>
  </CollapseItem>
  
  <CollapseItem name="背景" :expanded="true">
    <SettingItemBox name="颜色">
      <SettingItem>
        <n-color-picker
          size="small"
          :modes="['hex']"
          v-model:value="optionData.backgroundColor"
        ></n-color-picker>
      </SettingItem>
      <SettingItem>
        <n-button
          size="small"
          @click="optionData.backgroundColor = option.backgroundColor"
        >
          恢复默认
        </n-button>
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
