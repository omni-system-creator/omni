<template>
  <div class="share-access-container">
    <a-card class="share-card" :loading="loading">
      <template #title>
        <div class="share-header">
          <span class="share-title">文件分享</span>
        </div>
      </template>

      <div v-if="error" class="error-content">
        <FrownOutlined style="font-size: 48px; color: #ff4d4f; margin-bottom: 16px;" />
        <p>{{ error }}</p>
      </div>

      <div v-else-if="fileInfo" class="file-content">
        <div class="file-icon-wrapper">
          <component :is="getFileIcon(getFileType(fileInfo))" :style="{ fontSize: '64px', color: getFileColor(getFileType(fileInfo)) }" />
        </div>
        <h2 class="file-name">{{ fileInfo.fileName }}</h2>
        
        <div class="file-meta">
          <div class="meta-item">
            <span class="label">分享人：</span>
            <span class="value">{{ fileInfo.sharedByUserName }}</span>
          </div>
          <div class="meta-item">
            <span class="label">分享时间：</span>
            <span class="value">{{ formatDate(fileInfo.createdAt) }}</span>
          </div>
          <div class="meta-item" v-if="fileInfo.expirationTime">
            <span class="label">过期时间：</span>
            <span class="value">{{ formatDate(fileInfo.expirationTime) }}</span>
          </div>
        </div>

        <div class="actions">
          <a-button type="primary" size="large" @click="handleDownload" :loading="downloading">
            <template #icon><DownloadOutlined /></template>
            下载文件
          </a-button>
        </div>
      </div>
    </a-card>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import request from '@/utils/request';
import { 
  FileImageOutlined, 
  FilePdfOutlined, 
  FileWordOutlined, 
  FileExcelOutlined, 
  FilePptOutlined, 
  FileTextOutlined, 
  FileZipOutlined, 
  FileUnknownOutlined,
  FolderOutlined,
  DownloadOutlined,
  FrownOutlined
} from '@ant-design/icons-vue';
import dayjs from 'dayjs';

const route = useRoute();
const token = route.params.token as string;

const loading = ref(true);
const error = ref('');
const fileInfo = ref<any>(null);
const downloading = ref(false);

const formatDate = (date: string) => {
  return dayjs(date).format('YYYY-MM-DD HH:mm:ss');
};

const getFileType = (file: any) => {
  if (file.isFolder) return 'folder';
  const ext = file.fileName.split('.').pop()?.toLowerCase();
  if (['jpg', 'jpeg', 'png', 'gif', 'bmp'].includes(ext)) return 'image';
  if (ext === 'pdf') return 'pdf';
  if (['doc', 'docx'].includes(ext)) return 'word';
  if (['xls', 'xlsx'].includes(ext)) return 'excel';
  if (['ppt', 'pptx'].includes(ext)) return 'ppt';
  if (['txt', 'md', 'json', 'xml'].includes(ext)) return 'text';
  if (['zip', 'rar', '7z', 'tar', 'gz'].includes(ext)) return 'zip';
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
    case 'folder': return '#faad14';
    case 'image': return '#ff85c0';
    case 'pdf': return '#ff4d4f';
    case 'word': return '#1890ff';
    case 'excel': return '#52c41a';
    case 'ppt': return '#fa8c16';
    case 'text': return '#8c8c8c';
    case 'zip': return '#722ed1';
    default: return '#bfbfbf';
  }
};

const fetchShareInfo = async () => {
  try {
    loading.value = true;
    // Note: Adjust API path if necessary. Using request util directly.
    const res = await request.get(`/file/share/public/${token}`);
    fileInfo.value = res; // Assuming interceptor returns data directly
  } catch (err: any) {
    console.error(err);
    error.value = err.message || '获取分享信息失败';
  } finally {
    loading.value = false;
  }
};

const handleDownload = async () => {
  try {
    downloading.value = true;
    const res = await request.get(`/file/share/public/${token}/download`, {
        responseType: 'blob'
    });
    
    // Create download link
    const blob = new Blob([res as any]);
    const url = window.URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = fileInfo.value.fileName;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    window.URL.revokeObjectURL(url);
  } catch (err) {
    console.error(err);
    // message.error('下载失败');
  } finally {
    downloading.value = false;
  }
};

onMounted(() => {
  if (!token) {
    error.value = '无效的分享链接';
    loading.value = false;
    return;
  }
  fetchShareInfo();
});
</script>

<style scoped>
.share-access-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background-color: #f0f2f5;
}

.share-card {
  width: 100%;
  max-width: 600px;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.share-header {
  text-align: center;
}

.error-content {
  text-align: center;
  padding: 40px 0;
  color: #666;
}

.file-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 20px 0;
}

.file-icon-wrapper {
  margin-bottom: 24px;
}

.file-name {
  font-size: 20px;
  font-weight: 500;
  margin-bottom: 32px;
  color: #333;
  text-align: center;
  word-break: break-all;
}

.file-meta {
  width: 100%;
  background: #fafafa;
  padding: 16px;
  border-radius: 4px;
  margin-bottom: 32px;
}

.meta-item {
  display: flex;
  margin-bottom: 8px;
  font-size: 14px;
}

.meta-item:last-child {
  margin-bottom: 0;
}

.label {
  color: #999;
  width: 80px;
  flex-shrink: 0;
}

.value {
  color: #333;
}

.actions {
  text-align: center;
}
</style>