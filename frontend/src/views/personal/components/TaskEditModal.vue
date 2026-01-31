<template>
  <draggable-modal
    v-model:visible="visible"
    title="编辑任务"
    :width="600"
    height="auto"
    :footer="true"
    :confirm-loading="loading"
    :z-index="1020"
    :resizable="false"
    :maximizable="false"
    :centered="true"
    body-padding="0px"
    @ok="handleSave"
    @cancel="handleCancel"
  >
    <a-form layout="vertical" :model="form" class="task-edit-form">
      <a-form-item label="任务标题">
        <a-input v-model:value="form.title" placeholder="请输入任务标题" />
      </a-form-item>
      
      <a-row :gutter="16">
        <a-col :span="8">
          <a-form-item label="任务类型">
            <a-select v-model:value="form.type">
              <a-select-option value="task">任务</a-select-option>
              <a-select-option value="todo">待办</a-select-option>
              <a-select-option value="bug">缺陷</a-select-option>
              <a-select-option value="feature">需求</a-select-option>
            </a-select>
          </a-form-item>
        </a-col>
        <a-col :span="8">
          <a-form-item label="优先级">
            <a-select v-model:value="form.priority">
              <a-select-option value="high">高</a-select-option>
              <a-select-option value="medium">中</a-select-option>
              <a-select-option value="low">低</a-select-option>
            </a-select>
          </a-form-item>
        </a-col>
        <a-col :span="8">
          <a-form-item label="状态">
            <a-select v-model:value="form.status">
              <a-select-option value="pending">待处理</a-select-option>
              <a-select-option value="in_progress">进行中</a-select-option>
              <a-select-option value="completed">已完成</a-select-option>
            </a-select>
          </a-form-item>
        </a-col>
      </a-row>

      <a-row :gutter="16">
        <a-col :span="12">
          <a-form-item label="开始时间">
            <a-date-picker 
              v-model:value="form.startTime" 
              show-time 
              value-format="YYYY-MM-DDTHH:mm:ss" 
              format="YYYY-MM-DD HH:mm:ss"
              style="width: 100%" 
            />
          </a-form-item>
        </a-col>
        <a-col :span="12">
          <a-form-item label="截止时间">
            <a-date-picker 
              v-model:value="form.deadline" 
              show-time 
              value-format="YYYY-MM-DDTHH:mm:ss" 
              format="YYYY-MM-DD HH:mm:ss"
              style="width: 100%" 
            />
          </a-form-item>
        </a-col>
      </a-row>

      <a-form-item label="负责人">
        <user-selector
          v-model:value="assigneeUsername"
          :initial-display-data="assigneeDisplay"
          @change="handleAssigneeChange"
          placeholder="选择负责人"
          :z-index="1100"
          value-type="username"
        />
      </a-form-item>

      <a-form-item label="任务成员">
        <user-selector
          v-model:value="memberUsernames"
          :initial-display-data="membersDisplay"
          @change="handleMembersChange"
          placeholder="选择任务成员"
          :multiple="true"
          value-type="username"
          :z-index="1100"
        />
      </a-form-item>

      <a-form-item label="任务描述">
        <a-textarea v-model:value="form.description" :rows="6" placeholder="请输入任务描述" />
      </a-form-item>
    </a-form>
  </draggable-modal>
</template>

<script lang="ts" setup>
import { ref, reactive, watch } from 'vue';
import { message } from 'ant-design-vue';
import { updateTask, type UpdateTaskParams } from '@/api/task';
import DraggableModal from '@/components/DraggableModal.vue';
import UserSelector from '@/components/UserSelector.vue';

const props = defineProps<{
  visible: boolean;
  task: any;
}>();

const emit = defineEmits(['update:visible', 'success']);

const visible = ref(props.visible);
const loading = ref(false);
const form = reactive<UpdateTaskParams>({});

// User Selection State
// We use usernames for v-model binding to satisfy UserSelector's echo logic
// But we store IDs in the form for API submission
const assigneeUsername = ref<string | undefined>(undefined);
const memberUsernames = ref<string[]>([]);

const assigneeDisplay = ref<any[]>([]);
const membersDisplay = ref<any[]>([]);

watch(() => props.visible, (val) => {
  visible.value = val;
  if (val && props.task) {
    initForm();
  }
});

watch(visible, (val) => {
  emit('update:visible', val);
});

const initForm = () => {
  if (!props.task) return;
  
  // Basic fields
  form.title = props.task.title;
  form.type = props.task.type;
  form.priority = props.task.priority;
  form.status = props.task.status;
  form.startTime = props.task.startTime;
  form.deadline = props.task.deadline;
  form.description = props.task.description;
  form.assigneeId = props.task.assigneeId ? Number(props.task.assigneeId) : undefined;
  form.memberIds = props.task.members?.map((m: any) => m.userId) || [];

  // Assignee Display
  if (props.task.assigneeId) {
    // If we have username, use it. If not, we might have an issue with echo if UserSelector relies on username.
    // Assuming task.assigneeName is available, but UserSelector needs username for filtering in initialDisplayData.
    // Ideally task object should have assigneeUsername. If not, echo might be imperfect without it.
    // For now, let's construct what we can.
    assigneeDisplay.value = [{
      id: Number(props.task.assigneeId),
      username: props.task.assigneeName, // Fallback/Best guess if username not separate
      name: props.task.assigneeName,
      avatar: props.task.assigneeAvatar
    }];
    assigneeUsername.value = props.task.assigneeName; 
  } else {
    assigneeDisplay.value = [];
    assigneeUsername.value = undefined;
  }

  // Member Display
  membersDisplay.value = props.task.members?.map((m: any) => ({
    id: m.userId,
    username: m.username,
    name: m.name,
    avatar: m.avatar
  })) || [];
  
  memberUsernames.value = props.task.members?.map((m: any) => m.username) || [];
};

const handleAssigneeChange = (val: any) => {
  if (val) {
    // Val is the user object
    form.assigneeId = val.id;
    assigneeUsername.value = val.username;
    assigneeDisplay.value = [val];
  } else {
    form.assigneeId = undefined;
    assigneeUsername.value = undefined;
    assigneeDisplay.value = [];
  }
};

const handleMembersChange = (users: any[]) => {
  form.memberIds = users?.map(u => u.id) || [];
  memberUsernames.value = users?.map(u => u.username) || [];
  membersDisplay.value = users || [];
};

const handleSave = async () => {
  if (!props.task?.id) return;
  
  loading.value = true;
  try {
    const res = await updateTask(props.task.id, form);
    message.success('任务更新成功');
    emit('success', res);
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

<style scoped>
.task-edit-form {
  padding: 16px;
}

.task-edit-form :deep(.ant-form-item:last-child) {
  margin-bottom: 0;
}
</style>
