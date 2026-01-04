import { defineStore } from 'pinia';
import { ref } from 'vue';
import type { RouteLocationNormalized } from 'vue-router';

export interface TabItem {
  title: string;
  path: string;
  name: string;
  fullPath: string;
  meta: any;
  tooltip?: string;
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
      } else {
        const homeTab = {
          title: '首页',
          path: '/',
          name: 'HomeView',
          fullPath: view.fullPath,
          meta: { title: '首页', affix: true }
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

  function updateViewTitle(fullPath: string, title: string, tooltip?: string) {
    const view = visitedViews.value.find((v) => v.fullPath === fullPath);
    if (view) {
      view.title = title;
      if (tooltip) {
        view.tooltip = tooltip;
      }
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
    updateViewTitle
  };
});
