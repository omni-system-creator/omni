<template>
  <div class="login-container">
    <div class="background-animation">
      <div class="shape shape-1"></div>
      <div class="shape shape-2"></div>
      <div class="shape shape-3"></div>
    </div>
    
    <div class="login-content">
      <div class="login-card">
        <div class="card-header">
          <div class="logo-wrapper">
            <img src="@/assets/logo.svg" alt="Logo" class="logo" />
          </div>
          <h1 class="title">金兰®综合信息管理系统</h1>
          <p class="subtitle">JinLan Integrated Information Management System</p>
        </div>

        <a-form
          :model="formState"
          name="login-form"
          class="login-form"
          @finish="handleLogin"
        >
          <a-form-item
            name="username"
            :rules="[{ required: true, message: '请输入用户名' }]"
          >
            <a-input
              v-model:value="formState.username"
              placeholder="用户名"
              size="large"
            >
              <template #prefix>
                <UserOutlined class="input-icon" />
              </template>
            </a-input>
          </a-form-item>

          <a-form-item
            name="password"
            :rules="[{ required: true, message: '请输入密码' }]"
          >
            <a-input-password
              v-model:value="formState.password"
              placeholder="密码"
              size="large"
            >
              <template #prefix>
                <LockOutlined class="input-icon" />
              </template>
            </a-input-password>
          </a-form-item>

          <div class="form-options">
            <a-checkbox v-model:checked="formState.remember">记住我</a-checkbox>
            <a class="forgot-password" @click="handleForgotPassword">忘记密码？</a>
          </div>

          <a-form-item>
            <a-button
              type="primary"
              html-type="submit"
              size="large"
              block
              :loading="loading"
              class="login-button"
            >
              登 录
            </a-button>
          </a-form-item>
        </a-form>

        <div class="card-footer">
          <p>© 2025 jinlan.info All Rights Reserved.</p>
        </div>
      </div>
    </div>

    <!-- 忘记密码弹窗 -->
    <a-modal
      v-model:open="forgotPasswordVisible"
      title="重置密码"
      :confirm-loading="resetLoading"
      @ok="handleSendResetLink"
    >
      <a-form layout="vertical">
        <p style="margin-bottom: 20px; color: #666;">请输入您的注册邮箱，我们将向您发送重置密码的链接。</p>
        <a-form-item label="邮箱地址" required>
          <a-input v-model:value="forgotPasswordForm.email" placeholder="请输入邮箱地址" />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref } from 'vue';
import { useRouter } from 'vue-router';
import { UserOutlined, LockOutlined } from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import { useUserStore } from '@/stores/user';
import { login } from '@/api/auth';

const router = useRouter();
const userStore = useUserStore();
const loading = ref(false);

const formState = reactive({
  username: 'admin',
  password: 'admin123',
  remember: true,
});

const handleLogin = async (_values: any) => {
  loading.value = true;
  try {
    const res = await login({
      username: formState.username,
      password: formState.password
    }) as any;
    
    // 登录成功
    if (res.token) {
      userStore.setToken(res.token);
      
      // 保存用户信息
      if (res.user) {
        userStore.setUserInfo({
          id: res.user.id,
          username: res.user.username,
          nickname: res.user.nickname,
          avatar: res.user.avatar
        });
      } else {
        // 如果后端没有返回 user 对象，使用用户名作为 fallback
        userStore.setUserInfo({
            id: 0,
            username: formState.username
        });
      }
      
      message.success('登录成功');
      // 使用 replace 替换当前历史记录，避免返回登录页
      // 这里的 '/' 会被路由守卫拦截，触发动态路由加载
      router.replace('/');
    } else {
        // 如果后端没有返回 token，但也没报错（理论上不应该发生，因为有 request 拦截器）
        message.error('登录失败：未获取到 Token');
    }
  } catch (error) {
    console.error('Login failed:', error);
    // 错误处理已在 request 拦截器中统一处理，这里只需要关闭 loading
  } finally {
    loading.value = false;
  }
};

