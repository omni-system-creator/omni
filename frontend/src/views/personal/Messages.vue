<template>
  <div class="messages-container">
    <!-- 左侧会话列表 -->
    <div class="messages-sider">
      <div class="sider-header">
        <a-input-search v-model:value="searchText" placeholder="搜索消息、联系人、群组" allow-clear />
      </div>
      <div class="conversation-list">
        <a-list :data-source="filteredConversations" :split="false">
          <template #renderItem="{ item }">
            <div 
              :class="['conversation-item', { active: currentConversation?.id === item.id }]"
              @click="selectConversation(item)"
            >
              <div class="item-avatar">
                <a-badge :count="item.unreadCount" :dot="item.unreadCount > 0 && item.unreadCount < 10" :offset="[-5, 5]">
                  <a-avatar 
                    :size="40" 
                    :shape="item.type === 'system' || item.type === 'business' ? 'square' : 'circle'"
                    :style="{ backgroundColor: item.bgColor, color: '#fff' }"
                  >
                    <template #icon>
                      <img v-if="item.avatar" :src="item.avatar" />
                      <component v-else :is="item.icon" />
                    </template>
                  </a-avatar>
                </a-badge>
              </div>
              <div class="item-content">
                <div class="item-top">
                  <span class="item-name">{{ item.name }}</span>
                  <span class="item-time">{{ formatTime(item.lastTime) }}</span>
                </div>
                <div class="item-bottom">
                  <span class="item-msg">{{ item.lastMessage }}</span>
                </div>
              </div>
            </div>
          </template>
        </a-list>
      </div>
    </div>

    <!-- 右侧内容区域 -->
    <div class="messages-main">
      <div v-if="currentConversation" class="conversation-content">
        <!-- 头部 -->
        <div class="main-header">
          <div class="header-info">
            <span class="header-title">{{ currentConversation.name }}</span>
            <span v-if="currentConversation.type === 'group'" class="header-count">({{ currentConversation.memberCount }}人)</span>
            <a-tag v-if="currentConversation.type === 'business'" color="blue">业务通知</a-tag>
            <a-tag v-if="currentConversation.type === 'system'" color="orange">系统消息</a-tag>
          </div>
          <div class="header-actions">
            <a-button type="text" shape="circle">
              <template #icon><EllipsisOutlined /></template>
            </a-button>
          </div>
        </div>

        <!-- 聊天模式视图 -->
        <div v-if="['private', 'group'].includes(currentConversation.type)" class="chat-view">
          <div class="message-list" ref="messageListRef">
            <div v-for="msg in currentMessages" :key="msg.id" :class="['message-bubble', { 'is-self': msg.isSelf }]">
              <div class="msg-time" v-if="msg.showTime">{{ formatTime(msg.timestamp) }}</div>
              <div class="msg-content-wrapper">
                <a-avatar v-if="!msg.isSelf" :src="msg.senderAvatar" class="msg-avatar" />
                <div class="msg-body">
                  <div v-if="!msg.isSelf && currentConversation.type === 'group'" class="sender-name">{{ msg.senderName }}</div>
                  
                  <div class="bubble-content">
                    <!-- 文本消息 -->
                    <span v-if="msg.type === 'text'">{{ msg.content }}</span>
                    
                    <!-- 图片消息 -->
                    <a-image v-else-if="msg.type === 'image'" :src="msg.content" :width="150" />
                    
                    <!-- 文件消息 -->
                    <div v-else-if="msg.type === 'file'" class="file-message">
                      <FileOutlined class="file-icon" />
                      <div class="file-info">
                        <div class="file-name">{{ msg.fileName }}</div>
                        <div class="file-size">{{ msg.fileSize }}</div>
                      </div>
                    </div>
                  </div>
                </div>
                <a-avatar v-if="msg.isSelf" :src="userAvatar" class="msg-avatar" />
              </div>
            </div>
          </div>
          
          <div class="chat-input">
            <div class="toolbar">
              <a-tooltip title="表情"><SmileOutlined class="tool-icon" /></a-tooltip>
              <a-tooltip title="图片">
                <label class="upload-label">
                  <PictureOutlined class="tool-icon" />
                  <input type="file" accept="image/*" @change="handleImageUpload" style="display: none" />
                </label>
              </a-tooltip>
              <a-tooltip title="文件">
                <label class="upload-label">
                  <FolderOpenOutlined class="tool-icon" />
                  <input type="file" @change="handleFileUpload" style="display: none" />
                </label>
              </a-tooltip>
            </div>
            <a-textarea 
              v-model:value="inputMessage" 
              placeholder="按 Enter 发送，Ctrl + Enter 换行" 
              :auto-size="{ minRows: 3, maxRows: 5 }"
              @keydown.enter.prevent="handleSend"
            />
            <div class="send-action">
              <span class="tip">Ctrl + Enter 换行</span>
              <a-button type="primary" @click="handleSend">发送</a-button>
            </div>
          </div>
        </div>

        <!-- 通知模式视图 -->
        <div v-else class="notification-view">
          <a-list :data-source="currentMessages" item-layout="horizontal">
            <template #renderItem="{ item }">
              <a-list-item>
                <a-list-item-meta>
                  <template #title>
                    <span>
                      <span class="notify-title">{{ item.title }}</span>
                      <span class="notify-time">{{ formatTime(item.timestamp) }}</span>
                    </span>
                  </template>
                  <template #description>
                    <div>
                      <div class="notify-desc">{{ item.content }}</div>
                      <div v-if="item.actionText" class="notify-action">
                        <a-button type="link" size="small">{{ item.actionText }}</a-button>
                      </div>
                    </div>
                  </template>
                  <template #avatar>
                    <a-avatar :style="{ backgroundColor: item.level === 'urgent' ? '#ff4d4f' : '#1890ff' }">
                      <template #icon>
                        <AlertOutlined v-if="item.level === 'urgent'" />
                        <InfoCircleOutlined v-else />
                      </template>
                    </a-avatar>
                  </template>
                </a-list-item-meta>
              </a-list-item>
            </template>
          </a-list>
        </div>
      </div>

      <!-- 空状态 -->
      <div v-else class="empty-state">
        <a-empty description="选择一个会话开始交流" />
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { ref, computed, reactive, nextTick, watch } from 'vue';
import { 
  TeamOutlined, 
  BellOutlined, 
  AppstoreOutlined, 
  EllipsisOutlined,
  SmileOutlined,
  PictureOutlined,
  FolderOpenOutlined,
  FileOutlined,
  AlertOutlined,
  InfoCircleOutlined
} from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';

