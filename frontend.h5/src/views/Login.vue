<template>
  <div class="login-container">
    <div class="background-animation">
      <div class="shape shape-1"></div>
      <div class="shape shape-2"></div>
      <div class="shape shape-3"></div>
    </div>
    
    <div class="login-content">
      <div class="login-card" :class="{ 'is-app': isApp }">
        <div class="card-header">
          <div class="logo-wrapper">
            <svg class="logo" xmlns="http://www.w3.org/2000/svg" version="1.1" viewBox="0.00 0.00 512.00 512.00">
                <circle fill="#00aa01" cx="257.00" cy="28.00" r="23.13" />
                <circle fill="#00aa01" cx="95.28" cy="94.58" r="23.14" />
                <circle fill="#00aa01" cx="418.42" cy="95.28" r="23.14" />
                <circle fill="#00aa01" cx="256.50" cy="116.50" r="42.66" />
                <circle fill="#00aa01" cx="157.50" cy="157.51" r="42.66" />
                <circle fill="#00aa01" cx="355.49" cy="157.51" r="42.66" />
                <circle fill="#e4b801" cx="256.50" cy="256.50" r="72.65" />
                <circle fill="#00aa01" cx="116.50" cy="256.50" r="42.66" />
                <circle fill="#00aa01" cx="396.50" cy="256.50" r="42.66" />
                <circle fill="#00aa01" cx="28.00" cy="256.00" r="23.13" />
                <circle fill="#00aa01" cx="485.00" cy="257.00" r="23.13" />
                <circle fill="#00aa01" cx="157.50" cy="355.50" r="42.66" />
                <circle fill="#00aa01" cx="355.49" cy="355.50" r="42.66" />
                <circle fill="#00aa01" cx="256.50" cy="396.50" r="42.66" />
                <circle fill="#00aa01" cx="94.58" cy="417.72" r="23.14" />
                <circle fill="#00aa01" cx="417.72" cy="418.42" r="23.14" />
                <circle fill="#00aa01" cx="256.00" cy="485.00" r="23.13" />
            </svg>
          </div>
          <h1 class="title">金兰®综合信息管理系统</h1>
          <p class="subtitle">JinLan OmniSystem</p>
        </div>

        <van-form @submit="onSubmit" class="login-form">
          <van-cell-group inset :border="false" class="form-group">
            <van-field
              v-if="isApp"
              v-model="serverUrl"
              name="serverUrl"
              placeholder="服务器地址 (如 http://192.168.1.10:5016)"
              :rules="[{ required: true, message: '请输入服务器地址' }]"
              class="custom-input"
            >
              <template #left-icon>
                <van-icon name="cluster-o" class="input-icon" />
              </template>
            </van-field>

            <van-field
              v-model="username"
              name="username"
              placeholder="请输入用户名"
              :rules="[{ required: true, message: '请输入用户名' }]"
              class="custom-input"
            >
              <template #left-icon>
                <van-icon name="user-o" class="input-icon" />
              </template>
            </van-field>
            
            <van-field
              v-model="password"
              type="password"
              name="password"
              placeholder="请输入密码"
              :rules="[{ required: true, message: '请输入密码' }]"
              class="custom-input"
            >
              <template #left-icon>
                <van-icon name="lock" class="input-icon" />
              </template>
            </van-field>
          </van-cell-group>

          <div class="form-options">
            <!-- 占位保持间距 -->
          </div>

          <div style="margin-top: 24px;">
            <van-button 
              round 
              block 
              type="primary" 
              native-type="submit" 
              class="login-button"
              :loading="loading"
            >
              登 录
            </van-button>
          </div>
        </van-form>
      </div>
    </div>
    
    <div class="page-footer" v-show="showFooter">
      <p>v1.0.0 © 2025 os.jinlan.info All Rights Reserved.</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, nextTick, watch, onMounted, onUnmounted } from 'vue';
import { StatusBar, Style } from '@capacitor/status-bar';
import { useRouter, useRoute } from 'vue-router';
import { useUserStore } from '@/stores/user';
import { showToast } from 'vant';
import { login } from '@/api/auth';
import { Capacitor } from '@capacitor/core';
import { Keyboard, KeyboardResize } from '@capacitor/keyboard';

const username = ref('demo');
const password = ref('123456');
const serverUrl = ref('https://oms.jinlan.info');
// const remember = ref(false); // Removed
const loading = ref(false);
const router = useRouter();
const route = useRoute();
const userStore = useUserStore();
const isApp = Capacitor.isNativePlatform();
const showFooter = ref(true);

const onKeyboardShow = () => {
  showFooter.value = false;
  // 确保当前聚焦的输入框滚动到可视区域
  setTimeout(() => {
    const activeElement = document.activeElement;
    if (activeElement && activeElement.tagName === 'INPUT') {
        activeElement.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }
  }, 100);
};

