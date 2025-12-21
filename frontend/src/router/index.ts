import { createRouter, createWebHistory } from 'vue-router'
import { usePermissionStore } from '@/stores/permission'
import MainLayout from '../layouts/MainLayout.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/login',
      name: 'Login',
      component: () => import('../views/Login.vue'),
      meta: { title: '登录' }
    },
    // 基础路由，不需要权限
    {
      path: '/basic', // 避免和动态路由的 / 冲突
      component: MainLayout,
      children: [
        {
          path: '/redirect/:path(.*)',
          component: () => import('../views/redirect/index.vue')
        }
      ]
    },
    // 404 页面
    {
      path: '/:pathMatch(.*)*',
      component: () => import('../views/error/404.vue')
    }
  ]
})

let isRoutesLoaded = false;

// 路由守卫
router.beforeEach(async (to, from, next) => {
  let token = '';
  try {
    const authData = JSON.parse(localStorage.getItem('oms.auth') || '{}');
    token = authData.token;
  } catch (e) {
    console.error('Error parsing auth data', e);
  }
  
  if (to.path === '/login') {
    if (token) {
      next('/');
    } else {
      next();
    }
  } else {
    if (token) {
      // 检查是否已经加载过动态路由
      if (!isRoutesLoaded) {
        const permissionStore = usePermissionStore();
        // 1. 获取动态路由
        const accessRoutes = await permissionStore.generateRoutes();
        // 2. 加载权限点
        await permissionStore.loadPermissions();
        
        // 3. 动态添加路由
        // 注意：这里我们假设后端返回的路由结构是完整的树，
        // 顶级路由通常是 Layout，或者我们需要把它们挂载到 MainLayout 下
        // 简化起见，我们将后端返回的路由都作为 MainLayout 的 children
        // 但后端返回的结构如果包含了 Layout，则直接 addRoute
        
        accessRoutes.forEach(route => {
          router.addRoute(route);
        });
        
        // 必须加上这行，确保 addRoute 完整生效
        isRoutesLoaded = true;
        next({ ...to, replace: true });
      } else {
        next();
      }
    } else {
      next('/login');
    }
  }
});

export function resetRouter() {
  isRoutesLoaded = false;
  // 这里其实无法完全“移除”已添加的路由，但重置标志位后，
  // 下次进入路由守卫时会重新获取并 addRoute。
  // Vue Router 的 addRoute 会覆盖同名路由，所以是安全的。
}

export default router
