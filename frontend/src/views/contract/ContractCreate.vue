<template>
  <div class="contract-create-container">
    <a-page-header
      title="新建合同"
      sub-title="创建新的业务合同草稿"
      @back="() => $router.go(-1)"
    >
      <template #extra>
        <a-button key="1" @click="handleCancel">取消</a-button>
        <a-button key="2" type="primary" :loading="loading" @click="handleSubmit">提交审批</a-button>
      </template>
    </a-page-header>

    <div class="content-wrapper">
      <a-card :bordered="false" class="form-card">
        <contract-form ref="contractFormRef" />
      </a-card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { message } from 'ant-design-vue';
import { useRouter } from 'vue-router';
import ContractForm from './ContractForm.vue';

const router = useRouter();
const contractFormRef = ref();
const loading = ref(false);

const handleSubmit = () => {
  contractFormRef.value
    .validate()
    .then(() => {
      loading.value = true;
      // Simulate API call
      setTimeout(() => {
        loading.value = false;
        message.success('合同创建成功，已提交审批！');
        router.push('/contract/track');
      }, 1500);
    })
    .catch((error: any) => {
      console.log('error', error);
    });
};

const handleCancel = () => {
  message.info('已取消操作');
  router.go(-1);
};
</script>

<style scoped>
.contract-create-container {
  padding: 0;
}
.content-wrapper {
  padding: 24px;
}
.form-card {
  max-width: 1200px;
  margin: 0 auto;
}
</style>
