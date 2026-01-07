// Frontend types for KB matching Backend DTOs

export interface KbInfoDto {
  id: string;
  name: string;
  description?: string;
  category: string;
  type: string;
  sortOrder: number;
  createdAt: string;
  updatedAt?: string;
  fileCount: number;
  wordCount: number;
}

export interface CreateKbDto {
  name: string;
  description?: string;
  category: string;
  type: string;
}

export interface UpdateKbDto {
  name?: string;
  description?: string;
  category?: string;
  type?: string;
  sortOrder?: number;
}

export interface KbFileDto {
  id: string;
  name: string;
  size: string;
  status: 'uploading' | 'processing' | 'ready' | 'error';
  uploadTime: string;
  isFolder?: boolean;
  parentId?: string | null;
}

export interface CreateKbFolderDto {
  name: string;
  parentId?: string | null;
}

export interface KbNodeSourceDto {
  fileId: string;
  fileName: string;
  page: number;
}

export interface KbNodeDto {
  key: string;
  title: string;
  summary?: string;
  content?: string;
  sources: KbNodeSourceDto[];
  children: KbNodeDto[];
}

export interface ChatMessageDto {
  id?: string;
  role: 'user' | 'ai';
  content: string;
  sources?: KbNodeSourceDto[];
  createdAt?: string;
}

export interface SendMessageDto {
  kbId: string;
  message: string;
  model?: string;
  systemPrompt?: string;
}

export interface SiliconModelDto {
  id: string;
  object: string;
  created: number;
  ownedBy: string;
}
