<template>
  <div class="kb-container">
    <a-layout style="height: 100%">
      <!-- Left Sidebar: Knowledge Base List -->
      <a-layout-sider width="280" theme="light" class="kb-sider">
        <div class="sider-header">
          <span class="title">知识库</span>
          <a-tooltip title="仅管理员可新建">
            <a-button type="primary" size="small" @click="showCreateModal" :disabled="!isAdmin">
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
        
        <!-- Admin Toggle (Simulation) -->
        <div class="sider-footer">
          <a-switch v-model:checked="isAdmin" checked-children="Admin" un-checked-children="User" />
          <span class="role-text">{{ isAdmin ? '管理员视图' : '普通用户视图' }}</span>
        </div>
      </a-layout-sider>

      <!-- Main Content Area -->
      <a-layout-content class="kb-content">
        <div v-if="currentKb" class="kb-detail">
          <!-- Header -->
          <div class="kb-header">
            <div class="header-left">
              <h2>{{ currentKb.name }}</h2>
              <p class="description">{{ currentKb.description }}</p>
            </div>
            <div class="header-right">
              <a-radio-group v-model:value="activeView" button-style="solid">
                <a-radio-button value="chat">
                  <template #icon><MessageOutlined /></template>
                  问答检索
                </a-radio-button>
                <a-radio-button value="manage" v-if="isAdmin">
                  <template #icon><SettingOutlined /></template>
                  内容管理
                </a-radio-button>
              </a-radio-group>
            </div>
          </div>

          <!-- View: Chat / QA -->
          <div v-if="activeView === 'chat'" class="chat-view">
            <div class="chat-history" ref="chatHistoryRef">
              <div v-for="(msg, index) in chatMessages" :key="index" :class="['chat-message', msg.role]">
                <div class="avatar">
                  <UserOutlined v-if="msg.role === 'user'" />
                  <RobotOutlined v-else />
                </div>
                <div class="message-content">
                  <div class="bubble" v-html="msg.content"></div>
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
                  <div class="bubble thinking">SiliconFlow AI 正在思考中...</div>
                </div>
              </div>
            </div>
            
            <div class="chat-input">
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

          <!-- View: Management (Files & Catalog) - Only for Admin -->
          <div v-else-if="activeView === 'manage' && isAdmin" class="manage-view">
             <a-tabs v-model:activeKey="activeTab">
              <!-- Files Tab -->
              <a-tab-pane key="files" tab="文件管理">
                <div class="tab-toolbar">
                  <a-upload-dragger
                    v-model:fileList="fileList"
                    name="file"
                    :multiple="true"
                    :customRequest="handleCustomUpload"
                    :showUploadList="false"
                    class="upload-area"
                  >
                    <p class="ant-upload-drag-icon">
                      <InboxOutlined />
                    </p>
                    <p class="ant-upload-text">点击或拖拽文件到此处上传</p>
                    <p class="ant-upload-hint">支持 PDF, Word, Markdown, TXT, 图片等格式</p>
                  </a-upload-dragger>
                </div>

                <a-table 
                  :columns="fileColumns" 
                  :data-source="currentKbFiles" 
                  :pagination="false"
                  rowKey="id"
                >
                  <template #bodyCell="{ column, record }">
                    <template v-if="column.key === 'name'">
                      <a-space>
                        <FileTextOutlined />
                        {{ record.name }}
                      </a-space>
                    </template>
                    <template v-else-if="column.key === 'status'">
                      <a-tag :color="getStatusColor(record.status)">
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
                        <a-button type="link" size="small" @click="viewFile(record)">查看</a-button>
                        <a-popconfirm title="确定删除吗?" @confirm="deleteFile(record.id)">
                          <a-button type="link" danger size="small">删除</a-button>
                        </a-popconfirm>
                      </a-space>
                    </template>
                  </template>
                </a-table>
              </a-tab-pane>

              <!-- Knowledge Catalog Tab (Auto-generated) -->
              <a-tab-pane key="catalog" tab="知识目录">
                <div class="catalog-view">
                  <a-row :gutter="24">
                    <a-col :span="8">
                      <a-card title="知识点索引" class="catalog-card">
                        <a-tree
                          :tree-data="knowledgeTree"
                          :defaultExpandAll="true"
                          @select="onSelectKnowledge"
                        >
                          <template #title="{ title }">
                            <span>{{ title }}</span>
                          </template>
                        </a-tree>
                      </a-card>
                    </a-col>
                    <a-col :span="16">
                      <a-card title="知识详情 (AI 生成)" class="detail-card">
                        <div v-if="selectedKnowledge" class="knowledge-detail">
                          <h3>{{ selectedKnowledge.title }}</h3>
                          <div class="ai-badge">
                            <ThunderboltOutlined /> Generated by SiliconFlow AI
                          </div>
                          <p class="summary">{{ selectedKnowledge.summary }}</p>
                          
                          <a-divider orientation="left">来源关联</a-divider>
                          <div class="sources">
                            <a-tag v-for="source in selectedKnowledge.sources" :key="source.fileId" color="cyan">
                              <FileOutlined /> {{ source.fileName }} (P.{{ source.page }})
                            </a-tag>
                          </div>
                          
                          <a-divider orientation="left">详细描述</a-divider>
                          <div class="content" v-html="selectedKnowledge.content"></div>
                        </div>
                        <div v-else class="empty-state">
                          <a-empty description="请从左侧选择一个知识点查看详情" />
                        </div>
                      </a-card>
                    </a-col>
                  </a-row>
                </div>
              </a-tab-pane>
            </a-tabs>
          </div>
        </div>
        <div v-else class="empty-selection">
          <a-empty description="请选择一个知识库开始问答" />
        </div>
      </a-layout-content>
    </a-layout>

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
            <a-select-option value="general">通用文档</a-select-option>
            <a-select-option value="tech">技术文档</a-select-option>
            <a-select-option value="hr">人事行政</a-select-option>
            <a-select-option value="project">项目资料</a-select-option>
          </a-select>
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, reactive, nextTick, watch, onMounted } from 'vue';
import { 
  PlusOutlined, 
  FolderOutlined, 
  CodeOutlined, 
  BookOutlined, 
  SettingOutlined,
  InboxOutlined,
  FileTextOutlined,
  SyncOutlined,
  CheckCircleOutlined,
  ExclamationCircleOutlined,
  FileOutlined,
  ThunderboltOutlined,
  MessageOutlined,
  UserOutlined,
  RobotOutlined,
  SendOutlined
} from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import { 
  getKbs, 
  createKb, 
  deleteKb, 
  getKbFiles, 
  uploadKbFile, 
  deleteKbFile, 
  getKbNodes, 
  getChatHistory, 
  sendChatMessage 
} from '../../api/kb';
import type { 
  KbInfoDto, 
  KbFileDto, 
  KbNodeDto, 
  ChatMessageDto 
} from '../../types/kb';

