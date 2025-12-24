import { ConfigType, PackagesCategoryEnum, ChartFrameEnum } from '@/packages/index.d'
import { ChatCategoryEnum,ChatCategoryEnumName } from '../../index.d'

export const RemoteDesktopConfig: ConfigType = {
  key: 'RemoteDesktop',
  chartKey: 'VRemoteDesktop',
  conKey: 'VCRemoteDesktop',
  title: '远程桌面查看器',
  category: ChatCategoryEnum.MORE,
  categoryName: ChatCategoryEnumName.MORE,
  package: PackagesCategoryEnum.INFORMATIONS,
  chartFrame: ChartFrameEnum.COMMON,
  image: 'iframe.png'
}
