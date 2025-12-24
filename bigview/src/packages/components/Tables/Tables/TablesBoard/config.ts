import cloneDeep from 'lodash/cloneDeep'
import { PublicConfigClass } from '@/packages/public'
import { CreateComponentType } from '@/packages/index.d'
import { chartInitConfig } from '@/settings/designSetting'
import { TablesBoardConfig } from './index'
import dataJson from './data.json'

const { dimensions, source } = dataJson;

export const option = {
  dataset: {
    dimensions: dimensions.map(dim => ({
      ...dim,
      key: dim.dataIndex // 添加 key 属性
    })),
    source
  },
  pagination: {
    enabled: true,
    page: 1,
    pageSize: 5
  },
  align: 'center',
  style: {
    border: 'on',
    singleColumn: 'off',
    singleLine: 'off',
    bottomBordered: 'on',
    striped: 'on',
    fontSize: 16,
    borderWidth: 0,
    borderColor: 'black',
    borderStyle: 'solid'
  },
  inputShow: 'none'
};

export default class Config extends PublicConfigClass implements CreateComponentType {
  public key = TablesBoardConfig.key
  public attr = { ...chartInitConfig, w: 600, h: 300, zIndex: -1 }
  public chartConfig = cloneDeep(TablesBoardConfig)
  public option = cloneDeep(option)
}
