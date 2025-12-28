<template>
  <div class="page-container">
    <a-card :bordered="false" class="table-card">
      <template #title>
        <a-segmented v-model:value="activeTab" :options="tabOptions" @change="handleTabChange" />
      </template>
      <template #extra>
        <a-space>
          <a-button type="primary" @click="handleCreate">
            <template #icon><plus-outlined /></template>
            新建合同
          </a-button>
          <a-button>
            <template #icon><export-outlined /></template>
            导出报表
          </a-button>
        </a-space>
      </template>
      
      <div class="content-wrapper">
        <component :is="currentTabComponent" ref="listRef" />
      </div>
    </a-card>

    <a-drawer
      title="新建合同"
      :width="720"
      :visible="drawerVisible"
      :body-style="{ paddingBottom: '80px' }"
      :footer-style="{ textAlign: 'right' }"
      @close="onClose"
    >
      <contract-form ref="contractFormRef" />
      <template #footer>
        <a-space>
          <a-button @click="onClose">取消</a-button>
          <a-button type="primary" :loading="submitting" @click="onSubmit">提交</a-button>
        </a-space>
      </template>
    </a-drawer>
  </div>
</template>

<script lang="ts" setup>
import { ref, computed } from 'vue';
import { ExportOutlined, PlusOutlined } from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import dayjs from 'dayjs';
import ContractForm from './ContractForm.vue';
import SalesContractList from './components/SalesContractList.vue';
import PurchaseContractList from './components/PurchaseContractList.vue';
import { createContract } from '@/api/contract';
import type { CreateContractDto } from '@/api/contract';

const activeTab = ref('sales');

const tabOptions = [
  { label: '销售合同', value: 'sales' },
  { label: '采购合同', value: 'purchase' },
];

const currentTabComponent = computed(() => {
  switch (activeTab.value) {
    case 'sales': return SalesContractList;
    case 'purchase': return PurchaseContractList;
    default: return SalesContractList;
  }
});

const listRef = ref();

const handleTabChange = () => {
  // Component switching is handled by computed property
};

const drawerVisible = ref(false);
const submitting = ref(false);
const contractFormRef = ref();

const handleCreate = () => {
  drawerVisible.value = true;
};

const onClose = () => {
  drawerVisible.value = false;
};

const onSubmit = () => {
  contractFormRef.value.validate().then(async () => {
    submitting.value = true;
    try {
      const formState = contractFormRef.value.getFormState();
      
      const dto: CreateContractDto = {
        contractName: formState.contractName,
        type: formState.type,
        partnerName: formState.customer,
        signDate: formState.signDate ? dayjs(formState.signDate).format('YYYY-MM-DD') : undefined,
        startDate: formState.period && formState.period[0] ? dayjs(formState.period[0]).format('YYYY-MM-DD') : undefined,
        endDate: formState.period && formState.period[1] ? dayjs(formState.period[1]).format('YYYY-MM-DD') : undefined,
        manager: formState.manager,
        totalAmount: formState.amount,
        currency: formState.currency,
        paymentMethod: formState.paymentMethod,
        taxId: formState.taxId,
        description: formState.description,
        files: JSON.stringify(formState.fileList),
      };

      await createContract(dto);
      message.success('创建成功');
      drawerVisible.value = false;
      
      // Refresh list
      if (listRef.value && listRef.value.refresh) {
        listRef.value.refresh();
      }
    } catch (error) {
      console.error(error);
      message.error('创建失败');
    } finally {
      submitting.value = false;
    }
  }).catch((err: any) => {
    console.log('Validation failed:', err);
  });
};

</script>

<style scoped>
.page-container {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  height: 100%;
  padding: 16px;
}

.table-card {
  flex: 1;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

:deep(.ant-card-body) {
  flex: 1;
  overflow: hidden;
  padding: 0;
  display: flex;
  flex-direction: column;
}

:deep(.ant-card-head) {
  flex-shrink: 0;
}

.content-wrapper {
  flex: 1;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}
</style>
