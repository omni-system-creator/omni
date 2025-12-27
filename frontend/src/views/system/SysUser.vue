<template>
  <div class="sys-user-container">
    <SplitLayout>
      <template #left>
        <a-card :bordered="false" class="dept-card" :body-style="{ padding: '10px', height: 'calc(100% - 40px)', overflow: 'hidden' }">
          <template #title>
            <span><ApartmentOutlined /> 组织结构</span>
          </template>
          <DeptTree
            v-model:selectedKeys="selectedDeptKeys"
            @loaded="(data) => deptTreeData = data"
          />
        </a-card>
      </template>

      <template #right>
        <a-card :bordered="false" class="content-card">
          <template #title>
            <a-space>
              <a-input-search
                v-model:value="searchText"
                placeholder="搜索用户名/昵称"
                style="width: 250px"
                @search="handleSearch"
              />
            </a-space>
          </template>
          <template #extra>
            <a-button type="primary" @click="handleAdd">
              <template #icon><PlusOutlined /></template>
              新增用户
            </a-button>
          </template>

          <a-table
            :columns="columns"
            :data-source="filteredUsers"
            :loading="loading"
            row-key="id"
            :pagination="{ pageSize: 10 }"
            :scroll="{ x: 1000 }"
          >
            <template #bodyCell="{ column, record }">
              <template v-if="column.key === 'avatar'">
                <a-avatar :src="record.avatar">
                  <template #icon><UserOutlined /></template>
                </a-avatar>
              </template>
              
              <template v-else-if="column.key === 'dept'">
                <a-tag v-if="record.dept" color="cyan">{{ record.dept.name }}</a-tag>
                <span v-else>-</span>
              </template>

              <template v-else-if="column.key === 'isActive'">
                <a-tag :color="record.isActive ? 'success' : 'error'">
                  {{ record.isActive ? '启用' : '禁用' }}
                </a-tag>
              </template>
              
              <template v-else-if="column.key === 'roles'">
                <a-tag v-for="role in record.roles" :key="role" color="blue">{{ role }}</a-tag>
              </template>

              <template v-else-if="column.key === 'posts'">
                <a-tag v-for="(post, index) in record.posts" :key="index" color="purple">
                  {{ post.deptName }} - {{ post.postName }}
                </a-tag>
              </template>

              <template v-else-if="column.key === 'createdAt'">
                {{ formatDate(record.createdAt) }}
              </template>

              <template v-else-if="column.key === 'action'">
                <a-space divider type="vertical">
                  <a @click="handleEdit(record)">编辑</a>
                  <a @click="handleResetPwd(record)">重置密码</a>
                  <a-popconfirm
                    title="确定要删除该用户吗？此操作不可恢复"
                    ok-text="删除"
                    cancel-text="取消"
                    ok-type="danger"
                    @confirm="handleDelete(record)"
                    v-if="record.username !== 'admin'"
                  >
                    <a class="text-danger">删除</a>
                  </a-popconfirm>
                </a-space>
              </template>
            </template>
          </a-table>
        </a-card>
      </template>
    </SplitLayout>

    <!-- 用户表单弹窗 -->
    <a-modal
      v-model:open="modalVisible"
      :title="modalTitle"
      @ok="handleModalOk"
      :confirmLoading="confirmLoading"
      width="600px"
    >
      <a-form
        ref="formRef"
        :model="formState"
        :rules="rules"
        layout="vertical"
      >
        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="用户名" name="username">
              <a-input v-model:value="formState.username" :disabled="!!currentId" placeholder="请输入用户名" />
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="昵称" name="nickname">
              <a-input v-model:value="formState.nickname" placeholder="请输入昵称" />
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16" v-if="!currentId">
          <a-col :span="12">
            <a-form-item label="初始密码" name="password">
              <a-input-password v-model:value="formState.password" placeholder="请输入密码" />
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="所属部门" name="deptId">
              <a-tree-select
                v-model:value="formState.deptId"
                :tree-data="deptTreeData"
                :field-names="{ label: 'name', value: 'id', children: 'children' }"
                placeholder="请选择部门"
                allow-clear
                tree-default-expand-all
              />
            </a-form-item>
          </a-col>
           <a-col :span="12">
            <a-form-item label="手机号" name="phone">
              <a-input v-model:value="formState.phone" placeholder="请输入手机号" />
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="邮箱" name="email">
              <a-input v-model:value="formState.email" placeholder="请输入邮箱" />
            </a-form-item>
          </a-col>
          <a-col :span="12">
             <a-form-item label="状态" name="isActive" v-if="currentId && formState.username !== 'admin'">
                <a-switch v-model:checked="formState.isActive" checked-children="启用" un-checked-children="禁用" />
              </a-form-item>
          </a-col>
        </a-row>

        <a-form-item label="角色" name="roleIds">
          <a-select
            v-model:value="formState.roleIds"
            mode="multiple"
            placeholder="请选择角色"
            :options="roleOptions"
            :field-names="{ label: 'name', value: 'id' }"
          />
        </a-form-item>

        <a-form-item label="关联岗位">
          <div v-for="(item, index) in formState.postRelations" :key="index" style="display: flex; margin-bottom: 8px;">
            <a-tree-select
              v-model:value="item.deptId"
              :tree-data="deptTreeData"
              :field-names="{ label: 'name', value: 'id', children: 'children' }"
              placeholder="选择部门"
              style="width: 200px; margin-right: 8px;"
              tree-default-expand-all
              @change="handlePostDeptChange(index)"
            />
            <a-select
              v-model:value="item.postId"
              :options="getPostOptions(item.deptId)"
              :field-names="{ label: 'name', value: 'id' }"
              placeholder="选择岗位"
              style="flex: 1; margin-right: 8px;"
            />
            <MinusCircleOutlined @click="removePostRelation(index)" style="font-size: 20px; color: #ff4d4f; line-height: 32px; cursor: pointer;" />
          </div>
          <a-button type="dashed" block @click="addPostRelation">
            <PlusOutlined /> 添加关联岗位
          </a-button>
        </a-form-item>
      </a-form>
    </a-modal>

    <!-- 重置密码弹窗 -->
    <a-modal
      v-model:open="resetPwdVisible"
      title="重置密码"
      @ok="handleResetPwdSubmit"
      :confirmLoading="resetPwdLoading"
    >
      <a-form
        ref="resetPwdFormRef"
        :model="resetPwdState"
        :rules="resetPwdRules"
        layout="vertical"
      >
        <a-form-item label="新密码" name="newPassword">
          <a-input-password v-model:value="resetPwdState.newPassword" placeholder="请输入新密码">
            <template #addonAfter>
              <a-tooltip title="随机生成密码">
                <ThunderboltOutlined @click="handleGeneratePassword" style="cursor: pointer"/>
              </a-tooltip>
            </template>
          </a-input-password>
        </a-form-item>
        <a-form-item label="确认密码" name="confirmPassword">
          <a-input-password v-model:value="resetPwdState.confirmPassword" placeholder="请再次输入新密码" />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted, computed, reactive } from 'vue';
