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
            :root-id="currentOrgId"
            :show-global-node="userStore.isAdmin"
            :global-node-id="GLOBAL_DEPT_ID"
            global-node-label="全局用户"
            @loaded="onDeptLoaded"
            @select="handleSelect"
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
            :pagination="pagination"
            @change="handleTableChange"
            :scroll="{ x: 1000 }"
            style="flex: 1"
          >
            <template #bodyCell="{ column, record, index }">
              <template v-if="column.key === 'index'">
                {{ (pagination.current - 1) * pagination.pageSize + index + 1 }}
              </template>
              <template v-else-if="column.key === 'avatar'">
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

              <template v-else-if="column.key === 'superiorName'">
                <div v-if="record.superiorName" style="display: flex; align-items: center; gap: 8px;">
                  <a-avatar :src="record.superiorAvatar" size="small">
                    <template #icon><UserOutlined /></template>
                  </a-avatar>
                  <span>{{ record.superiorName }}</span>
                </div>
                <span v-else>-</span>
              </template>

              <template v-else-if="column.key === 'createdAt'">
                {{ formatDate(record.createdAt) }}
              </template>

              <template v-else-if="column.key === 'action'">
                <div style="display: flex; justify-content: center;">
                  <a-dropdown :trigger="['hover']">
                    <a class="ant-dropdown-link" @click.prevent>
                      <MoreOutlined />
                    </a>
                    <template #overlay>
                      <a-menu>
                        <a-menu-item
                          v-if="showImpersonateAction(record as UserListDto)"
                          key="impersonate"
                          @click="handleImpersonate(record as UserListDto)"
                        >
                          <!-- 用户指定的模拟登录 SVG 图标 -->
                          <svg
                            viewBox="0 0 16 16"
                            width="1em"
                            height="1em"
                            fill="currentColor"
                            style="vertical-align: -2px"
                          >
                            <g transform="translate(0, 0) scale(0.0625)">
                              <path d="m140.24 132.24l-40 40a6 6 0 0 1-8.48-8.48L121.51 134H24a6 6 0 0 1 0-12h97.51L91.76 92.24a6 6 0 0 1 8.48-8.48l40 40a6 6 0 0 1 0 8.48M200 34h-64a6 6 0 0 0 0 12h58v164h-58a6 6 0 0 0 0 12h64a6 6 0 0 0 6-6V40a6 6 0 0 0-6-6"></path>
                            </g>
                          </svg>
                          模拟登录
                        </a-menu-item>
                        <a-menu-item key="resetPwd" @click="handleResetPwd(record as UserListDto)">
                          <KeyOutlined />
                          重置密码
                        </a-menu-item>
                        <a-menu-item key="edit" @click="handleEdit(record as UserListDto)">
                          <EditOutlined />
                          编辑
                        </a-menu-item>
                        <a-menu-item
                          v-if="record.username !== 'admin'"
                          key="delete"
                          danger
                          @click="handleDelete(record as UserListDto)"
                        >
                          <DeleteOutlined />
                          删除
                        </a-menu-item>
                      </a-menu>
                    </template>
                  </a-dropdown>
                </div>
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
              <a-input-password v-model:value="formState.password" placeholder="请输入密码">
                <template #addonAfter>
                  <a-tooltip title="生成随机密码">
                    <ThunderboltOutlined @click="handleGenerateInitPassword" style="cursor: pointer" />
                  </a-tooltip>
                </template>
              </a-input-password>
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="所属部门" name="deptId">
              <a-tree-select
                v-model:value="formState.deptId"
                :tree-data="(deptTreeOptions as TreeSelectProps['treeData'])"
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

        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="向谁汇报" name="superiorId">
              <UserSelector
                :value="formState.superiorId"
                :initial-display-data="superiorDisplayData"
                @change="handleSuperiorChange"
                placeholder="请选择向谁汇报"
              />
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
              :tree-data="(deptTreeData as TreeSelectProps['treeData'])"
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
import { ref, onMounted, computed, reactive, watch, h } from 'vue';
import { message, Modal } from 'ant-design-vue';
import type { Rule } from 'ant-design-vue/es/form';
import type { TreeSelectProps } from 'ant-design-vue/es/tree-select';
import { PlusOutlined, UserOutlined, ApartmentOutlined, MinusCircleOutlined, ThunderboltOutlined, ExclamationCircleOutlined, MoreOutlined, KeyOutlined, EditOutlined, DeleteOutlined } from '@ant-design/icons-vue';
import { getUserList, createUser, updateUser, deleteUser, resetUserPassword, type UserListDto } from '@/api/user';
import { impersonateLogin } from '@/api/auth';
import { getRoleList, type RoleDto } from '@/api/role';
import { getDeptTree, type Dept } from '@/api/dept';
import { getPostList, type Post } from '@/api/post';
import { generatePassword } from '@/utils/password';
import dayjs from 'dayjs';
import DeptTree from '@/components/DeptTree/index.vue';
import SplitLayout from '@/components/SplitLayout/index.vue';
import UserSelector from '@/components/UserSelector.vue';
import { useUserStore } from '@/stores/user';
import router from '@/router';

