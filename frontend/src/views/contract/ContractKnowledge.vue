<template>
  <div class="knowledge-container">
    <!-- 左侧目录树 -->
    <div class="sidebar">
      <div class="sidebar-header">
        <span class="title">合同知识库</span>
        <a-button type="link" size="small" @click="showCategoryModal('add', null)">
          <template #icon><PlusOutlined /></template>
        </a-button>
      </div>
      
      <div class="tree-container">
        <a-input-search
          v-model:value="searchValue"
          placeholder="搜索文件夹"
          style="margin-bottom: 8px"
        />
        <a-tree
          v-if="treeData && treeData.length > 0"
          :tree-data="treeData"
          :field-names="{ children: 'children', title: 'name', key: 'id' }"
          :default-expanded-keys="expandedKeys"
          :selected-keys="selectedKeys"
          @select="onSelect"
          block-node
          show-icon
        >
          <template #icon="{ expanded }">
             <FolderOpenOutlined v-if="expanded" />
             <FolderOutlined v-else />
          </template>
          <template #title="{ dataRef }">
            <div class="tree-node">
              <span class="node-title">{{ dataRef.name }}</span>
              <span class="node-actions" @click.stop>
                <EditOutlined class="action-icon" @click="showCategoryModal('edit', dataRef)" />
                <DeleteOutlined class="action-icon" @click="handleDeleteCategory(dataRef.id)" />
                <PlusOutlined class="action-icon" @click="showCategoryModal('add', dataRef.id)" />
              </span>
            </div>
          </template>
        </a-tree>
      </div>
    </div>

    <!-- 右侧内容区 -->
    <div class="main-content">
      <div class="content-header">
        <div class="breadcrumb-area">
          <a-breadcrumb>
            <a-breadcrumb-item>合同知识库</a-breadcrumb-item>
            <a-breadcrumb-item v-for="(item, index) in breadcrumbList" :key="index">
              {{ item }}
            </a-breadcrumb-item>
          </a-breadcrumb>
        </div>
        <div class="action-area">
          <a-input-search
            v-model:value="fileSearchValue"
            placeholder="搜索文档"
            style="width: 250px; margin-right: 16px"
            @search="onFileSearch"
          />
          <a-button type="primary" @click="showUploadModal">
            <template #icon><UploadOutlined /></template>
            上传文档
          </a-button>
        </div>
      </div>

      <div class="file-list-container">
        <a-table
          :columns="columns"
          :data-source="fileList"
          :pagination="pagination"
          row-key="id"
        >
          <template #bodyCell="{ column, record }">
            <template v-if="column.key === 'name'">
              <div class="file-name-cell">
                <FilePdfOutlined v-if="record.type === 'pdf'" style="color: #ff4d4f; margin-right: 8px" />
                <FileWordOutlined v-else-if="record.type === 'doc' || record.type === 'docx'" style="color: #1890ff; margin-right: 8px" />
                <FileExcelOutlined v-else-if="record.type === 'xls' || record.type === 'xlsx'" style="color: #52c41a; margin-right: 8px" />
                <FileTextOutlined v-else style="color: #faad14; margin-right: 8px" />
                <span>{{ record.name }}</span>
              </div>
            </template>
            <template v-else-if="column.key === 'action'">
              <a-space>
                <a-tooltip title="预览">
                  <a-button type="text" size="small" @click="viewFile(record)">
                    <template #icon><EyeOutlined /></template>
                  </a-button>
                </a-tooltip>
                <a-tooltip title="下载">
                  <a-button type="text" size="small" @click="downloadFile(record)">
                    <template #icon><DownloadOutlined /></template>
                  </a-button>
                </a-tooltip>
                <a-tooltip title="重命名">
                  <a-button type="text" size="small" @click="showRenameModal(record)">
                    <template #icon><EditOutlined /></template>
                  </a-button>
                </a-tooltip>
                <a-tooltip title="删除">
                  <a-button type="text" danger size="small" @click="deleteFile(record)">
                    <template #icon><DeleteOutlined /></template>
                  </a-button>
                </a-tooltip>
              </a-space>
            </template>
          </template>
        </a-table>
      </div>
    </div>

    <!-- 上传模态框 -->
    <a-modal
      v-model:visible="uploadModalVisible"
      title="上传文档"
      @ok="handleUpload"
      :confirmLoading="uploadLoading"
    >
      <a-form layout="vertical">
        <a-form-item label="选择文件" required>
          <a-upload
            :file-list="uploadFileList"
            :before-upload="beforeUpload"
            @remove="handleRemove"
            :maxCount="1"
          >
            <a-button>
              <UploadOutlined />
              选择文件
            </a-button>
          </a-upload>
        </a-form-item>
        <a-form-item label="文档名称">
          <a-input v-model:value="uploadFileName" placeholder="如果不填则使用文件名" />
        </a-form-item>
      </a-form>
    </a-modal>

    <!-- 重命名模态框 -->
    <a-modal
      v-model:visible="renameModalVisible"
      title="重命名文档"
      @ok="handleRenameSubmit"
      :confirmLoading="renameLoading"
    >
      <a-form layout="vertical">
        <a-form-item label="文档名称" required>
          <a-input v-model:value="renameForm.name" placeholder="请输入新的文档名称" />
        </a-form-item>
      </a-form>
    </a-modal>

    <!-- 分类模态框 -->
    <a-modal
      v-model:visible="categoryModalVisible"
      :title="categoryModalType === 'add' ? '新增目录' : '编辑目录'"
      @ok="handleCategorySubmit"
      :confirmLoading="categoryLoading"
    >
      <a-form layout="vertical">
        <a-form-item label="上级分类">
          <a-tree-select
            v-model:value="categoryForm.parentId"
            :tree-data="treeData"
            :field-names="{ children: 'children', label: 'name', value: 'id' }"
            placeholder="请选择上级分类（留空为根目录）"
            tree-default-expand-all
            allow-clear
            style="width: 100%"
          />
        </a-form-item>
        <a-form-item label="目录名称" required>
          <a-input v-model:value="categoryForm.name" placeholder="请输入目录名称" />
        </a-form-item>
        <a-form-item label="排序">
          <a-input-number v-model:value="categoryForm.sortOrder" style="width: 100%" />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, reactive } from 'vue';
