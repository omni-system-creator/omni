<template>
  <div class="contract-template-container">
    <div class="header-actions">
      <div class="search-box">
        <a-input-search
          v-model:value="searchText"
          placeholder="搜索模板名称"
          enter-button
          @search="handleSearch"
          style="width: 300px"
        />
        <a-select
          v-model:value="filterType"
          style="width: 150px; margin-left: 16px"
          placeholder="模板类型"
          allowClear
          @change="handleSearch"
        >
          <a-select-option
            v-for="item in contractTypeOptions"
            :key="item.value"
            :value="item.value"
          >
            {{ item.label }}
          </a-select-option>
        </a-select>
      </div>
      <a-button type="primary" @click="showAddModal">
        <template #icon><PlusOutlined /></template>
        新增模板
      </a-button>
    </div>

    <a-table
      :columns="columns"
      :data-source="filteredData"
      :pagination="pagination"
      :loading="loading"
      rowKey="id"
      class="template-table"
    >
      <template #bodyCell="{ column, record, index }">
        <template v-if="column.key === 'index'">
          {{ (pagination.current - 1) * pagination.pageSize + index + 1 }}
        </template>
        <template v-if="column.key === 'type'">
          <a-tag :color="getTypeColor(record.type)">
            {{ getTypeName(record.type) }}
          </a-tag>
        </template>
        <template v-if="column.key === 'status'">
          <a-tag :color="getStatusColor(record.status)">
            {{ getStatusLabel(record.status) }}
          </a-tag>
        </template>
        <template v-if="column.key === 'action'">
          <a-space>
            <a-button type="link" size="small" @click="handlePreview(record)" title="预览">
              <EyeOutlined />
            </a-button>
            <a-button type="link" size="small" @click="handleEdit(record)" title="编辑">
              <EditOutlined />
            </a-button>
            <a-popconfirm
              title="确定要删除这个模板吗？"
              ok-text="确定"
              cancel-text="取消"
              @confirm="handleDelete(record.id)"
            >
              <a-button type="link" size="small" danger title="删除">
                <DeleteOutlined />
              </a-button>
            </a-popconfirm>
          </a-space>
        </template>
      </template>
    </a-table>

    <!-- 新增/编辑模态框 -->
    <a-modal
      v-model:open="modalVisible"
      :title="modalTitle"
      @ok="handleModalOk"
      :confirmLoading="modalLoading"
      width="600px"
    >
      <a-form layout="vertical" :model="formState" ref="formRef">
        <a-form-item
          label="模板名称"
          name="name"
          :rules="[{ required: true, message: '请输入模板名称' }]"
        >
          <a-input v-model:value="formState.name" placeholder="请输入模板名称" />
        </a-form-item>
        
        <a-form-item
          label="模板类型"
          name="type"
          :rules="[{ required: true, message: '请选择模板类型' }]"
        >
          <a-select v-model:value="formState.type" placeholder="请选择模板类型">
            <a-select-option
              v-for="item in contractTypeOptions"
              :key="item.value"
              :value="item.value"
            >
              {{ item.label }}
            </a-select-option>
          </a-select>
        </a-form-item>

        <a-form-item label="描述" name="description">
          <a-textarea v-model:value="formState.description" :rows="3" placeholder="请输入模板描述" />
        </a-form-item>

        <a-form-item label="上传文件" name="file">
          <a-upload-dragger
            v-model:fileList="fileList"
            name="file"
            :multiple="false"
            @change="handleFileChange"
            :before-upload="beforeUpload"
            @remove="handleFileRemove"
            @preview="handleFilePreview"
          >
            <p class="ant-upload-drag-icon">
              <InboxOutlined />
            </p>
            <p class="ant-upload-text">点击或拖拽文件到此区域上传</p>
            <p class="ant-upload-hint">
              支持 .docx, .pdf 格式文件
            </p>
          </a-upload-dragger>
        </a-form-item>
        
        <a-form-item label="状态" name="status">
           <a-radio-group v-model:value="formState.status">
              <a-radio
                v-for="item in statusOptions"
                :key="item.value"
                :value="item.value"
              >
                {{ item.label }}
              </a-radio>
           </a-radio-group>
        </a-form-item>
      </a-form>
    </a-modal>
    
    <!-- 预览模态框 (简单模拟) -->
    <a-modal v-model:open="previewVisible" title="模板预览" :footer="null" width="800px">
        <div class="preview-content">
            <h3>{{ previewData?.name }}</h3>
            <div class="preview-info">
                <p>类型: {{ getTypeName(previewData?.type) }}</p>
                <p>描述: {{ previewData?.description || '无' }}</p>
            </div>
            <a-divider />
            <div class="mock-doc-preview">
                <div class="doc-placeholder">
                    <FileTextOutlined style="font-size: 48px; color: #1890ff; margin-bottom: 16px;" />
                    <p>此处为文档预览区域</p>
                    <p>{{ previewData?.fileName }}</p>
                    <p v-if="previewData?.filePath">
                      <a :href="previewData.filePath" target="_blank">下载附件</a>
                    </p>
                </div>
            </div>
        </div>
    </a-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, reactive, computed, onMounted } from 'vue';