const loading = ref(false);
const users = ref<UserListDto[]>([]);
const searchText = ref('');
const roleOptions = ref<RoleDto[]>([]);
const postOptions = ref<Post[]>([]);
const deptTreeData = ref<Dept[]>([]);
const deptTreeOptions = computed(() => {
  if (userStore.isAdmin) {
    const globalNode: any = { id: GLOBAL_DEPT_ID, name: '全局用户', children: [] };
    return [globalNode, ...deptTreeData.value];
  }
  return deptTreeData.value;
});
const selectedDeptKeys = ref<number[]>([]);

const userStore = useUserStore();
const currentOrgId = computed(() => userStore.currentOrg?.id);

const GLOBAL_DEPT_ID = -1;

// 监听组织切换，清空选中部门
watch(currentOrgId, (newVal) => {
  console.log('SysUser: currentOrgId changed to', newVal);
  selectedDeptKeys.value = [];
});

const pagination = reactive({
  current: 1,
  pageSize: 10,
  showSizeChanger: true,
  showQuickJumper: true,
  showTotal: (total: number) => `共 ${total} 条`
});

const handleTableChange = (pag: any) => {
  pagination.current = pag.current;
  pagination.pageSize = pag.pageSize;
};

const columns: ColumnType[] = [
  { title: '序号', key: 'index', width: 60, align: 'center' as const, fixed: 'left' as const },
  { title: '头像', key: 'avatar', width: 60, align: 'center' as const },
  { title: '用户名', dataIndex: 'username', key: 'username' },
  { title: '昵称', dataIndex: 'nickname', key: 'nickname' },
  { title: '部门', key: 'dept' },
  { title: '角色', key: 'roles' },
  { title: '岗位', key: 'posts' },
  { title: '汇报', dataIndex: 'superiorName', key: 'superiorName' },
  { title: '状态', key: 'isActive', width: 80 },
  { title: '创建时间', key: 'createdAt', width: 160 },
  { title: '操作', key: 'action', width: 90, align: 'center' as const },
];

