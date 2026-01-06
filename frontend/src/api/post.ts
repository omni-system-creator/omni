import request from '@/utils/request';

export interface Post {
  id: number;
  code: string;
  fullCode: string;
  name: string;
  description?: string;
  sortOrder: number;
  isActive: boolean;
  deptId?: number;
  deptName?: string;
  createdAt: string;
}

export interface CreatePostParams {
  code: string;
  name: string;
  description?: string;
  sortOrder: number;
  isActive: boolean;
  deptId?: number;
}

export interface UpdatePostParams {
  code?: string;
  name?: string;
  description?: string;
  sortOrder?: number;
  isActive?: boolean;
  deptId?: number;
}

export const getPostList = (deptId?: number) => {
  return request.get<any, Post[]>('/post', { params: { deptId } });
};

export const getPostById = (id: number) => {
  return request.get<any, Post>(`/post/${id}`);
};

export const createPost = (data: CreatePostParams) => {
  return request.post('/post', data);
};

export const updatePost = (id: number, data: UpdatePostParams) => {
  return request.put(`/post/${id}`, data);
};

export const deletePost = (id: number) => {
  return request.delete(`/post/${id}`);
};
