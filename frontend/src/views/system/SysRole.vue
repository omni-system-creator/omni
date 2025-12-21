<template>
  <div class="sys-role-container">
    <a-card :bordered="false">
      <template #title>
        角色列表
      </template>
      <template #extra>
        <a-button type="primary" @click="handleAdd">
          <template #icon><PlusOutlined /></template>
          新增角色
        </a-button>
      </template>

      <a-table
        :columns="columns"
        :data-source="roles"
        :loading="loading"
        row-key="id"
        :pagination="{ pageSize: 10 }"
      >
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'isSystem'">
            <a-tag :color="record.isSystem ? 'orange' : 'green'">
              {{ record.isSystem ? '系统内置' : '自定义' }}
            </a-tag>
          </template>

          <template v-else-if="column.key === 'createdAt'">
            {{ formatDate(record.createdAt) }}
          </template>

          <template v-else-if="column.key === 'action'">
            <a-space divider type="vertical">
              <a @click="handleEdit(record)">编辑</a>
              <a @click="handlePermission(record)">分配权限</a>
              <a-popconfirm
                title="确定要删除该角色吗？此操作不可恢复"
                ok-text="删除"
                cancel-text="取消"
                ok-type="danger"
                @confirm="handleDelete(record)"
                v-if="!record.isSystem"
              >
                <a class="text-danger">删除</a>
              </a-popconfirm>
            </a-space>
          </template>
        </template>
      </a-table>
    </a-card>

    <!-- 角色表单弹窗 -->
    <a-modal
      v-model:open="modalVisible"
      :title="modalTitle"
      @ok="handleModalOk"
      :confirmLoading="confirmLoading"
    >
      <a-form
        ref="formRef"
        :model="formState"
        :rules="rules"
        layout="vertical"
      >
        <a-form-item label="角色名称" name="name">
          <a-input v-model:value="formState.name" placeholder="请输入角色名称" />
        </a-form-item>
        <a-form-item label="角色编码" name="code">
          <a-input v-model:value="formState.code" :disabled="!!currentId" placeholder="请输入角色编码 (如: ADMIN)" />
        </a-form-item>
        <a-form-item label="描述" name="description">
          <a-textarea v-model:value="formState.description" placeholder="请输入描述" :rows="3" />
        </a-form-item>
      </a-form>
    </a-modal>

    <!-- 权限分配弹窗 -->
    <a-modal
      v-model:open="permModalVisible"
      title="分配权限"
      @ok="handlePermOk"
      :confirmLoading="permSaving"
      width="600px"
    >
      <a-spin :spinning="permLoading">
        <div style="max-height: 500px; overflow-y: auto;">
          <a-tree
            v-if="permissionTree.length > 0"
            v-model:checkedKeys="checkedKeys"
            checkable
            :tree-data="permissionTree"
            :field-names="{ children: 'children', title: 'name', key: 'id' }"
            defaultExpandAll
          />
        </div>
      </a-spin>
    </a-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted, reactive } from 'vue';
import { message } from 'ant-design-vue';
import { PlusOutlined } from '@ant-design/icons-vue';
import { 
  getRoleList, createRole, updateRole, deleteRole, 
  getAllPermissions, getRolePermissionIds, assignRolePermissions,
  type RoleDto, type PermissionTreeDto 
} from '@/api/role';
import dayjs from 'dayjs';

const loading = ref(false);
const roles = ref<RoleDto[]>([]);

const columns = [
  { title: '角色名称', dataIndex: 'name', key: 'name' },
  { title: '角色编码', dataIndex: 'code', key: 'code' },
  { title: '类型', key: 'isSystem', width: 100 },
  { title: '描述', dataIndex: 'description', key: 'description' },
  { title: '创建时间', key: 'createdAt', width: 180 },
  { title: '操作', key: 'action', width: 250, align: 'center' },
];

const formatDate = (date: string) => {
  return dayjs(date).format('YYYY-MM-DD HH:mm:ss');
};

const loadData = async () => {
  loading.value = true;
  try {
    const res = await getRoleList();
    roles.value = res;
  } catch (error) {
    console.error(error);
  } finally {
    loading.value = false;
  }
};

// --- Modal Logic ---
const modalVisible = ref(false);
const confirmLoading = ref(false);
const modalTitle = ref('新增角色');
const currentId = ref<number | null>(null);
const formRef = ref();

const formState = reactive({
  name: '',
  code: '',
  description: ''
});

const rules = {
  name: [{ required: true, message: '请输入角色名称', trigger: 'blur' }],
  code: [{ required: true, message: '请输入角色编码', trigger: 'blur' }],
};

const handleAdd = () => {
  currentId.value = null;
  modalTitle.value = '新增角色';
  formState.name = '';
  formState.code = '';
  formState.description = '';
  modalVisible.value = true;
};

const handleEdit = (record: RoleDto) => {
  currentId.value = record.id;
  modalTitle.value = '编辑角色';
  formState.name = record.name;
  formState.code = record.code;
  formState.description = record.description || '';
  modalVisible.value = true;
};

const handleModalOk = async () => {
  try {
    await formRef.value.validate();
    confirmLoading.value = true;
    
    if (currentId.value) {
      await updateRole(currentId.value, {
        name: formState.name,
        description: formState.description
      });
      message.success('更新成功');
    } else {
      await createRole({
        name: formState.name,
        code: formState.code,
        description: formState.description
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

const handleDelete = async (record: RoleDto) => {
  try {
    await deleteRole(record.id);
    message.success('删除成功');
    loadData();
  } catch (error) {
    console.error(error);
  }
};

// --- Permission Logic ---
const permModalVisible = ref(false);
const permLoading = ref(false);
const permSaving = ref(false);
const permissionTree = ref<PermissionTreeDto[]>([]);
const checkedKeys = ref<number[]>([]);
const currentRoleId = ref<number | null>(null);

const loadPermissionTree = async () => {
  if (permissionTree.value.length > 0) return;
  try {
    const res = await getAllPermissions();
    permissionTree.value = res;
  } catch (error) {
    console.error(error);
  }
};

const handlePermission = async (record: RoleDto) => {
  currentRoleId.value = record.id;
  permModalVisible.value = true;
  permLoading.value = true;
  
  try {
    await loadPermissionTree();
    const ids = await getRolePermissionIds(record.id);
    checkedKeys.value = ids;
  } catch (error) {
    console.error(error);
  } finally {
    permLoading.value = false;
  }
};

const handlePermOk = async () => {
  if (!currentRoleId.value) return;
  
  permSaving.value = true;
  try {
    // antd tree checkedKeys might include half-checked keys if configured, 
    // but here we just need the fully checked ones usually, or handled by backend logic
    // simple array of numbers
    await assignRolePermissions(currentRoleId.value, checkedKeys.value as number[]);
    message.success('权限分配成功');
    permModalVisible.value = false;
  } catch (error) {
    console.error(error);
  } finally {
    permSaving.value = false;
  }
};

onMounted(() => {
  loadData();
});
</script>

<style scoped>
.sys-role-container {
  padding: 24px;
}
.text-danger {
  color: #ff4d4f;
}
</style>
