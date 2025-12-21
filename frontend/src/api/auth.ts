import request from '@/utils/request';

export const login = (data: any) => {
  return request({
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
