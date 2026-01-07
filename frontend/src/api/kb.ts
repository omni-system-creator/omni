import request from '../utils/request'
import type { 
  KbInfoDto, 
  CreateKbDto, 
  UpdateKbDto,
  KbFileDto, 
  KbNodeDto, 
  ChatMessageDto, 
  SendMessageDto,
  SiliconModelDto,
  CreateKbFolderDto
} from '../types/kb'

// --- KB Management ---

export function getKbs() {
  return request.get<any, KbInfoDto[]>('/kb')
}

export function getKb(id: string) {
  return request.get<any, KbInfoDto>(`/kb/${id}`)
}

export function createKb(data: CreateKbDto) {
  return request.post<any, KbInfoDto>('/kb', data)
}

export function updateKb(id: string, data: UpdateKbDto) {
  return request.put<any, any>(`/kb/${id}`, data)
}

export function deleteKb(id: string) {
  return request.delete<any, any>(`/kb/${id}`)
}

// --- File Management ---

export function getKbFiles(kbId: string) {
  return request.get<any, KbFileDto[]>(`/kb/${kbId}/files`)
}

export function getKbFolders(kbId: string, parentId?: string) {
  return request.get<any, KbFileDto[]>(`/kb/${kbId}/folders`, { params: { parentId } })
}

export function createKbFolder(kbId: string, data: CreateKbFolderDto) {
  return request.post<any, KbFileDto>(`/kb/${kbId}/folders`, data)
}

export function uploadKbFile(kbId: string, file: File, parentId?: string) {
  const formData = new FormData()
  formData.append('file', file)
  const url = parentId ? `/kb/${kbId}/files?parentId=${parentId}` : `/kb/${kbId}/files`
  return request.post<any, KbFileDto>(url, formData, {
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
}

export function deleteKbFile(fileId: string) {
  return request.delete<any, any>(`/kb/files/${fileId}`)
}

export function renameKbFile(fileId: string, name: string) {
  return request.put<any, any>(`/kb/files/${fileId}/rename`, { name })
}

export function moveKbFile(fileId: string, targetFolderId?: string) {
  return request.put<any, any>(`/kb/files/${fileId}/move`, { targetFolderId })
}

export function getKbFileDownloadUrl(fileId: string) {
  return `/api/kb/files/${fileId}/download`
}

// --- Catalog ---

export function getKbNodes(kbId: string) {
  return request.get<any, KbNodeDto[]>(`/kb/${kbId}/nodes`)
}

export function getKbNodeDetail(key: string) {
  return request.get<any, KbNodeDto>(`/kb/nodes/${key}`)
}

// --- Chat ---

export function getChatHistory(kbId: string) {
  return request.get<any, ChatMessageDto[]>(`/kb/${kbId}/chat`)
}

export function deleteChatHistory(kbId: string) {
  return request.delete<any, any>(`/kb/${kbId}/chat`)
}

export function deleteKbQaHistory(id: string) {
  return request.delete<any, any>(`/kb/chat/message/${id}`)
}

export function sendChatMessage(data: SendMessageDto) {
  return request.post<any, ChatMessageDto>('/kb/chat', data)
}

export function getAvailableModels() {
  return request.get<any, SiliconModelDto[]>('/kb/models')
}
