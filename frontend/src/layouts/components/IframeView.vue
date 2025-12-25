<template>
  <div v-show="false">
    <!-- Hidden container just to mount the iframes -->
  </div>
  
  <div v-for="item in iframeViews" 
       :key="tabsStore.getTabIdentity(item.fullPath)" 
       class="iframe-component-wrapper"
       :class="{ 'active-iframe': tabsStore.getTabIdentity(route.fullPath) === tabsStore.getTabIdentity(item.fullPath) }"
       :style="getIframeStyle(item)">
    <iframe :src="getIframeUrl(item)" frameborder="0" width="100%" height="100%"></iframe>
  </div>
</template>

<script lang="ts" setup>
import { computed, type CSSProperties } from 'vue';
import { useRoute } from 'vue-router';
import { useTabsStore } from '@/stores/tabs';

const route = useRoute();
const tabsStore = useTabsStore();

function getIframeStyle(item: any): CSSProperties {
  const isCurrent = tabsStore.getTabIdentity(route.fullPath) === tabsStore.getTabIdentity(item.fullPath);
  return {
    display: 'block',
    visibility: isCurrent ? 'visible' : 'hidden',
    zIndex: isCurrent ? 10 : -1,
    opacity: isCurrent ? 1 : 0,
    pointerEvents: isCurrent ? 'auto' : 'none' // Ensure clicks don't go through if unexpected
  };
}

// Filter visited views to find only iframe routes
const iframeViews = computed(() => {
  return tabsStore.visitedViews.filter(v => v.meta?.isIframe || v.name === 'IframeView' || v.path === '/iframe');
});


function getIframeUrl(item: any) {
  if (item.query && item.query.url) {
    return item.query.url as string;
  }
  // Fallback: try to parse from fullPath if query object is missing
  try {
    const urlObj = new URL(item.fullPath, 'http://dummy.com');
    return urlObj.searchParams.get('url') || '';
  } catch {
    return '';
  }
}
</script>

<style scoped>
.iframe-component-wrapper {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: white;
  z-index: 1; /* Ensure it covers the router-view placeholder */
}
</style>