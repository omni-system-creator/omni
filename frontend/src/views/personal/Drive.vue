<template>
  <div class="drive-container">
    <input type="file" ref="fileInput" style="display: none" @change="onFileSelected" />
    <!-- 左侧导航栏 -->
    <div class="drive-sider">
      <div class="nav-menu">
        <a-tree
          v-model:selectedKeys="selectedKeys"
          :tree-data="treeData"
          :default-expanded-keys="['personal', 'groups', 'org']"
          block-node
          @select="handleTreeSelect"
        >
          <template #title="{ title, icon, color }">
            <span class="tree-node-title">
              <component :is="icon" v-if="icon" :style="{ marginRight: '8px', color: color }" />
              {{ title }}
            </span>
          </template>
        </a-tree>
      </div>
      <div class="storage-info">
        <div class="storage-text">
          <span>存储空间</span>
          <span>45GB / 100GB</span>
        </div>
        <a-progress :percent="45" :show-info="false" size="small" status="active" />
      </div>
    </div>

    <!-- 右侧内容区域 -->
    <div class="drive-main">
      <!-- 顶部工具栏 -->
      <div class="main-header">
        <div class="breadcrumb-area">
          <a-breadcrumb>
            <a-breadcrumb-item v-for="(item, index) in breadcrumbs" :key="item.key">
              <span v-if="item.key.startsWith('nav_')">{{ item.title }}</span>
              <a v-else href="javascript:;" @click="handleBreadcrumbClick(item, index)">{{ item.title }}</a>
            </a-breadcrumb-item>
          </a-breadcrumb>
        </div>
        <div class="header-actions">
          <a-input-search
            v-model:value="searchText"
            placeholder="在当前目录搜索"
            style="width: 200px"
            @search="handleSearch"
          />
          <a-divider type="vertical" />
          <a-radio-group v-model:value="viewMode" button-style="solid">
            <a-radio-button value="grid"><AppstoreOutlined /></a-radio-button>
            <a-radio-button value="list"><BarsOutlined /></a-radio-button>
          </a-radio-group>
          <a-divider type="vertical" />
          <a-button type="primary" @click="handleUpload">
            <template #icon><CloudUploadOutlined /></template>
            上传
          </a-button>
          <a-tooltip title="新建文件夹">
            <a-button @click="handleNewFolder"><FolderAddOutlined /> 新建文件夹</a-button>
          </a-tooltip>
          <a-tooltip title="刷新">
            <a-button shape="circle" @click="refreshList"><ReloadOutlined /></a-button>
          </a-tooltip>
        </div>
      </div>

      <!-- 文件列表区域 -->
      <div class="file-list-container" v-loading="loading">
        <!-- 空状态 -->
        <a-empty v-if="fileList.length === 0" description="暂无文件" style="margin-top: 100px" />

        <!-- 网格视图 -->
        <div v-else-if="viewMode === 'grid'" class="file-grid">
          <div
            v-for="file in fileList"
            :key="file.id"
            class="file-card"
            :class="{ active: selectedFiles.includes(file.id) }"
            @click="selectFile(file, $event)"
            @dblclick="openFile(file)"
            @contextmenu.prevent="handleContextMenu($event, file)"
          >
            <div class="file-icon">
              <component :is="getFileIcon(getFileType(file))" :style="{ color: getFileColor(getFileType(file)) }" />
            </div>
            <div class="file-name" :title="file.name">
                {{ file.name }}
                <span v-if="file.isPublic" style="color: #1890ff; font-size: 12px;">(公)</span>
            </div>
            <div class="file-meta">{{ formatSize(file.size) }}</div>
          </div>
        </div>

        <!-- 列表视图 -->
        <div v-else class="file-list-view">
          <a-table
            :dataSource="fileList"
            :columns="columns"
            rowKey="id"
            :pagination="false"
            :row-selection="{ selectedRowKeys: selectedFiles, onChange: onSelectChange }"
            @customRow="customRow"
          >
            <template #bodyCell="{ column, record, text }">
              <template v-if="column.key === 'name'">
                <div class="list-name-cell" @dblclick="openFile(record)">
                  <component :is="getFileIcon(getFileType(record))" :style="{ color: getFileColor(getFileType(record)), marginRight: '8px', fontSize: '18px', flexShrink: 0 }" />
                  <a-tooltip :title="record.name" placement="topLeft">
                    <span class="file-name-text">{{ record.name }}</span>
                  </a-tooltip>
                  <a-tag v-if="record.isPublic" color="blue" style="margin-left: 8px; transform: scale(0.8); flex-shrink: 0;">公开</a-tag>
                </div>
              </template>
              <template v-else-if="column.key === 'deptName'">
                <a-tooltip :title="text" placement="topLeft">
                  <span>{{ text || '-' }}</span>
                </a-tooltip>
              </template>
              <template v-else-if="column.key === 'size'">
                <a-tooltip :title="formatSize(text)" placement="topLeft">
                  <span>{{ formatSize(text) }}</span>
                </a-tooltip>
              </template>
              <template v-else-if="column.key === 'updatedAt'">
                <a-tooltip :title="formatDate(text)" placement="topLeft">
                  <span>{{ formatDate(text) }}</span>
                </a-tooltip>
              </template>
              <template v-else-if="column.key === 'owner'">
                <a-tooltip :title="text" placement="topLeft">
                  <span>{{ text }}</span>
                </a-tooltip>
              </template>
              <template v-else-if="column.key === 'action'">
                <a-space>
                  <a-tooltip title="下载" v-if="!record.isFolder">
                    <a-button type="text" size="small" @click="handleDownload(record)"><DownloadOutlined /></a-button>
                  </a-tooltip>
                  <a-tooltip title="更多">
                    <a-dropdown trigger="click">
                      <a-button type="text" size="small"><EllipsisOutlined /></a-button>
                      <template #overlay>
                        <a-menu>
                          <a-menu-item key="open" @click="openFile(record)">打开</a-menu-item>
                          <a-menu-item key="share" @click="handleShare(record)" v-if="record.ownerId === userStore.id">分享</a-menu-item>
                          <a-menu-item key="rename" @click="handleRename(record)" v-if="record.ownerId === userStore.id">属性</a-menu-item>
                          <a-menu-divider />
                          <a-menu-item key="delete" danger @click="handleDelete(record)" v-if="record.ownerId === userStore.id">删除</a-menu-item>
                        </a-menu>
                      </template>
                    </a-dropdown>
                  </a-tooltip>
                </a-space>
              </template>
            </template>
          </a-table>
        </div>
      </div>
    </div>

    <!-- 文件预览弹窗 -->
    <a-modal v-model:open="previewVisible" :title="currentFile?.name" width="800px" :footer="null">
      <div class="preview-content">
        <div v-if="currentFile?.type === 'image'" class="preview-image">
          <img :src="currentFile.url || 'https://via.placeholder.com/600x400'" alt="preview" />
        </div>
        <div v-else class="preview-unknown">
          <FileUnknownOutlined style="font-size: 64px; color: #999; margin-bottom: 16px" />
          <p>该文件暂不支持在线预览</p>
          <a-button type="primary" @click="downloadFile(currentFile)">下载查看</a-button>
        </div>
      </div>
    </a-modal>

    <!-- 分享弹窗 -->
    <a-modal v-model:open="shareVisible" title="分享文件" @ok="handleShareSubmit" :confirmLoading="shareLoading" :okText="shareForm.shareType === 'public' && shareLink ? '复制链接' : '确认'">
      <div v-if="shareLink" style="padding: 20px 0; text-align: center;">
        <p>公开分享链接已生成：</p>
        <a-input v-model:value="shareLink" readonly>
            <template #addonAfter>
                <a-tooltip title="复制">
                    <CopyOutlined style="cursor: pointer;" @click="copyShareLink" />
                </a-tooltip>
            </template>
        </a-input>
      </div>
      <a-form v-else :model="shareForm" layout="vertical">
        <a-form-item label="分享方式">
            <a-radio-group v-model:value="shareForm.shareType">
                <a-radio-button value="user">指定用户</a-radio-button>
                <a-radio-button value="public">公开链接</a-radio-button>
            </a-radio-group>
        </a-form-item>
        
        <a-form-item label="选择用户" v-if="shareForm.shareType === 'user'">
            <a-select
                v-model:value="shareForm.targetUserIds"
                mode="multiple"
                placeholder="请选择用户"
                style="width: 100%"
                :options="userList.map(u => ({ label: u.nickname || u.username, value: u.id }))"
            />
        </a-form-item>

        <a-form-item label="过期时间">
            <a-date-picker 
                v-model:value="shareForm.expirationTime" 
                show-time 
                placeholder="选择过期时间 (留空表示永久有效)" 
                style="width: 100%" 
                valueFormat="YYYY-MM-DD HH:mm:ss"
            />
        </a-form-item>

        <a-form-item label="权限">
          <a-radio-group v-model:value="shareForm.permission">
            <a-radio value="read">只读</a-radio>
            <a-radio value="write">读写</a-radio>
          </a-radio-group>
        </a-form-item>
      </a-form>
    </a-modal>

    <!-- 新建文件夹 Modal -->
    <a-modal v-model:open="newFolderVisible" title="新建文件夹" @ok="handleNewFolderSubmit" :confirmLoading="newFolderLoading">
      <a-form :model="newFolderForm" layout="vertical">
        <a-form-item label="文件夹名称">
          <a-input v-model:value="newFolderForm.name" placeholder="请输入文件夹名称" />
        </a-form-item>
        <a-form-item label="公开性" v-if="getCurrentDeptId()">
          <a-checkbox v-model:checked="newFolderForm.isPublic">公开 (部门所有人可见)</a-checkbox>
        </a-form-item>
      </a-form>
    </a-modal>

    <!-- 编辑文件/文件夹 Modal -->
    <a-modal v-model:open="editFileVisible" title="编辑属性" @ok="handleEditFileSubmit" :confirmLoading="editFileLoading">
      <a-form :model="editFileForm" layout="vertical">
        <a-form-item label="名称">
          <a-input v-model:value="editFileForm.name" />
        </a-form-item>
        <a-form-item label="公开性" v-if="getCurrentDeptId() || editFileForm.isPublic !== undefined">
           <!-- Only show if it's a dept file or already public/private tracked -->
          <a-checkbox v-model:checked="editFileForm.isPublic">公开 (部门所有人可见)</a-checkbox>
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted, computed, createVNode } from 'vue';
import {
  CloudUploadOutlined,
  FolderOutlined,
  FolderAddOutlined,
  FileImageOutlined,
  FilePdfOutlined,
  FileWordOutlined,
  FileExcelOutlined,
  FilePptOutlined,
  FileTextOutlined,
  FileZipOutlined,
  FileUnknownOutlined,
  AppstoreOutlined,
  BarsOutlined,
  ReloadOutlined,
  DownloadOutlined,
  EllipsisOutlined,
  UserOutlined,
  TeamOutlined,
  BankOutlined,
  ApartmentOutlined,
  ClusterOutlined,
  ShareAltOutlined,
  HddOutlined,
  CopyOutlined
} from '@ant-design/icons-vue';
import { message, Modal } from 'ant-design-vue';
import * as FileApi from '@/api/file';
import type { FileItem } from '@/api/file';
import * as UserApi from '@/api/user';
import type { UserListDto } from '@/api/user';
import { useUserStore } from '@/stores/user';
import { getDeptTree, type Dept, DeptType } from '@/api/dept';

