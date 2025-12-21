<template>
  <div class="sys-user-container">
    <a-card :bordered="false">
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
      >
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'avatar'">
            <a-avatar :src="record.avatar">
              <template #icon><UserOutlined /></template>
            </a-avatar>
          </template>
          
          <template v-else-if="column.key === 'isActive'">
            <a-tag :color="record.isActive ? 'success' : 'error'">
              {{ record.isActive ? '启用' : '禁用' }}
            </a-tag>
          </template>
          
          <template v-else-if="column.key === 'roles'">
            <a-tag v-for="role in record.roles" :key="role" color="blue">{{ role }}</a-tag>
          </template>

          <template v-else-if="column.key === 'createdAt'">
            {{ formatDate(record.createdAt) }}
          </template>

          <template v-else-if="column.key === 'action'">
            <a-space divider type="vertical">
              <a @click="handleEdit(record)">编辑</a>
              <a-popconfirm
                title="确定要重置该用户的密码吗？"
                @confirm="handleResetPwd(record)"
              >
                <a>重置密码</a>
              </a-popconfirm>
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
            <a-form-item label="邮箱" name="email">
              <a-input v-model:value="formState.email" placeholder="请输入邮箱" />
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="手机号" name="phone">
              <a-input v-model:value="formState.phone" placeholder="请输入手机号" />
            </a-form-item>
          </a-col>
        </a-row>

        <a-form-item label="状态" name="isActive" v-if="currentId && formState.username !== 'admin'">
          <a-switch v-model:checked="formState.isActive" checked-children="启用" un-checked-children="禁用" />
        </a-form-item>

        <a-form-item label="角色" name="roleIds">
          <a-select
            v-model:value="formState.roleIds"
            mode="multiple"
            placeholder="请选择角色"
            :options="roleOptions"
            :field-names="{ label: 'name', value: 'id' }"
          />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted, computed, reactive } from 'vue';
import { message, Modal } from 'ant-design-vue';
import { PlusOutlined, UserOutlined } from '@ant-design/icons-vue';
import { getUserList, createUser, updateUser, deleteUser, resetUserPassword, type UserListDto } from '@/api/user';
import { getRoleList, type RoleDto } from '@/api/role';
import dayjs from 'dayjs';

const loading = ref(false);
const users = ref<UserListDto[]>([]);
const searchText = ref('');
const roleOptions = ref<RoleDto[]>([]);

const columns = [
  { title: '头像', key: 'avatar', width: 80, align: 'center' },
  { title: '用户名', dataIndex: 'username', key: 'username' },
  { title: '昵称', dataIndex: 'nickname', key: 'nickname' },
  { title: '角色', key: 'roles' },
  { title: '状态', key: 'isActive', width: 100 },
  { title: '创建时间', key: 'createdAt', width: 180 },
  { title: '操作', key: 'action', width: 200, align: 'center' },
];

const filteredUsers = computed(() => {
  if (!searchText.value) return users.value;
  const lower = searchText.value.toLowerCase();
  return users.value.filter(u => 
    u.username.toLowerCase().includes(lower) || 
    (u.nickname && u.nickname.toLowerCase().includes(lower))
  );
});

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
  roleIds: [] as number[]
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
  // 匹配角色名称到ID
  formState.roleIds = record.roles.map(roleName => {
    const role = roleOptions.value.find(r => r.name === roleName);
    return role ? role.id : 0;
  }).filter(id => id !== 0);
  
  modalVisible.value = true;
};

const handleModalOk = async () => {
  try {
    await formRef.value.validate();
    confirmLoading.value = true;
    
    if (currentId.value) {
      // Update
      await updateUser(currentId.value, {
        nickname: formState.nickname,
        email: formState.email,
        phone: formState.phone,
        isActive: formState.isActive,
        roleIds: formState.roleIds
      });
      message.success('更新成功');
    } else {
      // Create
      await createUser({
        username: formState.username,
        password: formState.password,
        nickname: formState.nickname,
        roleIds: formState.roleIds
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
  Modal.confirm({
    title: '重置密码',
    content: '请输入新密码：',
    // 这里简单演示，实际可以用自定义 content 渲染 input
    onOk: async () => {
       // 为了演示方便，这里重置为默认密码 123456
       try {
         await resetUserPassword(record.id, { newPassword: '123456' });
         message.success('密码已重置为 123456');
       } catch (error) {
         console.error(error);
       }
    }
  });
};

const handleSearch = () => {
  // 搜索逻辑已在 computed 中实现
};

onMounted(() => {
  loadData();
  loadRoles();
});
</script>

<style scoped>
.sys-user-container {
  padding: 24px;
}
.text-danger {
  color: #ff4d4f;
}
</style>
