import request from '@/utils/request';
import qs from 'qs';

export interface EbomDocumentDto {
  id: number;
  name: string;
  path: string;
  fileType: string;
  size: number;
  uploadedAt: string;
}

export interface EbomItemDto {
  key: string;
  title: string;
  spec: string;
  qty: number;
  unit: string;
  status: string;
  productType: string;
  version: string;
  designer: string;
  isLeaf: boolean;
  relatedDocuments: EbomDocumentDto[];
  children: EbomItemDto[];
}

export interface EbomDetailDto {
  key: string;
  title: string;
  version: string;
  designer: string;
  status: string;
  productType: string;
  spec: string;
  unit: string;
  relatedDocuments: EbomDocumentDto[];
}

export interface CreateEbomItemDto {
  key: string;
  title: string;
  spec: string;
  unit: string;
  productType: string;
  version: string;
  designer: string;
  relatedDocuments: EbomDocumentDto[];
  parentId: string;
  qty: number;
  isLeaf: boolean;
}

export interface AddChildItemDto {
  parentId: string;
  childId: string;
  qty: number;
}

export interface UpdateEbomItemDto {
  title: string;
  spec: string;
  unit: string;
  productType: string;
  status: string;
  version: string;
  designer: string;
  relatedDocuments: EbomDocumentDto[];
}

export const initPdmData = () => {
  return request.post<any, boolean>('/pdm/init');
};

export const getEbomTrees = () => {
  return request.get<any, EbomItemDto[]>('/pdm/ebom/tree');
};

export const createEbomItem = (data: CreateEbomItemDto) => {
  return request.post<any, EbomItemDto>('/pdm/ebom/create', data);
};

export const updateEbomItem = (id: string, data: UpdateEbomItemDto) => {
  return request.put<any, EbomItemDto>(`/pdm/ebom/items/${id}`, data);
};

export const deleteEbomItem = (id: string) => {
  return request.delete<any, boolean>(`/pdm/ebom/items/${id}`);
};

export const getEbomItem = (id: string) => {
  return request.get<any, EbomDetailDto>(`/pdm/ebom/items/${id}`);
};

export const getEbomChildren = (id: string) => {
  return request.get<any, EbomItemDto[]>(`/pdm/ebom/items/${id}/children`);
};

export const uploadEbomDocument = (file: File) => {
  const formData = new FormData();
  formData.append('file', file);
  return request.post<any, EbomDocumentDto>('/pdm/ebom/documents/upload', formData, {
    headers: {
      'Content-Type': 'multipart/form-data',
    },
  });
};

export const addChildItem = (data: AddChildItemDto) => {
  return request.post<any, boolean>('/pdm/ebom/items/children', data);
};

export const updateChildItemQty = (parentId: string, childId: string, qty: number) => {
  return request.put<any, boolean>(`/pdm/ebom/items/${parentId}/children/${childId}/qty`, { qty });
};

export const removeChildItem = (parentId: string, childId: string) => {
  return request.delete<any, boolean>(`/pdm/ebom/items/${parentId}/children/${childId}`);
};

export const searchEbomItems = (keyword: string, excludeId: string) => {
  return request.get<any, EbomItemDto[]>('/pdm/ebom/search', { params: { keyword, excludeId } });
};

export const importEbom = (file: File) => {
  const formData = new FormData();
  formData.append('file', file);
  return request.post<any, boolean>('/pdm/ebom/import', formData, {
    headers: {
      'Content-Type': 'multipart/form-data',
    },
  });
};

export const exportEbom = (rootId?: string) => {
  // Return blob for download
  return request.get('/pdm/ebom/export', { 
    params: { rootId },
    responseType: 'blob' 
  });
};

export const compareEbom = (itemIds: string[]) => {
  return request.get<any, any>('/pdm/ebom/compare', { 
    params: { itemIds },
    paramsSerializer: params => qs.stringify(params, { arrayFormat: 'repeat' })
  });
};
