import request from '@/utils/request';

export interface RoleDto {
  id: number;
  name: string;
  code: string;
  description?: string;
  isSystem: boolean;
  createdAt: string;
  deptId?: number;
  childRoleIds?: number[];
}

export interface CreateRoleDto {
  name: string;
  code: string;
  description?: string;
  deptId?: number;
  childRoleIds?: number[];
}

export interface UpdateRoleDto {
  name?: string;
  description?: string;
  deptId?: number;
  childRoleIds?: number[];
}

export interface PermissionTreeDto {
  id: number;
  name: string;
  code: string;
  type: string;
  parentId?: number;
  children?: PermissionTreeDto[];
}

export const getRoleList = (deptId?: number) => {
  return request.get<any, RoleDto[]>('/role', { params: { deptId } });
};

export const getRoleById = (id: number) => {
  return request.get<any, RoleDto>(`/role/${id}`);
};

export const createRole = (data: CreateRoleDto) => {
  return request.post('/role', data);
};

export const updateRole = (id: number, data: UpdateRoleDto) => {
  return request.put(`/role/${id}`, data);
};

export const deleteRole = (id: number) => {
  return request.delete(`/role/${id}`);
};

export const getAllPermissions = () => {
  return request.get<any, PermissionTreeDto[]>('/role/permissions');
};

export const getRolePermissionIds = (roleId: number) => {
  return request.get<any, number[]>(`/role/${roleId}/permissions`);
};

export const assignRolePermissions = (roleId: number, permissionIds: number[]) => {
  return request.post(`/role/${roleId}/permissions`, { permissionIds });
};
