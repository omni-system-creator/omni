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

export default router
