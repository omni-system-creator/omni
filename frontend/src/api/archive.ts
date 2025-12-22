import request from '@/utils/request';

// --- Interfaces ---

export interface ArchFond {
  id: number;
  code: string;
  name: string;
  description?: string;
  sortOrder: number;
  createdAt: string;
}

export interface CreateFondParams {
  code: string;
  name: string;
  description?: string;
  sortOrder: number;
}

export interface UpdateFondParams {
  code?: string;
  name?: string;
  description?: string;
  sortOrder?: number;
}

export interface ArchType {
  id: number;
  parentId?: number;
  code: string;
  name: string;
  sortOrder: number;
  children?: ArchType[];
}

export interface CreateTypeParams {
  parentId?: number;
  code: string;
  name: string;
  sortOrder: number;
}

export interface UpdateTypeParams {
    parentId?: number;
    code?: string;
    name?: string;
    sortOrder?: number;
}

export interface ArchFile {
  id: number;
  fondId: number;
  fondName: string;
  typeId: number;
  typeName: string;
  boxId?: number;
  boxCode?: string;
  archCode: string;
  title: string;
  docNumber?: string;
  author?: string;
  fileDate?: string;
  year?: string;
  retentionPeriod?: string;
  securityLevel?: string;
  pageCount: number;
  status: number;
  keywords?: string;
  remark?: string;
  sourceFileId?: number;
  createdAt: string;
  attachments?: ArchAttachment[];
}

export interface CreateArchFileParams {
  fondId: number;
  typeId: number;
  boxId?: number;
  archCode: string;
  title: string;
  docNumber?: string;
  author?: string;
  fileDate?: string;
  year?: string;
  retentionPeriod?: string;
  securityLevel?: string;
  pageCount?: number;
  keywords?: string;
  remark?: string;
  sourceFileId?: number;
}

export interface UpdateArchFileParams {
  fondId?: number;
  typeId?: number;
  boxId?: number;
  archCode?: string;
  title?: string;
  docNumber?: string;
  author?: string;
  fileDate?: string;
  year?: string;
  retentionPeriod?: string;
  securityLevel?: string;
  pageCount?: number;
  keywords?: string;
  remark?: string;
}

export interface ArchAttachment {
  id: number;
  fileName: string;
  extension?: string;
  size: number;
  filePath?: string;
  fileId?: number;
}

export interface ArchQueryParams {
  fondId?: number;
  typeId?: number;
  boxId?: number;
  title?: string;
  archCode?: string;
  year?: string;
  retentionPeriod?: string;
  securityLevel?: string;
  keyword?: string;
  page?: number;
  pageSize?: number;
}

// --- API ---

// Fond
export const getFonds = () => {
  return request.get('/archive/fond') as unknown as Promise<ArchFond[]>;
};

export const createFond = (data: CreateFondParams) => {
  return request.post('/archive/fond', data) as unknown as Promise<ArchFond>;
};

export const updateFond = (id: number, data: UpdateFondParams) => {
  return request.put(`/archive/fond/${id}`, data);
};

export const deleteFond = (id: number) => {
  return request.delete(`/archive/fond/${id}`);
};

// Type
export const getTypes = () => {
  return request.get('/archive/type') as unknown as Promise<ArchType[]>;
};

export const createType = (data: CreateTypeParams) => {
  return request.post('/archive/type', data) as unknown as Promise<ArchType>;
};

export const updateType = (id: number, data: UpdateTypeParams) => {
    return request.put(`/archive/type/${id}`, data);
};

export const deleteType = (id: number) => {
    return request.delete(`/archive/type/${id}`);
};

// File
export const getArchFiles = (params: ArchQueryParams) => {
  return request.get('/archive/file', { params }) as unknown as Promise<ArchFile[]>;
};

export const getArchFileById = (id: number) => {
  return request.get(`/archive/file/${id}`) as unknown as Promise<ArchFile>;
};

export const createArchFile = (data: CreateArchFileParams) => {
  return request.post('/archive/file', data) as unknown as Promise<ArchFile>;
};

export const updateArchFile = (id: number, data: UpdateArchFileParams) => {
  return request.put(`/archive/file/${id}`, data);
};

export const deleteArchFile = (id: number) => {
  return request.delete(`/archive/file/${id}`);
};
