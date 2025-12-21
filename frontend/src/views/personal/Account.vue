<template>
  <div class="account-container">
    <div class="account-sider">
      <div class="user-card">
        <div class="avatar-wrapper">
          <a-avatar :size="80" :src="userInfo.avatar || undefined" :style="{ backgroundColor: userInfo.avatar ? undefined : '#bfbfbf' }">
             <template #icon v-if="!userInfo.avatar"><UserOutlined /></template>
          </a-avatar>
          <div class="avatar-edit" @click="triggerAvatarUpload">
            <CameraOutlined />
          </div>
          <input type="file" ref="fileInput" accept="image/*" style="display: none" @change="handleAvatarChange" />
        </div>
        <div class="user-name">{{ userInfo.nickname || userInfo.username }}</div>
        <div class="user-signature">{{ userInfo.email || '未绑定邮箱' }}</div>
      </div>
      <a-menu v-model:selectedKeys="currentTab" mode="inline" class="account-menu">
        <a-menu-item key="profile">
          <template #icon><UserOutlined /></template>
          个人资料
        </a-menu-item>
        <a-menu-item key="security">
          <template #icon><SafetyCertificateOutlined /></template>
          安全设置
        </a-menu-item>
      </a-menu>
    </div>

    <div class="account-content">
      <!-- 个人资料 -->
      <div v-if="currentTab[0] === 'profile'" class="content-wrapper">
        <div class="section-title">个人资料</div>
        <a-form layout="vertical" :model="userInfo" class="profile-form">
          <a-form-item label="用户名">
             <a-input v-model:value="userInfo.username" disabled />
          </a-form-item>
          <a-form-item label="昵称">
            <a-input v-model:value="userInfo.nickname" placeholder="请输入昵称" />
          </a-form-item>
          <a-form-item label="电子邮箱">
            <a-input v-model:value="userInfo.email" placeholder="请输入电子邮箱" />
          </a-form-item>
          <a-form-item label="联系电话">
            <a-input v-model:value="userInfo.phone" placeholder="请输入联系电话" />
          </a-form-item>
          <a-form-item>
            <a-button type="primary" @click="handleSaveProfile" :loading="saving">保存修改</a-button>
          </a-form-item>
        </a-form>
      </div>

      <!-- 安全设置 -->
      <div v-else-if="currentTab[0] === 'security'" class="content-wrapper">
        <div class="section-title">安全设置</div>
        <div class="security-list">
          <div class="security-item">
            <div class="item-meta">
              <div class="item-title">登录密码</div>
              <div class="item-desc">建议您定期更改密码以保护账户安全</div>
            </div>
            <div class="item-action">
              <a-button type="link" @click="showPasswordModal">修改</a-button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 修改密码弹窗 -->
    <a-modal
      v-model:open="passwordVisible"
      title="修改密码"
      @ok="handleUpdatePassword"
      :confirmLoading="saving"
    >
      <a-form layout="vertical" :model="passwordForm" ref="passwordFormRef">
        <a-form-item label="当前密码" name="oldPassword" required>
          <a-input-password v-model:value="passwordForm.oldPassword" placeholder="请输入当前密码" />
        </a-form-item>
        <a-form-item label="新密码" name="newPassword" required>
          <a-input-password v-model:value="passwordForm.newPassword" placeholder="请输入新密码" />
        </a-form-item>
        <a-form-item label="确认新密码" name="confirmPassword" required>
          <a-input-password v-model:value="passwordForm.confirmPassword" placeholder="请再次输入新密码" />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, reactive, onMounted, watch } from 'vue';
import { useRoute } from 'vue-router';
import {
  UserOutlined,
  SafetyCertificateOutlined,
  CameraOutlined,
} from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import { useUserStore } from '@/stores/user';
import { getCurrentUser, updateProfile, changePassword, uploadAvatar } from '@/api/user';

// --- 状态 ---
const route = useRoute();
const userStore = useUserStore();
const currentTab = ref(['profile']);
const fileInput = ref<HTMLInputElement | null>(null);
const passwordVisible = ref(false);
const saving = ref(false);

const userInfo = reactive({
  id: 0,
  username: '',
  avatar: '',
  nickname: '',
  email: '',
  phone: ''
});

const passwordForm = reactive({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
});

// --- 方法 ---

// 初始化加载用户信息
const loadUserInfo = async () => {
  try {
    const res = await getCurrentUser() as any;
    if (res) {
       userInfo.id = res.id;
       userInfo.username = res.username;
       userInfo.avatar = res.avatar || '';
       userInfo.nickname = res.nickname || '';
       // 后端如果没有返回 email 和 phone，这里会是 undefined，需要处理一下
       userInfo.email = res.email || '';
       userInfo.phone = res.phone || '';
       
       // 同时更新 store，确保头像同步
       userStore.setUserInfo({
         username: res.username,
         nickname: res.nickname || '',
         avatar: res.avatar || ''
       });
    }
  } catch (error) {
    console.error('Failed to load user info', error);
  }
};

