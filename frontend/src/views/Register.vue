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
          <div class="header-row">
            <div class="logo-wrapper">
              <img src="@/assets/logo.svg" alt="Logo" class="logo" />
            </div>
            <div class="title-area">
              <h1 class="title">注册新组织</h1>
              <p class="subtitle">JinLan OmniSystem</p>
            </div>
          </div>
        </div>

        <a-form
          :model="formState"
          name="register-form"
          class="login-form"
          @finish="handleRegister"
          layout="vertical"
        >
          <a-row :gutter="16">
            <a-col :span="12">
               <a-form-item label="组织证照" required>
                <a-spin :spinning="ocrLoading" tip="正在识别证照...">
                  <a-upload
                    v-model:file-list="licenseFileList"
                    :max-count="1"
                    :before-upload="beforeUpload"
                    :custom-request="customUploadLicense"
                  >
                    <a-button>
                      <upload-outlined />
                      上传证照
                    </a-button>
                  </a-upload>
                </a-spin>
              </a-form-item>
            </a-col>
            <a-col :span="12">
               <a-form-item 
                 name="authLetterFileUrl" 
                 label="授权书" 
                 :rules="[{ required: true, message: '请上传授权书' }]"
               >
                <a-space>
                  <a-upload
                    v-model:file-list="authLetterFileList"
                    :max-count="1"
                    :before-upload="beforeUpload"
                    :custom-request="customUploadAuthLetter"
                  >
                    <a-button>
                      <upload-outlined />
                      上传授权书
                    </a-button>
                  </a-upload>
                  <a-button type="link" @click="downloadAuthTemplate">下载模板</a-button>
                  <a-input v-model:value="formState.authLetterFileUrl" style="display: none" />
                </a-space>
              </a-form-item>
            </a-col>
          </a-row>

          <a-row :gutter="16">
            <a-col :span="12">
               <a-form-item
                name="orgName"
                label="组织全称"
                :rules="[{ required: true, message: '请输入组织全称' }]"
              >
                <a-input
                  v-model:value="formState.orgName"
                  placeholder="组织全称"
                  size="large"
                >
                  <template #prefix>
                    <BankOutlined class="input-icon" />
                  </template>
                </a-input>
              </a-form-item>
            </a-col>
             <a-col :span="12">
               <a-form-item
                name="licenseCode"
                label="证照编码"
              >
                <a-input
                  v-model:value="formState.licenseCode"
                  placeholder="统一社会信用代码等"
                  size="large"
                />
              </a-form-item>
             </a-col>
          </a-row>

          <a-row :gutter="16">
            <a-col :span="12">
               <a-form-item
                name="orgShortName"
                label="简称"
              >
                <a-input
                  v-model:value="formState.orgShortName"
                  placeholder="简称"
                  size="large"
                />
              </a-form-item>
            </a-col>
            <a-col :span="12">
               <a-form-item
                name="orgAbbr"
                label="字母缩写"
              >
                <a-input
                  v-model:value="formState.orgAbbr"
                  placeholder="字母缩写"
                  size="large"
                />
              </a-form-item>
            </a-col>
          </a-row>

          <a-divider>联系人信息</a-divider>

          <a-row :gutter="16">
            <a-col :span="8">
              <a-form-item
                name="contactName"
                label="姓名"
                :rules="[{ required: true, message: '请输入联系人姓名' }]"
              >
                <a-input v-model:value="formState.contactName" placeholder="姓名" size="large" />
              </a-form-item>
            </a-col>
            <a-col :span="8">
              <a-form-item
                name="contactPhone"
                label="电话"
                :rules="[{ required: true, message: '请输入联系人电话' }]"
              >
                <a-input v-model:value="formState.contactPhone" placeholder="电话" size="large" />
              </a-form-item>
            </a-col>
            <a-col :span="8">
              <a-form-item
                name="contactEmail"
                label="邮箱"
              >
                <a-input v-model:value="formState.contactEmail" placeholder="邮箱" size="large" />
              </a-form-item>
            </a-col>
          </a-row>

          <a-divider>管理员账号</a-divider>

          <a-row :gutter="16">
            <a-col :span="12">
              <a-form-item
                name="username"
                label="管理员用户名"
                :rules="[{ required: true, message: '请输入管理员用户名' }]"
              >
                <a-input
                  v-model:value="formState.username"
                  placeholder="管理员用户名"
                  size="large"
                >
                  <template #prefix>
                    <UserOutlined class="input-icon" />
                  </template>
                </a-input>
              </a-form-item>
            </a-col>
            <a-col :span="12">
              <a-form-item
                name="adminPhone"
                label="管理员手机号"
              >
                <a-input
                  v-model:value="formState.adminPhone"
                  placeholder="管理员手机号"
                  size="large"
                />
              </a-form-item>
            </a-col>
          </a-row>

          <a-row :gutter="16">
            <a-col :span="12">
              <a-form-item
                name="password"
                label="密码"
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
            </a-col>
            <a-col :span="12">
               <a-form-item
                name="confirmPassword"
                label="确认密码"
                :rules="[
                  { required: true, message: '请确认密码' },
                  { validator: validateConfirmPassword }
                ]"
              >
                <a-input-password
                  v-model:value="formState.confirmPassword"
                  placeholder="确认密码"
                  size="large"
                >
                  <template #prefix>
                    <LockOutlined class="input-icon" />
                  </template>
                </a-input-password>
              </a-form-item>
            </a-col>
          </a-row>

          <a-form-item>
            <a-button
              type="primary"
              html-type="submit"
              size="large"
              block
              :loading="loading"
              class="login-button"
            >
              提交注册申请
            </a-button>
          </a-form-item>
          
          <div class="form-footer">
            <router-link to="/login">已有账号？去登录</router-link>
          </div>
        </a-form>

      </div>
    </div>

    <div class="page-footer">
      <p>1.0.0 © 2025 os.jinlan.info All Rights Reserved.</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref } from 'vue';
