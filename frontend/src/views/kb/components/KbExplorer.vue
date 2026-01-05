<template>
  <div class="explorer-layout">
    <div class="main-header">
      <div class="breadcrumb-area">
        <a-breadcrumb>
          <a-breadcrumb-item>知识库</a-breadcrumb-item>
          <a-breadcrumb-item v-if="currentKb">{{ currentKb?.name }}</a-breadcrumb-item>
          <a-breadcrumb-item v-for="(item, index) in breadcrumbs" :key="item.id || 'root'">
            <a v-if="index < breadcrumbs.length - 1" @click.prevent="handleBreadcrumbClick(item, index)">{{ item.name }}</a>
            <span v-else>{{ item.name }}</span>
          </a-breadcrumb-item>
        </a-breadcrumb>
      </div>
      <div class="header-actions">
        <a-dropdown trigger="hover" :arrow="true" placement="bottomRight">
          <a-button>
            <EllipsisOutlined />
          </a-button>
          <template #overlay>
            <div style="background: #fff; box-shadow: 0 2px 8px rgba(0,0,0,0.15); border-radius: 4px; padding: 4px 0;">
              <div style="padding: 8px 12px; border-bottom: 1px solid #f0f0f0;" @click.stop @keydown.stop>
                <a-input-search
                  v-model:value="fileSearchText"
                  placeholder="搜索文件"
                  size="small"
                  style="width: 100%"
                  :allowClear="true"
                />
              </div>
              <a-menu style="border: none; box-shadow: none;" :selectable="false">
                <a-menu-item key="view-grid" @click="viewMode = 'grid'">
                  <AppstoreOutlined /> 网格视图
                  <CheckOutlined v-if="viewMode === 'grid'" style="margin-left: 8px" />
                </a-menu-item>
                <a-menu-item key="view-list" @click="viewMode = 'list'">
                  <BarsOutlined /> 列表视图
                  <CheckOutlined v-if="viewMode === 'list'" style="margin-left: 8px" />
                </a-menu-item>
                <a-menu-divider />
                <a-menu-item key="upload" v-if="isAdmin" @click="triggerUpload">
                  <CloudUploadOutlined /> 上传文件
                </a-menu-item>
                <a-menu-item key="new-folder" v-if="isAdmin" @click="openNewFolderModal">
                  <FolderAddOutlined /> 新建文件夹
                </a-menu-item>
                <a-menu-divider v-if="isAdmin" />
                <a-menu-item key="refresh" @click="refreshFileList">
                  <ReloadOutlined /> 刷新
                </a-menu-item>
              </a-menu>
            </div>
          </template>
        </a-dropdown>
      </div>
    </div>
    <div class="file-explorer" @dragenter.prevent="handleDragEnter" @dragleave.prevent="handleDragLeave" @dragover.prevent @drop.prevent="handleDrop">
      <a-upload-dragger
        v-if="isDragOverlayVisible"
        :fileList="fileList"
        @update:fileList="fileList = $event"
        name="file"
        :multiple="true"
        :customRequest="customUpload"
        :showUploadList="false"
        class="upload-overlay"
      >
        <p class="ant-upload-drag-icon">
          <InboxOutlined />
        </p>
        <p class="ant-upload-text">释放文件到此处上传</p>
        <p class="ant-upload-hint">支持 PDF, Word, Markdown, TXT, 图片等格式</p>
      </a-upload-dragger>
    
      <div class="file-list-container">
        <!-- Empty State -->
        <a-empty v-if="filteredFiles.length === 0" description="暂无文件" style="margin-top: 100px" />

        <!-- Grid View -->
        <div v-else-if="viewMode === 'grid'" class="file-grid">
          <div
            v-for="file in filteredFiles"
            :key="file.id"
            class="file-card"
            :class="{ active: selectedFiles.includes(file.id) }"
            @click="handleSelectFile(file, $event)"
            @dblclick="file.isFolder ? handleFolderClick(file) : viewFile(file)"
            @contextmenu.prevent="handleContextMenu($event)"
          >
            <div class="file-icon">
              <component :is="getFileIcon(getFileType(file))" :style="{ color: getFileColor(getFileType(file)) }" />
            </div>
            <div class="file-name" :title="file.name">
                {{ file.name }}
            </div>
            <div class="file-meta">{{ file.size }}</div>
          </div>
        </div>

        <!-- List View -->
        <div v-else class="file-list-view">
          <a-table 
            :columns="fileColumns" 
            :data-source="filteredFiles" 
            :pagination="false"
            rowKey="id"
            :row-selection="{ selectedRowKeys: selectedFiles, onChange: onSelectChange }"
            @customRow="customRow"
          >
            <template #bodyCell="{ column, record }">
              <template v-if="column.key === 'name'">
                <div class="list-name-cell" @dblclick="record.isFolder ? handleFolderClick(record) : viewFile(record)">
                  <component :is="getFileIcon(getFileType(record))" :style="{ color: getFileColor(getFileType(record)), marginRight: '8px', fontSize: '18px', flexShrink: 0 }" />
                  <a-tooltip :title="record.name" placement="topLeft">
                    <span class="file-name-text">{{ record.name }}</span>
                  </a-tooltip>
                </div>
              </template>
              <template v-else-if="column.key === 'status'">
                <span v-if="record.isFolder">-</span>
                <a-tag v-else :color="getStatusColor(record.status)">
                  <template #icon>
                    <SyncOutlined v-if="record.status === 'processing'" spin />
                    <CheckCircleOutlined v-if="record.status === 'ready'" />
                    <ExclamationCircleOutlined v-if="record.status === 'error'" />
                  </template>
                  {{ getStatusText(record.status) }}
                </a-tag>
              </template>
              <template v-else-if="column.key === 'action'">
                <a-dropdown trigger="click" @click.stop>
                  <a-button type="text" size="small"><EllipsisOutlined /></a-button>
                  <template #overlay>
                    <a-menu>
                      <a-menu-item key="view" v-if="!record.isFolder" @click="viewFile(record)">查看</a-menu-item>
                      <a-menu-item key="download" v-if="!record.isFolder" @click="downloadFile(record)">下载</a-menu-item>
                      <template v-if="isAdmin">
                        <a-menu-divider v-if="!record.isFolder" />
                        <a-menu-item key="rename" @click="openRenameModal(record)">重命名</a-menu-item>
                        <a-menu-item key="move" @click="openMoveModal(record)">移动</a-menu-item>
                        <a-menu-divider />
                        <a-menu-item key="delete" danger @click="deleteFile(record.id)">删除</a-menu-item>
                      </template>
                    </a-menu>
                  </template>
                </a-dropdown>
              </template>
            </template>
          </a-table>
        </div>
      </div>
    </div>
    <a-modal v-model:open="isRenameModalVisible" title="重命名" @ok="handleRename">
      <a-input v-model:value="renameName" placeholder="请输入新名称" @pressEnter="handleRename" />
    </a-modal>
    <a-modal v-model:open="isNewFolderVisible" title="新建文件夹" @ok="handleCreateFolder">
      <a-input v-model:value="newFolderName" placeholder="请输入文件夹名称" @pressEnter="handleCreateFolder" />
    </a-modal>
    <a-modal v-model:open="isMoveModalVisible" title="移动文件" @ok="handleMove">
      <a-tree-select
        v-model:value="targetFolderId"
        style="width: 100%"
        :dropdown-style="{ maxHeight: '400px', overflow: 'auto' }"
        :tree-data="folderTreeData"
        placeholder="请选择目标文件夹"
        tree-default-expand-all
      />
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue';
import { message, Modal } from 'ant-design-vue';
import { 
  InboxOutlined,
  EllipsisOutlined,
  AppstoreOutlined,
  BarsOutlined,
  CheckOutlined,
  CloudUploadOutlined,
  FolderAddOutlined,
  ReloadOutlined,
  FileTextOutlined,
  SyncOutlined,
  CheckCircleOutlined,
  ExclamationCircleOutlined,
  FolderOutlined,
  FileImageOutlined,
  FilePdfOutlined,
  FileWordOutlined,
  FileExcelOutlined,
  FilePptOutlined,
  FileZipOutlined,
  FileUnknownOutlined
} from '@ant-design/icons-vue';
import type { KbFileDto, KbInfoDto } from '@/types/kb';
import { 
  getKbFiles, 
  uploadKbFile, 
  deleteKbFile, 
  renameKbFile, 
  moveKbFile, 
  createKbFolder, 
  getKbFolders,
  getKbFileDownloadUrl
} from '@/api/kb';
import type { TreeSelectProps } from 'ant-design-vue';
import { usePermissionStore } from '@/stores/permission';

