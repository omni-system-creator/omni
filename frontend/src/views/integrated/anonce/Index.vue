<script setup lang="ts">
import { ref, reactive, onMounted, watch } from 'vue';
import { message, type FormInstance } from 'ant-design-vue';
import type { Rule } from 'ant-design-vue/es/form';
import { 
  getAnonceList, 
  getAnonce,
  createAnonce, 
  updateAnonce, 
  deleteAnonce, 
  publishAnonce, 
  revokeAnonce,
  type AnonceDto,
  type CreateAnonceDto
} from '@/api/anonce';
import { getDictDataByCode, type DictDataDto } from '@/api/dict';
import { 
  PlusOutlined, 
  SearchOutlined
} from '@ant-design/icons-vue';
import dayjs from 'dayjs';

// --- State ---
const loading = ref(false);
const list = ref<AnonceDto[]>([]);
const total = ref(0);
const anonceTypes = ref<DictDataDto[]>([]);
const priorityTypes = ref<DictDataDto[]>([]);

const query = reactive({
  title: '',
  type: undefined as string | undefined,
  status: undefined as string | undefined,
  page: 1,
  pageSize: 10
});

const modalVisible = ref(false);
const modalLoading = ref(false);
const isEdit = ref(false);
const formRef = ref<FormInstance>();

const detailVisible = ref(false);
const detailData = ref<AnonceDto>();

// Drag functionality
let startX = 0;
let startY = 0;
let transformX = 0;
let transformY = 0;

const handleTitleMouseDown = (e: MouseEvent) => {
  const modalContent = document.querySelector('.anonce-detail-modal .ant-modal-content') as HTMLElement;
  if (!modalContent) return;

  startX = e.clientX;
  startY = e.clientY;
  
  // Get current transform values
  const transform = window.getComputedStyle(modalContent).transform;
  const matrix = new DOMMatrix(transform);
  transformX = matrix.m41;
  transformY = matrix.m42;

  document.addEventListener('mousemove', handleMouseMove);
  document.addEventListener('mouseup', handleMouseUp);
};

const handleMouseMove = (e: MouseEvent) => {
  const modalContent = document.querySelector('.anonce-detail-modal .ant-modal-content') as HTMLElement;
  if (!modalContent) return;
  
  const moveX = e.clientX - startX;
  const moveY = e.clientY - startY;
  
  modalContent.style.transform = `translate(${transformX + moveX}px, ${transformY + moveY}px)`;
};

const handleMouseUp = () => {
  document.removeEventListener('mousemove', handleMouseMove);
  document.removeEventListener('mouseup', handleMouseUp);
};

watch(detailVisible, (val) => {
  if (val) {
    // Reset position when opening
    setTimeout(() => {
      const modalContent = document.querySelector('.anonce-detail-modal .ant-modal-content') as HTMLElement;
      if (modalContent) {
        modalContent.style.transform = 'none';
      }
    }, 0);
  }
});

const formData = reactive({
  id: 0,
  title: '',
  content: '',
  type: undefined as string | undefined,
  priority: 'normal'
});

const rules: Record<string, Rule[]> = {
  title: [{ required: true, message: '请输入标题', trigger: 'blur' }],
  content: [{ required: true, message: '请输入内容', trigger: 'blur' }],
  type: [{ required: true, message: '请选择类型', trigger: 'change' }]
};

const columns = [
  { 
    title: '序号', 
    width: 70, 
    align: 'center' as const, 
    customRender: ({ index }: { index: number }) => (query.page - 1) * query.pageSize + index + 1 
  },
  { title: '标题', dataIndex: 'title', key: 'title', ellipsis: true },
  { title: '类型', dataIndex: 'type', key: 'type', width: 120 },
  { title: '状态', dataIndex: 'status', key: 'status', width: 100 },
  { title: '优先级', dataIndex: 'priority', key: 'priority', width: 100 },
  { title: '发布时间', dataIndex: 'publishTime', key: 'publishTime', width: 180 },
  { title: '创建时间', dataIndex: 'createdAt', key: 'createdAt', width: 180 },
  { title: '操作', key: 'action', width: 250, fixed: 'right' as const }
];

// --- Methods ---

const loadDicts = async () => {
  try {
    const [anonceTypeRes, priorityRes] = await Promise.all([
      getDictDataByCode('anonce_type'),
      getDictDataByCode('priority')
    ]);
    anonceTypes.value = anonceTypeRes || [];
    priorityTypes.value = priorityRes || [];
  } catch (error) {
    console.error('Failed to load dicts', error);
  }
};

const loadData = async () => {
  loading.value = true;
  try {
    const res = await getAnonceList(query);
    list.value = res.items;
    total.value = res.total;
  } catch (error) {
    // handled by interceptor
  } finally {
    loading.value = false;
  }
};

const handleSearch = () => {
  query.page = 1;
  loadData();
};

const handleReset = () => {
  query.title = '';
  query.type = undefined;
  query.status = undefined;
  handleSearch();
};

const handleAdd = () => {
  isEdit.value = false;
  formData.id = 0;
  formData.title = '';
  formData.content = '';
  formData.type = undefined;
  formData.priority = 'normal';
  modalVisible.value = true;
};

