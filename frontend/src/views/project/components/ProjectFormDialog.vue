<script setup lang="ts">
import { ref, watch, reactive } from 'vue';
import type { Rule } from 'ant-design-vue/es/form';
import type { ProjectInfo } from '@/types/project';
import { useUserStore } from '@/stores/user';

const props = defineProps<{
  open: boolean;
  project?: ProjectInfo; // If provided, it's edit mode
  loading?: boolean;
}>();

const emit = defineEmits<{
  (e: 'update:open', value: boolean): void;
  (e: 'confirm', values: ProjectInfo): void;
}>();

const userStore = useUserStore();
const formRef = ref();
// Temporary storage for selected usernames
const selectedMemberUsernames = ref<string[]>([]);
const selectedManagerInfo = ref<any[]>([]);
const selectedMembersInfo = ref<any[]>([]);

const formState = reactive<ProjectInfo>({
  code: '',
  name: '',
  type: 'dev',
  manager: '',
  members: [],
  description: '',
  plannedStartDate: '',
  plannedEndDate: ''
});

const rules: Record<string, Rule[]> = {
  code: [{ required: true, message: '请输入项目编号', trigger: 'blur' }],
  name: [{ required: true, message: '请输入项目名称', trigger: 'blur' }],
  type: [{ required: true, message: '请选择项目类型', trigger: 'change' }],
  manager: [{ required: true, message: '请选择负责人', trigger: 'change' }],
};

watch(
  () => props.open,
  (val) => {
    if (val) {
      if (props.project) {
        Object.assign(formState, props.project);
        // Ensure members is array
        if (!formState.members) formState.members = [];
        // Map members to usernames for selection
        selectedMemberUsernames.value = formState.members.map(m => m.username);
        
        // Init display info for Members
        selectedMembersInfo.value = formState.members.map(m => ({
            username: m.username,
            name: m.name || m.username,
            organization: m.organization || ''
        }));
        
        // Init display info for Manager
        const mgr = formState.manager;
        if (mgr) {
            const mgrInMembers = formState.members.find(m => m.username === mgr);
            if (mgrInMembers) {
                selectedManagerInfo.value = [{
                    username: mgrInMembers.username,
                    name: mgrInMembers.name || mgrInMembers.username,
                    organization: mgrInMembers.organization || ''
                }];
            } else {
                 selectedManagerInfo.value = [{
                     username: mgr,
                     name: mgr, 
                     organization: ''
                 }];
            }
        } else {
            selectedManagerInfo.value = [];
        }

      } else {
        // Reset for create
        formState.code = '';
        formState.name = '';
        formState.type = 'dev';
        formState.manager = userStore.username; 
        formState.members = [];
        selectedMemberUsernames.value = [];
        formState.description = '';
        formState.plannedStartDate = '';
        formState.plannedEndDate = '';
        
        selectedManagerInfo.value = [{
            username: userStore.username,
            name: userStore.nickname || userStore.username,
            organization: '' 
        }];
        selectedMembersInfo.value = [];
      }
    }
  }
);

const onManagerChange = (user: any) => {
    if (user) {
        selectedManagerInfo.value = [user];
    } else {
        selectedManagerInfo.value = [];
    }
};

const onMembersChange = (users: any[]) => {
    selectedMembersInfo.value = users;
};

const handleOk = () => {
  formRef.value.validate().then(() => {
    // Map selected usernames back to ProjectMember objects
    // Preserve existing roles if member was already in list, else default to 'Member'
    const currentMembersMap = new Map(formState.members?.map(m => [m.username, m]));
    
    // Also consider newly selected members info from UserSelector
    const newMembersMap = new Map(selectedMembersInfo.value.map(m => [m.username, m]));

    formState.members = selectedMemberUsernames.value.map(username => {
      if (currentMembersMap.has(username)) {
        const existing = currentMembersMap.get(username)!;
        // Update name/org if available in new selection
        if (newMembersMap.has(username)) {
            const newInfo = newMembersMap.get(username);
            return {
                ...existing,
                name: newInfo.name,
                organization: newInfo.organization
            };
        }
        return existing;
      }
      // New member
      const newInfo = newMembersMap.get(username);
      return {
        username,
        name: newInfo?.name,
        organization: newInfo?.organization,
        role: 'Member' // Default role
      };
    });

    emit('confirm', { ...formState });
  });
};

const handleCancel = () => {
  emit('update:open', false);
};
</script>

<template>
  <a-modal
    :open="open"
    :title="project ? '编辑项目' : '新建项目'"
    :confirm-loading="loading"
    @ok="handleOk"
    @cancel="handleCancel"
    width="600px"
  >
    <a-form
      ref="formRef"
      :model="formState"
      :rules="rules"
      :label-col="{ span: 6 }"
      :wrapper-col="{ span: 16 }"
    >
      <a-form-item label="项目编号" name="code">
        <a-input v-model:value="formState.code" :disabled="!!project && !!project.code" placeholder="请输入项目编号" />
      </a-form-item>
      <a-form-item label="项目名称" name="name">
        <a-input v-model:value="formState.name" placeholder="请输入项目名称" />
      </a-form-item>
      <a-form-item label="项目类型" name="type">
        <a-select v-model:value="formState.type">
            <a-select-option value="dev">研发</a-select-option>
            <a-select-option value="impl">实施</a-select-option>
            <a-select-option value="internal">内部</a-select-option>
        </a-select>
      </a-form-item>
      <a-form-item label="负责人" name="manager">
         <UserSelector
            v-model:value="formState.manager"
            :initial-display-data="selectedManagerInfo"
            placeholder="请选择负责人"
            @change="onManagerChange"
        />
      </a-form-item>
      <a-form-item label="项目成员" name="members">
        <UserSelector
            v-model:value="selectedMemberUsernames"
            multiple
            :initial-display-data="selectedMembersInfo"
            placeholder="请选择项目成员"
            @change="onMembersChange"
        />
      </a-form-item>
       <a-form-item label="计划时间">
         <a-range-picker 
           :value="[formState.plannedStartDate || '', formState.plannedEndDate || '']" 
           value-format="YYYY-MM-DD"
           @change="(_dates: any, dateStrings: string[]) => { formState.plannedStartDate = dateStrings[0]; formState.plannedEndDate = dateStrings[1]; }"
         />
      </a-form-item>
      <a-form-item label="描述" name="description">
        <a-textarea v-model:value="formState.description" />
      </a-form-item>
    </a-form>
  </a-modal>
</template>
