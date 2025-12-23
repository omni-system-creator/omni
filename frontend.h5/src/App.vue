<template>
  <router-view></router-view>
  
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
import { ref, onMounted } from 'vue';

const showMobileTips = ref(false);

onMounted(() => {
  // 检查是否为电脑端访问（通过UserAgent判断）
  const isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
  if (!isMobile) {
    // 如果是电脑端，跳转到Web端根路径
    // 注意：开发环境下如果两个项目端口不同，这里跳转可能会导致404，建议在生产环境生效
    // 但为了满足用户"自动跳转"的需求，这里直接跳转
    window.location.href = '/';
    return;
  }

  const hasClosed = localStorage.getItem('oms.mobile.tips.closed');
  if (!hasClosed) {
    showMobileTips.value = true;
  }
});

const closeTips = () => {
  showMobileTips.value = false;
  localStorage.setItem('oms.mobile.tips.closed', 'true');
};
</script>

<style>
body {
  margin: 0;
  background-color: #f7f8fa;
  font-family: -apple-system, BlinkMacSystemFont, 'Helvetica Neue', Helvetica, Segoe UI, Arial, Roboto, 'PingFang SC', 'miui', 'Hiragino Sans GB', 'Microsoft Yahei', sans-serif;
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