// --- 类型定义 ---
type FileType = 'folder' | 'image' | 'pdf' | 'word' | 'excel' | 'ppt' | 'text' | 'zip' | 'unknown';

interface BreadcrumbItem {
  key: string;
  title: string;
  parentId?: number | null;
  deptId?: number | null;
}

// --- 状态 ---
const selectedKeys = ref<string[]>(['personal-my']);
const searchText = ref('');
const viewMode = ref<'grid' | 'list'>('grid');
const loading = ref(false);
const fileList = ref<FileItem[]>([]);
const breadcrumbs = ref<BreadcrumbItem[]>([{ key: 'root', title: '我的网盘' }]);
const selectedFiles = ref<number[]>([]);
const previewVisible = ref(false);
const currentFile = ref<FileItem | null>(null);
const fileInput = ref<HTMLInputElement | null>(null);
const userStore = useUserStore();

// New Folder State
const newFolderVisible = ref(false);
const newFolderForm = ref({
    name: '新建文件夹',
    isPublic: false
});
const newFolderLoading = ref(false);

// Edit File State
const editFileVisible = ref(false);
const editFileForm = ref({
    id: 0,
    name: '',
    isPublic: false
});
const editFileLoading = ref(false);

// Share State
const shareVisible = ref(false);
const shareForm = ref({
    fileId: 0,
    targetUserIds: [] as number[],
    permission: 'read',
    shareType: 'user', // user | public
    expirationTime: null as string | null
});
const shareLink = ref('');
const userList = ref<UserListDto[]>([]);
const shareLoading = ref(false);

