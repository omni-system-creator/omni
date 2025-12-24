import { ConfigType, PackagesCategoryEnum, ChartFrameEnum } from '@/packages/index.d'
import { ChatCategoryEnum, ChatCategoryEnumName } from '../../index.d'

export const AdvChartConfig: ConfigType = {
  key: 'AdvChart',
  chartKey: 'VAdvChart',
  conKey: 'VCAdvChart',
  title: '高级噪音图表',
  category: ChatCategoryEnum.TABLE,
  categoryName: ChatCategoryEnumName.TABLE,
  package: PackagesCategoryEnum.TABLES,
  chartFrame: ChartFrameEnum.COMMON,
  image: 'adv_chart_noise.png'
}
