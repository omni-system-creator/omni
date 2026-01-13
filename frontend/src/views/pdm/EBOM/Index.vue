<template>
  <div class="ebom-container">
    <SplitLayout position="left" :initialWidth="280" :minWidth="220" :maxWidth="520">
      <template #sidebar>
        <a-card title="产品结构树" class="tree-card" :bordered="false">
          <template #extra>
            <a-tooltip title="新增产品">
              <a-button type="text" @click="openCreateProductModal">
                <template #icon><PlusOutlined /></template>
              </a-button>
            </a-tooltip>
          </template>
          <div class="card-tools">
            <a-input-search style="margin-bottom: 8px" placeholder="搜索零部件" />
          </div>
          <div class="scroll-panel">
            <a-tree
              :tree-data="(treeData as any)"
              v-model:expanded-keys="expandedKeys"
              :selected-keys="selectedKeys"
              @select="onSelect"
            >
              <template #title="{ title }">
                <span>{{ title }}</span>
              </template>
            </a-tree>
          </div>
        </a-card>
      </template>
      <template #main>
        <a-card title="零部件详情" class="detail-card" :bordered="false">
          <template #extra>
            <a-space>
              <a-button type="primary" @click="openCreateChildModal">新增子件</a-button>
              <a-button>导入EBOM</a-button>
              <a-button>比较差异</a-button>
            </a-space>
          </template>
          <div class="scroll-panel">
            <a-descriptions title="当前节点信息" bordered size="small" style="margin-bottom: 24px">
              <template #extra>
                <a-space>
                  <a-button type="link" size="small" @click="handleEdit">
                    <template #icon><EditOutlined /></template>修改
                  </a-button>
                  <a-button type="link" size="small" danger @click="handleDelete">
                    <template #icon><DeleteOutlined /></template>删除
                  </a-button>
                </a-space>
              </template>
              <a-descriptions-item label="物料编码">{{ currentNode.key || '-' }}</a-descriptions-item>
              <a-descriptions-item label="物料名称">{{ currentNode.title || '-' }}</a-descriptions-item>
              <a-descriptions-item label="规格型号">{{ currentNode.spec || '-' }}</a-descriptions-item>
              <a-descriptions-item label="单位">{{ currentNode.unit || '-' }}</a-descriptions-item>
              <a-descriptions-item label="产品分类">{{ getProductTypeLabel(currentNode.productType) || '-' }}</a-descriptions-item>
              <a-descriptions-item label="版本">{{ currentNode.version || '-' }}</a-descriptions-item>
              <a-descriptions-item label="设计者">{{ currentNode.designer || '-' }}</a-descriptions-item>
              <a-descriptions-item label="状态"><a-badge status="processing" :text="currentNode.status || '设计中'" /></a-descriptions-item>
              <a-descriptions-item label="关联文档">
                <div v-if="currentNode.relatedDocuments && currentNode.relatedDocuments.length">
                  <div v-for="doc in currentNode.relatedDocuments" :key="doc.id">
                    <a :href="doc.path" target="_blank">{{ doc.name }}</a>
                  </div>
                </div>
                <span v-else>-</span>
              </a-descriptions-item>
            </a-descriptions>

            <a-table :columns="columns" :data-source="currentNodeChildren" :pagination="false" size="middle">
              <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'status'">
                  <a-tag :color="record.status === '已归档' ? 'green' : 'blue'">{{ record.status }}</a-tag>
                </template>
                <template v-else-if="column.key === 'action'">
                  <a>编辑</a>
                  <a-divider type="vertical" />
                  <a>查看图纸</a>
                </template>
              </template>
            </a-table>
          </div>
        </a-card>
      </template>
    </SplitLayout>

    <!-- Create Product Modal -->
    <a-modal
      v-model:visible="createModalVisible"
      title="新增产品"
      @ok="handleCreateProduct"
      :confirmLoading="createLoading"
    >
      <a-form :model="createForm" :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }">
        <a-form-item label="产品编码" required>
          <a-input v-model:value="createForm.key" placeholder="例如: PRD-2024xxx" />
        </a-form-item>
        <a-form-item label="产品名称" required>
          <a-input v-model:value="createForm.title" placeholder="请输入产品名称" />
        </a-form-item>
        <a-form-item label="产品分类">
          <a-select v-model:value="createForm.productType" placeholder="请选择产品分类">
            <a-select-option v-for="item in productTypeDict" :key="item.value" :value="item.value">
              {{ item.label }}
            </a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="版本">
          <a-input v-model:value="createForm.version" />
        </a-form-item>
        <a-form-item label="设计者">
          <a-input v-model:value="createForm.designer" />
        </a-form-item>
        <a-form-item label="关联文档">
          <a-upload
            v-model:file-list="fileList"
            :custom-request="customUploadRequest"
            @change="handleUploadChange"
            :multiple="true"
          >
            <a-button>
              <upload-outlined />
              上传文档
            </a-button>
          </a-upload>
        </a-form-item>
        <a-form-item label="规格型号">
          <a-input v-model:value="createForm.spec" />
        </a-form-item>
        <a-form-item label="单位">
          <a-input v-model:value="createForm.unit" />
        </a-form-item>
      </a-form>
    </a-modal>

    <!-- Edit Product Modal -->
    <a-modal
      v-model:visible="editModalVisible"
      title="编辑产品"
      @ok="handleUpdateProduct"
      :confirmLoading="editLoading"
    >
      <a-form :model="editForm" :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }">
        <a-form-item label="产品名称" required>
          <a-input v-model:value="editForm.title" placeholder="请输入产品名称" />
        </a-form-item>
        <a-form-item label="产品分类">
          <a-select v-model:value="editForm.productType" placeholder="请选择产品分类">
            <a-select-option v-for="item in productTypeDict" :key="item.value" :value="item.value">
              {{ item.label }}
            </a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="版本">
          <a-input v-model:value="editForm.version" />
        </a-form-item>
        <a-form-item label="设计者">
          <a-input v-model:value="editForm.designer" />
        </a-form-item>
        <a-form-item label="关联文档">
          <a-upload
            v-model:file-list="fileList"
            :custom-request="customUploadRequest"
            @change="handleUploadChange"
            :multiple="true"
          >
            <a-button>
              <upload-outlined />
              上传文档
            </a-button>
          </a-upload>
        </a-form-item>
        <a-form-item label="规格型号">
          <a-input v-model:value="editForm.spec" />
        </a-form-item>
        <a-form-item label="单位">
          <a-input v-model:value="editForm.unit" />
        </a-form-item>
        <a-form-item label="状态">
          <a-select v-model:value="editForm.status">
            <a-select-option value="设计中">设计中</a-select-option>
            <a-select-option value="已归档">已归档</a-select-option>
          </a-select>
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, reactive, h } from 'vue';
import { message, Modal } from 'ant-design-vue';
import { PlusOutlined, EditOutlined, DeleteOutlined, ExclamationCircleOutlined, UploadOutlined } from '@ant-design/icons-vue';
import type { TreeProps, UploadChangeParam, UploadFile } from 'ant-design-vue';
import type { Key, ColumnType } from 'ant-design-vue/es/table/interface';
import SplitLayout from '@/components/SplitLayout/index.vue';
import { 
  getEbomTrees, initPdmData, createEbomItem, updateEbomItem, deleteEbomItem,
  type EbomItemDto, type CreateEbomItemDto, type UpdateEbomItemDto, type EbomDocumentDto,
  uploadEbomDocument
} from '@/api/pdm';
import { getDictDataByCode, type DictDataDto } from '@/api/dict';