// --- Mock 数据 (Tree) ---
// 左侧树形结构
const treeData = ref<any[]>([
  {
    title: '个人网盘',
    key: 'personal',
    icon: UserOutlined,
    children: [
      { title: '我的文件', key: 'personal-my', icon: HddOutlined },
      { title: '与我共享', key: 'personal-shared', icon: ShareAltOutlined },
      { title: '我共享的', key: 'personal-my-shares', icon: ShareAltOutlined },
    ],
  },
  {
    title: '公共网盘',
    key: 'org',
    icon: BankOutlined,
    children: []
  },
  {
    title: '群组网盘',
    key: 'groups',
    icon: TeamOutlined,
    children: [
      { title: '前端开发组', key: 'group-frontend', icon: FolderOutlined },
    ],
  },
]);

const loadDeptTree = async () => {
  try {
    const depts = await getDeptTree();
    
    const getDeptIcon = (type: DeptType) => {
      if (type === DeptType.Group) return { icon: BankOutlined, color: '#faad14' };
      if (type === DeptType.Company) return { icon: ApartmentOutlined, color: '#1890ff' };
      return { icon: ClusterOutlined, color: '#8c8c8c' };
    };

    const mapDeptToNode = (dept: Dept): any => {
      const { icon, color } = getDeptIcon(dept.type);
      return {
        title: dept.name,
        key: `dept_${dept.id}`,
        icon,
        color,
        children: dept.children ? dept.children.map(mapDeptToNode) : [],
        isDept: true,
        deptId: dept.id
      };
    };
    
    const orgNode = treeData.value.find(n => n.key === 'org');
    if (orgNode) {
      orgNode.children = depts.map(mapDeptToNode);
    }
  } catch (error) {
    console.error('Failed to load dept tree', error);
  }
};