const props = defineProps<{ currentKb: KbInfoDto | null }>();

const permissionStore = usePermissionStore();
const isAdmin = computed(() => permissionStore.hasPermission('KBAdmin'));

// Helper Functions
const getFileType = (file: KbFileDto): string => {
  if (file.isFolder) return 'folder';
  const name = file.name.toLowerCase();
  if (name.endsWith('.jpg') || name.endsWith('.jpeg') || name.endsWith('.png') || name.endsWith('.gif') || name.endsWith('.bmp')) return 'image';
  if (name.endsWith('.pdf')) return 'pdf';
  if (name.endsWith('.doc') || name.endsWith('.docx')) return 'word';
  if (name.endsWith('.xls') || name.endsWith('.xlsx')) return 'excel';
  if (name.endsWith('.ppt') || name.endsWith('.pptx')) return 'ppt';
  if (name.endsWith('.txt') || name.endsWith('.md') || name.endsWith('.json') || name.endsWith('.xml')) return 'text';
  if (name.endsWith('.zip') || name.endsWith('.rar') || name.endsWith('.7z') || name.endsWith('.tar') || name.endsWith('.gz')) return 'zip';
  return 'unknown';
};

const getFileIcon = (type: string) => {
  switch (type) {
    case 'folder': return FolderOutlined;
    case 'image': return FileImageOutlined;
    case 'pdf': return FilePdfOutlined;
    case 'word': return FileWordOutlined;
    case 'excel': return FileExcelOutlined;
    case 'ppt': return FilePptOutlined;
    case 'text': return FileTextOutlined;
    case 'zip': return FileZipOutlined;
    default: return FileUnknownOutlined;
  }
};

