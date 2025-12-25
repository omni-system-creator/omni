<template>
  <div class="advanced-chart-config">

    <!-- 区间缩放 -->
    <collapse-item name="区间缩放">
      <template #header>
        <div style="display: flex; align-items: center; gap: 8px;">
          <n-switch size="small" v-model:value="optionData.dataZoom.show"></n-switch>
        </div>
      </template>
      
      <div class="config-item" v-if="optionData.dataZoom.show">
        <div>缩放类型</div>
        <n-select 
          v-model:value="optionData.dataZoom.type" 
          size="small" 
          :options="dataZoomTypeOptions"
          style="width: 120px;"
        />
      </div>
      <div class="config-item" v-if="optionData.dataZoom.show">
        <div>底边距</div>
        <n-input-number 
          v-model:value="optionData.dataZoom.bottom" 
          size="small" 
          :min="0"
          :max="200"
          :step="5"
          style="width: 120px;"
          placeholder="底边距"
        />
      </div>
    </collapse-item>

    <!-- 提示框 -->
    <collapse-item name="提示框">
      <template #header>
        <div style="display: flex; align-items: center; gap: 8px;">
          <n-switch size="small" v-model:value="optionData.tooltip.show"></n-switch>
        </div>
      </template>
      
      <div class="tooltip-config-grid" v-if="optionData.tooltip.show">
        <div class="config-item">
          <div>联动所有X轴</div>
          <n-switch 
            v-model:value="optionData.tooltip.axisPointer.link" 
            size="small"
          />
        </div>
        <div class="config-item">
          <div>触发方式</div>
          <n-select 
            v-model:value="optionData.tooltip.trigger" 
            size="small" 
            :options="tooltipTriggerOptions"
          />
        </div>
        <div class="config-item">
          <div>背景颜色</div>
          <n-color-picker 
            v-model:value="optionData.tooltip.backgroundColor" 
            size="small"
            :show-alpha="true"
          />
        </div>
        <div class="config-item">
          <div>边框颜色</div>
          <n-color-picker 
            v-model:value="optionData.tooltip.borderColor" 
            size="small"
            :show-alpha="false"
          />
        </div>
        <div class="config-item">
          <div>边框宽度</div>
          <n-input-number 
            v-model:value="optionData.tooltip.borderWidth" 
            size="small" 
            :min="0"
            :max="10"
            :step="1"
            placeholder="边框宽度"
          />
        </div>
        <div class="config-item">
          <div>文字大小</div>
          <n-input-number 
            v-model:value="optionData.tooltip.textStyle.fontSize" 
            size="small" 
            :min="8"
            :max="24"
            :step="1"
            placeholder="字号"
          />
        </div>
        <div class="config-item">
          <div>文字颜色</div>
          <n-color-picker 
            v-model:value="optionData.tooltip.textStyle.color" 
            size="small"
            :show-alpha="false"
          />
        </div>
        <div class="config-item">
          <div>内边距</div>
          <n-input-number 
            v-model:value="optionData.tooltip.padding" 
            size="small" 
            :min="0"
            :max="20"
            :step="1"
            placeholder="内边距"
          />
        </div>
        <div class="config-item">
          
          <n-tooltip trigger="hover">
            <template #trigger>
              <div>
                <div>消息名称</div>
                <n-input 
                  v-model:value="optionData.tooltip.messageName" 
                  size="small" 
                />
              </div>
            </template>
            <n-text>用于将提示点的数据传送出去，使用方式：<br/>window.addEventListener('message', (event) => {<br/>&nbsp;&nbsp;console.log(event.data);<br/>});<br/>其中event.data.type就是这里的消息名称</n-text>
          </n-tooltip>
        </div>
      </div>
    </collapse-item>

    <!-- 图例 -->
    <collapse-item name="图例">
      <template #header>
        <div style="display: flex; align-items: center;">
          <n-switch size="small" v-model:value="optionData.showLegend"></n-switch>
        </div>
      </template>
      
      <div class="legend-config-grid" v-if="optionData.showLegend">
        <div class="config-item">
          <div>图例方向</div>
          <n-select 
            v-model:value="optionData.legend.orient" 
            size="small" 
            :options="legendOrientOptions"
          />
        </div>
        <div class="config-item">
          <div>水平位置</div>
          <n-select 
            v-model:value="optionData.legend.left" 
            size="small" 
            :options="legendHorizontalOptions"
          />
        </div>
        <div class="config-item">
          <div>垂直位置</div>
          <n-select 
            v-model:value="optionData.legend.top" 
            size="small" 
            :options="legendVerticalOptions"
          />
        </div>
        <div class="config-item">
          <div>图标大小</div>
          <n-input-number 
            v-model:value="optionData.legend.itemWidth" 
            size="small" 
            :min="10" 
            :max="50"
            placeholder="宽度"
          />
        </div>
        <div class="config-item">
          <div>图标高度</div>
          <n-input-number 
            v-model:value="optionData.legend.itemHeight" 
            size="small" 
            :min="10" 
            :max="50"
            placeholder="高度"
          />
        </div>
        <div class="config-item">
          <div>文字大小</div>
          <n-input-number 
            v-model:value="optionData.legend.textStyle.fontSize" 
            size="small" 
            :min="8" 
            :max="24"
            placeholder="字号"
          />
        </div>
        <div class="config-item">
          <div>文字颜色</div>
          <n-color-picker 
            v-model:value="optionData.legend.textStyle.color" 
            size="small"
            :show-alpha="false"
          />
        </div>
        <div class="config-item">
          <div>图例间距</div>
          <n-input-number 
            v-model:value="optionData.legend.itemGap" 
            size="small" 
            :min="5" 
            :max="50"
            placeholder="间距"
          />
        </div>
      </div>
    </collapse-item>

    <!-- 多数据源配置 -->
    <collapse-item name="数据源配置" v-if="optionData.multiDatasource">
      <div class="datasource-summary">
        <div class="datasource-info">
          <span v-if="datasourceList.length > 0">
            已配置 {{ datasourceList.length }} 个数据源
          </span>
          <span v-else class="no-datasource-text">未配置数据源</span>
        </div>
        <n-button type="primary" size="small" @click="showDatasourceDialog = true">
          配置数据源
        </n-button>
      </div>
    </collapse-item>

    <!-- 容器配置 -->
    <collapse-item name="容器配置" :expanded="true">
      <template #header>
        <n-button type="primary" size="small" @click="addContainer">添加容器</n-button>
      </template>
      
      <div class="container-list">
        <div v-for="(container, containerIndex) in containerList" :key="containerIndex" class="container-item">
          <div class="container-info">
            <div class="container-header">
              <span class="container-name">{{ container.name || `容器 ${containerIndex + 1}` }}</span>
              <div class="container-actions">
                <n-button size="small" quaternary circle @click="editContainer(containerIndex)" title="配置容器">
                  <template #icon>
                    <n-icon><SettingsOutline /></n-icon>
                  </template>
                </n-button>
                <n-button size="small" quaternary circle type="error" @click="removeContainer(containerIndex)" title="删除容器">
                  <template #icon>
                    <n-icon><TrashOutline /></n-icon>
                  </template>
                </n-button>
              </div>
            </div>
            <div class="container-stats">
              <div class="axis-info">
                <span class="axis-label">X轴:</span>
                <div class="axis-names" :title="getXAxisNames(container)">
                  <div v-for="(name, index) in getXAxisNamesList(container)" :key="index" class="axis-name-item">
                    {{ name }}
                  </div>
                </div>
              </div>
              <div class="axis-info">
                <span class="axis-label">Y轴:</span>
                <div class="axis-names" :title="getYAxisNames(container)">
                  <div v-for="(name, index) in getYAxisNamesList(container)" :key="index" class="axis-name-item">
                    {{ name }}
                  </div>
                </div>
              </div>
              <div class="axis-info">
                <span class="axis-label">系列:</span>
                <div class="axis-names" :title="getSeriesNames(container)">
                  <div v-for="(name, index) in getSeriesNamesList(container)" :key="index" class="axis-name-item">
                    {{ name }}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </collapse-item>
  </div>

  <!-- 对话框组件 -->
  <ContainerConfigDialog
    v-model:show="showContainerDialog"
    :container-data="currentContainerIndex >= 0 ? containerList[currentContainerIndex] : null"
    :datasource-options="datasourceOptions"
    :multi-datasource="optionData.multiDatasource"
    :datasources="datasourceList"
    @confirm="handleContainerConfirm"
  />

  <XAxisConfigDialog
    v-model:show="showXAxisDialog"
    :axis-data="currentContainerIndex >= 0 && currentXAxisIndex >= 0 ? containerList[currentContainerIndex].xAxis[currentXAxisIndex] : null"
    :datasource-options="datasourceOptions"
    :multi-datasource="optionData.multiDatasource"
    :datasources="datasourceList"
    @confirm="handleXAxisConfirm"
  />

  <YAxisConfigDialog
    v-model:show="showYAxisDialog"
    :axis-data="currentContainerIndex >= 0 && currentYAxisIndex >= 0 ? containerList[currentContainerIndex].yAxis[currentYAxisIndex] : null"
    @confirm="handleYAxisConfirm"
  />

  <SeriesConfigDialog
    v-model:show="showSeriesDialog"
    :series-data="currentContainerIndex >= 0 && currentSeriesIndex >= 0 ? containerList[currentContainerIndex].series[currentSeriesIndex] : null"
    :x-axis-options="currentContainerIndex >= 0 ? getXAxisOptions(currentContainerIndex) : []"
    :y-axis-options="currentContainerIndex >= 0 ? getYAxisOptions(currentContainerIndex) : []"
    :datasource-options="datasourceOptions"
    :multi-datasource="optionData.multiDatasource"
    @confirm="handleSeriesConfirm"
  />

  <!-- 数据源配置对话框 -->
  <DatasourceConfigDialog
    v-model="showDatasourceDialog"
    :datasources="datasourceList"
    @update:datasources="handleDatasourceUpdate"
    @confirm="handleDatasourceConfirm"
  />