const filteredUsers = computed(() => {
  let result = users.value;
  
  // 1. Dept Filter
  if (selectedDeptKeys.value.length > 0) {
      const deptId = selectedDeptKeys.value[0];
      if (deptId === GLOBAL_DEPT_ID) {
          result = result.filter(u => !u.dept && (!u.posts || u.posts.length === 0));
      } else if (typeof deptId === 'number') {
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

const loadAllDepts = async () => {
  try {
    const res = await getDeptTree();
    deptTreeData.value = res || [];
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
  postRelations: [] as { deptId: number | undefined, postId: number | undefined }[],
  superiorId: undefined as number | undefined,
  superiorName: '' as string
});

const rules: Record<string, Rule[]> = {
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
  formState.superiorId = undefined;
  formState.superiorName = '';
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
  formState.superiorId = record.superiorId;
  formState.superiorName = record.superiorName || '';
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

const superiorDisplayData = computed(() => {
  if (formState.superiorId && formState.superiorName) {
    return [{
      id: formState.superiorId,
      username: '', 
      name: formState.superiorName,
      organization: '',
      deptId: undefined
    }];
  }
  return [];
});

const handleSuperiorChange = (user: any) => {
  if (user) {
    formState.superiorId = user.id;
    formState.superiorName = user.name || user.nickname || user.username;
  } else {
    formState.superiorId = undefined;
    formState.superiorName = '';
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
    
    const normalizedDeptId = formState.deptId === GLOBAL_DEPT_ID ? undefined : formState.deptId;

    if (currentId.value) {
      // Update
      const postRelations = formState.postRelations
        .filter(p => p.deptId && p.postId && p.deptId !== GLOBAL_DEPT_ID)
        .map(p => ({ deptId: p.deptId as number, postId: p.postId as number }));

      await updateUser(currentId.value, {
        nickname: formState.nickname,
        email: formState.email,
        phone: formState.phone,
        isActive: formState.isActive,
        roleIds: formState.roleIds,
        deptId: normalizedDeptId,
        postRelations: postRelations,
        superiorId: formState.superiorId
      });
      message.success('更新成功');
    } else {
      // Create
      const postRelations = formState.postRelations
        .filter(p => p.deptId && p.postId && p.deptId !== GLOBAL_DEPT_ID)
        .map(p => ({ deptId: p.deptId as number, postId: p.postId as number }));

      await createUser({
        username: formState.username,
        password: formState.password,
        nickname: formState.nickname,
        roleIds: formState.roleIds,
        deptId: normalizedDeptId,
        postRelations: postRelations,
        superiorId: formState.superiorId
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

const showImpersonateAction = (record: UserListDto) => {
  if (!userStore.isAdmin && !userStore.canImpersonate) {
    return false;
  }

  if (record.id === userStore.id) {
    return false;
  }

  if (record.username === 'admin') {
    return false;
  }

  return true;
};

const handleImpersonate = (record: UserListDto) => {
  Modal.confirm({
    title: '确认模拟登录',
    icon: h(ExclamationCircleOutlined),
    content: `确定要切换为用户“${record.nickname || record.username}”吗？系统将直接进入该用户当前会话。`,
    okText: '确认切换',
    cancelText: '取消',
    onOk: async () => {
      const res = await impersonateLogin(record.id) as any;
      if (!res?.token || !res?.user) {
        message.error('模拟登录失败，未获取到目标用户凭证');
        return;
      }

      // 调试信息：被模拟用户的 id + 他的当前默认组织 id，
      // 与 TabsView.restoreTabsConfig 打印的 {userId, orgId} 对比，
      // 能直接看出「模拟登录后恢复的 user+org 维度是不是就是这个用户」
      console.debug('[SysUser.handleImpersonate] 即将发起模拟登录', {
        targetUserId: res.user.id,
        targetUsername: res.user.username,
        targetRoleCodes: res.user.roleCodes,
        // 模拟登录后后端会把目标用户的默认组织写回 JWT，这里先留日志便于比对恢复时的 orgId
        note: '刷新后 TabsView 会按 userStore.id + userStore.currentOrg.id 维度读取 tab 会话',
      });

      await userStore.beginImpersonation({
        token: res.token,
        user: {
          id: res.user.id,
          username: res.user.username,
          nickname: res.user.nickname || '',
          avatar: res.user.avatar || '',
          status: res.user.status || 'online',
          roles: res.user.roles || [],
          roleCodes: res.user.roleCodes || [],
          deptId: typeof res.user.deptId === 'number' ? res.user.deptId : null,
          isAdmin: !!res.user.isAdmin
        },
        currentOrg: null,
        currentRoutePath: '/'
      });
      message.success(`已切换为用户：${record.nickname || record.username}`);
    }
  });
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

const resetPwdRules: Record<string, Rule[]> = {
  newPassword: [{ required: true, message: '请输入新密码', trigger: 'blur' }, { min: 6, message: '密码至少6位', trigger: 'blur' }],
  confirmPassword: [{ required: true, validator: validateConfirmPassword, trigger: 'blur' }]
};

const handleGenerateInitPassword = () => {
  const pwd = generatePassword(8);
  formState.password = pwd;
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

const onDeptLoaded = (data: Dept[]) => {
  // Check if current selection is valid in the new tree
  let isValidSelection = false;
  if (selectedDeptKeys.value.length > 0) {
     const id = selectedDeptKeys.value[0];
     if (id !== undefined) {
        if (id === GLOBAL_DEPT_ID) {
            isValidSelection = true;
        } else {
            isValidSelection = !!findNodeById(data, id);
        }
     }
  }

  // Auto-select root node if nothing is selected or current selection is invalid
  if ((!isValidSelection || selectedDeptKeys.value.length === 0) && data.length > 0) {
    const root = data[0];
    if (root) {
      selectedDeptKeys.value = [root.id];
    }
  }
};

const findNodeById = (nodes: Dept[], id: number): Dept | null => {
  for (const node of nodes) {
    if (node.id === id) return node;
    if (node.children) {
      const found = findNodeById(node.children, id);
      if (found) return found;
    }
  }
  return null;
};

const handleSelect = (keys: number[], _e: any) => {
  // Prevent deselection: if keys is empty but we have a currently selected node, restore it
  if (keys.length === 0 && selectedDeptKeys.value.length > 0) {
     // Force update trigger if needed, though v-model should handle it,
     // but sometimes direct mutation is safer for "prevent" logic
     const current = selectedDeptKeys.value[0];
     if (current !== undefined) {
         // Use setTimeout to ensure the update happens after the current event loop
         setTimeout(() => {
             selectedDeptKeys.value = [current];
         }, 0);
     }
  }
};

watch(selectedDeptKeys, (val) => {
  if (val.length > 0) {
    loadData();
  }
});

onMounted(() => {
  // loadData(); // Deferred to watch(selectedDeptKeys)
  loadRoles();
  loadPosts();
  loadAllDepts();
});
</script>

<style scoped lang="scss">
.sys-user-container {
  flex: 1;
  padding: 10px;
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
  :deep(.ant-card-body) {
    padding: 0;
    flex: 1;
    display: flex;
    flex-direction: column;
    overflow: hidden;
    
    .ant-table-wrapper {
      height: 100%;
      .ant-spin-nested-loading {
        height: 100%;
        .ant-spin-container {
          height: 100%;
          display: flex;
          flex-direction: column;
          .ant-table {
            flex: 1;
            overflow: auto;
          }
          .ant-table-pagination {
            padding: 0 16px 16px 16px;
            margin: 0 !important;
          }
        }
      }
    }
  }
}

.text-danger {
  color: #ff4d4f;
}
</style>
