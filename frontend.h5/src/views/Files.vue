<template>
  <div class="files-container">
    <van-nav-bar title="文件">
      <template #right>
        <van-icon name="plus" size="18" @click="showActionSheet = true" />
      </template>
    </van-nav-bar>
    
    <div class="header-section">
      <van-search v-model="searchText" placeholder="搜索文件名/文件夹" shape="round" background="transparent" />
      
      <!-- 存储空间卡片 -->
      <div class="storage-card">
        <div class="storage-info">
          <div class="storage-text">
            <span class="used">已用 128.5 GB</span>
            <span class="total"> / 1 TB</span>
          </div>
          <van-button size="mini" round plain type="primary">清理</van-button>
        </div>
        <van-progress :percentage="12.5" :show-pivot="false" color="#1989fa" track-color="#ebedf0" stroke-width="6" />
      </div>

      <!-- 金刚区/快捷入口 -->
      <van-grid :border="false" class="file-categories">
        <van-grid-item icon="photo" text="图片" icon-color="#ff976a" />
        <van-grid-item icon="description" text="文档" icon-color="#1989fa" />
        <van-grid-item icon="video" text="视频" icon-color="#07c160" />
        <van-grid-item icon="music" text="音频" icon-color="#ee0a24" />
      </van-grid>
    </div>

    <van-tabs v-model:active="activeTab" background="#f7f8fa">
      <van-tab title="最近">
        <van-pull-refresh v-model="refreshing" @refresh="onRefresh">
          <div class="file-list">
            <div class="date-group">今天</div>
            <van-cell-group inset>
              <van-cell v-for="file in recentFiles" :key="file.id" center is-link @click="onFileClick(file)">
                <template #icon>
                  <div class="file-icon" :class="file.type">
                    <van-icon :name="getFileIcon(file.type)" />
                  </div>
                </template>
                <template #title>
                  <div class="file-name">{{ file.name }}</div>
                </template>
                <template #label>
                  <div class="file-info">{{ file.size }} · {{ file.time }}</div>
                </template>
                <template #right-icon>
                  <van-icon name="ellipsis" class="more-btn" @click.stop="onMoreClick(file)" />
                </template>
              </van-cell>
            </van-cell-group>
            
            <div class="date-group">昨天</div>
            <van-cell-group inset>
              <van-cell v-for="file in yesterdayFiles" :key="file.id" center is-link @click="onFileClick(file)">
                <template #icon>
                  <div class="file-icon" :class="file.type">
                    <van-icon :name="getFileIcon(file.type)" />
                  </div>
                </template>
                <template #title>
                  <div class="file-name">{{ file.name }}</div>
                </template>
                <template #label>
                  <div class="file-info">{{ file.size }} · {{ file.time }}</div>
                </template>
                <template #right-icon>
                  <van-icon name="ellipsis" class="more-btn" @click.stop="onMoreClick(file)" />
                </template>
              </van-cell>
            </van-cell-group>
          </div>
        </van-pull-refresh>
      </van-tab>
      
      <van-tab title="企业空间">
        <van-pull-refresh v-model="refreshing" @refresh="onRefresh">
          <div class="folder-list">
             <van-cell-group inset>
              <van-cell v-for="folder in companyFolders" :key="folder.id" center is-link>
                <template #icon>
                  <div class="folder-icon">
                    <van-icon name="folder-o" />
                  </div>
                </template>
                <template #title>
                  <div class="file-name">{{ folder.name }}</div>
                </template>
                <template #label>
                  <div class="file-info">{{ folder.count }}个项目 · {{ folder.time }}</div>
                </template>
              </van-cell>
            </van-cell-group>
          </div>
        </van-pull-refresh>
      </van-tab>
      
      <van-tab title="个人空间">
        <van-pull-refresh v-model="refreshing" @refresh="onRefresh">
          <div class="file-list">
            <div class="date-group">文件夹</div>
            <van-cell-group inset>
              <van-cell v-for="folder in personalFolders" :key="folder.id" center is-link>
                <template #icon>
                  <div class="folder-icon">
                    <van-icon name="folder-o" />
                  </div>
                </template>
                <template #title>
                  <div class="file-name">{{ folder.name }}</div>
                </template>
                <template #label>
                  <div class="file-info">{{ folder.count }}个项目 · {{ folder.time }}</div>
                </template>
              </van-cell>
            </van-cell-group>

            <div class="date-group">文件</div>
            <van-cell-group inset>
              <van-cell v-for="file in personalFiles" :key="file.id" center is-link @click="onFileClick(file)">
                <template #icon>
                  <div class="file-icon" :class="file.type">
                    <van-icon :name="getFileIcon(file.type)" />
                  </div>
                </template>
                <template #title>
                  <div class="file-name">{{ file.name }}</div>
                </template>
                <template #label>
                  <div class="file-info">{{ file.size }} · {{ file.time }}</div>
                </template>
                <template #right-icon>
                  <van-icon name="ellipsis" class="more-btn" @click.stop="onMoreClick(file)" />
                </template>
              </van-cell>
            </van-cell-group>
          </div>
        </van-pull-refresh>
      </van-tab>
    </van-tabs>

    <!-- 更多操作面板 -->
    <van-action-sheet
      v-model:show="showActionSheet"
      :actions="actions"
      cancel-text="取消"
      close-on-click-action
      @select="onSelectAction"
    />
    
    <!-- 文件操作面板 -->
    <van-action-sheet
      v-model:show="showFileActionSheet"
      :title="currentFile?.name"
      :actions="fileActions"
      cancel-text="取消"
      close-on-click-action
      @select="onSelectFileAction"
    />
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { showToast } from 'vant';