</template>

<script setup lang="ts">
import { ref, computed, watch, PropType } from 'vue'
import cloneDeep from 'lodash/cloneDeep'
import { CollapseItem, SettingItemBox, SettingItem } from '@/components/Pages/ChartItemSetting'
import { NInput, NInputNumber, NSelect, NButton, NModal, NCard, NIcon } from 'naive-ui'
import { SettingsOutline, TrashOutline } from '@vicons/ionicons5'
import ContainerConfigDialog from './components/ContainerConfigDialog.vue'
import XAxisConfigDialog from './components/XAxisConfigDialog.vue'
import YAxisConfigDialog from './components/YAxisConfigDialog.vue'
import SeriesConfigDialog from './components/SeriesConfigDialog.vue'
import DatasourceConfigDialog from './components/DatasourceConfigDialog.vue'
import { GlobalThemeJsonType } from '@/settings/chartThemes'

type AdvancedChartOptionType = GlobalThemeJsonType & {
  legend: any
  tooltip: any
  dataZoom: any
  showLegend: boolean
  multiDatasource: boolean
  containers: any[]
  datasources: any[]
}

const props = defineProps({
  optionData: {
    type: Object as PropType<AdvancedChartOptionType>,
    required: true
  }
})

// 数据源对话框显示状态
const showDatasourceDialog = ref(false)

