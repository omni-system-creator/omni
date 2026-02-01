<template>
  <DraggableModal
    v-model:visible="visible"
    :title="modalTitle"
    width="600px"
    @ok="handleSubmit"
    @cancel="handleCancel"
    :confirmLoading="loading"
    :footer="true"
  >
    <template #footer>
      <a-button @click="handleCancel">{{ disabled ? '关闭' : '取消' }}</a-button>
      <a-button v-if="!disabled" type="primary" :loading="loading" @click="handleSubmit">确定</a-button>
    </template>
    <a-form :model="formState" :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }">
      <a-form-item label="客户名称" required>
        <a-input-group compact>
          <a-input v-model:value="formState.partnerName" placeholder="请输入客户名称" style="width: calc(100% - 32px)" :disabled="disabled" />
          <a-button v-if="hasCustomerPerm && !disabled" type="primary" @click="openCustomerSelector">
            <template #icon><SelectOutlined /></template>
          </a-button>
          <a-button v-else disabled>
            <template #icon><SelectOutlined /></template>
          </a-button>
        </a-input-group>
      </a-form-item>
      <a-form-item label="应收金额" required>
        <a-input-number v-model:value="formState.amount" style="width: 100%" :min="0" :precision="2" :disabled="disabled" />
      </a-form-item>
      <a-form-item label="到期日期">
        <a-date-picker v-model:value="formState.dueDate" value-format="YYYY-MM-DD" style="width: 100%" :disabled="disabled" />
      </a-form-item>
      <a-form-item label="财务科目">
        <a-select v-model:value="formState.subjectId" placeholder="请选择科目" :disabled="disabled">
          <a-select-option v-for="s in subjects" :key="s.id" :value="s.id">{{ s.name }}</a-select-option>
        </a-select>
      </a-form-item>
      <a-form-item label="备注">
        <a-textarea v-model:value="formState.description" :rows="3" :disabled="disabled" />
      </a-form-item>
      <a-form-item label="附件">
        <a-upload
          :file-list="fileList"
          :before-upload="beforeUpload"
          @remove="handleRemove"
          :disabled="disabled"
        >
          <a-button :disabled="disabled">
            <upload-outlined />
            选择文件
          </a-button>
        </a-upload>
      </a-form-item>
    </a-form>
  </DraggableModal>

  <CustomerSelectorModal
    v-model:visible="customerSelectorVisible"
    @select="handleCustomerSelect"
  />
</template>

<script setup lang="ts">
import { ref, reactive, watch, onMounted, computed } from 'vue';
import { UploadOutlined, SelectOutlined } from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import type { UploadProps } from 'ant-design-vue';
import DraggableModal from '@/components/DraggableModal.vue';
import CustomerSelectorModal from '@/components/Selectors/CustomerSelectorModal.vue';
import { createApAr, updateApAr, getSubjects, type FinanceSubject, type FinanceApAr } from '@/api/finance';
import { usePermissionStore } from '@/stores/permission';

const props = defineProps<{
  visible: boolean;
  editData?: FinanceApAr;
  disabled?: boolean;
}>();

const emit = defineEmits(['update:visible', 'success']);
const permissionStore = usePermissionStore();

const isEdit = computed(() => !!props.editData);
const modalTitle = computed(() => {
  if (props.disabled) return '应收单详情';
  return isEdit.value ? '编辑应收单' : '新增应收单';
});

// Permission check
const hasCustomerPerm = computed(() => permissionStore.hasMenu('SalesCustomer'));

// Selector state
const customerSelectorVisible = ref(false);

const openCustomerSelector = () => {
  customerSelectorVisible.value = true;
};

const formState = reactive({
  partnerName: '',
  partnerId: undefined as string | undefined,
  amount: 0,
  dueDate: '',
  subjectId: undefined as number | undefined,
  description: ''
});

const handleCustomerSelect = (customer: any) => {
  formState.partnerName = customer.name;
  formState.partnerId = customer.id;
};

// Proxy for v-model
const visible = computed({
  get: () => props.visible,
  set: (val) => emit('update:visible', val)
});

const loading = ref(false);
const subjects = ref<FinanceSubject[]>([]);
const fileList = ref<UploadProps['fileList']>([]);

// Load subjects when modal opens or mounted
onMounted(async () => {
  if (subjects.value.length === 0) {
    subjects.value = await getSubjects('income');
  }
});

watch(() => props.visible, (val) => {
  if (val) {
    if (props.editData) {
      formState.partnerName = props.editData.partnerName;
      formState.partnerId = props.editData.partnerId;
      formState.amount = props.editData.amount;
      formState.dueDate = props.editData.dueDate || '';
      formState.subjectId = props.editData.subjectId;
      formState.description = props.editData.description || '';
      fileList.value = [];
    } else {
      // Reset form
      formState.partnerName = '';
      formState.partnerId = undefined;
      formState.amount = 0;
      formState.dueDate = '';
      formState.subjectId = undefined;
      formState.description = '';
      fileList.value = [];
    }
  }
});

const beforeUpload: UploadProps['beforeUpload'] = file => {
  fileList.value = [...(fileList.value || []), file];
  return false;
};

const handleRemove: UploadProps['onRemove'] = file => {
  const index = (fileList.value || []).indexOf(file);
  const newFileList = (fileList.value || []).slice();
  newFileList.splice(index, 1);
  fileList.value = newFileList;
};

const handleCancel = () => {
  visible.value = false;
};

const handleSubmit = async () => {
  if (!formState.partnerName) {
    message.error('请输入客户名称');
    return;
  }
  if (!formState.amount) {
    message.error('请输入金额');
    return;
  }

  loading.value = true;
  try {
    const formData = new FormData();
    formData.append('partnerName', formState.partnerName);
    if (formState.partnerId) formData.append('partnerId', formState.partnerId);
    formData.append('amount', formState.amount.toString());
    if (formState.dueDate) formData.append('dueDate', formState.dueDate);
    if (formState.subjectId) formData.append('subjectId', formState.subjectId.toString());
    if (formState.description) formData.append('description', formState.description);

    if (fileList.value) {
      fileList.value.forEach(file => {
        formData.append('attachments', file as any);
      });
    }

    if (isEdit.value && props.editData) {
      await updateApAr(props.editData.id, formData);
      message.success('更新成功');
    } else {
      formData.append('type', 'AR'); // Fixed type for AR modal
      await createApAr(formData);
      message.success('创建应收单成功');
    }
    emit('success');
    visible.value = false;
  } finally {
    loading.value = false;
  }
};
</script>

<style scoped>
:deep(.ant-input[disabled]),
:deep(.ant-input-number-input[disabled]),
:deep(.ant-select-disabled .ant-select-selector),
:deep(.ant-picker-input > input[disabled]) {
  color: rgba(0, 0, 0, 0.85) !important;
  cursor: default;
}
</style>
