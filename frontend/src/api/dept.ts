import request from '@/utils/request';

export const DeptType = {
  Group: 1,
  Company: 2,
  Department: 3
} as const;

export type DeptType = typeof DeptType[keyof typeof DeptType];

export interface Dept {
  id: number;
  parentId: number | null;
  name: string;
  code?: string;
  type: DeptType;
  leader?: string;
  phone?: string;
  email?: string;
  sortOrder: number;
  isActive: boolean;
  x?: number;
  y?: number;
  children?: Dept[];
  createdAt: string;
}

export type DeptDto = Dept;

export interface CreateDeptParams {
  parentId?: number | null;
  name: string;
  code?: string;
  type: DeptType;
  leader?: string;
  phone?: string;
  email?: string;
  sortOrder: number;
  isActive: boolean;
  x?: number;
  y?: number;
}

export interface UpdateDeptParams {
  parentId?: number | null;
  name?: string;
  code?: string;
  type?: DeptType;
  leader?: string;
  phone?: string;
  email?: string;
  sortOrder?: number;
  isActive?: boolean;
  x?: number;
  y?: number;
}

export interface UpdateDeptStructureParams {
    id: number;
    parentId: number | null;
    sortOrder: number;
}

export const getDeptTree = () => {
  return request.get('/dept/tree') as unknown as Promise<Dept[]>;
};

export const getDeptList = getDeptTree;

export const getDept = (id: number) => {
  return request.get(`/dept/${id}`) as unknown as Promise<Dept>;
};

export const createDept = (data: CreateDeptParams) => {
  return request.post('/dept', data) as unknown as Promise<Dept>;
};

export const updateDept = (id: number, data: UpdateDeptParams) => {
  return request.put(`/dept/${id}`, data);
};

export const deleteDept = (id: number) => {
  return request.delete(`/dept/${id}`);
};

export const updateDeptStructure = (data: UpdateDeptStructureParams[]) => {
    return request.put('/dept/structure', data);
};