const selectedKeys = ref<Key[]>([]);
const expandedKeys = ref<Key[]>([]);
const treeData = ref<EbomItemDto[]>([]);
const loading = ref(false);

// Common
const fileList = ref<UploadFile[]>([]);

// Create Product State
const createModalVisible = ref(false);
const createLoading = ref(false);
const productTypeDict = ref<DictDataDto[]>([]);
const createForm = reactive<CreateEbomItemDto>({
  key: '',
  title: '',
  spec: 'Standard',
  unit: 'PCS',
  productType: '',
  isLeaf: false,
  parentId: '',
  version: 'V1.0',
  designer: '工程师A',
  relatedDocuments: []
});

// Edit Product State
const editModalVisible = ref(false);
const editLoading = ref(false);
const editForm = reactive<UpdateEbomItemDto>({
  title: '',
  spec: '',
  unit: '',
  productType: '',
  status: '',
  version: '',
  designer: '',
  relatedDocuments: []
});

const loadDicts = async () => {
  try {
    const res = await getDictDataByCode('product_type');
    productTypeDict.value = res || [];
  } catch (error) {
    console.error('Failed to load dicts:', error);
  }
};

const loadData = async () => {
  loading.value = true;
  try {
    await initPdmData();
    const res = await getEbomTrees();
    treeData.value = res;
    
    // Expand root nodes by default
    expandedKeys.value = res.map(node => node.key);
    
    // Select first node if nothing selected
    if (selectedKeys.value.length === 0 && res.length > 0 && res[0]) {
      selectedKeys.value = [res[0].key];
    }
  } finally {
    loading.value = false;
  }
};

