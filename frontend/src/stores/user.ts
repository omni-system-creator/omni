import { defineStore } from 'pinia';
import { computed, nextTick, ref } from 'vue';
// import { useRouter } from 'vue-router';
import { usePermissionStore } from './permission';
import router, { resetRouter } from '@/router';
import { useTabsStore } from './tabs';
import { useSystemStore } from './system';
import { useLoadingStore } from './loading';
import { getUserOrgs, switchUserOrg, type UserOrgDto } from '@/api/user';

const IMPERSONATION_ORIGIN_STORAGE_KEY = 'oms.impersonationOrigin';

interface StoredUserInfo {
  id: number
  username: string
  nickname: string
  avatar: string
  status: string
  roles: number[]
  roleCodes: string[]
  deptId: number | null
  isAdmin: boolean
}

interface SessionSnapshot {
  token: string
  user: StoredUserInfo
  currentOrg: UserOrgDto | null
  currentRoutePath: string
}

export const useUserStore = defineStore('user', () => {
  // Helper to get initial state safely
  const getInitialState = () => {
    try {
      const authData = JSON.parse(localStorage.getItem('oms.auth') || '{}');
      const userData = JSON.parse(localStorage.getItem('oms.user') || '{}');
      const currentOrgData = JSON.parse(localStorage.getItem('oms.currentOrg') || 'null');
      const impersonationOriginData = JSON.parse(localStorage.getItem(IMPERSONATION_ORIGIN_STORAGE_KEY) || 'null');
      return {
        token: authData.token || '',
        id: userData.id || 0,
        username: userData.username || '',
        nickname: userData.nickname || '',
        avatar: userData.avatar || '',
        status: userData.status || 'online',
        roles: userData.roles || [],
        roleCodes: userData.roleCodes || [],
        deptId: typeof userData.deptId === 'number' ? userData.deptId : null,
        isAdmin: !!userData.isAdmin,
        currentOrg: currentOrgData,
        impersonationOrigin: impersonationOriginData
      };
    } catch (e) {
      console.error('Error parsing user store data', e);
      return { token: '', id: 0, username: '', nickname: '', avatar: '', status: 'online', roles: [], roleCodes: [], deptId: null, isAdmin: false, currentOrg: null, impersonationOrigin: null };
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
  const roleCodes = ref<string[]>(state.roleCodes);
  const deptId = ref<number | null>(state.deptId);
  const isAdmin = ref<boolean>(state.isAdmin);
  const canImpersonate = computed(() => isAdmin.value || roleCodes.value.includes('OrgAdmin'));
  const organizations = ref<UserOrgDto[]>([]);
  const currentOrg = ref<UserOrgDto | null>(state.currentOrg);
  const impersonationOrigin = ref<SessionSnapshot | null>(state.impersonationOrigin);
  const isImpersonating = computed(() => !!impersonationOrigin.value);
  const impersonationOriginName = computed(() => impersonationOrigin.value?.user.nickname || impersonationOrigin.value?.user.username || '');
  // const router = useRouter();

  function getStoredUserInfo(): StoredUserInfo {
    return {
      id: id.value,
      username: username.value,
      nickname: nickname.value,
      avatar: avatar.value,
      status: status.value,
      roles: roles.value,
      roleCodes: roleCodes.value,
      deptId: deptId.value,
      isAdmin: isAdmin.value
    };
  }

  function persistUserInfo() {
    localStorage.setItem('oms.user', JSON.stringify(getStoredUserInfo()));
  }

  function persistImpersonationOrigin(snapshot: SessionSnapshot | null) {
    impersonationOrigin.value = snapshot;
    if (snapshot) {
      localStorage.setItem(IMPERSONATION_ORIGIN_STORAGE_KEY, JSON.stringify(snapshot));
    } else {
      localStorage.removeItem(IMPERSONATION_ORIGIN_STORAGE_KEY);
    }
  }

  function setToken(newToken: string) {
    token.value = newToken;
    localStorage.setItem('oms.auth', JSON.stringify({ token: newToken }));
  }

  function setUserInfo(info: { id: number; username: string; nickname?: string; avatar?: string; status?: string; roles?: number[]; roleCodes?: string[]; deptId?: number | null; isAdmin?: boolean }) {
    id.value = info.id;
    username.value = info.username;
    nickname.value = info.nickname ?? nickname.value ?? '';
    avatar.value = info.avatar ?? avatar.value ?? '';
    status.value = info.status ?? status.value ?? 'online';
    roles.value = info.roles ?? roles.value ?? [];
    roleCodes.value = info.roleCodes ?? roleCodes.value ?? [];
    deptId.value = info.deptId === undefined ? deptId.value : (typeof info.deptId === 'number' ? info.deptId : null);
    isAdmin.value = info.isAdmin ?? isAdmin.value ?? false;
    persistUserInfo();
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
           } else if (exists) {
               // Update currentOrg info (e.g. orgAbbr) without full switch
               currentOrg.value = exists;
               localStorage.setItem('oms.currentOrg', JSON.stringify(exists));
           }
        }
      }
    } catch (e) {
      console.error('Failed to fetch organizations', e);
    }
  }

  async function switchOrg(org: UserOrgDto) {
    console.log('[UserStore] Switching to org:', org.id, org.name);
    try {
      await switchUserOrg(org.id);
      currentOrg.value = org;
      localStorage.setItem('oms.currentOrg', JSON.stringify(org));
      
      // Reload permissions and routes
      const permissionStore = usePermissionStore();
      const systemStore = useSystemStore();
      
      permissionStore.resetPermission();
      resetRouter();
      
      // Refresh system configs for the new org
      systemStore.fetchConfigs();

      const accessRoutes = await permissionStore.generateRoutes();
      await permissionStore.loadPermissions();
      
      // Dynamically add routes
      accessRoutes.forEach(route => {
        router.addRoute(route);
      });
      
    } catch (e) {
      console.error('Failed to switch organization', e);
    }
  }

  function persistSessionStorage(snapshot: SessionSnapshot | null) {
    if (!snapshot) {
      localStorage.removeItem('oms.auth');
      localStorage.removeItem('oms.user');
      localStorage.removeItem('oms.currentOrg');
      return;
    }

    localStorage.setItem('oms.auth', JSON.stringify({ token: snapshot.token }));
    localStorage.setItem('oms.user', JSON.stringify(snapshot.user));
    if (snapshot.currentOrg) {
      localStorage.setItem('oms.currentOrg', JSON.stringify(snapshot.currentOrg));
    } else {
      localStorage.removeItem('oms.currentOrg');
    }
  }

  function captureSessionSnapshot(): SessionSnapshot {
    return {
      token: token.value,
      user: getStoredUserInfo(),
      currentOrg: currentOrg.value,
      currentRoutePath: router.currentRoute.value.fullPath || '/'
    };
  }

  async function applySessionSnapshot(snapshot: SessionSnapshot) {
    persistSessionStorage(snapshot);
    // 统一跳到首页，由 TabsView.maybeRestoreLastActiveTab 在会话恢复完成后，
    // 根据「当前地址仍为 / + 最后活跃 Tab 是否为非首页」自动跳到正确业务 Tab。
    const nextUrl = `${window.location.origin}/`;

    try {
      window.location.replace(nextUrl);
    } catch (error) {
      console.warn('[UserStore] Fallback to reload after session switch', error);
      window.location.reload();
    }
    await new Promise(() => {});
  }

  async function beginImpersonation(snapshot: SessionSnapshot) {
    // 刷新前先把当前原用户（A）最后活跃的 tab 入库
    try {
      await useTabsStore().persistSessionToUserConfig();
    } catch (e) {
      console.warn('[UserStore.beginImpersonation] flush tabs config failed', e);
    }

    if (!impersonationOrigin.value) {
      persistImpersonationOrigin(captureSessionSnapshot());
    }

    const targetNick = snapshot.user.nickname || snapshot.user.username;
    // 先立即 show 全屏 Loading，保证 nextTick 之后 location.replace 执行前，渲染已经出过一帧，遮罩用户能看到
    useLoadingStore().show(`正在切换到用户「${targetNick}」...`, 'user-switch-impersonate');
    await nextTick();
    await applySessionSnapshot(snapshot);
  }

  async function exitImpersonation() {
    if (!impersonationOrigin.value) {
      return;
    }

    // 刷新前先把当前被模拟用户（B）最后活跃的 tab 入库
    try {
      await useTabsStore().persistSessionToUserConfig();
    } catch (e) {
      console.warn('[UserStore.exitImpersonation] flush tabs config failed', e);
    }

    const snapshot = impersonationOrigin.value;
    persistImpersonationOrigin(null);
    const originNick = snapshot.user.nickname || snapshot.user.username;
    useLoadingStore().show(`正在回到原账号「${originNick}」...`, 'user-switch-exit');
    await nextTick();
    await applySessionSnapshot(snapshot);
  }

  function logout() {
    token.value = '';
    id.value = 0;
    username.value = '';
    nickname.value = '';
    avatar.value = '';
    status.value = 'online';
    roles.value = [];
    roleCodes.value = [];
    currentOrg.value = null;
    organizations.value = [];
    
    localStorage.removeItem('oms.auth');
    localStorage.removeItem('oms.user');
    localStorage.removeItem('oms.currentOrg');
    localStorage.removeItem(IMPERSONATION_ORIGIN_STORAGE_KEY);
    impersonationOrigin.value = null;
    
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
    roleCodes,
    deptId,
    isAdmin,
    canImpersonate,
    setToken,
    setUserInfo,
    captureSessionSnapshot,
    beginImpersonation,
    exitImpersonation,
    logout,
    isLoggedIn,
    organizations,
    currentOrg,
    isImpersonating,
    impersonationOriginName,
    fetchOrganizations,
    switchOrg
  };
});
