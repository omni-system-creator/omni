<template>
  <div class="mine-container">
    <div class="user-header">
      <van-image
        v-if="userStore.avatar"
        round
        width="64px"
        height="64px"
        :src="userStore.avatar"
        class="avatar"
      />
      <div v-else class="avatar-placeholder">
        <van-icon name="user-o" size="32" color="#fff" />
      </div>
      <div class="user-info">
        <h3>{{ userStore.nickname }}</h3>
        <p>用户名: {{ userStore.username }}</p>
      </div>
    </div>

    <van-cell-group class="mt-2">
      <van-cell title="个人信息" is-link icon="user-o" />
      <van-cell title="账号安全" is-link icon="shield-o" />
    </van-cell-group>

    <van-cell-group class="mt-2">
      <van-cell title="清理缓存" is-link icon="delete-o" @click="handleClearCache" />
      <van-cell title="关于 OMS" is-link icon="info-o" value="v1.0.0" />
      <van-cell title="帮助中心" is-link icon="question-o" />
    </van-cell-group>

    <div class="logout-btn">
      <van-button block type="default" @click="handleLogout">退出登录</van-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useUserStore } from '@/stores/user';
import { useRouter } from 'vue-router';
import { showDialog, showSuccessToast } from 'vant';

const userStore = useUserStore();
const router = useRouter();

const handleClearCache = () => {
  showDialog({
    title: '提示',
    message: '确定要清理缓存吗？',
    showCancelButton: true,
  }).then(() => {
    try {
      const keysToRemove: string[] = [];
      for (let i = 0; i < localStorage.length; i++) {
        const key = localStorage.key(i);
        if (key && key !== 'oms.auth') {
          keysToRemove.push(key);
        }
      }
      
      keysToRemove.forEach(key => localStorage.removeItem(key));
      showSuccessToast('缓存已清理');
    } catch (error) {
      console.error('Clear cache failed:', error);
    }
  });
};

const handleLogout = () => {
  showDialog({
    title: '提示',
    message: '确定要退出登录吗？',
    showCancelButton: true,
  }).then(() => {
    userStore.logout();
    router.replace('/login');
  });
};
</script>

<style scoped>
.mine-container {
  min-height: 100vh;
  background-color: #f7f8fa;
}
.user-header {
  background: #fff;
  padding: 30px 20px;
  display: flex;
  align-items: center;
}
.user-info {
  margin-left: 15px;
}

.avatar-placeholder {
  width: 64px;
  height: 64px;
  border-radius: 50%;
  background-color: #bfbfbf;
  display: flex;
  align-items: center;
  justify-content: center;
}

.user-info h3 {
  margin: 0;
  font-size: 18px;
}
.user-info p {
  margin: 5px 0 0;
  color: #969799;
  font-size: 14px;
}
.mt-2 {
  margin-top: 12px;
}
.logout-btn {
  margin-top: 24px;
  padding: 0 16px;
}
</style>
