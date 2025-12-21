<template>
  <div class="drive-container">
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
          <template #title="{ title, icon }">
            <span class="tree-node-title">
              <component :is="icon" v-if="icon" style="margin-right: 8px" />
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
              <component :is="getFileIcon(file.type)" :style="{ color: getFileColor(file.type) }" />
            </div>
            <div class="file-name" :title="file.name">{{ file.name }}</div>
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
            <template #bodyCell="{ column, record }">
              <template v-if="column.key === 'name'">
                <div class="list-name-cell">
                  <component :is="getFileIcon(record.type)" :style="{ color: getFileColor(record.type), marginRight: '8px', fontSize: '18px' }" />
                  <span>{{ record.name }}</span>
                </div>
              </template>
              <template v-if="column.key === 'action'">
                <a-space>
                  <a-tooltip title="下载" v-if="record.type !== 'folder'">
                    <a-button type="text" size="small"><DownloadOutlined /></a-button>
                  </a-tooltip>
                  <a-tooltip title="更多">
                    <a-dropdown trigger="click">
                      <a-button type="text" size="small"><EllipsisOutlined /></a-button>
                      <template #overlay>
                        <a-menu>
                          <a-menu-item key="open" @click="openFile(record)">打开</a-menu-item>
                          <a-menu-item key="share">分享</a-menu-item>
                          <a-menu-item key="rename" :disabled="!record.permission.write">重命名</a-menu-item>
                          <a-menu-divider />
                          <a-menu-item key="delete" danger :disabled="!record.permission.delete">删除</a-menu-item>
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
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted } from 'vue';
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
  ShareAltOutlined,
  HddOutlined
} from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';

// --- 类型定义 ---
type FileType = 'folder' | 'image' | 'pdf' | 'word' | 'excel' | 'ppt' | 'text' | 'zip' | 'unknown';
type Permission = { read: boolean; write: boolean; delete: boolean };

interface FileItem {
  id: string;
  name: string;
  type: FileType;
  size?: number; // bytes
  updatedAt: string;
  owner: string;
  permission: Permission;
  url?: string;
  parentId?: string;
}

interface BreadcrumbItem {
  key: string;
  title: string;
  parentId?: string;
}

// --- 状态 ---
const selectedKeys = ref<string[]>(['personal-my']);
const searchText = ref('');
const viewMode = ref<'grid' | 'list'>('grid');
const loading = ref(false);
const fileList = ref<FileItem[]>([]);
const breadcrumbs = ref<BreadcrumbItem[]>([{ key: 'root', title: '我的网盘' }]);
const selectedFiles = ref<string[]>([]);
const previewVisible = ref(false);
const currentFile = ref<FileItem | null>(null);

// --- Mock 数据 ---
// 左侧树形结构
const treeData = [
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
    title: '群组网盘',
    key: 'groups',
    icon: TeamOutlined,
    children: [
      { title: '前端开发组', key: 'group-frontend', icon: FolderOutlined },
      { title: '项目攻坚组', key: 'group-project', icon: FolderOutlined },
      { title: '羽毛球兴趣组', key: 'group-badminton', icon: FolderOutlined },
    ],
  },
  {
    title: '组织网盘',
    key: 'org',
    icon: BankOutlined,
    children: [
      { title: '全公司共享', key: 'org-company', icon: HddOutlined },
      { title: '研发部', key: 'org-rd', icon: FolderOutlined },
      { title: '产品部', key: 'org-product', icon: FolderOutlined },
    ],
  },
];

// 模拟文件数据库
const mockFiles: FileItem[] = [
  // 个人网盘 - 根目录
  { id: 'f1', name: '工作文档', type: 'folder', size: 0, updatedAt: '2023-10-20 10:00', owner: 'me', permission: { read: true, write: true, delete: true } },
  { id: 'f2', name: '个人照片', type: 'folder', size: 0, updatedAt: '2023-10-21 14:30', owner: 'me', permission: { read: true, write: true, delete: true } },
  { id: 'fi1', name: '2023年度总结.docx', type: 'word', size: 25600, updatedAt: '2023-10-25 09:15', owner: 'me', permission: { read: true, write: true, delete: true } },
  { id: 'fi2', name: '项目架构图.png', type: 'image', size: 1048576, updatedAt: '2023-10-24 16:20', owner: 'me', permission: { read: true, write: true, delete: true }, url: 'https://picsum.photos/800/600' },
  
  // 我共享的文件
  { id: 'sfi1', name: '公开技术分享.pptx', type: 'ppt', size: 5242880, updatedAt: '2023-10-26 10:00', owner: 'me', permission: { read: true, write: true, delete: true } },
  { id: 'sfi2', name: '常用工具集合.zip', type: 'zip', size: 104857600, updatedAt: '2023-10-26 11:30', owner: 'me', permission: { read: true, write: true, delete: true } },

  // 工作文档 文件夹内
  { id: 'fi3', name: '需求规格说明书.pdf', type: 'pdf', size: 5242880, updatedAt: '2023-10-18 11:00', owner: 'me', permission: { read: true, write: true, delete: true }, parentId: 'f1' },
  
  // 群组网盘 - 前端开发组
  { id: 'gf1', name: '组件库规范', type: 'folder', size: 0, updatedAt: '2023-09-01 10:00', owner: 'admin', permission: { read: true, write: false, delete: false } },
  { id: 'gfi1', name: 'Vue3最佳实践.md', type: 'text', size: 5120, updatedAt: '2023-10-20 15:00', owner: 'zhangsan', permission: { read: true, write: true, delete: false } },
  
  // 组织网盘 - 全公司
  { id: 'ofi1', name: '员工手册2023版.pdf', type: 'pdf', size: 10485760, updatedAt: '2023-01-01 09:00', owner: 'hr', permission: { read: true, write: false, delete: false } },
  { id: 'ofi2', name: '公司Logo.ai', type: 'unknown', size: 2097152, updatedAt: '2023-01-01 09:00', owner: 'design', permission: { read: true, write: false, delete: false } },
];

