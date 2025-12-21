<template>
  <div class="sys-org-container">
    <a-card :bordered="false">
      <template #title>
        <a-space>
          <a-button type="primary" @click="handleAdd()">
            <template #icon><PlusOutlined /></template>
            新增
          </a-button>
          <a-button @click="expandAll">展开/折叠</a-button>
        </a-space>
      </template>

      <a-table
        :columns="columns"
        :data-source="deptList"
        :loading="loading"
        row-key="id"
        :pagination="false"
        v-if="deptList.length > 0"
        :expandedRowKeys="expandedRowKeys"
        @expand="onExpand"
      >
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'name'">
            <span v-if="record.type === DeptType.Group" style="margin-right: 8px">
              <BankOutlined style="color: #faad14" />
            </span>
            <span v-else-if="record.type === DeptType.Company" style="margin-right: 8px">
              <ApartmentOutlined style="color: #1890ff" />
            </span>
            <span v-else style="margin-right: 8px">
              <ClusterOutlined style="color: #8c8c8c" />
            </span>
            <span>{{ record.name }}</span>
          </template>
          <template v-if="column.key === 'type'">
            <a-tag color="blue" v-if="record.type === DeptType.Group">集团</a-tag>
            <a-tag color="cyan" v-else-if="record.type === DeptType.Company">公司</a-tag>
            <a-tag color="default" v-else>部门</a-tag>
          </template>
          <template v-else-if="column.key === 'isActive'">
            <a-tag :color="record.isActive ? 'success' : 'error'">
              {{ record.isActive ? '启用' : '禁用' }}
            </a-tag>
          </template>
          <template v-else-if="column.key === 'action'">
             <a-tooltip title="新增子部门">
              <a-button type="link" size="small" @click="handleAdd(record)">
                <template #icon><PlusOutlined /></template>
              </a-button>
            </a-tooltip>
            <a-tooltip title="编辑">
              <a-button type="link" size="small" @click="handleEdit(record)">
                <template #icon><EditOutlined /></template>
              </a-button>
            </a-tooltip>
            <a-tooltip title="删除">
              <a-popconfirm
                title="确定删除吗？"
                @confirm="handleDelete(record)"
                ok-text="是"
                cancel-text="否"
              >
                <a-button type="link" size="small" danger>
                  <template #icon><DeleteOutlined /></template>
                </a-button>
              </a-popconfirm>
            </a-tooltip>
          </template>
        </template>
      </a-table>
      <a-empty v-else />
    </a-card>

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
        <a-form-item label="上级" name="parentId">
          <a-tree-select
            v-model:value="formState.parentId"
            :tree-data="deptTreeSelectData"
            placeholder="请选择上级"
            allow-clear
            tree-default-expand-all
          >
            <template #title="{ label, type }">
               <span v-if="type === DeptType.Group">
                  <BankOutlined style="color: #faad14; margin-right: 4px" />
               </span>
               <span v-else-if="type === DeptType.Company">
                  <ApartmentOutlined style="color: #1890ff; margin-right: 4px" />
               </span>
               <span v-else-if="type === DeptType.Department">
                  <ClusterOutlined style="color: #8c8c8c; margin-right: 4px" />
               </span>
               {{ label }}
            </template>
          </a-tree-select>
        </a-form-item>
        <a-form-item label="名称" name="name">
          <a-input v-model:value="formState.name" placeholder="请输入名称" />
        </a-form-item>
        <a-form-item label="类型" name="type">
          <a-select v-model:value="formState.type">
            <a-select-option :value="DeptType.Group">集团</a-select-option>
            <a-select-option :value="DeptType.Company">公司</a-select-option>
            <a-select-option :value="DeptType.Department">部门</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="编码" name="code">
          <a-input v-model:value="formState.code" placeholder="请输入编码" />
        </a-form-item>
        <a-form-item label="负责人" name="leader">
          <a-input v-model:value="formState.leader" placeholder="请输入负责人姓名" />
        </a-form-item>
        <a-form-item label="联系电话" name="phone">
          <a-input v-model:value="formState.phone" placeholder="请输入联系电话" />
        </a-form-item>
        <a-form-item label="邮箱" name="email">
          <a-input v-model:value="formState.email" placeholder="请输入邮箱" />
        </a-form-item>
        <a-form-item label="排序" name="sortOrder">
          <a-input-number v-model:value="formState.sortOrder" :min="0" style="width: 100%" />
        </a-form-item>
        <a-form-item label="状态" name="isActive">
          <a-switch v-model:checked="formState.isActive" />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed, reactive } from 'vue';
import { message } from 'ant-design-vue';
import { 
  PlusOutlined, EditOutlined, DeleteOutlined,
  BankOutlined, ApartmentOutlined, ClusterOutlined
} from '@ant-design/icons-vue';
import { 
  getDeptTree, createDept, updateDept, deleteDept, 
  type Dept, DeptType
} from '@/api/dept';

