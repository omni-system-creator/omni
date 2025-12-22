<template>
  <a-form
    ref="formRef"
    :model="formState"
    :rules="rules"
    :label-col="{ span: 6 }"
    :wrapper-col="{ span: 16 }"
  >
    <a-form-item label="文件名称" name="name">
      <a-input v-model:value="formState.name" placeholder="请输入文件名称" />
    </a-form-item>
    <a-form-item label="档号" name="code">
      <a-input v-model:value="formState.code" placeholder="请输入档号" />
    </a-form-item>
    <a-form-item label="来源" name="source">
      <a-input v-model:value="formState.source" placeholder="请输入来源部门" />
    </a-form-item>
    <a-form-item label="密级" name="securityLevel">
      <a-select v-model:value="formState.securityLevel" placeholder="请选择密级">
        <a-select-option value="绝密">绝密</a-select-option>
        <a-select-option value="机密">机密</a-select-option>
        <a-select-option value="秘密">秘密</a-select-option>
        <a-select-option value="公开">公开</a-select-option>
      </a-select>
    </a-form-item>
    <a-form-item label="存档年限" name="retentionPeriod">
      <a-select v-model:value="formState.retentionPeriod" placeholder="请选择存档年限">
        <a-select-option value="10年">10年</a-select-option>
        <a-select-option value="30年">30年</a-select-option>
        <a-select-option value="永久">永久</a-select-option>
      </a-select>
    </a-form-item>
    <a-form-item label="附件" name="file">
      <a-upload-dragger
        v-model:fileList="fileList"
        name="file"
        :multiple="false"
        :before-upload="beforeUpload"
        @change="handleChange"
      >
        <p class="ant-upload-drag-icon">
          <inbox-outlined />
        </p>
        <p class="ant-upload-text">点击或拖拽文件到此区域上传</p>
      </a-upload-dragger>
    </a-form-item>
  </a-form>
</template>

<script setup lang="ts">
import { reactive, ref } from 'vue';
import { InboxOutlined } from '@ant-design/icons-vue';
import type { UploadChangeParam } from 'ant-design-vue';

const formRef = ref();
const formState = reactive({
  name: '',
  code: '',
  source: '',
  securityLevel: undefined,
  retentionPeriod: undefined,
});

const fileList = ref([]);

const rules = {
  name: [{ required: true, message: '请输入文件名称', trigger: 'blur' }],
  code: [{ required: true, message: '请输入档号', trigger: 'blur' }],
  source: [{ required: true, message: '请输入来源', trigger: 'blur' }],
  securityLevel: [{ required: true, message: '请选择密级', trigger: 'change' }],
  retentionPeriod: [{ required: true, message: '请选择存档年限', trigger: 'change' }],
};

const beforeUpload = (_file: any) => {
  // Return false to prevent automatic upload
  return false;
};

const handleChange = (info: UploadChangeParam) => {
  // Handle file changes if needed
  console.log(info);
};

// Expose formRef and formState to parent
defineExpose({
  formRef,
  formState,
  fileList
});
</script>
