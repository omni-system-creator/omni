import request from '@/utils/request';

// Categories
export interface FormCategory {
  id?: number;
  name: string;
  parentId?: number | null;
  sortOrder?: number;
  children?: FormCategory[];
}

export function getCategoryTree() {
  return request({
    url: '/form/categories/tree',
    method: 'get'
  });
}

export function createCategory(data: FormCategory) {
  return request({
    url: '/form/categories',
    method: 'post',
    data
  });
}

export function updateCategory(id: number, data: FormCategory) {
  return request({
    url: `/form/categories/${id}`,
    method: 'put',
    data
  });
}

export function deleteCategory(id: number) {
  return request({
    url: `/form/categories/${id}`,
    method: 'delete'
  });
}

// Forms
export interface FormDefinition {
  id?: number;
  categoryId: number;
  name: string;
  code?: string;
  description?: string;
  formItems?: string; // JSON string
  isPublished?: boolean;
  requiresLogin?: boolean;
  createdAt?: string;
  updatedAt?: string;
}

export function getFormList(params: { categoryId?: number }) {
  return request({
    url: '/form/definitions',
    method: 'get',
    params
  });
}

export function getFormDetail(id: number) {
  return request({
    url: `/form/definitions/${id}`,
    method: 'get'
  });
}

export function createForm(data: FormDefinition) {
  return request({
    url: '/form/definitions',
    method: 'post',
    data
  });
}

export function updateForm(id: number, data: FormDefinition) {
  return request({
    url: `/form/definitions/${id}`,
    method: 'put',
    data
  });
}

export function publishForm(_id: number, _isPublished: boolean) {
  // Since we don't have a specific publish endpoint, we get the form first (or assume we have data) 
  // and then update it. However, the best way here is to just expect the component to call updateForm.
  // But to keep compatibility with existing code imports, I'll add this.
  // Actually, better to just let the component handle the logic, but I need to export the function 
  // if it's imported.
  // Let's implement it as a partial update if possible, but the API expects a full DTO usually.
  // The updateForm expects FormDefinition.
  // I will assume the caller passes the full object or I'll just change the component to use updateForm.
  // For now, let's export a helper that requires the full object or just change the component.
  // I will NOT export publishForm here, I will remove it from FormList.vue imports and use updateForm there.
  return Promise.reject('Use updateForm instead');
}

export function deleteForm(id: number) {
  return request({
    url: `/form/definitions/${id}`,
    method: 'delete'
  });
}

export function submitForm(data: { formId: number; data: string; submittedBy?: string }) {
  return request({
    url: '/form/submit',
    method: 'post',
    data
  });
}
