<template>
  <div class="product-docs-layout" @click="closeContextMenu">
    <div class="left-panel">
      <div class="panel-header">
        <span class="title">资料目录</span>
        <div class="actions">
           <a-dropdown trigger="click">
              <a-button size="small" type="text"><PlusOutlined /></a-button>
              <template #overlay>
                <a-menu>
                  <a-menu-item @click="showCreateFolder">新建文件夹</a-menu-item>
                  <a-menu-item @click="showUploadFile">上传文件</a-menu-item>
                </a-menu>
              </template>
           </a-dropdown>
        </div>
      </div>
      <div class="tree-container">
          <a-tree
            v-if="documents.length"
            :tree-data="documents"
            :field-names="{ children: 'children', title: 'title', key: 'id' }"
            block-node
            @select="onSelect"
            @rightClick="onRightClick"
            v-model:expandedKeys="expandedKeys"
          >
            <template #title="{ title, type }">
                <span class="tree-node-title">
                    <FolderOutlined v-if="type === 'folder'" style="margin-right: 4px; color: #faad14;" />
                    <component 
                        v-else 
                        :is="getFileIconInfo(title).icon" 
                        :style="{ marginRight: '4px', color: getFileIconInfo(title).color }" 
                    />
                    {{ title }}
                </span>
            </template>
          </a-tree>
          <div v-else class="empty-tree">
            <a-spin size="small" />
          </div>
      </div>
    </div>
    <div class="right-panel">
        <iframe 
            v-if="selectedFile && selectedFile.type === 'file'"
            :src="previewUrl"
            class="preview-iframe"
            frameborder="0"
        ></iframe>
        <div v-else class="empty-preview">
            <div v-if="selectedFile && selectedFile.type === 'folder'" style="text-align: center;">
                <FolderOpenOutlined style="font-size: 64px; color: #1890ff; margin-bottom: 16px;" />
                <p style="font-size: 16px; color: #666;">{{ selectedFile.title }}</p>
                <p style="color: #999;">请选择文件夹内的文件进行预览</p>
            </div>
            <div v-else style="text-align: center;">
                <FileSearchOutlined style="font-size: 64px; color: #d9d9d9; margin-bottom: 16px;" />
                <p style="color: #999;">选择左侧文件进行预览</p>
            </div>
        </div>
    </div>
  </div>

  <!-- Context Menu -->
  <div 
      v-if="contextMenuVisible" 
      class="context-menu" 
      :style="{ left: contextMenuLeft + 'px', top: contextMenuTop + 'px' }"
      @click.stop
    >
      <div class="menu-item" @click="handleRename">重命名</div>
      <div class="menu-item" @click="showMoveModal">移动到...</div>
      <div class="menu-item delete" @click="handleDelete">删除</div>
  </div>

  <!-- Create Folder Modal -->
  <a-modal v-model:open="createFolderVisible" title="新建文件夹" @ok="handleCreateFolder">
      <a-form layout="vertical">
        <a-form-item label="文件夹名称" required>
            <a-input v-model:value="newFolderName" placeholder="请输入文件夹名称" @pressEnter="handleCreateFolder" />
        </a-form-item>
      </a-form>
  </a-modal>

  <!-- Upload File Modal -->
  <a-modal v-model:open="uploadFileVisible" title="上传文件" :footer="null">
      <a-upload-dragger
        name="file"
        :multiple="true"
        :customRequest="customUploadRequest"
        :showUploadList="false"
      >
        <p class="ant-upload-drag-icon">
          <inbox-outlined />
        </p>
        <p class="ant-upload-text">点击或拖拽文件到此区域上传</p>
        <p class="ant-upload-hint">
          支持单个或批量上传。
        </p>
      </a-upload-dragger>
  </a-modal>

  <!-- Rename Modal -->
  <a-modal v-model:open="renameVisible" title="重命名" @ok="confirmRename">
      <a-form layout="vertical">
        <a-form-item label="名称" required>
            <a-input v-model:value="renameValue" @pressEnter="confirmRename" />
        </a-form-item>
      </a-form>
  </a-modal>

  <!-- Move Modal -->
  <a-modal v-model:open="moveVisible" title="移动到" @ok="confirmMove">
      <a-tree-select
          v-model:value="moveTargetId"
          style="width: 100%"
          :dropdown-style="{ maxHeight: '400px', overflow: 'auto' }"
          :tree-data="folderTree"
          placeholder="请选择目标文件夹"
          tree-default-expand-all
          :field-names="{ children: 'children', label: 'title', value: 'id' }"
          allow-clear
      />
  </a-modal>
