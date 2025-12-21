import request from '@/utils/request';

export interface PermissionTreeDto {
  id: number;
  name: string;
  code: string;
  type: string; // MENU, BUTTON
  parentId?: number;
  icon?: string;
  path?: string;
  component?: string;
  sortOrder: number;
  isVisible: boolean;
  children?: PermissionTreeDto[];
}

export interface CreatePermissionDto {
  name: string;
  code: string;
  type: string;
  icon?: string;
  path?: string;
  component?: string;
  parentId?: number;
  sortOrder?: number;
  isVisible?: boolean;
}

export interface UpdatePermissionDto {
  name?: string;
  code?: string;
  type?: string;
  icon?: string;
  path?: string;
  component?: string;
  parentId?: number;
  sortOrder?: number;
  isVisible?: boolean;
}

export interface UpdatePermissionStructureDto {
  id: number;
  parentId?: number;
  sortOrder: number;
}

export const getPermissionList = () => {
  return request.get<any, PermissionTreeDto[]>('/permission');
};

export const createPermission = (data: CreatePermissionDto) => {
  return request.post('/permission', data);
};

export const updatePermission = (id: number, data: UpdatePermissionDto) => {
  return request.put(`/permission/${id}`, data);
};

export const deletePermission = (id: number) => {
  return request.delete(`/permission/${id}`);
};

export const batchUpdateStructure = (data: UpdatePermissionStructureDto[]) => {
  return request.post('/permission/batch-structure', data);
};