const getFileColor = (type: string) => {
  switch (type) {
    case 'folder': return '#ffec3d';
    case 'image': return '#ff4d4f';
    case 'pdf': return '#ff4d4f';
    case 'word': return '#1890ff';
    case 'excel': return '#52c41a';
    case 'ppt': return '#fa8c16';
    case 'zip': return '#722ed1';
    default: return '#8c8c8c';
  }
};

const getStatusColor = (status: string) => {
  switch (status) {
    case 'processing': return 'processing';
    case 'ready': return 'success';
    case 'error': return 'error';
    default: return 'default';
  }
};

const getStatusText = (status: string) => {
  switch (status) {
    case 'processing': return 'AI处理中';
    case 'ready': return '就绪';
    case 'error': return '失败';
    default: return '上传中';
  }
};

const fileColumns = [
  { title: '名称', dataIndex: 'name', key: 'name', ellipsis: true, sorter: (a: KbFileDto, b: KbFileDto) => a.name.localeCompare(b.name) },
  { title: '大小', align: 'right', dataIndex: 'size', key: 'size', width: 100, ellipsis: true },
  { title: '上传时间', align: 'center', dataIndex: 'uploadTime', key: 'uploadTime', width: 150, ellipsis: true },
  { title: '状态', key: 'status', width: 100, align: 'center' },
  { title: '操作', key: 'action', width: 60, align: 'center' },
];