import { message, Modal } from 'ant-design-vue';
import {
  FolderOutlined,
  FolderOpenOutlined,
  FileTextOutlined,
  UploadOutlined,
  EditOutlined,
  DeleteOutlined,
  PlusOutlined,
  FilePdfOutlined,
  FileWordOutlined,
  FileExcelOutlined,
  EyeOutlined,
  DownloadOutlined
} from '@ant-design/icons-vue';
import { 
  getKnowledgeFiles, 
  getKnowledgeCategories, 
  uploadKnowledgeFile, 
  createKnowledgeCategory, 
  updateKnowledgeCategory, 
  deleteKnowledgeCategory, 
  deleteKnowledgeFile, 
  downloadKnowledgeFileUrl, 
  updateKnowledgeFile
} from '@/api/contract';
import type { 
  ContractKnowledgeCategoryDto, 
  ContractKnowledgeFileDto
} from '@/api/contract';

// Rename File Modal
const renameModalVisible = ref(false);
const renameLoading = ref(false);
const renameForm = reactive({
  id: 0,
  name: ''
});

const showRenameModal = (record: any) => {
  renameForm.id = parseInt(record.id);
  // Remove extension for editing if desired, or keep full name
  // Let's keep full name to allow extension change if needed (though backend logic might be strict)
  // Backend logic in UpdateKnowledgeFileAsync handles extension:
  // "Ensure extension is preserved if user didn't provide it"
  // So user can edit just the name part.
  // But let's show full name for clarity.
  renameForm.name = record.name;
  renameModalVisible.value = true;
};

const handleRenameSubmit = async () => {
  if (!renameForm.name) {
    message.warning('请输入文件名称');
    return;
  }
  
  renameLoading.value = true;
  try {
    await updateKnowledgeFile(renameForm.id, { name: renameForm.name });
    message.success('重命名成功');
    renameModalVisible.value = false;
    if (currentCategoryId.value) {
      fetchFiles(currentCategoryId.value);
    }
  } catch (error) {
    console.error(error);
  } finally {
    renameLoading.value = false;
  }
};

// 侧边栏搜索
const searchValue = ref('');
const expandedKeys = ref<number[]>([]);
const selectedKeys = ref<number[]>([]);
const breadcrumbList = ref<string[]>(['法律法规', '民法典']);
const currentCategoryId = ref<number | null>(null);

// 树形数据
const treeData = ref<ContractKnowledgeCategoryDto[]>([]);

