import { PublicConfigClass } from '@/packages/public'
import { CreateComponentType } from '@/packages/index.d'
import { TestingPointConfig } from './index'
import cloneDeep from 'lodash/cloneDeep'
import { chartInitConfig } from '@/settings/designSetting'

export const option = {
  channel: '',
  classv: '',
  value: 0,
  outCircle: 5,
  maxValue: 30,
  minValue: 25,
  fontSize: 12,
  fontColor: '#00000000',
  maxValueColor: '#ff0000ff',
  midValueColor: '#ffff00ff',
  minValueColor: '#00ff00ff',
}

export default class Config extends PublicConfigClass implements CreateComponentType {
  public key = TestingPointConfig.key
  public attr = { ...chartInitConfig, w: 20, h: 20, zIndex: 1 }
  public chartConfig = cloneDeep(TestingPointConfig)
  public option = cloneDeep(option)
}
