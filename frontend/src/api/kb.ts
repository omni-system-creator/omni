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

export async function sendChatMessageStream(
  data: SendMessageDto, 
  onChunk: (content: string) => void,
  onDone?: () => void,
  onError?: (err: any) => void
) {
  try {
    const authData = JSON.parse(localStorage.getItem('oms.auth') || '{}');
    const token = authData.token;
    
    const response = await fetch('/api/kb/chat/stream', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify(data)
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    const reader = response.body?.getReader();
    const decoder = new TextDecoder();
    
    if (!reader) return;

    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      
      const chunk = decoder.decode(value, { stream: true });
      const lines = chunk.split('\n');
      
      for (const line of lines) {
        const trimmed = line.trim();
        if (!trimmed || !trimmed.startsWith('data: ')) continue;
        
        const dataStr = trimmed.slice(6);
        if (dataStr === '[DONE]') {
          onDone?.();
          return;
        }
        
        try {
          const parsed = JSON.parse(dataStr);
          if (parsed.content) {
            onChunk(parsed.content);
          }
        } catch (e) {
          console.error('Error parsing SSE data', e);
        }
      }
    }
    onDone?.();
  } catch (error) {
    onError?.(error);
    console.error('Stream error:', error);
  }
}

export function getAvailableModels() {
  return request.get<any, SiliconModelDto[]>('/kb/models')
}
