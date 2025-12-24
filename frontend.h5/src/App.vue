<template>
  <SplashScreen v-if="showSplash" @finish="onSplashFinish" />
  <router-view v-show="!showSplash"></router-view>
  
  <transition name="van-slide-up">
    <div v-if="showMobileTips" class="mobile-tips">
      <div class="tips-content">
        <van-icon name="info-o" class="tips-icon" />
        <div class="tips-text">
          移动端仅提供部分便于使用的功能，完整功能请使用电脑端访问。
        </div>
        <van-icon name="cross" class="close-icon" @click="closeTips" />
      </div>
    </div>
  </transition>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue';
import { useRouter } from 'vue-router';
import { App as CapacitorApp } from '@capacitor/app';
import { Capacitor } from '@capacitor/core';
import { showToast } from 'vant';
import 'vant/es/toast/style';
import SplashScreen from '@/components/SplashScreen.vue';
import { StatusBar, Style } from '@capacitor/status-bar';

const showSplash = ref(Capacitor.isNativePlatform());
const showMobileTips = ref(false);
const router = useRouter();
let backListener: any = null;
let lastBackTime = 0;

const onSplashFinish = () => {
  showSplash.value = false;
};

onMounted(async () => {
  // 检查是否为电脑端访问（通过UserAgent判断）
  const isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
  if (!isMobile) {
    // 如果是电脑端，跳转到Web端根路径
    window.location.href = '/';
    return;
  }

  const hasClosed = localStorage.getItem('oms.mobile.tips.closed');
  if (!hasClosed) {
    showMobileTips.value = true;
  }

  // 处理物理返回键 (仅在 Native App 中生效)
  if (Capacitor.isNativePlatform()) {
    try {
      await StatusBar.setStyle({ style: Style.Dark });
      await StatusBar.setOverlaysWebView({ overlay: false });
    } catch (e) {
      console.error('StatusBar setup failed', e);
    }

    backListener = await CapacitorApp.addListener('backButton', () => {
      const currentPath = router.currentRoute.value.path;
      // 定义退出应用的路径（首页和登录页）
      const exitPaths = ['/', '/login'];
      
      // 定义一级页面（Tab页和其他主功能页），这些页面点击返回键回到首页
      const firstLevelPaths = [
        '/home', // 兼容可能存在的别名
        '/message', 
        '/ai', 
        '/files', 
        '/mine', 
        '/apps', 
        '/contacts', 
        '/schedule', 
        '/todo'
      ];

      // 检查是否有打开的 Vant 遮罩层（弹窗、图片预览等）
      const hasOverlay = document.querySelector('.van-overlay');
      if (hasOverlay) {
        // 如果有遮罩层，尝试通过 router.back() 关闭
        // 注意：这要求 Vant 组件开启了 close-on-popstate 或者路由栈中有记录
        // 如果仅仅是 router.back()，可能页面会后退但弹窗没关（如果弹窗没推入 history）
        // 这里做一个简单的处理：如果有遮罩，优先认为用户想关闭遮罩，执行 back
        router.back();
        return;
      }

      if (exitPaths.includes(currentPath)) {
        // 首页或登录页，检查是否连续点击
        const now = Date.now();
        if (now - lastBackTime < 2000) {
           CapacitorApp.exitApp();
        } else {
           lastBackTime = now;
           showToast('再按一次退出应用');
        }
      } else if (firstLevelPaths.includes(currentPath)) {
        // 其他一级页面，返回首页
        router.replace('/');
      } else {
        // 子页面，执行路由后退
        router.back();
      }
    });
  } else {
    // H5 平台：模拟原生 App 的"返回键关闭遮罩"体验
    // 当检测到遮罩层打开时，向 History 栈推入一个状态
    // 当点击返回键时，popstate 触发，回退该状态，我们借此机会关闭遮罩
    
    const observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        if (mutation.type === 'childList') {
          // 检测遮罩层添加
          const addedOverlay = Array.from(mutation.addedNodes).find(
            (node) => node instanceof Element && node.classList.contains('van-overlay')
          );
          if (addedOverlay) {
            // 只有当当前状态不是 overlay 时才推入，防止重复
            if (!history.state?.overlay) {
              history.pushState({ overlay: true }, '');
            }
          }

          // 检测遮罩层移除
          const removedOverlay = Array.from(mutation.removedNodes).find(
            (node) => node instanceof Element && node.classList.contains('van-overlay')
          );
          if (removedOverlay) {
            // 如果遮罩关闭了，且当前 history state 标记了 overlay，说明是手动关闭（点击X或遮罩），需要回退 history
            if (history.state?.overlay) {
              history.back();
            }
          }
        }
      });
    });
    
    observer.observe(document.body, { childList: true });

    // 监听 popstate 来关闭遮罩
    window.addEventListener('popstate', () => {
      // 浏览器后退触发
      // 如果此时页面上还有遮罩（理论上 pushState 后退后，Overlay 还在 DOM 中），则手动点击关闭
      const overlay = document.querySelector('.van-overlay');
      if (overlay && overlay instanceof HTMLElement) {
        overlay.click();
      }
    });
  }
});

onUnmounted(() => {
  if (backListener) {
    backListener.remove();
  }
});

const closeTips = () => {
  showMobileTips.value = false;
  localStorage.setItem('oms.mobile.tips.closed', 'true');
};
</script>

<style>
:root {
  --safe-area-top: 24px;
  --safe-area-top: constant(safe-area-inset-top, 24px);
  --safe-area-top: env(safe-area-inset-top, 24px);
  --nav-bar-height: calc(46px + var(--safe-area-top));
}

/* 全局适配 fixed NavBar 的安全区 */
.van-nav-bar--fixed {
  padding-top: var(--safe-area-top);
  height: var(--nav-bar-height);
  box-sizing: border-box; 
}

/* 修正 placeholder 高度 */
.van-nav-bar__placeholder {
  height: var(--nav-bar-height) !important;
}

body {
  margin: 0;
  background-color: #f7f8fa;
  font-family: -apple-system, BlinkMacSystemFont, 'Helvetica Neue', Helvetica, Segoe UI, Arial, Roboto, 'PingFang SC', 'miui', 'Hiragino Sans GB', 'Microsoft Yahei', sans-serif;
  /* 适配刘海屏和沉浸式状态栏 */
  padding-bottom: env(safe-area-inset-bottom);
  padding-left: env(safe-area-inset-left);
  padding-right: env(safe-area-inset-right);
}

/* 强制修复 Vant NavBar 的顶部安全区适配，增加 fallback */
.van-nav-bar--safe-area-inset-top {
  padding-top: 0;
}

*, *::before, *::after {
  box-sizing: border-box;
}

.mobile-tips {
  position: fixed;
  bottom: 24px;
  left: 16px;
  right: 16px;
  z-index: 9999;
}

.tips-content {
  background: rgba(0, 0, 0, 0.85);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  color: #fff;
  padding: 12px 16px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  font-size: 13px;
  line-height: 1.5;
}

.tips-icon {
  font-size: 18px;
  margin-right: 10px;
  color: #fbbf24;
  flex-shrink: 0;
}

.tips-text {
  flex: 1;
  margin-right: 10px;
}

.close-icon {
  font-size: 16px;
  color: rgba(255, 255, 255, 0.6);
  padding: 4px;
  flex-shrink: 0;
}

.close-icon:active {
  color: #fff;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 50%;
}
</style>
