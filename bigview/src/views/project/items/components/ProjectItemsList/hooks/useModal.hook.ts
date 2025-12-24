import { ref } from 'vue'
import { ChartEnum } from '@/enums/pageEnum'
import { fetchPathByName, routerTurnByPath, openNewWindow, previewPath, goDialog } from '@/utils'
import { DialogEnum } from '@/enums/pluginEnum'
import { ResultEnum } from '@/enums/httpEnum'
import { createProjectApi, fetchProjectApi, saveProjectApi } from '@/api/path'
import { Chartype } from '../../../index.d'
export const useModalDataInit = () => {
  const modalShow = ref<boolean>(false)
  const modalData = ref<Chartype | null>(null)

  // 关闭 modal
  const closeModal = () => {
    modalShow.value = false
    modalData.value = null
  }

  // 缩放处理
  const resizeHandle = (cardData: Chartype) => {
    if (!cardData) return
    modalShow.value = true
    modalData.value = cardData
  }

  // 编辑处理
  const editHandle = (cardData: Chartype) => {
    if (!cardData) return
    const path = fetchPathByName(ChartEnum.CHART_HOME_NAME, 'href')
    routerTurnByPath(path, [cardData.id], undefined, true)
  }

  // 预览处理
  const previewHandle = (cardData: Chartype) => {
    openNewWindow(previewPath(cardData.id))
  }

  const copyHandle = async (cardData: Chartype, onRefresh?: () => void) => {
    if (!cardData) return
    const srcRes: any = await fetchProjectApi({ projectId: cardData.id })
    if (!srcRes || srcRes.code !== ResultEnum.SUCCESS || !srcRes.data) return
    if (!srcRes.data.content) {
      goDialog({
        type: DialogEnum.ERROR,
        message: '该项目内容为为空，请先保存项目内容再进行复制操作！',
        closeNegativeText: true,
        onPositiveCallback: () => {
        }
      })
      return
    }
    const name = `${srcRes.data.projectName} 副本`
    const createRes: any = await createProjectApi({ projectName: name, remarks: srcRes.data.remarks })
    if (!createRes || createRes.code !== ResultEnum.SUCCESS || !createRes.data) return
    const newId = createRes.data.id
    const form = new FormData()
    form.append('projectId', `${newId}`)
    form.append('content', srcRes.data.content || '{}')
    const saveRes = await saveProjectApi(form)
    if (!saveRes || saveRes.code !== ResultEnum.SUCCESS) return
    onRefresh && onRefresh()
    goDialog({
      type: DialogEnum.WARNING,
      message: '复制成功！是否打开副本的编辑页？',
      onPositiveCallback: () => {
        const path = fetchPathByName(ChartEnum.CHART_HOME_NAME, 'href')
        routerTurnByPath(path, [newId], undefined, true)
      }
    })
  }

  return {
    modalData,
    modalShow,
    closeModal,
    resizeHandle,
    editHandle,
    copyHandle,
    previewHandle
  }
}
