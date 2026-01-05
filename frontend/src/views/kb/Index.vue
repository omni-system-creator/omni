<template>
  <div class="kb-container">
    <input type="file" ref="fileInput" style="display: none" multiple accept=".pdf,.doc,.docx,.md,.txt,.png,.jpg,.jpeg" @change="handleFileInputChange" />
    <SplitLayout position="left" :initialWidth="280" :minWidth="200" :maxWidth="500">
      <template #sidebar>
        <div class="kb-sider">
          <div class="sider-header">
            <span class="title">知识库</span>
            <a-tooltip title="新建知识库" v-if="isAdmin">
              <a-button type="primary" size="small" @click="showCreateModal">
                <template #icon><PlusOutlined /></template>
                新建
              </a-button>
            </a-tooltip>
          </div>
          
          <div class="search-box">
            <a-input-search v-model:value="searchText" placeholder="搜索知识库..." />
          </div>

          <a-menu
            v-model:selectedKeys="selectedKbKeys"
            mode="inline"
            class="kb-menu"
            @click="handleKbSelect"
          >
            <a-menu-item v-for="kb in filteredKbs" :key="kb.id">
              <template #icon>
                <FolderOutlined v-if="kb.type === 'general'" />
                <CodeOutlined v-else-if="kb.type === 'code'" />
                <BookOutlined v-else />
              </template>
              <span>{{ kb.name }}</span>
              <a-dropdown :trigger="['contextmenu']" v-if="isAdmin">
                <span class="context-trigger"></span>
                <template #overlay>
                  <a-menu>
                    <a-menu-item key="delete" danger @click.stop="handleDeleteKb(kb.id)">删除</a-menu-item>
                  </a-menu>
                </template>
              </a-dropdown>
            </a-menu-item>
          </a-menu>
        </div>
      </template>

      <template #main>
        <div class="kb-content">
        <div v-if="currentKb" class="kb-detail">
          

          <div class="kb-body" ref="kbBodyRef" 
               @dragenter.prevent="handleDragEnter" 
               @dragover.prevent 
               @dragleave.prevent="handleDragLeave" 
               @drop.prevent="handleDrop">
            <SplitLayout v-if="splitReady" position="right" :initialWidth="splitWidth" :minWidth="360" :maxWidth="900">
              <template #main>
                <div class="explorer-layout">
                  <div class="main-header">
                    <div class="breadcrumb-area">
                      <a-breadcrumb>
                        <a-breadcrumb-item>知识库</a-breadcrumb-item>
                        <a-breadcrumb-item>{{ currentKb.name }}</a-breadcrumb-item>
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
                              <a-menu-item key="new-folder" v-if="isAdmin" @click="handleNewFolder">
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
                  <div class="file-explorer">
                  <a-upload-dragger
                      v-if="isDragOverlayVisible"
                      v-model:fileList="fileList"
                      name="file"
                      :multiple="true"
                      :customRequest="handleCustomUpload"
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
                    <a-empty v-if="filteredKbFiles.length === 0" description="暂无文件" style="margin-top: 100px" />

                    <!-- Grid View -->
                    <div v-else-if="viewMode === 'grid'" class="file-grid">
                      <div
                        v-for="file in filteredKbFiles"
                        :key="file.id"
                        class="file-card"
                        :class="{ active: selectedFiles.includes(file.id) }"
                        @click="selectFile(file, $event)"
                        @dblclick="file.isFolder ? handleFolderClick(file) : viewFile(file)"
                        @contextmenu.prevent="handleContextMenu($event, file)"
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
                        :data-source="filteredKbFiles" 
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
                            <a-space>
                              <a-tooltip title="查看" v-if="!record.isFolder">
                                <a-button type="text" size="small" @click="viewFile(record)"><FileTextOutlined /></a-button>
                              </a-tooltip>
                              <a-tooltip title="下载" v-if="!record.isFolder">
                                <a-button type="text" size="small" @click="downloadFile(record)"><DownloadOutlined /></a-button>
                              </a-tooltip>
                              <template v-if="isAdmin">
                                <a-dropdown trigger="click">
                                  <a-button type="text" size="small"><EllipsisOutlined /></a-button>
                                  <template #overlay>
                                    <a-menu>
                                      <a-menu-item key="rename" @click="openRenameModal(record)">重命名</a-menu-item>
                                      <a-menu-item key="move" @click="openMoveModal(record)">移动</a-menu-item>
                                      <a-menu-divider />
                                      <a-menu-item key="delete" danger @click="deleteFile(record.id)">删除</a-menu-item>
                                    </a-menu>
                                  </template>
                                </a-dropdown>
                              </template>
                            </a-space>
                          </template>
                        </template>
                      </a-table>
                    </div>
                  </div>
                </div>
                </div>
              </template>
              <template #sidebar>
                <div class="chat-panel">
                  <div class="chat-view">
                    <div class="chat-history" ref="chatHistoryRef">
                      <div v-for="(msg, index) in chatMessages" :key="index" :class="['chat-message', msg.role]">
                        <div class="avatar">
                          <UserOutlined v-if="msg.role === 'user'" />
                          <RobotOutlined v-else />
                        </div>
                        <div class="message-content">
                          <div class="bubble markdown-body" v-html="renderMarkdown(msg.content)"></div>
                          <div v-if="msg.sources && msg.sources.length" class="citations">
                            <span class="citation-title">参考来源:</span>
                            <a-tag v-for="(source, sIndex) in msg.sources" :key="sIndex" color="blue" class="citation-tag">
                              {{ source.fileName }} (P.{{ source.page }})
                            </a-tag>
                          </div>
                        </div>
                      </div>
                      <div v-if="isThinking" class="chat-message ai">
                        <div class="avatar"><RobotOutlined spin /></div>
                        <div class="message-content">
                          <div class="bubble thinking">AI 正在思考中...</div>
                        </div>
                      </div>
                      <div ref="chatBottomRef"></div>
                    </div>
                    <div class="chat-input" style="flex-direction: column; align-items: flex-start;">
                      <div class="model-selector" style="display: flex; align-items: center;">
                        <span style="margin-right: 8px; color: #666;">模型:</span>
                        <a-select v-model:value="selectedModel" style="width: 200px" size="small" :options="siliconModels.map(m => ({ label: m.label, value: m.value }))" />
                      </div>
                      <div style="display: flex; gap: 12px; align-items: flex-end; width: 100%;">
                        <a-textarea
                          v-model:value="userInput"
                          placeholder="请输入您的问题，例如：该产品的核心功能有哪些？"
                          :auto-size="{ minRows: 2, maxRows: 6 }"
                          @pressEnter.prevent="sendMessage"
                        />
                        <a-button type="primary" class="send-btn" @click="sendMessage" :loading="isThinking">
                          <template #icon><SendOutlined /></template>
                          发送
                        </a-button>
                      </div>
                    </div>
                  </div>
                </div>
              </template>
            </SplitLayout>
          </div>
        </div>
        <div v-else class="empty-selection">
          <a-empty description="请选择一个知识库开始问答" />
        </div>
      </div>
      </template>
    </SplitLayout>

  <!-- Create KB Modal -->
  <a-modal
      v-model:open="isCreateModalVisible"
      title="新建知识库"
      @ok="handleCreateKb"
    >
      <a-form layout="vertical">
        <a-form-item label="名称" required>
          <a-input v-model:value="newKbForm.name" />
        </a-form-item>
        <a-form-item label="描述">
          <a-textarea v-model:value="newKbForm.description" />
        </a-form-item>
        <a-form-item label="分类">
          <a-select v-model:value="newKbForm.category">
            <a-select-option v-for="dict in kbTypeOptions" :key="dict.value" :value="dict.value">
              {{ dict.label }}
            </a-select-option>
          </a-select>
        </a-form-item>
      </a-form>
  </a-modal>
  <a-modal
    v-model:open="isRenameModalVisible"
    title="重命名文件"
    @ok="confirmRename"
  >
    <a-form layout="vertical">
      <a-form-item label="新名称" required>
        <a-input v-model:value="renameName" />
      </a-form-item>
    </a-form>
  </a-modal>
  <a-modal
    v-model:open="isMoveModalVisible"
    title="移动文件"
    @ok="confirmMove"
  >
    <a-form layout="vertical">
      <a-form-item label="目标文件夹">
        <a-tree-select
          v-model:value="targetFolderId"
          style="width: 100%"
          :dropdown-style="{ maxHeight: '400px', overflow: 'auto' }"
          :tree-data="folderTreeData"
          :load-data="onLoadFolderData"
          placeholder="请选择目标文件夹"
          tree-default-expand-all
        />
      </a-form-item>
    </a-form>
  </a-modal>
  <a-modal
    v-model:open="isNewFolderVisible"
    title="新建文件夹"
    @ok="handleNewFolderSubmit"
  >
    <a-form layout="vertical">
      <a-form-item label="文件夹名称" required>
        <a-input v-model:value="newFolderName" placeholder="请输入文件夹名称" @pressEnter="handleNewFolderSubmit" />
      </a-form-item>
    </a-form>
  </a-modal>
