import { echartOptionProfixHandle, PublicConfigClass } from '@/packages/public'
import { AdvConfig } from './index'
import { CreateComponentType } from '@/packages/index.d'
import cloneDeep from 'lodash/cloneDeep'
import dataJson from './data.json'

export const includes = ['legend', 'grid']
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
    },
    formatter: function (params, ticket, callback) {
      console.log(params); // 检查 params 的内容

      if (params.length === 0) {
        return "";
      }

      var res = '';
      var seen = new Set(); // 用于记录已经处理过的数据点

      params.forEach(function (param) {
        if (param.value && param.value.distance !== undefined && param.value.noise !== undefined &&
          param.value.speed !== undefined && param.value.curve !== undefined) {
          // 使用 distance 作为唯一标识符，可以根据实际情况调整
          var key = param.value.distance.toFixed(2);
          if (!seen.has(key)) {
            seen.add(key);
            res += '当前公里标: ' + parseFloat(param.value.distance).toFixed(2) + '<hr/>';
            res += '噪声 : ' + parseFloat(param.value.noise).toFixed(2) + '<br/>';
            res += '速度 : ' + parseFloat(param.value.speed).toFixed(2) + '<br/>';
            res += '曲线 : ' + parseFloat(param.value.curve).toFixed(2) + '<br/>';
          }
        }
      });

      return res.trim();
    }
  },
  legend: {
    data: null
  },
  xAxis: [
    {
      type: 'value',
      name: '',
      boundaryGap: false,
      splitLine: false,
      axisTick: {
        show: false,
      },
      axisLabel: {
        // fomatter: ''
        formatter: function (value: any) {
          const stations = [{ "distance": 0, "station": "福州南站" }, { "distance": 3692.863, "station": "龙江站" }, { "distance": 4529.651, "station": "前锦站" }, { "distance": 5693.477, "station": "螺洲古镇站" }, { "distance": 7300.68099999379, "station": "帝封江站" }, { "distance": 8137.872, "station": "义序站" }, { "distance": 9294.302, "station": "盖山竹榄站" }, { "distance": 10535.702, "station": "吴山站" }, { "distance": 12382.889, "station": "盘屿站" }, { "distance": 13779.33, "station": "台屿站" }, { "distance": 14784.213, "station": "东岭站" }, { "distance": 16052.437, "station": "霞镜站" }, { "distance": 17117.074, "station": "浦上大道站" }, { "distance": 17909.537, "station": "凤冈里站" }, { "distance": 19018.192, "station": "金山站" }, { "distance": 20071.844, "station": "马榕站" }, { "distance": 21717.8279999938, "station": "阵坂站" }, { "distance": 22616.673, "station": "洪塘站" }, { "distance": 24016.469, "station": "农业大学站" }, { "distance": 27229.519, "station": "荆溪厚屿站" }]
          const max_x = 27230
          if (value == 10) {
            return stations[0].station
          } else if (value == max_x - 10) {
            return stations[stations.length - 1].station
          }
          for (var i = 0; i < stations.length; i++) {
            if (Math.abs(stations[i].distance - value) < 5) {
              return stations[i].station;
            }
          }
          return '';
        },
      },
      interval: 10,
      min: 0,
      max: dataJson.max_x,
      gridIndex: 0
    },
    {
      type: 'value',
      name: '',
      axisLabel: {
        formatter: '{value} m',
        interval: 100,
      },
      min: 0,
      max: 27230,
      gridIndex: 1
    }
  ],
  yAxis: [
    {
      type: 'value',
      name: '噪声',
      position: 'left',
      axisLabel: {
        formatter: '{value} dBA'
      },
      splitLine: {
        show: false
      },
      gridIndex: 0
    },
    {
      type: 'value',
      name: '速度',
      position: 'right',
      min: 0,
      max: 100,
      axisLabel: {
        formatter: '{value} km/h'
      },
      gridIndex: 0
    },
    {
      type: 'value',
      name: '曲线',
      position: 'left',
      axisLabel: {
        formatter: '{value}'
      },
      max: 1800,
      gridIndex: 1
    }
  ],
  dataset: { ...dataJson },
  series: [
    {
      name: '噪声',
      type: 'line',
      yAxisIndex: 0,
      encode: {
        x: 0,
        y: 2,
      },
      // data: noiseData,
      xAxisIndex: 0,
      gridIndex: 0,
      symbolSize: 0.5,
      smooth: true,
      sampling: 'lttb',
    },
    {
      name: '速度',
      type: 'line',
      yAxisIndex: 1,
      encode: {
        x: 0,
        y: 1,
      },
      // data: speedData,
      xAxisIndex: 0,
      gridIndex: 0,
      symbolSize: 0.5,
      smooth: true,
      sampling: 'lttb',
    },
    {
      name: '曲线',
      type: 'line',
      yAxisIndex: 2,
      encode: {
        x: 0,
        y: 3,
      },
      xAxisIndex: 1,
      gridIndex: 1,
      symbolSize: 0.2,
      smooth: true,
      sampling: 'lttb',
      lineStyle: {
        color: 'white'  // 设置线条颜色为黑色
      },
      markArea: {
        itemStyle: {
          color: '#4992ff'
        },
        data: { ...dataJson }.pieces.map((item) => { return [{ "xAxis": item.min, "itemStyle": { "color": dataJson.colors[item.val - 1] } }, { "xAxis": item.max }] },
        )
      }
    }
  ],
  dataZoom: [
    {
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
      top: '10%'
    },
    {
      left: '5%',
      right: '5%',
      height: '35%',
      top: '55%'
    }
  ],
}

export default class Config extends PublicConfigClass implements CreateComponentType {
  public key = AdvConfig.key
  public chartConfig = cloneDeep(AdvConfig)
  // 图表配置项
  public option = echartOptionProfixHandle(option, includes)
}
