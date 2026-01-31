<template>
  <draggable-modal
    v-model:visible="visible"
    title="新增进展记录"
    :width="600"
    height="auto"
    :z-index="1010"
    :resizable="false"
    :maximizable="false"
    :confirm-loading="loading"
    :initial-x="initialX"
    :initial-y="initialY"
    :footer="true"
    @ok="handleOk"
    @cancel="handleCancel"
  >
    <a-form layout="vertical">
      <a-form-item label="记录内容">
        <a-textarea v-model:value="form.comment" :rows="4" placeholder="请输入进展记录内容" />
      </a-form-item>

      <a-form-item label="附件">
         <a-upload
           :before-upload="beforeUpload"
           :file-list="fileList"
           @remove="handleRemoveFile"
         >
           <a-button>
             <upload-outlined /> 添加附件
           </a-button>
         </a-upload>
      </a-form-item>
    </a-form>
  </draggable-modal>
</template>

<script lang="ts" setup>
import { ref, reactive, watch } from 'vue';
import { message } from 'ant-design-vue';
import type { UploadProps } from 'ant-design-vue';
import { UploadOutlined } from '@ant-design/icons-vue';
import { addTaskProcess, type CreateTaskProcessParams } from '@/api/task';
import DraggableModal from '@/components/DraggableModal.vue';

const props = defineProps<{
  visible: boolean;
  taskId: number;
  initialX?: number;
  initialY?: number;
  defaultAction?: string;
}>();

const emit = defineEmits(['update:visible', 'success']);

const visible = ref(props.visible);
const loading = ref(false);
const fileList = ref<UploadProps['fileList']>([]);

const form = reactive<CreateTaskProcessParams & { newStatus: string }>({
  action: props.defaultAction || 'process',
  comment: '',
  newStatus: '',
  attachmentIds: ''
});

watch(() => props.visible, (val) => {
  visible.value = val;
  if (val) {
    resetForm();
  }
});

watch(visible, (val) => {
  emit('update:visible', val);
});

const resetForm = () => {
  form.action = props.defaultAction || 'process';
  handleActionChange(form.action);
  form.comment = '';
  form.attachmentIds = '';
  fileList.value = [];
};

const handleActionChange = (value: any) => {
  const val = value as string;
  if (val === 'complete') {
    form.newStatus = 'completed';
  } else if (val === 'reopen') {
    form.newStatus = 'pending';
  } else {
    form.newStatus = '';
  }
};

const beforeUpload: UploadProps['beforeUpload'] = file => {
  fileList.value = [...(fileList.value || []), file];
  return false;
};

const handleRemoveFile: UploadProps['onRemove'] = file => {
  const index = fileList.value?.indexOf(file);
  const newFileList = fileList.value?.slice();
  newFileList?.splice(index!, 1);
  fileList.value = newFileList;
};

const handleOk = async () => {
  if (!form.comment && !form.action) {
    message.warning('请输入进展记录或选择操作');
    return;
  }
  
  loading.value = true;
  try {
    const data: CreateTaskProcessParams = {
      action: form.action,
      comment: form.comment,
      newStatus: form.newStatus || undefined,
      attachmentIds: undefined
    };

    // Extract raw files from fileList
    const files = fileList.value?.map(f => f.originFileObj as File).filter(f => !!f) || [];

    await addTaskProcess(props.taskId, data, files);
    
    message.success('处理成功');
    emit('success', { action: form.action });
    visible.value = false;
  } catch (error) {
    console.error(error);
  } finally {
    loading.value = false;
  }
};

const handleCancel = () => {
  visible.value = false;
};
</script>
