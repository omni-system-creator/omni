import { echartOptionProfixHandle, PublicConfigClass } from '@/packages/public';
import { JoinTablesConfig } from './index';
import { CreateComponentType } from '@/packages/index.d';
import cloneDeep from 'lodash/cloneDeep';
import data from './chart_data_noise.json';

// 站点映射数据
export let stationMap = [
  { "distance": 0, "station": "福州南站" },
  { "distance": 3692.863, "station": "龙江站" },
  { "distance": 4529.651, "station": "前锦站" },
  { "distance": 5693.477, "station": "螺洲古镇站" },
  { "distance": 7300.68099999379, "station": "帝封江站" },
  { "distance": 8137.872, "station": "义序站" },
  { "distance": 9294.302, "station": "盖山竹榄站" },
  { "distance": 10535.702, "station": "吴山站" },
  { "distance": 12382.889, "station": "盘屿站" },
  { "distance": 13779.33, "station": "台屿站" },
  { "distance": 14784.213, "station": "东岭站" },
  { "distance": 16052.437, "station": "霞镜站" },
  { "distance": 17117.074, "station": "浦上大道站" },
  { "distance": 17909.537, "station": "凤冈里站" },
  { "distance": 19018.192, "station": "金山站" },
  { "distance": 20071.844, "station": "马榕站" },
  { "distance": 21717.8279999938, "station": "阵坂站" },
  { "distance": 22616.673, "station": "洪塘站" },
  { "distance": 24016.469, "station": "农业大学站" },
  { "distance": 27229.519, "station": "荆溪厚屿站" }
];

// 颜色配置
export const colors = ['rgba(73, 146, 255, 1)', 'rgba(124, 255, 178, 1)', 'rgba(255, 243, 105, 1)', 'rgba(255, 121, 129, 1)'];
export const includes = ['legend', 'xAxis', 'yAxis', 'grid']
// 解析数据
export const speedData = data.map(item => [item.distance, item.speed]);
export const noiseData = data.map(item => [item.distance, item.noise]);
export const curveData = data.map(item => [item.distance, item.curve]);

export const data_top = {
  dimensions: ["distance", "speed", "noise", "curve"],
  source: data.map(item => ({ distance: item.distance, speed: item.speed, noise: item.noise, curve: item.curve }))
};

// 获取颜色分段数据
export function getColorArray(noise_json: any[]) {
  let oldVal = 1;
  let oldMin = 0;
  const result = [];
  for (let i = 0; i < noise_json.length; i++) {
    if (noise_json[i].type !== oldVal) {
      result.push({ val: oldVal, min: oldMin, max: noise_json[i].distance });
      oldVal = noise_json[i].type;
      oldMin = noise_json[i].distance;
    }
    if (i === noise_json.length - 1 && noise_json[i].type === oldVal) {
      result.push({ val: oldVal, min: oldMin, max: noise_json[i].distance });
    }
  }
  return result;
}

export const piecesArr = getColorArray(data).map((item) => {
  if (item.val == 1) {
    return [{ xAxis: item.min }, { xAxis: item.max }];
  } else {
    return [{ xAxis: item.min, itemStyle: { color: colors[item.val - 1] } }, { xAxis: item.max }];
  }
});
// ECharts 配置项
export const option = {
  dataset: { ...data_top },
  tooltip: {
    trigger: 'axis',
    backgroundColor: "rgba(0, 44, 140, 0.50)",
    extraCssText: "box-shadow: 0 0 5px rgba(181, 245, 236, 0.5);padding:5px 15px",
    borderColor: "#5cdbd3",
    borderWidth: 1,
    color: '#fff',
    textStyle: {
      color: "rgba(237, 240, 240, 0.9)"
    },
    axisPointer: {
      animation: false
    },
    formatter: function (params: any) {
      if (params.length === 0) return "";
      let res = '';
      const seen = new Set();
      params.forEach((param: any) => {
        if (param.value && param.value.distance !== undefined && param.value.noise !== undefined &&
          param.value.speed !== undefined && param.value.curve !== undefined) {
          const key = param.value.distance.toFixed(2);
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
    data: ['速度', '噪声', '曲线']
  },
  axisPointer: {
    link: [{ xAxisIndex: 'all' }]
  },
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
  xAxis: [
    {
      type: 'value',
      name: '',
      show: true,
      boundaryGap: false,
      splitLine: false,
      axisTick: { show: false },
      axisLabel: {
        formatter: function (value: number) {
  
          if (value == 10) return stationMap[0].station;
          if (value == 27220) return stationMap[stationMap.length - 1].station;
          for (let i = 0; i < stationMap.length; i++) {
            if (Math.abs(stationMap[i].distance - value) < 5) return stationMap[i].station;
          }
          return '';
        }
      },
      interval: 10,
      min: 0,
      max: 27230,
      gridIndex: 0
    },
    {
      type: 'value',
      name: '',
      show: true,
      axisLabel: { formatter: '{value} m', interval: 100 },
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
      axisLabel: { formatter: '{value} dBA' },
      splitLine: { show: false },
      gridIndex: 0
    },
    {
      type: 'value',
      name: '速度',
      position: 'right',
      min: 0,
      max: 100,
      axisLabel: { formatter: '{value} km/h' },
      gridIndex: 0
    },
    {
      type: 'value',
      name: '曲线',
      position: 'left',
      axisLabel: { formatter: '{value}' },
      max: 1800,
      gridIndex: 1
    }
  ],
  series: [
    {
      name: '噪声',
      type: 'line',
      yAxisIndex: 0,
      encode: { x: 0, y: 2 },
      xAxisIndex: 0,
      gridIndex: 0,
      symbolSize: 0.5,
      smooth: true,
      lineStyle: {
        type: 'solid',
        width: 3,
        color: null
      },
      label: {
        show: false,
        position: 'top',
        color: '#fff',
        fontSize: 12
      },
      itemStyle: {
        color: null,
        borderRadius: 0
      },
      sampling: 'lttb'
    },
    {
      name: '速度',
      type: 'line',
      yAxisIndex: 1,
      encode: { x: 0, y: 1 },
      xAxisIndex: 0,
      gridIndex: 0,
      symbolSize: 0.5,
      smooth: true,
      lineStyle: {
        type: 'solid',
        width: 3,
        color: null
      },
      label: {
        show: false,
        position: 'top',
        color: '#fff',
        fontSize: 12
      },
      itemStyle: {
        color: null,
        borderRadius: 0
      },
      sampling: 'lttb'
    },
    {
      name: '曲线',
      type: 'line',
      yAxisIndex: 2,
      data: curveData,
      xAxisIndex: 1,
      gridIndex: 1,
      symbolSize: 0.2,
      smooth: true,
      sampling: 'lttb',
      lineStyle: {
        type: 'solid',
        width: 3,
        color: null
      },
      itemStyle: {
        color: null,
        borderRadius: 0
      },
      label: {
        show: false,
        position: 'top',
        color: '#fff',
        fontSize: 12
      },
      markArea: {
        itemStyle: { color: colors[0] },
        data: piecesArr
      }
    }
  ],
  customProperty:  stationMap
};

export default class Config extends PublicConfigClass implements CreateComponentType {
  public key = JoinTablesConfig.key;
  public chartConfig = cloneDeep(JoinTablesConfig);
  public option = echartOptionProfixHandle(option, includes);
}