// --- 类型定义 ---
type ConversationType = 'system' | 'business' | 'private' | 'group';
type MessageType = 'text' | 'image' | 'file';

interface Conversation {
  id: string;
  type: ConversationType;
  name: string;
  avatar?: string;
  icon?: any;
  bgColor?: string;
  lastMessage: string;
  lastTime: string;
  unreadCount: number;
  memberCount?: number;
}

interface Message {
  id: string;
  senderId: string;
  senderName?: string;
  senderAvatar?: string;
  content: string;
  type: MessageType;
  timestamp: string;
  isSelf: boolean;
  showTime?: boolean;
  fileName?: string;
  fileSize?: string;
  title?: string; // For notifications
  level?: 'normal' | 'urgent'; // For notifications
  actionText?: string; // For notifications
}

// --- 状态 ---
const searchText = ref('');
const currentConversation = ref<Conversation | null>(null);
const inputMessage = ref('');
const messageListRef = ref<HTMLDivElement | null>(null);
const userAvatar = 'https://randomuser.me/api/portraits/men/1.jpg'; // 当前用户头像

// --- Mock 数据 ---
const conversations = ref<Conversation[]>([
  {
    id: 'sys',
    type: 'system',
    name: '系统消息',
    icon: BellOutlined,
    bgColor: '#faad14',
    lastMessage: '系统维护通知：本周六凌晨2点进行升级',
    lastTime: '2023-10-25 10:00:00',
    unreadCount: 2
  },
  {
    id: 'biz',
    type: 'business',
    name: '业务审批提醒',
    icon: AppstoreOutlined,
    bgColor: '#1890ff',
    lastMessage: '您有一条新的报销申请待审批',
    lastTime: '2023-10-25 09:30:00',
    unreadCount: 5
  },
  {
    id: 'u1',
    type: 'private',
    name: '李四 (研发总监)',
    avatar: 'https://randomuser.me/api/portraits/men/32.jpg',
    lastMessage: '好的，我稍后看一下',
    lastTime: '10:45',
    unreadCount: 0
  },
  {
    id: 'u2',
    type: 'private',
    name: '王五 (前端主管)',
    avatar: 'https://randomuser.me/api/portraits/women/44.jpg',
    lastMessage: '这个组件的样式有点问题',
    lastTime: '昨天',
    unreadCount: 1
  },
  {
    id: 'g1',
    type: 'group',
    name: '前端开发组',
    icon: TeamOutlined,
    bgColor: '#52c41a',
    lastMessage: '赵六: 大家下午茶点了吗？',
    lastTime: '15:20',
    unreadCount: 12,
    memberCount: 8
  },
  {
    id: 'g2',
    type: 'group',
    name: '项目攻坚小组',
    icon: TeamOutlined,
    bgColor: '#722ed1',
    lastMessage: '张三: 今晚开个短会',
    lastTime: '11:00',
    unreadCount: 0,
    memberCount: 15
  }
]);

