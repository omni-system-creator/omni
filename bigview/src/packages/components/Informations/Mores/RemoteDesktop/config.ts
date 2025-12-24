import { PublicConfigClass } from '@/packages/public'
import { CreateComponentType } from '@/packages/index.d'
import { chartInitConfig } from '@/settings/designSetting'
import { RemoteDesktopConfig } from './index'
import cloneDeep from 'lodash/cloneDeep'

export const option = {
  baseUrl:'https://code.psy.cool/index.html',
  // 网站路径
  dataset: "https://code.psy.cool/index.html?username=2&width=1332&height=800&random=0.12455583381808921",
  // 宽高
  width: 1200,
  height: 800,
  // 用户名
  username:'2',
  password:'password',
  ipAddress:'127.0.0.1',
  port:3389,
  // 圆角
  borderRadius: 10
}

export default class Config extends PublicConfigClass implements CreateComponentType
{
  public key = RemoteDesktopConfig.key
  public attr = { ...chartInitConfig, w: 1200, h: 800, zIndex: -1 }
  public chartConfig = cloneDeep(RemoteDesktopConfig)
  public option = cloneDeep(option)
}
