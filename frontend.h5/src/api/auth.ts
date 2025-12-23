import request from '@/utils/request';

export interface LoginResponse {
  token: string;
  user: {
    id: number;
    username: string;
    nickname: string;
    avatar: string;
    status: string;
  };
}

export const login = (data: any) => {
  return request<any, LoginResponse>({
    url: '/auth/login',
    method: 'post',
    data,
  });
};

export const getRoutes = () => {
  return request.get('/auth/routes');
};

export const getPermissions = () => {
  return request.get('/auth/permissions');
};
