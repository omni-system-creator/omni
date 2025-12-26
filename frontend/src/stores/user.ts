import { defineStore } from 'pinia';
import { ref } from 'vue';
// import { useRouter } from 'vue-router';
import { usePermissionStore } from './permission';
import { resetRouter } from '@/router';
import { useTabsStore } from './tabs';

export const useUserStore = defineStore('user', () => {
  // Helper to get initial state safely
  const getInitialState = () => {
    try {
      const authData = JSON.parse(localStorage.getItem('oms.auth') || '{}');
      const userData = JSON.parse(localStorage.getItem('oms.user') || '{}');
      return {
        token: authData.token || '',
        id: userData.id || 0,
        username: userData.username || '',
        nickname: userData.nickname || '',
        avatar: userData.avatar || '',
        status: userData.status || 'online',
        roles: userData.roles || []
      };
    } catch (e) {
      console.error('Error parsing user store data', e);
      return { token: '', id: 0, username: '', nickname: '', avatar: '', status: 'online', roles: [] };
    }
  };

  const state = getInitialState();

  const token = ref<string>(state.token);
  const id = ref<number>(state.id);
  const username = ref<string>(state.username);
  const nickname = ref<string>(state.nickname);
  const avatar = ref<string>(state.avatar);
  const status = ref<string>(state.status);
  const roles = ref<number[]>(state.roles);
  // const router = useRouter();

  function setToken(newToken: string) {
    token.value = newToken;
    localStorage.setItem('oms.auth', JSON.stringify({ token: newToken }));
  }

  function setUserInfo(info: { id: number; username: string; nickname?: string; avatar?: string; status?: string; roles?: number[] }) {
    id.value = info.id;
    username.value = info.username;
    nickname.value = info.nickname || '';
    avatar.value = info.avatar || '';
    status.value = info.status || 'online';
    roles.value = info.roles || [];
    
    const userData = {
      id: id.value,
      username: username.value,
      nickname: nickname.value,
      avatar: avatar.value,
      status: status.value,
      roles: roles.value
    };
    localStorage.setItem('oms.user', JSON.stringify(userData));
  }

  function logout() {
    token.value = '';
    id.value = 0;
    username.value = '';
    nickname.value = '';
    avatar.value = '';
    status.value = 'online';
    roles.value = [];
    
    localStorage.removeItem('oms.auth');
    localStorage.removeItem('oms.user');
    
    // 清理权限和路由
    const permissionStore = usePermissionStore();
    permissionStore.resetPermission();
    resetRouter();
    
    // 清理标签页
    const tabsStore = useTabsStore();
    tabsStore.delAllViews();
    
    // router.push('/login'); // 这里不直接跳转，由调用处或拦截器处理
  }

  function isLoggedIn() {
    return !!token.value;
  }

  return {
    token,
    id,
    username,
    nickname,
    avatar,
    status,
    roles,
    setToken,
    setUserInfo,
    logout,
    isLoggedIn
  };
});
