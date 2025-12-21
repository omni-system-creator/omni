<template>
  <div class="sys-post-container">
    <a-row :gutter="16">
      <a-col :span="6">
        <a-card :bordered="false" title="组织机构" :body-style="{ padding: '10px' }">
          <a-tree
            v-if="deptTree.length > 0"
            :tree-data="deptTree"
            :field-names="{ children: 'children', title: 'name', key: 'id' }"
            defaultExpandAll
            @select="onSelectDept"
          >
            <template #title="{ name, type }">
              <span v-if="type === DeptType.Group">
                 <BankOutlined style="color: #faad14; margin-right: 4px" />
              </span>
              <span v-else-if="type === DeptType.Company">
                 <ApartmentOutlined style="color: #1890ff; margin-right: 4px" />
              </span>
              <span v-else>
                 <ClusterOutlined style="color: #8c8c8c; margin-right: 4px" />
              </span>
              <span>{{ name }}</span>
            </template>
          </a-tree>
          <div v-else style="text-align: center; margin-top: 20px; color: #999;">
            暂无数据
          </div>
        </a-card>
      </a-col>
      <a-col :span="18">
        <a-card :bordered="false">
          <template #title>
            <a-space>
              <a-button type="primary" @click="handleAdd()">
                <template #icon><PlusOutlined /></template>
                新增岗位
              </a-button>
            </a-space>
          </template>
    
          <a-table
            :columns="columns"
            :data-source="postList"
            :loading="loading"
            row-key="id"
            :pagination="{ pageSize: 10 }"
          >
            <template #bodyCell="{ column, record }">
              <template v-if="column.key === 'isActive'">
                <a-tag :color="record.isActive ? 'success' : 'error'">
                  {{ record.isActive ? '启用' : '禁用' }}
                </a-tag>
              </template>
              <template v-else-if="column.key === 'action'">
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
        </a-card>
      </a-col>
    </a-row>

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
        <a-form-item label="所属部门" name="deptId">
           <a-tree-select
              v-model:value="formState.deptId"
              style="width: 100%"
              :dropdown-style="{ maxHeight: '400px', overflow: 'auto' }"
              :tree-data="deptTree"
              placeholder="请选择所属部门"
              :field-names="{ children: 'children', label: 'name', value: 'id' }"
              tree-default-expand-all
              allow-clear
            />
        </a-form-item>
        <a-form-item label="岗位名称" name="name">
          <a-input v-model:value="formState.name" placeholder="请输入岗位名称" />
        </a-form-item>
        <a-form-item label="岗位编码" name="code">
          <a-input v-model:value="formState.code" placeholder="请输入岗位编码" />
        </a-form-item>
        <a-form-item label="描述" name="description">
          <a-textarea v-model:value="formState.description" placeholder="请输入描述" :rows="3" />
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
import { ref, onMounted, reactive } from 'vue';
import { message } from 'ant-design-vue';
import { 
  PlusOutlined, EditOutlined, DeleteOutlined,
  BankOutlined,
  ApartmentOutlined,
  ClusterOutlined
} from '@ant-design/icons-vue';
import { 
  getPostList, createPost, updatePost, deletePost, 
  type Post
} from '@/api/post';
import { getDeptList, type DeptDto, DeptType } from '@/api/dept';

const loading = ref(false);
const postList = ref<Post[]>([]);
const deptTree = ref<DeptDto[]>([]);
const selectedDeptId = ref<number | undefined>(undefined);

const columns = [
  { title: '岗位名称', dataIndex: 'name', key: 'name' },
  { title: '岗位编码', dataIndex: 'code', key: 'code' },
  { title: '所属部门', dataIndex: 'deptName', key: 'deptName' },
  { title: '排序', dataIndex: 'sortOrder', key: 'sortOrder', align: 'center' },
  { title: '描述', dataIndex: 'description', key: 'description' },
  { title: '状态', key: 'isActive', align: 'center' },
  { title: '创建时间', dataIndex: 'createdAt', key: 'createdAt' },
  { title: '操作', key: 'action', width: '150px', fixed: 'right' }
];

const fetchDeptTree = async () => {
  try {
    const res = await getDeptList();
    deptTree.value = res || [];
  } catch (error) {
    console.error(error);
  }
};

const fetchPosts = async () => {
  loading.value = true;
  try {
    const res = await getPostList(selectedDeptId.value);
    postList.value = res || [];
  } catch (error) {
    console.error(error);
  } finally {
    loading.value = false;
  }
};

const onSelectDept = (selectedKeys: number[]) => {
  if (selectedKeys && selectedKeys.length > 0) {
    selectedDeptId.value = selectedKeys[0];
  } else {
    selectedDeptId.value = undefined;
  }
  fetchPosts();
};

// Modal Logic
const modalVisible = ref(false);
const modalTitle = ref('');
const confirmLoading = ref(false);
const formRef = ref();
const currentId = ref<number | null>(null);

const formState = reactive<any>({
  name: '',
  code: '',
  description: '',
  sortOrder: 0,
  isActive: true,
  deptId: undefined
});

const rules = {
  deptId: [{ required: true, message: '请选择所属部门', trigger: 'change' }],
  name: [{ required: true, message: '请输入岗位名称', trigger: 'blur' }],
  code: [{ required: true, message: '请输入岗位编码', trigger: 'blur' }]
};

const handleAdd = () => {
  modalTitle.value = '新增岗位';
  currentId.value = null;
  formState.name = '';
  formState.code = '';
  formState.description = '';
  formState.sortOrder = 0;
  formState.isActive = true;
  // Default to selected department if available
  formState.deptId = selectedDeptId.value;
  modalVisible.value = true;
};

const handleEdit = (record: Post) => {
  modalTitle.value = '编辑岗位';
  currentId.value = record.id;
  formState.name = record.name;
  formState.code = record.code;
  formState.description = record.description;
  formState.sortOrder = record.sortOrder;
  formState.isActive = record.isActive;
  formState.deptId = record.deptId;
  modalVisible.value = true;
};

const handleDelete = async (record: Post) => {
  try {
    await deletePost(record.id);
    message.success('删除成功');
    fetchPosts();
  } catch (error) {
    // Error handled by interceptor
  }
};

const handleModalOk = async () => {
  try {
    await formRef.value.validate();
    confirmLoading.value = true;
    
    const payload = { ...formState };

    if (currentId.value) {
      await updatePost(currentId.value, payload);
      message.success('更新成功');
    } else {
      await createPost(payload);
      message.success('创建成功');
    }
    modalVisible.value = false;
    fetchPosts();
  } catch (error) {
    console.error(error);
  } finally {
    confirmLoading.value = false;
  }
};

onMounted(() => {
  fetchDeptTree();
  fetchPosts();
});
</script>
<style lang="scss" scoped>
  .sys-post-container {
    padding: 16px;
  }
</style>