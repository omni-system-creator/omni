import { RouteRecordRaw } from 'vue-router'
import { PreviewEnum } from '@/enums/pageEnum'

// 引入路径
const importPath = {
  'PreviewEnum.CHART_PREVIEW_NAME': () => import('@/views/preview/wrapper.vue'),
  'PreviewEnum.CHART_VIEW_NAME': () => import('@/views/preview/wrapper.vue')
}

const chartRoutes: RouteRecordRaw[] = [
  {
    path: PreviewEnum.CHART_PREVIEW,
    name: PreviewEnum.CHART_PREVIEW_NAME,
    component: importPath['PreviewEnum.CHART_PREVIEW_NAME'],
    meta: {
      title: '预览',
      isRoot: true
    }
  },
  {
    path: PreviewEnum.CHART_VIEW,
    name: PreviewEnum.CHART_VIEW_NAME,
    component: importPath['PreviewEnum.CHART_VIEW_NAME'],
    meta: {
      title: '查看',
      isRoot: true
    }
  }
]

export default chartRoutes