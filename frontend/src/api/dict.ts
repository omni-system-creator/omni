import request from '@/utils/request';

// --- Interfaces ---

export interface DictCategoryDto {
  id: number;
  code: string;
  name: string;
  sort: number;
  remark?: string;
  createdAt: string;
  updatedAt: string;
}

export interface CreateDictCategoryDto {
  code: string;
  name: string;
  sort: number;
  remark?: string;
}

export interface UpdateDictCategoryDto {
  name?: string;
  sort?: number;
  remark?: string;
}

export interface DictTypeDto {
  id: number;
  categoryId: number;
  code: string;
  name: string;
  sort: number;
  status: string; // normal, disabled
  remark?: string;
  createdAt: string;
  updatedAt: string;
}

export interface CreateDictTypeDto {
  categoryId: number;
  code: string;
  name: string;
  sort: number;
  status: string;
  remark?: string;
}

export interface UpdateDictTypeDto {
  name?: string;
  sort?: number;
  status?: string;
  remark?: string;
}

export interface DictDataDto {
  id: number;
  dictTypeId: number;
  label: string;
  value: string;
  sort: number;
  isDefault: boolean;
  status: string; // normal, disabled
  remark?: string;
  createdAt: string;
  updatedAt: string;
}

export interface CreateDictDataDto {
  dictTypeId: number;
  label: string;
  value: string;
  sort: number;
  isDefault: boolean;
  status: string;
  remark?: string;
}

export interface UpdateDictDataDto {
  label?: string;
  value?: string;
  sort?: number;
  isDefault?: boolean;
  status?: string;
  remark?: string;
}

// --- API Functions ---

// Categories
export const getDictCategories = () => {
  return request.get<any, DictCategoryDto[]>('/system/dict/categories');
};

export const createDictCategory = (data: CreateDictCategoryDto) => {
  return request.post<any, DictCategoryDto>('/system/dict/categories', data);
};

export const updateDictCategory = (id: number, data: UpdateDictCategoryDto) => {
  return request.put<any, DictCategoryDto>(`/system/dict/categories/${id}`, data);
};

export const deleteDictCategory = (id: number) => {
  return request.delete<any, boolean>(`/system/dict/categories/${id}`);
};

// Types
export const getDictTypes = (categoryId?: number) => {
  return request.get<any, DictTypeDto[]>('/system/dict/types', { params: { categoryId } });
};

export const createDictType = (data: CreateDictTypeDto) => {
  return request.post<any, DictTypeDto>('/system/dict/types', data);
};

export const updateDictType = (id: number, data: UpdateDictTypeDto) => {
  return request.put<any, DictTypeDto>(`/system/dict/types/${id}`, data);
};

export const deleteDictType = (id: number) => {
  return request.delete<any, boolean>(`/system/dict/types/${id}`);
};

// Data
export const getDictData = (typeId?: number, typeCode?: string) => {
  return request.get<any, DictDataDto[]>('/system/dict/data', { params: { typeId, typeCode } });
};

export const createDictData = (data: CreateDictDataDto) => {
  return request.post<any, DictDataDto>('/system/dict/data', data);
};

export const updateDictData = (id: number, data: UpdateDictDataDto) => {
  return request.put<any, DictDataDto>(`/system/dict/data/${id}`, data);
};

export const deleteDictData = (id: number) => {
  return request.delete<any, boolean>(`/system/dict/data/${id}`);
};

// Helper to get dict data by code (for use in other pages)
export const getDictDataByCode = (code: string) => {
  return request.get<any, DictDataDto[]>('/system/dict/data', { params: { typeCode: code } });
};
