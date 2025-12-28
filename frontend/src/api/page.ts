import request from '@/utils/request';

// Types
export interface PageCategory {
  id: number;
  name: string;
  parentId?: number | null;
  children?: PageCategory[];
  sortOrder?: number;
}

export interface ApiBinding {
  apiId: number;
  triggerEvent: string; // e.g., 'onMounted', 'onClick_btn1'
  paramsMap?: Record<string, string>; // e.g., { "page": "state.page" }
}

export interface PageDefinition {
  id: number;
  name: string;
  categoryId?: number;
  code?: string; // TSX Code
  config?: string; // Visual Config (JSON)
  apiBindings?: string; // JSON String
  description?: string;
  updatedAt?: string;
}

export interface PageListParams {
    categoryId?: number;
    keyword?: string;
    page?: number;
    pageSize?: number;
}

// API Methods
export const getPageCategoryTree = () => {
  return request.get<any, PageCategory[]>('/page/categories');
};

export const createPageCategory = (data: any) => {
  return request.post<any, PageCategory>('/page/categories', data);
};

export const updatePageCategory = (id: number, data: any) => {
    return request.put<any, PageCategory>(`/page/categories/${id}`, data);
};

export const deletePageCategory = (id: number) => {
    return request.delete(`/page/categories/${id}`);
};

export const getPages = (params: PageListParams) => {
  return request.get<any, { items: PageDefinition[], total: number }>('/page', { params });
};

export const getPageById = (id: number) => {
    return request.get<any, PageDefinition>(`/page/${id}`);
};

export const savePage = (data: any) => {
    if (data.id && data.id > 0) {
        return request.put<any, PageDefinition>(`/page/${data.id}`, data);
    } else {
        return request.post<any, PageDefinition>('/page', data);
    }
};

export const deletePage = (id: number) => {
    return request.delete(`/page/${id}`);
};
