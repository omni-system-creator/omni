<script setup lang="ts">
import { ref, watch } from 'vue';
import { useRoute } from 'vue-router';

const route = useRoute();
const active = ref(0);

watch(() => route.path, (newPath) => {
  if (newPath.startsWith('/message')) {
    active.value = 1;
  } else if (newPath.startsWith('/ai')) {
    active.value = 2;
  } else if (newPath.startsWith('/files')) {
    active.value = 3;
  } else if (newPath.startsWith('/mine')) {
    active.value = 4;
  } else {
    active.value = 0;
  }
}, { immediate: true });
</script>

<template>
  <div class="layout-container">
    <router-view />
    <van-tabbar v-model="active" :z-index="999" class="custom-tabbar">
      <van-tabbar-item replace to="/" icon="home-o">工作台</van-tabbar-item>
      <van-tabbar-item replace to="/message" icon="chat-o">消息</van-tabbar-item>
      <van-tabbar-item replace to="/ai" class="ai-tab">
        <template #icon>
          <div class="ai-icon-wrapper">
            <!-- Robot Icon SVG -->
            <svg viewBox="0 0 1024 1024" width="26" height="26" fill="currentColor">
              <path d="M832 512h-64v-128c0-70.4-57.6-128-128-128h-96v-64c0-17.6-14.4-32-32-32s-32 14.4-32 32v64h-96c-70.4 0-128 57.6-128 128v128h-64c-35.2 0-64 28.8-64 64v192c0 35.2 28.8 64 64 64h640c35.2 0 64-28.8 64-64v-192c0-35.2-28.8-64-64-64z m-544-128c0-35.2 28.8-64 64-64h256c35.2 0 64 28.8 64 64v128H288v-128z m448 384H192v-192h640v192zM320 640a64 64 0 1 1 128 0 64 64 0 0 1-128 0z m256 0a64 64 0 1 1 128 0 64 64 0 0 1-128 0z" />
            </svg>
          </div>
        </template>
        <span class="ai-text">AI助手</span>
      </van-tabbar-item>
      <van-tabbar-item replace to="/files" icon="orders-o">文件</van-tabbar-item>
      <van-tabbar-item replace to="/mine" icon="user-o">我的</van-tabbar-item>
    </van-tabbar>
  </div>
</template>

<style scoped>
.layout-container {
  padding-bottom: 50px;
}

.custom-tabbar {
  box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.05);
}

.ai-icon-wrapper {
  width: 44px;
  height: 44px;
  background: linear-gradient(135deg, #7232dd, #1989fa);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 24px;
  margin-top: -24px;
  box-shadow: 0 4px 12px rgba(25, 137, 250, 0.4);
  border: 4px solid #fff;
  transition: all 0.3s ease;
  position: relative;
  z-index: 10;
}

.van-tabbar-item--active .ai-icon-wrapper {
  transform: translateY(-4px);
  box-shadow: 0 6px 16px rgba(25, 137, 250, 0.5);
}

.ai-text {
  font-weight: bold;
  background: linear-gradient(135deg, #7232dd, #1989fa);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}
</style>
