import { defineStore } from 'pinia';
import { ref } from 'vue';
import { getRoutes, getPermissions } from '@/api/auth';
import type { RouteRecordRaw } from 'vue-router';

// 导入所有视图组件
const modules = import.meta.glob('../views/**/*.vue');

export const usePermissionStore = defineStore('permission', () => {
  const routes = ref<RouteRecordRaw[]>([]);
  const permissions = ref<string[]>([]);

  // 将后端返回的菜单树转换为 Vue Router 路由配置
  const generateRoutes = async () => {
    try {
      const res: any = await getRoutes();
      const backendRoutes = filterAsyncRoutes(res);
      routes.value = backendRoutes;
      return backendRoutes;
    } catch (error) {
      console.error('获取路由失败:', error);
      return [];
    }
  };

  const loadPermissions = async () => {
    try {
      const res: any = await getPermissions();
      permissions.value = res;
    } catch (error) {
      console.error('获取权限失败:', error);
    }
  };

  const hasPermission = (permission: string) => {
    return permissions.value.includes(permission);
  };

  const resetPermission = () => {
    routes.value = [];
    permissions.value = [];
  };

  return {
    routes,
    permissions,
    generateRoutes,
    loadPermissions,
    hasPermission,
    resetPermission
  };
});

// 递归处理后端路由数据
function filterAsyncRoutes(routes: any[]) {
  const res: RouteRecordRaw[] = [];

  routes.forEach(route => {
    const component = route.component;
    let tmp: any;

    // Check if component is iframe
    const isIframe = component && (component.includes('iframe/Index') || component.includes('iframe/index'));

    // 特殊处理首页或顶级非 Layout 路由
    if (route.path === '/' && component !== 'Layout') {
      tmp = {
        path: '/',
        name: 'Root', // 给顶级路由一个固定的 name，确保 addRoute 时能正确覆盖旧路由
        component: () => import('@/layouts/MainLayout.vue'),
        children: [
          {
            path: '',
            component: modules[`../${component}`],
            name: route.key,
            meta: {
              title: route.title,
              icon: route.icon,
              query: route.query,
              isIframe
            }
          }
        ]
      };
    } else {
      tmp = {
        path: route.path,
        component: component === 'Layout' 
          ? () => import('@/layouts/MainLayout.vue') 
          : modules[`../${component}`],
        name: route.key,
        meta: {
          title: route.title,
          icon: route.icon,
          query: route.query,
          isIframe
        }
      };

      if (route.children && route.children.length > 0) {
        tmp.children = filterAsyncRoutes(route.children);
      }
    }

    res.push(tmp);
  });

  return res;
}