// 数据源配置
const datasourceList = computed({
  get: () => props.optionData.datasources || [],
  set: (value) => {
    props.optionData.datasources = value
    updateHandle()
  }
})

// 容器配置
const containerList = computed({
  get: () => props.optionData.containers || [],
  set: (value) => {
    props.optionData.containers = value
    updateHandle()
  }
})

// 数据源类型选项
const datasourceTypeOptions = [
  { label: 'API接口', value: 'api' },
  { label: '静态数据', value: 'static' },
  { label: 'WebSocket', value: 'websocket' }
]

// X轴位置选项
const xAxisPositionOptions = [
  { label: '底部', value: 'bottom' },
  { label: '顶部', value: 'top' }
]

// Y轴位置选项
const yAxisPositionOptions = [
  { label: '左侧', value: 'left' },
  { label: '右侧', value: 'right' }
]

// 系列类型选项
const seriesTypeOptions = [
  { label: '折线图', value: 'line' },
  { label: '柱状图', value: 'bar' },
  { label: '散点图', value: 'scatter' },
  { label: '面积图', value: 'area' }
]

// 缩放类型选项
const dataZoomTypeOptions = [
  { label: '滑动条', value: 'slider' },
  { label: '内置', value: 'inside' },
  { label: '两者都有', value: 'both' }
]

