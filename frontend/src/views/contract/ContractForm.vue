<template>
  <a-form
    ref="formRef"
    :model="formState"
    :rules="rules as any"
    layout="vertical"
  >
    <!-- Section 1: Basic Info -->
    <a-divider orientation="left">基本信息</a-divider>
    <a-row :gutter="24">
      <a-col :span="12">
        <a-form-item label="合同名称" name="contractName">
          <a-input v-model:value="formState.contractName" placeholder="请输入合同名称" />
        </a-form-item>
      </a-col>
      <a-col :span="12">
        <a-form-item label="合同编号" name="contractNo">
          <a-input v-model:value="formState.contractNo" placeholder="请输入合同编号，可空" />
        </a-form-item>
      </a-col>
      <a-col :span="12">
        <a-form-item label="客户名称" name="customer">
          <div style="display: flex; gap: 8px;">
            <a-input v-model:value="formState.customer" placeholder="请选择客户" readonly @click="openCustomerSelector" />
            <a-button type="primary" @click="openCustomerSelector">选择</a-button>
          </div>
        </a-form-item>
      </a-col>
      <a-col :span="12">
        <a-form-item label="合同类型" name="type">
          <a-select v-model:value="formState.type" placeholder="请选择合同类型">
            <a-select-option v-for="item in contractTypeOptions" :key="item.value" :value="item.value">
              {{ item.label }}
            </a-select-option>
          </a-select>
        </a-form-item>
      </a-col>
      <a-col :span="12">
        <a-form-item label="总价类型" name="pricingType">
          <a-select v-model:value="formState.pricingType" placeholder="请选择总价类型">
            <a-select-option v-for="item in pricingTypeOptions" :key="item.value" :value="item.value">
              {{ item.label }}
            </a-select-option>
          </a-select>
        </a-form-item>
      </a-col>
      <a-col :span="12">
        <a-form-item label="负责人" name="manager">
          <UserSelector
            v-model:value="formState.manager"
            :initial-display-data="selectedManagerInfo"
            placeholder="请选择负责人"
            @change="onManagerChange"
          />
        </a-form-item>
      </a-col>
      <a-col :span="12">
        <a-form-item label="签订日期" name="signDate">
          <a-date-picker v-model:value="formState.signDate" style="width: 100%" />
        </a-form-item>
      </a-col>
      <a-col :span="12">
        <a-form-item label="有效期限" name="period">
          <a-range-picker v-model:value="formState.period" style="width: 100%" />
        </a-form-item>
      </a-col>
    </a-row>

    <!-- Section 2: Financial Info -->
    <a-divider orientation="left">财务条款</a-divider>
    <a-row :gutter="24">
      <a-col :span="8">
        <a-form-item label="合同金额" name="amount">
          <a-input-number
            v-model:value="formState.amount"
            :formatter="(value: any) => `¥ ${value}`.replace(/\B(?=(\d{3})+(?!\d))/g, ',')"
            :parser="(value: any) => value.replace(/\¥\s?|(,*)/g, '')"
            style="width: 100%"
          />
        </a-form-item>
      </a-col>
      <a-col :span="8">
        <a-form-item label="币种" name="currency">
          <a-select v-model:value="formState.currency">
            <a-select-option v-for="item in currencyOptions" :key="item.value" :value="item.value">
              {{ item.label }}
            </a-select-option>
          </a-select>
        </a-form-item>
      </a-col>
      <a-col :span="8">
        <a-form-item label="付款方式" name="paymentMethod">
          <a-select v-model:value="formState.paymentMethod">
            <a-select-option v-for="item in paymentMethodOptions" :key="item.value" :value="item.value">
              {{ item.label }}
            </a-select-option>
          </a-select>
        </a-form-item>
      </a-col>
    </a-row>
    


    <!-- Section 3: Details & Attachments -->
    <a-divider orientation="left">其他信息</a-divider>
    <a-form-item label="合同详情/备注" name="description">
      <a-textarea v-model:value="formState.description" :rows="4" placeholder="请输入合同详细条款或备注信息" />
    </a-form-item>

    <a-form-item label="附件上传" name="files">
      <a-upload-dragger
        v-model:fileList="formState.fileList"
        name="file"
        action="https://www.mocky.io/v2/5cc8019d300000980a055e76"
        @change="handleUploadChange"
      >
        <p class="ant-upload-drag-icon">
          <inbox-outlined />
        </p>
        <p class="ant-upload-text">点击或拖拽文件到此区域上传</p>
        <p class="ant-upload-hint">
          支持单个或批量上传。严禁上传公司内部绝密数据或其他违禁文件。
        </p>
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
import { message } from 'ant-design-vue';
import { InboxOutlined } from '@ant-design/icons-vue';
import type { UploadChangeParam } from 'ant-design-vue';
import dayjs from 'dayjs';
import type { Dayjs } from 'dayjs';
import { getDictDataByCode, type DictDataDto } from '@/api/dict';
import CustomerSelector from './components/CustomerSelector.vue';
import UserSelector from '@/components/UserSelector.vue';
import { getUserList } from '@/api/user';
import type { ContractCustomerSelectDto } from '@/api/contract';