const onKeyboardHide = () => {
  showFooter.value = true;
};

onMounted(() => {
  if (isApp) {
    try {
      StatusBar.setStyle({ style: Style.Dark });
      StatusBar.setOverlaysWebView({ overlay: false });
    } catch (e) {}
    
    window.addEventListener('keyboardWillShow', onKeyboardShow);
    window.addEventListener('keyboardWillHide', onKeyboardHide);
    
    // 允许键盘调整 WebView 大小
    Keyboard.setResizeMode({ mode: KeyboardResize.Native });
  }
});

onUnmounted(() => {
  if (isApp) {
    window.removeEventListener('keyboardWillShow', onKeyboardShow);
    window.removeEventListener('keyboardWillHide', onKeyboardHide);
  }
});

if (isApp) {
  const storedUrl = localStorage.getItem('oms.server.url');
  if (storedUrl) {
    serverUrl.value = storedUrl;
  } else {
    serverUrl.value = 'https://oms.jinlan.info';
    // 立即保存默认值，确保 request 拦截器能读取到
    localStorage.setItem('oms.server.url', serverUrl.value);
  }
  
  watch(serverUrl, (val) => {
    localStorage.setItem('oms.server.url', val);
  });
}

// 初始化时从 localStorage 加载记住的用户名和密码 - Removed
/*
const initRemembered = () => {
  const remembered = localStorage.getItem('oms.remember');
  if (remembered) {
    try {
      const { username: u, password: p, remember: r } = JSON.parse(remembered);
      if (r) {
        username.value = u;
        password.value = p;
        remember.value = true;
      }
    } catch (e) {
      // ignore
    }
  }
};

initRemembered();
*/

const onSubmit = async (values: any) => {
  try {
    loading.value = true;
    const res = await login({
      username: values.username,
      password: values.password
    });
    
    // Login successful
    if (res.token) {
      userStore.setToken(res.token);
      
      if (res.user) {
        userStore.setUserInfo({
          id: res.user.id,
          username: res.user.username,
          nickname: res.user.nickname,
          avatar: res.user.avatar || '',
          status: res.user.status || 'online'
        });
      } else {
        // Fallback if no user object
        userStore.setUserInfo({
          id: 0,
          username: values.username,
          nickname: values.username,
          avatar: '',
          status: 'online'
        });
      }
      
      await nextTick();
      showToast('登录成功');
      
      const redirect = route.query.redirect as string;
      if (redirect) {
        router.replace(decodeURIComponent(redirect));
      } else {
        router.replace('/');
      }
    } else {
      showToast('登录失败：未获取到Token');
    }
  } catch (error) {
    console.error('Login failed:', error);
    // Error is handled by request interceptor usually, but safe to log
  } finally {
    loading.value = false;
  }
};
</script>

<style scoped>
.login-container {
  position: relative;
  width: 100%;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background-color: #0f172a;
  overflow-y: auto;
  overflow-x: hidden;

  /* 适配刘海屏和沉浸式状态栏 */
  padding-top: env(safe-area-inset-top, 24px);
  padding-bottom: env(safe-area-inset-bottom);
}

.login-content {
  position: relative;
  z-index: 1;
  padding: 20px;
  width: 100%;
  max-width: 420px;
  margin: auto; /* 垂直居中，且允许滚动 */
}

/* 修复自动填充背景色和文本颜色 */
:deep(input:-webkit-autofill),
:deep(input:-webkit-autofill:hover),
:deep(input:-webkit-autofill:focus),
:deep(input:-webkit-autofill:active) {
  transition: background-color 5000s ease-in-out 0s;
  -webkit-text-fill-color: #fff !important;
  caret-color: #fff;
  background-color: transparent !important;
  -webkit-box-shadow: 0 0 0 1000px transparent inset !important; /* 尝试透明背景 */
}

/* 如果透明背景不起作用，可以使用暗色背景遮盖黄色 */
:deep(.is-app input:-webkit-autofill) {
   -webkit-box-shadow: 0 0 0 1000px transparent inset !important;
   background-color: transparent !important;
   transition: background-color 5000s ease-in-out 0s;
}

/* 动态背景图形 */
.background-animation {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 0;
  overflow: hidden;
}

.shape {
  position: absolute;
  border-radius: 50%;
  filter: blur(80px);
  opacity: 0.3;
}