const fetchCategories = async () => {
  try {
    const res = await getKnowledgeCategories();
    // Assuming res is the array of categories
    const categories = res as unknown as ContractKnowledgeCategoryDto[];
    if (categories && categories.length > 0) {
       treeData.value = categories;
       
       // Default select first leaf if possible, or just first node
       if (treeData.value && treeData.value.length > 0) {
          const firstNode = treeData.value[0];
          if (firstNode) {
            expandedKeys.value = [firstNode.id];
            // Find first leaf for selection (simplified)
            if (firstNode.children && firstNode.children.length > 0) {
              const firstChild = firstNode.children[0];
              if (firstChild) {
                selectedKeys.value = [firstChild.id];
                currentCategoryId.value = firstChild.id;
                fetchFiles(firstChild.id);
                breadcrumbList.value = [firstNode.name, firstChild.name];
              }
            } else {
              selectedKeys.value = [firstNode.id];
              currentCategoryId.value = firstNode.id;
              fetchFiles(firstNode.id);
              breadcrumbList.value = [firstNode.name];
            }
          }
       }
    } else {
        throw new Error("No categories from API");
    }
  } catch (error) {
     console.error('Failed to fetch categories:', error);
     treeData.value = [];
  }
};

// Category Management
const categoryModalVisible = ref(false);
const categoryLoading = ref(false);
const categoryModalType = ref<'add' | 'edit'>('add');
const categoryIdToEdit = ref<number | null>(null);

const categoryForm = reactive({
  name: '',
  sortOrder: 0,
  parentId: undefined as number | undefined
});

const showCategoryModal = (type: 'add' | 'edit', payload: any) => {
  categoryModalType.value = type;
  categoryForm.name = '';
  categoryForm.sortOrder = 0;
  categoryForm.parentId = undefined;

  if (type === 'add') {
    // If adding child, payload is parentId
    if (payload) {
        categoryForm.parentId = payload;
    }
  } else {
    // If editing, payload is data object
    const data = payload;
    if (data) {
        categoryIdToEdit.value = data.id;
        categoryForm.name = data.name; 
        categoryForm.sortOrder = data.sortOrder || 0;
        if (data.parentId) {
            categoryForm.parentId = data.parentId;
        }
    }
  }
  categoryModalVisible.value = true;
};

const handleCategorySubmit = async () => {
  if (!categoryForm.name) {
    message.warning('请输入目录名称');
    return;
  }

  categoryLoading.value = true;
  try {
    if (categoryModalType.value === 'add') {
      await createKnowledgeCategory({
        name: categoryForm.name,
        parentId: categoryForm.parentId,
        sortOrder: categoryForm.sortOrder
      });
      message.success('创建成功');
    } else {
      await updateKnowledgeCategory(categoryIdToEdit.value!, {
        name: categoryForm.name,
        sortOrder: categoryForm.sortOrder,
        parentId: categoryForm.parentId
      });
      message.success('更新成功');
    }
    categoryModalVisible.value = false;
    fetchCategories();
  } catch (error) {
    console.error(error);
  } finally {
    categoryLoading.value = false;
  }
};

const handleDeleteCategory = (id: number) => {
  if (!id) return;
  
  Modal.confirm({
    title: '确认删除',
    content: '确定要删除该目录吗？删除后无法恢复。',
    onOk: async () => {
      try {
        await deleteKnowledgeCategory(id);
        message.success('删除成功');
        if (currentCategoryId.value === id) {
           currentCategoryId.value = null; 
           selectedKeys.value = [];
        }
        fetchCategories();
      } catch (error) {
        console.error(error);
      }
    }
  });
};

// 文件搜索
const fileSearchValue = ref('');
const onFileSearch = (val: string) => {
  // Current category search not implemented fully in UI logic, but API supports it
  // We need to know current category. 
  // For simplicity, just log or re-fetch if we tracked current category.
  console.log('Search file:', val);
};

// 表格列定义
const columns = [
  {
    title: '文档名称',
    dataIndex: 'name',
    key: 'name',
    width: '40%',
  },
  {
    title: '上传人',
    dataIndex: 'uploader',
    key: 'uploader',
    width: '15%',
  },
  {
    title: '上传时间',
    dataIndex: 'uploadTime',
    key: 'uploadTime',
    width: '20%',
  },
  {
    title: '大小',
    dataIndex: 'size',
    key: 'size',
    width: '10%',
  },
  {
    title: '操作',
    key: 'action',
    width: '15%',
  },
];

