<template>
  <n-modal v-model:show="showModal" preset="dialog" title="容器配置" style="width: 600px;">
    <div class="container-config-dialog">
      <!-- 基本信息 -->
      <setting-item-box name="基本信息">
        <setting-item name="容器名称">
          <n-input v-model:value="containerData.name" size="small" placeholder="容器名称" />
        </setting-item>
      </setting-item-box>

      <!-- 位置配置 -->
      <setting-item-box name="位置配置">
        <setting-item name="左边距">
          <n-input v-model:value="containerData.grid.left" size="small" />
        </setting-item>
        <setting-item name="右边距">
          <n-input v-model:value="containerData.grid.right" size="small" />
        </setting-item>
        <setting-item name="上边距">
          <n-input v-model:value="containerData.grid.top" size="small" />
        </setting-item>
        <setting-item name="高度">
          <n-input v-model:value="containerData.grid.height" size="small" />
        </setting-item>
      </setting-item-box>

      <!-- X轴管理 -->
      <setting-item-box name="X轴管理" :alone="true">
        <div class="container-flex-layout">
          <div class="axis-list flex-item">
            <draggable 
              v-model="containerData.xAxis" 
              item-key="name"
              handle=".drag-handle"
              ghost-class="ghost-item"
              @change="onXAxisOrderChange"
            >
              <template #item="{ element: xAxis, index }">
                <div class="axis-item">
                  <div class="drag-handle">
                    <n-icon size="14">
                      <svg viewBox="0 0 24 24">
                        <path fill="currentColor" d="M9 3h2v2H9V3zm4 0h2v2h-2V3zM9 7h2v2H9V7zm4 0h2v2h-2V7zm-4 4h2v2H9v-2zm4 0h2v2h-2v-2zm-4 4h2v2H9v-2zm4 0h2v2h-2v-2zm-4 4h2v2H9v-2zm4 0h2v2h-2v-2z"/>
                      </svg>
                    </n-icon>
                  </div>
                  <span>{{ getXAxisDisplayName(xAxis, index) }}</span>
                  <div class="axis-actions">
                    <n-button size="small" @click="editXAxis(index)">编辑</n-button>
                    <n-button size="small" type="error" @click="removeXAxis(index)">删除</n-button>
                  </div>
                </div>
              </template>
            </draggable>
          </div>
          <n-button type="primary" size="small" style="width: 80px;" @click="addXAxis">添加X轴</n-button>
        </div>
      </setting-item-box>

      <!-- Y轴管理 -->
      <setting-item-box name="Y轴管理" :alone="true">
        <div class="container-flex-layout">
          <div class="axis-list flex-item">
            <draggable 
              v-model="containerData.yAxis" 
              item-key="name"
              handle=".drag-handle"
              ghost-class="ghost-item"
              @change="onYAxisOrderChange"
            >
              <template #item="{ element: yAxis, index }">
                <div class="axis-item">
                  <div class="drag-handle">
                    <n-icon size="14">
                      <svg viewBox="0 0 24 24">
                        <path fill="currentColor" d="M9 3h2v2H9V3zm4 0h2v2h-2V3zM9 7h2v2H9V7zm4 0h2v2h-2V7zm-4 4h2v2H9v-2zm4 0h2v2h-2v-2zm-4 4h2v2H9v-2zm4 0h2v2h-2v-2zm-4 4h2v2H9v-2zm4 0h2v2h-2v-2z"/>
                      </svg>
                    </n-icon>
                  </div>
                  <span>{{ getYAxisDisplayName(yAxis, index) }}</span>
                  <div class="axis-actions">
                    <n-button size="small" @click="editYAxis(index)">编辑</n-button>
                    <n-button size="small" type="error" @click="removeYAxis(index)">删除</n-button>
                  </div>
                </div>
              </template>
            </draggable>
          </div>
          <n-button type="primary" size="small" style="width: 80px;" @click="addYAxis">添加Y轴</n-button>
        </div>
      </setting-item-box>

      <!-- 系列管理 -->
      <setting-item-box name="系列管理" :alone="true">
        <div class="container-flex-layout">
          <div class="series-list flex-item">
            <draggable 
              v-model="containerData.series" 
              item-key="name"
              handle=".drag-handle"
              ghost-class="ghost-item"
              @change="onSeriesOrderChange"
            >
              <template #item="{ element: series, index }">
                <div class="series-item">
                  <div class="drag-handle">
                    <n-icon size="14">
                      <svg viewBox="0 0 24 24">
                        <path fill="currentColor" d="M9 3h2v2H9V3zm4 0h2v2h-2V3zM9 7h2v2H9V7zm4 0h2v2h-2V7zm-4 4h2v2H9v-2zm4 0h2v2h-2v-2zm-4 4h2v2H9v-2zm4 0h2v2h-2v-2zm-4 4h2v2H9v-2zm4 0h2v2h-2v-2z"/>
                      </svg>
                    </n-icon>
                  </div>
                  <span>{{ getSeriesDisplayName(series, index) }}</span>
                  <div class="series-actions">
                    <n-button size="small" @click="editSeries(index)">编辑</n-button>
                    <n-button size="small" type="error" @click="removeSeries(index)">删除</n-button>
                  </div>
                </div>
              </template>
            </draggable>
          </div>
          <n-button type="primary" size="small" style="width: 80px;" @click="addSeries">添加系列</n-button>
        </div>
      </setting-item-box>
    </div>

    <template #action>
      <n-button @click="handleCancel">取消</n-button>
      <n-button type="primary" @click="handleConfirm">确定</n-button>
    </template>
  </n-modal>

  <!-- X轴配置对话框 -->
  <XAxisConfigDialog 
    v-model:show="xAxisDialogVisible" 
    :axis-data="currentXAxis"
    :datasource-options="datasourceOptions"
    :multi-datasource="multiDatasource"
    :datasources="datasources"
    @confirm="handleXAxisConfirm"
  />

  <!-- Y轴配置对话框 -->
  <YAxisConfigDialog 
    v-model:show="yAxisDialogVisible" 
    :axis-data="currentYAxis"
    :container-data="containerData"
    :datasources="datasources"
    @confirm="handleYAxisConfirm" 
  />

  <!-- 系列配置对话框 -->
  <SeriesConfigDialog 
    v-model:show="seriesDialogVisible" 
    :series-data="currentSeries"
    :x-axis-options="xAxisOptions"
    :y-axis-options="yAxisOptions"
    :datasource-options="datasourceOptions"
    :multi-datasource="multiDatasource"
    :datasources="datasources"
    @confirm="handleSeriesConfirm"
  />
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import cloneDeep from 'lodash/cloneDeep'
import Draggable from 'vuedraggable'
import SettingItemBox from '@/components/Pages/ChartItemSetting/SettingItemBox.vue'
import SettingItem from '@/components/Pages/ChartItemSetting/SettingItem.vue'
import XAxisConfigDialog from './XAxisConfigDialog.vue'
import YAxisConfigDialog from './YAxisConfigDialog.vue'
import SeriesConfigDialog from './SeriesConfigDialog.vue'

