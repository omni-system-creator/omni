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
          <a-select-option value="sales">销售合同</a-select-option>
          <a-select-option value="purchase">采购合同</a-select-option>
          <a-select-option value="service">服务合同</a-select-option>
          <a-select-option value="labor">劳动合同</a-select-option>
          <a-select-option value="other">其他</a-select-option>
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
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'type'">
          <a-tag :color="getTypeColor(record.type)">
            {{ getTypeName(record.type) }}
          </a-tag>
        </template>
        <template v-if="column.key === 'status'">
          <a-badge :status="record.status === 'active' ? 'success' : 'default'" :text="record.status === 'active' ? '启用' : '停用'" />
        </template>
        <template v-if="column.key === 'action'">
          <a-space>
            <a-button type="link" size="small" @click="handlePreview(record)">预览</a-button>
            <a-button type="link" size="small" @click="handleEdit(record)">编辑</a-button>
            <a-popconfirm
              title="确定要删除这个模板吗？"
              ok-text="确定"
              cancel-text="取消"
              @confirm="handleDelete(record.id)"
            >
              <a-button type="link" size="small" danger>删除</a-button>
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
            <a-select-option value="sales">销售合同</a-select-option>
            <a-select-option value="purchase">采购合同</a-select-option>
            <a-select-option value="service">服务合同</a-select-option>
            <a-select-option value="labor">劳动合同</a-select-option>
            <a-select-option value="other">其他</a-select-option>
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
            action="https://www.mocky.io/v2/5cc8019d300000980a055e76"
            @change="handleFileChange"
            :before-upload="beforeUpload"
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
              <a-radio value="active">启用</a-radio>
              <a-radio value="inactive">停用</a-radio>
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
  SearchOutlined
} from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import type { UploadChangeParam, UploadProps } from 'ant-design-vue';

// --- 类型定义 ---
interface TemplateItem {
  id: string;
  name: string;
  type: string;
  description: string;
  status: 'active' | 'inactive';
  updatedAt: string;
  fileName: string;
}

// --- 状态 ---
const searchText = ref('');
const filterType = ref<string | undefined>(undefined);
const loading = ref(false);
const modalVisible = ref(false);
const modalLoading = ref(false);
const modalTitle = ref('新增模板');
const previewVisible = ref(false);
const previewData = ref<TemplateItem | null>(null);

const fileList = ref([]);
const formRef = ref();

const formState = reactive({
  id: '',
  name: '',
  type: undefined as string | undefined,
  description: '',
  status: 'active',
  fileName: ''
});

// 模拟数据
const dataSource = ref<TemplateItem[]>([
  {
    id: '1',
    name: '标准产品销售合同',
    type: 'sales',
    description: '适用于一般标准产品的销售业务',
    status: 'active',
    updatedAt: '2023-12-01 10:00:00',
    fileName: 'standard_sales_contract_v1.docx'
  },
  {
    id: '2',
    name: '原材料采购框架协议',
    type: 'purchase',
    description: '适用于长期原材料采购合作',
    status: 'active',
    updatedAt: '2023-11-20 14:30:00',
    fileName: 'material_purchase_agreement.pdf'
  },
  {
    id: '3',
    name: '技术服务合同',
    type: 'service',
    description: '适用于软件开发及技术支持服务',
    status: 'active',
    updatedAt: '2023-12-05 09:15:00',
    fileName: 'tech_service_contract.docx'
  },
  {
    id: '4',
    name: '员工劳动合同（标准版）',
    type: 'labor',
    description: '全职员工标准劳动合同',
    status: 'active',
    updatedAt: '2023-10-15 16:00:00',
    fileName: 'employee_labor_contract.docx'
  },
]);

// --- 表格配置 ---
const columns = [
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
  },
];

const pagination = {
  pageSize: 10,
};

// --- 计算属性 ---
const filteredData = computed(() => {
  return dataSource.value.filter(item => {
    const matchText = item.name.toLowerCase().includes(searchText.value.toLowerCase());
    const matchType = !filterType.value || item.type === filterType.value;
    return matchText && matchType;
  });
});

