<template>
  <draggable-modal
    v-model:visible="visible"
    :title="isAssignMode ? '派发任务' : '新建待办事项'"
    :confirm-loading="loading"
    :width="600"
    height="auto"
    :centered="true"
    :footer="true"
    :resizable="false"
    :maximizable="false"
    @ok="handleOk"
    @cancel="handleCancel"
  >
    <a-form
      ref="formRef"
      :model="formState"
      :rules="rules"
      layout="vertical"
    >
      <a-form-item label="任务标题" name="title">
        <a-input v-model:value="formState.title" placeholder="请输入任务标题" />
      </a-form-item>

      <a-row :gutter="16">
        <a-col :span="12">
          <a-form-item label="任务类型" name="type">
            <a-select v-model:value="formState.type" placeholder="请选择任务类型">
              <a-select-option value="task">任务</a-select-option>
              <a-select-option value="todo">待办</a-select-option>
              <a-select-option value="bug">缺陷</a-select-option>
              <a-select-option value="feature">需求</a-select-option>
            </a-select>
          </a-form-item>
        </a-col>
        <a-col :span="12">
          <a-form-item label="优先级" name="priority">
            <a-select v-model:value="formState.priority" placeholder="请选择优先级">
              <a-select-option value="high">高</a-select-option>
              <a-select-option value="medium">中</a-select-option>
              <a-select-option value="low">低</a-select-option>
            </a-select>
          </a-form-item>
        </a-col>
      </a-row>
      
      <a-form-item :label="isAssignMode ? '指派给' : '负责人'" name="assignee">
         <UserSelector
            v-model:value="formState.assignee"
            :initial-display-data="selectedUsers"
            placeholder="请选择执行人"
            :multiple="false"
            @change="handleUserChange"
         />
      </a-form-item>

      <a-form-item label="任务成员" name="members">
         <UserSelector
            v-model:value="formState.members"
            :initial-display-data="selectedMembers"
            placeholder="请选择任务成员"
            :multiple="true"
            @change="handleMembersChange"
         />
      </a-form-item>
      
      <a-row :gutter="16">
        <a-col :span="12">
          <a-form-item label="截止时间" name="deadline">
            <a-date-picker
              v-model:value="formState.deadline"
              show-time
              format="YYYY-MM-DD HH:mm:ss"
              style="width: 100%"
              placeholder="请选择截止时间"
            />
          </a-form-item>
        </a-col>
      </a-row>
      
      <a-form-item label="任务描述" name="description">
        <a-textarea
          v-model:value="formState.description"
          placeholder="请输入任务描述"
          :rows="4"
        />
      </a-form-item>

      <a-form-item label="附件">
        <a-upload
          v-model:file-list="fileList"
          :before-upload="beforeUpload"
          multiple
        >
          <a-button>
            <upload-outlined />
            选择附件
          </a-button>
        </a-upload>
      </a-form-item>
    </a-form>
  </draggable-modal>
</template>

<script lang="ts" setup>
import { ref, reactive, watch } from 'vue';
import type { FormInstance, UploadProps } from 'ant-design-vue';
import type { Rule } from 'ant-design-vue/es/form';
import { UploadOutlined } from '@ant-design/icons-vue';
import dayjs from 'dayjs';
import UserSelector from '@/components/UserSelector.vue';
import DraggableModal from '@/components/DraggableModal.vue';
import { createTask, type CreateTaskParams } from '@/api/task';
import { message } from 'ant-design-vue';
import { useUserStore } from '@/stores/user';

const props = defineProps<{
  visible: boolean;
  isAssignMode: boolean;
}>();

const emit = defineEmits(['update:visible', 'success']);

const userStore = useUserStore();

const visible = ref(props.visible);
const formRef = ref<FormInstance>();
const assigneeName = ref('');
const assigneeId = ref<string | number>('');
const selectedUsers = ref<any[]>([]);
const memberIds = ref<number[]>([]);
const selectedMembers = ref<any[]>([]);
const loading = ref(false);
const fileList = ref<UploadProps['fileList']>([]);

interface TaskFormState {
  title: string;
  type: string;
  priority: string;
  deadline: any;
  description: string;
  assignee: number | string | undefined;
  members: any;
}

const formState = reactive<TaskFormState>({
  title: '',
  type: 'task',
  priority: 'medium',
  deadline: undefined,
  description: '',
  assignee: undefined,
  members: undefined,
});

const beforeUpload: UploadProps['beforeUpload'] = () => {
  return false;
};

const rules: Record<string, Rule[]> = {
    title: [{ required: true, message: '请输入任务标题', trigger: 'blur' }],
    type: [{ required: true, message: '请选择任务类型', trigger: 'change' }],
    priority: [{ required: true, message: '请选择优先级', trigger: 'change' }],
  deadline: [{ required: false }],
  assignee: [{ required: true, message: '请选择执行人', trigger: 'change' }],
  members: [{ required: false }],
};

watch(() => props.visible, (val) => {
  visible.value = val;
  if (val) {
    resetForm();
  }
});

watch(visible, (val) => {
  emit('update:visible', val);
});

const handleUserChange = (user: any) => {
  if (user) {
    assigneeName.value = user.name;
    assigneeId.value = user.id;
    selectedUsers.value = [user];
  } else {
    assigneeName.value = '';
    assigneeId.value = '';
    selectedUsers.value = [];
  }
};

const handleMembersChange = (users: any[]) => {
  if (users && users.length > 0) {
    memberIds.value = users.map(u => u.id);
    selectedMembers.value = users;
  } else {
    memberIds.value = [];
    selectedMembers.value = [];
  }
};

const handleOk = () => {
  formRef.value?.validate().then(async () => {
    loading.value = true;
    try {
      const params: CreateTaskParams = {
        title: formState.title,
        type: formState.type,
        priority: formState.priority,
        description: formState.description,
        deadline: formState.deadline ? dayjs(formState.deadline).format('YYYY-MM-DDTHH:mm:ss') : undefined,
        assigneeId: assigneeId.value ? String(assigneeId.value) : undefined,
        memberIds: memberIds.value
      };
      
      const files = fileList.value?.map(f => f.originFileObj).filter(f => !!f) as File[];
      
      await createTask(params, files);
      message.success('任务创建成功');
      emit('success');
      visible.value = false;
      resetForm();
    } catch (error) {
      console.error(error);
    } finally {
      loading.value = false;
    }
  }).catch(error => {
    console.log('Validation failed:', error);
  });
};

const handleCancel = () => {
  visible.value = false;
  resetForm();
};

const resetForm = () => {
  formRef.value?.resetFields();
  
  formState.title = '';
  formState.type = props.isAssignMode ? 'task' : 'todo';
  formState.priority = 'medium';
  formState.deadline = undefined;
  formState.description = '';
  formState.members = undefined;
  memberIds.value = [];
  selectedMembers.value = [];
  fileList.value = [];

  if (props.isAssignMode) {
    formState.assignee = undefined;
    assigneeName.value = '';
    assigneeId.value = '';
    selectedUsers.value = [];
  } else {
    // Default to current user for Todo
    const userId = userStore.id;
    formState.assignee = userId;
    assigneeName.value = userStore.nickname || userStore.username;
    assigneeId.value = userId;
    selectedUsers.value = [{ 
      id: userStore.id, 
      name: userStore.nickname || userStore.username,
      username: userStore.username,
      organization: userStore.currentOrg?.name || ''
    }];
  }
};
</script>