const handleEdit = async (record: AnonceDto) => {
  try {
    const res = await getAnonce(record.id);
    isEdit.value = true;
    formData.id = res.id;
    formData.title = res.title;
    formData.content = res.content;
    formData.type = res.type;
    formData.priority = res.priority;
    modalVisible.value = true;
  } catch (error) {
    // handled
  }
};

const handleDetail = async (id: number) => {
  try {
    const res = await getAnonce(id);
    detailData.value = res;
    detailVisible.value = true;
  } catch (error) {
    // handled
  }
};

const handleDelete = async (id: number) => {
  try {
    await deleteAnonce(id);
    message.success('删除成功');
    loadData();
  } catch (error) {
    // handled
  }
};

const handlePublish = async (id: number) => {
  try {
    await publishAnonce(id);
    message.success('发布成功');
    loadData();
  } catch (error) {
    // handled
  }
};

const handleRevoke = async (id: number) => {
  try {
    await revokeAnonce(id);
    message.success('撤回成功');
    loadData();
  } catch (error) {
    // handled
  }
};

const handleModalOk = async () => {
  try {
    await formRef.value?.validate();
    modalLoading.value = true;
    if (isEdit.value) {
      await updateAnonce(formData.id, formData);
      message.success('更新成功');
    } else {
      await createAnonce(formData as CreateAnonceDto);
      message.success('创建成功');
    }
    modalVisible.value = false;
    loadData();
  } catch (error) {
    // handled
  } finally {
    modalLoading.value = false;
  }
};

const getTypeName = (typeValue: string) => {
  const found = anonceTypes.value.find(t => t.value === typeValue);
  return found ? found.label : typeValue;
};

const getPriorityName = (value: string) => {
  const found = priorityTypes.value.find(t => t.value === value);
  return found ? found.label : value;
};

const getPriorityColor = (value: string) => {
  switch (value) {
    case 'high': return 'red';
    case 'normal': return 'blue';
    case 'low': return 'green';
    default: return 'default';
  }
};

const getStatusColor = (status: string) => {
  switch (status) {
    case 'published': return 'green';
    case 'draft': return 'default';
    case 'revoked': return 'orange';
    default: return 'default';
  }
};

const getStatusText = (status: string) => {
  switch (status) {
    case 'published': return '已发布';
    case 'draft': return '草稿';
    case 'revoked': return '已撤回';
    default: status;
  }
};

// --- Lifecycle ---
onMounted(() => {
  loadDicts();
  loadData();
});
</script>