const loading = ref(false);
const deptList = ref<Dept[]>([]);
const expandedRowKeys = ref<number[]>([]);

const columns = [
  { title: '名称', dataIndex: 'name', key: 'name', width: '250px' },
  { title: '类型', dataIndex: 'type', key: 'type', width: '100px', align: 'center' },
  { title: '排序', dataIndex: 'sortOrder', key: 'sortOrder', width: '80px', align: 'center' },
  { title: '编码', dataIndex: 'code', key: 'code', width: '120px' },
  { title: '负责人', dataIndex: 'leader', key: 'leader', width: '100px' },
  { title: '电话', dataIndex: 'phone', key: 'phone', width: '120px' },
  { title: '状态', key: 'isActive', width: '80px', align: 'center' },
  { title: '创建时间', dataIndex: 'createdAt', key: 'createdAt', width: '160px' },
  { title: '操作', key: 'action', width: '150px', fixed: 'right' }
];

const fetchDeptTree = async () => {
  loading.value = true;
  try {
    const res = await getDeptTree();
    deptList.value = res || [];
    // Default expand all
    if (expandedRowKeys.value.length === 0) {
        expandAllKeys(deptList.value);
    }
  } catch (error) {
    console.error(error);
  } finally {
    loading.value = false;
  }
};

const expandAllKeys = (list: Dept[]) => {
    list.forEach(item => {
        expandedRowKeys.value.push(item.id);
        if (item.children) {
            expandAllKeys(item.children);
        }
    });
};

const onExpand = (expanded: boolean, record: Dept) => {
  if (expanded) {
    expandedRowKeys.value.push(record.id);
  } else {
    expandedRowKeys.value = expandedRowKeys.value.filter(k => k !== record.id);
  }
};

const expandAll = () => {
  if (expandedRowKeys.value.length > 0) {
    expandedRowKeys.value = [];
  } else {
    expandAllKeys(deptList.value);
  }
};

// Modal Logic
const modalVisible = ref(false);
const modalTitle = ref('');
const confirmLoading = ref(false);
const formRef = ref();
const currentId = ref<number | null>(null);

const formState = reactive<any>({
  parentId: undefined,
  name: '',
  code: '',
  type: DeptType.Department,
  leader: '',
  phone: '',
  email: '',
  sortOrder: 0,
  isActive: true
});

const rules = {
  name: [{ required: true, message: '请输入部门名称', trigger: 'blur' }]
};

// Tree Select Data
const deptTreeSelectData = computed(() => {
  const mapData = (list: Dept[]): any[] => {
    return list.map(item => ({
      label: item.name,
      value: item.id,
      type: item.type,
      children: item.children ? mapData(item.children) : undefined,
      disabled: item.id === currentId.value // Prevent selecting self as parent
    }));
  };
  return [
    { label: '顶级部门', value: 0, children: null }, // 0 or null for root
    ...mapData(deptList.value)
  ];
});

const handleAdd = (record?: Dept) => {
  modalTitle.value = '新增部门';
  currentId.value = null;
  formState.parentId = record ? record.id : undefined;
  formState.name = '';
  formState.code = '';
  formState.leader = '';
  formState.phone = '';
  formState.email = '';
  formState.sortOrder = 0;
  formState.isActive = true;
  modalVisible.value = true;
};

const handleEdit = (record: Dept) => {
  modalTitle.value = '编辑部门';
  currentId.value = record.id;
  formState.parentId = record.parentId;
  formState.name = record.name;
  formState.code = record.code;
  formState.type = record.type;
  formState.leader = record.leader;
  formState.phone = record.phone;
  formState.email = record.email;
  formState.sortOrder = record.sortOrder;
  formState.isActive = record.isActive;
  modalVisible.value = true;
};

const handleDelete = async (record: Dept) => {
  try {
    await deleteDept(record.id);
    message.success('删除成功');
    fetchDeptTree();
  } catch (error) {
    // Error handled by interceptor
  }
};

const handleModalOk = async () => {
  try {
    await formRef.value.validate();
    confirmLoading.value = true;
    
    // ParentId 0 -> null
    const payload = { ...formState };
    if (payload.parentId === 0) payload.parentId = null;

    if (currentId.value) {
      await updateDept(currentId.value, payload);
      message.success('更新成功');
    } else {
      await createDept(payload);
      message.success('创建成功');
    }
    modalVisible.value = false;
    fetchDeptTree();
  } catch (error) {
    console.error(error);
  } finally {
    confirmLoading.value = false;
  }
};

onMounted(() => {
  fetchDeptTree();
});
</script>
<style scoped>
.sys-org-container {
  padding: 16px;
}
</style>