const triggerAvatarUpload = () => {
  fileInput.value?.click();
};

const handleAvatarChange = async (event: Event) => {
  const target = event.target as HTMLInputElement;
  const file = target.files?.[0];
  if (!file) return;

  // 简单的前端验证
  const isLt2M = file.size / 1024 / 1024 < 2;
  if (!isLt2M) {
    message.error('头像大小不能超过 2MB!');
    return;
  }

  try {
    const formData = new FormData();
    formData.append('file', file);
    const res = await uploadAvatar(formData) as any;
    
    if (res && res.avatarUrl) {
      userInfo.avatar = res.avatarUrl;
      userStore.setUserInfo({
         username: userInfo.username,
         nickname: userInfo.nickname,
         avatar: res.avatarUrl
       });
      message.success('头像上传成功');
    }
  } catch (error) {
    // 错误处理已在 request 拦截器
  } finally {
      // 清空 input，允许再次选择同一文件
      if (fileInput.value) fileInput.value.value = '';
  }
};

const handleSaveProfile = async () => {
  saving.value = true;
  try {
    await updateProfile({
      nickname: userInfo.nickname,
      email: userInfo.email,
      phone: userInfo.phone
    });
    message.success('个人资料已更新');
    // 更新 store
    userStore.setUserInfo({
       username: userInfo.username,
       nickname: userInfo.nickname,
       avatar: userInfo.avatar
    });
  } catch (error) {
    // 错误处理已在 request 拦截器
  } finally {
    saving.value = false;
  }
};

const showPasswordModal = () => {
  passwordForm.oldPassword = '';
  passwordForm.newPassword = '';
  passwordForm.confirmPassword = '';
  passwordVisible.value = true;
};

const handleUpdatePassword = async () => {
  if (!passwordForm.oldPassword || !passwordForm.newPassword || !passwordForm.confirmPassword) {
    message.warning('请填写完整的密码信息');
    return;
  }
  
  if (passwordForm.newPassword !== passwordForm.confirmPassword) {
    message.error('两次输入的新密码不一致');
    return;
  }

  saving.value = true;
  try {
    await changePassword({
      oldPassword: passwordForm.oldPassword,
      newPassword: passwordForm.newPassword
    });
    message.success('密码修改成功');
    passwordVisible.value = false;
  } catch (error) {
    // 错误处理已在 request 拦截器
  } finally {
    saving.value = false;
  }
};

onMounted(() => {
  loadUserInfo();
  if (route.query.tab) {
    currentTab.value = [route.query.tab as string];
  }
});

watch(() => route.query.tab, (newTab) => {
  if (newTab) {
    currentTab.value = [newTab as string];
  }
});
</script>

<style scoped>
.account-container {
  display: flex;
  background-color: #f0f2f5;
  min-height: calc(100vh - 64px - 24px); /* 减去 header 和 margin */
  gap: 24px;
}

.account-sider {
  width: 300px;
  background: #fff;
  padding: 24px 0;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.user-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 24px;
  width: 100%;
}

.avatar-wrapper {
  position: relative;
  margin-bottom: 16px;
  cursor: pointer;
}

.avatar-edit {
  position: absolute;
  right: 0;
  bottom: 0;
  width: 24px;
  height: 24px;
  background: #1890ff;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 14px;
  opacity: 0;
  transition: opacity 0.3s;
}

.avatar-wrapper:hover .avatar-edit {
  opacity: 1;
}

.user-name {
  font-size: 20px;
  font-weight: 500;
  color: rgba(0, 0, 0, 0.85);
  margin-bottom: 4px;
}

.user-signature {
  color: rgba(0, 0, 0, 0.45);
}

.account-menu {
  width: 100%;
  border-right: none;
}

.account-content {
  flex: 1;
  background: #fff;
  padding: 24px;
}

.content-wrapper {
  max-width: 600px;
}

.section-title {
  font-size: 20px;
  font-weight: 500;
  color: rgba(0, 0, 0, 0.85);
  margin-bottom: 24px;
  padding-bottom: 12px;
  border-bottom: 1px solid #f0f0f0;
}

.security-list {
  width: 100%;
}

.security-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 0;
  border-bottom: 1px solid #f0f0f0;
}

.security-item:last-child {
  border-bottom: none;
}

.item-title {
  font-size: 16px;
  color: rgba(0, 0, 0, 0.85);
  margin-bottom: 4px;
}

.item-desc {
  color: rgba(0, 0, 0, 0.45);
  font-size: 14px;
}

.text-warning {
  color: #faad14;
}
</style>
