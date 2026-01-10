<template>
  <a-form
    ref="formRef"
    :model="formState"
    :rules="rules"
    :label-col="{ span: 6 }"
    :wrapper-col="{ span: 16 }"
  >
    <a-row :gutter="16">
      <a-col :span="12">
        <a-form-item label="项目编号" name="code">
          <a-input v-model:value="formState.code" :disabled="isEdit" />
        </a-form-item>
      </a-col>
      <a-col :span="12">
        <a-form-item label="项目名称" name="name">
          <a-input v-model:value="formState.name" />
        </a-form-item>
      </a-col>
    </a-row>
    
    <a-row :gutter="16">
      <a-col :span="12">
        <a-form-item label="客户名称" name="customer">
          <a-input v-model:value="formState.customer" />
        </a-form-item>
      </a-col>
      <a-col :span="12">
        <a-form-item label="负责人" name="leader">
          <a-input v-model:value="formState.leader" />
        </a-form-item>
      </a-col>
    </a-row>

    <a-row :gutter="16">
      <a-col :span="12">
        <a-form-item label="地区" name="region">
          <a-select v-model:value="formState.region" placeholder="选择地区">
            <a-select-option value="华东">华东</a-select-option>
            <a-select-option value="华北">华北</a-select-option>
            <a-select-option value="华南">华南</a-select-option>
            <a-select-option value="西北">西北</a-select-option>
            <a-select-option value="西南">西南</a-select-option>
          </a-select>
        </a-form-item>
      </a-col>
      <a-col :span="12">
        <a-form-item label="项目类型" name="type">
          <a-select v-model:value="formState.type" placeholder="项目类型">
            <a-select-option v-for="item in tenderTypes" :key="item.value" :value="item.value">
              {{ item.label }}
            </a-select-option>
          </a-select>
        </a-form-item>
      </a-col>
    </a-row>

    <a-row :gutter="16">
      <a-col :span="12">
        <a-form-item label="预算金额" name="budget">
          <a-input v-model:value="formState.budget" />
        </a-form-item>
      </a-col>
      <a-col :span="12">
        <a-form-item label="开标时间" name="bidTime">
          <a-date-picker v-model:value="formState.bidTime" style="width: 100%" show-time format="YYYY-MM-DD HH:mm" />
        </a-form-item>
      </a-col>
    </a-row>

    <a-form-item label="项目状态" name="status">
      <a-select v-model:value="formState.status">
        <a-select-option value="进行中">进行中</a-select-option>
        <a-select-option value="已中标">已中标</a-select-option>
        <a-select-option value="未中标">未中标</a-select-option>
        <a-select-option value="流标">流标</a-select-option>
      </a-select>
    </a-form-item>

    <a-form-item label="项目描述" name="description" :label-col="{ span: 3 }" :wrapper-col="{ span: 20 }">
      <a-textarea v-model:value="formState.description" :rows="4" />
    </a-form-item>
  </a-form>
</template>

<script setup lang="ts">
import { ref, reactive, watch, onMounted } from 'vue';
import type { FormInstance } from 'ant-design-vue';
import { getDictDataByCode, type DictDataDto } from '@/api/dict';

interface Props {
  modelValue: any;
  isEdit?: boolean;
}

const props = withDefaults(defineProps<Props>(), {
  isEdit: false
});

const emit = defineEmits(['update:modelValue']);

const formRef = ref<FormInstance>();
const tenderTypes = ref<DictDataDto[]>([]);

const formState = reactive({ ...props.modelValue });

onMounted(async () => {
  const res = await getDictDataByCode('sales_bid_type');
  tenderTypes.value = res;
});

watch(() => props.modelValue, (val) => {
  Object.assign(formState, val);
}, { deep: true });

watch(formState, (val) => {
  emit('update:modelValue', val);
}, { deep: true });

const rules: Record<string, any[]> = {
  code: [{ required: true, message: '请输入项目编号', trigger: 'blur' }],
  name: [{ required: true, message: '请输入项目名称', trigger: 'blur' }],
  status: [{ required: true, message: '请选择项目状态', trigger: 'change' }]
};

const validate = () => {
  return formRef.value?.validate();
};

const resetFields = () => {
  formRef.value?.resetFields();
};

defineExpose({
  validate,
  resetFields
});
</script>
