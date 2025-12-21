<template>
  <a-dropdown>
    <span class="user-dropdown-link">
      <a-avatar v-if="userStore.avatar" :src="userStore.avatar" />
      <a-avatar v-else style="background-color: #bfbfbf">
        <template #icon><UserOutlined /></template>
      </a-avatar>
      <span class="username">{{ userStore.nickname || userStore.username }}</span>
    </span>
    <template #overlay>
      <a-menu>
        <a-menu-item key="account" @click="router.push('/personal/account')">
          <DynamicIcon icon="ant-design:user-outlined" />
          <span style="margin-left: 8px">个人中心</span>
        </a-menu-item>
        <a-menu-item key="password" @click="showChangePassword">
          <DynamicIcon icon="ant-design:lock-outlined" />
          <span style="margin-left: 8px">修改密码</span>
        </a-menu-item>
        <a-menu-item key="about" @click="showAbout">
          <DynamicIcon icon="ant-design:info-circle-outlined" />
          <span style="margin-left: 8px">关于系统</span>
        </a-menu-item>
        <a-menu-divider />
        <a-menu-item key="logout" @click="handleLogout">
          <DynamicIcon icon="ant-design:logout-outlined" />
          <span style="margin-left: 8px">退出登录</span>
        </a-menu-item>
      </a-menu>
    </template>
  </a-dropdown>

  <AboutModal v-model:open="aboutVisible" />
</template>

<script lang="ts" setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { message } from 'ant-design-vue';
import { UserOutlined } from '@ant-design/icons-vue';
import { useUserStore } from '@/stores/user';
import DynamicIcon from '@/components/DynamicIcon.vue';
import AboutModal from './AboutModal.vue';

const router = useRouter();
const userStore = useUserStore();
const aboutVisible = ref(false);

const showChangePassword = () => {
  router.push('/personal/account?tab=security');
};

const showAbout = () => {
  aboutVisible.value = true;
};

const handleLogout = () => {
  userStore.logout();
  message.success('已退出登录');
  router.push('/login');
};
</script>

<style scoped>
.user-dropdown-link {
  cursor: pointer;
  display: flex;
  align-items: center;
  padding: 0 12px;
  transition: all 0.3s;
}

.user-dropdown-link:hover {
  background: rgba(0, 0, 0, 0.025);
}

.username {
  margin-left: 8px;
}
</style>