</div>
</template>

<script setup lang="ts">
import { ref, computed, reactive, nextTick, watch, onMounted, onUnmounted } from 'vue';
import { 
  PlusOutlined, 
  FolderOutlined, 
  CodeOutlined, 
  BookOutlined, 
  InboxOutlined,
  FileTextOutlined,
  SyncOutlined,
  CheckCircleOutlined,
  CheckOutlined,
  ExclamationCircleOutlined,
  UserOutlined,
  RobotOutlined,
  SendOutlined,
  AppstoreOutlined,
  BarsOutlined,
  ReloadOutlined,
  CloudUploadOutlined,
  FolderAddOutlined,
  DownloadOutlined,
  EllipsisOutlined,
  FileImageOutlined,
  FilePdfOutlined,
  FileWordOutlined,
  FileExcelOutlined,
  FilePptOutlined,
  FileZipOutlined,
  FileUnknownOutlined
} from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import { 
  getKbs, 
  createKb, 
  deleteKb, 
  getKbFiles, 
  uploadKbFile, 
  deleteKbFile, 
  createKbFolder, 
  getKbNodes, 
  getChatHistory, 
  // sendChatMessage,
  getAvailableModels,
  renameKbFile,
  moveKbFile,
  getKbFileDownloadUrl,
  getKbFolders
} from '../../api/kb';
import { getDictDataByCode, type DictDataDto } from '../../api/dict';
import type { TreeSelectProps } from 'ant-design-vue';
import type { 
  KbInfoDto, 
  KbFileDto, 
  KbNodeDto, 
  ChatMessageDto,
  SiliconModelDto
} from '../../types/kb';
import { usePermissionStore } from '@/stores/permission';
import MarkdownIt from 'markdown-it';
import hljs from 'highlight.js';
import 'highlight.js/styles/github.css'; // Or another style
import SplitLayout from '@/components/SplitLayout/index.vue';