const breadcrumbs = ref<{ id: string | null; name: string }[]>([{ id: null, name: '根目录' }]);
const files = ref<KbFileDto[]>([]);
const viewMode = ref<'grid' | 'list'>('list');
const fileSearchText = ref('');
const selectedFiles = ref<string[]>([]);
const isDragOverlayVisible = ref(false);
const dragCounter = ref(0);
const fileList = ref<any[]>([]);
const isRenameModalVisible = ref(false);
const isMoveModalVisible = ref(false);
const renameTarget = ref<KbFileDto | null>(null);
const moveTarget = ref<KbFileDto | null>(null);
const renameName = ref('');
const pollInterval = ref<number | null>(null);
const targetFolderId = ref<string | undefined>(undefined);
const isNewFolderVisible = ref(false);
const newFolderName = ref('');
const currentFolderId = ref<string | null>(null);
const folderTreeData = ref<TreeSelectProps['treeData']>([]);

const filteredFiles = computed(() => {
  let list = files.value;
  if (currentFolderId.value) {
    list = list.filter(f => f.parentId === currentFolderId.value);
  } else {
    list = list.filter(f => !f.parentId);
  }
  if (!fileSearchText.value) return list;
  return list.filter(f => f.name.toLowerCase().includes(fileSearchText.value.toLowerCase()));
});

const fetchFiles = async (kbId: string) => {
  try {
    const res = await getKbFiles(kbId);
    files.value = res;
    const processingFiles = res.filter(f => f.status === 'processing');
    if (processingFiles.length > 0) startPolling(kbId); else stopPolling();
  } catch {
    message.error('获取文件列表失败');
  }
};

const startPolling = (kbId: string) => {
  if (pollInterval.value) return;
  pollInterval.value = window.setInterval(() => fetchFiles(kbId), 5000);
};

const stopPolling = () => {
  if (pollInterval.value) {
    clearInterval(pollInterval.value);
    pollInterval.value = null;
  }
};

watch(() => props.currentKb, (kb) => {
  if (kb) {
    fetchFiles(kb.id);
    currentFolderId.value = null;
    breadcrumbs.value = [{ id: null, name: '根目录' }];
  } else {
    files.value = [];
  }
}, { immediate: true });

const handleSelectFile = (file: KbFileDto, event: MouseEvent) => {
  let newSelected: string[] = [];
  if (event.ctrlKey || event.metaKey) {
    const index = selectedFiles.value.indexOf(file.id);
    if (index > -1) {
      newSelected = [...selectedFiles.value];
      newSelected.splice(index, 1);
    } else {
      newSelected = [...selectedFiles.value, file.id];
    }
  } else {
    newSelected = [file.id];
  }
  selectedFiles.value = newSelected;
};

const onSelectChange = (keys: string[]) => {
  selectedFiles.value = keys;
};

const customRow = (record: KbFileDto) => {
  return {
    onDblclick: () => record.isFolder ? handleFolderClick(record) : viewFile(record),
    onContextmenu: (e: MouseEvent) => handleContextMenu(e, record)
  };
};

const handleContextMenu = (e: MouseEvent, _record?: KbFileDto) => { e.preventDefault(); };

const triggerUpload = () => {
  const input = document.querySelector('.ant-upload-drag-icon + input') as HTMLInputElement;
  if (input) input.click();
};

const customUpload = async (options: any) => {
  const { file, onSuccess, onError } = options;
  if (!props.currentKb) return;
  try {
    await uploadKbFile(props.currentKb.id, file as File, currentFolderId.value || undefined);
    message.success(`${file.name} 上传成功`);
    onSuccess(true);
    fetchFiles(props.currentKb.id);
  } catch (error) {
    message.error(`${file.name} 上传失败`);
    onError(error);
  }
};

const viewFile = (file: KbFileDto) => {
  message.info(`预览文件: ${file.name}`);
};

const downloadFile = (file: KbFileDto) => {
  const url = getKbFileDownloadUrl(file.id);
  window.open(url, '_blank');
};

const openRenameModal = (file: KbFileDto) => {
  renameTarget.value = file;
  renameName.value = file.name;
  isRenameModalVisible.value = true;
};

const handleRename = async () => {
  if (!renameTarget.value || !renameName.value) return;
  try {
    await renameKbFile(renameTarget.value.id, renameName.value);
    message.success('重命名成功');
    isRenameModalVisible.value = false;
    if (props.currentKb) fetchFiles(props.currentKb.id);
  } catch {
    message.error('重命名失败');
  }
};