const props = defineProps<{
  initialType?: string;
}>();

const formRef = ref();
const contractTypeOptions = ref<DictDataDto[]>([]);
const pricingTypeOptions = ref<DictDataDto[]>([]);
const currencyOptions = ref<DictDataDto[]>([]);
const paymentMethodOptions = ref<DictDataDto[]>([]);
const customerSelectorVisible = ref(false);
const selectedManagerInfo = ref<any[]>([]);

onMounted(async () => {
  const [typeRes, pricingRes, currencyRes, paymentRes] = await Promise.all([
    getDictDataByCode('contract_type'),
    getDictDataByCode('contract_pricing_type'),
    getDictDataByCode('contract_currency'),
    getDictDataByCode('contract_payment_method')
  ]);
  contractTypeOptions.value = typeRes || [];
  pricingTypeOptions.value = pricingRes || [];
  currencyOptions.value = currencyRes || [];
  paymentMethodOptions.value = paymentRes || [];
  
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
});

const formState = reactive({
  contractName: '',
  contractNo: '',
  customer: undefined as string | undefined,
  type: props.initialType || undefined,
  pricingType: undefined as string | undefined,
  signDate: undefined as Dayjs | undefined,
  manager: undefined,
  amount: 0,
  currency: undefined as string | undefined,
  paymentMethod: undefined as string | undefined,
  period: [] as any,
  description: '',
  fileList: [] as any[],
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
  signDate: [{ required: true, message: '请选择签订日期', trigger: 'change' }],
  amount: [{ required: true, message: '请输入合同金额', trigger: 'blur' }],
};

const handleUploadChange = (info: UploadChangeParam) => {
  const status = info.file.status;
  if (status !== 'uploading') {
    console.log(info.file, info.fileList);
  }
  if (status === 'done') {
    message.success(`${info.file.name} file uploaded successfully.`);
  } else if (status === 'error') {
    message.error(`${info.file.name} file upload failed.`);
  }
};

const openCustomerSelector = () => {
  customerSelectorVisible.value = true;
};

const handleCustomerSelect = (customer: ContractCustomerSelectDto) => {
  formState.customer = customer.name;
  // You can also populate other fields if needed, e.g. manager, contact info
};

const validate = () => {
  return formRef.value.validate();
};

const resetFields = () => {
  formRef.value.resetFields();
};

const getFormState = () => {
  return formState;
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
  formState.type = data.type;
  formState.pricingType = data.pricingType;
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
  formState.description = data.description;
  
  if (data.startDate && data.endDate) {
    formState.period = [dayjs(data.startDate), dayjs(data.endDate)];
  } else {
    formState.period = [];
  }
  
  if (data.files) {
    try {
      const files = JSON.parse(data.files);
      formState.fileList = Array.isArray(files) ? files : [];
    } catch (e) {
      formState.fileList = [];
    }
  } else {
    formState.fileList = [];
  }
};

defineExpose({
  validate,
  resetFields,
  getFormState,
  setFormState
});
</script>