import { 
  PlusOutlined, 
  InboxOutlined, 
  FileTextOutlined,
  EyeOutlined,
  EditOutlined,
  DeleteOutlined
} from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import type { UploadChangeParam, UploadProps } from 'ant-design-vue';
import type { ColumnType } from 'ant-design-vue/es/table';
import { getTemplates, createTemplate, updateTemplate, deleteTemplate, uploadTemplateFile, deleteTemplateFile } from '@/api/contract';
import type { ContractTemplateDto } from '@/api/contract';
import { getDictDataByCode, type DictDataDto } from '@/api/dict';

// --- 类型定义 ---
interface TemplateItem {
  id: string;
  name: string;
  type: string;
  description: string;
  status: 'active' | 'inactive';
  updatedAt: string;
  fileName: string;
  filePath: string;
}

const contractTypeOptions = ref<DictDataDto[]>([]);
const statusOptions = ref<DictDataDto[]>([]);

// --- 状态 ---
const searchText = ref('');
const filterType = ref<string | undefined>(undefined);
const loading = ref(false);
const modalVisible = ref(false);
const modalLoading = ref(false);
const modalTitle = ref('新增模板');
const previewVisible = ref(false);
const previewData = ref<TemplateItem | null>(null);

const fileList = ref<any[]>([]);
const formRef = ref();

const formState = reactive({
  id: '',
  name: '',
  type: undefined as string | undefined,
  description: '',
  status: '' as string | undefined,
  fileName: '',
  filePath: ''
});

const currentUploadFile = ref<File | null>(null);
const removeExistingFile = ref(false);

// 模拟数据
const dataSource = ref<TemplateItem[]>([]);

const fetchTemplates = async () => {
  loading.value = true;
  try {
    const res = await getTemplates(filterType.value);
    if (res) {
      dataSource.value = res.map((item: ContractTemplateDto) => ({
        id: item.id.toString(),
        name: item.name,
        type: item.type,
        description: item.description || '',
        status: item.status as 'active' | 'inactive',
        updatedAt: item.updatedAt ? new Date(item.updatedAt).toLocaleString() : new Date(item.createdAt).toLocaleString(),
        fileName: item.fileName || '',
        filePath: item.filePath || '',
      }));
    }
  } catch (error) {
    console.error('Failed to fetch templates:', error);
    dataSource.value = [];
  } finally {
    loading.value = false;
  }
};

onMounted(async () => {
  const [typeRes, statusRes] = await Promise.all([
    getDictDataByCode('contract_type'),
    getDictDataByCode('status')
  ]);
  contractTypeOptions.value = typeRes || [];
  statusOptions.value = statusRes || [];

  if (!filterType.value && contractTypeOptions.value.length > 0) {
    const defaultType = contractTypeOptions.value.find(item => item.isDefault) || contractTypeOptions.value[0];
    if (defaultType) {
      filterType.value = defaultType.value;
    }
  }

  if (!formState.type && contractTypeOptions.value.length > 0) {
    const defaultType = contractTypeOptions.value.find(item => item.isDefault) || contractTypeOptions.value[0];
    if (defaultType) {
      formState.type = defaultType.value;
    }
  }

  if (!formState.status && statusOptions.value.length > 0) {
    const defaultStatus = statusOptions.value.find(item => item.isDefault) || statusOptions.value[0];
    if (defaultStatus) {
      formState.status = defaultStatus.value;
    }
  }

  await fetchTemplates();
});

// --- Actions ---
const handleSearch = () => {
  fetchTemplates();
};

const showAddModal = () => {
  modalTitle.value = '新增模板';
  formState.id = '';
  formState.name = '';
  formState.type = undefined;
  formState.description = '';
  formState.status = statusOptions.value.find(item => item.isDefault)?.value || statusOptions.value[0]?.value || '';
  formState.fileName = '';
  formState.filePath = '';
  fileList.value = [];
  currentUploadFile.value = null;
  removeExistingFile.value = false;
  modalVisible.value = true;
};

const handleEdit = (record: any) => {
  modalTitle.value = '编辑模板';
  formState.id = record.id;
  formState.name = record.name;
  formState.type = record.type;
  formState.description = record.description;
  formState.status = record.status;
  formState.fileName = record.fileName;
  formState.filePath = record.filePath;
  fileList.value = record.fileName ? [{
    uid: '-1',
    name: record.fileName,
    status: 'done',
    url: record.filePath,
  }] : [];
  currentUploadFile.value = null;
  removeExistingFile.value = false;
  modalVisible.value = true;
};

const handleDelete = async (id: string) => {
  try {
    await deleteTemplate(Number(id));
    message.success('删除成功');
    fetchTemplates();
  } catch (error) {
    message.error('删除失败');
    console.error(error);
  }
};