import { message } from 'ant-design-vue';
import { PlusOutlined, UserOutlined, ApartmentOutlined, MinusCircleOutlined, ThunderboltOutlined } from '@ant-design/icons-vue';
import { getUserList, createUser, updateUser, deleteUser, resetUserPassword, type UserListDto } from '@/api/user';
import { getRoleList, type RoleDto } from '@/api/role';
import { type Dept } from '@/api/dept';
import { getPostList, type Post } from '@/api/post';
import { generatePassword } from '@/utils/password';
import dayjs from 'dayjs';
import DeptTree from '@/components/DeptTree/index.vue';
import SplitLayout from '@/components/SplitLayout/index.vue';

const loading = ref(false);
const users = ref<UserListDto[]>([]);
const searchText = ref('');
const roleOptions = ref<RoleDto[]>([]);
const postOptions = ref<Post[]>([]);
const deptTreeData = ref<Dept[]>([]);
const selectedDeptKeys = ref<number[]>([]);

const columns = [
  { title: '头像', key: 'avatar', width: 60, align: 'center' },
  { title: '用户名', dataIndex: 'username', key: 'username' },
  { title: '昵称', dataIndex: 'nickname', key: 'nickname' },
  { title: '部门', key: 'dept' },
  { title: '角色', key: 'roles' },
  { title: '岗位', key: 'posts' },
  { title: '状态', key: 'isActive', width: 80 },
  { title: '创建时间', key: 'createdAt', width: 160 },
  { title: '操作', key: 'action', width: 180, align: 'center' },
];