// 消息记录 Mock
const messagesMap = reactive<Record<string, Message[]>>({
  'sys': [
    { id: 's1', senderId: 'sys', title: '系统维护通知', content: '系统将于本周六凌晨2:00-4:00进行服务器升级维护，期间无法访问，请提前保存工作内容。', type: 'text', timestamp: '2023-10-25 10:00:00', isSelf: false, level: 'urgent' },
    { id: 's2', senderId: 'sys', title: '安全提醒', content: '检测到您的账号在异地登录，如非本人操作请及时修改密码。', type: 'text', timestamp: '2023-10-24 15:30:00', isSelf: false, level: 'urgent', actionText: '修改密码' },
    { id: 's3', senderId: 'sys', title: '版本更新', content: 'OMS系统 V2.1.0 版本已发布，新增了即时通讯功能。', type: 'text', timestamp: '2023-10-20 09:00:00', isSelf: false, level: 'normal', actionText: '查看详情' },
  ],
  'biz': [
    { id: 'b1', senderId: 'oa', title: '报销审批', content: '您提交的【10月差旅费】报销申请已被财务审核通过。', type: 'text', timestamp: '2023-10-25 09:30:00', isSelf: false, level: 'normal', actionText: '查看详情' },
    { id: 'b2', senderId: 'crm', title: '新客户分配', content: '销售总监分配给您一个新的潜在客户：杭州科技技术有限公司。', type: 'text', timestamp: '2023-10-24 14:20:00', isSelf: false, level: 'normal', actionText: '去跟进' },
  ],
  'u1': [
    { id: 'm1', senderId: 'u1', senderName: '李四', senderAvatar: 'https://randomuser.me/api/portraits/men/32.jpg', content: '张工，上周那个API接口文档更新了吗？', type: 'text', timestamp: '2023-10-25 10:30:00', isSelf: false, showTime: true },
    { id: 'm2', senderId: 'me', content: '已经更新了，在Wiki上可以看到。', type: 'text', timestamp: '2023-10-25 10:32:00', isSelf: true },
    { id: 'm3', senderId: 'u1', senderName: '李四', senderAvatar: 'https://randomuser.me/api/portraits/men/32.jpg', content: '好的，我稍后看一下', type: 'text', timestamp: '2023-10-25 10:45:00', isSelf: false },
  ],
  'g1': [
    { id: 'gm1', senderId: 'u2', senderName: '王五', senderAvatar: 'https://randomuser.me/api/portraits/women/44.jpg', content: '@所有人 下周一要进行代码评审，请大家准备好。', type: 'text', timestamp: '2023-10-25 14:00:00', isSelf: false, showTime: true },
    { id: 'gm2', senderId: 'u3', senderName: '赵六', senderAvatar: 'https://randomuser.me/api/portraits/men/46.jpg', content: '收到', type: 'text', timestamp: '2023-10-25 14:05:00', isSelf: false },
    { id: 'gm3', senderId: 'me', content: '收到，PPT模板有吗？', type: 'text', timestamp: '2023-10-25 14:10:00', isSelf: true },
    { id: 'gm4', senderId: 'u2', senderName: '王五', senderAvatar: 'https://randomuser.me/api/portraits/women/44.jpg', content: '有的，发群里了', type: 'text', timestamp: '2023-10-25 14:12:00', isSelf: false },
    { id: 'gm5', senderId: 'u2', senderName: '王五', senderAvatar: 'https://randomuser.me/api/portraits/women/44.jpg', content: 'code_review_template.pptx', fileName: 'code_review_template.pptx', fileSize: '2.5MB', type: 'file', timestamp: '2023-10-25 14:12:05', isSelf: false },
    { id: 'gm6', senderId: 'u3', senderName: '赵六', senderAvatar: 'https://randomuser.me/api/portraits/men/46.jpg', content: '大家下午茶点了吗？', type: 'text', timestamp: '2023-10-25 15:20:00', isSelf: false, showTime: true },
  ]
});

// --- 计算属性 ---
const filteredConversations = computed(() => {
  if (!searchText.value) return conversations.value;
  return conversations.value.filter(c => c.name.includes(searchText.value));
});

