<template>
  <n-modal v-model:show="showModal" preset="dialog" title="X轴配置" style="width: 650px;">
    <div class="xaxis-config-dialog">
      <!-- 基本配置 -->
      <setting-item-box name="基本配置">
        <setting-item name="轴名称">
          <n-input 
            v-model:value="axisData.name" 
            size="small" 
            :placeholder="axisData.dataField ? `${axisData.dataField}（字段名）` : 'X轴名称'" 
          />
        </setting-item>
        <setting-item name="轴类型">
          <n-select 
            v-model:value="axisData.type" 
            size="small" 
            :options="axisTypeOptions"
            placeholder="选择轴类型"
          />
        </setting-item>
        <setting-item name="位置">
          <n-select 
            v-model:value="axisData.position" 
            size="small" 
            :options="xAxisPositionOptions"
            placeholder="选择位置"
          />
        </setting-item>
        <setting-item name="偏移量">
          <n-input-number 
            v-model:value="axisData.offset" 
            size="small" 
            :min="0"
            placeholder="偏移量"
          />
        </setting-item>
      </setting-item-box>

      <!-- 对数刻度配置 -->
      <setting-item-box name="对数刻度配置" v-if="axisData.type === 'log'">
        <setting-item name="对数底数">
          <n-select 
            v-model:value="axisData.logBase" 
            size="small" 
            :options="logBaseOptions"
            placeholder="选择对数底数"
          />
        </setting-item>
        <setting-item name="最小值">
          <n-input-number 
            v-model:value="axisData.min" 
            size="small" 
            :min="0.001"
            :step="0.1"
            placeholder="最小值（必须大于0）"
          />
        </setting-item>
        <setting-item name="最大值">
          <n-input-number 
            v-model:value="axisData.max" 
            size="small" 
            :min="0.001"
            :step="0.1"
            placeholder="最大值（必须大于0）"
          />
        </setting-item>
      </setting-item-box>

      <!-- 数值范围 -->
      <setting-item-box name="数值范围" v-if="axisData.type === 'value'">
        <setting-item name="最小值">
          <n-input-number 
            v-model:value="axisData.min" 
            size="small" 
            placeholder="最小值"
          />
        </setting-item>
        <setting-item name="最大值">
          <n-input-number 
            v-model:value="axisData.max" 
            size="small" 
            placeholder="最大值"
          />
        </setting-item>
      </setting-item-box>

      <setting-item-box name="标签配置" :alone="true">
        <div>
          <n-switch v-model:value="axisData.customLabels.enabled" size="small" />
        </div>
        <div v-if="axisData.customLabels.enabled" class="custom-labels-container">
          <setting-item name="">
            <n-input
              v-model:value="axisData.customLabels.textValue"
              type="textarea"
              size="small"
              placeholder="请输入标签配置，格式：数值:标签文本，多个标签用分号分隔&#10;示例：0:起点;50:中点;100:终点"
              :rows="4"
              style="width: 100%;"
              @blur="validateLabels"
            />
          </setting-item>
          <div class="format-hint">
            <n-text depth="3" style="font-size: 12px;">
              格式说明：数值:标签文本，多个标签用分号(;)分隔<br/>
              示例：0:起点;50:中点;100:终点
            </n-text>
          </div>
        </div>
      </setting-item-box>

      <!-- 数据源 -->
      <setting-item-box name="数据源" v-if="props.multiDatasource">
        <setting-item name="数据源">
          <n-select 
            v-model:value="axisData.datasourceIndex" 
            size="small" 
            :options="datasourceOptions"
            placeholder="选择数据源"
          />
        </setting-item>
        <setting-item name="数据字段">
          <n-select 
            v-model:value="axisData.dataField" 
            size="small" 
            :options="fieldOptions"
            placeholder="选择数据字段"
            clearable
          />
        </setting-item>
      </setting-item-box>

      <!-- 显示配置 -->
      <setting-item-box name="显示配置" :alone="true">
        <el-row>
          <el-col :span="6">
            <n-switch v-model:value="axisData.axisLine.show" size="small">
              <template #checked>
                轴线
              </template>
              <template #unchecked>
                轴线
              </template>
            </n-switch>
          </el-col>
          <el-col :span="6">
            <n-switch v-model:value="axisData.axisTick.show" size="small">
              <template #checked>
                刻度
              </template>
              <template #unchecked>
                刻度
              </template>
            </n-switch>
          </el-col>
          <el-col :span="6">
            <n-switch v-model:value="axisData.axisLabel.show" size="small">
              <template #checked>
                标签
              </template>
              <template #unchecked>
                标签
              </template>
            </n-switch>
          </el-col>
          <el-col :span="6">
            <n-switch v-model:value="axisData.splitLine.show" size="small">
              <template #checked>
                网格
              </template>
              <template #unchecked>
                网格
              </template>
            </n-switch>
          </el-col>
        </el-row>
      </setting-item-box>

      <!-- 样式配置 -->
      <setting-item-box name="样式配置" :alone="true">
        <div style="padding-right: 10px;">
          <el-row :gutter="10">
            <el-col :span="6">
              <setting-item name="轴线颜色" v-if="axisData.axisLine.show">
                <n-color-picker v-model:value="axisData.axisLine.lineStyle.color" size="small" />
              </setting-item>
            </el-col>
            <el-col :span="6">
              <setting-item name="刻度颜色" v-if="axisData.axisTick.show">
                <n-color-picker v-model:value="axisData.axisTick.lineStyle.color" size="small" />
              </setting-item>
            </el-col>
            <el-col :span="6">
              <setting-item name="标签颜色" v-if="axisData.axisLabel.show">
                <n-color-picker v-model:value="axisData.axisLabel.color" size="small" />
              </setting-item>
            </el-col>
            <el-col :span="6">
              <setting-item name="网格线颜色" v-if="axisData.splitLine.show">
                <n-color-picker v-model:value="axisData.splitLine.lineStyle.color" size="small" />
              </setting-item>
            </el-col>
          </el-row>
        </div>
      </setting-item-box>
    </div>

    <template #action>
      <n-button @click="handleCancel">取消</n-button>
      <n-button type="primary" @click="handleConfirm">确定</n-button>
    </template>
  </n-modal>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import cloneDeep from 'lodash/cloneDeep'
