<template>
  <div class="account-container">
    <div class="account-sider">
      <div class="user-card">
        <div class="avatar-wrapper">
          <a-avatar :size="80" :src="userInfo.avatar" />
          <div class="avatar-edit" @click="triggerAvatarUpload">
            <CameraOutlined />
          </div>
          <input type="file" ref="fileInput" accept="image/*" style="display: none" @change="handleAvatarChange" />
        </div>
        <div class="user-name">{{ userInfo.nickname }}</div>
        <div class="user-signature">{{ userInfo.signature || '暂无个性签名' }}</div>
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
        <a-menu-item key="binding">
          <template #icon><LinkOutlined /></template>
          账号绑定
        </a-menu-item>
      </a-menu>
    </div>

    <div class="account-content">
      <!-- 个人资料 -->
      <div v-if="currentTab[0] === 'profile'" class="content-wrapper">
        <div class="section-title">个人资料</div>
        <a-form layout="vertical" :model="userInfo" class="profile-form">
          <a-form-item label="昵称">
            <a-input v-model:value="userInfo.nickname" placeholder="请输入昵称" />
          </a-form-item>
          <a-form-item label="个性签名">
            <a-textarea v-model:value="userInfo.signature" placeholder="设置你的个性签名" :rows="3" />
          </a-form-item>
          <a-form-item label="性别">
            <a-radio-group v-model:value="userInfo.gender">
              <a-radio value="1">男</a-radio>
              <a-radio value="2">女</a-radio>
              <a-radio value="0">保密</a-radio>
            </a-radio-group>
          </a-form-item>
          <a-form-item label="所在部门">
            <a-input v-model:value="userInfo.department" disabled />
          </a-form-item>
          <a-form-item label="职位">
            <a-input v-model:value="userInfo.position" disabled />
          </a-form-item>
          <a-form-item label="联系电话">
            <a-input v-model:value="userInfo.phone" placeholder="请输入联系电话" />
          </a-form-item>
          <a-form-item label="办公地点">
            <a-input v-model:value="userInfo.location" placeholder="请输入办公地点" />
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
          <a-divider />
          <div class="security-item">
            <div class="item-meta">
              <div class="item-title">密保手机</div>
              <div class="item-desc">已绑定手机：{{ desensitizePhone(userInfo.phone) }}</div>
            </div>
            <div class="item-action">
              <a-button type="link">修改</a-button>
            </div>
          </div>
          <a-divider />
          <div class="security-item">
            <div class="item-meta">
              <div class="item-title">密保邮箱</div>
              <div class="item-desc">
                <span v-if="userInfo.email">已绑定邮箱：{{ userInfo.email }}</span>
                <span v-else class="text-warning">未绑定邮箱</span>
              </div>
            </div>
            <div class="item-action">
              <a-button type="link" v-if="userInfo.email">修改</a-button>
              <a-button type="link" v-else>绑定</a-button>
            </div>
          </div>
        </div>
      </div>

      <!-- 账号绑定 -->
      <div v-else-if="currentTab[0] === 'binding'" class="content-wrapper">
        <div class="section-title">账号绑定</div>
        <div class="binding-list">
          <div class="binding-item">
            <div class="binding-icon wechat">
              <WechatOutlined />
            </div>
            <div class="binding-info">
              <div class="binding-name">微信</div>
              <div class="binding-status">
                <span v-if="bindingInfo.wechat" class="status-bound">已绑定：{{ bindingInfo.wechat }}</span>
                <span v-else class="status-unbound">当前未绑定微信账号</span>
              </div>
            </div>
            <div class="binding-action">
              <a-button type="link" v-if="bindingInfo.wechat" danger>解绑</a-button>
              <a-button type="link" v-else>绑定</a-button>
            </div>
          </div>
          <div class="binding-item">
            <div class="binding-icon dingtalk">
              <DingdingOutlined />
            </div>
            <div class="binding-info">
              <div class="binding-name">钉钉</div>
              <div class="binding-status">
                <span v-if="bindingInfo.dingtalk" class="status-bound">已绑定：{{ bindingInfo.dingtalk }}</span>
                <span v-else class="status-unbound">当前未绑定钉钉账号</span>
              </div>
            </div>
            <div class="binding-action">
              <a-button type="link" v-if="bindingInfo.dingtalk" danger>解绑</a-button>
              <a-button type="link" v-else>绑定</a-button>
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
import { ref, reactive } from 'vue';
import {
  UserOutlined,
  SafetyCertificateOutlined,
  LinkOutlined,
  CameraOutlined,
  WechatOutlined,
  DingdingOutlined
} from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';

// --- 状态 ---
const currentTab = ref(['profile']);
const fileInput = ref<HTMLInputElement | null>(null);
const passwordVisible = ref(false);
const saving = ref(false);

