<template>
  <div class="color-picker-container">
    <!-- 常用颜色 -->
    <div class="preset-colors">
      <div class="color-section-title">常用颜色</div>
      <div class="color-grid">
        <div 
          v-for="color in presetColors" 
          :key="color"
          class="color-item"
          :class="{ active: modelValue === color }"
          :style="{ backgroundColor: color }"
          @click="selectColor(color)"
        >
          <n-icon v-if="modelValue === color" class="check-icon" size="12">
            <svg viewBox="0 0 24 24">
              <path fill="currentColor" d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/>
            </svg>
          </n-icon>
        </div>
      </div>
    </div>

    <!-- 图表主题色 -->
    <div class="theme-colors">
      <div class="color-section-title">图表主题色</div>
      <div class="color-grid">
        <div 
          v-for="color in chartThemeColors" 
          :key="color"
          class="color-item"
          :class="{ active: modelValue === color }"
          :style="{ backgroundColor: color }"
          @click="selectColor(color)"
        >
          <n-icon v-if="modelValue === color" class="check-icon" size="12">
            <svg viewBox="0 0 24 24">
              <path fill="currentColor" d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/>
            </svg>
          </n-icon>
        </div>
      </div>
    </div>

    <!-- 渐变色 -->
    <div class="gradient-colors">
      <div class="color-section-title">渐变色</div>
      <div class="color-grid">
        <div 
          v-for="gradient in gradientColors" 
          :key="gradient.value"
          class="color-item gradient-item"
          :class="{ active: modelValue === gradient.value }"
          :style="{ background: gradient.background }"
          @click="selectColor(gradient.value)"
        >
          <n-icon v-if="modelValue === gradient.value" class="check-icon" size="12">
            <svg viewBox="0 0 24 24">
              <path fill="currentColor" d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/>
            </svg>
          </n-icon>
        </div>
      </div>
    </div>

    <!-- 自定义颜色 -->
    <div class="custom-color">
      <div class="color-section-title">自定义颜色</div>
      <div class="custom-color-picker">
        <n-color-picker 
          v-model:value="customColor" 
          size="small" 
          :show-alpha="false"
          @update:value="selectColor"
        />
        <span class="custom-color-text">点击选择自定义颜色</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

interface Props {
  modelValue: string
}

const props = defineProps<Props>()
const emit = defineEmits(['update:modelValue'])

// 常用颜色
const presetColors = [
  '#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7',
  '#DDA0DD', '#98D8C8', '#F7DC6F', '#BB8FCE', '#85C1E9',
  '#F8C471', '#82E0AA', '#F1948A', '#85C1E9', '#D7BDE2',
  '#A3E4D7', '#F9E79F', '#FADBD8', '#D5DBDB', '#AED6F1'
]

// 图表主题色（ECharts默认色板）
const chartThemeColors = [
  '#5470c6', '#91cc75', '#fac858', '#ee6666', '#73c0de',
  '#3ba272', '#fc8452', '#9a60b4', '#ea7ccc', '#5470c6',
  '#6395fa', '#62daab', '#657798', '#f6bd16', '#e86452',
  '#6ac7b6', '#a53f2b', '#69c0ff', '#fa541c', '#13c2c2'
]

// 渐变色
const gradientColors = [
  {
    value: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
    background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)'
  },
  {
    value: 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)',
    background: 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)'
  },
  {
    value: 'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)',
    background: 'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)'
  },
  {
    value: 'linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)',
    background: 'linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)'
  },
  {
    value: 'linear-gradient(135deg, #fa709a 0%, #fee140 100%)',
    background: 'linear-gradient(135deg, #fa709a 0%, #fee140 100%)'
  },
  {
    value: 'linear-gradient(135deg, #a8edea 0%, #fed6e3 100%)',
    background: 'linear-gradient(135deg, #a8edea 0%, #fed6e3 100%)'
  },
  {
    value: 'linear-gradient(135deg, #ff9a9e 0%, #fecfef 100%)',
    background: 'linear-gradient(135deg, #ff9a9e 0%, #fecfef 100%)'
  },
  {
    value: 'linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%)',
    background: 'linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%)'
  }
]

const customColor = ref(props.modelValue)

const selectColor = (color: string) => {
  emit('update:modelValue', color)
  customColor.value = color
}
</script>

<style lang="scss" scoped>
.color-picker-container {
  width: 100%;
  padding: 12px;
  background: #1a1a1a;
  border-radius: 6px;
  border: 1px solid #404040;
}

.color-section-title {
  font-size: 12px;
  color: #e0e0e0;
  margin-bottom: 8px;
  font-weight: 500;
}

.color-grid {
  display: grid;
  grid-template-columns: repeat(10, 1fr);
  gap: 6px;
  margin-bottom: 16px;
}

.color-item {
  width: 24px;
  height: 24px;
  border-radius: 4px;
  cursor: pointer;
  border: 2px solid transparent;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s ease;
  position: relative;

  &:hover {
    transform: scale(1.1);
    border-color: #409eff;
  }

  &.active {
    border-color: #409eff;
    box-shadow: 0 0 0 2px rgba(64, 158, 255, 0.3);
  }

  &.gradient-item {
    border-radius: 6px;
  }

  .check-icon {
    color: #fff;
    text-shadow: 0 0 2px rgba(0, 0, 0, 0.8);
  }
}

.custom-color {
  .color-section-title {
    margin-bottom: 8px;
  }
}

.custom-color-picker {
  display: flex;
  align-items: center;
  gap: 8px;

  .custom-color-text {
    font-size: 12px;
    color: #999;
  }
}

.preset-colors, .theme-colors, .gradient-colors {
  margin-bottom: 16px;

  &:last-child {
    margin-bottom: 0;
  }
}
</style>