interface Props {
  show: boolean
  containerData: any
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

const containerData = ref({})
const xAxisDialogVisible = ref(false)
const yAxisDialogVisible = ref(false)
const seriesDialogVisible = ref(false)
const currentXAxis = ref({})
const currentYAxis = ref({})
const currentSeries = ref({})
const currentEditIndex = ref(-1)

// 计算属性
const xAxisOptions = computed(() => {
  return containerData.value?.xAxis?.map((axis: any, index: number) => ({
    label: axis.name || `X轴 ${index + 1}`,
    value: index
  })) || []
})

const yAxisOptions = computed(() => {
  return containerData.value?.yAxis?.map((axis: any, index: number) => ({
    label: axis.name || `Y轴 ${index + 1}`,
    value: index
  })) || []
})

const getDataSourceName = (datasource: any, index: number) => {
  return datasource.name || `数据源${index + 1}`
}
// 获取系列显示名称
const getSeriesDisplayName = (series: any, index: number) => {
  // 如果有配置名称，直接使用
  if (series.name && series.name.trim()) {
    return series.name
  }
  
  // 如果没有名称，尝试生成"数据源名称.字段名称"格式
  if (props.datasources && series.datasourceIndex !== undefined && series.dataField) {
    const datasource = props.datasources[series.datasourceIndex]
    if (datasource && getDataSourceName(datasource,series.datasourceIndex)) {
      return `${getDataSourceName(datasource,series.datasourceIndex)}.${series.dataField}`
    }
  }
  
  // 如果都没有，使用默认格式
  return `系列 ${index + 1}`
}

// 获取X轴显示名称
const getXAxisDisplayName = (xAxis: any, index: number) => {
  // 如果有配置名称，直接使用
  if (xAxis.name && xAxis.name.trim()) {
    return xAxis.name
  }
  
  // 如果没有名称，尝试显示绑定的数据字段名
  if (xAxis.dataField) {
    if (props.datasources && xAxis.datasourceIndex !== undefined) {
      const datasource = props.datasources[xAxis.datasourceIndex]
      if (datasource && getDataSourceName(datasource,xAxis.datasourceIndex)) {
        return `${getDataSourceName(datasource,xAxis.datasourceIndex)}.${xAxis.dataField}`
      }
    }
    return xAxis.dataField
  }
  
  // 如果都没有，使用默认格式
  return `X轴 ${index + 1}`
}

// 获取Y轴显示名称
const getYAxisDisplayName = (yAxis: any, index: number) => {
  // 如果有配置名称，直接使用
  if (yAxis.name && yAxis.name.trim()) {
    return yAxis.name
  }
  
  // 如果没有名称，尝试显示绑定的系列字段名
  if (containerData.value?.series) {
    const boundSeries = containerData.value.series.find((series: any) => series.yAxisIndex === index)
    if (boundSeries && boundSeries.dataField) {
      if (props.datasources && boundSeries.datasourceIndex !== undefined) {
        const datasource = props.datasources[boundSeries.datasourceIndex]
        if (datasource && getDataSourceName(datasource,boundSeries.datasourceIndex)) {
          return `${getDataSourceName(datasource,boundSeries.datasourceIndex)}.${boundSeries.dataField}`
        }
      }
      return boundSeries.dataField
    }
  }
  
  // 如果都没有，使用默认格式
  return `Y轴 ${index + 1}`
}

// 监听数据变化
watch(() => props.containerData, (newData) => {
  if (newData) {
    containerData.value = cloneDeep(newData)
    // 确保必要的数组属性存在
    if (!containerData.value.xAxis) {
      containerData.value.xAxis = []
    }
    if (!containerData.value.yAxis) {
      containerData.value.yAxis = []
    }
    if (!containerData.value.series) {
      containerData.value.series = []
    }
  } else {
    // 如果没有数据，初始化为默认结构
    containerData.value = {
      xAxis: [],
      yAxis: [],
      series: []
    }
  }
}, { immediate: true, deep: true })

// X轴操作
const addXAxis = () => {
  const newXAxis = {
    name: '',
    type: 'value',
    position: 'bottom',
    offset: 0,
    datasourceIndex: 0,
    dataField: ''
  }
  currentXAxis.value = newXAxis
  currentEditIndex.value = -1
  xAxisDialogVisible.value = true
}

const editXAxis = (index: number) => {
  if (containerData.value?.xAxis?.[index]) {
    currentXAxis.value = cloneDeep(containerData.value.xAxis[index])
    currentEditIndex.value = index
    xAxisDialogVisible.value = true
  }
}

const removeXAxis = (index: number) => {
  if (containerData.value?.xAxis) {
    containerData.value.xAxis.splice(index, 1)
  }
}

const handleXAxisConfirm = (axisData: any) => {
  if (!containerData.value.xAxis) {
    containerData.value.xAxis = []
  }
  if (currentEditIndex.value === -1) {
    containerData.value.xAxis.push(axisData)
  } else {
    containerData.value.xAxis[currentEditIndex.value] = axisData
  }
  xAxisDialogVisible.value = false
}

// Y轴操作
const addYAxis = () => {
  // 根据已有Y轴数量决定默认位置：第一个在左侧，第二个在右侧，后续交替
  const yAxisCount = containerData.value?.yAxis?.length || 0
  const defaultPosition = yAxisCount % 2 === 0 ? 'left' : 'right'
  
  const newYAxis = {
    name: '',
    type: 'value',
    nameRotate: 0,
    position: defaultPosition,
    offset: 0
  }
  currentYAxis.value = newYAxis
  currentEditIndex.value = -1
  yAxisDialogVisible.value = true
}

const editYAxis = (index: number) => {
  if (containerData.value?.yAxis?.[index]) {
    currentYAxis.value = cloneDeep(containerData.value.yAxis[index])
    currentEditIndex.value = index
    yAxisDialogVisible.value = true
  }
}

const removeYAxis = (index: number) => {
  if (containerData.value?.yAxis) {
    containerData.value.yAxis.splice(index, 1)
  }
}

const handleYAxisConfirm = (axisData: any) => {
  if (!containerData.value.yAxis) {
    containerData.value.yAxis = []
  }
  if (currentEditIndex.value === -1) {
    containerData.value.yAxis.push(axisData)
  } else {
    containerData.value.yAxis[currentEditIndex.value] = axisData
  }
  yAxisDialogVisible.value = false
}

// 系列操作
const addSeries = () => {
  const newSeries = {
    name: '',
    type: 'line',
    xAxisIndex: 0,
    yAxisIndex: 0,
    datasourceIndex: 0,
    dataField: ''
  }
  currentSeries.value = newSeries
  currentEditIndex.value = -1
  seriesDialogVisible.value = true
}

const editSeries = (index: number) => {
  if (containerData.value?.series?.[index]) {
    currentSeries.value = cloneDeep(containerData.value.series[index])
    currentEditIndex.value = index
    seriesDialogVisible.value = true
  }
}

const removeSeries = (index: number) => {
  if (containerData.value?.series) {
    containerData.value.series.splice(index, 1)
  }
}

const handleSeriesConfirm = (seriesData: any) => {
  if (!containerData.value.series) {
    containerData.value.series = []
  }
  if (currentEditIndex.value === -1) {
    containerData.value.series.push(seriesData)
  } else {
    containerData.value.series[currentEditIndex.value] = seriesData
  }
  seriesDialogVisible.value = false
}

// 拖拽排序事件处理
const onXAxisOrderChange = () => {
  // X轴顺序改变时触发
  console.log('X轴顺序已更新')
}

const onYAxisOrderChange = () => {
  // Y轴顺序改变时触发
  console.log('Y轴顺序已更新')
}

const onSeriesOrderChange = () => {
  // 系列顺序改变时触发，系列排序越后面对应的图表内容显示越上层
  console.log('系列顺序已更新')
}

// 对话框操作
const handleCancel = () => {
  emit('update:show', false)
}

const handleConfirm = () => {
  emit('confirm', containerData.value)
  emit('update:show', false)
}
</script>

<style lang="scss" scoped>
.container-config-dialog {
  max-height: 500px;
  overflow-y: auto;
}

// 容器管理布局样式
.container-flex-layout {
  display: flex;
  flex-direction: row;
  gap: 0.5rem;
  
  .flex-item {
    flex: 1 1 0%;
  }
}

.axis-list, .series-list {
  margin-bottom: 12px;
  display: flex;
  flex-direction: column;
  flex: 1;
}

.axis-item, .series-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 12px;
  background: #2a2a2a;
  border: 1px solid #404040;
  border-radius: 4px;
  color: #e0e0e0;
  min-width: 0; /* 允许flex项目收缩 */
  margin-bottom: 5px;

  &:last-child {
    margin-bottom: 0;
  }

  .drag-handle {
    display: flex;
    align-items: center;
    margin-right: 8px;
    cursor: grab;
    color: #888;
    flex-shrink: 0; /* 防止拖拽手柄收缩 */
    
    &:hover {
      color: #ccc;
    }
    
    &:active {
      cursor: grabbing;
    }
  }

  span {
    color: #e0e0e0;
    flex: 1;
    margin-right: 8px; /* 减少与右侧按钮的间距 */
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap; /* 防止文本换行 */
  }

  .axis-actions, .series-actions {
    display: flex;
    gap: 4px; /* 减少按钮间距 */
    flex-shrink: 0; /* 防止按钮区域收缩 */
    width: 100px; /* 固定按钮区域宽度 */

    .n-button {
      flex: 1; /* 让按钮撑满可用空间 */
      min-width: 0; /* 允许按钮收缩 */
    }
  }
}

.ghost-item {
  opacity: 0.5;
  background: #404040;
}
</style>