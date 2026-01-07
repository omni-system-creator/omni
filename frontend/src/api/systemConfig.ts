import request from '@/utils/request';

export const ConfigType = {
  String: 0,
  Number: 1,
  Boolean: 2,
  Text: 3,
  Image: 4,
  File: 5,
  Json: 6
} as const;

export type ConfigType = typeof ConfigType[keyof typeof ConfigType];

export interface SystemConfigDto {
  id: number;
  category: string;
  key: string;
  type: ConfigType;
  value: string;
  description: string;
  isSystem: boolean;
  orgId?: number;
  isOverridable: boolean;
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

export const deleteConfig = (id: number) => {
  return request.delete(`/systemconfig/${id}`);
};
