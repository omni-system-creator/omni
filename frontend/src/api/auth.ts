import request from '@/utils/request';

export const login = (data: any) => {
  return request({
    url: '/auth/login',
    method: 'post',
    data,
  });
};
