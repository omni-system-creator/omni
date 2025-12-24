import { ConfigType, PackagesCategoryEnum, ChartFrameEnum } from '@/packages/index.d'
import { ChatCategoryEnum,ChatCategoryEnumName } from '../../index.d'

export const TestingPointConfig: ConfigType = {
    key: 'TestingPoint',
    chartKey: 'VTestingPoint',
    conKey: 'VCTestingPoint',
    title: '试验测点',
    category: ChatCategoryEnum.MORE,
    categoryName: ChatCategoryEnumName.MORE,
    package: PackagesCategoryEnum.DECORATES,
    chartFrame: ChartFrameEnum.STATIC,
    image: 'flow-circle.png'
}
