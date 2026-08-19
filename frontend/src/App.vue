<template>
  <a-config-provider :locale="zhCN">
    <router-view />

    <!--
      通用全屏 Loading 遮罩（全站唯一，挂在根组件外）。
      业务代码不要直接改这里，统一调用 useLoadingStore() 暴露的 show/hide：

        const loadingStore = useLoadingStore();

        // 方式 1：用返回的 close 句柄，最简洁且安全
        const close = loadingStore.show('正在批量导入...');
        try { await doImport(); } finally { close(); }

        // 方式 2：显式传 id，用于跨函数/跨组件同一份任务的开关
        loadingStore.show('查询中...', 'query-user');
        // ... 其他函数里：
        loadingStore.hide('query-user');

      支持多层嵌套：同一时刻有多个 show 未 hide，遮罩保持显示，
      文案取最后一次 show 的内容（更贴合"此刻正在干什么"）。
    -->
    <div
      v-if="loadingStore.isVisible"
      class="global-loading-mask"
    >
      <!--
        不使用 a-spin 的 tip 属性 + 占位 slot 的组合，原因：
          - 不传 slot → tip 可能渲染不出来
          - 传占文档流的占位 slot → Ant Design 会渲染"内容/tip 间分隔线"（中间一根横线）
          - 传 display:none 的占位 slot → tip 外层容器宽度被挤成 0，文字竖排
        最终解法：只让 a-spin 承担 dots 指示器渲染，tip 文案直接在 flex 容器里自己排，
        宽度/对齐/颜色完全可控，不会出现分隔线也不会竖排。
      -->
      <div class="global-loading-inner">
        <a-spin
          size="large"
          :spinning="true"
        />
        <div class="global-loading-text">{{ loadingStore.currentText || '加载中...' }}</div>
      </div>
    </div>
  </a-config-provider>
</template>

<script setup lang="ts">
import { onMounted, watchEffect } from 'vue';
import zhCN from 'ant-design-vue/es/locale/zh_CN';
import dayjs from 'dayjs';
import 'dayjs/locale/zh-cn';
import { useSystemStore } from '@/stores/system';
import { useLoadingStore } from '@/stores/loading';

dayjs.locale('zh-cn');

const systemStore = useSystemStore();
const loadingStore = useLoadingStore();

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

<style>
/* 遮罩样式使用全局非 scoped 原因：
   1. z-index/position fixed 样式需脱离 scoped hash 才能精确压过 Modal/Drawer 等全局组件
   2. Ant Design 的 a-spin 内部 .ant-spin-text 类是子组件里非 hash 渲染，scoped 下选不中 */
.global-loading-mask {
  position: fixed;
  inset: 0;
  z-index: 9999;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  /* 透明度直接写在 background 色值 alpha 通道上：不使用 opacity 整层合成，
     内容（dots + tip）不会被一起柔化，避免边缘发光 */
  background: #0b1220d9;
  user-select: none;
  filter: none;
}

/* Spin dots 用冷灰，柔和不爆白 */
.global-loading-mask .ant-spin-dot-item {
  background-color: #cbd5e1 !important;
}

/* 自己控制的内部布局：dots 在上、tip 在下，都居中 */
.global-loading-inner {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  width: 420px;
  max-width: 90vw;
}

/* tip 文案完全独立于 a-spin 的布局器，宽度/换行/对齐自己说了算 */
.global-loading-text {
  color: #e2e8f0;
  font-size: 16px;
  font-weight: 600;
  letter-spacing: 0;
  text-shadow: none !important;
  -webkit-text-stroke: 0;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-rendering: optimizeLegibility;
  margin-top: 28px;
  outline: none;
  border: 0;
  box-shadow: none;
  text-align: center;
  width: 100%;
  line-height: 1.5;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
</style>