// 模拟文件数据
const fileList = ref<any[]>([]);

const fetchFiles = async (categoryId: number, keyword?: string) => {
  try {
    const res = await getKnowledgeFiles(categoryId, keyword);
    if (res) {
      fileList.value = res.map((item: ContractKnowledgeFileDto) => ({
        id: item.id.toString(),
        name: item.name,
        type: item.type,
        uploader: item.uploader || '系统',
        uploadTime: new Date(item.uploadTime).toLocaleString(),
        size: formatFileSize(item.size), // Format bytes to string
        filePath: item.filePath, // Add filePath for preview
      }));
    }
  } catch (error) {
    console.error('Failed to fetch files:', error);
    // Fallback mock data
    fileList.value = [
      {
        id: '1',
        name: '中华人民共和国民法典.pdf',
        type: 'pdf',
        uploader: '系统管理员',
        uploadTime: '2023-01-01 10:00:00',
        size: '5.2 MB',
      },
      {
        id: '2',
        name: '合同审查要点指南.docx',
        type: 'doc',
        uploader: '法务部',
        uploadTime: '2023-05-12 14:30:00',
        size: '1.5 MB',
      },
      {
        id: '3',
        name: '2023年度合同台账模板.xlsx',
        type: 'xls',
        uploader: '财务部',
        uploadTime: '2023-06-20 09:15:00',
        size: '45 KB',
      },
    ];
  }
};

onMounted(() => {
  fetchCategories();
});

const pagination = {
  pageSize: 10,
  showSizeChanger: true,
  showQuickJumper: true,
};

// 树节点选择
const onSelect = (keys: number[], info: any) => {
  console.log('selected', keys, info);
  
  const nodeData = info.node.dataRef;
  
  if (nodeData) {
    // Breadcrumb logic
    const path: string[] = [];
    // Traverse treeData to find path
    const findPath = (nodes: ContractKnowledgeCategoryDto[], targetId: number, currentPath: string[]): boolean => {
       for (const node of nodes) {
          const newPath = [...currentPath, node.name];
          if (node.id === targetId) {
             path.push(...newPath);
             return true;
          }
          if (node.children && node.children.length > 0) {
             if (findPath(node.children, targetId, newPath)) return true;
          }
       }
       return false;
    };
    findPath(treeData.value || [], nodeData.id, []);
    breadcrumbList.value = path;
    
    currentCategoryId.value = nodeData.id;
    fetchFiles(nodeData.id);
    selectedKeys.value = keys;
  }
};

const viewFile = (record: any) => {
  // Preview logic
  // If PDF/Image, open in new tab
  const ext = record.name.split('.').pop()?.toLowerCase();
  const previewTypes = ['pdf', 'png', 'jpg', 'jpeg', 'gif', 'txt'];
  
  if (previewTypes.includes(ext)) {
     // Use static file URL for preview to avoid "attachment" disposition
     // Assuming backend serves wwwroot
     // If filePath starts with "uploads/...", and server base URL handles it
     // But wait, we are in dev mode probably. 
     // If dev server proxies /api, it might not proxy static files unless configured.
     // However, usually "public" or "static" folder works.
     // Let's try to use the API download endpoint but without forcing download if possible.
     // Actually, browser default behavior for PDF is inline if not "attachment".
     // My backend currently returns "File(...)" which might default to attachment if name provided.
     // Let's use the static path if we are sure it works.
     // If record.filePath is "uploads/knowledge/...", then url is "/uploads/knowledge/..."
     // This assumes the frontend dev server proxies requests to backend, or backend is on same origin.
     // In typical Vue setup, we might need a full URL if backend is different port.
     // But let's assume relative path works if proxy is set up.
     
     // Safer bet: use download URL but relying on browser to handle it.
     // If I want to be 100% sure of inline, I should update backend to set Content-Disposition: inline.
     // But user asked for "Preview".
     // Let's try static path first.
     // Backend now returns path starting with / if available, or we handle it.
     let path = record.filePath || '';
     if (path && !path.startsWith('/')) {
        path = '/' + path;
     }
     const url = path || downloadKnowledgeFileUrl(parseInt(record.id));
     window.open(url, '_blank');
  } else {
     message.info('该文件类型不支持在线预览，请下载查看');
  }
};

