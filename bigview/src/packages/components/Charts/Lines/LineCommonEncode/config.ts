import { echartOptionProfixHandle, PublicConfigClass } from '@/packages/public'
import { LineCommonEncodeConfig } from './index'
import { CreateComponentType } from '@/packages/index.d'
import cloneDeep from 'lodash/cloneDeep'
import dataJson from './data.json'

export const includes = ['legend', 'xAxis', 'yAxis', 'grid']
export const seriesItem = {
  name: "serie-1",
  encode: {
    x: 0,
    y: 1
  },
  type: 'line',
  label: {
    show: true,
    position: 'top',
    color: '#fff',
    fontSize: 12
  },
  symbolSize: 5, //设定实心点的大小
  itemStyle: {
    color: null,
    borderRadius: 0
  },
  lineStyle: {
    type: 'solid',
    width: 3,
    color: null
  }
}

export const option = {
  tooltip: {
    show: true,
    trigger: 'axis',
    axisPointer: {
      type: 'line'
    }
  },
  xAxis: {
    show: true,
    type: 'value'
  },
  yAxis: {
    show: true,
    type: 'value'
  },
  legend: { show: true },
  dataZoom: [
    {
      show: true,
      type: 'inside',
      disabled: false,
      realtime: true,
      start: 0,
      end: 100,
      xAxisIndex: [0, 1],
    },
  ],
  dataset: { ...dataJson },
  series: [seriesItem, seriesItem]
}

export default class Config extends PublicConfigClass implements CreateComponentType {
  public key: string = LineCommonEncodeConfig.key
  public chartConfig = cloneDeep(LineCommonEncodeConfig)
  // 图表配置项
  public option = echartOptionProfixHandle(option, includes)
}
