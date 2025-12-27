import request from '@/utils/request';

export interface InterfaceCategory {
  id: number;
  name: string;
  urlPrefix: string;
  parentId?: number;
  sortOrder: number;
  children?: InterfaceCategory[];
}

export interface InterfaceDefinition {
  id: number;
  categoryId: number;
  categoryName: string;
  name: string;
  path: string;
  fullPath: string;
  method: string;
  description?: string;
  flowConfig?: string;
  isPublished: boolean;
  requiresAuth: boolean;
  viewRoles: number[];
  callRoles: number[];
  manageRoles: number[];
  createdAt: string;
  updatedAt: string;
}

export interface InterfaceListParams {
  categoryId?: number;
  keyword?: string;
  page?: number;
  pageSize?: number;
}

export const interfaceApi = {
  // Categories
  getCategoryTree() {
    return request.get<InterfaceCategory[]>('/interface/categories');
  },

  createCategory(data: { name: string; urlPrefix: string; parentId?: number; sortOrder?: number }) {
    return request.post<InterfaceCategory>('/interface/categories', data);
  },

  updateCategory(id: number, data: { name: string; urlPrefix: string; parentId?: number; sortOrder?: number }) {
    return request.put<InterfaceCategory>(`/interface/categories/${id}`, data);
  },

  deleteCategory(id: number) {
    return request.delete(`/interface/categories/${id}`);
  },

  // Interfaces
  getInterfaces(params: InterfaceListParams) {
    return request.get<{ items: InterfaceDefinition[]; total: number }>('/interface', { params });
  },

  getInterfaceById(id: number) {
    return request.get<InterfaceDefinition>(`/interface/${id}`);
  },

  createInterface(data: Partial<InterfaceDefinition>) {
    return request.post<InterfaceDefinition>('/interface', data);
  },

  updateInterface(id: number, data: Partial<InterfaceDefinition>) {
    return request.put<InterfaceDefinition>(`/interface/${id}`, data);
  },

  deleteInterface(id: number) {
    return request.delete(`/interface/${id}`);
  },

  publishInterface(id: number, isPublished: boolean) {
    return request.put(`/interface/${id}/publish`, null, {
      params: { isPublished }
    });
  },

  // Debug
  debugInterface(id: number, data: { params?: any; body?: any }) {
    return request.post<any>(`/interface/${id}/debug`, data);
  },

  debugFlow(data: { flowConfig: string; data: { params?: any; body?: any; sessionId?: string } }) {
    return request.post<any>('/interface/debug-flow', data);
  }
};
