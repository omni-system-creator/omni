import { ConfigType, PackagesCategoryEnum, ChartFrameEnum } from '@/packages/index.d'
import { ChatCategoryEnum, ChatCategoryEnumName } from '../../index.d'

export const MapSelectConfig: ConfigType = {
  key: 'MapSelect',
  chartKey: 'VMapSelect',
  conKey: 'VCMapSelect',
  title: '地图选择器',
  category: ChatCategoryEnum.MAP,
  categoryName: ChatCategoryEnumName.MAP,
  package: PackagesCategoryEnum.CHARTS,
  chartFrame: ChartFrameEnum.NAIVE_UI,
  image: 'inputs_select.png'
}
