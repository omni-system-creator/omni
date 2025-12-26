import request from '@/utils/request';

// Categories
export interface FormCategory {
  id?: number;
  name: string;
  parentId?: number | null;
  sort?: number;
  children?: FormCategory[];
}

export function getCategoryTree(params?: any) {
  // Mock data for now if backend is not ready, but normally this calls API
  // return request({
  //   url: '/api/form/category/tree',
  //   method: 'get',
  //   params
  // });
  
  // Return mock promise for UI development
  return Promise.resolve({
    data: [
      {
        id: 1,
        name: '人事管理',
        children: [
          { id: 11, name: '入职申请' },
          { id: 12, name: '请假申请' }
        ]
      },
      {
        id: 2,
        name: '行政管理',
        children: [
          { id: 21, name: '物资申领' }
        ]
      }
    ]
  });
}

export function createCategory(data: FormCategory) {
  return Promise.resolve({ code: 200, message: 'Success' });
}

export function updateCategory(id: number, data: FormCategory) {
  return Promise.resolve({ code: 200, message: 'Success' });
}

export function deleteCategory(id: number) {
  return Promise.resolve({ code: 200, message: 'Success' });
}

// Forms
export interface FormDefinition {
  id?: number;
  name: string;
  categoryId: number;
  description?: string;
  status?: number; // 0: Draft, 1: Published
  content?: string;
  publishUrl?: string;
  createTime?: string;
}

export function getFormList(params: any) {
  // return request({
  //   url: '/api/form/list',
  //   method: 'get',
  //   params
  // });
  
  return Promise.resolve({
    data: {
      total: 2,
      list: [
        { id: 1, name: '员工入职登记表', categoryId: 11, status: 1, createTime: '2023-10-01', description: '用于新员工入职信息采集' },
        { id: 2, name: '请假条', categoryId: 12, status: 0, createTime: '2023-10-05', description: '员工请假使用' }
      ]
    }
  });
}

export function getFormDetail(id: number) {
  return Promise.resolve({
    data: {
      id,
      name: '员工入职登记表',
      categoryId: 11,
      content: '[]', // JSON string of form schema
      status: 1
    }
  });
}

export function createForm(data: FormDefinition) {
  return Promise.resolve({ code: 200, message: 'Success', data: { id: 99 } });
}

export function updateForm(id: number, data: FormDefinition) {
  return Promise.resolve({ code: 200, message: 'Success' });
}

export function deleteForm(id: number) {
  return Promise.resolve({ code: 200, message: 'Success' });
}

export function publishForm(id: number) {
  return Promise.resolve({ code: 200, message: 'Success', data: { url: `http://localhost:5173/form/submit/${id}` } });
}
