import { ConfigType, PackagesCategoryEnum, ChartFrameEnum } from '@/packages/index.d'
import { ChatCategoryEnum,ChatCategoryEnumName } from '../../index.d'

export const TestingModelConfig: ConfigType = {
    key: 'TestingModel',
    chartKey: 'VTestingModel',
    conKey: 'VCTestingModel',
    title: '试验模型',
    category: ChatCategoryEnum.MORE,
    categoryName: ChatCategoryEnumName.MORE,
    package: PackagesCategoryEnum.DECORATES,
    chartFrame: ChartFrameEnum.STATIC,
    image: 'model.png'
}