onMounted(() => {
  loadData();
  loadDicts();
});

const getProductTypeLabel = (code?: string) => {
  if (!code) return '';
  const found = productTypeDict.value.find(d => d.value === code);
  return found ? found.label : code;
};

const openCreateProductModal = () => {
  createForm.key = '';
  createForm.title = '';
  createForm.spec = 'Standard';
  createForm.unit = 'PCS';
  createForm.productType = '';
  createForm.isLeaf = false;
  createForm.parentId = ''; // Root item
  createForm.version = 'V1.0';
  createForm.designer = '工程师A';
  createForm.relatedDocuments = [];
  fileList.value = [];
  createModalVisible.value = true;
};

const customUploadRequest = async (options: any) => {
  const { file, onSuccess, onError } = options;
  try {
    const res = await uploadEbomDocument(file as File);
    onSuccess(res, file);
  } catch (err) {
    onError(err);
  }
};

const handleUploadChange = (info: UploadChangeParam) => {
  let resFileList = [...info.fileList];
  
  // Update file list with response data
  resFileList = resFileList.map(file => {
    if (file.response) {
      file.url = file.response.path; // Correct download url
    }
    return file;
  });

  fileList.value = resFileList;
};

const getDocumentsFromList = (): EbomDocumentDto[] => {
  return fileList.value.map(file => {
    if (file.originFileObj && file.response) {
        // Newly uploaded
        const resp = file.response as EbomDocumentDto; 
        return {
            id: resp.id,
            name: resp.name,
            path: resp.path,
            fileType: resp.fileType,
            size: resp.size,
            uploadedAt: resp.uploadedAt
        };
    } else {
        // Existing
        return {
            id: Number(file.uid),
            name: file.name,
            path: file.url || '',
            fileType: (file as any).type || file.name.split('.').pop() || '',
            size: file.size || 0,
            uploadedAt: new Date().toISOString()
        };
    }
  });
};

const openCreateChildModal = () => {
  if (!currentNode.value || !currentNode.value.key) {
    message.warning('请先选择父节点');
    return;
  }
  createForm.key = '';
  createForm.title = '';
  createForm.spec = 'Standard';
  createForm.unit = 'PCS';
  createForm.productType = '';
  createForm.isLeaf = true;
  createForm.parentId = currentNode.value.key;
  createForm.version = 'V1.0';
  createForm.designer = '工程师A';
  createForm.relatedDocuments = [];
  fileList.value = [];
  createModalVisible.value = true;
};

const handleCreateProduct = async () => {
  if (!createForm.key || !createForm.title) {
    message.warning('请输入产品编码和名称');
    return;
  }
  
  createLoading.value = true;
  try {
    createForm.relatedDocuments = getDocumentsFromList();
    await createEbomItem(createForm);
    message.success('创建成功');
    createModalVisible.value = false;
    loadData(); // Reload tree
  } catch (error) {
    console.error(error);
  } finally {
    createLoading.value = false;
  }
};

