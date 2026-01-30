import request from '@/utils/request';

export interface UserConfigDto {
  key: string;
  value: string | null;
  description?: string;
}

export const userConfigApi = {
  // 获取配置
  getConfigs(prefix?: string) {
    return request<UserConfigDto[]>({
      url: '/UserConfig',
      method: 'get',
      params: { prefix },
    });
  },

  // 保存配置
  setConfig(data: UserConfigDto) {
    return request<void>({
      url: '/UserConfig',
      method: 'post',
      data,
    });
  },

  // 删除配置
  deleteConfig(key: string) {
    return request<void>({
      url: `/UserConfig/${key}`,
      method: 'delete',
    });
  },
};