</template>

<script setup lang="ts">
import { ref, onMounted, computed, createVNode } from 'vue';
import { 
    FolderOutlined, FileOutlined, PlusOutlined, 
    FolderOpenOutlined, FileSearchOutlined, InboxOutlined,
    ExclamationCircleOutlined,
    FilePdfOutlined, FileWordOutlined, FileExcelOutlined,
    FilePptOutlined, FileImageOutlined, FileTextOutlined,
    FileZipOutlined, FileMarkdownOutlined, FileUnknownOutlined
} from '@ant-design/icons-vue';
import type { ProductDocDto } from '@/api/sales';
import { 
    getProductDocs, createProductDoc, uploadProductDoc, 
    deleteProductDoc, renameProductDoc, moveProductDoc 
} from '@/api/sales';
import { message, Modal } from 'ant-design-vue';

const documents = ref<ProductDocDto[]>([]);
const expandedKeys = ref<string[]>([]);
const selectedFile = ref<ProductDocDto | null>(null);

const previewUrl = computed(() => {
    if (!selectedFile.value || !selectedFile.value.url) return '';
    
    // Construct full URL if it's relative
    let fileUrl = selectedFile.value.url;
    if (fileUrl.startsWith('/')) {
        fileUrl = `${window.location.origin}${fileUrl}`;
    }
    
    const encodedUrl = window.btoa(fileUrl);
    let url = `https://kkview.dingzhi.info/onlinePreview?url=${encodedUrl}`;
    
    const ext = selectedFile.value.title.split('.').pop()?.toLowerCase();
    if (['doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'].includes(ext || '')) {
        url += '&officePreviewType=pdf';
    }
    
    return url;
});

const getFileIconInfo = (filename: string) => {
    if (!filename) return { icon: FileUnknownOutlined, color: '#999' };
    const ext = filename.split('.').pop()?.toLowerCase();
    switch (ext) {
        case 'pdf': return { icon: FilePdfOutlined, color: '#ff4d4f' };
        case 'doc':
        case 'docx': return { icon: FileWordOutlined, color: '#1890ff' };
        case 'xls':
        case 'xlsx': return { icon: FileExcelOutlined, color: '#52c41a' };
        case 'ppt':
        case 'pptx': return { icon: FilePptOutlined, color: '#fa8c16' };
        case 'jpg':
        case 'jpeg':
        case 'png':
        case 'gif':
        case 'bmp':
        case 'svg': return { icon: FileImageOutlined, color: '#13c2c2' };
        case 'txt': return { icon: FileTextOutlined, color: '#666' };
        case 'zip':
        case 'rar':
        case '7z':
        case 'tar':
        case 'gz': return { icon: FileZipOutlined, color: '#722ed1' };
        case 'md': return { icon: FileMarkdownOutlined, color: '#000' };
        default: return { icon: FileOutlined, color: '#666' };
    }
};

const loadData = async () => {
    try {
        const res = await getProductDocs();
        documents.value = res || [];
        // Expand root nodes by default if needed, or keep existing
        if (expandedKeys.value.length === 0) {
            expandedKeys.value = documents.value.map(d => d.id);
        }
    } catch (e) {
        console.error('Failed to load docs:', e);
    }
};

const onSelect = (selectedKeys: string[], info: any) => {
    if (selectedKeys.length && info.node) {
        // Prefer dataRef if available (standard in AntD Vue for treeData)
        selectedFile.value = info.node.dataRef || info.node;
    } else {
        selectedFile.value = null;
    }
};

// Context Menu
const contextMenuVisible = ref(false);
const contextMenuLeft = ref(0);
const contextMenuTop = ref(0);
const contextNode = ref<ProductDocDto | null>(null);

const onRightClick = ({ event, node }: any) => {
    // Select the node on right click
    // selectedFile.value = node.dataRef || node; // Optional: select on right click
    contextNode.value = node.dataRef || node;
    contextMenuLeft.value = event.clientX;
    contextMenuTop.value = event.clientY;
    contextMenuVisible.value = true;
};

const closeContextMenu = () => {
    contextMenuVisible.value = false;
};

// Rename
const renameVisible = ref(false);
const renameValue = ref('');

const handleRename = () => {
    if (!contextNode.value) return;
    renameValue.value = contextNode.value.title;
    renameVisible.value = true;
    closeContextMenu();
};

const confirmRename = async () => {
    if (!renameValue.value) {
        message.warning('请输入名称');
        return;
    }
    try {
        await renameProductDoc(contextNode.value!.id, renameValue.value);
        message.success('重命名成功');
        renameVisible.value = false;
        loadData();
    } catch (e) {
        message.error('重命名失败');
    }
};

