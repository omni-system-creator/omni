import axios from 'axios';
import type { AxiosInstance, AxiosResponse } from 'axios';
import { showToast, showDialog } from 'vant';

export interface ApiResponse<T = any> {
  code: number;
  msg: string;
  data: T;
}

const service: AxiosInstance = axios.create({
  baseURL: '/api',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

service.interceptors.request.use(
  (config) => {
    try {
      const authData = JSON.parse(localStorage.getItem('oms.auth') || '{}');
      const token = authData.token;
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
    } catch (e) {
      // ignore
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

service.interceptors.response.use(
  (response: AxiosResponse<ApiResponse>) => {
    const res = response.data;
    // 如果是二进制数据则直接返回
    if (response.config.responseType === 'blob' || response.config.responseType === 'arraybuffer') {
      return response;
    }
    
    // 适配后端返回结构，假设 200 为成功
    if (res.code !== 200) {
      showToast(res.msg || 'Error');
      return Promise.reject(new Error(res.msg || 'Error'));
    }
    return res.data;
  },
  (error) => {
    if (error.response && error.response.status === 401) {
      showDialog({ message: '登录已过期，请重新登录' }).then(() => {
         // 跳转登录页逻辑，可以在这里处理，或者交给路由守卫
         // window.location.href = '/m/login'; 
      });
    } else {
      showToast(error.message || 'Request Error');
    }
    return Promise.reject(error);
  }
);

export default service;
