import cloneDeep from 'lodash/cloneDeep'
import { PublicConfigClass } from '@/packages/public'
import { CreateComponentType } from '@/packages/index.d'
import { chartInitConfig } from '@/settings/designSetting'
import { COMPONENT_INTERACT_EVENT_KET } from '@/enums/eventEnum'
import { interactActions, ComponentInteractEventEnum } from './interact'
import { InputsTreeConfig } from './index'

export const option = {
  // 时间组件展示类型，必须和 interactActions 中定义的数据一致
  [COMPONENT_INTERACT_EVENT_KET]: ComponentInteractEventEnum.DATA,
  // 默认值
  selectValue: '1',
  // 暴露配置内容给用户
  dataset: [
    {
      "key": "文件夹",
      "label": "文件夹",
      "children": [
        {
          "key": "空的",
          "label": "空的"
        },
        {
          "key": "我的文件",
          "label": "我的文件",
          "children": [
            {
              "label": "template.txt",
              "key": "template.txt"
            }
          ]
        }
      ]
    }
  ],
  // tree 节点配置
  nodeProps:{
    onClick:''
  },

}

export default class Config extends PublicConfigClass implements CreateComponentType {
  public key = InputsTreeConfig.key
  public attr = { ...chartInitConfig, w: 260, h: 32, zIndex: -1 }
  public chartConfig = cloneDeep(InputsTreeConfig)
  public interactActions = interactActions
  public option = cloneDeep(option)
}
