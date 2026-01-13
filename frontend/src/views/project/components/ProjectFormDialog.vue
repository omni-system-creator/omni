<script setup lang="ts">
import { ref, watch, reactive, onMounted } from 'vue';
import type { Rule } from 'ant-design-vue/es/form';
import { TreeSelect } from 'ant-design-vue';
import { getUserList } from '@/api/user';
import { getDeptTree, type Dept } from '@/api/dept';
import type { ProjectInfo } from '@/types/project';
import { useUserStore } from '@/stores/user';

const SHOW_CHILD = TreeSelect.SHOW_CHILD;

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
const treeData = ref<any[]>([]);
// Temporary storage for selected usernames
const selectedMemberUsernames = ref<string[]>([]);

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

onMounted(async () => {
  try {
    const deptRes = await getDeptTree();
    cachedDeptTree.value = deptRes || [];

    // Init tree with root depts
    treeData.value = (deptRes || []).map(d => ({
        title: d.name,
        value: `dept-${d.id}`,
        key: `dept-${d.id}`,
        selectable: false,
        isLeaf: false // Allow expansion to load users/sub-depts
    }));
  } catch (e) {
    console.error(e);
  }
});

const cachedDeptTree = ref<Dept[]>([]);

const findDept = (depts: Dept[], id: number): Dept | undefined => {
    for (const d of depts) {
        if (d.id === id) return d;
        if (d.children) {
            const found = findDept(d.children, id);
            if (found) return found;
        }
    }
    return undefined;
};

const onLoadData = async (treeNode: any) => {
  const { value } = treeNode;
  if (!value || !value.startsWith('dept-')) return;
  
  const deptId = parseInt(value.split('-')[1]);
  if (isNaN(deptId)) return;

  try {
      // Fetch users for this dept
      const users = await getUserList({ deptId });
      
      // Get sub-depts from cache
      const currentDept = findDept(cachedDeptTree.value, deptId);
      const subDepts = currentDept?.children || [];

      const deptNodes = subDepts.map(d => ({
        title: d.name,
        value: `dept-${d.id}`,
        key: `dept-${d.id}`,
        selectable: false,
        isLeaf: false
      }));

      const userNodes = users.map(u => {
          const postNames = u.posts && u.posts.length > 0 ? ` - ${u.posts.map(p => p.postName).join(', ')}` : '';
          return {
              title: `${u.nickname || u.username} (${u.username})${postNames}`,
              value: u.username,
              key: u.username,
              isLeaf: true
          };
      });

      treeNode.dataRef.children = [...deptNodes, ...userNodes];
      treeData.value = [...treeData.value];
  } catch (e) {
      console.error(e);
  }
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
      } else {
        // Reset for create
        formState.code = '';
        formState.name = '';
        formState.type = 'dev';
        formState.manager = userStore.username; // Default to current user
        formState.members = [];
        selectedMemberUsernames.value = [];
        formState.description = '';
        formState.plannedStartDate = '';
        formState.plannedEndDate = '';
      }
    }
  }
);

const handleOk = () => {
  formRef.value.validate().then(() => {
    // Map selected usernames back to ProjectMember objects
    // Preserve existing roles if member was already in list, else default to 'Member'
    const currentMembersMap = new Map(formState.members?.map(m => [m.username, m]));
    
    formState.members = selectedMemberUsernames.value.map(username => {
      if (currentMembersMap.has(username)) {
        return currentMembersMap.get(username)!;
      }
      return {
        username,
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
         <a-tree-select
            v-model:value="formState.manager"
            style="width: 100%"
            :dropdown-style="{ maxHeight: '400px', overflow: 'auto' }"
            :tree-data="treeData"
            :load-data="onLoadData"
            placeholder="请选择负责人"
            allow-clear
            show-search
            tree-node-filter-prop="title"
        />
      </a-form-item>
      <a-form-item label="项目成员" name="members">
        <a-tree-select
            v-model:value="selectedMemberUsernames"
            style="width: 100%"
            :dropdown-style="{ maxHeight: '400px', overflow: 'auto' }"
            :tree-data="treeData"
            :load-data="onLoadData"
            placeholder="请选择项目成员"
            allow-clear
            multiple
            tree-checkable
            :show-checked-strategy="SHOW_CHILD"
            show-search
            tree-node-filter-prop="title"
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
