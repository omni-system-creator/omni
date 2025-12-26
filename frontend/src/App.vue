<template>
  <a-config-provider :locale="zhCN">
    <router-view />
  </a-config-provider>
</template>

<script setup lang="ts">
import { onMounted } from 'vue';
import zhCN from 'ant-design-vue/es/locale/zh_CN';
import dayjs from 'dayjs';
import 'dayjs/locale/zh-cn';

dayjs.locale('zh-cn');

onMounted(() => {
  // 检查是否为移动端访问（通过UserAgent判断）
  const isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
  if (isMobile && !window.location.pathname.startsWith('/m')) {
    // 如果是移动端，跳转到移动端项目路径
    window.location.href = '/m' + window.location.pathname + window.location.search;
  }
});
</script>