// Markdown Setup
const md: any = new MarkdownIt({
  html: true,
  linkify: true,
  typographer: true,
  highlight: function (str: string, lang: string): string {
    if (lang && hljs.getLanguage(lang)) {
      try {
        return '<pre class="hljs"><code>' +
               hljs.highlight(str, { language: lang, ignoreIllegals: true }).value +
               '</code></pre>';
      } catch (__) {}
    }

    return '<pre class="hljs"><code>' + md.utils.escapeHtml(str) + '</code></pre>';
  }
});

const renderMarkdown = (text: string) => {
  return md.render(text);
};

// --- State ---
const permissionStore = usePermissionStore();
const isAdmin = computed(() => permissionStore.hasPermission('KBAdmin'));
const activeView = ref<'chat' | 'manage'>('chat');
const searchText = ref('');
const selectedKbKeys = ref<string[]>([]);
const isCreateModalVisible = ref(false);
// const activeTab = ref('files');
const fileList = ref([]); // Ant Design Upload fileList
const userInput = ref('');
const isThinking = ref(false);
// const chatHistoryRef = ref<HTMLElement | null>(null);
const chatBottomRef = ref<HTMLElement | null>(null);
const kbBodyRef = ref<HTMLElement | null>(null);
const splitWidth = ref(480);
const splitReady = ref(false);
const isDragOverlayVisible = ref(false);
const dragCounter = ref(0);
const viewMode = ref<'grid' | 'list'>('list');
const fileSearchText = ref('');
const selectedFiles = ref<string[]>([]);

const handleDragEnter = (e: DragEvent) => {
  console.log(e); // Use e to avoid unused variable
  dragCounter.value++;
  isDragOverlayVisible.value = true;
};

const handleDragLeave = (e: DragEvent) => {
  console.log(e); // Use e to avoid unused variable
  dragCounter.value--;
  if (dragCounter.value <= 0) {
    isDragOverlayVisible.value = false;
    dragCounter.value = 0;
  }
};

const handleDrop = (e: DragEvent) => {
  console.log(e); // Use e to avoid unused variable
  dragCounter.value = 0;
  isDragOverlayVisible.value = false;
};


// Data Refs
const kbs = ref<KbInfoDto[]>([]);
const currentKbFiles = ref<KbFileDto[]>([]);
const knowledgeTree = ref<KbNodeDto[]>([]);
const chatMessages = ref<ChatMessageDto[]>([]);
const selectedKnowledge = ref<KbNodeDto | null>(null);
const kbTypeOptions = ref<DictDataDto[]>([]);
const siliconModels = ref<DictDataDto[]>([]);
const selectedModel = ref<string>('');
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
const breadcrumbs = ref<{ id: string | null; name: string }[]>([{ id: null, name: '根目录' }]);
const folderTreeData = ref<TreeSelectProps['treeData']>([]);

const newKbForm = reactive({
  name: '',
  description: '',
  category: 'general'
});

// --- Computed ---
const filteredKbs = computed(() => {
  if (!searchText.value) return kbs.value;
  return kbs.value.filter(kb => kb.name.toLowerCase().includes(searchText.value.toLowerCase()));
});

const filteredKbFiles = computed(() => {
  let files = currentKbFiles.value;
  
  // Filter by folder
  // Only filter by folder if not searching (or maybe search within folder? usually search is global or current folder recursive)
  // Let's assume search is within current folder for now to match UI expectation, or global?
  // Drive.vue does search via API param.
  // Here we have all files in memory (client-side filtering).
  // If we want to show folder structure, we must filter by parentId.
  if (!fileSearchText.value) {
     files = files.filter(f => f.parentId === (currentFolderId.value || null));
  } else {
     // If searching, maybe show all matches? But flat list.
     files = files.filter(file => file.name.toLowerCase().includes(fileSearchText.value.toLowerCase()));
  }
  
  return files;
});

