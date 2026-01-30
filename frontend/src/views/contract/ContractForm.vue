<template>
  <a-form
    ref="formRef"
    :model="formState"
    :rules="rules as any"
    layout="vertical"
  >
    <a-row :gutter="24">
      <a-col :span="24">
        <a-form-item label="客户名称" name="customer">
          <div style="display: flex; gap: 8px;">
            <a-input v-model:value="formState.customer" placeholder="请输入或选择客户" @change="handleCustomerNameChange" />
            <a-button type="primary" @click="openCustomerSelector">选择</a-button>
          </div>
        </a-form-item>
      </a-col>
      <a-col :span="14">
        <a-form-item label="合同名称" name="contractName">
          <a-input v-model:value="formState.contractName" placeholder="请输入合同名称" />
        </a-form-item>
      </a-col>
      <a-col :span="10">
        <a-form-item label="合同编号" name="contractNo">
          <a-input v-model:value="formState.contractNo" placeholder="请输入合同编号，可空" />
        </a-form-item>
      </a-col>
      <a-col :span="7">
        <a-form-item label="合同类型" name="type">
          <a-select v-model:value="formState.type" placeholder="请选择合同类型">
            <a-select-option v-for="item in contractTypeOptions" :key="item.value" :value="item.value">
              {{ item.label }}
            </a-select-option>
          </a-select>
        </a-form-item>
      </a-col>
      <a-col :span="7">
        <a-form-item label="总价类型" name="pricingType">
          <a-select v-model:value="formState.pricingType" placeholder="请选择总价类型">
            <a-select-option v-for="item in pricingTypeOptions" :key="item.value" :value="item.value">
              {{ item.label }}
            </a-select-option>
          </a-select>
        </a-form-item>
      </a-col>
      <a-col :span="10">
        <a-form-item label="负责人" name="manager">
          <UserSelector
            v-model:value="formState.manager"
            :initial-display-data="selectedManagerInfo"
            placeholder="请选择负责人"
            @change="onManagerChange"
          />
        </a-form-item>
      </a-col>
      <a-col :span="7">
        <a-form-item label="合同状态" name="lifecycleStatus">
          <a-select v-model:value="formState.lifecycleStatus" placeholder="请选择合同状态">
            <a-select-option v-for="item in lifecycleStatusOptions" :key="item.value" :value="item.value">
              {{ item.label }}
            </a-select-option>
          </a-select>
        </a-form-item>
      </a-col>
      <a-col :span="7">
        <a-form-item label="签订日期" name="signDate">
          <a-date-picker v-model:value="formState.signDate" style="width: 100%" />
        </a-form-item>
      </a-col>
      <a-col :span="10">
        <a-form-item label="有效期限" name="period">
          <a-range-picker v-model:value="formState.period" style="width: 100%" />
        </a-form-item>
      </a-col>
    </a-row>

    <!-- Section 2: Financial Info -->
    <a-divider orientation="left">财务条款</a-divider>
    <a-row :gutter="24">
      <a-col :span="7">
        <a-form-item label="付款方式" name="paymentMethod">
          <a-select v-model:value="formState.paymentMethod">
            <a-select-option v-for="item in paymentMethodOptions" :key="item.value" :value="item.value">
              {{ item.label }}
            </a-select-option>
          </a-select>
        </a-form-item>
      </a-col>
      <a-col :span="7">
        <a-form-item label="币种" name="currency">
          <a-select v-model:value="formState.currency">
            <a-select-option v-for="item in currencyOptions" :key="item.value" :value="item.value">
              {{ item.label }}
            </a-select-option>
          </a-select>
        </a-form-item>
      </a-col>
      <a-col :span="10">
        <a-form-item label="合同总金额" name="amount">
          <a-input-number
            v-model:value="formState.amount"
            :formatter="(value: any) => `¥ ${value}`.replace(/\B(?=(\d{3})+(?!\d))/g, ',')"
            :parser="(value: any) => value.replace(/\¥\s?|(,*)/g, '')"
            style="width: 100%"
          />
        </a-form-item>
      </a-col>
    </a-row>
    


    <!-- Section 3: Details & Attachments -->
    <a-divider orientation="left">其他信息</a-divider>
    <a-form-item label="合同详情/备注" name="description">
      <a-textarea v-model:value="formState.description" :rows="4" placeholder="请输入合同详细条款或备注信息" />
    </a-form-item>

    <a-form-item label="附件" name="files" v-if="!isEdit">
      <a-upload-dragger
        v-model:file-list="fileList"
        :before-upload="beforeUpload"
        @remove="handleRemoveFile"
        multiple
      >
        <p class="ant-upload-drag-icon">
          <inbox-outlined />
        </p>
        <p class="ant-upload-text">点击或拖拽文件到此区域上传</p>
        <p class="ant-upload-hint">支持单个或多个文件上传</p>
      </a-upload-dragger>
    </a-form-item>

    <CustomerSelector
      v-model:visible="customerSelectorVisible"
      @select="handleCustomerSelect"
    />
  </a-form>
