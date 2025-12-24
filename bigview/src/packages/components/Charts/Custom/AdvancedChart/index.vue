<template>
  <v-chart
    ref="vChartRef"
    :init-options="initOptions"
    :theme="themeColor"
    :option="option"
    :update-options="{
      replaceMerge: replaceMergeArr
    }"
    @datazoom="onDataZoomChange"
    autoresize
  ></v-chart>
</template>

<script setup lang="ts">
import { ref, computed, watch, PropType, nextTick } from 'vue'
import VChart from 'vue-echarts'
import { isObject, cloneDeep } from 'lodash'
import { useCanvasInitOptions } from '@/hooks/useCanvasInitOptions.hook'
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
//引入柱状图 折线图 散点图
import { BarChart, LineChart, ScatterChart } from 'echarts/charts'
import config, { includes, barSeriesItem, lineSeriesItem } from './config'
import { mergeTheme } from '@/packages/public/chart'
import { useChartDataFetch } from '@/hooks'
import { useChartEditStore } from '@/store/modules/chartEditStore/chartEditStore'
import { isPreview } from '@/utils'
import { DatasetComponent, GridComponent, TooltipComponent, LegendComponent } from 'echarts/components'
import { color } from 'html2canvas/dist/types/css/types/color'

const props = defineProps({
  themeSetting: {
    type: Object,
    required: true
  },
  themeColor: {
    type: Object,
    required: true
  },
  chartConfig: {
    type: Object as PropType<config>,
    required: true
  }
})

const initOptions = useCanvasInitOptions(props.chartConfig.option, props.themeSetting)

use([DatasetComponent, CanvasRenderer, BarChart, LineChart, ScatterChart, GridComponent, TooltipComponent, LegendComponent])

const replaceMergeArr = ref<string[]>()

const vChartRef = ref<typeof VChart | null>(null)

const fileDataCache = ref<Record<string, any>>({})
const workflowDataCache = ref<Record<string, any>>({})
// 存储每个taskId对应的AbortController
const abortControllers = ref<Record<string, AbortController>>({})

// dataZoom状态缓存
const dataZoomState = ref<{start?: number, end?: number, startValue?: any, endValue?: any}>({})

// xAxis原始min/max值缓存（当dataZoom为0-100时的值）
const xAxisOriginalRange = ref<Record<number, {min?: number, max?: number}>>({})

const getDataSourceName = (datasource: any, index: number) => {
  return datasource.name || `数据源${index + 1}`
}

const getUsedFields = (datasourceIndex: number) => {
// 获取用到了的field
  const usedFields = new Set<string>()
  const baseOption = cloneDeep(props.chartConfig.option)
  // 遍历所有容器，收集X轴和系列使用的字段
  baseOption.containers.forEach((container: any) => {
    container.xAxis?.forEach((xAxis: any) => {
      if (xAxis.dataField && xAxis.datasourceIndex === datasourceIndex && !usedFields.has(xAxis.dataField)) {
        usedFields.add(xAxis.dataField)
      }
    })
    container.series?.forEach((series: any) => {
      if (series.dataField && series.datasourceIndex === datasourceIndex && !usedFields.has(series.dataField)) {
        usedFields.add(series.dataField)
      }
    })
  })
  return Array.from(usedFields)
}