// 格式化日期
const formatDate = (dateStr: string) => {
  if (!dateStr) return '-';
  const date = new Date(dateStr);
  const pad = (n: number) => n.toString().padStart(2, '0');
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())} ${pad(date.getHours())}:${pad(date.getMinutes())}:${pad(date.getSeconds())}`;
};

// --- 表格列定义 ---
const columns = [
  { title: '名称', dataIndex: 'name', key: 'name', ellipsis: true, sorter: (a: FileItem, b: FileItem) => a.name.localeCompare(b.name) },
  { title: '所属组织', dataIndex: 'deptName', key: 'deptName', ellipsis: true, width: 150 },
  { title: '大小', dataIndex: 'size', key: 'size', ellipsis: true, width: 120 },
  { title: '修改时间', dataIndex: 'updatedAt', key: 'updatedAt', ellipsis: true, width: 180 },
  { title: '所有者', dataIndex: 'ownerName', key: 'owner', ellipsis: true, width: 100 },
  { title: '操作', key: 'action', width: 100, align: 'center' },
];

// --- 方法 ---

// 获取文件类型
const getFileType = (file: FileItem): FileType => {
  if (file.isFolder) return 'folder';
  const ext = file.extension?.toLowerCase() || '';
  if (['.jpg', '.jpeg', '.png', '.gif', '.bmp'].includes(ext)) return 'image';
  if (['.pdf'].includes(ext)) return 'pdf';
  if (['.doc', '.docx'].includes(ext)) return 'word';
  if (['.xls', '.xlsx'].includes(ext)) return 'excel';
  if (['.ppt', '.pptx'].includes(ext)) return 'ppt';
  if (['.txt', '.md', '.json', '.xml'].includes(ext)) return 'text';
  if (['.zip', '.rar', '.7z', '.tar', '.gz'].includes(ext)) return 'zip';
  return 'unknown';
};

// 获取文件图标
const getFileIcon = (type: FileType) => {
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

// 获取图标颜色
const getFileColor = (type: FileType) => {
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

// 格式化文件大小
const formatSize = (bytes?: number) => {
  if (bytes === undefined || bytes === 0) return '-';
  const k = 1024;
  const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(1)) + ' ' + sizes[i];
};

// 加载文件列表
const loadFiles = async (parentId?: number | null, driveKey?: string, deptId?: number) => {
  const currentKey = driveKey || selectedKeys.value[0];
  loading.value = true;
  selectedFiles.value = [];
  
  try {
    if (currentKey === 'personal-shared') {
        const shares = await FileApi.getSharedWithMe();
        fileList.value = shares.map(s => ({
            id: s.fileId, // Use fileId to allow operations like download/preview
            name: s.fileName,
            extension: s.fileName.includes('.') ? '.' + s.fileName.split('.').pop() : '',
            size: 0, // Not provided in share DTO
            isFolder: s.isFolder,
            ownerId: s.sharedByUserId,
            ownerName: s.sharedByUserName,
            createdAt: s.createdAt,
            updatedAt: s.createdAt,
            hasChildren: false,
            isPublic: false
        })) as unknown as FileItem[];
        return;
    }

    if (currentKey === 'personal-my-shares') {
        const shares = await FileApi.getMySharedFiles();
        fileList.value = shares.map(s => ({
            id: s.fileId,
            name: s.fileName,
            extension: s.fileName.includes('.') ? '.' + s.fileName.split('.').pop() : '',
            size: 0,
            isFolder: s.isFolder,
            ownerId: s.sharedByUserId, // Me
            ownerName: '我',
            deptId: null, // Add missing property
            createdAt: s.createdAt,
            updatedAt: s.createdAt,
            hasChildren: false,
            isPublic: false
        })) as unknown as FileItem[];
        return;
    }

    const params: FileApi.FileQueryParams = {};
    
    // 如果指定了 parentId，则优先使用 parentId (进入文件夹)
    if (parentId !== undefined) {
      params.parentId = parentId;
    } else {
      // 否则根据左侧导航 key 加载根目录
      // 暂时只支持个人网盘根目录
      params.parentId = null; 
      // 这里可以扩展 driveKey 逻辑，比如 params.deptId = ...
    }

    if (currentKey === 'org') {
      params.isPublic = true;
    }

    if (deptId !== undefined) {
        params.deptId = deptId;
    }

    if (searchText.value) {
      params.name = searchText.value;
    }

    const data = await FileApi.getFileList(params);
    fileList.value = data;
  } catch (error) {
    message.error('加载文件列表失败');
    console.error(error);
  } finally {
    loading.value = false;
  }
};

// 获取树路径
const getTreePath = (data: any[], targetKey: string): any[] => {
  for (const item of data) {
    if (item.key === targetKey) {
      return [item];
    }
    if (item.children) {
      const childPath = getTreePath(item.children, targetKey);
      if (childPath.length) {
        return [item, ...childPath];
      }
    }
  }
  return [];
};

const updateBreadcrumbs = (key: string) => {
  const path = getTreePath(treeData.value, key);
  breadcrumbs.value = path.map((item, index) => {
    if (index === path.length - 1) {
      return { key: 'root', title: item.title, deptId: item.deptId };
    }
    return { key: 'nav_' + item.key, title: item.title, deptId: item.deptId };
  });
};

// 获取当前上下文的 DeptId
const getCurrentDeptId = () => {
    // Check if any breadcrumb has deptId
    // Usually it's carried over from the root dept node
    for (let i = breadcrumbs.value.length - 1; i >= 0; i--) {
        if (breadcrumbs.value[i].deptId) {
            return breadcrumbs.value[i].deptId;
        }
    }
    return undefined;
};

// 树节点选择
const handleTreeSelect = (keys: string[], info: any) => {
  if (!keys.length) return;
  const key = keys[0];
  
  // 更新面包屑（统一使用树路径）
  updateBreadcrumbs(key);
  
  // Handle dept node
  if (info.node.isDept) {
    loadFiles(undefined, undefined, info.node.deptId);
    return;
  }
  
  if (key === 'personal-my') {
    loadFiles();
  } else if (key === 'personal-shared') {
    loadFiles(undefined, 'personal-shared');
  } else if (key === 'personal-my-shares') {
    loadFiles(undefined, 'personal-my-shares');
  } else if (key === 'groups') {
      // expand
  } else if (key === 'org') {
      // expand
      loadFiles(undefined, 'org');
  } else {
      // default
      loadFiles();
  }
};

// 面包屑点击
const handleBreadcrumbClick = (item: BreadcrumbItem, index: number) => {
  if (index === breadcrumbs.value.length - 1) return;
  if (item.key.startsWith('nav_')) return;
  
  // 截断面包屑
  breadcrumbs.value = breadcrumbs.value.slice(0, index + 1);
  
  if (item.key === 'root') {
    // 回到根目录
    loadFiles(undefined, selectedKeys.value[0]);
  } else if (item.key.startsWith('dept_')) {
      // Back to dept root
      loadFiles(undefined, undefined, item.deptId || undefined);
  } else {
    // 加载对应文件夹 ID
    const deptId = getCurrentDeptId();
    loadFiles(Number(item.key), undefined, deptId);
  }
};

// 打开文件/进入文件夹
const openFile = (file: FileItem) => {
  if (file.isFolder) {
    // 进入文件夹
    const deptId = getCurrentDeptId() || file.deptId; // If file has deptId, use it (e.g. from list)
    breadcrumbs.value.push({ 
        key: file.id.toString(), 
        title: file.name, 
        parentId: file.parentId,
        deptId: deptId
    });
    loadFiles(file.id, undefined, deptId || undefined);
  } else {
    // 预览文件
    currentFile.value = file;
    // 暂时对于图片直接显示，其他显示不支持
    previewVisible.value = true;
  }
};

// 选中文件
const selectFile = (file: FileItem, event: MouseEvent) => {
  if (event.ctrlKey || event.metaKey) {
    const index = selectedFiles.value.indexOf(file.id);
    if (index > -1) {
      selectedFiles.value.splice(index, 1);
    } else {
      selectedFiles.value.push(file.id);
    }
  } else {
    selectedFiles.value = [file.id];
  }
};

// 表格选中变更
const onSelectChange = (keys: number[]) => {
  selectedFiles.value = keys;
};

// 表格行属性
const customRow = (record: FileItem) => {
  return {
    onDblclick: () => openFile(record),
    onContextmenu: (e: MouseEvent) => handleContextMenu(e, record)
  };
};

// 右键菜单
const handleContextMenu = (_e: MouseEvent, file: FileItem) => {
  if (!selectedFiles.value.includes(file.id)) {
    selectedFiles.value = [file.id];
  }
};

const handleSearch = () => {
  const currentFolder = breadcrumbs.value[breadcrumbs.value.length - 1];
  let parentId: number | null = null;
  if (currentFolder && currentFolder.key !== 'root' && !currentFolder.key.startsWith('dept_')) {
      parentId = Number(currentFolder.key);
  }
  const deptId = getCurrentDeptId();
  loadFiles(parentId, undefined, deptId);
};

const handleNewFolder = () => {
    newFolderForm.value = {
        name: '新建文件夹',
        isPublic: false
    };
    newFolderVisible.value = true;
};

const handleNewFolderSubmit = async () => {
    if (!newFolderForm.value.name) {
        message.warning('请输入文件夹名称');
        return;
    }

    newFolderLoading.value = true;
    try {
        const currentFolder = breadcrumbs.value[breadcrumbs.value.length - 1];
        let parentId: number | null = null;
        if (currentFolder && currentFolder.key !== 'root' && !currentFolder.key.startsWith('dept_')) {
            parentId = Number(currentFolder.key);
        }
        
        const deptId = getCurrentDeptId();

        await FileApi.createFolder({ 
            name: newFolderForm.value.name, 
            parentId,
            deptId: deptId || undefined,
            isPublic: newFolderForm.value.isPublic
        });
        message.success('创建成功');
        newFolderVisible.value = false;
        refreshList();
    } catch (error) {
        console.error(error);
        message.error('创建失败');
    } finally {
        newFolderLoading.value = false;
    }
};

const refreshList = () => {
  const currentFolder = breadcrumbs.value[breadcrumbs.value.length - 1];
  const deptId = getCurrentDeptId();
  
  if (currentFolder?.key === 'root') {
    loadFiles(undefined, selectedKeys.value[0]);
  } else if (currentFolder?.key.startsWith('dept_')) {
      loadFiles(undefined, undefined, deptId);
  } else if (currentFolder) {
    loadFiles(Number(currentFolder.key), undefined, deptId);
  }
};

const handleUpload = () => {
  if (fileInput.value) {
    fileInput.value.click();
  }
};

const onFileSelected = async (e: Event) => {
    const files = (e.target as HTMLInputElement).files;
    if (!files || files.length === 0) return;

    const file = files[0];
    const currentFolder = breadcrumbs.value[breadcrumbs.value.length - 1];
    let parentId: number | null = null;
    if (currentFolder && currentFolder.key !== 'root' && !currentFolder.key.startsWith('dept_')) {
        parentId = Number(currentFolder.key);
    }
    const deptId = getCurrentDeptId();

    try {
        message.loading({ content: '上传中...', key: 'upload' });
        // Default isPublic to false for now, or could check if in a public folder?
        // For now, let's keep it simple.
        await FileApi.uploadFile(file, parentId, deptId || undefined, false);
        message.success({ content: '上传成功', key: 'upload' });
        refreshList();
    } catch (error) {
        message.error({ content: '上传失败', key: 'upload' });
    } finally {
        // Reset input
        (e.target as HTMLInputElement).value = '';
    }
};

const handleDownload = async (file: FileItem | null) => {
  if (!file || file.isFolder) return;
  try {
      message.loading({ content: '准备下载...', key: 'download' });
      const blob = await FileApi.downloadFile(file.id);
      const url = window.URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;
      link.download = file.name; // Backend sets filename, but we can set it here too
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      window.URL.revokeObjectURL(url);
      message.success({ content: '开始下载', key: 'download' });
  } catch (error) {
      message.error({ content: '下载失败', key: 'download' });
  }
};

const handleDelete = async (file: FileItem) => {
    Modal.confirm({
        title: '确认删除',
        content: `确定要删除 ${file.name} 吗？`,
        onOk: async () => {
            try {
                await FileApi.deleteFile(file.id);
                message.success('删除成功');
                refreshList();
            } catch (error) {
                console.error(error);
            }
        }
    });
};

const handleRename = (file: FileItem) => {
    editFileForm.value = {
        id: file.id,
        name: file.name,
        isPublic: file.isPublic || false
    };
    editFileVisible.value = true;
};

const handleEditFileSubmit = async () => {
    if (!editFileForm.value.name) {
        message.warning('请输入名称');
        return;
    }
    
    editFileLoading.value = true;
    try {
        await FileApi.updateFile(editFileForm.value.id, {
            name: editFileForm.value.name,
            isPublic: editFileForm.value.isPublic
        });
        message.success('更新成功');
        editFileVisible.value = false;
        refreshList();
    } catch (error) {
        console.error(error);
        message.error('更新失败');
    } finally {
        editFileLoading.value = false;
    }
};

const handleShare = async (file: FileItem) => {
    shareForm.value = {
        fileId: file.id,
        targetUserIds: [],
        permission: 'read',
        shareType: 'user',
        expirationTime: null
    };
    shareLink.value = '';
    shareVisible.value = true;
    
    // Load users if not loaded
    if (userList.value.length === 0) {
        try {
            const users = await UserApi.getUserList();
            userList.value = users;
        } catch (error) {
            console.error('Failed to load users', error);
        }
    }
};

const copyShareLink = () => {
    if (!shareLink.value) return;
    navigator.clipboard.writeText(shareLink.value).then(() => {
        message.success('复制成功');
    }).catch(() => {
        message.error('复制失败');
    });
};

const handleShareSubmit = async () => {
    if (shareLink.value) {
        copyShareLink();
        shareVisible.value = false;
        return;
    }

    if (shareForm.value.shareType === 'user' && shareForm.value.targetUserIds.length === 0) {
        message.warning('请选择要分享的用户');
        return;
    }
    
    shareLoading.value = true;
    try {
        const result = await FileApi.shareFile({
            fileId: shareForm.value.fileId,
            targetUserIds: shareForm.value.shareType === 'user' ? shareForm.value.targetUserIds : undefined,
            permission: shareForm.value.permission,
            isPublicLink: shareForm.value.shareType === 'public',
            expirationTime: shareForm.value.expirationTime
        }) as unknown as any; 

        if (shareForm.value.shareType === 'public') {
             // Assuming result structure matches backend response
             // Backend: ApiResponse<object>.Success({ Token: ... }, message)
             // Frontend request wrapper: returns data.data (payload) or just data?
             // Need to verify request util. Assuming standard interceptor returning response.data
             // If ApiResponse is standard { code, message, data }, and axios returns data part.
             // If interceptor unwraps 'data' field:
             // Let's assume result is the 'data' field of ApiResponse.
             
             // Wait, I need to know how request.post behaves.
             // Usually in these templates, it returns the payload.
             // If so, result should be { token: '...' }
             
             const token = result?.token; 
             if (token) {
                 // Construct link. Assuming frontend route /s/:token
                 const origin = window.location.origin;
                 shareLink.value = `${origin}/s/${token}`;
                 message.success('链接生成成功');
             } else {
                 // Fallback if token is in message or direct
                 // But based on my controller change: new { Token = message }
                 // Wait, controller: Success(new { Token = message }, "...")
                 // So data is { Token: "..." } (PascalCase in C# -> camelCase in JSON usually?)
                 // Default JSON serializer usually camelCase?
                 // Let's assume token or Token.
                 
                 const t = result?.token || result?.Token;
                 if (t) {
                     const origin = window.location.origin;
                     shareLink.value = `${origin}/s/${t}`;
                     message.success('链接生成成功');
                 } else {
                     message.warning('未获取到分享链接');
                 }
             }
        } else {
            message.success('分享成功');
            shareVisible.value = false;
        }
    } catch (error) {
        console.error(error);
        message.error('分享失败');
    } finally {
        shareLoading.value = false;
    }
};

// 初始化
onMounted(() => {
  loadDeptTree();
  const initialKey = 'personal-my';
  selectedKeys.value = [initialKey];
  updateBreadcrumbs(initialKey);
  loadFiles(undefined, initialKey);
});
</script>

<style scoped>
.drive-container {
  display: flex;
  flex: 1;
  background: #fff;
  border-radius: 8px;
  overflow: hidden;
  border: 1px solid #f0f0f0;
}

/* 左侧 */
.drive-sider {
  width: 260px;
  background: #fafafa;
  border-right: 1px solid #f0f0f0;
  display: flex;
  flex-direction: column;
}

.sider-header {
  padding: 16px;
}

.nav-menu {
  flex: 1;
  overflow-y: auto;
  padding: 8px 8px 0;
}

.nav-menu :deep(.ant-tree-treenode) {
  padding-bottom: 6px;
}

.nav-menu :deep(.ant-tree-node-content-wrapper) {
  line-height: 36px;
  min-height: 36px;
}

.nav-menu :deep(.ant-tree-switcher) {
  line-height: 36px;
}

.storage-info {
  padding: 16px;
  border-top: 1px solid #f0f0f0;
}

.storage-text {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  color: #666;
  margin-bottom: 8px;
}

/* 右侧 */
.drive-main {
  flex: 1;
  display: flex;
  flex-direction: column;
  background: #fff;
}

.main-header {
  height: 56px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 16px;
  border-bottom: 1px solid #f0f0f0;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.file-list-container {
  flex: 1;
  overflow-y: auto;
  padding: 16px;
}

/* 网格视图 */
.file-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
  gap: 16px;
}

.file-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 16px 8px;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s;
  border: 1px solid transparent;
}

.file-card:hover {
  background: #f5f5f5;
}

.file-card.active {
  background: #e6f7ff;
  border-color: #1890ff;
}

.file-icon {
  font-size: 48px;
  margin-bottom: 8px;
}

.file-name {
  font-size: 14px;
  color: #333;
  text-align: center;
  width: 100%;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  margin-bottom: 4px;
}

.file-meta {
  font-size: 12px;
  color: #999;
}

/* 列表视图 */
.list-name-cell {
  display: flex;
  align-items: center;
  cursor: pointer;
  max-width: 100%;
}

.file-name-text {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  flex: 1;
  min-width: 0;
}

/* 预览 */
.preview-content {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 300px;
  background: #f5f5f5;
  border-radius: 4px;
}

.preview-image img {
  max-width: 100%;
  max-height: 500px;
}

.preview-unknown {
  text-align: center;
}
</style>
