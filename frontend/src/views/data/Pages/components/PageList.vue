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
          <template v-if="column.key === 'action'">
            <a @click="handleDesign(record)">设计</a>
            <a-divider type="vertical" />
            <a @click="handlePreview(record)">预览</a>
            <a-divider type="vertical" />
            <a-popconfirm title="确定删除吗?" @confirm="handleDelete(record.id)">
              <a class="danger-text">删除</a>
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
        <a-form-item label="描述">
          <a-textarea v-model:value="formState.description" />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, watch, reactive, onMounted } from 'vue';
import { PlusOutlined } from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import { getPages, savePage, deletePage, type PageDefinition } from '@/api/page';

const props = defineProps<{
  categoryId?: number;
  categoryName?: string;
}>();

const emit = defineEmits(['design', 'preview']);

const loading = ref(false);
const data = ref<PageDefinition[]>([]);
const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0
});

const columns = [
  { title: '页面名称', dataIndex: 'name', key: 'name' },
  { title: '更新时间', dataIndex: 'updatedAt', key: 'updatedAt', width: 200 },
  { title: '操作', key: 'action', width: 200 }
];

const modalVisible = ref(false);
const modalTitle = ref('新建页面');
const formState = reactive<any>({
  id: null,
  name: '',
  description: '',
  categoryId: null
});

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
};

const handleModalOk = async () => {
  if (!formState.name) return message.warning('请输入名称');
  
  try {
    await savePage({ ...formState });
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
