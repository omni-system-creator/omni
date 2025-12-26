<template>
  <div class="mobile-form-submit">
    <van-nav-bar
      title="填写表单"
      left-text="返回"
      left-arrow
      @click-left="onClickLeft"
    />
    
    <div v-if="loading" class="loading-state">
      <van-loading type="spinner" vertical>加载中...</van-loading>
    </div>
    
    <div v-else-if="error" class="error-state">
      <van-empty image="error" :description="error">
        <template #bottom>
          <van-button v-if="error === 'requires_login'" type="primary" @click="goToLogin">去登录</van-button>
        </template>
      </van-empty>
    </div>
    
    <div v-else-if="submitted" class="success-state">
      <van-empty image="network" description="提交成功" />
      <div class="success-actions">
        <van-button block type="primary" @click="resetForm">再填一份</van-button>
        <van-button block plain type="primary" @click="onClickLeft" style="margin-top: 10px">返回首页</van-button>
      </div>
    </div>
    
    <van-form v-else @submit="onSubmit">
      <van-cell-group inset style="margin-top: 10px;">
        <div v-for="item in formItems" :key="item.id">
           <!-- Input -->
           <van-field
             v-if="item.type === 'input'"
             v-model="formData[item.id]"
             :name="item.id"
             :label="item.label"
             :placeholder="item.placeholder"
             :rules="[{ required: item.required, message: item.label + '不能为空' }]"
           />
           <!-- Textarea -->
           <van-field
             v-else-if="item.type === 'textarea'"
             v-model="formData[item.id]"
             :name="item.id"
             :label="item.label"
             :placeholder="item.placeholder"
             type="textarea"
             rows="2"
             autosize
             :rules="[{ required: item.required, message: item.label + '不能为空' }]"
           />
           <!-- Number -->
            <van-field
             v-else-if="item.type === 'number'"
             v-model="formData[item.id]"
             :name="item.id"
             :label="item.label"
             :placeholder="item.placeholder"
             type="number"
             :rules="[{ required: item.required, message: item.label + '不能为空' }]"
           />
           <!-- Date Picker (simplified as text for now, or native date) -->
           <!-- Vant date picker requires popup, implementing simple text for robustness or native input -->
           <van-field
             v-else-if="item.type === 'date'"
             v-model="formData[item.id]"
             :name="item.id"
             :label="item.label"
             :placeholder="item.placeholder"
             type="date"
             :rules="[{ required: item.required, message: item.label + '不能为空' }]"
           />
           
           <!-- Others simplified for now -->
           <van-field
             v-else
             v-model="formData[item.id]"
             :name="item.id"
             :label="item.label"
             :placeholder="'(暂不支持的类型: ' + item.type + ')'"
             readonly
           />
        </div>
      </van-cell-group>
      <div style="margin: 16px;">
        <van-button round block type="primary" native-type="submit" :loading="submitting">
          提交
        </van-button>
      </div>
    </van-form>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { showToast } from 'vant';
import { getFormDetail, submitForm } from '@/api/form';
import { useUserStore } from '@/stores/user';

const route = useRoute();
const router = useRouter();
const userStore = useUserStore();

const loading = ref(true);
const submitting = ref(false);
const submitted = ref(false);
const error = ref('');
const formDefinition = ref<any>(null);
const formItems = ref<any[]>([]);
const formData = ref<Record<string, any>>({});

const onClickLeft = () => {
  if (window.history.length > 1) {
    history.back();
  } else {
    router.push('/');
  }
};

const goToLogin = () => {
  router.push({
    path: '/login',
    query: { redirect: route.fullPath }
  });
};

const loadForm = async () => {
  const id = route.params.id as string;
  if (!id) {
    error.value = '无效的表单链接';
    loading.value = false;
    return;
  }

  try {
    const res = await getFormDetail(parseInt(id));
    const data = (res as any).data || res;

    if (!data.isPublished) {
      error.value = '该表单未发布或已停止收集';
      loading.value = false;
      return;
    }

    if (data.requiresLogin && !userStore.token) {
       error.value = 'requires_login';
       loading.value = false;
       return;
    }

    formDefinition.value = data;
    try {
      formItems.value = JSON.parse(data.formItems || '[]');
    } catch (e) {
      formItems.value = [];
    }
    
    // Init form data
    formItems.value.forEach((item: any) => {
      formData.value[item.id] = item.defaultValue;
    });

  } catch (e) {
    error.value = '加载表单失败';
    console.error(e);
  } finally {
    loading.value = false;
  }
};

const onSubmit = async () => {
  try {
    submitting.value = true;
    await submitForm({
      formId: formDefinition.value.id,
      data: JSON.stringify(formData.value),
      submittedBy: userStore.username || 'Anonymous'
    });
    submitted.value = true;
  } catch (e) {
    showToast('提交失败');
    console.error(e);
  } finally {
    submitting.value = false;
  }
};

const resetForm = () => {
  submitted.value = false;
  formData.value = {};
  formItems.value.forEach((item: any) => {
    formData.value[item.id] = item.defaultValue;
  });
};

onMounted(() => {
  loadForm();
});
</script>

<style scoped>
.mobile-form-submit {
  min-height: 100vh;
  background-color: #f7f8fa;
}
.loading-state, .error-state {
  padding-top: 100px;
  text-align: center;
}
.success-actions {
  padding: 20px;
}
</style>