import { useRouter } from 'vue-router';
import { UserOutlined, LockOutlined, BankOutlined, UploadOutlined } from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import type { Rule } from 'ant-design-vue/es/form';
import type { UploadProps } from 'ant-design-vue';
import { register, uploadRegistrationFile, recognizeLicense } from '@/api/auth';

const router = useRouter();
const loading = ref(false);

const formState = reactive({
  orgName: '',
  orgShortName: '',
  orgAbbr: '',
  licenseCode: '',
  contactName: '',
  contactPhone: '',
  contactEmail: '',
  username: '',
  adminPhone: '',
  password: '',
  confirmPassword: '',
  licenseFileUrl: '',
  authLetterFileUrl: ''
});

const licenseFileList = ref<UploadProps['fileList']>([]);
const authLetterFileList = ref<UploadProps['fileList']>([]);
const ocrLoading = ref(false);

const validateConfirmPassword = async (_rule: Rule, value: string) => {
  if (value === '') {
    return Promise.reject('请再次输入密码');
  } else if (value !== formState.password) {
    return Promise.reject("两次输入的密码不一致!");
  } else {
    return Promise.resolve();
  }
};

const beforeUpload: UploadProps['beforeUpload'] = file => {
  const isLt5M = file.size / 1024 / 1024 < 5;
  if (!isLt5M) {
    message.error('文件必须小于 5MB!');
  }
  return isLt5M;
};

const customUploadLicense = async (options: any) => {
  const { file, onSuccess, onError } = options;
  try {
    const res = await uploadRegistrationFile(file) as any;
    const url = res?.url ?? res?.Url ?? res?.data?.url ?? res?.data?.Url;
    if (url) {
      formState.licenseFileUrl = url;
      onSuccess(res, file);
      message.success('证照上传成功');

      // OCR Recognition
      ocrLoading.value = true;
      message.loading({ content: '正在识别证照信息...', key: 'ocr' });
      try {
        const ocrRes = await recognizeLicense(file) as any;
        if (ocrRes && (ocrRes.orgName || ocrRes.licenseCode || ocrRes.orgShortName || ocrRes.orgAbbr)) {
           if (ocrRes.orgName) formState.orgName = ocrRes.orgName;
           if (ocrRes.licenseCode) formState.licenseCode = ocrRes.licenseCode;
           if (ocrRes.orgShortName) formState.orgShortName = ocrRes.orgShortName;
           if (ocrRes.orgAbbr) formState.orgAbbr = ocrRes.orgAbbr;
           message.success({ content: '识别成功', key: 'ocr' });
        } else {
           message.warning({ content: '未能识别出有效信息，请手动填写', key: 'ocr' });
        }
      } catch (ocrErr) {
        console.error('OCR Error', ocrErr);
        message.warning({ content: '智能识别服务暂不可用，请手动填写', key: 'ocr' });
      } finally {
        ocrLoading.value = false;
      }
    } else {
      onError(new Error('Upload failed'));
      message.error('证照上传失败');
    }
  } catch (err) {
    onError(err);
    message.error('证照上传出错');
  }
};

