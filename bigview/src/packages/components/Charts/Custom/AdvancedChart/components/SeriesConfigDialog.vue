<template>
  <n-modal v-model:show="showModal" preset="dialog" title="系列配置" style="width: 700px;">
    <div class="series-config-dialog">
      <!-- 基本配置 -->
      <setting-item-box name="基本配置">
        <setting-item name="系列名称">
          <n-input 
            v-model:value="seriesData.name" 
            size="small" 
            :placeholder="seriesData.dataField ? `${seriesData.dataField}（字段名）` : '系列名称'" 
          />
        </setting-item>
        <setting-item name="图表类型">
          <n-select 
            v-model:value="seriesData.type" 
            size="small" 
            :options="chartTypeOptions"
            placeholder="选择图表类型"
          />
        </setting-item>
        <setting-item name="X轴">
          <n-select 
            v-model:value="seriesData.xAxisIndex" 
            size="small" 
            :options="xAxisOptions"
            placeholder="选择X轴"
          />
        </setting-item>
        <setting-item name="Y轴">
          <n-select 
            v-model:value="seriesData.yAxisIndex" 
            size="small" 
            :options="yAxisOptions"
            placeholder="选择Y轴"
          />
        </setting-item>
      </setting-item-box>

      <!-- 数据源 -->
      <setting-item-box name="数据源" v-if="multiDatasource">
        <setting-item name="数据源">
          <n-select 
            v-model:value="seriesData.datasourceIndex" 
            size="small" 
            :options="datasourceOptions"
            placeholder="选择数据源"
          />
        </setting-item>
        <setting-item name="Y轴字段">
          <n-select 
            v-model:value="seriesData.dataField" 
            size="small" 
            :options="fieldOptions"
            placeholder="选择Y轴数据字段"
          />
        </setting-item>
      </setting-item-box>

      <!-- 样式配置 -->
      <setting-item-box name="样式配置">
        <setting-item name="颜色">
          <div class="color-picker-wrapper">
            <n-popover trigger="click" placement="bottom-start" :show-arrow="false">
              <template #trigger>
                <div class="color-preview" :style="{ backgroundColor: seriesData.itemStyle.color }">
                  <span class="color-value" :style="{ color: colorTextColor }">{{ seriesData.itemStyle.color }}</span>
                </div>
              </template>
              <ColorPicker v-model="seriesData.itemStyle.color" />
            </n-popover>
          </div>
        </setting-item>

        <!-- stack 只支持堆叠于 'value' 和 'log' 类型的类目轴上，不支持 'time' 和 'category' 类型的类目轴。 堆叠组是填一个名字 -->
        <setting-item name="堆叠组" v-if="seriesData.type === 'bar'">
          <div>
            <n-input v-model:value="seriesData.stack" size="small" placeholder="输入堆叠组名称" />
          </div>
        </setting-item>
        <setting-item name="线宽" v-if="isLineType">
          <n-input-number 
            v-model:value="seriesData.lineStyle.width" 
            size="small" 
            :min="1"
            :max="10"
          />
        </setting-item>
        <setting-item name="平滑曲线" v-if="isLineType">
          <div>
            <n-switch v-model:value="seriesData.smooth" size="small" />
          </div>
        </setting-item>
        <setting-item name="显示标记点" v-if="isLineType">
          <div>
            <n-switch v-model:value="seriesData.showSymbol" size="small" />
          </div>
        </setting-item>
        <!-- 面积图样式配置 -->
        <setting-item name="面积透明度" v-if="seriesData.type === 'area'">
          <n-input-number 
            v-model:value="seriesData.areaStyle.opacity" 
            size="small" 
            :min="0"
            :max="1"
            :step="0.1"
            placeholder="0.3"
          />
        </setting-item>
        <setting-item name="散点大小" v-if="seriesData.type === 'scatter'">
          <n-input-number 
            v-model:value="seriesData.symbolSize" 
            size="small" 
            :min="0"
            :max="5000"
          />
        </setting-item>
        <!--散点形状-->
        <setting-item name="散点形状" v-if="seriesData.type === 'scatter'">
          <n-select 
            v-model:value="seriesData.symbol" 
            size="small" 
            :options="symbolOptions"
          />
        </setting-item>
      </setting-item-box>

      <!-- 标注区域（markArea）配置 -->
      <setting-item-box name="标注区域" :alone="true">
        <!-- 批量导入/下载模板 -->
        <setting-item name="">
          <div>
            <n-space>
              <n-button size="small" @click="downloadMarkAreaCsvTemplate">下载CSV模板</n-button>
              <n-button size="small" @click="downloadMarkAreaJsonTemplate">下载JSON模板</n-button>
              <n-button size="small" @click="triggerImport('csv')">导入CSV</n-button>
              <n-button size="small" @click="triggerImport('json')">导入JSON</n-button>
              <n-button size="small" @click="addMarkArea">新增标注区域</n-button>
            </n-space>
            <input ref="csvInputRef" type="file" accept=".csv" @change="handleImportCsv" style="display: none;" />
            <input ref="jsonInputRef" type="file" accept=".json,.txt" @change="handleImportJson" style="display: none;" />
            <div class="helper-text">模板字段：name,start_xAxis,end_xAxis,color（示例：区域1,07:30,10:00,#d0e3ff）</div>
          </div>
        </setting-item>
        <template v-if="seriesData.markArea && Array.isArray(seriesData.markArea.data)">
          <div class="mark-area-list">
            <div class="mark-area-item" v-for="(pair, idx) in seriesData.markArea.data" :key="idx">
              <n-input 
                class="ma-field name" 
                v-model:value="seriesData.markArea.data[idx][0].name" 
                size="small" 
                placeholder="区域名称 (可选)" 
              />
              <n-input 
                class="ma-field start" 
                v-model:value="seriesData.markArea.data[idx][0].xAxis" 
                size="small" 
                placeholder="起点 xAxis，如 07:30" 
              />
              <n-input 
                class="ma-field end" 
                v-model:value="seriesData.markArea.data[idx][1].xAxis" 
                size="small" 
                placeholder="终点 xAxis，如 10:00" 
              />
              <n-color-picker 
                class="ma-field color" 
                v-model:value="seriesData.markArea.data[idx][0].itemStyle.color" 
                size="small" 
              />
              <div class="mark-area-actions">
                <n-tooltip trigger="hover">
                  <template #trigger>
                    <n-button quaternary circle size="small" type="error" @click="removeMarkArea(idx)">
                      <n-icon size="16"><TrashOutline /></n-icon>
                    </n-button>
                  </template>
                  删除该区域
                </n-tooltip>
              </div>
            </div>
          </div>
        </template>
      </setting-item-box>

      <!-- 标签配置 -->
      <setting-item-box name="标签配置">
        <setting-item name="显示标签">
          <div>
            <n-switch v-model:value="seriesData.label.show" size="small" />
          </div>
        </setting-item>
        <setting-item name="标签位置" v-if="seriesData.label.show">
          <n-select 
            v-model:value="seriesData.label.position" 
            size="small" 
            :options="labelPositionOptions"
          />
        </setting-item>
        <setting-item name="标签颜色" v-if="seriesData.label.show">
          <n-color-picker v-model:value="seriesData.label.color" size="small" />
        </setting-item>
      </setting-item-box>

      <!-- 动画配置 -->
      <setting-item-box name="动画配置">
        <setting-item name="启用动画">
          <div>
            <n-switch v-model:value="seriesData.animation" size="small" />
          </div>
        </setting-item>
        <setting-item name="动画时长" v-if="seriesData.animation">
          <n-input-number 
            v-model:value="seriesData.animationDuration" 
            size="small" 
            :min="0"
            :max="5000"
          />
        </setting-item>
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
import SettingItemBox from '@/components/Pages/ChartItemSetting/SettingItemBox.vue'
import SettingItem from '@/components/Pages/ChartItemSetting/SettingItem.vue'
import ColorPicker from './ColorPicker.vue'
import { getBestTextColor } from '@/utils/colorUtils'
import { TrashOutline } from '@vicons/ionicons5'