const openMoveModal = async (file: KbFileDto) => {
  moveTarget.value = file;
  if (props.currentKb) {
    const folders = await getKbFolders(props.currentKb.id);
    folderTreeData.value = buildFolderTree(folders, null);
  }
  isMoveModalVisible.value = true;
};

const buildFolderTree = (folders: KbFileDto[], parentId: string | null): any[] => {
  return folders.filter(f => f.parentId === parentId).map(f => ({
    title: f.name, value: f.id, key: f.id, children: buildFolderTree(folders, f.id)
  }));
};

const handleMove = async () => {
  if (!moveTarget.value) return;
  try {
    await moveKbFile(moveTarget.value.id, targetFolderId.value || '');
    message.success('移动成功');
    isMoveModalVisible.value = false;
    if (props.currentKb) fetchFiles(props.currentKb.id);
  } catch {
    message.error('移动失败');
  }
};

const deleteFile = (id: string) => {
  Modal.confirm({
    title: '确认删除',
    content: '确认删除该文件？',
    onOk: async () => {
      try {
        await deleteKbFile(id);
        message.success('删除成功');
        if (props.currentKb) fetchFiles(props.currentKb.id);
      } catch {
        message.error('删除失败');
      }
    }
  });
};

const openNewFolderModal = () => {
  newFolderName.value = '';
  isNewFolderVisible.value = true;
};

const handleCreateFolder = async () => {
  if (!props.currentKb || !newFolderName.value) return;
  try {
    await createKbFolder(props.currentKb.id, {
      name: newFolderName.value,
      parentId: currentFolderId.value || undefined
    });
    message.success('创建成功');
    isNewFolderVisible.value = false;
    fetchFiles(props.currentKb.id);
  } catch {
    message.error('创建失败');
  }
};

const handleFolderClick = (folder: KbFileDto) => {
  currentFolderId.value = folder.id;
  breadcrumbs.value.push({ id: folder.id, name: folder.name });
};

const handleBreadcrumbClick = (item: any, index: number) => {
  currentFolderId.value = item.id;
  breadcrumbs.value = breadcrumbs.value.slice(0, index + 1);
};

const refreshFileList = () => {
  if (props.currentKb) fetchFiles(props.currentKb.id);
};

const handleDragEnter = () => {
  dragCounter.value++;
  isDragOverlayVisible.value = true;
};
const handleDragLeave = () => {
  dragCounter.value--;
  if (dragCounter.value <= 0) {
    isDragOverlayVisible.value = false;
    dragCounter.value = 0;
  }
};
const handleDrop = () => {
  dragCounter.value = 0;
  isDragOverlayVisible.value = false;
};
</script>

<style scoped>
.explorer-layout {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.main-header {
  padding: 12px 16px;
  border-bottom: 1px solid #f0f0f0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #fff;
}

.breadcrumb-area {
  flex: 1;
  overflow: hidden;
}

.header-actions {
  display: flex;
  gap: 8px;
}

.file-explorer {
  flex: 1;
  overflow: hidden;
  position: relative;
  display: flex;
  flex-direction: column;
}

.upload-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(255, 255, 255, 0.9);
  z-index: 10;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  border: 2px dashed #1890ff;
}

.file-list-container {
  flex: 1;
  overflow-y: auto;
  padding: 16px;
}

/* Grid View */
.file-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
  gap: 16px;
}

.file-card {
  border: 1px solid #f0f0f0;
  border-radius: 8px;
  padding: 16px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s;
  background: #fff;
}

.file-card:hover {
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
  transform: translateY(-2px);
}

.file-card.active {
  border-color: #1890ff;
  background: #e6f7ff;
}

.file-icon {
  font-size: 48px;
  margin-bottom: 8px;
}

.file-name {
  font-size: 14px;
  color: #333;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.file-meta {
  font-size: 12px;
  color: #999;
  margin-top: 4px;
}

/* List View */
.file-list-view {
  background: #fff;
}

.list-name-cell {
  display: flex;
  align-items: center;
  cursor: pointer;
}

.file-name-text {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
</style>
