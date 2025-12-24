<template>
  <div
    class="go-border-box"
    :style="{
      boxShadow: `inset 0 0 ${borderShadowWidth}px ${borderShadowColor}`,
      width: `${w}px`,
      height: `${h}px`,
      backgroundColor: backgroundColor
    }"
  >
    <div class="border-header" :style="{ height: `${borderTitleHeight}px` }">
      <img :src="border14Header" :style="{ width: borderTitleWidth + 'px', height: borderTitleHeight + 'px' }" alt="" />
      <div
        class="text"
        :style="{
          fontSize: borderTitleSize + 'px',
          color: borderTitleColor,
          width: borderTitleWidth + 'px',
          left: borderTitleLeft + 'px'
        }"
      >
        {{ borderTitle }}
      </div>
    </div>
    <div class="border-body"></div>
    <div
      class="border-footer"
      :style="{ height: `${borderBottomHeight}px`, backgroundImage: `url(${border14Bottom})` }"
    ></div>
    <div class="tl" :style="{ width: `20px`, height: `20px` }"></div>
    <div class="tr" :style="{ width: `20px`, height: `20px` }"></div>
    <div class="bl" :style="{ width: `20px`, height: `20px` }"></div>
    <div class="br" :style="{ width: `20px`, height: `20px` }"></div>
  </div>
</template>

<script setup lang="ts">
import { PropType, toRefs } from 'vue'
import { CreateComponentType } from '@/packages/index.d'
import border14Header from '@/assets/images/chart/decorates/border14-header.png'
import border14Bottom from '@/assets/images/chart/decorates/border14-bottom.png'

const props = defineProps({
  chartConfig: {
    type: Object as PropType<CreateComponentType>,
    required: true
  }
})

const { w, h } = toRefs(props.chartConfig.attr)
const {
  backgroundColor,
  borderTitle,
  borderTitleColor,
  borderTitleSize,
  borderTitleLeft,
  borderTitleHeight,
  borderTitleWidth,
  borderShadowColor,
  borderShadowWidth,
  borderBottomHeight
} = toRefs(props.chartConfig.option)
</script>

<style lang="scss" scoped>
@include go('border-box') {
  display: flex;
  flex-direction: column;
  position: relative;
  .border-header {
    position: relative;

    .text {
      position: absolute;
      top: 0%;
      bottom: 8%;
      display: flex;
      align-items: center;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }
  }

  .border-body {
    flex: 1;
  }

  .border-footer {
    background-size: auto 100%;
    background-position: center;
    background-repeat: no-repeat;
    overflow: hidden;
  }

  .tl {
    position: absolute;
    top: 0;
    left: 0;
    border-top: 1px solid #2e90ff;
    border-left: 1px solid #2e90ff;
  }
  .tr {
    position: absolute;
    top: 0;
    right: 0;
    border-top: 1px solid #2e90ff;
    border-right: 1px solid #2e90ff;
  }
  .bl {
    position: absolute;
    left: 0;
    bottom: 0;
    border-left: 1px solid #2e90ff;
    border-bottom: 1px solid #2e90ff;
  }
  .br {
    position: absolute;
    right: 0;
    bottom: 0;
    border-right: 1px solid #2e90ff;
    border-bottom: 1px solid #2e90ff;
  }
}
</style>