<template>
  <div class="page-container">
    <div class="action-header">
      <div class="search-area">
        <a-input 
          v-model:value="query.title" 
          placeholder="搜索公告标题" 
          style="width: 250px" 
          allow-clear 
          @pressEnter="handleSearch"
        />
        <a-select 
          v-model:value="query.type" 
          placeholder="公告类型" 
          style="width: 150px; margin-left: 8px" 
          allow-clear
          @change="handleSearch"
        >
          <a-select-option v-for="item in anonceTypes" :key="item.id" :value="item.value">
            {{ item.label }}
          </a-select-option>
        </a-select>
        <a-select 
          v-model:value="query.status" 
          placeholder="状态" 
          style="width: 120px; margin-left: 8px" 
          allow-clear
          @change="handleSearch"
        >
          <a-select-option value="draft">草稿</a-select-option>
          <a-select-option value="published">已发布</a-select-option>
          <a-select-option value="revoked">已撤回</a-select-option>
        </a-select>
        <a-button type="primary" @click="handleSearch" style="margin-left: 8px">
          <template #icon><SearchOutlined /></template> 查询
        </a-button>
        <a-button @click="handleReset" style="margin-left: 8px">重置</a-button>
      </div>
      <div class="btn-area">
        <a-button type="primary" @click="handleAdd">
          <template #icon><PlusOutlined /></template>
          新增公告
        </a-button>
      </div>
    </div>

    <a-table 
      :columns="columns" 
      :data-source="list" 
      :pagination="{ 
        total: total, 
        current: query.page, 
        pageSize: query.pageSize,
        showSizeChanger: true,
        showQuickJumper: true,
        showTotal: (total: number) => `共 ${total} 条`,
        onChange: (page, pageSize) => { query.page = page; query.pageSize = pageSize; loadData(); }
      }"
      :loading="loading"
      row-key="id"
    >
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'type'">
          <a-tag color="blue">{{ getTypeName(record.type) }}</a-tag>
        </template>
        <template v-if="column.key === 'status'">
          <a-badge :status="getStatusColor(record.status) as any" :text="getStatusText(record.status)" />
        </template>
        <template v-if="column.key === 'priority'">
          <a-tag :color="getPriorityColor(record.priority)">
            {{ getPriorityName(record.priority) }}
          </a-tag>
        </template>
        <template v-if="column.key === 'publishTime'">
          {{ record.publishTime ? dayjs(record.publishTime).format('YYYY-MM-DD HH:mm') : '-' }}
        </template>
        <template v-if="column.key === 'createdAt'">
          {{ dayjs(record.createdAt).format('YYYY-MM-DD HH:mm') }}
        </template>
        <template v-if="column.key === 'action'">
          <a-space :size="0">
            <a-button type="link" size="small" @click="handleDetail(record.id)">查看</a-button>
            <a-button type="link" size="small" @click="handleEdit(record as AnonceDto)" :disabled="record.status === 'published'">编辑</a-button>
            <a-button type="link" size="small" v-if="record.status !== 'published'" @click="handlePublish(record.id)">发布</a-button>
            <a-button type="link" size="small" v-if="record.status === 'published'" @click="handleRevoke(record.id)" style="color: #faad14">撤回</a-button>
            <a-popconfirm title="确定要删除这条公告吗？" @confirm="handleDelete(record.id)">
              <a-button type="link" size="small" danger>删除</a-button>
            </a-popconfirm>
          </a-space>
        </template>
      </template>
    </a-table>

    <!-- Modal -->
    <a-modal
      v-model:open="modalVisible"
      :title="isEdit ? '编辑公告' : '新增公告'"
      :confirm-loading="modalLoading"
      @ok="handleModalOk"
      width="800px"
    >
      <a-form ref="formRef" :model="formData" :rules="rules" layout="vertical">
        <a-row :gutter="16">
          <a-col :span="16">
            <a-form-item label="标题" name="title">
              <a-input v-model:value="formData.title" placeholder="请输入公告标题" />
            </a-form-item>
          </a-col>
          <a-col :span="8">
            <a-form-item label="类型" name="type">
              <a-select v-model:value="formData.type" placeholder="选择类型">
                <a-select-option v-for="item in anonceTypes" :key="item.id" :value="item.value">
                  {{ item.label }}
                </a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
        </a-row>
        
        <a-row :gutter="16">
          <a-col :span="8">
             <a-form-item label="优先级" name="priority">
              <a-select v-model:value="formData.priority" placeholder="选择优先级">
                <a-select-option v-for="item in priorityTypes" :key="item.id" :value="item.value">
                  {{ item.label }}
                </a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
        </a-row>

        <a-form-item label="内容" name="content">
          <a-textarea 
            v-model:value="formData.content" 
            placeholder="请输入公告内容" 
            :rows="10" 
            show-count 
            :maxlength="2000" 
          />
        </a-form-item>
      </a-form>
    </a-modal>

    <!-- Detail Modal -->
    <a-modal
      v-model:open="detailVisible"
      :footer="null"
      :title="null"
      width="900px"
      :body-style="{ padding: '0' }"
      wrap-class-name="anonce-detail-modal"
      :modal-render="(args: any) => args.originVNode"
    >
      <div class="anonce-detail">
        <div 
          class="anonce-header" 
          @mousedown="handleTitleMouseDown"
        >
          <h2 class="anonce-title">{{ detailData?.title }}</h2>
          <div class="anonce-meta">
            <a-space size="middle" wrap>
              <a-tag color="blue" v-if="detailData?.type">{{ getTypeName(detailData.type) }}</a-tag>
              
              <a-tag v-if="detailData?.priority" :color="getPriorityColor(detailData.priority)">
                {{ getPriorityName(detailData.priority) }}
              </a-tag>

              <span class="meta-item">
                <a-badge 
                  v-if="detailData?.status"
                  :status="getStatusColor(detailData.status) as any" 
                  :text="getStatusText(detailData.status)" 
                />
              </span>

              <span class="meta-text" v-if="detailData?.publishTime">
                发布时间：{{ dayjs(detailData.publishTime).format('YYYY-MM-DD HH:mm') }}
              </span>
              
              <span class="meta-text" v-if="detailData?.createdAt">
                创建时间：{{ dayjs(detailData.createdAt).format('YYYY-MM-DD HH:mm') }}
              </span>
            </a-space>
          </div>
        </div>
        
        <a-divider style="margin: 0" />
        
        <div class="anonce-content">
          {{ detailData?.content }}
        </div>
      </div>
    </a-modal>
  </div>
</template>

<style>
.anonce-detail-modal .ant-modal-content {
  padding: 0;
  overflow: hidden;
}
</style>

<style scoped>
.page-container {
  padding: 24px;
  background: #fff;
  min-height: 100%;
}

.action-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 16px;
}

.search-area {
  display: flex;
  align-items: center;
}

/* Detail Modal Styles */
.anonce-detail {
  display: flex;
  flex-direction: column;
}

.anonce-header {
  padding: 24px 32px 16px;
  text-align: center;
  background-color: #fcfcfc;
  cursor: move;
  user-select: none;
}

.anonce-title {
  font-size: 24px;
  font-weight: 600;
  color: #1f1f1f;
  margin-bottom: 16px;
  line-height: 1.4;
}

.anonce-meta {
  color: #8c8c8c;
  font-size: 13px;
}

.meta-text {
  color: #8c8c8c;
}

.anonce-content {
  padding: 32px;
  font-size: 16px;
  line-height: 1.8;
  color: #262626;
  white-space: pre-wrap;
  min-height: 200px;
  max-height: 60vh;
  overflow-y: auto;
  background-color: #fff;
}
</style>
