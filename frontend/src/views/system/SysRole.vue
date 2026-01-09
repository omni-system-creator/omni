<template>
  <div class="sys-role-container">
    <SplitLayout>
      <template #left>
        <a-card :bordered="false" class="dept-card"
          :body-style="{ padding: '10px', height: 'calc(100% - 40px)', overflow: 'hidden' }">
          <template #title>
            <span>
              <ApartmentOutlined /> 组织结构
            </span>
          </template>
          <DeptTree v-model:selectedKeys="selectedDeptKeys" :root-id="currentOrgId" @loaded="onDeptLoaded" @select="onSelectDept" />
        </a-card>
      </template>

      <template #right>
        <a-card :bordered="false" class="content-card">
          <template #title>
            角色列表
          </template>
          <template #extra>
            <a-button type="primary" @click="handleAdd">
              <template #icon>
                <PlusOutlined />
              </template>
              新增角色
            </a-button>
          </template>

          <a-table :columns="columns" :data-source="roles" :loading="loading" row-key="id"
            :pagination="{ pageSize: 10 }">
            <template #bodyCell="{ column, record }">
              <template v-if="column.key === 'isSystem'">
                <a-tag :color="record.isSystem ? 'orange' : 'green'">
                  {{ record.isSystem ? '系统内置' : '自定义' }}
                </a-tag>
              </template>

              <template v-else-if="column.key === 'rootDept'">
                <a-tag color="cyan">{{ getRootDeptName(record.deptId) }}</a-tag>
              </template>

              <template v-else-if="column.key === 'createdAt'">
                {{ formatDate(record.createdAt) }}
              </template>

              <template v-else-if="column.key === 'action'">
                <a-space divider type="vertical">
                  <a @click="handleEdit(record as RoleDto)">编辑</a>
                  <a @click="handlePermission(record as RoleDto)">分配权限</a>
                  <a-popconfirm title="确定要删除该角色吗？此操作不可恢复" ok-text="删除" cancel-text="取消" ok-type="danger"
                    @confirm="handleDelete(record as RoleDto)" v-if="!record.isSystem">
                    <a class="text-danger">删除</a>
                  </a-popconfirm>
                </a-space>
              </template>
            </template>
          </a-table>
        </a-card>
      </template>
    </SplitLayout>

    <!-- 角色表单弹窗 -->
    <a-modal v-model:open="modalVisible" :title="modalTitle" @ok="handleModalOk" :confirmLoading="confirmLoading">
      <a-form ref="formRef" :model="formState" :rules="rules" layout="vertical">
        <a-form-item label="角色名称" name="name">
          <a-input v-model:value="formState.name" placeholder="请输入角色名称" />
        </a-form-item>
        <a-form-item label="角色编码" name="code">
          <a-input v-model:value="formState.code" :disabled="!!currentId" placeholder="请输入角色编码" />
        </a-form-item>
        <a-form-item label="描述" name="description">
          <a-textarea v-model:value="formState.description" placeholder="请输入描述" :rows="3" />
        </a-form-item>
        <a-form-item label="所属部门" name="deptId" help="如果不选择，则为全局角色">
          <a-tree-select v-model:value="formState.deptId" show-search style="width: 100%"
            :dropdown-style="{ maxHeight: '400px', overflow: 'auto' }" placeholder="请选择部门" allow-clear
            tree-default-expand-all :tree-data="depts"
            :field-names="{ children: 'children', label: 'name', value: 'id' }" />
        </a-form-item>
        <a-form-item label="包含角色" name="childRoleIds" help="选择此角色继承的其他角色权限">
          <a-select v-model:value="formState.childRoleIds" mode="multiple" style="width: 100%" placeholder="请选择要继承的角色"
            :options="roleOptions" />
        </a-form-item>
      </a-form>
    </a-modal>

    <!-- 权限分配弹窗 -->
    <a-modal v-model:open="permModalVisible" title="分配权限" @ok="handlePermOk" :confirmLoading="permSaving" width="600px">
      <a-spin :spinning="permLoading">
        <div style="max-height: 500px; overflow-y: auto;">
          <a-tree v-if="permissionTree.length > 0" v-model:checkedKeys="checkedKeys" checkable :check-strictly="true"
            :tree-data="(permissionTree as unknown as TreeProps['treeData'])" :field-names="{ children: 'children', title: 'name', key: 'id' }"
            defaultExpandAll />
        </div>
      </a-spin>
    </a-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted, reactive, computed } from 'vue';
