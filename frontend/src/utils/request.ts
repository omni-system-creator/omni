import axios from 'axios';
import type { AxiosInstance, AxiosRequestConfig, AxiosResponse } from 'axios';
import { message } from 'ant-design-vue';

// 定义接口响应结构
export interface ApiResponse<T = any> {
  code: number;
  msg: string;
  data: T;
}

const service: AxiosInstance = axios.create({
  baseURL: '/api', // 使用代理
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// 请求拦截器
service.interceptors.request.use(
  (config) => {
    try {
      const authData = JSON.parse(localStorage.getItem('oms.auth') || '{}');
      const token = authData.token;
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
    } catch (e) {
      console.error('Error parsing auth data', e);
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// 响应拦截器
service.interceptors.response.use(
  (response: AxiosResponse<ApiResponse>) => {
    // 处理 Token 自动刷新
    const refreshToken = response.headers['x-refresh-token'];
    if (refreshToken) {
      try {
        const authData = JSON.parse(localStorage.getItem('oms.auth') || '{}');
        authData.token = refreshToken;
        localStorage.setItem('oms.auth', JSON.stringify(authData));
      } catch (e) {
         localStorage.setItem('oms.auth', JSON.stringify({ token: refreshToken }));
      }
    }

    const res = response.data;
    
    // 如果是二进制数据，直接返回
    if (response.request.responseType === 'blob' || response.request.responseType === 'arraybuffer') {
        return response.data;
    }

    // 这里假设后端返回的总是 ApiResponse 结构，且 http status 总是 200
    // 如果 code 不为 200，视为业务错误
    if (res.code && res.code !== 200) {
      // 401: 未登录或 token 过期
      if (res.code === 401) {
        // 清除 token 并跳转登录页
        localStorage.removeItem('oms.auth');
        localStorage.removeItem('oms.user');
        // 避免重复提示
        if (!window.location.pathname.includes('/login')) {
            message.error('登录已过期，请重新登录');
            window.location.href = '/login';
        }
      } else {
        message.error(res.msg || '系统错误');
      }
      return Promise.reject(new Error(res.msg || 'Error'));
    } else {
      return res.data; // 直接返回 data 部分
    }
  },
  (error) => {
    // 处理 HTTP 错误
    const msg = error.response?.data?.msg || error.message || '网络错误';
    message.error(msg);
    
    if (error.response?.status === 401) {
        localStorage.removeItem('oms.auth');
        localStorage.removeItem('oms.user');
        window.location.href = '/login';
    }
    
    return Promise.reject(error);
  }
);

export default service;
