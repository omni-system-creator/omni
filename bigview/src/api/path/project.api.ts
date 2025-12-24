import axios from 'axios'
import { http } from '@/api/http'
import { httpErrorHandle } from '@/utils'
import { ContentTypeEnum, RequestHttpEnum, ModuleTypeEnum } from '@/enums/httpEnum'
import { ProjectItem, ProjectDetail } from './project'

// * 项目列表
export const projectListApi = async (data: object) => {
  try {
    const res = await axios.get('/data/items.json')
    return {
      ...res.data,
      data: res.data.rows
    }
  } catch {
    httpErrorHandle()
  }
}

// * 新增项目
export const createProjectApi = async (data: object) => {
  try {
    const res = await axios.get('/data/create.json') 
    return {
      ...res.data,
      data: res.data.rows
    }
  } catch {
    httpErrorHandle()
  }
}

// * 获取项目
export const fetchProjectApi = async (data: object) => {
  try {
    const { data } = await axios.get('/data/item.json') 
    return data
  } catch {
    httpErrorHandle()
  }
}

// * 保存项目
export const saveProjectApi = async (data: object) => {
}

// * 修改项目基础信息
export const updateProjectApi = async (data: object) => {
}

// * 删除项目
export const deleteProjectApi = async (data: object) => {
}

// * 修改发布状态 [-1未发布,1发布]
export const changeProjectReleaseApi = async (data: object) => {
}

// * 上传文件
export const uploadFile = async (data: object) => {
}

// 获取树形结构
export const getDashboardApi = async () => {
}

// 查询图表id
export const queryByChartIdApi = async (chartId: string) => {
}

export const buildSqlApi = async (data: any) => {
}