interface Props {
  show: boolean
  seriesData: any
  xAxisOptions?: any[]
  yAxisOptions?: any[]
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

const seriesData = ref({
  name: '',
  type: 'line',
  xAxisIndex: 0,
  yAxisIndex: 0,
  datasourceIndex: 0,
  dataField: '',
  itemStyle: {
    color: '#5470c6'
  },
  lineStyle: {
    width: 2
  },
  stack: '',
  smooth: false,
  showSymbol: false,
  label: {
    show: false,
    position: 'top',
    color: '#333'
  },
  symbol: 'circle',
  symbolSize: 10,
  areaStyle: {
    opacity: 0.3
  },
  markArea: {
    data: [] as any[]
  },
  animation: true,
  animationDuration: 1000
})

const seriesTypeOptions = [
  { label: '折线图', value: 'line' },
  { label: '柱状图', value: 'bar' },
  { label: '散点图', value: 'scatter' },
  { label: '面积图', value: 'area' }
]

const labelPositionOptions = [
  { label: '顶部', value: 'top' },
  { label: '底部', value: 'bottom' },
  { label: '左侧', value: 'left' },
  { label: '右侧', value: 'right' },
  { label: '内部', value: 'inside' }
]

const chartTypeOptions = [
  { label: '折线图', value: 'line' },
  { label: '柱状图', value: 'bar' },
  { label: '散点图', value: 'scatter' },
  { label: '面积图', value: 'area' }
]

const symbolOptions = [
  { label: '圆形', value: 'circle' },
  { label: '矩形', value: 'rect' },
  { label: '圆角矩形', value: 'roundRect' },
  { label: '三角形', value: 'triangle' },
  { label: '宝石', value: 'diamond' },
  { label: '标记', value: 'pin' },
  { label: '箭头', value: 'arrow' }
]

const logBaseOptions = [
  { label: '自然对数 (e)', value: 'e' },
  { label: '常用对数 (10)', value: 10 },
  { label: '二进制对数 (2)', value: 2 }
]

const zeroHandlingOptions = [
  { label: '跳过零值和负值', value: 'skip' },
  { label: '替换为指定值', value: 'replace' },
  { label: '使用绝对值', value: 'absolute' }
]
import { parseCSVHeaders, downloadTextFile, readFile } from '@/utils/file'

// 计算字段选项
const fieldOptions = computed(() => {
  if (!props.datasources || !Array.isArray(props.datasources)) {
    console.log('SeriesConfig fieldOptions: no datasources or not array')
    return []
  }
  
  if (seriesData.value.datasourceIndex === undefined || seriesData.value.datasourceIndex === null) {
    return []
  }
  
  const selectedDatasource = props.datasources[seriesData.value.datasourceIndex]
  
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
        console.log('SeriesConfig failed to parse staticData as JSON:', error)
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
  // 检查其他可能的数据结构
  else if (selectedDatasource.data && Array.isArray(selectedDatasource.data) && selectedDatasource.data.length > 0) {
    const firstItem = selectedDatasource.data[0]
    if (firstItem && typeof firstItem === 'object') {
      const keys = Object.keys(firstItem)
      return keys.map(key => ({
        label: key,
        value: key
      }))
    }
  }
  
  console.log('SeriesConfig fieldOptions: no valid data found')
  return []
})

// 计算属性
const isLineType = computed(() => {
  return seriesData.value.type === 'line' || seriesData.value.type === 'area'
})

// 计算颜色值文字的最佳颜色
const colorTextColor = computed(() => {
  return getBestTextColor(seriesData.value.itemStyle.color)
})

// 监听数据变化
watch(() => props.seriesData, (newData) => {
  if (newData) {
    seriesData.value = cloneDeep({
      name: '',
      type: 'line',
      xAxisIndex: 0,
      yAxisIndex: 0,
      datasourceIndex: 0,
      dataField: '',
      itemStyle: {
        color: '#5470c6'
      },
      lineStyle: {
        width: 2
      },
      areaStyle: {
        opacity: 0.3
      },
      markArea: {
        data: [] as any[]
      },
      stack: '',
      smooth: false,
      showSymbol: false,
      label: {
        show: false,
        position: 'top',
        color: '#333'
      },
      animation: true,
      animationDuration: 1000,
      ...newData
    })
  }
}, { immediate: true, deep: true })

const handleCancel = () => {
  emit('update:show', false)
}

const handleConfirm = () => {
  emit('confirm', cloneDeep(seriesData.value))
  emit('update:show', false)
}

// 标注区域操作
const addMarkArea = () => {
  if (!seriesData.value.markArea) {
    seriesData.value.markArea = { data: [] as any[] }
  }
  seriesData.value.markArea.data.push([
    {
      name: 'Mark Area',
      xAxis: '',
      itemStyle: { color: '#d0e3ff' }
    },
    {
      xAxis: ''
    }
  ])
}

// ================= 批量模板下载与导入（仅标注区域） =================
const csvInputRef = ref<HTMLInputElement | null>(null)
const jsonInputRef = ref<HTMLInputElement | null>(null)

const downloadMarkAreaCsvTemplate = () => {
  const header = 'name,start_xAxis,end_xAxis,color\n'
  const example = '区域1,07:30,10:00,#d0e3ff\n'
  downloadTextFile(header + example, 'markArea_template', 'csv')
  window['$message'].success('CSV模板已下载')
}

const downloadMarkAreaJsonTemplate = () => {
  const tpl = [
    { name: '区域1', start_xAxis: '07:30', end_xAxis: '10:00', color: '#d0e3ff' }
  ]
  downloadTextFile(JSON.stringify(tpl, null, 2), 'markArea_template', 'json')
  window['$message'].success('JSON模板已下载')
}

const triggerImport = (type: 'csv' | 'json') => {
  if (type === 'csv') {
    csvInputRef.value?.click()
  } else {
    jsonInputRef.value?.click()
  }
}

const handleImportCsv = async (e: Event) => {
  const input = e.target as HTMLInputElement
  const file = input.files?.[0]
  if (!file) return
  try {
    const raw = String(await readFile(file))
    const text = raw.replace(/\r\n/g, '\n').replace(/\r/g, '\n')
    const lines = text.split(/\n/).filter(l => l.trim())
    if (lines.length < 2) {
      window['$message'].warning('CSV内容为空或缺少数据行')
      return
    }
    // 解析表头，兼容 BOM
    let headers = parseCSVHeaders(text)
    if (!headers || headers.length === 0) {
      headers = lines[0].split(',').map(h => h.trim().replace(/^\uFEFF/, ''))
    } else {
      headers = headers.map(h => h.trim().replace(/^\uFEFF/, ''))
    }
    const idxName = headers.indexOf('name')
    const idxStart = headers.indexOf('start_xAxis')
    const idxEnd = headers.indexOf('end_xAxis')
    const idxColor = headers.indexOf('color')
    if (idxName < 0 || idxStart < 0 || idxEnd < 0) {
      window['$message'].error('CSV模板字段必须包含：name,start_xAxis,end_xAxis[,color]')
      return
    }
    const imported: any[] = []
    for (let i = 1; i < lines.length; i++) {
      const cols = lines[i].split(',').map(c => c.trim())
      const name = (cols[idxName] || '').trim()
      const start_xAxis = (cols[idxStart] || '').trim()
      const end_xAxis = (cols[idxEnd] || '').trim()
      const color = idxColor >= 0 ? (cols[idxColor] || '').trim() : '#d0e3ff'
      if (!start_xAxis || !end_xAxis) continue
      imported.push([
        { name: name || 'Mark Area', xAxis: start_xAxis, itemStyle: { color: color || '#d0e3ff' } },
        { xAxis: end_xAxis }
      ])
    }
    if (!seriesData.value.markArea) {
      seriesData.value.markArea = { data: [] }
    }
    seriesData.value.markArea.data = imported
    window['$message'].success(`已导入 ${imported.length} 个标注区域`)
  } catch (err) {
    window['$message'].error('CSV解析失败，请检查文件内容')
  } finally {
    input.value = ''
  }
}

const handleImportJson = async (e: Event) => {
  const input = e.target as HTMLInputElement
  const file = input.files?.[0]
  if (!file) return
  try {
    const text = String(await readFile(file))
    const arr = JSON.parse(text)
    if (!Array.isArray(arr)) {
      window['$message'].error('JSON内容必须为数组')
      return
    }
    const imported: any[] = []
    for (const item of arr) {
      if (!item) continue
      const name = (item.name || 'Mark Area')
      const start_xAxis = (item.start_xAxis || '').trim?.() || item.start_xAxis || ''
      const end_xAxis = (item.end_xAxis || '').trim?.() || item.end_xAxis || ''
      const color = item.color || '#d0e3ff'
      if (!start_xAxis || !end_xAxis) continue
      imported.push([
        { name, xAxis: start_xAxis, itemStyle: { color } },
        { xAxis: end_xAxis }
      ])
    }
    if (!seriesData.value.markArea) {
      seriesData.value.markArea = { data: [] }
    }
    seriesData.value.markArea.data = imported
    window['$message'].success(`已导入 ${imported.length} 个标注区域`)
  } catch (err) {
    window['$message'].error('JSON解析失败，请检查文件内容')
  } finally {
    input.value = ''
  }
}

const removeMarkArea = (idx: number) => {
  if (seriesData.value.markArea && Array.isArray(seriesData.value.markArea.data)) {
    seriesData.value.markArea.data.splice(idx, 1)
  }
}
</script>

<style lang="scss" scoped>
.series-config-dialog {
  max-height: 500px;
  overflow-y: auto;
}

.color-picker-wrapper {
  width: 100%;
}

.color-preview {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 6px 12px;
  border: 1px solid #404040;
  border-radius: 4px;
  cursor: pointer;
  background: #2a2a2a;
  transition: all 0.2s ease;
  min-height: 32px;

  &:hover {
    border-color: #409eff;
  }

  .color-value {
    font-size: 12px;
    color: #e0e0e0;
    font-family: monospace;
  }
}

.mark-area-item {
  border: 1px dashed #404040;
  border-radius: 6px;
  padding: 6px;
  display: flex;
  align-items: center;
  gap: 8px;
}
.mark-area-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.mark-area-actions {
  margin-left: auto;
}
.ma-field.name {
  flex: 1 1 120px;
  min-width: 100px;
}
.ma-field.start,
.ma-field.end {
  width: 90px;
}
.ma-field.color {
  width: 100px;
}
.label {
  font-size: 12px;
  color: #ccc;
}
</style>