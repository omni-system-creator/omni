import request from '@/utils/request';

export const login = (data: any) => {
  return request({
    url: '/auth/login',
    method: 'post',
    data,
  });
};

export const register = (data: any) => {
  return request({
    url: '/auth/register',
    method: 'post',
    data,
  });
};

export const uploadRegistrationFile = (file: File) => {
  const formData = new FormData();
  formData.append('file', file);
  return request({
    url: '/auth/upload-registration-file',
    method: 'post',
    data: formData,
    headers: {
      'Content-Type': 'multipart/form-data',
    },
  });
};

export const recognizeLicense = (file: File) => {
  const formData = new FormData();
  formData.append('file', file);
  return request({
    url: '/auth/recognize-license',
    method: 'post',
    data: formData,
    headers: {
      'Content-Type': 'multipart/form-data',
    },
    timeout: 60000,
  });
};

export const getRoutes = () => {
  return request.get('/auth/routes');
};

export const getPermissions = () => {
  return request.get('/auth/permissions');
};