// Move
const moveVisible = ref(false);
const moveTargetId = ref<string | undefined>(undefined);

// Filter tree to only show folders for move target
const filterFolders = (nodes: ProductDocDto[]): ProductDocDto[] => {
    return nodes
        .filter(n => n.type === 'folder')
        .map(n => ({
            ...n,
            children: n.children ? filterFolders(n.children) : []
        }));
};

const folderTree = computed(() => filterFolders(documents.value));

const showMoveModal = () => {
    moveTargetId.value = undefined;
    moveVisible.value = true;
    closeContextMenu();
};

const confirmMove = async () => {
    if (!contextNode.value) return;
    try {
        await moveProductDoc(contextNode.value.id, moveTargetId.value);
        message.success('移动成功');
        moveVisible.value = false;
        loadData();
    } catch (e) {
        message.error('移动失败');
    }
};

// Delete
const handleDelete = () => {
    if (!contextNode.value) return;
    closeContextMenu();
    Modal.confirm({
        title: '确认删除',
        icon: createVNode(ExclamationCircleOutlined),
        content: `确定要删除 "${contextNode.value.title}" 吗？删除后无法恢复。`,
        okText: '确认',
        cancelText: '取消',
        onOk: async () => {
            try {
                await deleteProductDoc(contextNode.value!.id);
                message.success('删除成功');
                if (selectedFile.value?.id === contextNode.value!.id) {
                    selectedFile.value = null;
                }
                loadData();
            } catch (e) {
                message.error('删除失败');
            }
        }
    });
};

// Create Folder
const createFolderVisible = ref(false);
const newFolderName = ref('');
const showCreateFolder = () => {
    newFolderName.value = '';
    createFolderVisible.value = true;
};
const handleCreateFolder = async () => {
    if (!newFolderName.value) {
        message.warning('请输入文件夹名称');
        return;
    }
    try {
        await createProductDoc({
            title: newFolderName.value,
            type: 'folder',
            parentId: selectedFile.value?.type === 'folder' ? selectedFile.value.id : undefined
        });
        message.success('文件夹创建成功');
        createFolderVisible.value = false;
        loadData();
    } catch(e) {
        message.error('创建失败');
    }
};

// Upload File
const uploadFileVisible = ref(false);
const showUploadFile = () => {
    uploadFileVisible.value = true;
};

const customUploadRequest = async (options: any) => {
    const { file, onSuccess, onError } = options;
    try {
        const parentId = selectedFile.value?.type === 'folder' ? selectedFile.value.id : undefined;
        await uploadProductDoc(file, parentId);
        message.success(`${file.name} 上传成功`);
        onSuccess(null, file);
        uploadFileVisible.value = false;
        loadData();
    } catch (e) {
        console.error(e);
        message.error(`${file.name} 上传失败`);
        onError(e);
    }
};

onMounted(loadData);
</script>

<style scoped>
.product-docs-layout {
  display: flex;
  height: 100%; /* Ensure it takes full height of container */
  min-height: 500px;
  border: 1px solid #f0f0f0;
  background: #fff;
}

.left-panel {
  width: 250px;
  border-right: 1px solid #f0f0f0;
  display: flex;
  flex-direction: column;
  background: #fafafa;
}

.panel-header {
  padding: 12px 16px;
  border-bottom: 1px solid #f0f0f0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #fff;
}

.panel-header .title {
    font-weight: 500;
}

.tree-container {
  flex: 1;
  overflow-y: auto;
  padding: 8px 0;
}

.empty-tree {
    display: flex;
    justify-content: center;
    padding-top: 20px;
}

.right-panel {
  flex: 1;
  display: flex;
  flex-direction: column;
  background: #fff;
}

.preview-iframe {
    width: 100%;
    height: 100%;
    border: none;
}

.empty-preview {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    background: #fbfbfb;
}

.context-menu {
  position: fixed;
  background: #fff;
  border: 1px solid #f0f0f0;
  box-shadow: 0 2px 8px rgba(0,0,0,0.15);
  border-radius: 4px;
  z-index: 1000;
  padding: 4px 0;
  min-width: 120px;
}
.menu-item {
  padding: 8px 12px;
  cursor: pointer;
  transition: all 0.3s;
  font-size: 14px;
  color: #333;
}
.menu-item:hover {
  background: #f5f5f5;
}
.menu-item.delete {
  color: #ff4d4f;
}
</style>