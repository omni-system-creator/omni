import request from '../utils/request'
import type { ProjectFullDto, ProjectListItem } from '../types/project'

export function getProjects(params?: any) {
  return request.get<any, ProjectListItem[]>('/project', { params })
}

export function getProject(code: string) {
  return request.get<any, ProjectFullDto>(`/project/${code}`)
}

export function saveProject(data: ProjectFullDto) {
  return request.post<any, boolean>('/project', data)
}