// --- State ---
const isAdmin = ref(true); // Toggle for demo purposes
const activeView = ref<'chat' | 'manage'>('chat');
const searchText = ref('');
const selectedKbKeys = ref<string[]>([]);
const isCreateModalVisible = ref(false);
const activeTab = ref('files');
const fileList = ref([]); // Ant Design Upload fileList
const userInput = ref('');
const isThinking = ref(false);
const chatHistoryRef = ref<HTMLElement | null>(null);

// Data Refs
const kbs = ref<KbInfoDto[]>([]);
const currentKbFiles = ref<KbFileDto[]>([]);
const knowledgeTree = ref<KbNodeDto[]>([]);
const chatMessages = ref<ChatMessageDto[]>([]);
const selectedKnowledge = ref<KbNodeDto | null>(null);

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

const currentKb = computed(() => {
  if (selectedKbKeys.value.length === 0) return null;
  return kbs.value.find(kb => kb.id === selectedKbKeys.value[0]) || null;
});

const fileColumns = [
  { title: '文件名', key: 'name', width: '40%' },
  { title: '大小', dataIndex: 'size', key: 'size', width: '15%' },
  { title: '上传时间', dataIndex: 'uploadTime', key: 'uploadTime', width: '25%' },
  { title: '状态', key: 'status', width: '20%' }, // Uploading -> AI Processing -> Ready
  { title: '操作', key: 'action', width: '150px' },
];

// --- Lifecycle ---
onMounted(() => {
  fetchKbs();
});

// --- Watchers ---

