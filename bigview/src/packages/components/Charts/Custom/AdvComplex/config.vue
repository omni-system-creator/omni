<template>
  <collapse-item name="数据" :expanded="true">
    <setting-item-box name="数据仓库" :alone="true">
      <setting-item>
        <n-text>配置数据仓库数据源</n-text>
        <n-button type="primary" tertiary size="small" @click.stop="showModal = true">
          <template #icon>
            <n-icon>
              <pencil-icon />
            </n-icon>
          </template>
          编辑
        </n-button>
      </setting-item>
    </setting-item-box>
    <setting-item-box name="自行上传" :alone="true">
      <setting-item>
        <n-text>配置自行上传数据</n-text>
        <n-button type="primary" tertiary size="small" @click.stop="showModal = true">
          <template #icon>
            <n-icon>
              <pencil-icon />
            </n-icon>
          </template>
          编辑
        </n-button>
      </setting-item>
    </setting-item-box>
  </collapse-item>
  <collapse-item name="样式" :expanded="true">
    <setting-item-box name="分组" :alone="true">
      <setting-item>
        <!-- <n-text>配置自行上传数据</n-text> -->
        <n-button type="primary" tertiary size="small" @click.stop="showModal = true">
          <template #icon>
            <n-icon>
              <pencil-icon />
            </n-icon>
          </template>
          编辑
        </n-button>
      </setting-item>
    </setting-item-box>
    <SettingItemBox name="颜色">
      <SettingItem name="主体颜色">
        <n-color-picker
          size="small"
          :modes="['hex']"
          v-model:value="optionData.series[2].markArea.itemStyle.color"
        ></n-color-picker>
      </SettingItem>
    </SettingItemBox>
  </collapse-item>
</template>

<script setup lang="ts">
import { PropType, computed, ref, toRaw } from 'vue'
import { merge, cloneDeep } from 'lodash'

import GlobalSetting from '@/components/Pages/ChartItemSetting/GlobalSetting.vue'
import CollapseItem from '@/components/Pages/ChartItemSetting/CollapseItem.vue'
import SettingItemBox from '@/components/Pages/ChartItemSetting/SettingItemBox.vue'
import SettingItem from '@/components/Pages/ChartItemSetting/SettingItem.vue'

import { lineConf } from '@/packages/chartConfiguration/echarts'
import { GlobalThemeJsonType } from '@/settings/chartThemes'
import { barSeriesItem, lineSeriesItem } from './config'
import { icon } from '@/plugins'
const { HelpOutlineIcon } = icon.ionicons5
const props = defineProps({
  optionData: {
    type: Object as PropType<GlobalThemeJsonType>,
    required: true
  }
})

const seriesList = computed(() => {
  return props.optionData.series
})

const updateHandle = (item: any, value: string) => {
  const _label = cloneDeep(toRaw(item.label))
  lineSeriesItem.label = _label
  // if (value === 'line') {
  //   merge(item, lineSeriesItem)
  // } else {
  //   merge(item, barSeriesItem)
  // }
}

const showModal = ref(false)
</script>