const userInfo = reactive({
  avatar: 'https://randomuser.me/api/portraits/men/1.jpg',
  nickname: 'Admin',
  signature: '追求卓越，止于至善',
  gender: '1',
  department: '研发部',
  position: '高级前端工程师',
  phone: '13800138000',
  email: 'admin@example.com',
  location: '杭州总部 - A座5楼'
});

const bindingInfo = reactive({
  wechat: 'Wx_Admin_001',
  dingtalk: ''
});

const passwordForm = reactive({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
});

// --- 方法 ---

// 触发头像上传
const triggerAvatarUpload = () => {
  fileInput.value?.click();
};

// 处理头像变更
const handleAvatarChange = (e: Event) => {
  const file = (e.target as HTMLInputElement).files?.[0];
  if (file) {
    // 模拟上传
    const reader = new FileReader();
    reader.onload = (e) => {
      userInfo.avatar = e.target?.result as string;
      message.success('头像修改成功');
    };
    reader.readAsDataURL(file);
  }
};

// 保存个人资料
const handleSaveProfile = () => {
  saving.value = true;
  setTimeout(() => {
    saving.value = false;
    message.success('个人资料保存成功');
  }, 1000);
};

// 手机号脱敏
const desensitizePhone = (phone: string) => {
  if (!phone) return '';
  return phone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2');
};

// 显示修改密码弹窗
const showPasswordModal = () => {
  passwordForm.oldPassword = '';
  passwordForm.newPassword = '';
  passwordForm.confirmPassword = '';
  passwordVisible.value = true;
};

// 确认修改密码
const handleUpdatePassword = () => {
  if (!passwordForm.oldPassword || !passwordForm.newPassword || !passwordForm.confirmPassword) {
    message.warning('请填写完整的密码信息');
    return;
  }
  if (passwordForm.newPassword !== passwordForm.confirmPassword) {
    message.error('两次输入的新密码不一致');
    return;
  }
  
  saving.value = true;
  setTimeout(() => {
    saving.value = false;
    passwordVisible.value = false;
    message.success('密码修改成功，请重新登录');
  }, 1000);
};

</script>

<style scoped>
.account-container {
  display: flex;
  flex: 1;
  background: #fff;
  border-radius: 8px;
  overflow: hidden;
  border: 1px solid #f0f0f0;
}

.account-sider {
  width: 280px;
  border-right: 1px solid #f0f0f0;
  padding: 24px 0;
  display: flex;
  flex-direction: column;
}

.user-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 0 24px 24px;
  border-bottom: 1px solid #f0f0f0;
  margin-bottom: 16px;
}

.avatar-wrapper {
  position: relative;
  cursor: pointer;
  margin-bottom: 16px;
}

.avatar-edit {
  position: absolute;
  right: 0;
  bottom: 0;
  width: 24px;
  height: 24px;
  background: #1890ff;
  color: #fff;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  border: 2px solid #fff;
  transition: all 0.3s;
}

.avatar-wrapper:hover .avatar-edit {
  transform: scale(1.1);
}

.user-name {
  font-size: 18px;
  font-weight: 500;
  color: #333;
  margin-bottom: 8px;
}

.user-signature {
  font-size: 12px;
  color: #999;
  text-align: center;
  line-height: 1.5;
}

.account-menu {
  border-right: none;
}

.account-content {
  flex: 1;
  padding: 24px 40px;
}

.content-wrapper {
  max-width: 600px;
}

.section-title {
  font-size: 20px;
  font-weight: 500;
  color: #333;
  margin-bottom: 24px;
}

.profile-form {
  max-width: 500px;
}

/* 安全设置 */
.security-list {
  width: 100%;
}

.security-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
}

.item-title {
  font-size: 14px;
  font-weight: 500;
  color: #333;
  margin-bottom: 4px;
}

.item-desc {
  font-size: 13px;
  color: #999;
}

.text-warning {
  color: #faad14;
}

/* 账号绑定 */
.binding-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 24px;
}

.binding-item {
  display: flex;
  align-items: center;
  padding: 20px;
  border: 1px solid #f0f0f0;
  border-radius: 8px;
  transition: all 0.3s;
}

.binding-item:hover {
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}

.binding-icon {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  margin-right: 16px;
}

.binding-icon.wechat {
  background: #e6ffeb;
  color: #07c160;
}

.binding-icon.dingtalk {
  background: #e6f7ff;
  color: #1890ff;
}

.binding-info {
  flex: 1;
}

.binding-name {
  font-size: 14px;
  font-weight: 500;
  color: #333;
  margin-bottom: 4px;
}

.binding-status {
  font-size: 12px;
}

.status-bound {
  color: #999;
}

.status-unbound {
  color: #ff4d4f;
}
</style>