const currentKb = computed(() => {
  if (selectedKbKeys.value.length === 0) return null;
  return kbs.value.find(kb => kb.id === selectedKbKeys.value[0]) || null;
});

const fileColumns = [
  { title: '名称', dataIndex: 'name', key: 'name', ellipsis: true, sorter: (a: KbFileDto, b: KbFileDto) => a.name.localeCompare(b.name) },
  { title: '大小', dataIndex: 'size', key: 'size', width: 120, ellipsis: true },
  { title: '上传时间', dataIndex: 'uploadTime', key: 'uploadTime', width: 180, ellipsis: true },
  { title: '状态', key: 'status', width: 100 },
  { title: '操作', key: 'action', width: 120, align: 'center' },
];

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

const selectFile = (file: KbFileDto, event: MouseEvent) => {
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

const onSelectChange = (keys: string[]) => {
  selectedFiles.value = keys;
};

const customRow = (record: KbFileDto) => {
  return {
    onDblclick: () => viewFile(record),
    onContextmenu: (e: MouseEvent) => handleContextMenu(e, record)
  };
};

const handleContextMenu = (_e: MouseEvent, file: KbFileDto) => {
  if (!selectedFiles.value.includes(file.id)) {
    selectedFiles.value = [file.id];
  }
};

const refreshFileList = () => {
  if (currentKb.value) {
    fetchFiles(currentKb.value.id);
  }
};

// --- Lifecycle ---
onMounted(() => {
  fetchKbs();
  fetchDicts();
  nextTick(() => {
    if (kbBodyRef.value) {
      splitWidth.value = Math.round((kbBodyRef.value.clientWidth || 1000) / 2);
      splitReady.value = true;
    }
  });
});

const fetchDicts = async () => {
  try {
    const res = await getDictDataByCode('kb_type');
    kbTypeOptions.value = res || [];
    
    // Fetch models from SiliconFlow API via backend
    const modelRes = await getAvailableModels();
    siliconModels.value = modelRes.map((m: SiliconModelDto, index: number) => ({
      id: index, // dummy id
      dictTypeId: 0, 
      label: m.id,
      value: m.id,
      sort: index,
      isDefault: false,
      status: 'normal',
      createdAt: '',
      updatedAt: ''
    } as unknown as DictDataDto));
    
    if (siliconModels.value.length > 0) {
      // Default to DeepSeek V2.5 if available, otherwise first
      const defaultModel = siliconModels.value.find(m => m.value.includes('DeepSeek-V2.5'));
      selectedModel.value = defaultModel ? defaultModel.value : (siliconModels.value[0]?.value || '');
    }
  } catch (error) {
    console.error('Failed to fetch dicts or models:', error);
  }
};

// --- Watchers ---

// Fetch data when Current KB changes
watch(currentKb, (newKb) => {
  if (newKb) {
    // Always fetch chat history when switching KBs
    fetchChatHistory(newKb.id);
    fetchFiles(newKb.id);
    
    // Reset other views
    currentKbFiles.value = [];
    knowledgeTree.value = [];
    selectedKnowledge.value = null;
    
    // Reset folder state
    currentFolderId.value = null;
    breadcrumbs.value = [{ id: null, name: '根目录' }];

    // Measure container and show split
    nextTick(() => {
      try {
        if (kbBodyRef.value) {
          const w = kbBodyRef.value.clientWidth || 1000;
          splitWidth.value = Math.round(w / 2);
          splitReady.value = true;
        } else {
          splitReady.value = true; // fallback to show
        }
      } catch {
        splitReady.value = true;
      }
    });
  } else {
    chatMessages.value = [];
  }
});

// Fetch data when View/Tab changes
watch(activeView, (newView) => {
  if (!currentKb.value) return;
  if (newView === 'manage') {
    if (knowledgeTree.value.length === 0) {
      fetchNodes(currentKb.value.id);
    }
  }
});

// Switch back to chat view if user loses admin rights while in manage view
watch(isAdmin, (val) => {
  if (!val && activeView.value === 'manage') {
    activeView.value = 'chat';
    message.warning('权限变更：已切换回问答模式');
  }
});

// Scroll to bottom of chat
watch(chatMessages, () => {
  scrollToBottom();
}, { deep: true });

const startPolling = () => {
  if (pollInterval.value) return;
  pollInterval.value = window.setInterval(() => {
    if (currentKb.value) {
      getKbFiles(currentKb.value.id).then(res => {
         currentKbFiles.value = res;
      }).catch(() => {});
    }
  }, 3000);
};

const stopPolling = () => {
  if (pollInterval.value) {
    clearInterval(pollInterval.value);
    pollInterval.value = null;
  }
};

onUnmounted(() => {
  stopPolling();
});

// Auto-refresh when files are processing
watch(currentKbFiles, (files) => {
  const hasProcessing = files.some(f => f.status === 'processing' || f.status === 'uploading');
  if (hasProcessing) {
    startPolling();
  } else {
    stopPolling();
  }
}, { deep: true });

// --- Methods ---

const fetchKbs = async () => {
  try {
    const res = await getKbs();
    kbs.value = res;
    // Select first if none selected
    if (kbs.value.length > 0 && selectedKbKeys.value.length === 0) {
      selectedKbKeys.value = [kbs.value[0]!.id];
    }
  } catch (error) {
    console.error('Failed to fetch KBs:', error);
  }
};

const fetchFiles = async (kbId: string) => {
  try {
    const res = await getKbFiles(kbId);
    currentKbFiles.value = res;
  } catch (error) {
    console.error('Failed to fetch files:', error);
  }
};

const fetchNodes = async (kbId: string) => {
  try {
    const res = await getKbNodes(kbId);
    knowledgeTree.value = res;
  } catch (error) {
    console.error('Failed to fetch nodes:', error);
  }
};

const fetchChatHistory = async (kbId: string) => {
  try {
    const res = await getChatHistory(kbId);
    chatMessages.value = res;
    // If empty, add greeting
    if (chatMessages.value.length === 0 && currentKb.value) {
      chatMessages.value.push({
        role: 'ai',
        content: `您好！我是 ${currentKb.value.name} 知识助手。请问有什么可以帮您？`
      });
    }
  } catch (error) {
    console.error('Failed to fetch chat history:', error);
  }
};

const scrollToBottom = () => {
  nextTick(() => {
    if (chatBottomRef.value) {
      chatBottomRef.value.scrollIntoView({ behavior: 'smooth', block: 'end' });
    }
  });
};

const showCreateModal = () => {
  newKbForm.name = '';
  newKbForm.description = '';
  newKbForm.category = 'general';
  isCreateModalVisible.value = true;
};

const handleCreateKb = async () => {
  if (!newKbForm.name) {
    message.error('请输入知识库名称');
    return;
  }
  
  try {
    const res = await createKb({
      name: newKbForm.name,
      description: newKbForm.description,
      category: newKbForm.category,
      type: newKbForm.category === 'tech' ? 'code' : 'general'
    });
    
    kbs.value.push(res);
    selectedKbKeys.value = [res.id];
    activeView.value = 'chat';
    
    isCreateModalVisible.value = false;
    message.success('知识库创建成功');
  } catch (error) {
    console.error('Failed to create KB:', error);
    message.error('创建失败');
  }
};

const handleKbSelect = ({ key }: { key: string }) => {
  selectedKbKeys.value = [key];
  scrollToBottom();
};

const handleDeleteKb = async (id: string) => {
  try {
    await deleteKb(id);
    const index = kbs.value.findIndex(k => k.id === id);
    if (index !== -1) {
      kbs.value.splice(index, 1);
      if (selectedKbKeys.value[0] === id) {
        selectedKbKeys.value = [];
        if (kbs.value.length > 0) {
          selectedKbKeys.value = [kbs.value[0]!.id];
        }
      }
      message.success('已删除');
    }
  } catch (error) {
    console.error('Failed to delete KB:', error);
    message.error('删除失败');
  }
};

const fileInput = ref<HTMLInputElement | null>(null);

const triggerUpload = () => {
  fileInput.value?.click();
};

const handleFileInputChange = (e: Event) => {
  const target = e.target as HTMLInputElement;
  if (target.files) {
    Array.from(target.files).forEach(file => {
      handleCustomUpload({
        file: file,
        onSuccess: () => {},
        onError: () => {}
      });
    });
  }
  target.value = '';
};

const handleCustomUpload = async (options: any) => {
  const { file, onSuccess, onError } = options;
  if (!currentKb.value) return;

  try {
    // Optimistic UI update
    const tempFile: KbFileDto = {
      id: 'temp-' + Date.now(),
      name: file.name,
      size: (file.size / 1024 / 1024).toFixed(2) + ' MB',
      uploadTime: new Date().toLocaleString(),
      status: 'uploading',
      isFolder: false,
      parentId: currentFolderId.value
    };
    currentKbFiles.value.unshift(tempFile);

    const res = await uploadKbFile(currentKb.value.id, file, currentFolderId.value || undefined);
    
    // Replace temp with real
    const index = currentKbFiles.value.findIndex(f => f.id === tempFile.id);
    if (index !== -1) {
      currentKbFiles.value[index] = res;
    } else {
      currentKbFiles.value.unshift(res);
    }
    
    onSuccess(res, file);
    message.success(`${file.name} 上传成功`);
  } catch (error) {
    console.error('Upload failed:', error);
    // Remove temp
    const index = currentKbFiles.value.findIndex(f => f.id.startsWith('temp-') && f.name === file.name);
    if (index !== -1) {
      currentKbFiles.value.splice(index, 1);
    }
    onError(error);
    message.error(`${file.name} 上传失败`);
  }
};

const handleNewFolder = () => {
  newFolderName.value = '新建文件夹';
  isNewFolderVisible.value = true;
};

const handleNewFolderSubmit = async () => {
  if (!newFolderName.value) {
    message.warning('请输入文件夹名称');
    return;
  }
  if (!currentKb.value) return;

  try {
    const res = await createKbFolder(currentKb.value.id, {
      name: newFolderName.value,
      parentId: currentFolderId.value || undefined
    });
    currentKbFiles.value.unshift(res);
    isNewFolderVisible.value = false;
    message.success('创建成功');
  } catch (error) {
    console.error(error);
    message.error('创建失败');
  }
};

const handleFolderClick = (folder: KbFileDto) => {
  if (!folder.isFolder) return;
  currentFolderId.value = folder.id;
  breadcrumbs.value.push({ id: folder.id, name: folder.name });
  selectedFiles.value = [];
};

const handleBreadcrumbClick = (item: { id: string | null; name: string }, index: number) => {
  currentFolderId.value = item.id;
  breadcrumbs.value = breadcrumbs.value.slice(0, index + 1);
  selectedFiles.value = [];
};

const deleteFile = async (id: string) => {
  try {
    await deleteKbFile(id);
    const index = currentKbFiles.value.findIndex(f => f.id === id);
    if (index !== -1) {
      currentKbFiles.value.splice(index, 1);
      message.success('文件已删除');
    }
  } catch (error) {
    console.error('Failed to delete file:', error);
    message.error('删除失败');
  }
};

const viewFile = (file: KbFileDto) => {
  message.info(`预览文件: ${file.name}`);
};

const getStatusColor = (status: string) => {
  switch (status) {
    case 'ready': return 'success';
    case 'processing': return 'processing';
    case 'error': return 'error';
    default: return 'default';
  }
};

const getStatusText = (status: string) => {
  switch (status) {
    case 'ready': return '已就绪';
    case 'processing': return 'AI 解析中';
    case 'error': return '失败';
    case 'uploading': return '上传中';
    default: return status;
  }
};

const openRenameModal = (file: KbFileDto) => {
  renameTarget.value = file;
  renameName.value = file.name;
  isRenameModalVisible.value = true;
};

const confirmRename = async () => {
  if (!renameTarget.value || !currentKb.value) return;
  try {
    await renameKbFile(renameTarget.value.id, renameName.value.trim());
    await fetchFiles(currentKb.value.id);
    isRenameModalVisible.value = false;
    message.success('重命名成功');
  } catch (error) {
    message.error('重命名失败');
  }
};

const fetchRootFolders = async () => {
  if (!currentKb.value) return;
  try {
    const folders = await getKbFolders(currentKb.value.id);
    folderTreeData.value = [
      {
        title: '根目录',
        value: 'root',
        key: 'root',
        children: folders.map(f => ({
          title: f.name,
          value: f.id,
          key: f.id,
          isLeaf: false,
          pId: 'root'
        }))
      }
    ];
  } catch (error) {
    console.error('Failed to load root folders:', error);
  }
};

const onLoadFolderData = async (treeNode: any) => {
  const { value } = treeNode;
  if (!currentKb.value || value === 'root') {
    return;
  }
  
  try {
    const folders = await getKbFolders(currentKb.value.id, value);
    const children = folders.map(f => ({
      title: f.name,
      value: f.id,
      key: f.id,
      isLeaf: false,
      pId: value
    }));
    
    // Helper to update tree data recursively
    const updateTree = (data: any[]): any[] => {
      return data.map(node => {
        if (node.value === value) {
          return { ...node, children };
        }
        if (node.children) {
          return { ...node, children: updateTree(node.children) };
        }
        return node;
      });
    };
    
    folderTreeData.value = updateTree(folderTreeData.value as any[]);
  } catch (error) {
    console.error('Failed to load folders:', error);
  }
};

const openMoveModal = (file: KbFileDto) => {
  moveTarget.value = file;
  targetFolderId.value = undefined;
  fetchRootFolders();
  isMoveModalVisible.value = true;
};

const confirmMove = async () => {
  if (!moveTarget.value || !currentKb.value) return;
  try {
    const targetId = targetFolderId.value === 'root' ? undefined : targetFolderId.value;
    await moveKbFile(moveTarget.value.id, targetId);
    await fetchFiles(currentKb.value.id);
    isMoveModalVisible.value = false;
    message.success('移动成功');
  } catch (error) {
    message.error('移动失败');
  }
};

const downloadFile = (file: KbFileDto) => {
  const url = getKbFileDownloadUrl(file.id);
  window.open(url, '_blank');
};

// const onSelectKnowledge = async (selectedKeys: string[]) => {
//   if (selectedKeys.length > 0) {
//     const key = selectedKeys[0];
//     try {
//       // In a real app, we might fetch detail here if it wasn't fully loaded in tree
//       // For now, assuming tree has basic info, but let's simulate fetching detail if needed
//       // const res = await getKbNodeDetail(key); 
//       // selectedKnowledge.value = res;
      
//       // Since tree structure already has data, we find it
//       const findNode = (nodes: KbNodeDto[]): KbNodeDto | null => {
//         for (const node of nodes) {
//           if (node.key === key) return node;
//           if (node.children) {
//             const found = findNode(node.children);
//             if (found) return found;
//           }
//         }
//         return null;
//       };
//       selectedKnowledge.value = findNode(knowledgeTree.value);
//     } catch (error) {
//       console.error('Failed to get node detail:', error);
//     }
//   }
// };

// --- Chat Methods ---
const sendMessage = async () => {
  if (!userInput.value.trim() || !currentKb.value || isThinking.value) return;
  
  const question = userInput.value;
  const kbId = currentKb.value.id;
  
  // Optimistic update
  chatMessages.value.push({ role: 'user', content: question });
  
  userInput.value = '';
  isThinking.value = true;
  scrollToBottom();

  // Create AI Message Placeholder
  const aiMessageIndex = chatMessages.value.length;
  chatMessages.value.push({ role: 'ai', content: '' });

  try {
    // Use fetch for streaming
    const response = await fetch('/api/kb/chat/stream', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        // Add Authorization header if needed
      },
      body: JSON.stringify({
        kbId,
        message: question,
        model: selectedModel.value
      })
    });

    if (!response.ok) throw new Error(response.statusText);
    if (!response.body) throw new Error('No response body');

    const reader = response.body.getReader();
    const decoder = new TextDecoder("utf-8");
    let buffer = '';

    while (true) {
      const { done, value } = await reader.read();
      if (done) break;

      buffer += decoder.decode(value, { stream: true });
      const lines = buffer.split('\n');
      buffer = lines.pop() || ''; // Keep the last incomplete line

      for (const line of lines) {
        if (line.trim() === '') continue;
        if (line.startsWith('data: ')) {
          const data = line.slice(6);
          if (data === '[DONE]') break;
          
          try {
            const parsed = JSON.parse(data);
            if (parsed.content) {
              // Hide thinking state on first content received
              if (isThinking.value) {
                isThinking.value = false;
              }
              if (chatMessages.value[aiMessageIndex]) {
                  chatMessages.value[aiMessageIndex].content += parsed.content;
              }
              scrollToBottom();
            }
          } catch (e) {
            console.error('Error parsing SSE data:', e);
          }
        }
      }
    }
  } catch (error) {
    console.error('Chat error:', error);
    if (chatMessages.value[aiMessageIndex]) {
        chatMessages.value[aiMessageIndex].content += '\n[发生错误，请稍后重试]';
    }
  } finally {
    isThinking.value = false;
    scrollToBottom();
  }
};
</script>