// 图例方向选项
const legendOrientOptions = [
  { label: '水平', value: 'horizontal' },
  { label: '垂直', value: 'vertical' }
]

// 图例水平位置选项
const legendHorizontalOptions = [
  { label: '左侧', value: 'left' },
  { label: '居中', value: 'center' },
  { label: '右侧', value: 'right' }
]

// 图例垂直位置选项
const legendVerticalOptions = [
  { label: '顶部', value: 'top' },
  { label: '中间', value: 'middle' },
  { label: '底部', value: 'bottom' }
]

// 提示框触发方式选项
const tooltipTriggerOptions = [
  { label: '数据项', value: 'item' },
  { label: '坐标轴', value: 'axis' },
  { label: '无', value: 'none' }
]

// 数据源选项
const datasourceOptions = computed(() => {
  return datasourceList.value.map((item, index) => ({
    label: item.name || `数据源${index + 1}`,
    value: index
  }))
})

// 数据源对话框处理
const handleDatasourceUpdate = (newDatasources: any[]) => {
  datasourceList.value = newDatasources
}

const handleDatasourceConfirm = (newDatasources: any[]) => {
  datasourceList.value = newDatasources
}

// 添加容器
const addContainer = () => {
  const newContainer = {
    name: `容器${containerList.value.length + 1}`,
    grid: {
      left: '10%',
      right: '10%',
      top: '10%',
      height: '30%'
    },
    xAxis: [{
      name: 'X轴1',
      position: 'bottom',
      offset: 0,
      datasourceIndex: 0,
      dataField: 'x'
    }],
    yAxis: [{
      name: 'Y轴1',
      position: 'left',
      offset: 0
    }],
    series: []
  }
  containerList.value.push(newContainer)
}

// 删除容器
const removeContainer = (containerIndex: number) => {
  containerList.value.splice(containerIndex, 1)
}

// 添加X轴
const addXAxis = (containerIndex: number) => {
  const container = containerList.value[containerIndex]
  const newXAxis = {
    name: `X轴${container.xAxis.length + 1}`,
    position: 'bottom',
    offset: 0,
    datasourceIndex: 0,
    dataField: 'x'
  }
  container.xAxis.push(newXAxis)
  updateHandle()
}

// 删除X轴
const removeXAxis = (containerIndex: number, xIndex: number) => {
  containerList.value[containerIndex].xAxis.splice(xIndex, 1)
  updateHandle()
}

// 添加Y轴
const addYAxis = (containerIndex: number) => {
  const container = containerList.value[containerIndex]
  // 根据已有Y轴数量决定默认位置：第一个在左侧，第二个在右侧，后续交替
  const yAxisCount = container.yAxis.length
  const defaultPosition = yAxisCount % 2 === 0 ? 'left' : 'right'
  
  const newYAxis = {
    name: `Y轴${yAxisCount + 1}`,
    position: defaultPosition,
    offset: 0
  }
  container.yAxis.push(newYAxis)
  updateHandle()
}

// 删除Y轴
const removeYAxis = (containerIndex: number, yIndex: number) => {
  containerList.value[containerIndex].yAxis.splice(yIndex, 1)
  updateHandle()
}

// 添加系列
const addSeries = (containerIndex: number) => {
  const container = containerList.value[containerIndex]
  const newSeries = {
    name: `系列${container.series.length + 1}`,
    type: 'line',
    xAxisIndex: 0,
    yAxisIndex: 0,
    datasourceIndex: 0,
    dataField: 'y'
  }
  container.series.push(newSeries)
  updateHandle()
}

// 删除系列
const removeSeries = (containerIndex: number, seriesIndex: number) => {
  containerList.value[containerIndex].series.splice(seriesIndex, 1)
  updateHandle()
}

// 获取X轴选项
const getXAxisOptions = (containerIndex: number) => {
  const container = containerList.value[containerIndex]
  if (!container || !container.xAxis || !Array.isArray(container.xAxis)) {
    return []
  }
  return container.xAxis.map((axis: any, index: number) => ({
    label: axis.name || `X轴${index + 1}`,
    value: index
  }))
}

