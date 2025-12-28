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
import { createContract } from '@/api/contract';
import type { CreateContractDto } from '@/api/contract';
import dayjs from 'dayjs';

const router = useRouter();
const contractFormRef = ref();
const loading = ref(false);

const handleSubmit = () => {
  contractFormRef.value
    .validate()
    .then(async () => {
      loading.value = true;
      try {
        const formState = contractFormRef.value.getFormState();
        
        // Transform form state to DTO
        const dto: CreateContractDto = {
          contractName: formState.contractName,
          type: formState.type,
          partnerName: formState.customer, // Map customer to PartnerName
          signDate: formState.signDate ? dayjs(formState.signDate).format('YYYY-MM-DD') : undefined,
          startDate: formState.period && formState.period[0] ? dayjs(formState.period[0]).format('YYYY-MM-DD') : undefined,
          endDate: formState.period && formState.period[1] ? dayjs(formState.period[1]).format('YYYY-MM-DD') : undefined,
          manager: formState.manager,
          totalAmount: formState.amount,
          currency: formState.currency,
          paymentMethod: formState.paymentMethod,
          taxId: formState.taxId,
          description: formState.description,
          files: JSON.stringify(formState.fileList.map((f: any) => ({
            uid: f.uid,
            name: f.name,
            size: f.size,
            type: f.type,
            lastModified: f.lastModified
          }))), // Serialize file metadata
        };

        await createContract(dto);
        message.success('合同创建成功，已提交审批！');
        router.push('/contract/track');
      } catch (error) {
        console.error('Create contract failed:', error);
        // message.error('合同创建失败，请重试'); // Global error handler might handle this
      } finally {
        loading.value = false;
      }
    })
    .catch((error: any) => {
      console.log('Validation failed:', error);
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