const filteredUsers = computed(() => {
  let result = users.value;
  
  // 1. Dept Filter
  if (selectedDeptKeys.value.length > 0) {
      const deptId = selectedDeptKeys.value[0];
      if (typeof deptId === 'number') {
        // Need to find all sub-dept IDs if we want recursive filter?
        // For simplicity, just filter exact match or check if backend returns dept hierarchy path
        // Here we do simple exact match first, or recursive if we had helper
        const deptIds = getSubDeptIds(deptId, deptTreeData.value);
        result = result.filter(u => u.dept && deptIds.includes(u.dept.id));
      }
  }

  // 2. Search Text
  if (searchText.value) {
    const lower = searchText.value.toLowerCase();
    result = result.filter(u => 
      u.username.toLowerCase().includes(lower) || 
      (u.nickname && u.nickname.toLowerCase().includes(lower))
    );
  }
  return result;
});

const getSubDeptIds = (rootId: number, tree: Dept[]): number[] => {
    let ids: number[] = [rootId];
    const findNode = (nodes: Dept[]): Dept | undefined => {
        for (const node of nodes) {
            if (node.id === rootId) return node;
            if (node.children) {
                const found = findNode(node.children);
                if (found) return found;
            }
        }
        return undefined;
    };
    
    const rootNode = findNode(tree);
    if (rootNode) {
        const collectIds = (node: Dept) => {
            if (node.children) {
                node.children.forEach(child => {
                    ids.push(child.id);
                    collectIds(child);
                });
            }
        };
        collectIds(rootNode);
    }
    return ids;
};

const formatDate = (date: string) => {
  return dayjs(date).format('YYYY-MM-DD HH:mm:ss');
};

const loadData = async () => {
  loading.value = true;
  try {
    const res = await getUserList();
    users.value = res;
  } catch (error) {
    console.error(error);
  } finally {
    loading.value = false;
  }
};

const loadRoles = async () => {
  try {
    const res = await getRoleList();
    roleOptions.value = res;
  } catch (error) {
    console.error(error);
  }
};

const loadPosts = async () => {
  try {
    const res = await getPostList();
    postOptions.value = res;
  } catch (error) {
    console.error(error);
  }
};

// --- Modal Logic ---
const modalVisible = ref(false);
const confirmLoading = ref(false);
const modalTitle = ref('新增用户');
const currentId = ref<number | null>(null);
const formRef = ref();

const formState = reactive({
  username: '',
  password: '',
  nickname: '',
  email: '',
  phone: '',
  isActive: true,
  roleIds: [] as number[],
  deptId: undefined as number | undefined,
  postRelations: [] as { deptId: number | undefined, postId: number | undefined }[]
});

const rules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }, { min: 6, message: '密码至少6位', trigger: 'blur' }],
};

const handleAdd = () => {
  currentId.value = null;
  modalTitle.value = '新增用户';
  formState.username = '';
  formState.password = '';
  formState.nickname = '';
  formState.email = '';
  formState.phone = '';
  formState.isActive = true;
  formState.roleIds = [];
  formState.deptId = undefined;
  formState.postRelations = [];
  // If a dept is selected in tree, default to it
  if (selectedDeptKeys.value.length > 0) {
      formState.deptId = selectedDeptKeys.value[0];
  }
  modalVisible.value = true;
};

const handleEdit = (record: UserListDto) => {
  currentId.value = record.id;
  modalTitle.value = '编辑用户';
  formState.username = record.username;
  formState.password = ''; // 编辑时不回显密码
  formState.nickname = record.nickname || '';
  formState.email = record.email || '';
  formState.phone = record.phone || '';
  formState.isActive = record.isActive;
  formState.deptId = record.dept?.id;
  
  // 匹配角色名称到ID
  formState.roleIds = record.roles.map(roleName => {
    const role = roleOptions.value.find(r => r.name === roleName);
    return role ? role.id : 0;
  }).filter(id => id !== 0);

  // 岗位关联
  formState.postRelations = record.posts.map(p => ({
    deptId: p.deptId,
    postId: p.postId
  }));
  
  modalVisible.value = true;
};

