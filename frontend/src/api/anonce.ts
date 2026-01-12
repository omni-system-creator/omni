import request from '@/utils/request';

export interface AnonceDto {
  id: number;
  title: string;
  content: string;
  type: string;
  status: string;
  priority: string;
  publishTime?: string;
  createdAt: string;
  updatedAt: string;
  createdBy?: number;
}

export interface CreateAnonceDto {
  title: string;
  content: string;
  type: string;
  priority?: string;
}

export interface UpdateAnonceDto {
  title?: string;
  content?: string;
  type?: string;
  priority?: string;
}

export interface AnonceQueryDto {
  title?: string;
  type?: string;
  status?: string;
  page: number;
  pageSize: number;
}

export const getAnonceList = (params: AnonceQueryDto) => {
  return request.get<any, { items: AnonceDto[]; total: number }>('/anonce', { params });
};

export const getAnonce = (id: number) => {
  return request.get<any, AnonceDto>(`/anonce/${id}`);
};

export const createAnonce = (data: CreateAnonceDto) => {
  return request.post<any, AnonceDto>('/anonce', data);
};

export const updateAnonce = (id: number, data: UpdateAnonceDto) => {
  return request.put<any, AnonceDto>(`/anonce/${id}`, data);
};

export const deleteAnonce = (id: number) => {
  return request.delete<any, boolean>(`/anonce/${id}`);
};

export const publishAnonce = (id: number) => {
  return request.post<any, boolean>(`/anonce/${id}/publish`);
};

export const revokeAnonce = (id: number) => {
  return request.post<any, boolean>(`/anonce/${id}/revoke`);
};
