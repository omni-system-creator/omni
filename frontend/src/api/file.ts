import request from '@/utils/request';

export interface FileItem {
  id: number;
  name: string;
  extension?: string;
  size: number;
  isFolder: boolean;
  contentType?: string;
  parentId?: number | null;
  ownerId: number;
  ownerName?: string;
  deptId?: number | null;
  deptName?: string;
  isPublic?: boolean;
  createdAt: string;
  updatedAt: string;
  hasChildren: boolean;
}

export interface FileQueryParams {
  parentId?: number | null;
  ownerId?: number;
  deptId?: number;
  name?: string;
  isFolder?: boolean;
  isPublic?: boolean;
}

export interface CreateFolderParams {
  name: string;
  parentId?: number | null;
  deptId?: number;
  isPublic?: boolean;
}

export interface UpdateFileParams {
  name?: string;
  parentId?: number | null;
  isPublic?: boolean;
}

export interface RenameFileParams {
  name: string;
}

export interface ShareFileParams {
  fileId: number;
  targetUserIds?: number[];
  permission: string;
  isPublicLink?: boolean;
  expirationTime?: string | null;
}

export interface FileShareItem {
  id: number;
  fileId: number;
  fileName: string;
  isFolder: boolean;
  sharedByUserId: number;
  sharedByUserName: string;
  sharedToUserId: number | null;
  sharedToUserName: string | null;
  permission: string;
  createdAt: string;
  token?: string;
  expirationTime?: string;
}

export const getFileList = (params?: FileQueryParams) => {
  return request.get('/file', { params }) as unknown as Promise<FileItem[]>;
};

export const createFolder = (data: CreateFolderParams) => {
  return request.post('/file/folder', data) as unknown as Promise<FileItem>;
};

export const uploadFile = (file: File, parentId?: number | null, deptId?: number, isPublic: boolean = false) => {
  const formData = new FormData();
  formData.append('file', file);
  if (parentId) formData.append('parentId', parentId.toString());
  if (deptId) formData.append('deptId', deptId.toString());
  formData.append('isPublic', isPublic.toString());
  
  return request.post('/file/upload', formData, {
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  }) as unknown as Promise<FileItem>;
};

export const deleteFile = (id: number) => {
  return request.delete(`/file/${id}`);
};

export const updateFile = (id: number, data: UpdateFileParams) => {
  return request.put(`/file/${id}`, data);
};

export const renameFile = (id: number, data: RenameFileParams) => {
  return request.put(`/file/${id}/rename`, data);
};

export const downloadFile = (id: number) => {
  return request.get(`/file/${id}/download`, {
    responseType: 'blob'
  }) as unknown as Promise<Blob>;
};

export const shareFile = (data: ShareFileParams) => {
  return request.post('/file/share', data);
};

export const getSharedWithMe = () => {
  return request.get('/file/shared/me') as unknown as Promise<FileShareItem[]>;
};

export const getMySharedFiles = () => {
  return request.get('/file/shared/others') as unknown as Promise<FileShareItem[]>;
};
