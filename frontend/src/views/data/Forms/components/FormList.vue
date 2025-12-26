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
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'status'">
            <a-tag :color="record.status === 1 ? 'green' : 'orange'">
              {{ record.status === 1 ? '已发布' : '草稿' }}
            </a-tag>
          </template>
          <template v-else-if="column.key === 'action'">
            <a-space>
              <a-button type="link" size="small" @click="handleEdit(record)">编辑</a-button>
              <a-button type="link" size="small" @click="handleDesign(record)">设计</a-button>
              <a-button 
                type="link" 
                size="small" 
                @click="handlePublish(record)"
                v-if="record.status !== 1"
              >
                发布
              </a-button>
              <a-button 
                type="link" 
                size="small" 
                @click="handleViewLink(record)"
                v-if="record.status === 1"
              >
                链接
              </a-button>
              <a-popconfirm title="确定删除吗？" @confirm="handleDelete(record.id)">
                <a-button type="link" danger size="small">删除</a-button>
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
import { PlusOutlined, CopyOutlined } from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import { getFormList, createForm, updateForm, deleteForm, publishForm, getCategoryTree, type FormDefinition } from '@/api/form';

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

const loading = ref(false);
const tableData = ref<FormDefinition[]>([]);
const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0
});
const queryParams = reactive({
  keyword: '',
  categoryId: props.categoryId
});

const columns = [
  { title: '表单名称', dataIndex: 'name', key: 'name' },
  { title: '描述', dataIndex: 'description', key: 'description', ellipsis: true },
  { title: '状态', dataIndex: 'status', key: 'status', width: 100 },
  { title: '创建时间', dataIndex: 'createTime', key: 'createTime', width: 180 },
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
  description: ''
});

// Link Modal
const linkModalVisible = ref(false);
const publishUrl = ref('');

const loadData = async () => {
  loading.value = true;
  try {
    const res = await getFormList({
      page: pagination.current,
      pageSize: pagination.pageSize,
      ...queryParams
    });
    tableData.value = (res as any).data.list;
    pagination.total = (res as any).data.total;
  } catch (e) {
    // error
  } finally {
    loading.value = false;
  }
};

const loadCategories = async () => {
  const res = await getCategoryTree();
  categoryTreeData.value = (res as any).data;
};

const handleSearch = () => {
  pagination.current = 1;
  loadData();
};

const handleTableChange = (pag: any) => {
  pagination.current = pag.current;
  pagination.pageSize = pag.pageSize;
  loadData();
};

const handleCreate = () => {
  formState.id = undefined;
  formState.name = '';
  formState.categoryId = props.categoryId || (categoryTreeData.value[0] as any)?.id;
  formState.description = '';
  dialogTitle.value = '新建表单';
  dialogVisible.value = true;
};

const handleEdit = (record: FormDefinition) => {
  formState.id = record.id;
  formState.name = record.name;
  formState.categoryId = record.categoryId;
  formState.description = record.description;
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
  const res = await publishForm(record.id!);
  message.success('发布成功');
  loadData();
  publishUrl.value = (res as any).data.url;
  linkModalVisible.value = true;
};

const handleViewLink = (record: FormDefinition) => {
  // Normally this URL comes from backend or constructed
  publishUrl.value = `http://localhost:5173/form/submit/${record.id}`; 
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
