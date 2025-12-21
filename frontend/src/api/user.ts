import request from '@/utils/request';

export interface UserListDto {
  id: number;
  username: string;
  nickname?: string;
  email?: string;
  phone?: string;
  avatar?: string;
  isActive: boolean;
  createdAt: string;
  lastLoginAt?: string;
  roles: string[];
}

export interface CreateUserDto {
  username: string;
  password?: string; // 可选，若为空则后端设置默认密码
  nickname?: string;
  roleIds: number[];
}

export interface UpdateUserDto {
  nickname?: string;
  email?: string;
  phone?: string;
  isActive?: boolean;
  roleIds?: number[];
}

export interface UpdateProfileDto {
  nickname?: string;
  email?: string;
  phone?: string;
}

export interface ChangePasswordDto {
  oldPassword?: string; // 管理员重置密码时不需要
  newPassword: string;
}

export const uploadAvatar = (data: FormData) => {
  return request({
    url: '/user/avatar',
    method: 'post',
    headers: {
      'Content-Type': 'multipart/form-data',
    },
    data,
  });
};

export const getCurrentUser = () => {
  return request.get('/user/me');
};

export const updateProfile = (data: UpdateProfileDto) => {
  return request.put('/user/profile', data);
};

export const changePassword = (data: ChangePasswordDto) => {
  return request.post('/user/change-password', data);
};

// --- 管理员接口 ---

export const getUserList = () => {
  return request.get<any, UserListDto[]>('/user');
};

export const getUserById = (id: number) => {
  return request.get<any, UserListDto>(`/user/${id}`);
};

export const createUser = (data: CreateUserDto) => {
  return request.post('/user', data);
};

export const updateUser = (id: number, data: UpdateUserDto) => {
  return request.put(`/user/${id}`, data);
};

export const deleteUser = (id: number) => {
  return request.delete(`/user/${id}`);
};

export const resetUserPassword = (id: number, data: ChangePasswordDto) => {
  return request.post(`/user/${id}/reset-password`, data);
};
