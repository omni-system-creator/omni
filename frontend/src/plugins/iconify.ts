import { addAPIProvider } from '@iconify/vue';
export function setupIcons() {
  // 配置 Iconify 使用本地后端 API (api/icons)
  // 这样前端会请求 /api/icons/{prefix}.json?icons={icons}
  // 而不是访问公共 API
  addAPIProvider('', {
    resources: ['/api/icons'],
  });
}