const handleModalOk = async () => {
  formRef.value.validate().then(async () => {
    modalLoading.value = true;
    try {
      if (formState.id) {
        await updateTemplate(Number(formState.id), {
          name: formState.name,
          type: formState.type!,
          description: formState.description,
          status: formState.status
        });
        if (currentUploadFile.value) {
          await uploadTemplateFile(Number(formState.id), currentUploadFile.value);
        } else if (removeExistingFile.value) {
          await deleteTemplateFile(Number(formState.id));
        }
        message.success('模板更新成功');
      } else {
        const created = await createTemplate({
          name: formState.name,
          type: formState.type!,
          description: formState.description,
          status: formState.status
        });
        if (currentUploadFile.value) {
          await uploadTemplateFile(created.id, currentUploadFile.value);
        }
        message.success('创建模板成功');
        if (formState.type) {
          filterType.value = formState.type;
        }
      }
      
      modalVisible.value = false;
      currentUploadFile.value = null;
      fileList.value = [];
      removeExistingFile.value = false;
      fetchTemplates();
    } catch (error) {
      message.error('操作失败');
      console.error(error);
    } finally {
      modalLoading.value = false;
    }
  });
};

const handlePreview = (record: any) => {
  previewData.value = record;
  previewVisible.value = true;
};

// --- File Upload ---
const beforeUpload: UploadProps['beforeUpload'] = file => {
  currentUploadFile.value = file as File;
  fileList.value = [file];
  removeExistingFile.value = false;
  return false;
};

const handleFileChange = (info: UploadChangeParam) => {
  let resFileList = [...info.fileList];
  resFileList = resFileList.slice(-1); // Only keep the last file
  fileList.value = resFileList;
};

const handleFileRemove: UploadProps['onRemove'] = () => {
  fileList.value = [];
  currentUploadFile.value = null;
  if (formState.id) {
    removeExistingFile.value = true;
  }
  return true;
};

const handleFilePreview: UploadProps['onPreview'] = file => {
  const url = (file.url as string) || formState.filePath;
  if (url) {
    window.open(url, '_blank');
  }
};

// --- Computed ---
const getDictLabel = (options: DictDataDto[], value?: string) => {
  if (!value) return '';
  const item = options.find(item => item.value === value);
  return item ? item.label : value;
};

const filteredData = computed(() => {
  let data = dataSource.value;
  if (searchText.value) {
    const key = searchText.value.toLowerCase();
    data = data.filter(item => item.name.toLowerCase().includes(key));
  }
  // Filter by type is handled by API call in fetchTemplates, but for mock data fallback we need client-side filtering
  if (filterType.value) {
     data = data.filter(item => item.type === filterType.value);
  }
  return data;
});

const getTypeName = (type: string | undefined) => getDictLabel(contractTypeOptions.value, type);

const getTypeColor = (type: string | undefined) => {
  const map: Record<string, string> = {
    sales: 'blue',
    purchase: 'green',
    service: 'orange',
    labor: 'cyan',
    other: 'default'
  };
  return type ? map[type] || 'default' : 'default';
};

const getStatusLabel = (status: string | undefined) => getDictLabel(statusOptions.value, status);

const getStatusColor = (status: string | undefined) => {
  switch (status) {
    case '1':
      return 'success';
    case '0':
      return 'default';
  }
};

// --- 表格配置 ---
const columns: ColumnType[] = [
  {
    title: '序号',
    key: 'index',
    width: 80,
    align: 'center',
  },
  {
    title: '模板名称',
    dataIndex: 'name',
    key: 'name',
  },
  {
    title: '类型',
    dataIndex: 'type',
    key: 'type',
    width: 150,
  },
  {
    title: '描述',
    dataIndex: 'description',
    key: 'description',
    ellipsis: true,
  },
  {
    title: '更新时间',
    dataIndex: 'updatedAt',
    key: 'updatedAt',
    width: 200,
  },
  {
    title: '状态',
    dataIndex: 'status',
    key: 'status',
    width: 100,
  },
  {
    title: '操作',
    key: 'action',
    width: 200,
    align: 'center',
  },
];

const pagination = reactive({
  current: 1,
  pageSize: 10,
  showSizeChanger: true,
  pageSizeOptions: ['10', '20', '50', '100'],
  position: ['bottomRight'] as ('bottomLeft' | 'bottomCenter' | 'bottomRight')[],
  showTotal: (total: number) => `共 ${total} 条`,
  onChange: (page: number, pageSize: number) => {
    pagination.current = page;
    pagination.pageSize = pageSize;
  },
  onShowSizeChange: (page: number, pageSize: number) => {
    pagination.current = page;
    pagination.pageSize = pageSize;
  },
});
</script>

<style scoped>
.contract-template-container {
  background: #fff;
  padding: 24px;
  flex: 1;
}

.header-actions {
  display: flex;
  justify-content: space-between;
  margin-bottom: 24px;
}

.template-table {
    background: #fff;
}

.mock-doc-preview {
    height: 400px;
    background: #f5f5f5;
    display: flex;
    justify-content: center;
    align-items: center;
    border: 1px dashed #d9d9d9;
    border-radius: 4px;
}

.doc-placeholder {
    text-align: center;
    color: #999;
}
</style>
