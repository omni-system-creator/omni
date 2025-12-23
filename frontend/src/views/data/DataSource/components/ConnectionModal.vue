<template>
  <a-modal
    :visible="visible"
    :title="isEditMode ? '编辑数据源连接' : '新建数据源连接'"
    :confirmLoading="confirmLoading"
    @ok="handleOk"
    @cancel="handleCancel"
  >
    <a-form :model="formState" :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }">
      <a-form-item label="连接名称" required>
        <a-input v-model:value="formState.name" />
      </a-form-item>
      <a-form-item label="数据源类型" required>
        <a-select v-model:value="formState.type">
          <a-select-option value="mysql">MySQL</a-select-option>
          <a-select-option value="postgresql" disabled>PostgreSQL</a-select-option>
          <a-select-option value="oracle" disabled>Oracle</a-select-option>
          <a-select-option value="sqlserver" disabled>SQL Server</a-select-option>
        </a-select>
      </a-form-item>
      <a-form-item label="主机地址" required>
        <a-input v-model:value="formState.host" placeholder="127.0.0.1" />
      </a-form-item>
      <a-form-item label="端口" required>
        <a-input v-model:value="formState.port" placeholder="3306" />
      </a-form-item>
      <a-form-item label="用户名" required>
        <a-input v-model:value="formState.user" />
      </a-form-item>
      <a-form-item label="密码" required>
        <a-input-password v-model:value="formState.password" :placeholder="isEditMode ? '不修改请留空' : ''" />
      </a-form-item>
      <a-form-item label="默认数据库">
        <a-input v-model:value="formState.database" />
      </a-form-item>
    </a-form>
    <template #footer>
      <a-button key="test" :loading="testingConnection" @click="handleTestConnection">测试连接</a-button>
      <a-button key="back" @click="handleCancel">取消</a-button>
      <a-button key="submit" type="primary" :loading="confirmLoading" @click="handleOk">确定</a-button>
    </template>
  </a-modal>
</template>

<script setup lang="ts">
import { ref, reactive, watch, computed } from 'vue';
import { message } from 'ant-design-vue';
import * as api from '@/api/dataSource';
import type { CreateDataSourceDto } from '@/api/dataSource';

const props = defineProps<{
  visible: boolean;
  editId?: number;
}>();

const emit = defineEmits(['update:visible', 'success']);

const confirmLoading = ref(false);
const testingConnection = ref(false);
const isEditMode = computed(() => !!props.editId);

const formState = reactive<CreateDataSourceDto>({
  name: '',
  type: 'mysql',
  host: '',
  port: '3306',
  user: '',
  password: '',
  database: '',
});

watch(
  () => props.visible,
  async (val) => {
    if (val) {
      if (props.editId) {
        // Edit mode: fetch data
        try {
          const res = await api.getDataSource(props.editId);
          if (res) {
            formState.name = res.name;
            formState.type = res.type;
            formState.host = res.host;
            formState.port = res.port;
            formState.user = res.user;
            formState.database = res.database;
            formState.password = ''; // Security
          }
        } catch (error) {
          message.error('获取连接详情失败');
        }
      } else {
        // Create mode: reset
        formState.name = '';
        formState.type = 'mysql';
        formState.host = '';
        formState.port = '3306';
        formState.user = '';
        formState.password = '';
        formState.database = '';
      }
    }
  }
);

const handleCancel = () => {
  emit('update:visible', false);
};

const handleTestConnection = async () => {
  testingConnection.value = true;
  try {
    const res = await api.testConnection(formState);
    if (res) {
      message.success('连接成功');
    } else {
      message.error('连接测试失败');
    }
  } catch (error) {
    message.error('连接测试出错');
  } finally {
    testingConnection.value = false;
  }
};

const handleOk = async () => {
  confirmLoading.value = true;
  try {
    if (isEditMode.value && props.editId) {
      await api.updateDataSource(props.editId, formState);
      message.success('更新成功');
    } else {
      await api.createDataSource(formState);
      message.success('创建成功');
    }
    emit('update:visible', false);
    emit('success');
  } catch (error) {
    message.error(isEditMode.value ? '更新失败' : '创建失败');
  } finally {
    confirmLoading.value = false;
  }
};
</script>
