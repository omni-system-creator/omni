import { echartOptionProfixHandle, PublicConfigClass } from '@/packages/public'
import { AdvancedConfig } from './index'
import { CreateComponentType } from '@/packages/index.d'
import cloneDeep from 'lodash/cloneDeep'

export const includes = ['legend', 'xAxis', 'yAxis', 'grid']
// 柱状折线组合图 分别定义series
// 写死name可以定义legend显示的名称
export const barSeriesItem = {
  type: 'bar',
  barWidth: 15,
  label: {
    show: true,
    position: 'top',
    color: '#fff',
    fontSize: 12
  },
  itemStyle: {
    color: null,
    borderRadius: 2
  }
}

export const lineSeriesItem = {
  type: 'line',
  symbol: 'circle',
  label: {
    show: true,
    position: 'top',
    color: '#fff',
    fontSize: 12
  },
  symbolSize: 5, //设定实心点的大小
  itemStyle: {
    borderWidth: 1
  },
  lineStyle: {
    type: 'solid',
    width: 3,
    color: null
  }
}

export const option = {
  multiDatasource: true,
  showLegend: true,
  legend: {
    orient: 'horizontal',
    left: 'center',
    top: 'top',
    itemWidth: 25,
    itemHeight: 14,
    itemGap: 10,
    textStyle: {
      fontSize: 12,
      color: '#333'
    }
  },
  tooltip: {
    trigger: 'axis',
    backgroundColor: "rgba(0, 44, 140, 0.50)",
    extraCssText: "box-shadow: 0 0 5px rgba(181, 245, 236, 0.5);padding:5px 15px",
    borderColor: "#5cdbd3",//设置自定义边框颜色
    borderWidth: 1,
    color: '#fff',
    textStyle: {
      color: "rgba(237, 240, 240, 0.9)" //设置文字颜色
    },
    axisPointer: {
      animation: false
    }
  },
  containers: [
    {
      name: '默认容器',
      grid: {
        left: '5%',
        right: '5%',
        height: '35%',
        top: '15%'
      },
      series: []
    }
  ],
  series: [
  ],
  dataZoom: [
    {
      type: 'slider',
      show: true,
      realtime: true,
      start: 0,
      end: 100,
      xAxisIndex: [0, 1]
    },
    {
      type: 'inside',
      realtime: true,
      start: 0,
      end: 100,
      xAxisIndex: [0, 1]
    }
  ],
  grid: [
    {
      left: '5%',
      right: '5%',
      height: '35%',
      top: '10%',
      name: 'A'
    },
    {
      left: '5%',
      right: '5%',
      height: '35%',
      top: '55%',
      name: 'B'
    }
  ],
}

export default class Config extends PublicConfigClass implements CreateComponentType {
  public key = AdvancedConfig.key
  public chartConfig = cloneDeep(AdvancedConfig)
  // 图表配置项
  public option = echartOptionProfixHandle(option, includes)
}