interface FileItem {
  id: string;
  name: string;
  type: 'pdf' | 'word' | 'excel' | 'image' | 'zip' | 'ppt';
  size: string;
  time: string;
}

interface FolderItem {
  id: string;
  name: string;
  count: number;
  time: string;
}

const searchText = ref('');
const activeTab = ref(0);
const showActionSheet = ref(false);
const showFileActionSheet = ref(false);
const currentFile = ref<FileItem | null>(null);
const refreshing = ref(false);

const onRefresh = () => {
  setTimeout(() => {
    showToast('刷新成功');
    refreshing.value = false;
  }, 1000);
};

const actions = [
  { name: '上传文件', icon: 'upgrade' },
  { name: '新建文件夹', icon: 'add-o' },
  { name: '扫一扫', icon: 'scan' },
];

const fileActions = [
  { name: '查看', icon: 'eye-o' },
  { name: '下载', icon: 'down' },
  { name: '分享', icon: 'share-o' },
  { name: '重命名', icon: 'edit' },
  { name: '删除', color: '#ee0a24', icon: 'delete-o' },
];

const recentFiles: FileItem[] = [
  { id: '1', name: '2024年度项目计划书.docx', type: 'word', size: '2.4 MB', time: '10:30' },
  { id: '2', name: '产品设计草图_v2.png', type: 'image', size: '4.8 MB', time: '09:15' },
  { id: '3', name: 'Q4财务报表.xlsx', type: 'excel', size: '1.2 MB', time: '08:50' },
];

const yesterdayFiles: FileItem[] = [
  { id: '4', name: '系统架构图.pdf', type: 'pdf', size: '8.5 MB', time: '17:20' },
  { id: '5', name: '项目汇报演示.pptx', type: 'ppt', size: '15.6 MB', time: '14:00' },
  { id: '6', name: '备份数据_20241024.zip', type: 'zip', size: '156 MB', time: '11:45' },
];

const companyFolders: FolderItem[] = [
  { id: 'f1', name: '公共资料库', count: 128, time: '2024-10-24' },
  { id: 'f2', name: '研发部文档', count: 56, time: '2024-10-23' },
  { id: 'f3', name: '市场部素材', count: 324, time: '2024-10-22' },
  { id: 'f4', name: '行政制度', count: 12, time: '2024-10-20' },
];

const personalFolders: FolderItem[] = [
  { id: 'pf1', name: '我的相册', count: 326, time: '2024-10-24' },
  { id: 'pf2', name: '学习资料', count: 45, time: '2024-10-21' },
];

const personalFiles: FileItem[] = [
  { id: 'p1', name: '个人简历_2024.pdf', type: 'pdf', size: '2.4 MB', time: '2024-10-25' },
  { id: 'p2', name: '装修设计图.zip', type: 'zip', size: '128 MB', time: '2024-10-18' },
  { id: 'p3', name: '读书笔记.docx', type: 'word', size: '1.2 MB', time: '2024-09-15' },
];

const getFileIcon = (type: string) => {
  switch (type) {
    case 'pdf': return 'description';
    case 'word': return 'orders-o';
    case 'excel': return 'bar-chart-o';
    case 'ppt': return 'tv-o';
    case 'image': return 'photo-o';
    case 'zip': return 'bag-o';
    default: return 'description';
  }
};

const onFileClick = (file: FileItem) => {
  showToast(`打开文件: ${file.name}`);
};

const onMoreClick = (file: FileItem) => {
  currentFile.value = file;
  showFileActionSheet.value = true;
};

const onSelectAction = (item: any) => {
  showToast(item.name);
};

const onSelectFileAction = (item: any) => {
  showToast(`${item.name}: ${currentFile.value?.name}`);
};
</script>

<style scoped>
.files-container {
  height: calc(100vh - 50px);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  background-color: #f7f8fa;
}

:deep(.van-tabs) {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

:deep(.van-tabs__wrap) {
  flex-shrink: 0;
}

:deep(.van-tabs__content) {
  flex: 1;
  overflow-y: auto;
  -webkit-overflow-scrolling: touch;
}

:deep(.van-pull-refresh) {
  min-height: 100%;
}

.header-section {
  background: #fff;
  padding-bottom: 12px;
  border-bottom-left-radius: 16px;
  border-bottom-right-radius: 16px;
  margin-bottom: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.02);
}

.storage-card {
  margin: 0 16px 16px;
  padding: 16px;
  background: linear-gradient(135deg, #e0f2fe 0%, #f0f9ff 100%);
  border-radius: 12px;
}

.storage-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.storage-text {
  font-size: 14px;
}

.storage-text .used {
  font-weight: bold;
  color: #1989fa;
}

.storage-text .total {
  color: #969799;
  font-size: 12px;
}

.file-categories {
  margin-top: 8px;
}

.date-group {
  padding: 16px 16px 8px;
  color: #969799;
  font-size: 14px;
}

.file-list, .folder-list {
  padding-bottom: 20px;
}

.file-icon, .folder-icon {
  width: 40px;
  height: 40px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 12px;
  font-size: 24px;
}

.folder-icon {
  background-color: #fffbe8;
  color: #ffc400;
}

.file-icon.pdf { background-color: #ffeaea; color: #ee0a24; }
.file-icon.word { background-color: #e8f3ff; color: #1989fa; }
.file-icon.excel { background-color: #eaf9e6; color: #07c160; }
.file-icon.ppt { background-color: #fff4e6; color: #ff976a; }
.file-icon.image { background-color: #f2efff; color: #7232dd; }
.file-icon.zip { background-color: #f7f8fa; color: #646566; }

.file-name {
  font-weight: 500;
  color: #323233;
  margin-bottom: 4px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.file-info {
  font-size: 12px;
  color: #969799;
}

.more-btn {
  padding: 8px;
  color: #969799;
}
</style>