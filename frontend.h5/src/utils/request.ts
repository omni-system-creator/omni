import axios from 'axios';
import type { AxiosInstance, AxiosResponse } from 'axios';
import { showToast, showDialog } from 'vant';
import { Capacitor } from '@capacitor/core';
import router from '@/router';

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
      const isApp = Capacitor.isNativePlatform();
      if (isApp) {
        const serverUrl = localStorage.getItem('oms.server.url');
        if (serverUrl) {
          const url = serverUrl.replace(/\/$/, '');
          const fullBase = url.startsWith('http') ? url : `http://${url}`;
          
          // 强制将 url 转换为绝对路径，绕过 baseURL 机制
          if (config.url && !config.url.startsWith('http')) {
             const path = config.url.startsWith('/') ? config.url.slice(1) : config.url;
             config.url = `${fullBase}/api/${path}`;
             config.baseURL = '';
          }
        } else {
          showToast('未设置服务器地址');
        }
      }

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
    
    // 增加对返回数据的防御性检查
    if (!res || typeof res !== 'object') {
      const url = response.config.url || 'unknown url';
      const baseURL = response.config.baseURL || '';
      const fullUrl = baseURL + (url.startsWith('/') ? url : `/${url}`);
      const rawMsg = String(res).slice(0, 100);
      showToast(`URL: ${fullUrl}\n响应格式错误: ${rawMsg}`);
      console.error(`Response format error for ${fullUrl}:`, res);
      return Promise.reject(new Error(`Invalid response format from ${fullUrl}`));
    }

    // 适配后端返回结构，假设 200 为成功
    if (res.code !== 200) {
      const errorMsg = res.msg || `请求失败 (Code: ${res.code})`;
      showToast({
        message: errorMsg,
        type: 'fail',
        duration: 3000
      });
      return Promise.reject(new Error(errorMsg));
    }
    return res.data;
  },
  (error) => {
    console.error('Request Error:', error);
    let msg = 'Request Error';
    
    if (error.response) {
      // 服务器返回了状态码，但不是 2xx
      const status = error.response.status;
      const data = error.response.data;
      
      if (status === 401) {
        msg = '登录已过期，请重新登录';
        showDialog({ message: msg }).then(() => {
          localStorage.removeItem('oms.auth');
          const currentPath = router.currentRoute.value.fullPath;
          router.replace({
            path: '/login',
            query: { redirect: currentPath }
          });
        });
        return Promise.reject(error);
      } else if (status === 404) {
        msg = `接口不存在: ${error.config.url}`;
      } else if (status === 500) {
        msg = '服务器内部错误';
      } else {
        msg = data.msg || error.message || `HTTP Error ${status}`;
      }
    } else if (error.request) {
      // 请求已发出，但没有收到响应
      msg = '网络错误，无法连接到服务器。请检查网络或服务器地址配置。可能存在跨域(CORS)限制。';
    } else {
      // 设置请求时触发错误
      msg = error.message;
    }

    showToast({
      message: msg,
      type: 'fail',
      duration: 3000,
      wordBreak: 'break-all'
    });
    return Promise.reject(error);
  }
);

export default service;
