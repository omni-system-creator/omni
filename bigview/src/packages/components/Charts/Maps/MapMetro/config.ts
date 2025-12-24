import { PublicConfigClass } from '@/packages/public'
import { CreateComponentType } from '@/packages/index.d'
import { MapMetroConfig } from './index'
import { chartInitConfig } from '@/settings/designSetting'
import cloneDeep from 'lodash/cloneDeep'
import dataJson from './data.json'

const baseUrl = location.protocol + '//' + location.hostname
const styleURL = import.meta.env.VITE_IS_LOCAL == '1' ? (baseUrl + '/tiles/styles/basic-preview/style.json') : 'https://mapserver.web.psy.cool/styles/basic-preview/style.json';

export const option = {
  dataset: dataJson,
  mapOptions: {
    city: '',
    line: '',
    showAll: false,
  },
  maplibreglOptions: {
    dataset: [],
    center: [121.342, 28.4869], // 默认中心点（经度, 纬度）
    zoom: 11.5, // 默认缩放级别
    // style: 'https://mapserver.web.psy.cool/styles/basic-preview/style.json', // 默认样式
    style: styleURL,
    bearing: 90, // 旋转角度
    pitch: 48, // 倾斜角度
    hot_param: 'yingdian',
    hot_size: '20',
    alpha: 128,
    line: 'geojson_tz',
    maxPitch: 85,
    lineWidth: 8,
    lineColor: '#888',
    lineColor2: '#fff',
    railwayWidth: 1.0,
    showLabel: true,
  }
}

export default class Config extends PublicConfigClass implements CreateComponentType {
  public key = MapMetroConfig.key
  public attr = { ...chartInitConfig, w: 1000, h: 800, zIndex: -1 }
  public chartConfig = cloneDeep(MapMetroConfig)
  public option = cloneDeep(option)
}
