<template>
  <div class="form-list-container">
    <div class="list-header">
      <div class="header-left">
        <span class="category-title">{{ categoryName || '全部表单' }}</span>
      </div>
      <div class="header-right">
        <a-space>
          <a-input-search
            v-model:value="queryParams.keyword"
            placeholder="搜索表单"
            style="width: 200px"
            @search="handleSearch"
          />
          <a-button type="primary" @click="handleCreate">
            <template #icon><PlusOutlined /></template>
            新建表单
          </a-button>
        </a-space>
      </div>
    </div>

    <div class="list-content">
      <a-table
        :columns="columns"
        :data-source="tableData"
        :loading="loading"
        :pagination="pagination"
        @change="handleTableChange"
        row-key="id"
      >
        <template #bodyCell="{ column, record, index }">
          <template v-if="column.key === 'index'">
            {{ (pagination.current - 1) * pagination.pageSize + index + 1 }}
          </template>
          <template v-else-if="column.key === 'status'">
            <a-tag :color="record.isPublished ? 'green' : 'orange'">
              {{ record.isPublished ? '已发布' : '草稿' }}
            </a-tag>
          </template>
          <template v-else-if="column.key === 'updatedAt'">
            {{ record.updatedAt ? dayjs(record.updatedAt).format('YYYY-MM-DD HH:mm:ss') : '-' }}
          </template>
          <template v-else-if="column.key === 'action'">
            <a-space>
              <a-tooltip title="编辑">
                <a-button type="link" size="small" @click="handleEdit(record)">
                  <template #icon><EditOutlined /></template>
                </a-button>
              </a-tooltip>
              <a-tooltip title="设计">
                <a-button type="link" size="small" @click="handleDesign(record)">
                  <template #icon><FormOutlined /></template>
                </a-button>
              </a-tooltip>
              <a-tooltip title="发布" v-if="!record.isPublished">
                <a-button 
                  type="link" 
                  size="small" 
                  @click="handlePublish(record)"
                >
                  <template #icon><SendOutlined /></template>
                </a-button>
              </a-tooltip>
              <a-tooltip title="取消发布" v-if="record.isPublished">
                <a-button 
                  type="link" 
                  size="small" 
                  @click="handleUnpublish(record)"
                >
                  <template #icon><StopOutlined /></template>
                </a-button>
              </a-tooltip>
              <a-tooltip title="分享" v-if="record.isPublished">
                <a-button 
                  type="link" 
                  size="small" 
                  @click="handleViewLink(record)"
                >
                  <template #icon><ShareAltOutlined /></template>
                </a-button>
              </a-tooltip>
              <a-popconfirm title="确定删除吗？" @confirm="handleDelete(record.id)">
                <a-tooltip title="删除">
                  <a-button type="link" danger size="small">
                    <template #icon><DeleteOutlined /></template>
                  </a-button>
                </a-tooltip>
              </a-popconfirm>
            </a-space>
          </template>
        </template>
      </a-table>
    </div>

    <!-- Create/Edit Dialog -->
    <a-modal
      v-model:open="dialogVisible"
      :title="dialogTitle"
      @ok="handleDialogOk"
      :confirmLoading="confirmLoading"
    >
      <a-form :model="formState" layout="vertical">
        <a-form-item label="表单名称" required>
          <a-input v-model:value="formState.name" placeholder="请输入表单名称" />
        </a-form-item>
        <a-form-item label="所属分类" required>
           <a-tree-select
            v-model:value="formState.categoryId"
            style="width: 100%"
            :dropdown-style="{ maxHeight: '400px', overflow: 'auto' }"
            :tree-data="categoryTreeData"
            placeholder="请选择分类"
            :field-names="{ children: 'children', label: 'name', value: 'id' }"
            tree-default-expand-all
          />
        </a-form-item>
        <a-form-item label="描述">
          <a-textarea v-model:value="formState.description" :rows="4" />
        </a-form-item>
        <a-form-item label="设置" name="requiresLogin">
          <a-space direction="vertical">
            <a-checkbox v-model:checked="formState.requiresLogin">需要登录才能填报</a-checkbox>
            <a-checkbox v-model:checked="formState.limitOnePerUser">每人只能填一份 (需登录)</a-checkbox>
          </a-space>
        </a-form-item>
      </a-form>
    </a-modal>

    <!-- Publish Link Modal -->
    <a-modal
      v-model:open="linkModalVisible"
      title="表单链接"
      :footer="null"
    >
      <div class="link-content">
        <a-input v-model:value="publishUrl" readonly>
          <template #addonAfter>
            <CopyOutlined style="cursor: pointer" @click="copyLink" />
          </template>
        </a-input>
        <div style="margin-top: 16px; text-align: center;">
          <a-qrcode :value="publishUrl" />
        </div>
      </div>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, watch, onMounted } from 'vue';
import { 
  PlusOutlined, 
  CopyOutlined,
  EditOutlined,
  FormOutlined,
  SendOutlined,
  StopOutlined,
  ShareAltOutlined,
  DeleteOutlined
} from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import dayjs from 'dayjs';
import { useRouter } from 'vue-router';
import { getFormList, createForm, updateForm, deleteForm, getCategoryTree, type FormDefinition } from '@/api/form';

const props = defineProps({
  categoryId: {
    type: Number,
    default: null
  },
  categoryName: {
    type: String,
    default: ''
  }
});

const emit = defineEmits(['open-designer']);