<style scoped>
.kb-container {
  flex: 1;
  background-color: #f0f2f5;
  padding: 0;
  overflow: hidden;
}

.kb-sider {
  height: 100%;
  background: #fff;
  border-right: 1px solid #e8e8e8;
  display: flex;
  flex-direction: column;
}

.sider-header {
  padding: 16px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid #f0f0f0;
}

.title {
  font-weight: 600;
  font-size: 16px;
}

.search-box {
  padding: 12px;
}

.kb-menu {
  flex: 1;
  overflow-y: auto;
  border-right: none;
}

.sider-footer {
  padding: 12px;
  border-top: 1px solid #f0f0f0;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  background: #fafafa;
}

.role-text {
  font-size: 12px;
  color: #666;
}

.kb-content {
  background: #fff;
  padding: 0;
  height: 100%;
  display: flex;
  flex-direction: column;
  overflow: hidden; /* Prevent page scroll */
}

.kb-detail {
  display: flex;
  flex-direction: column;
  flex: 1;
  overflow: hidden;
}

.kb-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 0;
  border-bottom: 1px solid #f0f0f0;
  padding: 12px;
  padding-bottom: 0;
}

.kb-body {
  display: flex;
  gap: 24px;
  height: 100%;
}

.file-explorer {
  height: 100%;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  position: relative;
}

