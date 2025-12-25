import { http } from '@/api/http'
import { httpErrorHandle } from '@/utils'
import { RequestHttpEnum, ModuleTypeEnum } from '@/enums/httpEnum'
import {LoginResult, UserInfoResult} from './system'

// * 登录
export const loginApi = async (data: object) => {
  try {
    const res = await http(RequestHttpEnum.POST)<LoginResult>(`/login`, data) //  await http(RequestHttpEnum.POST)<LoginResult>(`${ModuleTypeEnum.SYSTEM}/login`, data)
    return res
  } catch (err) {
    httpErrorHandle()
  }
}

// * 登出
export const logoutApi = async () => {
  try {
    const res = await http(RequestHttpEnum.GET)(`/logout`) //  await http(RequestHttpEnum.GET)(`${ModuleTypeEnum.SYSTEM}/logout`)
    return res
  } catch (err) {
    httpErrorHandle()
  }
}

// * 获取用户信息
export const getUserInfoApi = async () => {
  try {
    const res = await http(RequestHttpEnum.GET)<UserInfoResult>(`/getInfo`) //  await http(RequestHttpEnum.POST)<LoginResult>(`${ModuleTypeEnum.SYSTEM}/login`, data)
    return res
  } catch (err) {
    httpErrorHandle()
  }
}

// * 获取 oss 上传接口
export const ossUrlApi = async (data: object) => {
  try {
    const res = await http(RequestHttpEnum.GET)<{
      /**
       * bucket 地址
       */
      bucketURL?: string
    }>(`/bigview/getOssInfo`, data)
    return res
  } catch (err) {
    httpErrorHandle()
  }
}

export const getWorkflowInstanceList = async (params: any) => {
  try {
    const res = await http(RequestHttpEnum.GET)<any>(`instance/list`, params)
    return res
  } catch (err) {
    httpErrorHandle()
  }
}

export const getWorkflowInstanceData = async (params: any, signal?: AbortSignal) => {
  try {
    const res = await http(RequestHttpEnum.GET)<any>(`instance/data`, params, { signal })
    return res
  } catch (err) {
    httpErrorHandle()
  }
}

// * 上传数据源文件（JSON/CSV）
export const uploadDatasourceFileApi = async (file: File, fileType: 'json' | 'csv') => {
  try {
    const formData = new FormData()
    formData.append('file', file)
    formData.append('fileType', fileType)
    
    const res = await http(RequestHttpEnum.POST)<{
      fileName: string
      filePath: string
      fileType: string
      originalName: string
      fileSize: number
    }>(`${ModuleTypeEnum.DATASOURCE}/uploadFile`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    })
    return res
  } catch (err) {
    httpErrorHandle()
  }
}

// * 删除数据源文件
export const deleteDatasourceFileApi = async (filePath: string) => {
  try {
    const res = await http(RequestHttpEnum.DELETE)<{
      filePath: string
      deleted: boolean
    }>(`${ModuleTypeEnum.DATASOURCE}/deleteFile?filePath=${encodeURIComponent(filePath)}`)
    return res
  } catch (err) {
    httpErrorHandle()
  }
}

// * 获取数据源文件内容
export const getDatasourceFileContentApi = async (filePath: string) => {
  try {
    const res = await http(RequestHttpEnum.GET)<{
      filePath: string
      content: string
    }>(`${ModuleTypeEnum.DATASOURCE}/getFileContent?filePath=${encodeURIComponent(filePath)}`)
    return res
  } catch (err) {
    httpErrorHandle()
  }
}