const downloadFile = (record: any) => {
  const url = downloadKnowledgeFileUrl(parseInt(record.id));
  // Create hidden link to trigger download
  const link = document.createElement('a');
  link.href = url;
  link.download = record.name; // This might be ignored by browser if Content-Disposition is set by server
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
};

const deleteFile = (record: any) => {
  if (!record.id) return;
  
  Modal.confirm({
    title: '确认删除',
    content: `确定要删除文档 "${record.name}" 吗？`,
    onOk: async () => {
      try {
        await deleteKnowledgeFile(parseInt(record.id));
        message.success('删除成功');
        if (currentCategoryId.value) {
           fetchFiles(currentCategoryId.value);
        }
      } catch (error) {
        console.error(error);
      }
    }
  });
};

// --- Upload Logic ---
const uploadModalVisible = ref(false);
const uploadLoading = ref(false);
const uploadFileList = ref<any[]>([]);
const uploadFileName = ref('');

const showUploadModal = () => {
  if (!currentCategoryId.value) {
    message.warning('请先选择一个分类');
    return;
  }
  uploadFileList.value = [];
  uploadFileName.value = '';
  uploadModalVisible.value = true;
};

const beforeUpload = (file: any) => {
  uploadFileList.value = [file];
  if (!uploadFileName.value) {
    uploadFileName.value = file.name;
  }
  return false; // Prevent auto upload
};

const handleRemove = () => {
  uploadFileList.value = [];
  uploadFileName.value = '';
};

const formatFileSize = (bytes: number) => {
    if (bytes === 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
};

const handleUpload = async () => {
  if (uploadFileList.value.length === 0) {
    message.warning('请选择文件');
    return;
  }
  
  if (!currentCategoryId.value) {
    message.error('未选择分类');
    return;
  }

  uploadLoading.value = true;
  try {
    const file = uploadFileList.value[0];
    const formData = new FormData();
    formData.append('file', file);
    formData.append('categoryId', currentCategoryId.value.toString());

    await uploadKnowledgeFile(formData);
    message.success('上传成功');
    uploadModalVisible.value = false;
    fetchFiles(currentCategoryId.value);
  } catch (error) {
    console.error(error);
    message.error('上传失败');
  } finally {
    uploadLoading.value = false;
  }
};
</script>

<style scoped>
.knowledge-container {
  display: flex;
  flex: 1;
  height: 100%;
  width: 100%;
  background-color: #f0f2f5;
  gap: 16px;
  overflow: hidden; /* 防止整体滚动 */
  padding: 16px;
  box-sizing: border-box;
}

.sidebar {
  width: 280px;
  background: #fff;
  border-radius: 4px;
  display: flex;
  flex-direction: column;
  padding: 16px;
  box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.03);
}

.sidebar-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.sidebar-header .title {
  font-weight: 600;
  font-size: 16px;
}

.tree-container {
  flex: 1;
  overflow-y: auto;
}

.tree-node {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex: 1;
  width: 100%;
  min-width: 0;
}

.node-title {
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.node-actions {
  display: none;
  margin-left: 8px;
  flex-shrink: 0;
}

.tree-node:hover .node-actions {
  display: inline-flex;
  align-items: center;
}

.action-icon {
  margin-left: 8px;
  color: #666;
  font-size: 14px;
}

.action-icon:hover {
  color: #1890ff;
}

:deep(.ant-tree-node-content-wrapper) {
  display: flex;
  align-items: center;
  min-height: 36px;
}

:deep(.ant-tree-switcher) {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 36px;
}

:deep(.ant-tree-title) {
  flex: 1;
  overflow: hidden;
  min-width: 0;
}

.main-content {
  flex: 1;
  background: #fff;
  border-radius: 4px;
  display: flex;
  flex-direction: column;
  padding: 24px;
  box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.03);
  overflow: hidden;
}

.content-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  padding-bottom: 16px;
  border-bottom: 1px solid #f0f0f0;
}

.file-list-container {
  flex: 1;
  overflow-y: auto;
}

.file-name-cell {
  display: flex;
  align-items: center;
}

.delete-btn {
  color: #ff4d4f;
}

.delete-btn:hover {
  color: #ff7875;
}

/* 自定义滚动条样式 */
::-webkit-scrollbar {
  width: 6px;
  height: 6px;
}

::-webkit-scrollbar-thumb {
  background: #ccc;
  border-radius: 3px;
}

::-webkit-scrollbar-track {
  background: transparent;
}
</style>