const getPostOptions = (deptId: number | undefined) => {
  if (!deptId) return [];
  return postOptions.value.filter(p => p.deptId === deptId);
};

const handlePostDeptChange = (index: number) => {
  if (formState.postRelations[index]) {
    formState.postRelations[index].postId = undefined;
  }
};

const addPostRelation = () => {
  formState.postRelations.push({ deptId: undefined, postId: undefined });
};

const removePostRelation = (index: number) => {
  formState.postRelations.splice(index, 1);
};

const handleModalOk = async () => {
  try {
    await formRef.value.validate();
    confirmLoading.value = true;
    
    if (currentId.value) {
      // Update
      const postRelations = formState.postRelations
        .filter(p => p.deptId && p.postId)
        .map(p => ({ deptId: p.deptId as number, postId: p.postId as number }));

      await updateUser(currentId.value, {
        nickname: formState.nickname,
        email: formState.email,
        phone: formState.phone,
        isActive: formState.isActive,
        roleIds: formState.roleIds,
        deptId: formState.deptId,
        postRelations: postRelations
      });
      message.success('更新成功');
    } else {
      // Create
      const postRelations = formState.postRelations
        .filter(p => p.deptId && p.postId)
        .map(p => ({ deptId: p.deptId as number, postId: p.postId as number }));

      await createUser({
        username: formState.username,
        password: formState.password,
        nickname: formState.nickname,
        roleIds: formState.roleIds,
        deptId: formState.deptId,
        postRelations: postRelations
      });
      message.success('创建成功');
    }
    
    modalVisible.value = false;
    loadData();
  } catch (error) {
    console.error(error);
  } finally {
    confirmLoading.value = false;
  }
};

const handleDelete = async (record: UserListDto) => {
  try {
    await deleteUser(record.id);
    message.success('删除成功');
    loadData();
  } catch (error) {
    console.error(error);
  }
};

const handleResetPwd = async (record: UserListDto) => {
  currentId.value = record.id;
  resetPwdState.newPassword = '';
  resetPwdState.confirmPassword = '';
  resetPwdVisible.value = true;
};

// --- Reset Password Logic ---
const resetPwdVisible = ref(false);
const resetPwdLoading = ref(false);
const resetPwdFormRef = ref();
const resetPwdState = reactive({
  newPassword: '',
  confirmPassword: ''
});

const validateConfirmPassword = async (_rule: any, value: string) => {
  if (value === '') {
    return Promise.reject('请再次输入密码');
  } else if (value !== resetPwdState.newPassword) {
    return Promise.reject("两次输入的密码不一致!");
  } else {
    return Promise.resolve();
  }
};

const resetPwdRules = {
  newPassword: [{ required: true, message: '请输入新密码', trigger: 'blur' }, { min: 6, message: '密码至少6位', trigger: 'blur' }],
  confirmPassword: [{ required: true, validator: validateConfirmPassword, trigger: 'blur' }]
};

const handleGeneratePassword = () => {
  const pwd = generatePassword();
  resetPwdState.newPassword = pwd;
  resetPwdState.confirmPassword = pwd;
};

const handleResetPwdSubmit = async () => {
  try {
    await resetPwdFormRef.value.validate();
    if (!currentId.value) return;

    resetPwdLoading.value = true;
    await resetUserPassword(currentId.value, { newPassword: resetPwdState.newPassword });
    message.success('密码重置成功');
    resetPwdVisible.value = false;
  } catch (error) {
    console.error(error);
  } finally {
    resetPwdLoading.value = false;
  }
};



const handleSearch = () => {
  // 搜索逻辑已在 computed 中实现
};

onMounted(() => {
  loadData();
  loadRoles();
  loadPosts();
});
</script>

<style scoped>
.sys-user-container {
  flex: 1;
  padding: 16px;
}
.dept-card {
  height: 100%;
  display: flex;
  flex-direction: column;
}
:deep(.ant-card-body) {
  flex: 1;
  overflow: hidden;
}
.content-card {
  height: 100%;
  display: flex;
  flex-direction: column;
}
.text-danger {
  color: #ff4d4f;
}
</style>