// 获取Y轴选项
const getYAxisOptions = (containerIndex: number) => {
  const container = containerList.value[containerIndex]
  if (!container || !container.yAxis || !Array.isArray(container.yAxis)) {
    return []
  }
  return container.yAxis.map((axis: any, index: number) => ({
    label: axis.name || `Y轴${index + 1}`,
    value: index
  }))
}

const getDataSourceName = (datasource: any, index: number) => {
  return datasource.name || `数据源${index + 1}`
}

// 获取X轴名称列表（数组格式）
const getXAxisNamesList = (container: any) => {
  if (!container.xAxis || container.xAxis.length === 0) {
    return ['无']
  }
  
  return container.xAxis.map((axis: any, index: number) => {
    // 如果有配置名称，直接使用
    if (axis.name && axis.name.trim()) {
      return axis.name
    }
    
    // 如果没有名称，尝试显示绑定的数据字段名
    if (axis.dataField) {
      if (datasourceList.value && axis.datasourceIndex !== undefined) {
        const datasource = datasourceList.value[axis.datasourceIndex]
        if (datasource && getDataSourceName(datasource, axis.datasourceIndex)) {
          return `${getDataSourceName(datasource, axis.datasourceIndex)}.${axis.dataField}`
        }
      }
      return axis.dataField
    }
    
    // 如果都没有，使用默认格式
    return `X轴${index + 1}`
  })
}

// 获取X轴名称列表
const getXAxisNames = (container: any) => {
  return getXAxisNamesList(container).join(', ')
}

// 获取Y轴名称列表（数组格式）
const getYAxisNamesList = (container: any) => {
  if (!container.yAxis || container.yAxis.length === 0) {
    return ['无']
  }
  
  return container.yAxis.map((axis: any, index: number) => {
    // 如果有配置名称，直接使用
    if (axis.name && axis.name.trim()) {
      return axis.name
    }
    
    // 如果没有名称，尝试显示绑定的系列字段名
    if (container.series) {
      const boundSeries = container.series.find((series: any) => series.yAxisIndex === index)
      if (boundSeries && boundSeries.dataField) {
        if (datasourceList.value && boundSeries.datasourceIndex !== undefined) {
          const datasource = datasourceList.value[boundSeries.datasourceIndex]
          if (datasource && getDataSourceName(datasource, boundSeries.datasourceIndex)) {
            return `${getDataSourceName(datasource, boundSeries.datasourceIndex)}.${boundSeries.dataField}`
          }
        }
        return boundSeries.dataField
      }
    }
    
    // 如果都没有，使用默认格式
    return `Y轴${index + 1}`
  })
}

// 获取Y轴名称列表
const getYAxisNames = (container: any) => {
  return getYAxisNamesList(container).join(', ')
}

// 获取系列名称列表（数组格式）
const getSeriesNamesList = (container: any) => {
  if (!container.series || container.series.length === 0) {
    return ['无']
  }
  
  return container.series.map((series: any, index: number) => {
    // 如果有配置名称，直接使用
    if (series.name && series.name.trim()) {
      return series.name
    }
    
    // 如果没有名称，尝试生成"数据源名称.字段名称"格式
    if (datasourceList.value && series.datasourceIndex !== undefined && series.dataField) {
      const datasource = datasourceList.value[series.datasourceIndex]
      if (datasource && getDataSourceName(datasource, series.datasourceIndex)) {
        return `${getDataSourceName(datasource, series.datasourceIndex)}.${series.dataField}`
      }
    }
    
    // 如果只有字段名，直接显示字段名
    if (series.dataField) {
      return series.dataField
    }
    
    // 如果都没有，使用默认格式
    return `系列${index + 1}`
  })
}

// 获取系列名称列表
const getSeriesNames = (container: any) => {
  return getSeriesNamesList(container).join(', ')
}

