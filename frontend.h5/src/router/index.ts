import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '@/stores/user'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/login',
      name: 'Login',
      component: () => import('@/views/Login.vue')
    },
    {
      path: '/',
      component: () => import('@/views/Layout.vue'),
      children: [
        {
          path: '',
          name: 'Home',
          component: () => import('@/views/Home.vue')
        },
        {
          path: 'message',
          name: 'Message',
          component: () => import('@/views/Message.vue')
        },
        {
          path: 'ai',
          name: 'AI',
          component: () => import('@/views/AI.vue')
        },
        {
          path: 'files',
          name: 'Files',
          component: () => import('@/views/Files.vue')
        },
        {
          path: 'mine',
          name: 'Mine',
          component: () => import('@/views/Mine.vue')
        }
      ]
    },
    {
      path: '/todo',
      name: 'Todo',
      component: () => import('@/views/Todo.vue')
    },
    {
      path: '/apps',
      name: 'Apps',
      component: () => import('@/views/Apps.vue')
    },
    {
      path: '/schedule',
      name: 'Schedule',
      component: () => import('@/views/Schedule.vue')
    },
    {
      path: '/contacts',
      name: 'Contacts',
      component: () => import('@/views/Contacts.vue')
    }
  ]
})

router.beforeEach((to, from, next) => {
  const userStore = useUserStore();
  
  // 尝试从 localStorage 同步 token，防止刷新或状态未及时更新
  if (!userStore.token) {
    try {
      const authData = JSON.parse(localStorage.getItem('oms.auth') || '{}');
      if (authData.token) {
        userStore.setToken(authData.token);
      }
    } catch (e) {
      console.error('Failed to parse auth data', e);
    }
  }

  if (to.name !== 'Login' && !userStore.token) {
    next({ name: 'Login', replace: true });
  } else {
    next();
  }
});

export default router
