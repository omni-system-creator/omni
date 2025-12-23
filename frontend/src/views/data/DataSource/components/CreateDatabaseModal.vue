<template>
  <a-modal
    :visible="visible"
    title="新建数据库"
    :confirmLoading="loading"
    @ok="handleOk"
    @cancel="handleCancel"
  >
    <a-form :model="formState" :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }">
      <a-form-item label="数据库名称" required>
        <a-input v-model:value="formState.name" placeholder="请输入数据库名称" />
      </a-form-item>
      <a-form-item label="字符集">
        <a-select v-model:value="formState.charSet">
          <a-select-option value="utf8mb4">utf8mb4</a-select-option>
          <a-select-option value="utf8">utf8</a-select-option>
          <a-select-option value="latin1">latin1</a-select-option>
        </a-select>
      </a-form-item>
      <a-form-item label="排序规则">
        <a-select v-model:value="formState.collation">
          <a-select-option value="utf8mb4_general_ci">utf8mb4_general_ci</a-select-option>
          <a-select-option value="utf8mb4_unicode_ci">utf8mb4_unicode_ci</a-select-option>
          <a-select-option value="utf8_general_ci">utf8_general_ci</a-select-option>
        </a-select>
      </a-form-item>
    </a-form>
  </a-modal>
</template>

<script setup lang="ts">
import { ref, reactive, watch } from 'vue';
import { message } from 'ant-design-vue';
import * as api from '@/api/dataSource';

const props = defineProps<{
  visible: boolean;
  connectionId: number;
}>();

const emit = defineEmits(['update:visible', 'success']);

const loading = ref(false);
const formState = reactive({
  name: '',
  charSet: 'utf8mb4',
  collation: 'utf8mb4_general_ci'
});

watch(
  () => props.visible,
  (val) => {
    if (val) {
      formState.name = '';
      formState.charSet = 'utf8mb4';
      formState.collation = 'utf8mb4_general_ci';
    }
  }
);

const handleCancel = () => {
  emit('update:visible', false);
};

const handleOk = async () => {
  if (!formState.name) {
    message.warning('请输入数据库名称');
    return;
  }
  loading.value = true;
  try {
    await api.createDatabase(props.connectionId, formState);
    message.success('数据库创建成功');
    emit('update:visible', false);
    emit('success');
  } catch (error) {
    console.error(error);
    message.error('创建失败');
  } finally {
    loading.value = false;
  }
};
</script>