const router = useRouter();
const loading = ref(false);
const tableData = ref<FormDefinition[]>([]);
const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0,
  showSizeChanger: true,
  pageSizeOptions: ['10', '20', '50', '100'],
  showTotal: (total: number) => `共 ${total} 条`
});
const queryParams = reactive({
  keyword: '',
  categoryId: props.categoryId
});

const columns = [
  { title: '序号', key: 'index', width: 70, align: 'center' },
  { title: '表单名称', dataIndex: 'name', key: 'name' },
  { title: '描述', dataIndex: 'description', key: 'description', ellipsis: true },
  { title: '状态', dataIndex: 'isPublished', key: 'status', width: 100 },
  { title: '修改时间', dataIndex: 'updatedAt', key: 'updatedAt', width: 180 },
  { title: '操作', key: 'action', width: 280, fixed: 'right' }
];

// Dialog Logic
const dialogVisible = ref(false);
const dialogTitle = ref('新建表单');
const confirmLoading = ref(false);
const categoryTreeData = ref([]);
const formState = reactive<FormDefinition>({
  name: '',
  categoryId: 0,
  description: '',
  requiresLogin: false,
  limitOnePerUser: false
});

// Link Modal
const linkModalVisible = ref(false);
const publishUrl = ref('');

const loadData = async () => {
  loading.value = true;
  try {
    const res = await getFormList({
      categoryId: queryParams.categoryId
    });
    // request returns res.data directly (the array)
    const list = (Array.isArray(res) ? res : (res as any).data) || [];
    tableData.value = list;
    pagination.total = list.length;
  } catch (e) {
    // error
  } finally {
    loading.value = false;
  }
};

const loadCategories = async () => {
  const res = await getCategoryTree();
  categoryTreeData.value = (Array.isArray(res) ? res : (res as any).data) || [];
};

const handleSearch = () => {
  // Client side filtering if backend doesn't support search yet
  // Or just reload if backend supports search (it only supports categoryId now)
  loadData();
};

const handleTableChange = (pag: any) => {
  pagination.current = pag.current;
  pagination.pageSize = pag.pageSize;
  // loadData(); // No need to reload if client side pagination, but Ant Design Table handles it if we don't handle change event for server side
  // But here we are just setting pagination state. If we want client side pagination with Ant Table, we pass data and pagination prop.
  // If we want server side, we call API. 
  // Since backend doesn't support pagination, we should probably just let Ant Table handle it by not listening to change or implementing client side slicing.
  // For simplicity, let's just reload.
  // Actually, if backend returns all, Ant Table with pagination prop will slice it automatically if we don't use server-side logic.
  // But we are setting tableData to full list.
};

const handleCreate = () => {
  formState.id = undefined;
  formState.name = '';
  formState.categoryId = props.categoryId || (categoryTreeData.value[0] as any)?.id;
  formState.description = '';
  formState.requiresLogin = false;
  formState.limitOnePerUser = false;
  dialogTitle.value = '新建表单';
  dialogVisible.value = true;
};

const handleEdit = (record: FormDefinition) => {
  formState.id = record.id;
  formState.name = record.name;
  formState.categoryId = record.categoryId;
  formState.description = record.description;
  formState.requiresLogin = !!record.requiresLogin;
  formState.limitOnePerUser = !!record.limitOnePerUser;
  dialogTitle.value = '编辑表单';
  dialogVisible.value = true;
};

const handleDesign = (record: FormDefinition) => {
  // Open designer
  emit('open-designer', record);
};

const handleDelete = async (id: number) => {
  await deleteForm(id);
  message.success('删除成功');
  loadData();
};

const handleDialogOk = async () => {
  if (!formState.name) {
    message.warning('请输入表单名称');
    return;
  }
  if (!formState.categoryId) {
    message.warning('请选择分类');
    return;
  }
  
  confirmLoading.value = true;
  try {
    if (formState.id) {
      await updateForm(formState.id, formState);
    } else {
      await createForm(formState);
    }
    message.success('保存成功');
    dialogVisible.value = false;
    loadData();
  } catch (e) {
    // error
  } finally {
    confirmLoading.value = false;
  }
};

const handlePublish = async (record: FormDefinition) => {
  await updateForm(record.id!, {
    ...record,
    isPublished: true
  });
  message.success('发布成功');
  loadData();
  handleViewLink({ ...record, isPublished: true });
};

const handleUnpublish = async (record: FormDefinition) => {
  await updateForm(record.id!, {
    ...record,
    isPublished: false
  });
  message.success('已取消发布');
  loadData();
};

const handleViewLink = (record: FormDefinition) => {
  const routeData = router.resolve({
    name: 'FormSubmit',
    params: { id: record.id }
  });
  publishUrl.value = `${window.location.origin}${routeData.href}`; 
  linkModalVisible.value = true;
};

const copyLink = () => {
  navigator.clipboard.writeText(publishUrl.value);
  message.success('链接已复制');
};

watch(() => props.categoryId, (val) => {
  queryParams.categoryId = val;
  handleSearch();
});

onMounted(() => {
  loadData();
  loadCategories();
});
</script>

<style scoped>
.form-list-container {
  padding: 16px;
  background: #fff;
  height: 100%;
  display: flex;
  flex-direction: column;
}

.list-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.category-title {
  font-size: 18px;
  font-weight: 600;
}

.list-content {
  flex: 1;
  overflow: hidden;
}
</style>
