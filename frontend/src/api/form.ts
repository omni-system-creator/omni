import request from '@/utils/request';

export interface FormCategory {
  id?: number;
  name: string;
  parentId?: number | null;
  sortOrder: number;
  children?: FormCategory[];
}

export interface FormDefinition {
  id?: number;
  categoryId: number;
  name: string;
  code?: string;
  description?: string;
  version?: string;
  isPublished?: boolean;
  formConfig?: string;
  formItems?: string;
  manageRoleIds?: string;
  submitRoleIds?: string;
  fillRoleIds?: string;
  viewRoleIds?: string;
  requiresLogin?: boolean;
  limitOnePerUser?: boolean;
  createdAt?: string;
  updatedAt?: string;
}

// Categories
export function getCategoryTree() {
  return request.get<FormCategory[]>('/form/categories');
}

export function createCategory(data: any) {
  return request.post('/form/categories', data);
}

export function updateCategory(id: number, data: any) {
  return request.put(`/form/categories/${id}`, data);
}

export function deleteCategory(id: number) {
  return request.delete(`/form/categories/${id}`);
}

// Forms
export function getFormList(params: any) {
  return request.get<{ items: FormDefinition[]; total: number }>('/form', { params });
}

export function getFormDetail(id: string | number) {
  return request.get<FormDefinition>(`/form/${id}`);
}

export function createForm(data: any) {
  return request.post('/form', data);
}

export function updateForm(id: number, data: any) {
  return request.put(`/form/${id}`, data);
}

export function deleteForm(id: number) {
  return request.delete(`/form/${id}`);
}

export function submitForm(data: { formId: number; data: string; submittedBy: string }) {
  return request.post('/form/submit', data);
}

export function getFormResults(formId: number, params: any) {
  return request.get(`/form/${formId}/results`, { params });
}