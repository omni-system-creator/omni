import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router'
import MainLayout from '../layouts/MainLayout.vue'
import menuData from '../assets/menu.json'

// Import all Vue components from the views directory
const modules = import.meta.glob('../views/**/*.vue')

// Recursive function to generate routes from menu data
function generateRoutes(items: any[]): RouteRecordRaw[] {
  const routes: RouteRecordRaw[] = []

  for (const item of items) {
    if (item.children) {
      routes.push(...generateRoutes(item.children))
    } else if (item.path && item.component) {
      const componentPath = `../${item.component}`
      routes.push({
        path: item.path.startsWith('/') ? item.path.substring(1) : item.path, // Remove leading slash for child routes
        name: item.key,
        component: modules[componentPath],
        meta: { title: item.title, affix: item.key === 'HomeView' }
      })
    }
  }

  return routes
}

const dynamicRoutes = generateRoutes(menuData)

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/login',
      name: 'Login',
      component: () => import('../views/Login.vue'),
      meta: { title: '登录' }
    },
    {
      path: '/',
      component: MainLayout,
      children: [
        ...dynamicRoutes,
        {
          path: '/redirect/:path(.*)',
          component: () => import('../views/redirect/index.vue')
        }
      ]
    }
  ]
})

// 路由守卫
router.beforeEach((to, from, next) => {
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
      next();
    } else {
      next('/login');
    }
  }
});

export default router