const handleEdit = () => {
  if (!currentNode.value || !currentNode.value.key) {
    message.warning('请选择一个节点');
    return;
  }
  
  editForm.title = currentNode.value.title;
  editForm.spec = currentNode.value.spec || '';
  editForm.unit = currentNode.value.unit || '';
  editForm.productType = currentNode.value.productType || '';
  editForm.status = currentNode.value.status || '设计中';
  editForm.version = currentNode.value.version || '';
  editForm.designer = currentNode.value.designer || '';
  
  // Populate file list
  fileList.value = currentNode.value.relatedDocuments?.map((doc: EbomDocumentDto) => ({
    uid: String(doc.id),
    name: doc.name,
    status: 'done',
    url: doc.path,
    size: doc.size,
    type: doc.fileType
  })) || [];
  
  editModalVisible.value = true;
};

const handleUpdateProduct = async () => {
  if (!currentNode.value || !currentNode.value.key) return;
  
  if (!editForm.title) {
    message.warning('请输入产品名称');
    return;
  }
  
  editLoading.value = true;
  try {
    editForm.relatedDocuments = getDocumentsFromList();
    await updateEbomItem(currentNode.value.key, editForm);
    message.success('更新成功');
    editModalVisible.value = false;
    loadData();
  } catch (error) {
    console.error(error);
  } finally {
    editLoading.value = false;
  }
};

const handleDelete = () => {
  if (!currentNode.value || !currentNode.value.key) {
    message.warning('请选择一个节点');
    return;
  }

  Modal.confirm({
    title: '确认删除',
    icon: () => h(ExclamationCircleOutlined),
    content: `确定要删除 "${currentNode.value.title}" 吗？如果该节点包含子节点，删除将失败。`,
    okText: '确认',
    cancelText: '取消',
    onOk: async () => {
      try {
        await deleteEbomItem(currentNode.value.key);
        message.success('删除成功');
        selectedKeys.value = []; // Clear selection
        loadData();
      } catch (error) {
        console.error(error);
      }
    }
  });
};

const columns: ColumnType[] = [
  { title: '物料编码', dataIndex: 'key', key: 'key' },
  { title: '物料名称', dataIndex: 'title', key: 'title' },
  { title: '规格型号', dataIndex: 'spec', key: 'spec' },
  { title: '数量', dataIndex: 'qty', key: 'qty' },
  { title: '单位', dataIndex: 'unit', key: 'unit' },
  { title: '状态', dataIndex: 'status', key: 'status' },
  { title: '操作', key: 'action' },
];

const flattenData = (data: any[]): any[] => {
  let result: any[] = [];
  data.forEach(item => {
    result.push(item);
    if (item.children) {
      result = result.concat(flattenData(item.children));
    }
  });
  return result;
};

const allNodes = computed(() => flattenData(treeData.value));

const currentNode = computed(() => {
  const key = selectedKeys.value[0];
  if (!key && treeData.value.length > 0) return treeData.value[0];
  return allNodes.value.find(item => item.key === key) || (treeData.value.length > 0 ? treeData.value[0] : {});
});

const currentNodeChildren = computed(() => {
  const node = currentNode.value;
  if (!node || !node.children) return [];
  return node.children;
});

const onSelect: TreeProps['onSelect'] = (keys, _info) => {
  if (keys.length > 0) {
    selectedKeys.value = keys;
  }
};
</script>

<style scoped>
.ebom-container {
  padding: 10px;
  flex: 1;
  overflow: hidden;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
}
.ebom-container :deep(.split-layout) {
  flex: 1;
  width: 100%;
  height: 100%;
  overflow: hidden;
}
.tree-card {
  height: 100%;
  display: flex;
  flex-direction: column;
}
.tree-card :deep(.ant-card-head) {
  padding-right: 12px;
}
.tree-card :deep(.ant-card-body) {
  flex: 1;
  min-height: 0;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  padding: 16px 0 0 16px;
}
.detail-card {
  height: 100%;
  display: flex;
  flex-direction: column;
}
.detail-card :deep(.ant-card-body) {
  flex: 1;
  min-height: 0;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  padding: 16px 0 0 16px;
}
.scroll-panel {
  flex: 1;
  min-height: 0;
  overflow: auto;
}
.card-tools {
  padding-right: 16px;
}
</style>