const option = computed(() => {
  const baseOption = cloneDeep(props.chartConfig.option)
  console.log('baseOption', baseOption)
  if (!baseOption.containers || !Array.isArray(baseOption.containers) || baseOption.containers.length === 0) {
    return mergeTheme(baseOption, props.themeSetting, includes)
  }

  if (baseOption.datasources && Array.isArray(baseOption.datasources)) {
    baseOption.datasources.forEach((datasource: any, datasourceIndex: number) => {
      if (datasource.type === 'static-json' && datasource.staticData && !datasource.data) {
        try {
          datasource.data = JSON.parse(datasource.staticData)
        } catch (error) {
          datasource.data = []
        }
      }
      else if (datasource.type === 'static-csv' && datasource.csvData && !datasource.data) {
        try {
          // 解析CSV数据为JSON格式
          const lines = datasource.csvData.trim().split('\n')
          if (lines.length > 1) {
            const headers = lines[0].split(',').map((h: string) => h.trim())
            const data = lines.slice(1).map((line: string) => {
              const values = line.split(',').map((v: string) => v.trim())
              const obj: any = {}
              headers.forEach((header: string, index: number) => {
                obj[header] = values[index] || ''
              })
              return obj
            })
            datasource.data = data
          } else {
            datasource.data = []
          }
        } catch (error) {
          console.error('静态CSV数据解析失败:', error)
          datasource.data = []
        }
      }
      else if ((datasource.type === 'file-json' || datasource.type === 'file-csv') && datasource.filePath) {
        if (fileDataCache.value[datasource.filePath]) {
          datasource.data = fileDataCache.value[datasource.filePath]
        } else {
          datasource.data = []
        }
      }
      else if ((datasource.type === 'workflow-json' || datasource.type === 'workflow-csv') && datasource.workflowInstance) {
        if (workflowDataCache.value[datasourceIndex+'']) {
          datasource.data = workflowDataCache.value[datasourceIndex+'']
        } else {
          datasource.data = []
        }
      }
      else if ((datasource.type === 'api-json' || datasource.type === 'api-csv') && datasource.url && !datasource.data) {
         datasource.data = []
       }
    })
  }

  const echartsOption: any = {
    grid: [],
    xAxis: [],
    yAxis: [],
    series: []
  }

  if (baseOption.tooltip?.show) {
    echartsOption.axisPointer = {
      link: baseOption.tooltip.axisPointer?.link ? [{ xAxisIndex: 'all' }] : []
    }
    echartsOption.tooltip = {
      show: true,
      trigger: baseOption.tooltip.trigger || 'axis',
      backgroundColor: baseOption.tooltip.backgroundColor || 'rgba(50,50,50,0.7)',
      borderColor: baseOption.tooltip.borderColor || '#333',
      borderWidth: baseOption.tooltip.borderWidth || 0,
      textStyle: {
        color: baseOption.tooltip.textStyle?.color || '#fff',
        fontSize: baseOption.tooltip.textStyle?.fontSize || 12
      },
      padding: baseOption.tooltip.padding || 10,
      formatter: function (params: any[], ticket: string, callback: Function) {
        if (params.length === 0) {
          return "";
        }
        // 获取当前 X 轴位置的所有原始数据
        var currentXValue = params[0]?.axisValue;
        var allDataAtCurrentX: any = {};
        
        // 对于对数轴和数值轴，需要从原始数据中获取正确的X值
        if (params[0] && Array.isArray(params[0].value) && params[0].value.length === 2) {
          // 如果是坐标对数据，使用坐标对中的X值
          currentXValue = params[0].value[0];
        }
        
        // 遍历所有数据源，查找当前 X 轴位置的数据
        if (baseOption.datasources && Array.isArray(baseOption.datasources)) {
          baseOption.datasources.forEach((datasource: any, dsIndex: number) => {
            if (datasource.data && Array.isArray(datasource.data)) {
              // 查找匹配当前 X 轴值的数据行
              var matchingRow = datasource.data.find((row: any) => {
                // 根据数据源的 X 轴字段查找匹配的行
                var xField = datasource.xField || 'x'; // 优先使用配置的xField，否则使用'x'
                return String(row[xField]) === String(currentXValue);
              });
              
              if (matchingRow) {
                allDataAtCurrentX[`${getDataSourceName(datasource,dsIndex)}`] = matchingRow;
              }
            }
          });
        }

        if (baseOption.tooltip.messageName) {
          window.postMessage({
            type: baseOption.tooltip.messageName,
            data: params.reduce((acc, p) => {
              // 正确处理坐标对数据
              var value = p.value;
              if (Array.isArray(value) && value.length === 2) {
                acc[p.seriesName] = { x: value[0], y: value[1] };
              } else {
                acc[p.seriesName] = value;
              }
              return acc;
            }, {}),
            rawData: allDataAtCurrentX
          }, '*');
        }
        
        var res = '<div style="line-height:25px;margin:-5px 0;">';
        if (params.length > 0) {
          var firstParam = params[0];
          var xAxisName = firstParam.axisId ? firstParam.axisId.replace(/^\u0000/g, '').replace(/\u0000\d+$/g, '') : 'X轴';
          
          // 正确显示X轴值
          var xValue = firstParam.axisValue;
          if (Array.isArray(firstParam.value) && firstParam.value.length === 2) {
            xValue = firstParam.value[0];
          }
          res += xAxisName + ': ' + xValue + '<hr/>';
        }
        params.forEach(function (param) {
          var displayValue = param.value;
          // 如果是坐标对数据，只显示Y值
          if (Array.isArray(param.value) && param.value.length === 2) {
            displayValue = param.value[1];
          }
          res += param.marker + ' ' + param.seriesName + ': ' + displayValue + '<br/>';
        });
        res += '</div>';
        return res.trim();
      }
    }
  } else {
    echartsOption.tooltip = {
      show: false
    }
    console.log('提示框已关闭')
  }

  // 处理图例配置
  if (baseOption.showLegend) {
    // 收集所有系列名称并去重
    const allSeriesNames = new Set<string>()
    
    baseOption.containers.forEach((container, index) => {
      if (container.series && Array.isArray(container.series)) {
        container.series.forEach((series: any, seriesIndex) => {
          
          // 如果系列名称为空，使用数据字段名或默认名称
          let seriesName = series.name
          if (!seriesName || seriesName.trim() === '') {
            if (series.dataField) {
              seriesName = series.dataField
            } else {
              seriesName = `${series.type || '系列'} ${index + 1}-${seriesIndex + 1}`
            }
            // 更新系列名称
            series.name = seriesName
          }
          
          allSeriesNames.add(seriesName)
        })
      }
    })
    
    const legendData = Array.from(allSeriesNames)
    
    echartsOption.legend = {
      show: true,
      orient: baseOption.legend?.orient || 'horizontal',
      left: baseOption.legend?.left || 'center',
      top: baseOption.legend?.top || 'top',
      itemWidth: baseOption.legend?.itemWidth || 25,
      itemHeight: baseOption.legend?.itemHeight || 14,
      itemGap: baseOption.legend?.itemGap || 10,
      textStyle: {
        fontSize: baseOption.legend?.textStyle?.fontSize || 12,
        color: baseOption.legend?.textStyle?.color || '#333'
      },
      data: legendData // 添加去重后的系列名称数据
    }
    
  }

  // 处理数据缩放配置
  if (baseOption.dataZoom?.show) {
    const dataZoomConfig = []
    
    // 计算所有 xAxis 的全局索引数量（跨容器累加）
    const totalXAxisCount = baseOption.containers.reduce((sum: number, c: any) => sum + (c.xAxis?.length || 0), 0)
    const allXAxisIndices = Array.from({ length: totalXAxisCount }, (_, i) => i)

    // 计算缩放尺的位置，基于所有容器的最左和最右边距对齐
    let minLeft = '100%'
    let minRight = '100%'
    let hasPixelValues = false
    
    // 遍历所有容器，找到最左和最右的边距
    baseOption.containers.forEach((container: any) => {
      const grid = container.grid || { left: '10%', right: '10%' }
      
      // 处理百分比格式的left值
      if (typeof grid.left === 'string' && grid.left.includes('%')) {
        const leftPercent = parseFloat(grid.left.replace('%', ''))
        const currentMinLeft = parseFloat((minLeft as string).replace('%', ''))
        if (leftPercent < currentMinLeft) {
          minLeft = grid.left
        }
      }
      // 处理像素格式的left值
      else if (typeof grid.left === 'string' && (grid.left.includes('px') || !isNaN(Number(grid.left)))) {
        hasPixelValues = true
        const leftPixel = parseFloat(grid.left.toString().replace('px', ''))
        const currentMinLeftPixel = minLeft === '100%' ? Infinity : parseFloat((minLeft as string).toString().replace('px', ''))
        if (leftPixel < currentMinLeftPixel) {
          minLeft = leftPixel + 'px'
        }
      }
      
      // 处理百分比格式的right值
      if (typeof grid.right === 'string' && grid.right.includes('%')) {
        const rightPercent = parseFloat(grid.right.replace('%', ''))
        const currentMinRight = parseFloat((minRight as string).replace('%', ''))
        if (rightPercent < currentMinRight) {
          minRight = grid.right
        }
      }
      // 处理像素格式的right值
      else if (typeof grid.right === 'string' && (grid.right.includes('px') || !isNaN(Number(grid.right)))) {
        hasPixelValues = true
        const rightPixel = parseFloat(grid.right.toString().replace('px', ''))
        const currentMinRightPixel = minRight === '100%' ? Infinity : parseFloat((minRight as string).toString().replace('px', ''))
        if (rightPixel < currentMinRightPixel) {
          minRight = rightPixel + 'px'
        }
      }
    })
    
    // 如果有像素值但初始值还是百分比，则重置为合理的像素值
    if (hasPixelValues) {
      if (minLeft === '100%') minLeft = '60px'
      if (minRight === '100%') minRight = '60px'
    }
    
    // 根据缩放类型添加配置
    if (baseOption.dataZoom.type === 'slider' || baseOption.dataZoom.type === 'both') {
      dataZoomConfig.push({
        type: 'slider',
        show: true,
        realtime: baseOption.dataZoom.realtime !== false,
        start: dataZoomState.value.start !== undefined ? dataZoomState.value.start : (baseOption.dataZoom.start || 0),
        end: dataZoomState.value.end !== undefined ? dataZoomState.value.end : (baseOption.dataZoom.end || 100),
        xAxisIndex: allXAxisIndices,
        // 设置缩放尺的位置，与所有容器的最左和最右边距对齐
        left: minLeft,
        right: minRight,
        bottom: baseOption.dataZoom.bottom !== undefined ? baseOption.dataZoom.bottom : 20
      })
    }
    
    if (baseOption.dataZoom.type === 'inside' || baseOption.dataZoom.type === 'both') {
      dataZoomConfig.push({
        type: 'inside',
        realtime: baseOption.dataZoom.realtime !== false,
        start: dataZoomState.value.start !== undefined ? dataZoomState.value.start : (baseOption.dataZoom.start || 0),
        end: dataZoomState.value.end !== undefined ? dataZoomState.value.end : (baseOption.dataZoom.end || 100),
        xAxisIndex: allXAxisIndices
      })
    }
    echartsOption.dataZoom = dataZoomConfig
  }

  // 处理每个容器的配置
  let globalXAxisIndex = 0 // 全局xAxis索引计数器
  baseOption.containers.forEach((container: any, containerIndex: number) => {
    // 添加网格配置
    echartsOption.grid.push({
      left: container.grid?.left || '10%',
      right: container.grid?.right || '10%',
      top: container.grid?.top || '10%',
      height: container.grid?.height || '30%'
    })

    // 处理X轴配置 - 按照配置中的顺序渲染
    container.xAxis?.forEach((xAxis: any, xAxisIndex: number) => {
      const xAxisConfig: any = {
        gridIndex: containerIndex,
        name: xAxis.name || '',
        position: xAxis.position || 'bottom',
        offset: xAxis.offset || 0,
        type: xAxis.type || 'category',
        // 添加z-index以支持轴的层级显示
        z: xAxisIndex,
        axisTick: {
          show: xAxis.axisTick?.show !== false,
          lineStyle: {
            color: xAxis.axisTick?.lineStyle?.color || '#666666'
          }
        },
        axisLabel: {
          show: xAxis.axisLabel?.show !== false,
          color: xAxis.axisLabel?.color || '#666666'
        },
        axisLine: {
          show: xAxis.axisLine?.show !== false,
          lineStyle: {
            color: xAxis.axisLine?.lineStyle?.color || '#666666'
          }
        },
        splitLine: {
          show: xAxis.splitLine?.show !== false,
          lineStyle: {
            color: xAxis.splitLine?.lineStyle?.color || '#666666'
          }
        }
      }

      // 对数轴配置
      if (xAxis.type === 'log') {
        xAxisConfig.logBase = xAxis.logBase || Math.E
        if (xAxis.min !== undefined && xAxis.min !== null) {
          xAxisConfig.min = xAxis.min
        }
        if (xAxis.max !== undefined && xAxis.max !== null) {
          xAxisConfig.max = xAxis.max
        }
      }
      // 数值轴配置
      else if (xAxis.type === 'value') {
        if (xAxis.min !== undefined && xAxis.min !== null) {
          xAxisConfig.min = xAxis.min
        }
        if (xAxis.max !== undefined && xAxis.max !== null) {
          xAxisConfig.max = xAxis.max
        }
      }

      if (!xAxis.name || xAxis.name.trim() === '') {
        if (xAxis.dataField) {
          xAxisConfig.name = xAxis.dataField
        }
      }

      if (xAxis.datasourceIndex !== undefined && baseOption.datasources && baseOption.datasources[xAxis.datasourceIndex]) {
        const datasource = baseOption.datasources[xAxis.datasourceIndex]
        if (datasource.data && Array.isArray(datasource.data) && datasource.data.length > 0) {
          const firstItem = datasource.data[0]
          if (xAxis.dataField && firstItem && firstItem.hasOwnProperty(xAxis.dataField)) {
            xAxisConfig.data = datasource.data.map((item: any) => item[xAxis.dataField])
            
            // 如果是数值轴且未配置min/max，自动计算数据的最小值和最大值
            if (xAxis.type === 'value' || xAxis.type === 'log') {
              const numericData = xAxisConfig.data.filter((val: any) => typeof val === 'number' && !isNaN(val))
              if (numericData.length > 0) {
                const dataMin = Math.min(...numericData)
                const dataMax = Math.max(...numericData)
                
                // 检查dataZoom是否为0-100（即全范围显示）
                const currentStart = dataZoomState.value.start !== undefined ? dataZoomState.value.start : 0
                const currentEnd = dataZoomState.value.end !== undefined ? dataZoomState.value.end : 100
                const isFullRange = currentStart === 0 && currentEnd === 100
                
                if (isFullRange) {
                  // 当dataZoom为0-100时，存储原始的min/max值
                  if (xAxis.min === undefined || xAxis.min === null) {
                    xAxisOriginalRange.value[globalXAxisIndex] = xAxisOriginalRange.value[globalXAxisIndex] || {}
                    xAxisOriginalRange.value[globalXAxisIndex].min = dataMin
                    xAxisConfig.min = dataMin
                  }
                  if (xAxis.max === undefined || xAxis.max === null) {
                    xAxisOriginalRange.value[globalXAxisIndex] = xAxisOriginalRange.value[globalXAxisIndex] || {}
                    xAxisOriginalRange.value[globalXAxisIndex].max = dataMax
                    xAxisConfig.max = dataMax
                  }
                } else {
                  // 当dataZoom不为0-100时，使用存储的原始min/max值
                  const originalRange = xAxisOriginalRange.value[globalXAxisIndex]
                  if (originalRange) {
                    if (xAxis.min === undefined || xAxis.min === null) {
                      xAxisConfig.min = originalRange.min !== undefined ? originalRange.min : dataMin
                    }
                    if (xAxis.max === undefined || xAxis.max === null) {
                      xAxisConfig.max = originalRange.max !== undefined ? originalRange.max : dataMax
                    }
                  }
                }
              }
            }
          } else {
            xAxisConfig.data = []
          }
        }
      } else {
        xAxisConfig.data = []
      }

      if (xAxis.customLabels && xAxis.customLabels.enabled && xAxis.customLabels.labels && xAxis.customLabels.labels.length > 0) {
        const customLabelsMap = new Map()
        xAxis.customLabels.labels.forEach((label: any) => {
          customLabelsMap.set(label.value, label.text)
        })

        const customValues = xAxis.customLabels.labels.map((label: any) => label.value)
        
        if (xAxisConfig.type === 'value') {
          const existingData = xAxisConfig.data || []
          const allValues = [...new Set([...existingData, ...customValues])]
          xAxisConfig.data = allValues

          const minCustomValue = Math.min(...customValues)
          const maxCustomValue = Math.max(...customValues)
          
          if (xAxisConfig.min !== undefined && xAxisConfig.min > minCustomValue) {
            xAxisConfig.min = minCustomValue
          }
          if (xAxisConfig.max !== undefined && xAxisConfig.max < maxCustomValue) {
            xAxisConfig.max = maxCustomValue
          }
        }
        if (!xAxisConfig.axisLabel) {
          xAxisConfig.axisLabel = {}
        }
        xAxisConfig.axisLabel.customValues = customValues
        xAxisConfig.axisLabel.interval = 0 // 显示所有刻度
        xAxisConfig.splitNumber = Math.max(5, customValues.length) // 确保有足够的分割数
        xAxisConfig.axisLabel.formatter = function(value: any, index: number) {
          if (customLabelsMap.has(value)) {
            return customLabelsMap.get(value)
          }
          return ''
        }
        if (!xAxisConfig.axisTick) {
          xAxisConfig.axisTick = {}
        }
        xAxisConfig.axisTick.customValues = customValues
      }
      echartsOption.xAxis.push(xAxisConfig)
      globalXAxisIndex++ // 递增全局xAxis索引
    })

    container.yAxis?.forEach((yAxis: any, yAxisIndex: number) => {
      const yAxisConfig: any = {
        gridIndex: containerIndex,
        name: yAxis.name || '',
        nameRotate: yAxis.nameRotate !== undefined ? yAxis.nameRotate : 0,
        position: yAxis.position || 'left',
        offset: yAxis.offset || 0,
        type: yAxis.type || 'category',
        z: yAxisIndex,
        axisTick: {
          show: yAxis.axisTick?.show !== false,
          lineStyle: {
            color: yAxis.axisTick?.lineStyle?.color || '#666666'
          }
        },
        axisLabel: {
          show: yAxis.axisLabel?.show !== false,
          color: yAxis.axisLabel?.color || '#666666'
        },
        axisLine: {
          show: yAxis.axisLine?.show !== false,
          lineStyle: {
            color: yAxis.axisLine?.lineStyle?.color || '#666666'
          }
        },
        splitLine: {
          show: yAxis.splitLine?.show !== false,
          lineStyle: {
            color: yAxis.splitLine?.lineStyle?.color || '#eeeeee'
          }
        }
      }

      if (yAxis.customLabels?.enabled && Array.isArray(yAxis.customLabels.labels) && yAxis.customLabels.labels.length > 0) {
        const customLabelsMap = new Map()
        yAxis.customLabels.labels.forEach((label: { value: number; text: string }) => {
          customLabelsMap.set(label.value, label.text)
        })
        
        const customValues = yAxis.customLabels.labels.map((label: { value: number; text: string }) => label.value)
        
        if (yAxisConfig.type === 'category') {
          const existingData = yAxisConfig.data || []
          const allValues = [...new Set([...existingData, ...customValues])]
          yAxisConfig.data = allValues
        } else {
          const minCustomValue = Math.min(...customValues)
          const maxCustomValue = Math.max(...customValues)
          
          if (yAxisConfig.min !== undefined && yAxisConfig.min > minCustomValue) {
            yAxisConfig.min = minCustomValue
          }
          if (yAxisConfig.max !== undefined && yAxisConfig.max < maxCustomValue) {
            yAxisConfig.max = maxCustomValue
          }
        }       
        if (!yAxisConfig.axisLabel) {
          yAxisConfig.axisLabel = {}
        }
        yAxisConfig.axisLabel.customValues = customValues
        yAxisConfig.axisLabel.interval = 0         
        yAxisConfig.splitNumber = Math.max(5, customValues.length)
        yAxisConfig.axisLabel.formatter = function(value: any, index: number) {
          if (customLabelsMap.has(value)) {
            return customLabelsMap.get(value)
          }
          return ''
        }
        if (!yAxisConfig.axisTick) {
          yAxisConfig.axisTick = {}
        }
        yAxisConfig.axisTick.customValues = customValues
      }

      if (yAxis.type === 'log') {
        yAxisConfig.logBase = yAxis.logBase || Math.E
        if (yAxis.min !== undefined && yAxis.min !== null) {
          yAxisConfig.min = yAxis.min
        }
        if (yAxis.max !== undefined && yAxis.max !== null) {
          yAxisConfig.max = yAxis.max
        }
      }
      else if (yAxis.type === 'value') {
        if (yAxis.min !== undefined && yAxis.min !== null) {
          yAxisConfig.min = yAxis.min
        }
        if (yAxis.max !== undefined && yAxis.max !== null) {
          yAxisConfig.max = yAxis.max
        }
      }
      
      if (!yAxis.name || yAxis.name.trim() === '') {
        const globalYAxisIndex = containerIndex > 0 ? 
          baseOption.containers.slice(0, containerIndex).reduce((sum, c) => sum + (c.yAxis?.length || 0), 0) + yAxisIndex :
          yAxisIndex
        
        const boundSeries = container.series?.find((series: any) => series.yAxisIndex === yAxisIndex)
        if (boundSeries && boundSeries.dataField) {
          yAxisConfig.name = boundSeries.dataField
        }
      }
      
      if (yAxis.min !== undefined && yAxis.min !== null) {
        yAxisConfig.min = yAxis.min
      }
      if (yAxis.max !== undefined && yAxis.max !== null) {
        yAxisConfig.max = yAxis.max
      }
      if (yAxis.splitNumber !== undefined) {
        yAxisConfig.splitNumber = yAxis.splitNumber
      } else {
        yAxisConfig.splitNumber = 5
      }
      
      yAxisConfig.scale = false
      yAxisConfig.boundaryGap = [0, 0]
      
      echartsOption.yAxis.push(yAxisConfig)
    })

    container.series?.forEach((series: any, seriesIndex: number) => {
      let globalXAxisStartIndex = 0
      let globalYAxisStartIndex = 0
      
      for (let i = 0; i < containerIndex; i++) {
        globalXAxisStartIndex += baseOption.containers[i].xAxis?.length || 0
        globalYAxisStartIndex += baseOption.containers[i].yAxis?.length || 0
      }
      
      const seriesConfig: any = {
        name: series.name || `系列${seriesIndex + 1}`,
        type: series.type || 'line',
        xAxisIndex: globalXAxisStartIndex + (series.xAxisIndex || 0),
        yAxisIndex: globalYAxisStartIndex + (series.yAxisIndex || 0),
        z: seriesIndex,
        data: []
      }

      if (series.type === 'scatter') {
        seriesConfig.symbol = series.symbol || 'circle'
        seriesConfig.symbolSize = series.symbolSize || 10
        seriesConfig.symbolStyle = series.symbolStyle || {}
      }
      if (series.type === 'bar') {
        seriesConfig.stack = series.stack || ''
      }
      if (series.type === 'line') {
        seriesConfig.smooth = series.smooth || false
        seriesConfig.showSymbol = series.showSymbol !== false
        if (series.lineStyle) {
          seriesConfig.lineStyle = series.lineStyle
        }
      } else if (series.type === 'area') {
        seriesConfig.type = 'line' // ECharts中面积图实际是line类型
        seriesConfig.smooth = series.smooth || false
        seriesConfig.showSymbol = series.showSymbol !== false
        seriesConfig.areaStyle = series.areaStyle || {} // 添加面积样式
        if (series.lineStyle) {
          seriesConfig.lineStyle = series.lineStyle
        }
      }

      // 设置样式
      if (series.itemStyle) {
        seriesConfig.itemStyle = cloneDeep(series.itemStyle)
        
        // 处理渐变色配置
        if (series.itemStyle.color && typeof series.itemStyle.color === 'string' && series.itemStyle.color.includes('linear-gradient')) {
          // 解析CSS渐变色为ECharts渐变色格式
          const gradientMatch = series.itemStyle.color.match(/linear-gradient\(([^)]+)\)/)
          if (gradientMatch) {
            const gradientStr = gradientMatch[1]
            const parts = gradientStr.split(',').map(part => part.trim())
            
            // 提取角度（如果有）
            let angle = 0
            let colorStops = parts
            if (parts[0].includes('deg')) {
              angle = parseInt(parts[0].replace('deg', '').trim())
              colorStops = parts.slice(1)
            } else if (parts[0].includes('135deg')) {
              angle = 135
              colorStops = parts.slice(1)
            }
            
            // 转换为ECharts渐变色格式
            const colors = []
            colorStops.forEach((stop, index) => {
              const colorMatch = stop.match(/(#[0-9a-fA-F]{6}|rgb\([^)]+\))/g)
              const percentMatch = stop.match(/(\d+)%/)
              
              if (colorMatch && colorMatch[0]) {
                colors.push({
                  offset: percentMatch ? parseInt(percentMatch[1]) / 100 : index / (colorStops.length - 1),
                  color: colorMatch[0]
                })
              }
            })
            
            if (colors.length > 0) {
              // 根据角度确定渐变方向
              let x = 0, y = 0, x2 = 0, y2 = 1
              if (angle === 135) {
                x = 0; y = 0; x2 = 1; y2 = 1
              } else if (angle === 90) {
                x = 0; y = 1; x2 = 0; y2 = 0
              } else if (angle === 0) {
                x = 0; y = 0; x2 = 1; y2 = 0
              }
              
              seriesConfig.itemStyle.color = {
                type: 'linear',
                x, y, x2, y2,
                colorStops: colors
              }
            }
          }
        }
      }

      if (series.label) {
        seriesConfig.label = series.label
      }

      if (series.animation !== undefined) {
        seriesConfig.animation = series.animation
        if (series.animationDuration) {
          seriesConfig.animationDuration = series.animationDuration
        }
      }

      if (series.datasourceIndex !== undefined && baseOption.datasources && baseOption.datasources[series.datasourceIndex]) {
        const datasource = baseOption.datasources[series.datasourceIndex]
        if (datasource.data && Array.isArray(datasource.data)) {
          let rawData = []
          if (series.dataField && datasource.data.length > 0) {
            const firstItem = datasource.data[0]
            if (firstItem && firstItem.hasOwnProperty(series.dataField)) {
              rawData = datasource.data.map((item: any) => item[series.dataField])
            } else {
              rawData = []
            }
          } else {
            rawData = []
          }
          
          const xAxisIndex = series.xAxisIndex || 0
          const yAxisIndex = series.yAxisIndex || 0
          const localXAxisIndex = xAxisIndex % (container.xAxis?.length || 1)
          const localYAxisIndex = yAxisIndex % (container.yAxis?.length || 1)
          
          if (container.xAxis && container.xAxis[localXAxisIndex]) {
            const xAxis = container.xAxis[localXAxisIndex]
            const yAxis = container.yAxis && container.yAxis[localYAxisIndex]
            
            if (xAxis.datasourceIndex !== undefined && baseOption.datasources && baseOption.datasources[xAxis.datasourceIndex]) {
              const xDatasource = baseOption.datasources[xAxis.datasourceIndex]
              if (xDatasource.data && Array.isArray(xDatasource.data)) {
                let xData = xDatasource.data.map((item: any) => item[xAxis.dataField])
                                                
                if (xAxis.type === 'category') {
                  seriesConfig.data = rawData
                } else {
                  seriesConfig.data = rawData.map((yValue, index) => [xData[index], yValue])
                }
              } else {
                if (xAxis.type === 'category') {
                  seriesConfig.data = rawData
                } else {
                  seriesConfig.data = rawData.map((yValue, index) => [index, yValue])
                }
              }
            } else {
              if (xAxis.type === 'category') {
                seriesConfig.data = rawData
              } else {
                seriesConfig.data = rawData.map((yValue, index) => [index, yValue])
              }
            }
          } else {
            seriesConfig.data = rawData.map((yValue, index) => [index, yValue])
          }
        }
      } else {
        if (series.yAxisIndex > 0) {
          seriesConfig.data = []
        }
      }

      if (seriesConfig.xAxisIndex >= echartsOption.xAxis.length) {
        console.warn(`系列 ${series.name} 的 xAxisIndex ${seriesConfig.xAxisIndex} 超出范围，重置为 ${globalXAxisStartIndex}`)
        seriesConfig.xAxisIndex = globalXAxisStartIndex
      }
      
      if (seriesConfig.yAxisIndex >= echartsOption.yAxis.length) {
        console.warn(`系列 ${series.name} 的 yAxisIndex ${seriesConfig.yAxisIndex} 超出范围，重置为 ${globalYAxisStartIndex}`)
        seriesConfig.yAxisIndex = globalYAxisStartIndex
      }

      // 标注区域（markArea）
      if (series.markArea && Array.isArray(series.markArea.data) && series.markArea.data.length > 0) {
        try {
          // 直接克隆配置，保持 [ { name, xAxis, itemStyle }, { xAxis } ] 结构
          seriesConfig.markArea = cloneDeep(series.markArea)
        } catch (e) {
          console.warn('markArea 配置应用失败:', e)
        }
      }

      echartsOption.series.push(seriesConfig)
    })
  })

  console.log('echartsOption', echartsOption)
  return mergeTheme(echartsOption, props.themeSetting, includes)
})

// 监听数据源变化，异步加载文件内容
watch(
  () => props.chartConfig.option.datasources,
  async (datasources) => {
    if (!datasources || !Array.isArray(datasources)) return
    
    datasources.forEach(async (datasource, datasourceIndex) => { 
      if ((datasource.type === 'file-json') && datasource.filePath && !fileDataCache.value[datasource.filePath]) {
        try {
          const { getDatasourceFileContentApi } = await import('@/api/path/system.api')
          const response = await getDatasourceFileContentApi(datasource.filePath)
          if (response && response.data) {
            fileDataCache.value[datasource.filePath] = JSON.parse(response.data.content)
          }
        } catch (error) {
          console.error('文件数据加载失败:', error)
          fileDataCache.value[datasource.filePath] = []
        }
      }
      else if (datasource.type === 'file-csv' && datasource.filePath && !fileDataCache.value[datasource.filePath]) {
        try {
          const { getDatasourceFileContentApi } = await import('@/api/path/system.api')
          const response = await getDatasourceFileContentApi(datasource.filePath)
          if (response && response.data) {
            const csvdata = response.data.content
            // 解析CSV数据为JSON格式
            const lines = csvdata.trim().replace(/\r/,'').split('\n')
            if (lines.length > 1) {
              const headers = lines[0].split(',').map((h: string) => h.trim())
              const data = lines.slice(1).map((line: string) => {
                const values = line.split(',').map((v: string) => v.trim())
                const obj: any = {}
                headers.forEach((header: string, index: number) => {
                  obj[header] = values[index] || ''
                })
                return obj
              })
              fileDataCache.value[datasource.filePath] = data
            }
          }
        } catch (error) {
          console.error('文件数据加载失败:', error)
          fileDataCache.value[datasource.filePath] = []
        }
      }
      else if (datasource.type === 'workflow-json' && datasource.workflowInstance) {
        // 获取用到了的field
        const fields = getUsedFields(datasourceIndex)
        if (fields.length > 0) {
          try {
            const { getWorkflowInstanceData } = await import('@/api/path/system.api')
            const response = await getWorkflowInstanceData({
              taskId: datasource.workflowInstance.taskId,
              format: 'json',
              maxSize: 1000,
              fields: fields.join(','),
            })
            if (response && response.data) {
              workflowDataCache.value[datasourceIndex+''] = response.data
            }
          } catch (error) {
            console.error('工作流数据加载失败:', error)
            workflowDataCache.value[datasourceIndex+''] = []
          }
        }
        console.log('加载工作流实例JSON数据', fields)
      }
      else if (datasource.type === 'workflow-csv' && datasource.workflowInstance) {
        console.log('加载工作流实例CSV数据')
      }
    })
  },
  { immediate: true, deep: true }
)

watch(
  () => props.chartConfig.option.dataset,
  (newData: any, oldData) => {
    try {
      if (!isObject(newData) || !('dimensions' in newData)) return
      if (Array.isArray((newData as any)?.dimensions)) {
        const seriesArr: typeof barSeriesItem[] = []
        // 对oldData进行判断，防止传入错误数据之后对旧维度判断产生干扰
        // 此处计算的是dimensions的Y轴维度，若是dimensions.length为0或1，则默认为1，排除X轴维度干扰
        const oldDimensions =
          Array.isArray(oldData?.dimensions) && oldData.dimensions.length >= 1 ? oldData.dimensions.length : 1
        const newDimensions = (newData as any).dimensions.length >= 1 ? (newData as any).dimensions.length : 1
        const dimensionsGap = newDimensions - oldDimensions
        if (dimensionsGap < 0) {
          props.chartConfig.option.series.splice(newDimensions - 1)
        } else if (dimensionsGap > 0) {
          if (!oldData || !oldData?.dimensions || !Array.isArray(oldData?.dimensions) || !oldData?.dimensions.length) {
            props.chartConfig.option.series = []
          }
          for (let i = 0; i < dimensionsGap; i++) {
            seriesArr.push(cloneDeep(barSeriesItem))
          }
          props.chartConfig.option.series.push(...seriesArr)
        }
        replaceMergeArr.value = ['series']
        nextTick(() => {
          replaceMergeArr.value = []
        })
      }
    } catch (error) {
      console.log(error)
    }
  },
  {
    deep: false
  }
)

// 使用useChartDataFetch hook，但不使用其返回的vChartRef
useChartDataFetch(props.chartConfig, useChartEditStore, (newData: any) => {
  props.chartConfig.option.dataset = newData
})

const onDataZoomChangeHandleTimer = ref<any>(0)
const onDataZoomChange = async (params: any) => {
  const dataZoomInfo = params.batch ? params.batch[0] : params
  const { start, end, startValue, endValue } = dataZoomInfo
  dataZoomState.value = { start, end, startValue, endValue }
  if(onDataZoomChangeHandleTimer.value)  clearTimeout(onDataZoomChangeHandleTimer.value)
  onDataZoomChangeHandleTimer.value = setTimeout(async () => {
    const baseOption = cloneDeep(props.chartConfig.option)
    if (!baseOption.datasources || !Array.isArray(baseOption.datasources)) return
    for (let datasourceIndex = 0; datasourceIndex < baseOption.datasources.length; datasourceIndex++) {
      const datasource = baseOption.datasources[datasourceIndex]
      
      if (datasource.type === 'workflow-json' && datasource.workflowInstance) {
        // 获取该数据源使用的字段
        const fields = getUsedFields(datasourceIndex)
        if (fields.length === 0) continue
        
        const taskId = datasource.workflowInstance.taskId
        
        // 取消相同taskId的之前请求
        if (abortControllers.value[taskId]) {
          console.log('🚫 取消之前的请求:', taskId)
          abortControllers.value[taskId].abort()
        }
        
        // 创建新的AbortController
        const abortController = new AbortController()
        abortControllers.value[taskId] = abortController
        console.log('🔄 创建新的请求控制器:', taskId)
        
        try {
          console.log('📡 开始请求数据:', { taskId, start, end, fields })
          const { getWorkflowInstanceData } = await import('@/api/path/system.api')
          const response = await getWorkflowInstanceData({
            taskId: taskId,
            format: 'json',
            startPercent: start,
            endPercent: end,
            maxSize: 1000,
            fields: fields.join(','),
          }, abortController.signal)
          
          if (response && response.data) {
            // 更新缓存数据
            workflowDataCache.value[datasourceIndex+''] = response.data
            console.log('✅ workflow数据缓存已更新:', datasourceIndex, response.data.length)
          }
          
          // 请求成功后清理AbortController
          delete abortControllers.value[taskId]
          console.log('🧹 清理成功的请求控制器:', taskId)
        } catch (error) {
          // 区分取消错误和其他错误
          if (error.name === 'AbortError') {
            console.log('⏹️ 请求已取消:', taskId)
          } else {
            console.error('❌ 重新获取工作流数据失败:', error)
          }
          // 清理AbortController
          delete abortControllers.value[taskId]
          console.log('🧹 清理失败的请求控制器:', taskId)
        }
      }
    }
  }, 500)
}
</script>
