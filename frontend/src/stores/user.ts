import { defineStore } from 'pinia';
import { ref } from 'vue';
// import { useRouter } from 'vue-router';
import { usePermissionStore } from './permission';
import { resetRouter } from '@/router';
import { useTabsStore } from './tabs';
import { getUserOrgs, switchUserOrg, type UserOrgDto } from '@/api/user';

export const useUserStore = defineStore('user', () => {
  // Helper to get initial state safely
  const getInitialState = () => {
    try {
      const authData = JSON.parse(localStorage.getItem('oms.auth') || '{}');
      const userData = JSON.parse(localStorage.getItem('oms.user') || '{}');
      const currentOrgData = JSON.parse(localStorage.getItem('oms.currentOrg') || 'null');
      return {
        token: authData.token || '',
        id: userData.id || 0,
        username: userData.username || '',
        nickname: userData.nickname || '',
        avatar: userData.avatar || '',
        status: userData.status || 'online',
        roles: userData.roles || [],
        deptId: typeof userData.deptId === 'number' ? userData.deptId : null,
        isAdmin: !!userData.isAdmin,
        currentOrg: currentOrgData
      };
    } catch (e) {
      console.error('Error parsing user store data', e);
      return { token: '', id: 0, username: '', nickname: '', avatar: '', status: 'online', roles: [], deptId: null, isAdmin: false, currentOrg: null };
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
  const deptId = ref<number | null>(state.deptId);
  const isAdmin = ref<boolean>(state.isAdmin);
  const organizations = ref<UserOrgDto[]>([]);
  const currentOrg = ref<UserOrgDto | null>(state.currentOrg);
  // const router = useRouter();

  function setToken(newToken: string) {
    token.value = newToken;
    localStorage.setItem('oms.auth', JSON.stringify({ token: newToken }));
  }

  function setUserInfo(info: { id: number; username: string; nickname?: string; avatar?: string; status?: string; roles?: number[]; deptId?: number | null; isAdmin?: boolean }) {
    id.value = info.id;
    username.value = info.username;
    nickname.value = info.nickname || '';
    avatar.value = info.avatar || '';
    status.value = info.status || 'online';
    roles.value = info.roles || [];
    deptId.value = typeof info.deptId === 'number' ? info.deptId : null;
    isAdmin.value = !!info.isAdmin;
    
    const userData = {
      id: id.value,
      username: username.value,
      nickname: nickname.value,
      avatar: avatar.value,
      status: status.value,
      roles: roles.value,
      deptId: deptId.value,
      isAdmin: isAdmin.value
    };
    localStorage.setItem('oms.user', JSON.stringify(userData));
  }

  async function fetchOrganizations() {
    try {
      const res = await getUserOrgs();
      if (res) {
        organizations.value = res;
        // If currentOrg is not set, set it to the one marked as current or first one
        // If currentOrg IS set, make sure it still exists in the list (unless it's Demo which always exists)
        if (!currentOrg.value) {
           const current = res.find(o => o.isCurrent) || res[0];
           if (current) switchOrg(current);
        } else {
           // Verify current org still valid
           const exists = res.find(o => o.id === currentOrg.value?.id);
           if (!exists && currentOrg.value.id !== 0) { // If not found and not Demo(0)
               if (res.length > 0 && res[0]) switchOrg(res[0]);
               else currentOrg.value = null;
           }
        }
      }
    } catch (e) {
      console.error('Failed to fetch organizations', e);
    }
  }

  async function switchOrg(org: UserOrgDto) {
    try {
      await switchUserOrg(org.id);
      currentOrg.value = org;
      localStorage.setItem('oms.currentOrg', JSON.stringify(org));
      // Trigger any necessary reloads or state updates
    } catch (e) {
      console.error('Failed to switch organization', e);
    }
  }

  function logout() {
    token.value = '';
    id.value = 0;
    username.value = '';
    nickname.value = '';
    avatar.value = '';
    status.value = 'online';
    roles.value = [];
    currentOrg.value = null;
    organizations.value = [];
    
    localStorage.removeItem('oms.auth');
    localStorage.removeItem('oms.user');
    localStorage.removeItem('oms.currentOrg');
    
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
    deptId,
    isAdmin,
    setToken,
    setUserInfo,
    logout,
    isLoggedIn,
    organizations,
    currentOrg,
    fetchOrganizations,
    switchOrg
  };
});
