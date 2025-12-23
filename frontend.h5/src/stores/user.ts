import { defineStore } from 'pinia';
import { ref } from 'vue';

export const useUserStore = defineStore('user', () => {
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
        status: userData.status || 'online'
      };
    } catch (e) {
      return { token: '', id: 0, username: '', nickname: '', avatar: '', status: 'online' };
    }
  };

  const state = getInitialState();

  const token = ref<string>(state.token);
  const id = ref<number>(state.id);
  const username = ref<string>(state.username);
  const nickname = ref<string>(state.nickname);
  const avatar = ref<string>(state.avatar);
  const status = ref<string>(state.status);

  function setToken(newToken: string) {
    token.value = newToken;
    localStorage.setItem('oms.auth', JSON.stringify({ token: newToken }));
  }

  function setUserInfo(info: { id: number; username: string; nickname?: string; avatar?: string; status?: string }) {
    id.value = info.id;
    username.value = info.username;
    nickname.value = info.nickname || '';
    avatar.value = info.avatar || '';
    status.value = info.status || 'online';
    
    localStorage.setItem('oms.user', JSON.stringify({
      id: info.id,
      username: info.username,
      nickname: info.nickname,
      avatar: info.avatar,
      status: info.status
    }));
  }

  function logout() {
    token.value = '';
    id.value = 0;
    username.value = '';
    nickname.value = '';
    avatar.value = '';
    localStorage.removeItem('oms.auth');
    localStorage.removeItem('oms.user');
  }

  return {
    token,
    id,
    username,
    nickname,
    avatar,
    status,
    setToken,
    setUserInfo,
    logout
  };
});
