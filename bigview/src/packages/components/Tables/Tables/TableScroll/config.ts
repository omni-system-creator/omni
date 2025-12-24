import { PublicConfigClass } from '@/packages/public'
import { CreateComponentType } from '@/packages/index.d'
import { TableScrollConfig } from './index'
import cloneDeep from 'lodash/cloneDeep'
import dataJson from './data.json'

export const option = {
  header: ["列1", "列2", "列3", "列4", "列5", "列6", "列7", "列8", "列9", "列10"],
  dataset: dataJson,
  index: true,
  columnWidth: [150, 150, 150, 150, 150, 150, 150, 150, 150, 150], // 调整列宽
  align: ['center', 'right', 'right', 'right'],
  rowNum: 5,
  waitTime: 2,
  headerHeight: 35,
  carousel: 'single',
  headerBGC: '#00BAFF',
  oddRowBGC: '#003B51',
  evenRowBGC: '#0A2732'
}

export default class Config extends PublicConfigClass implements CreateComponentType {
  public key = TableScrollConfig.key
  public chartConfig = cloneDeep(TableScrollConfig)
  public option = cloneDeep(option)
}
