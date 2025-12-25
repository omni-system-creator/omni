import { http } from '@/api/http'
import { RequestHttpEnum, ContentTypeEnum } from '@/enums/httpEnum'

// * 项目列表
export const projectListApi = async (params: object) => {
    return http(RequestHttpEnum.GET)('/bigview/project/list', params)
}

// * 新增项目
export const createProjectApi = async (data: object) => {
    return http(RequestHttpEnum.POST)('/bigview/project/create', data)
}

// * 获取项目
export const fetchProjectApi = async (params: object) => {
    return http(RequestHttpEnum.GET)('/bigview/project/detail', params)
}

// * 保存项目 (update content)
export const saveProjectApi = async (data: object) => {
    return http(RequestHttpEnum.POST)('/bigview/project/update', data)
}

// * 修改项目基础信息
export const updateProjectApi = async (data: object) => {
    return http(RequestHttpEnum.POST)('/bigview/project/update', data)
}

// * 删除项目
export const deleteProjectApi = async (params: object) => {
    return http(RequestHttpEnum.DELETE)('/bigview/project/delete', params)
}

// * 修改发布状态 [-1未发布,1发布]
export const changeProjectReleaseApi = async (data: object) => {
    return http(RequestHttpEnum.POST)('/bigview/project/publish', data)
}

// * 上传文件
export const uploadFile = async (data: object) => {
    return http(RequestHttpEnum.POST)('/bigview/upload', data, ContentTypeEnum.FORM_DATA)
}