.file-table {
  flex: 1;
  overflow: hidden;
}

.file-table :deep(.ant-spin-nested-loading),
.file-table :deep(.ant-spin-container),
.file-table :deep(.ant-table),
.file-table :deep(.ant-table-container),
.file-table :deep(.ant-table-content),
.file-table :deep(.ant-table-body),
.file-table :deep(.ant-table-tbody) {
  height: 100%;
}

.file-table :deep(table) {
  height: 100%;
  width: 100%;
}

.file-table :deep(.ant-table-body) {
  overflow-y: auto !important;
}

.file-table :deep(.ant-table-placeholder) {
  height: 100% !important;
  width: 100% !important;
  /* Remove flex from tr to keep table layout behavior for width */
}

.file-table :deep(.ant-table-placeholder .ant-table-cell) {
  border-bottom: none !important;
  height: 100% !important;
  display: flex !important;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}

.file-table :deep(.ant-table-header) {
  overflow: hidden !important;
  margin-bottom: 0 !important;
  padding-bottom: 0 !important;
  flex-shrink: 0;
}

.chat-panel {
  border-left: 1px solid #f0f0f0;
  display: flex;
  flex-direction: column;
  height: 100%;
  overflow: hidden;
}

.header-left h2 {
  margin-bottom: 8px;
  font-size: 24px;
  font-weight: 600;
}

