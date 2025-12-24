import { PublicConfigClass } from '@/packages/public'
import { CreateComponentType } from '@/packages/index.d'
import { Border14Config } from './index'
import cloneDeep from 'lodash/cloneDeep'

export const option = {
  borderTitle: '边框-14',
  borderTitleWidth: 250,
  borderTitleHeight: 50,
  borderTitleSize: 16,
  borderTitleLeft: 30,
  borderTitleColor: '#fff',
  borderBottomHeight: 8,
  borderShadowWidth: 8,
  borderShadowColor: '#2d95fa',
  backgroundColor: '#00000000'
}

export default class Config extends PublicConfigClass implements CreateComponentType {
  public key = Border14Config.key
  public chartConfig = cloneDeep(Border14Config)
  public option = cloneDeep(option)
}
