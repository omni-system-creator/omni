import request from '../utils/request'
import type { 
  KbInfoDto, 
  CreateKbDto, 
  KbFileDto, 
  KbNodeDto, 
  ChatMessageDto, 
  SendMessageDto 
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

export function deleteKb(id: string) {
  return request.delete<any, any>(`/kb/${id}`)
}

// --- File Management ---

export function getKbFiles(kbId: string) {
  return request.get<any, KbFileDto[]>(`/kb/${kbId}/files`)
}

export function uploadKbFile(kbId: string, file: File) {
  const formData = new FormData()
  formData.append('file', file)
  return request.post<any, KbFileDto>(`/kb/${kbId}/files`, formData, {
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
}

export function deleteKbFile(fileId: string) {
  return request.delete<any, any>(`/kb/files/${fileId}`)
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

export function sendChatMessage(data: SendMessageDto) {
  return request.post<any, ChatMessageDto>('/kb/chat', data)
}