.description {
  color: #666;
  margin: 0;
}

/* Chat View Styles */
.chat-view {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  max-width: 900px;
  margin: 0 auto;
  width: 100%;
}

.chat-history {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.chat-message {
  display: flex;
  gap: 12px;
}

.chat-message.user {
  flex-direction: row-reverse;
}

.chat-message .avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: #e6f7ff;
  color: #1890ff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  flex-shrink: 0;
}

.chat-message.user .avatar {
  background: #f5f5f5;
  color: #555;
}

.message-content {
  max-width: 70%;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.bubble {
  padding: 12px 16px;
  border-radius: 12px;
  line-height: 1.5;
  font-size: 14px;
  background: #f5f5f5;
  color: #333;
}

.chat-message.user .bubble {
  background: #1890ff;
  color: #fff;
  border-radius: 12px 0 12px 12px;
}

.chat-message.ai .bubble {
  background: #f7f7f7;
  border: 1px solid #eee;
  border-radius: 0 12px 12px 12px;
}

/* Markdown Styles inside bubble */
.markdown-body :deep(p) {
  margin-bottom: 12px;
}
.markdown-body :deep(p:last-child) {
  margin-bottom: 0;
}
.markdown-body :deep(pre) {
  background: #2d2d2d;
  color: #ccc;
  padding: 12px;
  border-radius: 6px;
  overflow-x: auto;
  margin: 12px 0;
}
.markdown-body :deep(code) {
  background: rgba(0,0,0,0.05);
  padding: 2px 4px;
  border-radius: 4px;
  font-family: monospace;
}
.markdown-body :deep(pre code) {
  background: transparent;
  padding: 0;
  color: inherit;
}
.markdown-body :deep(ul), .markdown-body :deep(ol) {
  padding-left: 20px;
  margin-bottom: 12px;
}
.markdown-body :deep(h1), .markdown-body :deep(h2), .markdown-body :deep(h3) {
  margin-top: 16px;
  margin-bottom: 8px;
  font-weight: 600;
  line-height: 1.4;
}
.markdown-body :deep(a) {
  color: #1890ff;
}
.chat-message.user .markdown-body :deep(a) {
  color: #fff;
  text-decoration: underline;
}

.bubble.thinking {
  color: #999;
  font-style: italic;
}

.citations {
  font-size: 12px;
  color: #666;
}

.citation-title {
  margin-right: 8px;
  font-weight: 500;
}

.citation-tag {
  cursor: pointer;
}

.chat-input {
  padding: 8px;
  background: #fff;
  border-top: 1px solid #f0f0f0;
  display: flex;
  gap: 8px;
  align-items: flex-end;
}

.send-btn {
  height: auto;
  padding: 8px 24px;
}

/* Manage View Styles */
.manage-view {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.tab-toolbar {
  padding: 8px;
}

.upload-overlay {
  position: absolute;
  inset: 0;
  z-index: 10;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(24, 144, 255, 0.08);
  border: 2px dashed #1890ff;
  border-radius: 8px;
}

.upload-overlay :deep(.ant-upload) {
  width: 100%;
  height: 100%;
  padding: 0;
}

.upload-overlay :deep(.ant-upload-btn) {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  padding: 0 !important;
}

.upload-overlay :deep(.ant-upload-drag-container) {
  display: flex !important;
  flex-direction: column;
  justify-content: center;
  height: 100%;
  width: 100%;
}

.upload-area {
  padding: 20px 0;
  background: #fafafa;
  border: 1px dashed #d9d9d9;
  border-radius: 4px;
  margin-bottom: 24px;
}

.catalog-view {
  height: 100%;
}

.catalog-card, .detail-card {
  height: 600px;
  overflow-y: auto;
}

.knowledge-detail {
  padding: 0 16px;
}

.ai-badge {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  background: linear-gradient(90deg, #e6f7ff 0%, #f0f5ff 100%);
  color: #1890ff;
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 12px;
  margin-bottom: 16px;
}

.summary {
  font-size: 14px;
  color: #595959;
  line-height: 1.6;
  background: #fafafa;
  padding: 12px;
  border-radius: 4px;
  border-left: 3px solid #1890ff;
}

.empty-selection {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100%;
}

.file-list-container {
  flex: 1;
  overflow-y: auto;
}

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

.explorer-layout {
  display: flex;
  flex-direction: column;
  height: 100%;
  overflow: hidden;
}

.main-header {
  height: 56px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 16px;
  border-bottom: 1px solid #f0f0f0;
  flex-shrink: 0;
  background: #fff;
}

.breadcrumb-area {
  flex: 1;
  overflow: hidden;
  white-space: nowrap;
  text-overflow: ellipsis;
  margin-right: 16px;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}
</style>