// 初始化数据结构
const initializeData = () => {
  if (!props.optionData.containers) {
    props.optionData.containers = []
  }
  if (!props.optionData.datasources) {
    props.optionData.datasources = []
  }
  
  // 初始化tooltip配置
  if (!props.optionData.tooltip) {
    props.optionData.tooltip = {
      show: true,
      trigger: 'axis',
      backgroundColor: 'rgba(50,50,50,0.7)',
      borderColor: '#333',
      borderWidth: 0,
      textStyle: {
        color: '#fff',
        fontSize: 12
      },
      padding: 10,
      axisPointer: {
        link: false
      }
    }
  }
  
  // 处理dataZoom配置，支持数组和对象两种格式
  if (!props.optionData.dataZoom) {
    props.optionData.dataZoom = { 
      show: false,
      type: 'slider',
      start: 0,
      end: 100,
      bottom: 20
    }
  } else if (Array.isArray(props.optionData.dataZoom)) {
    // 如果是数组格式，转换为对象格式供配置面板使用
    const sliderConfig = props.optionData.dataZoom.find(item => item.type === 'slider' || !item.type)
    if (sliderConfig) {
      props.optionData.dataZoom = {
        show: sliderConfig.show !== false,
        type: sliderConfig.type || 'slider',
        start: sliderConfig.start || 0,
        end: sliderConfig.end || 100,
        realtime: sliderConfig.realtime !== false,
        bottom: sliderConfig.bottom || 20
      }
    } else {
      // 如果没有slider配置，创建默认配置
      props.optionData.dataZoom = { 
        show: true,
        type: 'slider',
        start: 0,
        end: 100,
        realtime: true,
        bottom: 20
      }
    }
  } else {
    // 确保现有的dataZoom对象配置有完整的属性
    if (props.optionData.dataZoom.type === undefined) {
      props.optionData.dataZoom.type = 'slider'
    }
    if (props.optionData.dataZoom.start === undefined) {
      props.optionData.dataZoom.start = 0
    }
    if (props.optionData.dataZoom.end === undefined) {
      props.optionData.dataZoom.end = 100
    }
    if (props.optionData.dataZoom.realtime === undefined) {
      props.optionData.dataZoom.realtime = true
    }
    if (props.optionData.dataZoom.bottom === undefined) {
      props.optionData.dataZoom.bottom = 20
    }
  }
  if (!props.optionData.legend) {
    props.optionData.legend = {
      orient: 'horizontal'
    }
  }
}

// 更新处理
const updateHandle = () => {
  // 由于 props.optionData 是响应式的，不需要手动更新 targetData
}

// 对话框状态
const showContainerDialog = ref(false)
const showXAxisDialog = ref(false)
const showYAxisDialog = ref(false)
const showSeriesDialog = ref(false)

// 当前编辑的索引
const currentContainerIndex = ref(-1)
const currentXAxisIndex = ref(-1)
const currentYAxisIndex = ref(-1)
const currentSeriesIndex = ref(-1)

// 编辑容器
const editContainer = (containerIndex: number) => {
  currentContainerIndex.value = containerIndex
  showContainerDialog.value = true
}

// 编辑X轴
const editXAxis = (containerIndex: number, xAxisIndex: number) => {
  currentContainerIndex.value = containerIndex
  currentXAxisIndex.value = xAxisIndex
  showXAxisDialog.value = true
}

// 编辑Y轴
const editYAxis = (containerIndex: number, yAxisIndex: number) => {
  currentContainerIndex.value = containerIndex
  currentYAxisIndex.value = yAxisIndex
  showYAxisDialog.value = true
}

// 编辑系列
const editSeries = (containerIndex: number, seriesIndex: number) => {
  currentContainerIndex.value = containerIndex
  currentSeriesIndex.value = seriesIndex
  showSeriesDialog.value = true
}

// 处理对话框确认
const handleContainerConfirm = (containerData: any) => {
  if (currentContainerIndex.value >= 0) {
    containerList.value[currentContainerIndex.value] = containerData
  }
  showContainerDialog.value = false
}

const handleXAxisConfirm = (xAxisData: any) => {
  if (currentContainerIndex.value >= 0 && currentXAxisIndex.value >= 0) {
    containerList.value[currentContainerIndex.value].xAxis[currentXAxisIndex.value] = xAxisData
  }
  showXAxisDialog.value = false
}

const handleYAxisConfirm = (yAxisData: any) => {
  if (currentContainerIndex.value >= 0 && currentYAxisIndex.value >= 0) {
    containerList.value[currentContainerIndex.value].yAxis[currentYAxisIndex.value] = yAxisData
  }
  showYAxisDialog.value = false
}

