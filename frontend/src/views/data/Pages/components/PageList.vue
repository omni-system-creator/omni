<template>
  <div class="page-list-container">
    <div class="list-header">
      <div class="left">
        <span class="category-title">{{ categoryName || '所有页面' }}</span>
      </div>
      <div class="right">
        <a-button type="primary" @click="handleCreate">
          <template #icon><PlusOutlined /></template>
          新建页面
        </a-button>
      </div>
    </div>
    
    <div class="list-content">
      <a-table
        :columns="columns"
        :data-source="data"
        :loading="loading"
        :pagination="pagination"
        @change="handleTableChange"
        row-key="id"
      >
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'updatedAt'">
            {{ formatDate(record.updatedAt) }}
          </template>
          <template v-if="column.key === 'action'">
            <a-tooltip title="设计">
              <a-button type="link" size="small" @click="handleDesign(record as PageDefinition)">
                <template #icon><FormOutlined /></template>
              </a-button>
            </a-tooltip>
            <a-tooltip title="预览">
              <a-button type="link" size="small" @click="handlePreview(record as PageDefinition)">
                <template #icon><PlayCircleOutlined /></template>
              </a-button>
            </a-tooltip>
            <a-tooltip title="编辑信息">
              <a-button type="link" size="small" @click="handleEdit(record as PageDefinition)">
                <template #icon><EditOutlined /></template>
              </a-button>
            </a-tooltip>
            <a-divider type="vertical" />
            <a-popconfirm title="确定删除吗?" @confirm="handleDelete(record.id)">
              <a-button type="link" size="small" danger>
                <template #icon><DeleteOutlined /></template>
              </a-button>
            </a-popconfirm>
          </template>
        </template>
      </a-table>
    </div>

    <!-- Create/Edit Modal -->
    <a-modal
      v-model:open="modalVisible"
      :title="modalTitle"
      @ok="handleModalOk"
    >
      <a-form :model="formState" layout="vertical">
        <a-form-item label="页面名称" required>
          <a-input v-model:value="formState.name" />
        </a-form-item>
        <a-form-item label="所属分类">
          <a-tree-select
            v-model:value="formState.categoryId"
            :tree-data="categories"
            :field-names="{ label: 'name', value: 'id', children: 'children' }"
            placeholder="请选择分类"
            allow-clear
            tree-default-expand-all
          />
        </a-form-item>
        <a-form-item label="描述">
          <a-textarea v-model:value="formState.description" />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, watch, reactive, onMounted } from 'vue';
import { PlusOutlined, EditOutlined, DeleteOutlined, PlayCircleOutlined, FormOutlined } from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import dayjs from 'dayjs';
import { getPages, savePage, deletePage, type PageDefinition, getPageCategoryTree, type PageCategory } from '@/api/page';

const props = defineProps<{
  categoryId?: number;
  categoryName?: string;
}>();

const formatDate = (dateStr: string) => {
  if (!dateStr) return '-';
  return dayjs(dateStr).format('YYYY-MM-DD HH:mm:ss');
};

const emit = defineEmits(['design', 'preview']);

const loading = ref(false);
const data = ref<PageDefinition[]>([]);
const categories = ref<PageCategory[]>([]);
const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0
});

const columns = [
  { title: '页面名称', dataIndex: 'name', key: 'name' },
  { title: '描述', dataIndex: 'description', key: 'description' },
  { title: '更新时间', dataIndex: 'updatedAt', key: 'updatedAt', width: 200 },
  { title: '操作', key: 'action', width: 240 }
];

const modalVisible = ref(false);
const modalTitle = ref('新建页面');
const formState = reactive<any>({
  id: null,
  name: '',
  description: '',
  categoryId: null
});

const loadCategories = async () => {
  try {
    const res = await getPageCategoryTree();
    categories.value = res || [];
  } catch (e) {
    console.error(e);
  }
};

const loadData = async () => {
  loading.value = true;
  try {
    const res = await getPages({
      page: pagination.current,
      pageSize: pagination.pageSize,
      categoryId: props.categoryId
    });
    data.value = res.items;
    pagination.total = res.total;
  } finally {
    loading.value = false;
  }
};

watch(() => props.categoryId, () => {
  pagination.current = 1;
  loadData();
});

const handleTableChange = (pag: any) => {
  pagination.current = pag.current;
  pagination.pageSize = pag.pageSize;
  loadData();
};

const handleCreate = () => {
  formState.id = null;
  formState.name = '';
  formState.description = '';
  formState.categoryId = props.categoryId;
  modalTitle.value = '新建页面';
  modalVisible.value = true;
  loadCategories();
};

const handleEdit = (record: PageDefinition) => {
  formState.id = record.id;
  formState.name = record.name;
  formState.description = record.description;
  formState.categoryId = record.categoryId;
  modalTitle.value = '编辑页面';
  modalVisible.value = true;
  loadCategories();
};

const handleModalOk = async () => {
  if (!formState.name) return message.warning('请输入名称');
  
  try {
    // Preserve existing data for edit, only update metadata
    let dataToSave = { ...formState };
    if (formState.id) {
       // If editing, we might need to fetch full object or just send fields to update
       // Backend update usually handles partial updates or we send what we have
       // Ideally we should merge with existing data if needed, but for rename/move, this is enough
       // provided the backend doesn't clear other fields if they are null in DTO.
       // Based on PageService.cs, it updates fields from DTO. We should ensure we don't clear config/code.
       // The UpdatePageAsync implementation updates Name, CategoryId, Code, Config, etc.
       // We need to be careful. The current formState only has name, desc, categoryId.
       // Code and Config are missing.
       // We should fetch the full page data first or ensure backend supports partial update / check nulls.
       // Let's check backend logic... PageService.cs lines:
       // page.Name = dto.Name; page.CategoryId = dto.CategoryId; page.Code = dto.Code; ...
       // It blindly assigns. So we MUST fetch the page first or send all data.
       
       // Optimization: fetch the current record from `data` array if it contains enough info?
       // The list api usually doesn't return full config/code for performance.
       // So we better fetch by ID first.
       
       const fullPage = await import('@/api/page').then(m => m.getPageById(formState.id));
       if (fullPage) {
         dataToSave = { ...fullPage, ...formState };
       }
    }

    await savePage(dataToSave);
    message.success('保存成功');
    modalVisible.value = false;
    loadData();
  } catch (e) {
    message.error('保存失败');
  }
};

const handleDelete = async (id: number) => {
  try {
    await deletePage(id);
    message.success('删除成功');
    loadData();
  } catch (e) {
    message.error('删除失败');
  }
};

const handleDesign = (record: PageDefinition) => {
  emit('design', record);
};

const handlePreview = (record: PageDefinition) => {
  emit('preview', record);
};

onMounted(() => {
  loadData();
});
</script>

<style scoped>
.page-list-container {
  padding: 20px;
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

.danger-text {
  color: #ff4d4f;
}
</style>
