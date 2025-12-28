<template>
  <a-form
    ref="formRef"
    :model="formState"
    :rules="rules"
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
        <a-form-item label="合同编号" name="contractCode">
          <a-input v-model:value="formState.contractCode" placeholder="系统自动生成" disabled />
        </a-form-item>
      </a-col>
    </a-row>
    <a-row :gutter="24">
      <a-col :span="12">
        <a-form-item label="客户名称" name="customer">
          <a-select v-model:value="formState.customer" placeholder="请选择客户" show-search>
            <a-select-option value="cust001">上海未来科技有限公司</a-select-option>
            <a-select-option value="cust002">北京创新动力有限公司</a-select-option>
            <a-select-option value="cust003">深圳云端网络股份公司</a-select-option>
          </a-select>
        </a-form-item>
      </a-col>
      <a-col :span="12">
        <a-form-item label="合同类型" name="type">
          <a-select v-model:value="formState.type" placeholder="请选择合同类型">
            <a-select-option value="sales">销售合同</a-select-option>
            <a-select-option value="purchase">采购合同</a-select-option>
            <a-select-option value="cooperation">合作协议</a-select-option>
            <a-select-option value="other">其他合同</a-select-option>
          </a-select>
        </a-form-item>
      </a-col>
    </a-row>

    <a-row :gutter="24">
      <a-col :span="12">
        <a-form-item label="签订日期" name="signDate">
          <a-date-picker v-model:value="formState.signDate" style="width: 100%" />
        </a-form-item>
      </a-col>
      <a-col :span="12">
        <a-form-item label="负责人" name="manager">
          <a-select v-model:value="formState.manager" placeholder="请选择负责人">
            <a-select-option value="张三">张三</a-select-option>
            <a-select-option value="李四">李四</a-select-option>
          </a-select>
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
            <a-select-option value="CNY">人民币 (CNY)</a-select-option>
            <a-select-option value="USD">美元 (USD)</a-select-option>
            <a-select-option value="EUR">欧元 (EUR)</a-select-option>
          </a-select>
        </a-form-item>
      </a-col>
      <a-col :span="8">
        <a-form-item label="付款方式" name="paymentMethod">
          <a-select v-model:value="formState.paymentMethod">
            <a-select-option value="bank">银行转账</a-select-option>
            <a-select-option value="check">支票</a-select-option>
            <a-select-option value="cash">现金</a-select-option>
          </a-select>
        </a-form-item>
      </a-col>
    </a-row>
    
    <a-row :gutter="24">
      <a-col :span="12">
          <a-form-item label="有效期限" name="period">
            <a-range-picker v-model:value="formState.period" style="width: 100%" />
          </a-form-item>
      </a-col>
      <a-col :span="12">
          <a-form-item label="纳税人识别号" name="taxId">
            <a-input v-model:value="formState.taxId" placeholder="请输入纳税人识别号" />
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
  </a-form>
</template>

<script setup lang="ts">
import { reactive, ref, watch } from 'vue';
import { message } from 'ant-design-vue';
import { InboxOutlined } from '@ant-design/icons-vue';
import type { UploadChangeParam } from 'ant-design-vue';

const props = defineProps<{
  initialType?: string;
}>();

const formRef = ref();

const formState = reactive({
  contractName: '',
  contractCode: 'CNT-' + new Date().getTime(),
  customer: undefined,
  type: props.initialType || undefined,
  signDate: undefined,
  manager: undefined,
  amount: 0,
  currency: 'CNY',
  paymentMethod: 'bank',
  period: [],
  taxId: '',
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

const validate = () => {
  return formRef.value.validate();
};

const resetFields = () => {
  formRef.value.resetFields();
};

const getFormState = () => {
  return formState;
};

defineExpose({
  validate,
  resetFields,
  getFormState,
});
</script>