const currentMessages = computed(() => {
  if (!currentConversation.value) return [];
  return messagesMap[currentConversation.value.id] || [];
});

// --- 方法 ---
const formatTime = (timeStr: string) => {
  if (!timeStr) return '';
  // 简单处理，实际项目可以使用 dayjs
  if (timeStr.length < 10) return timeStr; // 已经是短格式
  const date = new Date(timeStr);
  const now = new Date();
  if (date.toDateString() === now.toDateString()) {
    const parts = timeStr.split(' ');
    return parts.length > 1 ? (parts[1] || '').substring(0, 5) : timeStr; // HH:mm
  }
  return timeStr.split(' ')[0]; // YYYY-MM-DD
};

const selectConversation = (item: Conversation) => {
  currentConversation.value = item;
  // 清除未读
  const idx = conversations.value.findIndex(c => c.id === item.id);
  if (idx !== -1 && conversations.value[idx]) {
    conversations.value[idx].unreadCount = 0;
  }
  scrollToBottom();
};

const scrollToBottom = () => {
  nextTick(() => {
    if (messageListRef.value) {
      messageListRef.value.scrollTop = messageListRef.value.scrollHeight;
    }
  });
};

const handleSend = (e?: KeyboardEvent) => {
  // 处理 Ctrl+Enter
  if (e && e.ctrlKey) {
    inputMessage.value += '\n';
    return;
  }

  if (!inputMessage.value.trim() || !currentConversation.value) return;

  const newMsg: Message = {
    id: Date.now().toString(),
    senderId: 'me',
    content: inputMessage.value,
    type: 'text',
    timestamp: new Date().toLocaleString(),
    isSelf: true,
    showTime: false
  };

  const cid = currentConversation.value.id;
  if (!messagesMap[cid]) {
    messagesMap[cid] = [];
  }
  messagesMap[cid]?.push(newMsg);
  
  // 更新列表最后一条消息
  const conv = conversations.value.find(c => c.id === currentConversation.value?.id);
  if (conv) {
    conv.lastMessage = inputMessage.value;
    conv.lastTime = new Date().toLocaleString();
  }

  inputMessage.value = '';
  scrollToBottom();

  // 模拟自动回复
  if (currentConversation.value.type === 'private') {
    setTimeout(() => {
      const replyMsg: Message = {
        id: Date.now().toString(),
        senderId: currentConversation.value!.id,
        senderAvatar: currentConversation.value!.avatar,
        content: '收到，我现在有点忙，稍后回复你。',
        type: 'text',
        timestamp: new Date().toLocaleString(),
        isSelf: false
      };
      messagesMap[currentConversation.value!.id]?.push(replyMsg);
      if (conv) {
        conv.lastMessage = replyMsg.content;
        conv.lastTime = replyMsg.timestamp;
      }
      scrollToBottom();
    }, 1000);
  }
};

const handleImageUpload = (e: Event) => {
  const file = (e.target as HTMLInputElement).files?.[0];
  if (!file || !currentConversation.value) return;
  
  message.loading({ content: '图片上传中...', key: 'upload' });
  
  // 模拟上传
  setTimeout(() => {
    if (!currentConversation.value) return;
    message.success({ content: '发送成功', key: 'upload' });
    const newMsg: Message = {
      id: Date.now().toString(),
      senderId: 'me',
      content: 'https://picsum.photos/300/200', // Mock image
      type: 'image',
      timestamp: new Date().toLocaleString(),
      isSelf: true
    };
    if (!messagesMap[currentConversation.value.id]) {
      messagesMap[currentConversation.value.id] = [];
    }
    messagesMap[currentConversation.value.id]?.push(newMsg);
    scrollToBottom();
  }, 1000);
};

const handleFileUpload = (e: Event) => {
  const file = (e.target as HTMLInputElement).files?.[0];
  if (!file || !currentConversation.value) return;

  message.loading({ content: '文件上传中...', key: 'upload' });

  setTimeout(() => {
    message.success({ content: '发送成功', key: 'upload' });
    const newMsg: Message = {
      id: Date.now().toString(),
      senderId: 'me',
      content: file.name,
      fileName: file.name,
      fileSize: (file.size / 1024).toFixed(1) + 'KB',
      type: 'file',
      timestamp: new Date().toLocaleString(),
      isSelf: true
    };
    messagesMap[currentConversation.value!.id]?.push(newMsg);
    scrollToBottom();
  }, 1000);
};

// 监听会话切换，滚动到底部
watch(() => currentConversation.value, () => {
  scrollToBottom();
});
</script>