// 忘记密码逻辑
const forgotPasswordVisible = ref(false);
const resetLoading = ref(false);
const forgotPasswordForm = reactive({
  email: ''
});

const handleForgotPassword = () => {
  forgotPasswordVisible.value = true;
};

const handleSendResetLink = () => {
  if (!forgotPasswordForm.email) {
    message.warning('请输入邮箱地址');
    return;
  }
  
  resetLoading.value = true;
  // 模拟发送邮件延迟
  setTimeout(() => {
    resetLoading.value = false;
    forgotPasswordVisible.value = false;
    message.success('重置链接已发送至您的邮箱，请查收');
    forgotPasswordForm.email = '';
  }, 1500);
};
</script>

<style scoped>
.login-container {
  position: relative;
  width: 100vw;
  height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  background-color: #0f172a;
  overflow: hidden;
}

/* 动态背景图形 */
.background-animation {
  position: absolute;
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
  max-width: 480px;
}

.login-card {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 24px;
  padding: 40px;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
  color: #fff;
}

.card-header {
  text-align: center;
  margin-bottom: 40px;
}

.logo-wrapper {
  margin-bottom: 20px;
}

.logo {
  height: 64px;
  width: auto;
  filter: drop-shadow(0 0 10px rgba(255, 255, 255, 0.3));
}

.title {
  font-size: 28px;
  font-weight: 700;
  color: #fff;
  margin-bottom: 8px;
  letter-spacing: 1px;
}

.subtitle {
  font-size: 14px;
  color: rgba(255, 255, 255, 0.6);
  font-weight: 300;
}

.login-form :deep(.ant-input-affix-wrapper) {
  background: rgba(0, 0, 0, 0.2);
  border-color: rgba(255, 255, 255, 0.1);
  padding-top: 10px;
  padding-bottom: 10px;
  color: #fff;
}

.login-form :deep(.ant-input-affix-wrapper:hover),
.login-form :deep(.ant-input-affix-wrapper:focus),
.login-form :deep(.ant-input-affix-wrapper-focused) {
  border-color: #3b82f6;
  background: rgba(0, 0, 0, 0.3);
  box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.2);
}

.login-form :deep(.ant-input) {
  background: transparent !important;
  color: #fff;
}

.login-form :deep(.ant-input)::placeholder {
  color: rgba(255, 255, 255, 0.7);
}

.login-form :deep(.ant-input-password-icon) {
  color: rgba(255, 255, 255, 0.5);
}

/* 覆盖浏览器自动填充样式 */
.login-form :deep(input:-webkit-autofill),
.login-form :deep(input:-webkit-autofill:hover),
.login-form :deep(input:-webkit-autofill:focus),
.login-form :deep(input:-webkit-autofill:active) {
  -webkit-text-fill-color: #fff !important;
  -webkit-box-shadow: 0 0 0 1000px transparent inset !important;
  transition: background-color 5000s ease-in-out 0s;
  caret-color: #fff;
}

.input-icon {
  color: rgba(255, 255, 255, 0.5);
  font-size: 18px;
}

.form-options {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  color: rgba(255, 255, 255, 0.8);
}

.login-form :deep(.ant-checkbox-wrapper) {
  color: rgba(255, 255, 255, 0.8);
}

.forgot-password {
  color: #60a5fa;
  cursor: pointer;
  transition: color 0.3s;
}

.forgot-password:hover {
  color: #93c5fd;
}

.login-button {
  height: 50px;
  font-size: 18px;
  font-weight: 600;
  border-radius: 12px;
  background: linear-gradient(135deg, #3b82f6, #2563eb);
  border: none;
  box-shadow: 0 10px 15px -3px rgba(37, 99, 235, 0.4);
  transition: all 0.3s;
}

.login-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 20px 25px -5px rgba(37, 99, 235, 0.5);
  background: linear-gradient(135deg, #2563eb, #1d4ed8);
}

.card-footer {
  text-align: center;
  margin-top: 20px;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
  padding-top: 20px;
}

.card-footer p {
  color: rgba(255, 255, 255, 0.4);
  font-size: 12px;
}
</style>