.shape-1 {
  top: -10%;
  left: -10%;
  width: 50vw;
  height: 50vw;
  background: linear-gradient(135deg, #4f46e5, #3b82f6);
  animation: wander-1 25s infinite alternate ease-in-out;
}

.shape-2 {
  bottom: -10%;
  right: -10%;
  width: 40vw;
  height: 40vw;
  background: linear-gradient(135deg, #06b6d4, #22d3ee);
  animation: wander-2 30s infinite alternate ease-in-out;
}

.shape-3 {
  top: 15%;
  right: 15%;
  width: 30vw;
  height: 30vw;
  background: linear-gradient(135deg, #8b5cf6, #d946ef);
  animation: wander-3 35s infinite alternate ease-in-out;
  opacity: 0.2;
}

@keyframes wander-1 {
  0% { transform: translate(0, 0) rotate(0deg) scale(1); }
  50% { transform: translate(20vw, 15vh) rotate(25deg) scale(1.5); }
  100% { transform: translate(10vw, 30vh) rotate(45deg) scale(1.2); }
}

@keyframes wander-2 {
  0% { transform: translate(0, 0) rotate(0deg) scale(1); }
  50% { transform: translate(-20vw, -15vh) rotate(-25deg) scale(1.4); }
  100% { transform: translate(-30vw, -10vh) rotate(-45deg) scale(1.1); }
}

@keyframes wander-3 {
  0% { transform: translate(0, 0) rotate(0deg) scale(1); }
  50% { transform: translate(-25vw, 25vh) rotate(25deg) scale(1.6); }
  100% { transform: translate(-45vw, 10vh) rotate(50deg) scale(1.3); }
}

.login-content {
  position: relative;
  z-index: 1;
  padding: 20px;
  width: 100%;
  max-width: 420px;
}

.login-card {
  /* background: rgba(255, 255, 255, 0.1); */
  /* backdrop-filter: blur(20px); */
  /* -webkit-backdrop-filter: blur(20px); */
  /* border: 1px solid rgba(255, 255, 255, 0.2); */
  /* border-radius: 20px; */
  padding: 0;
  /* box-shadow: 0 15px 35px -5px rgba(0, 0, 0, 0.5); */
  color: #fff;
}

.login-card.is-app {
  background: transparent;
  backdrop-filter: none;
  -webkit-backdrop-filter: none;
  border: none;
  box-shadow: none;
}

.card-header {
  text-align: center;
  margin-bottom: 30px;
}

.logo {
  height: 64px;
  width: auto;
  margin-bottom: 10px;
  filter: drop-shadow(0 0 10px rgba(255, 255, 255, 0.3));
}

.title {
  font-size: 28px;
  font-weight: 700;
  color: #fff;
  margin-bottom: 8px;
  letter-spacing: 1px;
  white-space: nowrap;
}

.subtitle {
  font-size: 14px;
  color: rgba(255, 255, 255, 0.6);
  font-weight: 300;
  margin: 0;
  white-space: nowrap;
}

/* 表单样式重写 */
.form-group {
  background: transparent !important;
  margin: 0 !important;
}

.custom-input {
  background: rgba(0, 0, 0, 0.2) !important;
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 8px;
  margin-bottom: 16px;
  padding: 12px 16px;
}

.custom-input:after {
  display: none;
}

/* 覆盖浏览器自动填充样式 */
:deep(input:-webkit-autofill),
:deep(input:-webkit-autofill:hover),
:deep(input:-webkit-autofill:focus),
:deep(input:-webkit-autofill:active) {
  -webkit-text-fill-color: #fff !important;
  transition: background-color 5000s ease-in-out 0s;
  caret-color: #fff;
}

:deep(.van-field__control) {
  color: #fff !important;
}

:deep(.van-field__control::placeholder) {
  color: rgba(255, 255, 255, 0.4);
}

.input-icon {
  color: rgba(255, 255, 255, 0.6);
  font-size: 18px;
  margin-right: 8px;
}

.form-options {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 14px;
  padding: 0 4px;
  height: 24px; /* 保留高度占位 */
}

:deep(.van-checkbox__label) {
  color: rgba(255, 255, 255, 0.8) !important;
}

:deep(.van-checkbox__icon .van-icon) {
  border-color: rgba(255, 255, 255, 0.4);
  background-color: transparent;
}

:deep(.van-checkbox__icon--checked .van-icon) {
  background-color: #1989fa;
  border-color: #1989fa;
}

.forgot-password {
  color: rgba(255, 255, 255, 0.8);
  cursor: pointer;
}

.login-button {
  background: linear-gradient(135deg, #3b82f6, #2563eb);
  border: none;
  font-size: 16px;
  font-weight: 600;
  height: 44px;
  box-shadow: 0 4px 12px rgba(37, 99, 235, 0.3);
}

.page-footer {
  position: absolute;
  bottom: 24px;
  left: 0;
  width: 100%;
  text-align: center;
  z-index: 10;
}

.page-footer p {
  color: rgba(255, 255, 255, 0.4);
  font-size: 12px;
  margin: 0;
}
</style>