import { parseCSVHeaders } from '@/utils/file'
import SettingItemBox from '@/components/Pages/ChartItemSetting/SettingItemBox.vue'
import SettingItem from '@/components/Pages/ChartItemSetting/SettingItem.vue'

interface Props {
  show: boolean
  axisData: any
  datasourceOptions?: any[]
  multiDatasource?: boolean
  datasources?: any[]
}

const props = defineProps<Props>()
const emit = defineEmits(['update:show', 'confirm'])

// 使用computed属性来处理v-model
const showModal = computed({
  get: () => props.show,
  set: (value) => emit('update:show', value)
})

// 计算字段选项
const fieldOptions = computed(() => {
  if (!props.datasources || !Array.isArray(props.datasources)) {
    return []
  }
  
  if (axisData.value.datasourceIndex === undefined || axisData.value.datasourceIndex === null) {
    return []
  }
  
  const selectedDatasource = props.datasources[axisData.value.datasourceIndex]
  
  if (!selectedDatasource) {
    return []
  }
  
  // 如果是静态数据JSON类型，检查 staticData 字段
  if ((selectedDatasource.type === 'static-json' || selectedDatasource.type === 'file-json' || selectedDatasource.type === 'workflow-json') && selectedDatasource.staticData) {
    if (typeof selectedDatasource.staticData === 'string') {
      try {
        const parsedData = JSON.parse(selectedDatasource.staticData)
        if (Array.isArray(parsedData) && parsedData.length > 0) {
          const firstItem = parsedData[0]
          if (firstItem && typeof firstItem === 'object') {
            const keys = Object.keys(firstItem)
            return keys.map(key => ({
              label: key,
              value: key
            }))
          }
        }
      } catch (error) {
        console.log('failed to parse staticData as JSON:', error)
      }
    }
  }
  // 如果是静态数据CSV类型，检查 csvData 字段
  else if ((selectedDatasource.type === 'static-csv' || selectedDatasource.type === 'file-csv' || selectedDatasource.type === 'workflow-csv') && selectedDatasource.csvData) {
    if (typeof selectedDatasource.csvData === 'string') {
      const csvHeaders = parseCSVHeaders(selectedDatasource.csvData)
      if (csvHeaders.length > 0) {
        return csvHeaders.map(header => ({
          label: header,
          value: header
        }))
      }
    }
  }
  return []
})