const customUploadAuthLetter = async (options: any) => {
  const { file, onSuccess, onError } = options;
  try {
    const res = await uploadRegistrationFile(file) as any;
    const url = res?.url ?? res?.Url ?? res?.data?.url ?? res?.data?.Url;
    if (url) {
      formState.authLetterFileUrl = url;
      onSuccess(res, file);
      message.success('授权书上传成功');
    } else {
      onError(new Error('Upload failed'));
      message.error('授权书上传失败');
    }
  } catch (err) {
    onError(err);
    message.error('授权书上传出错');
  }
};

const downloadAuthTemplate = () => {
  const url = encodeURI('/templates/注册授权委托书.docx');
  window.open(url, '_blank');
};
const handleRegister = async (values: any) => {
  loading.value = true;
  try {
    await register({
      orgName: values.orgName,
      orgShortName: values.orgShortName,
      orgAbbr: values.orgAbbr,
      licenseCode: values.licenseCode,
      licenseFileUrl: formState.licenseFileUrl,
      authLetterFileUrl: formState.authLetterFileUrl,
      contactName: values.contactName,
      contactPhone: values.contactPhone,
      contactEmail: values.contactEmail,
      username: values.username,
      password: values.password
    }) as any;

    // Axios拦截器已将ApiResponse解包为data，这里直接视为成功
    message.success('注册申请已提交，请等待审核');
    // 不自动登录，因需审批
    router.push('/login');
  } catch (error: any) {
    console.error(error);
    message.error(error.message || '注册请求失败');
  } finally {
    loading.value = false;
  }
};
</script>

<style scoped>
.login-container {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: #f0f2f5;
  position: relative;
  overflow-y: auto;
}

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
  filter: blur(50px);
  opacity: 0.6;
  animation: float 20s infinite ease-in-out;
}

.shape-1 {
  top: -10%;
  left: -10%;
  width: 50vw;
  height: 50vw;
  background: radial-gradient(circle, #1890ff 0%, rgba(24, 144, 255, 0) 70%);
  animation-delay: 0s;
}

.shape-2 {
  bottom: -10%;
  right: -10%;
  width: 40vw;
  height: 40vw;
  background: radial-gradient(circle, #722ed1 0%, rgba(114, 46, 209, 0) 70%);
  animation-delay: -5s;
}

.shape-3 {
  top: 40%;
  left: 40%;
  width: 30vw;
  height: 30vw;
  background: radial-gradient(circle, #52c41a 0%, rgba(82, 196, 26, 0) 70%);
  animation-delay: -10s;
}

@keyframes float {
  0% { transform: translate(0, 0) rotate(0deg); }
  33% { transform: translate(30px, -50px) rotate(10deg); }
  66% { transform: translate(-20px, 20px) rotate(-5deg); }
  100% { transform: translate(0, 0) rotate(0deg); }
}

.login-content {
  z-index: 1;
  width: 100%;
  max-width: 800px;
  padding: 0 20px;
}

.login-card {
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(10px);
  padding: 40px;
  border-radius: 16px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  width: 100%;
  margin: 24px 0;
}

.card-header {
  text-align: center;
  margin-bottom: 24px;
}

.logo-wrapper {
  margin-bottom: 0;
}

.logo {
  height: 48px;
}

.header-row {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
}

.title-area {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
}

.title {
  font-size: 28px;
  color: #1f1f1f;
  font-weight: 600;
  margin-bottom: 4px;
  background: linear-gradient(45deg, #1890ff, #722ed1);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.subtitle {
  font-size: 16px;
  color: #8c8c8c;
  margin: 0;
}

.login-form {
  margin-top: 24px;
}

.input-icon {
  color: rgba(0, 0, 0, 0.25);
}

.login-button {
  height: 48px;
  font-size: 16px;
  border-radius: 8px;
  background: linear-gradient(45deg, #1890ff, #722ed1);
  border: none;
  box-shadow: 0 4px 12px rgba(24, 144, 255, 0.3);
  transition: all 0.3s;
}

.login-button:hover {
  transform: translateY(-1px);
  box-shadow: 0 6px 16px rgba(24, 144, 255, 0.4);
  background: linear-gradient(45deg, #40a9ff, #9254de);
}

.form-footer {
  text-align: center;
  margin-top: 16px;
}

.page-footer {
  text-align: center;
  color: #8c8c8c;
  font-size: 14px;
  padding: 16px 0 24px;
}

@media (max-width: 576px) {
  .login-card {
    padding: 24px;
  }
}
</style>