// Fetch data when Current KB changes
watch(currentKb, (newKb) => {
  if (newKb) {
    // Always fetch chat history when switching KBs
    fetchChatHistory(newKb.id);
    
    // Reset other views
    currentKbFiles.value = [];
    knowledgeTree.value = [];
    selectedKnowledge.value = null;

    // Fetch management data if in manage view
    if (activeView.value === 'manage') {
      if (activeTab.value === 'files') fetchFiles(newKb.id);
      if (activeTab.value === 'catalog') fetchNodes(newKb.id);
    }
  } else {
    chatMessages.value = [];
  }
});

// Fetch data when View/Tab changes
watch([activeView, activeTab], ([newView, newTab]) => {
  if (!currentKb.value) return;
  
  if (newView === 'manage') {
    if (newTab === 'files' && currentKbFiles.value.length === 0) {
      fetchFiles(currentKb.value.id);
    } else if (newTab === 'catalog' && knowledgeTree.value.length === 0) {
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
    if (chatHistoryRef.value) {
      chatHistoryRef.value.scrollTop = chatHistoryRef.value.scrollHeight;
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
  activeView.value = 'chat';
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
      status: 'uploading'
    };
    currentKbFiles.value.unshift(tempFile);

    const res = await uploadKbFile(currentKb.value.id, file);
    
    // Replace temp file with real one
    const index = currentKbFiles.value.findIndex(f => f.id === tempFile.id);
    if (index !== -1) {
      currentKbFiles.value[index] = res;
    } else {
      currentKbFiles.value.unshift(res);
    }
    
    message.success(`${file.name} 上传成功，正在进行 AI 解析...`);
    onSuccess("ok");
    
    // Poll for status or reload after delay (Simulated for now, ideally use WebSocket)
    setTimeout(() => {
      if (currentKb.value) fetchFiles(currentKb.value.id);
    }, 2000);

  } catch (error) {
    console.error('Upload failed:', error);
    const index = currentKbFiles.value.findIndex(f => f.name === file.name && f.status === 'uploading');
    if (index !== -1) {
       currentKbFiles.value[index]!.status = 'error';
    }
    onError(error);
    message.error('文件上传失败');
  }
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

const onSelectKnowledge = async (selectedKeys: string[]) => {
  if (selectedKeys.length > 0) {
    const key = selectedKeys[0];
    try {
      // In a real app, we might fetch detail here if it wasn't fully loaded in tree
      // For now, assuming tree has basic info, but let's simulate fetching detail if needed
      // const res = await getKbNodeDetail(key); 
      // selectedKnowledge.value = res;
      
      // Since tree structure already has data, we find it
      const findNode = (nodes: KbNodeDto[]): KbNodeDto | null => {
        for (const node of nodes) {
          if (node.key === key) return node;
          if (node.children) {
            const found = findNode(node.children);
            if (found) return found;
          }
        }
        return null;
      };
      selectedKnowledge.value = findNode(knowledgeTree.value);
    } catch (error) {
      console.error('Failed to get node detail:', error);
    }
  }
};

// --- Chat Methods ---
const sendMessage = async () => {
  if (!userInput.value.trim() || !currentKb.value) return;
  
  const question = userInput.value;
  const kbId = currentKb.value.id;
  
  // Optimistic update
  chatMessages.value.push({ role: 'user', content: question });
  
  userInput.value = '';
  isThinking.value = true;
  scrollToBottom();

  try {
    const res = await sendChatMessage({
      kbId,
      message: question
    });
    
    chatMessages.value.push(res);
  } catch (error) {
    console.error('Failed to send message:', error);
    chatMessages.value.push({
      role: 'ai',
      content: '抱歉，我现在无法回答您的问题，请稍后再试。'
    });
  } finally {
    isThinking.value = false;
    scrollToBottom();
  }
};
</script>

<style scoped>
.kb-container {
  height: 100%;
  background-color: #f0f2f5;
  padding: 16px;
}

.kb-sider {
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
  margin-left: 16px;
  padding: 24px;
  display: flex;
  flex-direction: column;
}

.kb-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 24px;
  border-bottom: 1px solid #f0f0f0;
  padding-bottom: 16px;
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
  padding: 20px;
  background: #fff;
  border-top: 1px solid #f0f0f0;
  display: flex;
  gap: 12px;
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
  margin-bottom: 16px;
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
</style>
