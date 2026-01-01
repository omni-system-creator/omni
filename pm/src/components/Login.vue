<script setup lang="ts">
import { ref } from 'vue'
import { NCard, NInput, NButton, NForm, NFormItem, useMessage } from 'naive-ui'
import { useProjectStore } from '../stores/projectStore'

const store = useProjectStore()
const message = useMessage()

const username = ref('')
const password = ref('')
const loading = ref(false)

const handleLogin = async () => {
  if (!username.value || !password.value) {
    message.warning('请输入用户名和密码')
    return
  }

  loading.value = true
  try {
    const success = await store.login(username.value, password.value)
    if (success) {
      message.success('登录成功')
    } else {
      message.error('登录失败：用户名或密码错误')
    }
  } catch (e) {
    message.error('登录出错')
    console.error(e)
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="login-container">
    <n-card title="项目管理系统登录" class="login-card">
      <n-form>
        <n-formItem label="用户名">
          <n-input v-model:value="username" placeholder="请输入用户名" @keydown.enter="handleLogin" />
        </n-formItem>
        <n-form-item label="密码">
          <n-input type="password" v-model:value="password" placeholder="请输入密码" @keydown.enter="handleLogin" />
        </n-form-item>
        <n-button type="primary" block :loading="loading" @click="handleLogin">
          登录
        </n-button>
      </n-form>
    </n-card>
  </div>
</template>

<style scoped>
.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
  background-color: #f0f2f5;
}

.login-card {
  width: 400px;
}
</style>
