import { defineStore } from 'pinia';
import { ref } from 'vue';
import type { RouteLocationNormalized } from 'vue-router';
import { userConfigApi } from '@/api/userConfig';
import { useUserStore } from './user';

export interface TabItem {
  title: string;
  path: string;
  name: string;
  fullPath: string;
  meta: any;
  tooltip?: string;
  activeAt: string;
}

// 与 TabsView.vue 保持同一个 user_config key，不允许两套写不同 key
const TAB_SESSION_CONFIG_KEY = 'ui.tabs.session';

interface StoredTabSession {
  version: number;
  tabs: Array<{
    title: string;
    path: string;
    name: string;
    fullPath: string;
    tooltip?: string;
    activeAt: string;
  }>;
}

export const useTabsStore = defineStore('tabs', () => {
  const visitedViews = ref<TabItem[]>([]);
  const cachedViews = ref<string[]>([]);
  const isWebFull = ref(false);

  function toggleWebFull() {
    isWebFull.value = !isWebFull.value;
  }

  // Helper to get identity string for tab matching (ignoring UI-only query params)
  function getTabIdentity(fullPath: string) {
    try {
      const url = new URL(fullPath, 'http://dummy.com');
      const params = new URLSearchParams(url.search);
      // Remove UI state params that shouldn't create new tabs
      params.delete('webFull');
      params.delete('browserFull');
      params.sort();
      return url.pathname + '?' + params.toString();
    } catch (e) {
      return fullPath;
    }
  }

  function addView(view: RouteLocationNormalized) {
    // 确保首页总是被添加
    if (view.path === '/' || view.name === 'HomeView') {
      const existingHome = visitedViews.value.find(v => v.path === '/');
      if (existingHome) {
        if (existingHome.fullPath !== view.fullPath) {
          existingHome.fullPath = view.fullPath;
        }
        if (!existingHome.activeAt) {
          existingHome.activeAt = new Date().toISOString();
        }
      } else {
        const homeTab = {
          title: '首页',
          path: '/',
          name: 'HomeView',
          fullPath: view.fullPath,
          meta: { title: '首页', affix: true },
          activeAt: new Date().toISOString()
        };
        visitedViews.value.unshift(homeTab);
      }
    }

    if (view.meta.keepAlive !== false) {
      const name = view.name as string;
      if (name && !cachedViews.value.includes(name)) {
        cachedViews.value.push(name);
      }
    }

    const viewIdentity = getTabIdentity(view.fullPath);
    const existingView = visitedViews.value.find((v) => getTabIdentity(v.fullPath) === viewIdentity);
      if (existingView) {
        if (existingView.fullPath !== view.fullPath) {
          existingView.fullPath = view.fullPath;
        }
        if (!existingView.activeAt) {
          existingView.activeAt = new Date().toISOString();
        }
        return;
      }
    
    // Don't add to tabs if hidden or no title
    if (!view.meta.title && !view.name) return;

    if (view.path === '/') return;

    visitedViews.value.push({
      title: (view.meta.title as string) || (view.name as string),
      path: view.path,
      name: view.name as string,
      fullPath: view.fullPath,
      meta: view.meta,
      activeAt: new Date().toISOString(),
    });
  }

  function delView(view: TabItem) {
    const index = visitedViews.value.findIndex((v) => v.fullPath === view.fullPath);
    if (index > -1) {
      visitedViews.value.splice(index, 1);
    }
    const i = cachedViews.value.indexOf(view.name);
    if (i > -1) {
      cachedViews.value.splice(i, 1);
    }
  }

  function delOthersViews(view: TabItem) {
    visitedViews.value = visitedViews.value.filter((v) => {
      return v.meta.affix || v.fullPath === view.fullPath;
    });
    cachedViews.value = cachedViews.value.filter((name) => {
      const v = visitedViews.value.find((i) => i.name === name);
      return v && v.meta.keepAlive !== false;
    });
  }

  function delLeftViews(view: TabItem) {
    const index = visitedViews.value.findIndex((v) => v.fullPath === view.fullPath);
    if (index > -1) {
      visitedViews.value = visitedViews.value.filter((v, i) => {
        return v.meta.affix || v.fullPath === view.fullPath || i > index;
      });
      refreshCachedViews();
    }
  }

  function delRightViews(view: TabItem) {
    const index = visitedViews.value.findIndex((v) => v.fullPath === view.fullPath);
    if (index > -1) {
      visitedViews.value = visitedViews.value.filter((v, i) => {
        return v.meta.affix || v.fullPath === view.fullPath || i < index;
      });
      refreshCachedViews();
    }
  }

  function delAllViews() {
    visitedViews.value = visitedViews.value.filter((v) => v.meta.affix);
    refreshCachedViews();
  }

  function delCachedView(view: TabItem) {
    const i = cachedViews.value.indexOf(view.name);
    if (i > -1) {
      cachedViews.value.splice(i, 1);
    }
  }

  function refreshCachedViews() {
    cachedViews.value = visitedViews.value
      .filter((v) => v.meta.keepAlive !== false)
      .map((v) => v.name);
  }

  function replaceViews(views: TabItem[]) {
    visitedViews.value = views.map(view => ({
      ...view,
      activeAt: view.activeAt || (view as TabItem & { openedAt?: string }).openedAt || new Date().toISOString()
    }));
    refreshCachedViews();
  }

  function getLatestActiveView(views?: TabItem[]) {
    const sourceViews = views ?? visitedViews.value;
    if (!sourceViews.length) {
      return undefined;
    }

    return sourceViews.reduce((latest, current) => {
      const latestTime = new Date(latest.activeAt || 0).getTime();
      const currentTime = new Date(current.activeAt || 0).getTime();
      return currentTime > latestTime ? current : latest;
    }, sourceViews[0]!);
  }

  function touchView(fullPath: string) {
    const view = visitedViews.value.find(v => v.fullPath === fullPath);
    if (view) {
      view.activeAt = new Date().toISOString();
    }
  }

  function updateViewTitle(fullPath: string, title: string, tooltip?: string) {
    const view = visitedViews.value.find((v) => v.fullPath === fullPath);
    if (view) {
      view.title = title;
      if (tooltip) {
        view.tooltip = tooltip;
      }
    }
  }

  /**
   * 立即把当前 visitedViews 持久化写入 sys_user_config（用户+组织维度），
   * 会真正 await 请求完成再返回，保证「页面即将被刷新前」的最后状态能入库。
   * 主要用在：
   *   - beginImpersonation 切换模拟前，flush 当前 A 用户的最后活跃 tab
   *   - exitImpersonation 退出模拟前，flush 当前 B 用户的最后活跃 tab
   * 这些场景「下一步就是 location.replace 整页刷新」，不能走 TabsView 的 300ms 去抖。
   */
  async function persistSessionToUserConfig() {
    const userStore = useUserStore();
    if (!userStore.currentOrg?.id || !userStore.id) {
      return;
    }
    const payload: StoredTabSession = {
      version: 1,
      tabs: visitedViews.value.map((view) => ({
        title: view.title,
        path: view.path,
        name: view.name,
        fullPath: view.fullPath,
        tooltip: view.tooltip,
        activeAt: view.activeAt,
      })),
    };
    try {
      await userConfigApi.setConfig({
        key: TAB_SESSION_CONFIG_KEY,
        value: JSON.stringify(payload),
        description: '用户标签页会话',
      });
    } catch (error) {
      // 写库失败只打日志，不允许阻塞会话切换本身
      console.warn('[TabsStore] persistSessionToUserConfig 写入失败', error);
    }
  }

  return {
    visitedViews,
    cachedViews,
    addView,
    delView,
    delCachedView,
    delOthersViews,
    delLeftViews,
    delRightViews,
    delAllViews,
    isWebFull,
    toggleWebFull,
    getTabIdentity,
    updateViewTitle,
    replaceViews,
    getLatestActiveView,
    touchView,
    persistSessionToUserConfig,
  };
});
