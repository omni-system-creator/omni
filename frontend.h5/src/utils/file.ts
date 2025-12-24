import { Capacitor } from '@capacitor/core';

/**
 * 获取完整的文件访问路径
 * @param url 相对路径或绝对路径
 * @returns 完整的URL
 */
export const getFileUrl = (url: string) => {
  if (!url) return '';
  if (url.startsWith('http') || url.startsWith('https') || url.startsWith('data:')) {
    return url;
  }
  
  const isApp = Capacitor.isNativePlatform();
  if (isApp) {
    const serverUrl = localStorage.getItem('oms.server.url');
    if (serverUrl) {
       const baseUrl = serverUrl.replace(/\/$/, '');
       const path = url.startsWith('/') ? url : `/${url}`;
       // 确保包含协议头
       const fullBase = baseUrl.startsWith('http') ? baseUrl : `http://${baseUrl}`;
       return `${fullBase}${path}`;
    }
  }
  
  return url;
};