import { message } from 'ant-design-vue';
import type { Rule } from 'ant-design-vue/es/form';
import type { TreeProps } from 'ant-design-vue/es/tree';
import { PlusOutlined, ApartmentOutlined } from '@ant-design/icons-vue';
import {
  getRoleList, createRole, updateRole, deleteRole,
  getAllPermissions, getRolePermissionIds, assignRolePermissions,
  type RoleDto, type PermissionTreeDto
} from '@/api/role';
import { type Dept } from '@/api/dept';
import DeptTree from '@/components/DeptTree/index.vue';
import SplitLayout from '@/components/SplitLayout/index.vue';
import dayjs from 'dayjs';
import { useUserStore } from '@/stores/user';

const loading = ref(false);
const roles = ref<RoleDto[]>([]);
const depts = ref<Dept[]>([]);
const selectedDeptKeys = ref<number[]>([]);

const userStore = useUserStore();
const isAdmin = computed(() => userStore.isAdmin);
const currentOrgId = computed(() => userStore.currentOrg?.id);

const columns = computed(() => {
  const base: ColumnType[] = [
    { title: '角色名称', dataIndex: 'name', key: 'name' },
    { title: '角色编码', dataIndex: 'code', key: 'code' },
    { title: '类型', key: 'isSystem', width: 100 },
    { title: '描述', dataIndex: 'description', key: 'description' },
    { title: '创建时间', key: 'createdAt', width: 180 },
    { title: '操作', key: 'action', width: 250, align: 'center' },
  ];
  if (isAdmin.value) {
    base.splice(2, 0, { title: '根组织', key: 'rootDept', width: 160 });
  }
  return base;
});

const formatDate = (date: string) => {
  return dayjs(date).format('YYYY-MM-DD HH:mm:ss');
};

const findPathToId = (nodes: Dept[], targetId: number, path: Dept[] = []): Dept[] | null => {
  for (const node of nodes) {
    const currentPath = [...path, node];
    if (node.id === targetId) {
      return currentPath;
    }
    if (node.children && node.children.length > 0) {
      const result = findPathToId(node.children, targetId, currentPath);
      if (result) return result;
    }
  }
  return null;
};

const getRootDeptName = (deptId?: number) => {
  if (!deptId) return '全局';
  const path = findPathToId(depts.value || [], deptId);
  const root = path?.[0];
  return root ? root.name : '-';
};

const loadData = async (deptIdParam?: number) => {
  loading.value = true;
  try {
    const deptId = deptIdParam !== undefined ? deptIdParam : (selectedDeptKeys.value.length > 0 ? selectedDeptKeys.value[0] : undefined);
    const rolesRes = await getRoleList(deptId);
    roles.value = rolesRes;
  } catch (error) {
    console.error(error);
  } finally {
    loading.value = false;
  }
};