const handleSeriesConfirm = (seriesData: any) => {
  if (currentContainerIndex.value >= 0 && currentSeriesIndex.value >= 0) {
    containerList.value[currentContainerIndex.value].series[currentSeriesIndex.value] = seriesData
  }
  showSeriesDialog.value = false
}

// 监听变化
watch(() => props.optionData, () => {
  initializeData()
}, { immediate: true, deep: true })
</script>

<style lang="scss" scoped>
.advanced-chart-config {
  width: 100%;
  max-width: 348px;
}

.config-item {
  display: flex;
  align-items: center;
  padding: 8px 0;
  font-size: 12px;
}

.datasource-summary {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 0;
}

.datasource-info {
  font-size: 13px;
  color: #666;
}

.no-datasource-text {
  color: #999;
}

.container-list {
  display: flex;
  flex-direction: column;
  --border-color: #666; 
  gap: 8px;
  margin-left: -12px;
  margin-right: -12px;
  .container-name {
    color: #999999;
  }
}

.container-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  border: 1px solid var(--border-color);
  border-radius: 6px;
  padding-left: 12px;
  padding-right: 12px;
  padding-top: 6px;
  padding-bottom: 6px;
  background: var(--bg-color-secondary);
}

.container-info {
  flex: 1;
}

.container-name {
  font-weight: 500;
  margin-bottom: 4px;
  display: block;
}

.container-stats {
  display: flex;
  flex-direction: column;
  gap: 4px;
  font-size: 12px;
  color: var(--text-color-3);
}

.axis-info {
  display: flex;
  align-items: flex-start;
  gap: 6px;
}

.axis-label {
  min-width: 32px;
  font-weight: 500;
  color: var(--text-color-2);
  flex-shrink: 0;
}

.axis-names {
  flex: 1;
  line-height: 1.4;
}

.axis-name-item {
  word-break: break-all;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  margin-bottom: 2px;
}

.axis-name-item:last-child {
  margin-bottom: 0;
}

.container-actions {
  display: flex;
  gap: 4px;
  align-items: center;
}

.container-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
  margin-bottom: 8px;
}

.container-name {
  font-weight: 500;
  color: #333;
}

.container-header .n-input {
  flex: 1;
}

.axis-config {
  margin-bottom: 8px;
}

.axis-header {
  display: flex;
  gap: 8px;
  align-items: center;
  width: 100%;
}

.axis-header .n-input {
  flex: 1;
}

.series-config {
  margin-bottom: 8px;
}

.series-header {
  display: flex;
  gap: 8px;
  align-items: center;
  width: 100%;
}

.series-header .n-input {
  flex: 1;
}

.zoom-range {
  display: flex;
  align-items: center;
  gap: 4px;
}

.zoom-range span {
  font-size: 11px;
  color: #666;
}

/* 优化小尺寸下的布局 */
:deep(.n-collapse-item__header) {
  padding: 8px 12px;
  font-size: 12px;
}

:deep(.n-collapse-item__content-wrapper) {
  padding: 0 12px 12px;
}

:deep(.n-button) {
  font-size: 11px;
  padding: 4px 8px;
}

:deep(.n-input) {
  font-size: 11px;
}

:deep(.n-select) {
  font-size: 11px;
}

:deep(.n-input-number) {
  font-size: 11px;
}

/* 设置项布局优化 */
:deep(.setting-item-box) {
  margin-bottom: 8px;
}

:deep(.setting-item) {
  margin-bottom: 6px;
}

:deep(.setting-item .setting-item-label) {
  font-size: 11px;
}

/* 提示框配置布局 */
.tooltip-config-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 6px;
}

.tooltip-config-grid .config-item {
  margin-bottom: 0;
  display: flex;
  align-items: flex-start;
  flex-direction: column;
  gap: 6px;
  padding: 2px 0;
}

.tooltip-config-grid .config-item > div:first-child {
  font-size: 12px;
  color: #666;
  margin-bottom: 0;
}

/* 图例配置布局 */
.legend-config-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 6px;
}

.legend-config-grid .config-item {
  margin-bottom: 0;
  display: flex;
  align-items: flex-start;
  flex-direction: column;
  gap: 6px;
  padding: 2px 0;
}

.legend-config-grid .config-item > div:first-child {
  font-size: 12px;
  color: #666;
  margin-bottom: 0;
}
</style>
