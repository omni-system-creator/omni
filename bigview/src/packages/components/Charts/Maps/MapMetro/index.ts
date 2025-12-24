import { ConfigType, PackagesCategoryEnum, ChartFrameEnum } from '@/packages/index.d'
import { ChatCategoryEnum, ChatCategoryEnumName } from '../../index.d'

export const MapMetroConfig: ConfigType = {
  key: 'MapMetro',
  chartKey: 'VMapMetro',
  conKey: 'VCMapMetro',
  title: '地铁地图',
  category: ChatCategoryEnum.MAP,
  categoryName: ChatCategoryEnumName.MAP,
  package: PackagesCategoryEnum.CHARTS,
  chartFrame: ChartFrameEnum.COMMON,
  image: 'map_tile.png' // map_amap.png
}
