import { echartOptionProfixHandle, PublicConfigClass } from '@/packages/public'
import { LineLogGradientsConfig } from './index'
import { CreateComponentType } from '@/packages/index.d'
import { graphic } from 'echarts/core'
import { defaultTheme, chartColorsSearch } from '@/settings/chartThemes/index'
import cloneDeep from 'lodash/cloneDeep'
import dataJson from './data.json'

export const includes = ['legend', 'xAxis', 'yAxis', 'grid']

const option = {
  tooltip: {
    show: true,
    trigger: 'axis',
    axisPointer: {
      type: 'line'
    }
  },
  xAxis: {
    show: true,
    type: 'log',
    max: 1000,
    axisLabel: {
      formatter: function (v) {
        return '{base|10}{power|' + Math.log10(v) + '}';
      },
      rich: {
        base: {
          fontSize: 14,
        },
        power: {
          verticalAlign: 'super',
          fontSize: 10,
        }
      }
    }
  },
  yAxis: {
    show: true,
    type: 'log',
    axisLabel: {
      formatter: function (v) {
        return '{base|10}{power|' + Math.log10(v) + '}';
        // return v;
      },
      rich: {
        base: {
          fontSize: 14,
        },
        power: {
          verticalAlign: 'super',
          fontSize: 10,
        }
      }
    }
  },
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
  series: [
    {
      type: 'line',
      smooth: false,
      symbolSize: 5, //设定实心点的大小
      label: {
        show: true,
        position: 'top',
        color: '#fff',
        fontSize: 12
      },
      lineStyle: {
        width: 3,
        type: 'solid'
      },
      encode: {
        x: 0,
        y: 1,
      },
      areaStyle: {
        opacity: 0.8,
        color: new graphic.LinearGradient(0, 0, 0, 1, [
          {
            offset: 0,
            color: chartColorsSearch[defaultTheme][3]
          },
          {
            offset: 1,
            color: 'rgba(0,0,0,0)'
          }
        ])
      }
    },
    {
      type: 'line',
      smooth: false,
      label: {
        show: true,
        position: 'top',
        color: '#fff',
        fontSize: 12
      },
      lineStyle: {
        width: 3,
        type: 'solid'
      },
      encode: {
        x: 0,
        y: 2,
      },
      areaStyle: {
        opacity: 0.8,
        color: new graphic.LinearGradient(0, 0, 0, 1, [
          {
            offset: 0,
            color: chartColorsSearch[defaultTheme][4]
          },
          {
            offset: 1,
            color: 'rgba(0,0,0,0)'
          }
        ])
      }
    }
  ]
}

export default class Config extends PublicConfigClass implements CreateComponentType {
  public key: string = LineLogGradientsConfig.key
  public chartConfig = cloneDeep(LineLogGradientsConfig)
  // 图表配置项
  public option = echartOptionProfixHandle(option, includes)
}
