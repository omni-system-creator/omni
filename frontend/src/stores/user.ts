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
        username: userData.username || '',
        nickname: userData.nickname || '',
        avatar: userData.avatar || '',
        status: userData.status || 'online'
      };
    } catch (e) {
      console.error('Error parsing user store data', e);
      return { token: '', username: '', nickname: '', avatar: '', status: 'online' };
    }
  };

  const state = getInitialState();

  const token = ref<string>(state.token);
  const username = ref<string>(state.username);
  const nickname = ref<string>(state.nickname);
  const avatar = ref<string>(state.avatar);
  const status = ref<string>(state.status);
  // const router = useRouter();

  function setToken(newToken: string) {
    token.value = newToken;
    localStorage.setItem('oms.auth', JSON.stringify({ token: newToken }));
  }

  function setUserInfo(info: { username: string; nickname?: string; avatar?: string; status?: string }) {
    username.value = info.username;
    nickname.value = info.nickname || '';
    avatar.value = info.avatar || '';
    status.value = info.status || 'online';
    
    const userData = {
      username: username.value,
      nickname: nickname.value,
      avatar: avatar.value,
      status: status.value
    };
    localStorage.setItem('oms.user', JSON.stringify(userData));
  }

  function logout() {
    token.value = '';
    username.value = '';
    nickname.value = '';
    avatar.value = '';
    status.value = 'online';
    
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
    username,
    nickname,
    avatar,
    status,
    setToken,
    setUserInfo,
    logout,
    isLoggedIn
  };
});
