import request from '@/utils/request';

/**
 * 获取 AI 问候语
 */
export function getAiGreeting() {
  return request<string>({
    url: '/dashboard/greeting',
    method: 'get',
  });
}

/**
 * 获取 AI 系统标语
 */
export function getAiSlogan() {
  return request<string>({
    url: '/dashboard/slogan',
    method: 'get',
  });
}
