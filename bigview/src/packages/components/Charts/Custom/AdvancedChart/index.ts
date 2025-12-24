// 公共类型声明
import { ConfigType, PackagesCategoryEnum, ChartFrameEnum } from '@/packages/index.d'
// 当前[信息模块]分类声明
import { ChatCategoryEnum,ChatCategoryEnumName } from '../../index.d'

export const AdvancedConfig: ConfigType = {
  key: 'AdvancedChart',
  chartKey: 'VAdvancedChart',
  conKey: 'VCAdvancedChart',
  title: '高级图表',
  category: ChatCategoryEnum.CUSTOM,
  categoryName: ChatCategoryEnumName.CUSTOM,
  package: PackagesCategoryEnum.CHARTS,
  chartFrame: ChartFrameEnum.ECHARTS,
  image: 'AdvancedChart.png'
}