// --- 方法 ---

const getTypeColor = (type: string) => {
  const map: Record<string, string> = {
    sales: 'blue',
    purchase: 'cyan',
    service: 'purple',
    labor: 'orange',
    other: 'default'
  };
  return map[type] || 'default';
};

const getTypeName = (type: string | undefined) => {
    if (!type) return '';
    const map: Record<string, string> = {
        sales: '销售合同',
        purchase: '采购合同',
        service: '服务合同',
        labor: '劳动合同',
        other: '其他'
    };
    return map[type] || '未知类型';
};

const handleSearch = () => {
  // 实际项目中可能触发后端搜索，这里仅依赖 computed 过滤
};

const showAddModal = () => {
  modalTitle.value = '新增模板';
  formState.id = '';
  formState.name = '';
  formState.type = undefined;
  formState.description = '';
  formState.status = 'active';
  formState.fileName = '';
  fileList.value = [];
  modalVisible.value = true;
};

const handleEdit = (record: TemplateItem) => {
  modalTitle.value = '编辑模板';
  formState.id = record.id;
  formState.name = record.name;
  formState.type = record.type;
  formState.description = record.description;
  formState.status = record.status;
  formState.fileName = record.fileName;
  fileList.value = []; // 编辑时暂不回显文件列表，除非需要重新上传
  modalVisible.value = true;
};

const handleDelete = (id: string) => {
  dataSource.value = dataSource.value.filter(item => item.id !== id);
  message.success('模板删除成功');
};

const handlePreview = (record: TemplateItem) => {
    previewData.value = record;
    previewVisible.value = true;
};

const handleModalOk = () => {
  formRef.value.validate().then(() => {
      // 如果是新增且没有文件
      if (!formState.id && !formState.fileName && fileList.value.length === 0) {
           message.warning('请上传模板文件');
           return;
      }
      
      modalLoading.value = true;
      
      // 模拟异步请求
      setTimeout(() => {
        if (formState.id) {
          // 编辑
          const index = dataSource.value.findIndex(item => item.id === formState.id);
          if (index !== -1) {
            dataSource.value[index] = {
              ...dataSource.value[index],
              name: formState.name,
              type: formState.type!,
              description: formState.description,
              status: formState.status as 'active' | 'inactive',
              updatedAt: new Date().toLocaleString(),
              fileName: formState.fileName || dataSource.value[index].fileName // 如果没上传新文件保持原样
            };
          }
          message.success('模板更新成功');
        } else {
          // 新增
          const newItem: TemplateItem = {
            id: Date.now().toString(),
            name: formState.name,
            type: formState.type!,
            description: formState.description,
            status: formState.status as 'active' | 'inactive',
            updatedAt: new Date().toLocaleString(),
            fileName: formState.fileName || (fileList.value[0] as any)?.name
          };
          dataSource.value.unshift(newItem);
          message.success('模板新增成功');
        }
        
        modalLoading.value = false;
        modalVisible.value = false;
      }, 1000);
  });
};

const handleFileChange = (info: UploadChangeParam) => {
  const status = info.file.status;
  if (status === 'done') {
    message.success(`${info.file.name} 文件上传成功.`);
    formState.fileName = info.file.name;
  } else if (status === 'error') {
    // 这里的 mock 接口可能会失败，我们在 beforeUpload 里模拟成功或者直接忽略错误
    // 实际项目中根据接口返回处理
    // message.error(`${info.file.name} 文件上传失败.`);
    
    // 即使上传接口失败，演示时我们也假装成功获取文件名
     formState.fileName = info.file.name;
  }
};

const beforeUpload: UploadProps['beforeUpload'] = file => {
    // 简单模拟，直接设置为文件列表
    fileList.value = [file] as any;
    formState.fileName = file.name;
    return false; // 阻止自动上传，实际项目中可能需要为 true
};

</script>

<style scoped>
.contract-template-container {
  background: #fff;
  padding: 24px;
  min-height: 100%;
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
