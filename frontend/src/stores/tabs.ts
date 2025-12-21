import { defineStore } from 'pinia';
import { ref } from 'vue';
import type { RouteLocationNormalized } from 'vue-router';

export interface TabItem {
  title: string;
  path: string;
  name: string;
  fullPath: string;
  meta: any;
}

export const useTabsStore = defineStore('tabs', () => {
  const visitedViews = ref<TabItem[]>([]);
  const cachedViews = ref<string[]>([]);

  function addView(view: RouteLocationNormalized) {
    // 确保首页总是被添加
    if (view.path === '/' || view.name === 'HomeView') {
      const homeTab = {
        title: '首页',
        path: '/',
        name: 'HomeView',
        fullPath: '/',
        meta: { title: '首页', affix: true }
      };
      if (!visitedViews.value.some(v => v.path === '/')) {
        visitedViews.value.unshift(homeTab);
      }
    }

    if (view.meta.keepAlive !== false) {
      const name = view.name as string;
      if (name && !cachedViews.value.includes(name)) {
        cachedViews.value.push(name);
      }
    }

    if (visitedViews.value.some((v) => v.path === view.path)) return;
    
    // Don't add to tabs if hidden or no title
    if (!view.meta.title && !view.name) return;

    // 如果是首页，已经在上面处理过了，这里跳过
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
    const index = visitedViews.value.findIndex((v) => v.path === view.path);
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
      return v.meta.affix || v.path === view.path;
    });
    cachedViews.value = cachedViews.value.filter((name) => {
      const v = visitedViews.value.find((i) => i.name === name);
      return v && v.meta.keepAlive !== false;
    });
  }

  function delLeftViews(view: TabItem) {
    const index = visitedViews.value.findIndex((v) => v.path === view.path);
    if (index > -1) {
      visitedViews.value = visitedViews.value.filter((v, i) => {
        return v.meta.affix || v.path === view.path || i > index;
      });
      refreshCachedViews();
    }
  }

  function delRightViews(view: TabItem) {
    const index = visitedViews.value.findIndex((v) => v.path === view.path);
    if (index > -1) {
      visitedViews.value = visitedViews.value.filter((v, i) => {
        return v.meta.affix || v.path === view.path || i < index;
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
  };
});