const axisData = ref({
  name: '',
  type: 'value',
  position: 'bottom',
  offset: 0,
  min: undefined as number | undefined,
  max: undefined as number | undefined,
  datasourceIndex: 0,
  dataField: '',
  logBase: 10,
  customLabels: {
    enabled: false,
    textValue: '',
    labels: [] as Array<{ value: number; text: string }>
  },
  axisLine: {
    show: true,
    lineStyle: {
      color: '#666666'
    }
  },
  axisTick: {
    show: true,
    lineStyle: {
      color: '#666666'
    }
  },
  axisLabel: {
    show: true,
    color: '#666666'
  },
  splitLine: {
    show: false,
    lineStyle: {
      color: '#e0e0e0'
    }
  }
})

const xAxisPositionOptions = [
  { label: '底部', value: 'bottom' },
  { label: '顶部', value: 'top' }
]

const axisTypeOptions = [
  { label: '类目轴', value: 'category' },
  { label: '数值轴', value: 'value' },
  { label: '对数轴', value: 'log' },
  { label: '时间轴', value: 'time' }
]

const logBaseOptions = [
  { label: '自然对数 (e)', value: 'e' },
  { label: '常用对数 (10)', value: 10 },
  { label: '二进制对数 (2)', value: 2 }
]

// 自定义标签管理方法已移除，现在使用textarea格式
// 解析自定义标签文本
const parseCustomLabels = (textValue: string) => {
  if (!textValue || !textValue.trim()) {
    return []
  }
  
  const labels = []
  const pairs = textValue.split(';')
  
  for (const pair of pairs) {
    const trimmedPair = pair.trim()
    if (!trimmedPair) continue
    
    const colonIndex = trimmedPair.indexOf(':')
    if (colonIndex === -1) continue
    
    const valueStr = trimmedPair.substring(0, colonIndex).trim()
    const text = trimmedPair.substring(colonIndex + 1).trim()
    
    const value = parseFloat(valueStr)
    if (!isNaN(value) && text) {
      labels.push({ value, text })
    }
  }
  
  return labels
}

watch(() => axisData.value.customLabels.textValue, (newTextValue) => {
  if (axisData.value.customLabels.enabled) {
    axisData.value.customLabels.labels = parseCustomLabels(newTextValue)
  }
}, { immediate: true })

const validateLabels = () => {
  if(!axisData.value.customLabels.labels) return
  const newLabels = axisData.value.customLabels.labels
  if (Array.isArray(newLabels) && newLabels.length > 0) {
    const textValue = newLabels
      .filter(label => label.value !== undefined && label.text)
      .map(label => `${label.value}:${label.text}`)
      .join(';')
    
    if (textValue !== axisData.value.customLabels.textValue) {
      axisData.value.customLabels.textValue = textValue
    }
  }
}

watch(() => props.axisData, (newData) => {
  if (newData) {
    axisData.value = cloneDeep({
      name: '',
      position: 'bottom',
      offset: 0,
      datasourceIndex: 0,
      dataField: '',
      customLabels: {
        enabled: false,
        textValue: '',
        labels: [] as Array<{ value: number; text: string }>
      },
      axisLine: {
        show: true,
        lineStyle: {
          color: '#666666'
        }
      },
      axisTick: {
        show: true
      },
      axisLabel: {
        show: true,
        color: '#666666'
      },
      splitLine: {
        show: false,
        lineStyle: {
          color: '#e0e0e0'
        }
      },
      ...newData
    })
    if (!axisData.value.axisTick.lineStyle) {
      axisData.value.axisTick.lineStyle = {
        color: '#666666'
      }
    }
  }
}, { immediate: true, deep: true })

const handleCancel = () => {
  emit('update:show', false)
}

const handleConfirm = () => {
  emit('confirm', cloneDeep(axisData.value))
  emit('update:show', false)
}
</script>

<style lang="scss" scoped>
.xaxis-config-dialog {
  max-height: 500px;
  overflow-y: auto;
  
  // 优化布局间距
  :deep(.setting-item-box) {
    margin-bottom: 16px;
    
    .setting-item-box-header {
      white-space: nowrap;
      font-weight: 500;
    }
  }
  
  :deep(.setting-item) {
    margin-bottom: 12px;
    
    .setting-item-label {
      white-space: nowrap;
      min-width: 80px;
    }
  }

  .custom-labels-container {
    margin-top: 12px;
    
    .custom-label-item {
      margin-bottom: 8px;
      
      .label-inputs {
        display: flex;
        align-items: center;
        flex-wrap: wrap;
        gap: 8px;
      }
    }

    .format-hint {
      margin-top: 8px;
      padding: 8px;
      background-color: #353535;
      border-radius: 4px;
      border-left: 3px solid #18a058;
    } 
  }
}
</style>