// 公共类型声明
import { ConfigType, PackagesCategoryEnum, ChartFrameEnum } from '@/packages/index.d'
// 当前[信息模块]分类声明
import { ChatCategoryEnum,ChatCategoryEnumName } from '../../index.d'

export const AdvConfig: ConfigType = {
  key: 'AdvComplex',
  chartKey: 'VAdvComplex',
  conKey: 'VCAdvComplex',
  title: '高级图形',
  category: ChatCategoryEnum.CUSTOM,
  categoryName: ChatCategoryEnumName.CUSTOM,
  package: PackagesCategoryEnum.CHARTS,
  chartFrame: ChartFrameEnum.ECHARTS,
  image: 'AdvChart.png'
}