<script setup lang="ts">
import { ref, watch, reactive } from 'vue';
import dayjs from 'dayjs';

const props = defineProps<{
  open: boolean;
  initialName?: string;
  initialManager?: string;
  initialStartDate?: string;
  loading?: boolean;
}>();

const emit = defineEmits<{
  (e: 'update:open', value: boolean): void;
  (e: 'confirm', values: { code: string; name: string; manager: string; startDate: string }): void;
}>();

const formRef = ref();
const formState = reactive({
  code: '',
  name: '',
  manager: '',
  startDate: undefined as string | undefined
});

const rules = {
  code: [{ required: true, message: '请输入新项目编号', trigger: 'blur' }],
  name: [{ required: true, message: '请输入新项目名称', trigger: 'blur' }],
  manager: [{ required: true, message: '请输入负责人', trigger: 'blur' }],
  startDate: [{ required: true, message: '请选择开始日期', trigger: 'change' }]
};

watch(
  () => props.open,
  (val) => {
    if (val) {
      formState.code = ''; // User should define new code
      formState.name = props.initialName ? `${props.initialName}_copy` : '';
      formState.manager = props.initialManager || '';
      formState.startDate = props.initialStartDate || dayjs().format('YYYY-MM-DD');
    }
  }
);

const handleOk = () => {
  formRef.value
    .validate()
    .then(() => {
      emit('confirm', {
        code: formState.code,
        name: formState.name,
        manager: formState.manager,
        startDate: formState.startDate!
      });
    })
    .catch((err: any) => {
      console.log('Validate Failed:', err);
    });
};

const handleCancel = () => {
  emit('update:open', false);
};
</script>

<template>
  <a-modal
    :open="open"
    title="克隆项目"
    :confirm-loading="loading"
    @ok="handleOk"
    @cancel="handleCancel"
  >
    <a-form
      ref="formRef"
      :model="formState"
      :rules="rules"
      :label-col="{ span: 6 }"
      :wrapper-col="{ span: 16 }"
    >
      <a-form-item label="新项目编号" name="code">
        <a-input v-model:value="formState.code" placeholder="请输入唯一编号" />
      </a-form-item>
      
      <a-form-item label="新项目名称" name="name">
        <a-input v-model:value="formState.name" placeholder="请输入项目名称" />
      </a-form-item>
      
      <a-form-item label="负责人" name="manager">
        <a-input v-model:value="formState.manager" placeholder="请输入负责人" />
      </a-form-item>
      
      <a-form-item label="新的开始日期" name="startDate">
        <a-date-picker
          v-model:value="formState.startDate"
          value-format="YYYY-MM-DD"
          style="width: 100%"
          :allowClear="false"
        />
        <div class="tip">所有任务时间将根据开始日期的变化进行平移</div>
      </a-form-item>
    </a-form>
  </a-modal>
</template>

<style scoped>
.tip {
  font-size: 12px;
  color: #888;
  margin-top: 4px;
}
</style>
