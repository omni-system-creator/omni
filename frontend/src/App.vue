<template>
  <a-config-provider :locale="zhCN">
    <router-view />
  </a-config-provider>
</template>

<script setup lang="ts">
import { onMounted, watchEffect } from 'vue';
import zhCN from 'ant-design-vue/es/locale/zh_CN';
import dayjs from 'dayjs';
import 'dayjs/locale/zh-cn';
import { useSystemStore } from '@/stores/system';

dayjs.locale('zh-cn');

const systemStore = useSystemStore();

onMounted(() => {
  // 加载系统配置
  systemStore.fetchConfigs();

  // 检查是否为移动端访问（通过UserAgent判断）
  const isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
  if (isMobile && !window.location.pathname.startsWith('/m')) {
    // 如果是移动端，跳转到移动端项目路径
    window.location.href = '/m' + window.location.pathname + window.location.search;
  }
});

// 动态更新页面标题和图标
watchEffect(() => {
  if (systemStore.systemName) {
    document.title = systemStore.systemName;
  }
  
  const favicon = systemStore.getConfig('SystemFavicon');
  if (favicon) {
    let link = document.querySelector("link[rel~='icon']") as HTMLLinkElement;
    if (!link) {
      link = document.createElement('link');
      link.rel = 'icon';
      document.head.appendChild(link);
    }
    
    let href = favicon;
    if (typeof href === 'string' && !href.startsWith('/') && !href.startsWith('http') && !href.startsWith('data:')) {
      href = `/${href}`;
    }
    
    // Auto-detect type based on extension
    if (href.endsWith('.svg')) link.type = 'image/svg+xml';
    else if (href.endsWith('.png')) link.type = 'image/png';
    else if (href.endsWith('.jpg') || href.endsWith('.jpeg')) link.type = 'image/jpeg';
    else if (href.endsWith('.ico')) link.type = 'image/x-icon';
    
    // Add timestamp to prevent caching
    link.href = `${href}?v=${new Date().getTime()}`;
  }
});
</script>
