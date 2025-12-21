import request from '@/utils/request';

export interface SystemConfigDto {
  id: number;
  category: string;
  key: string;
  value: string;
  description: string;
  isSystem: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface UpdateSystemConfigDto {
  value: string;
  description?: string;
}

export const getAllConfigs = () => {
  return request.get<any, SystemConfigDto[]>('/systemconfig');
};

export const updateConfig = (id: number, data: UpdateSystemConfigDto) => {
  return request.put(`/systemconfig/${id}`, data);
};