</template>

<script setup lang="ts">
import { reactive, ref, watch, onMounted } from 'vue';
import dayjs from 'dayjs';
import type { Dayjs } from 'dayjs';
import { getDictDataByCode, type DictDataDto } from '@/api/dict';
import CustomerSelector from './components/CustomerSelector.vue';
import UserSelector from '@/components/UserSelector.vue';
import { getUserList } from '@/api/user';
import type { ContractCustomerSelectDto } from '@/api/contract';
import { message } from 'ant-design-vue';
import type { UploadProps } from 'ant-design-vue';
import { InboxOutlined } from '@ant-design/icons-vue';
import { deleteContractFile } from '@/api/contract';
import { useUserStore } from '@/stores/user';

const props = defineProps<{
  initialType?: string;
  isEdit?: boolean;
}>();

const userStore = useUserStore();
const formRef = ref();
const fileList = ref<UploadProps['fileList']>([]);
const contractTypeOptions = ref<DictDataDto[]>([]);
const pricingTypeOptions = ref<DictDataDto[]>([]);
const lifecycleStatusOptions = ref<DictDataDto[]>([]);
const currencyOptions = ref<DictDataDto[]>([]);
const paymentMethodOptions = ref<DictDataDto[]>([]);
const customerSelectorVisible = ref(false);
const selectedManagerInfo = ref<any[]>([]);

// Handle manual upload
const beforeUpload: UploadProps['beforeUpload'] = file => {
  fileList.value = [...(fileList.value || []), file];
  return false;
};

const handleRemoveFile: UploadProps['onRemove'] = async (file) => {
  if (file.url) {
    try {
        await deleteContractFile(file.url);
        message.success('文件已删除');
        return true;
    } catch (e) {
        message.error('删除失败');
        return false;
    }
  }
  return true;
};

onMounted(async () => {
  const [typeRes, pricingRes, currencyRes, paymentRes, lifecycleRes] = await Promise.all([
    getDictDataByCode('contract_type'),
    getDictDataByCode('contract_pricing_type'),
    getDictDataByCode('contract_currency'),
    getDictDataByCode('contract_payment_method'),
    getDictDataByCode('contract_status')
  ]);
  contractTypeOptions.value = typeRes || [];
  pricingTypeOptions.value = pricingRes || [];
  currencyOptions.value = currencyRes || [];
  paymentMethodOptions.value = paymentRes || [];
  lifecycleStatusOptions.value = lifecycleRes || [];
  
  // Set default value for type if no type is currently selected
  if (!formState.type && contractTypeOptions.value.length > 0) {
    const defaultOption = contractTypeOptions.value.find(item => item.isDefault);
    if (defaultOption) {
      formState.type = defaultOption.value;
    }
  }

  // Set default value for pricingType
  if (!formState.pricingType && pricingTypeOptions.value.length > 0) {
    const defaultOption = pricingTypeOptions.value.find(item => item.isDefault);
    if (defaultOption) {
      formState.pricingType = defaultOption.value;
    }
  }

  // Set default value for lifecycleStatus
  if (!formState.lifecycleStatus && lifecycleStatusOptions.value.length > 0) {
    const defaultOption = lifecycleStatusOptions.value.find(item => item.isDefault);
    if (defaultOption) {
      formState.lifecycleStatus = defaultOption.value;
    }
  }

  // Set default value for currency
  if (!formState.currency && currencyOptions.value.length > 0) {
    const defaultOption = currencyOptions.value.find(item => item.isDefault);
    if (defaultOption) {
      formState.currency = defaultOption.value;
    }
  }

  // Set default value for paymentMethod
  if (!formState.paymentMethod && paymentMethodOptions.value.length > 0) {
    const defaultOption = paymentMethodOptions.value.find(item => item.isDefault);
    if (defaultOption) {
      formState.paymentMethod = defaultOption.value;
    }
  }

  // Set default manager to current user if not editing (manager is undefined)
  if (!formState.manager && userStore.username) {
    formState.manager = userStore.username;
    selectedManagerInfo.value = [{
      username: userStore.username,
      name: userStore.nickname || userStore.username,
      organization: userStore.currentOrg?.name || ''
    }];
  }
});

