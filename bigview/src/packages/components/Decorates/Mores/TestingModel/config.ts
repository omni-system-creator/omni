import { PublicConfigClass } from '@/packages/public'
import { CreateComponentType } from '@/packages/index.d'
import { TestingModelConfig } from './index'
import cloneDeep from 'lodash/cloneDeep'
import { chartInitConfig } from '@/settings/designSetting'

export const option = {
  dataset: '',
  channels: 'A_*|B_*|C_*|D_*',
  fit: 'contain',
  borderRadius: 0,
}

export default class Config extends PublicConfigClass implements CreateComponentType {
  public key = TestingModelConfig.key
  public attr = { ...chartInitConfig, w: 400, h: 200, zIndex: 1 }
  public chartConfig = cloneDeep(TestingModelConfig)
  public option = cloneDeep(option)
}