<style scoped>
.messages-container {
  display: flex;
  height: calc(100vh - 120px); /* 减去头部和面包屑的高度 */
  background: #fff;
  border-radius: 8px;
  overflow: hidden;
  border: 1px solid #f0f0f0;
}

/* 左侧列表 */
.messages-sider {
  width: 280px;
  border-right: 1px solid #f0f0f0;
  display: flex;
  flex-direction: column;
  background: #fafafa;
}

.sider-header {
  padding: 16px;
  border-bottom: 1px solid #f0f0f0;
}

.conversation-list {
  flex: 1;
  overflow-y: auto;
}

.conversation-item {
  display: flex;
  padding: 12px 16px;
  cursor: pointer;
  transition: all 0.3s;
}

.conversation-item:hover {
  background: #f0f0f0;
}

.conversation-item.active {
  background: #e6f7ff;
}

.item-avatar {
  margin-right: 12px;
}

.item-content {
  flex: 1;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.item-top {
  display: flex;
  justify-content: space-between;
  margin-bottom: 4px;
}

.item-name {
  font-weight: 500;
  color: #333;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.item-time {
  font-size: 12px;
  color: #999;
}

.item-bottom {
  display: flex;
}

.item-msg {
  font-size: 12px;
  color: #888;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

/* 右侧主区域 */
.messages-main {
  flex: 1;
  display: flex;
  flex-direction: column;
  background: #fff;
}

.conversation-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.main-header {
  height: 60px;
  border-bottom: 1px solid #f0f0f0;
  padding: 0 20px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.header-title {
  font-size: 16px;
  font-weight: 600;
  margin-right: 8px;
}

.header-count {
  color: #999;
  font-size: 12px;
}

/* 聊天视图 */
.chat-view {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.message-list {
  flex: 1;
  padding: 20px;
  overflow-y: auto;
  background: #f7f7f7;
}

.message-bubble {
  margin-bottom: 20px;
}

.msg-time {
  text-align: center;
  font-size: 12px;
  color: #ccc;
  margin-bottom: 10px;
}

.msg-content-wrapper {
  display: flex;
  align-items: flex-start;
}

.is-self .msg-content-wrapper {
  flex-direction: row-reverse;
}

.msg-avatar {
  margin: 0 10px;
  flex-shrink: 0;
}

.msg-body {
  max-width: 70%;
  display: flex;
  flex-direction: column;
}

.is-self .msg-body {
  align-items: flex-end;
}

.sender-name {
  font-size: 12px;
  color: #999;
  margin-bottom: 4px;
}

.bubble-content {
  background: #fff;
  padding: 10px 14px;
  border-radius: 8px;
  border-top-left-radius: 0;
  box-shadow: 0 1px 2px rgba(0,0,0,0.05);
  font-size: 14px;
  line-height: 1.5;
  word-wrap: break-word;
}

.is-self .bubble-content {
  background: #1890ff;
  color: #fff;
  border-radius: 8px;
  border-top-right-radius: 0;
}

.file-message {
  display: flex;
  align-items: center;
  min-width: 200px;
}

.file-icon {
  font-size: 32px;
  margin-right: 12px;
}

.is-self .file-icon {
  color: #fff;
}

.file-name {
  font-weight: 500;
}

.file-size {
  font-size: 12px;
  opacity: 0.8;
}

/* 输入区域 */
.chat-input {
  border-top: 1px solid #f0f0f0;
  padding: 10px 20px 20px;
  background: #fff;
}

.toolbar {
  margin-bottom: 10px;
  display: flex;
  gap: 16px;
}

.tool-icon {
  font-size: 20px;
  color: #666;
  cursor: pointer;
  transition: color 0.3s;
}

.tool-icon:hover {
  color: #1890ff;
}

.upload-label {
  cursor: pointer;
  display: flex;
  align-items: center;
}

.send-action {
  display: flex;
  justify-content: flex-end;
  align-items: center;
  margin-top: 10px;
}

.send-action .tip {
  color: #999;
  font-size: 12px;
  margin-right: 12px;
}

/* 通知视图 */
.notification-view {
  flex: 1;
  overflow-y: auto;
  padding: 0 20px;
}

.notify-title {
  font-weight: 500;
  color: #333;
}

.notify-time {
  font-size: 12px;
  color: #999;
  margin-left: 10px;
}

.notify-desc {
  color: #666;
  margin-top: 4px;
}

.notify-action {
  margin-top: 8px;
}

.empty-state {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #999;
}
</style>