const onDeptLoaded = (data: Dept[]) => {
  depts.value = data;
  
  // Check if current selection is valid in the new tree
  let isValidSelection = false;
  if (selectedDeptKeys.value.length > 0) {
     const id = selectedDeptKeys.value[0];
     if (id !== undefined) {
        isValidSelection = !!findNodeById(data, id);
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

const onSelectDept = (keys: number[]) => {
  // Prevent deselection
  if (keys.length === 0 && selectedDeptKeys.value.length > 0) {
      const current = selectedDeptKeys.value[0];
      if (current !== undefined) {
         setTimeout(() => {
             selectedDeptKeys.value = [current];
         }, 0);
      }
  }
};

watch(selectedDeptKeys, (val) => {
    if (val && val.length > 0) {
        loadData(val[0]);
    }
});

const initData = async () => {
  try {
    // DeptTree loads depts automatically
    await loadData();
  } catch (error) {
    console.error(error);
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
  description: '',
  deptId: undefined as number | undefined,
  childRoleIds: [] as number[]
});

const roleOptions = computed(() => {
  return roles.value
    .filter(r => r.id !== currentId.value)
    .map(r => ({ label: r.name, value: r.id }));
});

const rules: Record<string, Rule[]> = {
  name: [{ required: true, message: '请输入角色名称', trigger: 'blur' }],
  code: [{ required: true, message: '请输入角色编码', trigger: 'blur' }, { validator: (_r: any, v: string) => v && v.indexOf('-') === -1 ? Promise.resolve() : Promise.reject('角色编码不能包含连字符(-)'), trigger: 'blur' }],
};

const handleAdd = () => {
  currentId.value = null;
  modalTitle.value = '新增角色';
  formState.name = '';
  formState.code = '';
  formState.description = '';
  // 如果左侧选中了部门，则自动填充
  if (selectedDeptKeys.value.length > 0) {
    formState.deptId = selectedDeptKeys.value[0];
  } else {
    formState.deptId = undefined;
  }
  formState.childRoleIds = [];
  modalVisible.value = true;
};

const handleEdit = (record: RoleDto) => {
  currentId.value = record.id;
  modalTitle.value = '编辑角色';
  formState.name = record.name;
  formState.code = record.code;
  formState.description = record.description || '';
  formState.deptId = record.deptId;
  formState.childRoleIds = record.childRoleIds || [];
  modalVisible.value = true;
};

const handleModalOk = async () => {
  try {
    await formRef.value.validate();
    confirmLoading.value = true;

    if (currentId.value) {
      await updateRole(currentId.value, {
        name: formState.name,
        description: formState.description,
        deptId: formState.deptId,
        childRoleIds: formState.childRoleIds
      });
      message.success('更新成功');
    } else {
      await createRole({
        name: formState.name,
        code: formState.code,
        description: formState.description,
        deptId: formState.deptId,
        childRoleIds: formState.childRoleIds
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
const checkedKeys = ref<{ checked: number[], halfChecked: number[] } | number[]>([]);
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
    // checkStrictly 模式下，需要根据 ID 列表来设置 checkedKeys
    // 注意：如果后端返回了所有选中的 ID（包括父节点），我们可以直接设置
    // 如果是 checkStrictly，checkedKeys 应该是一个包含 checked 数组的对象
    checkedKeys.value = { checked: ids, halfChecked: [] };
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
    // checkStrictly 为 true 时，checkedKeys 是 { checked: [], halfChecked: [] }
    let ids: number[] = [];
    if (Array.isArray(checkedKeys.value)) {
      ids = checkedKeys.value;
    } else {
      ids = checkedKeys.value.checked;
      // 如果需要把半选状态的父节点也传给后端（通常建议这样做，以便后端能构建完整树），可以合并
      // ids = [...checkedKeys.value.checked, ...checkedKeys.value.halfChecked];
      // 但用户明确要求"父子勾选不要关联各自独立勾选"，这意味着用户可能只想给子节点权限而不给父节点？
      // 不过在菜单系统中，如果父节点没权限，子节点通常也不可见。
      // 但既然用户要求“独立”，我们就只传用户明确勾选的（checked）。
      // 如果用户需要父节点，他们应该手动勾选父节点。
    }

    await assignRolePermissions(currentRoleId.value, ids);
    message.success('权限分配成功');
    permModalVisible.value = false;
  } catch (error) {
    console.error(error);
  } finally {
    permSaving.value = false;
  }
};

onMounted(() => {
  initData();
});
</script>

<style scoped>
.sys-role-container {
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
}

.text-danger {
  color: #ff4d4f;
}
</style>
