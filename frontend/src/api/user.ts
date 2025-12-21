import request from '@/utils/request';

export interface UpdateProfileDto {
  nickname?: string;
  email?: string;
  phone?: string;
}

export interface ChangePasswordDto {
  oldPassword: string;
  newPassword: string;
}

export const getUserInfo = () => {
  return request.get('/user/me');
};

export const updateProfile = (data: UpdateProfileDto) => {
  return request.put('/user/profile', data);
};

export const changePassword = (data: ChangePasswordDto) => {
  return request.post('/user/change-password', data);
};

export const uploadAvatar = (file: File) => {
  const formData = new FormData();
  formData.append('file', file);
  return request.post('/user/avatar', formData, {
    headers: {
      'Content-Type': 'multipart/form-data',
    },
  });
};