// --- 表格列定义 ---
const columns = [
  { title: '文件名', dataIndex: 'name', key: 'name', sorter: (a: FileItem, b: FileItem) => a.name.localeCompare(b.name) },
  { title: '大小', dataIndex: 'size', key: 'size', customRender: ({ text }: { text: number }) => formatSize(text), width: 120 },
  { title: '修改时间', dataIndex: 'updatedAt', key: 'updatedAt', width: 180 },
  { title: '所有者', dataIndex: 'owner', key: 'owner', width: 100 },
  { title: '操作', key: 'action', width: 100, align: 'center' },
];

// --- 方法 ---

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
const loadFiles = (parentId?: string, driveKey?: string) => {
  loading.value = true;
  selectedFiles.value = [];
  
  setTimeout(() => {
    // 简单的 Mock 逻辑
    if (driveKey) {
      // 切换网盘根目录
      if (driveKey === 'personal-my') {
        fileList.value = mockFiles.filter(f => !f.parentId && (f.owner === 'me' || f.owner === 'system') && !['sfi1', 'sfi2'].includes(f.id));
      } else if (driveKey === 'personal-my-shares') {
        fileList.value = mockFiles.filter(f => ['sfi1', 'sfi2'].includes(f.id));
      } else if (driveKey === 'group-frontend') {
        fileList.value = mockFiles.filter(f => !f.parentId && (f.owner === 'admin' || f.owner === 'zhangsan'));
      } else if (driveKey === 'org-company') {
        fileList.value = mockFiles.filter(f => f.owner === 'hr' || f.owner === 'design');
      } else {
        fileList.value = []; // 其他暂为空
      }
    } else if (parentId) {
      // 进入文件夹
      fileList.value = mockFiles.filter(f => f.parentId === parentId);
    }
    
    loading.value = false;
  }, 300);
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
  const path = getTreePath(treeData, key);
  breadcrumbs.value = path.map((item, index) => {
    if (index === path.length - 1) {
      return { key: 'root', title: item.title };
    }
    return { key: 'nav_' + item.key, title: item.title };
  });
};

// 树节点选择
const handleTreeSelect = (keys: string[]) => {
  if (keys.length > 0) {
    const key = keys[0];
    if (key) {
      updateBreadcrumbs(key);
      loadFiles(undefined, key);
    }
  }
};

// 面包屑点击
const handleBreadcrumbClick = (item: BreadcrumbItem, index: number) => {
  if (index === breadcrumbs.value.length - 1) return;
  if (item.key.startsWith('nav_')) return;
  
  // 截断面包屑
  breadcrumbs.value = breadcrumbs.value.slice(0, index + 1);
  
  if (item.key === 'root') {
    // 回到根目录，重新根据 selectedKeys 加载
    loadFiles(undefined, selectedKeys.value[0]);
  } else {
    // 加载对应文件夹 ID
    loadFiles(item.key);
  }
};

// 打开文件/进入文件夹
const openFile = (file: FileItem) => {
  if (file.type === 'folder') {
    // 进入文件夹
    breadcrumbs.value.push({ key: file.id, title: file.name, parentId: file.parentId });
    loadFiles(file.id);
  } else {
    // 预览文件
    currentFile.value = file;
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
const onSelectChange = (keys: string[]) => {
  selectedFiles.value = keys;
};

// 表格行属性
const customRow = (record: FileItem) => {
  return {
    onDblclick: () => openFile(record),
    onContextmenu: (e: MouseEvent) => handleContextMenu(e, record)
  };
};

// 右键菜单 (暂未实现完整右键菜单，仅阻止默认)
const handleContextMenu = (_e: MouseEvent, file: FileItem) => {
  // 实际项目中这里会弹出自定义右键菜单
  // 这里暂时只做选中
  if (!selectedFiles.value.includes(file.id)) {
    selectedFiles.value = [file.id];
  }
};

const handleSearch = () => {
  message.info('搜索功能开发中...');
};

const handleNewFolder = () => {
  message.success('已新建文件夹：新建文件夹');
  const newFolder: FileItem = {
    id: Date.now().toString(),
    name: '新建文件夹',
    type: 'folder',
    updatedAt: new Date().toLocaleString(),
    owner: 'me',
    permission: { read: true, write: true, delete: true },
    parentId: breadcrumbs.value.length > 1 ? breadcrumbs.value[breadcrumbs.value.length - 1]?.key : undefined
  };
  fileList.value.unshift(newFolder);
};

const refreshList = () => {
  const currentFolder = breadcrumbs.value[breadcrumbs.value.length - 1];
  if (currentFolder?.key === 'root') {
    loadFiles(undefined, selectedKeys.value[0]);
  } else if (currentFolder) {
    loadFiles(currentFolder.key);
  }
  message.success('刷新成功');
};

const handleUpload = () => {
  message.info('点击了上传按钮');
};

const downloadFile = (file: FileItem | null) => {
  if (!file) return;
  message.success(`开始下载：${file.name}`);
};

// 初始化
onMounted(() => {
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