const formState = reactive({
  contractName: '',
  contractNo: '',
  customer: undefined as string | undefined,
  partnerId: undefined as number | undefined,
  type: props.initialType || undefined,
  pricingType: undefined as string | undefined,
  lifecycleStatus: undefined as string | undefined,
  signDate: undefined as Dayjs | undefined,
  manager: undefined as string | undefined,
  amount: 0,
  currency: undefined as string | undefined,
  paymentMethod: undefined as string | undefined,
  period: [] as any,
  description: '',
});

watch(() => props.initialType, (newVal) => {
  if (newVal) {
    formState.type = newVal;
  }
});

const rules = {
  contractName: [{ required: true, message: '请输入合同名称', trigger: 'blur' }],
  customer: [{ required: true, message: '请选择客户', trigger: 'change' }],
  type: [{ required: true, message: '请选择合同类型', trigger: 'change' }],
  pricingType: [{ required: true, message: '请选择总价类型', trigger: 'change' }],
  lifecycleStatus: [{ required: true, message: '请选择合同状态', trigger: 'change' }],
  signDate: [{ required: true, message: '请选择签订日期', trigger: 'change' }],
  amount: [{ required: true, message: '请输入合同金额', trigger: 'blur' }],
};

const openCustomerSelector = () => {
  customerSelectorVisible.value = true;
};

const handleCustomerSelect = (customer: ContractCustomerSelectDto) => {
  formState.customer = customer.name;
  formState.partnerId = Number(customer.id);
  // You can also populate other fields if needed, e.g. manager, contact info
};

const handleCustomerNameChange = () => {
  formState.partnerId = undefined;
};

const validate = () => {
  return formRef.value.validate();
};

const resetFields = () => {
  formRef.value.resetFields();
  fileList.value = [];
};

const getFormState = () => {
  // Separate existing files (string/JSON) and new files (File objects)
  const existingFiles = fileList.value?.filter(f => f.url).map(f => ({
      name: f.name,
      url: f.url,
      size: f.size,
      type: f.type,
      uploadTime: (f as any).uploadTime
  })) || [];
  
  const newFiles = fileList.value?.filter(f => !f.url).map(f => f.originFileObj) || [];

  return {
    ...formState,
    fileList: existingFiles,
    newUploadFiles: newFiles
  };
};

const onManagerChange = (user: any) => {
  if (user) {
    selectedManagerInfo.value = [user];
  } else {
    selectedManagerInfo.value = [];
  }
};

const setFormState = async (data: any) => {
  formState.contractName = data.contractName;
  formState.contractNo = data.contractNo;
  formState.customer = data.partnerName;
  formState.partnerId = data.partnerId;
  formState.type = data.type;
  formState.pricingType = data.pricingType;
  formState.lifecycleStatus = data.lifecycleStatus;
  formState.signDate = data.signDate ? dayjs(data.signDate) : undefined;
  formState.manager = data.manager;
  selectedManagerInfo.value = [];
  if (data.manager) {
    try {
      const users = await getUserList({ keyword: data.manager });
      const user = (users || []).find(u => u.username === data.manager);
      if (user) {
        selectedManagerInfo.value = [{
          username: user.username,
          name: user.nickname || user.username,
          organization: user.dept?.name || ''
        }];
      } else {
        selectedManagerInfo.value = [{
          username: data.manager,
          name: data.manager,
          organization: ''
        }];
      }
    } catch {
      selectedManagerInfo.value = [{
        username: data.manager,
        name: data.manager,
        organization: ''
      }];
    }
  }
  formState.amount = data.totalAmount;
  formState.currency = data.currency;
  formState.paymentMethod = data.paymentMethod;
  formState.period = [
    data.startDate ? dayjs(data.startDate) : undefined,
    data.endDate ? dayjs(data.endDate) : undefined
  ];
  formState.description = data.description;
  
  // attachments population logic removed as per user request: "Edit contract does not need to see attachments"
  fileList.value = [];
};

defineExpose({
  validate,
  resetFields,
  getFormState,
  setFormState
});
</script>
