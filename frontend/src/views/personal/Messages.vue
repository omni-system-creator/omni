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
                    :shape="item.type === 'system' || item.type === 'app' ? 'square' : 'circle'"
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
            <a-avatar 
              :size="32"
              :shape="currentConversation.type === 'system' || currentConversation.type === 'app' ? 'square' : 'circle'"
              :style="{ backgroundColor: currentConversation.bgColor, marginRight: '10px' }"
            >
              <template #icon>
                <img v-if="currentConversation.avatar" :src="currentConversation.avatar" />
                <component v-else :is="currentConversation.icon" />
              </template>
            </a-avatar>
            <span class="header-title">{{ currentConversation.name }}</span>
            <span v-if="currentConversation.type === 'group'" class="header-count">({{ currentConversation.memberCount }}人)</span>
            <a-tag v-if="currentConversation.type === 'app'" color="blue">业务通知</a-tag>
            <a-tag v-if="currentConversation.type === 'system'" color="orange">系统消息</a-tag>
          </div>
          <div class="header-actions">
            <a-popconfirm
              v-if="userStore.isAdmin && ['private'].includes(currentConversation.type)"
              title="确定要清空与该用户的聊天记录吗？此操作不可恢复。"
              ok-text="确定"
              cancel-text="取消"
              @confirm="handleDeleteHistory"
            >
              <a-tooltip title="清空记录">
                <a-button type="text" danger shape="circle">
                  <template #icon><DeleteOutlined /></template>
                </a-button>
              </a-tooltip>
            </a-popconfirm>
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
                    <a-image v-else-if="msg.type === 'image'" :src="msg.content" :width="150" @load="onImageLoad" />
                    
                    <!-- 文件消息 -->
                    <div v-else-if="msg.type === 'file'" class="file-message">
                      <a :href="msg.content" target="_blank" rel="noopener" style="display:flex;align-items:center;text-decoration:none;color:inherit">
                        <FileOutlined class="file-icon" />
                        <div class="file-info">
                          <div class="file-name">{{ msg.fileName }}</div>
                          <div class="file-size">{{ msg.fileSize }}</div>
                        </div>
                      </a>
                    </div>
                  </div>
                </div>
                <!-- Delete Action (Right for received messages, Left for sent messages) -->
                <div v-if="userStore.isAdmin || msg.isSelf" :class="['message-actions', { 'is-self': msg.isSelf }]">
                  <a-popconfirm
                    title="确定删除这条消息吗？"
                    @confirm="handleDeleteSingleMessage(msg.id)"
                  >
                    <CloseOutlined class="delete-icon" />
                  </a-popconfirm>
                </div>
                <a-avatar v-if="msg.isSelf" :src="userAvatarUrl" class="msg-avatar" :style="!userAvatarUrl ? { backgroundColor: '#d9d9d9', color: '#fff' } : undefined">
                  <template #icon><UserOutlined /></template>
                </a-avatar>
              </div>
            </div>
          </div>
          
          <div class="chat-input">
            <div class="toolbar">
              <a-popover v-model:open="emojiOpen" trigger="click" placement="topLeft">
                <template #content>
                  <div class="emoji-panel">
                    <span class="emoji-item" v-for="e in emojiList" :key="e" @click="handleEmojiClick(e)">{{ e }}</span>
                  </div>
                </template>
                <a-tooltip title="表情"><SmileOutlined class="tool-icon" /></a-tooltip>
              </a-popover>
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
import { ref, computed, reactive, nextTick, watch, onMounted } from 'vue';
import { useRoute } from 'vue-router';
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
  InfoCircleOutlined,
  UserOutlined,
  DeleteOutlined,
  CloseOutlined
} from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import { chatApi, type ChatMessageDto } from '@/api/chat';
import { HubConnectionBuilder, HubConnection } from '@microsoft/signalr';
import { useUserStore } from '@/stores/user';

// --- 类型定义 ---
type ConversationType = 'system' | 'app' | 'private' | 'group';
// 移除未使用的类型别名

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
  senderName?: string; // Add this line
  senderAvatar?: string;
  content: string;
  type: 'text' | 'image' | 'file';
  timestamp: string;
  isSelf: boolean;
  showTime?: boolean;
  title?: string; // for system/business
  level?: 'normal' | 'urgent'; // for system/business
  actionText?: string; // for system/business
  fileName?: string;
  fileSize?: string;
}

// --- 状态 ---
const searchText = ref('');
const currentConversation = ref<Conversation | null>(null);
const inputMessage = ref('');
const messageListRef = ref<HTMLDivElement | null>(null);
const userStore = useUserStore();
const userAvatarUrl = computed(() => userStore.avatar || '');
let chatConnection: HubConnection | null = null;

const emojiOpen = ref(false);
const emojiList = [
  '😀','😃','😄','😁','😆','😅','😂','🙂','🙃','😉','😊','😍','😘','😗','😙','😚',
  '😜','😝','🤗','🤔','🤨','😐','😑','😶','😏','😒','🙄','😬','😭','😤','😡','👍',
  '👎','👏','👏','💪','👀','🎉','❤️','💔','⚡'
];
const handleEmojiClick = (e: string) => {
  inputMessage.value += e;
  emojiOpen.value = false;
};

// --- Mock 数据 ---
// 移除 Mock 数据，改从 API 获取

// 消息记录 Mock
// 移除 messagesMap，改从 API 获取
const messagesMap = reactive<Record<string, Message[]>>({});
// 会话列表
const conversations = ref<Conversation[]>([]);

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
// 从后端获取会话列表
const fetchConversations = async () => {
  try {
    const uid = Number(userStore.id);
    if (!uid) return;
    const list = await chatApi.getConversations(uid);
    conversations.value = (list || []).map((c: any) => ({
      ...c,
      icon: c.type === 'system' ? BellOutlined : (c.type === 'app' ? AppstoreOutlined : (c.type === 'group' ? TeamOutlined : UserOutlined)),
      bgColor: c.type === 'system' ? '#faad14' : (c.type === 'app' ? '#1890ff' : (c.type === 'group' ? '#52c41a' : undefined))
    }));
    if (!currentConversation.value && conversations.value.length > 0) {
      selectConversation(conversations.value[0] as Conversation);
    }
  } catch (e) {
    console.error('获取会话列表失败', e);
  }
};
const formatTime = (timeStr: string) => {
  if (!timeStr) return '';
  const date = new Date(timeStr);
  if (isNaN(date.getTime())) return timeStr;

  const now = new Date();
  const isToday = date.toDateString() === now.toDateString();
  const isThisYear = date.getFullYear() === now.getFullYear();

  const hours = String(date.getHours()).padStart(2, '0');
  const minutes = String(date.getMinutes()).padStart(2, '0');

  if (isToday) {
    return `${hours}:${minutes}`;
  }

  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');

  if (isThisYear) {
    return `${month}-${day} ${hours}:${minutes}`;
  }

  return `${date.getFullYear()}-${month}-${day} ${hours}:${minutes}`;
};

const getAvatarColor = (name: string) => {
  const colors = ['#f56a00', '#7265e6', '#ffbf00', '#00a2ae', '#1890ff', '#52c41a'];
  let hash = 0;
  for (let i = 0; i < name.length; i++) {
    hash = name.charCodeAt(i) + ((hash << 5) - hash);
  }
  return colors[Math.abs(hash) % colors.length];
};

const selectConversation = (item: Conversation) => {
  currentConversation.value = item;
  // 清除未读
  const idx = conversations.value.findIndex(c => c.id === item.id);
  if (idx !== -1 && conversations.value[idx]) {
    conversations.value[idx].unreadCount = 0;
  }
  
  // 加载历史记录
  if (item.type === 'private') {
    const myUserId = userStore.id;
    const peerUserId = Number(item.id);
    if (myUserId && !isNaN(peerUserId)) {
      chatApi.getHistory({ myUserId, peerUserId, page: 1, pageSize: 100 })
        .then(res => {
          const items = res.items || [];
          messagesMap[item.id] = items.map((m: ChatMessageDto, index: number) => {
            let showTime = false;
            if (index === 0) {
              showTime = true;
            } else {
              const prev = items[index - 1];
              if (prev) {
                const prevTime = new Date(prev.createdAt).getTime();
                const currTime = new Date(m.createdAt).getTime();
                if (currTime - prevTime > 5 * 60 * 1000) {
                  showTime = true;
                }
              } else {
                showTime = true;
              }
            }
            return {
              id: String(m.id),
              senderId: String(m.senderUserId),
              senderName: m.senderName,
              senderAvatar: m.senderAvatar,
              content: m.content,
              type: m.type,
              fileName: m.fileName,
              fileSize: m.fileSize,
              timestamp: m.createdAt,
              isSelf: m.isSelf,
              showTime
            };
          });
          scrollToBottom();
          scheduleAutoScroll();
        })
        .catch(() => {});
    }
  }

  scrollToBottom();
  scheduleAutoScroll();
};

const scrollToBottom = () => {
  nextTick(() => {
    if (messageListRef.value) {
      messageListRef.value.scrollTop = messageListRef.value.scrollHeight;
    }
  });
};

const scheduleAutoScroll = () => {
  [50, 200, 800].forEach(ms => setTimeout(() => scrollToBottom(), ms));
};

const onImageLoad = () => {
  scheduleAutoScroll();
};

const handleSend = (e?: any) => {
  // 处理 Ctrl+Enter
  if (e && e.ctrlKey) {
    inputMessage.value += '\n';
    return;
  }

  if (!inputMessage.value.trim() || !currentConversation.value) return;

  const newMsg: Message = {
    id: Date.now().toString(),
    senderId: 'me',
    senderAvatar: userAvatarUrl.value,
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
  
  // Calculate showTime
  const list = messagesMap[cid];
  const lastMsg = list.length > 0 ? list[list.length - 1] : null;
  if (!lastMsg) {
    newMsg.showTime = true;
  } else {
    const prevTime = new Date(lastMsg.timestamp).getTime();
    const currTime = new Date(newMsg.timestamp).getTime();
    if (currTime - prevTime > 5 * 60 * 1000) {
      newMsg.showTime = true;
    }
  }

  messagesMap[cid]?.push(newMsg);
  
  // 更新列表最后一条消息
  const conv = conversations.value.find(c => c.id === currentConversation.value?.id);
  if (conv) {
    conv.lastMessage = inputMessage.value;
    conv.lastTime = new Date().toLocaleString();
  }

  const myUserId = userStore.id;
  const peerUserId = Number(currentConversation.value.id);
  inputMessage.value = '';
  scrollToBottom();

  // Persist and broadcast via backend
  if (currentConversation.value.type === 'private' && myUserId && peerUserId) {
    chatApi.send({ myUserId, peerUserId, type: 'text', content: newMsg.content })
      .catch(() => { /* errors already handled by request */ });
  }
};

const handleImageUpload = (e: Event) => {
  const file = (e.target as HTMLInputElement).files?.[0];
  if (!file || !currentConversation.value) return;

  const peerUserId = Number(currentConversation.value.id);
  if (isNaN(peerUserId)) {
    message.warning('该会话不支持发送文件');
    return;
  }

  message.loading({ content: '图片上传中...', key: 'upload' });
  
  // 乐观更新：先在本地展示一条图片消息（使用 blob URL）
  const blobUrl = URL.createObjectURL(file);
  const tempId = Date.now().toString();
  const cid = currentConversation.value.id;
  const nowStr = new Date().toLocaleString();
  const optimisticMsg: Message = {
    id: tempId,
    senderId: 'me',
    senderAvatar: userAvatarUrl.value,
    content: blobUrl,
    type: 'image',
    fileName: file.name,
    fileSize: `${Math.round(file.size / 1024)}KB`,
    timestamp: nowStr,
    isSelf: true,
    showTime: false
  };
  if (!messagesMap[cid]) messagesMap[cid] = [];
  const list = messagesMap[cid];
  const lastMsg = list.length > 0 ? list[list.length - 1] : null;
  if (!lastMsg) {
    optimisticMsg.showTime = true;
  } else {
    const prevTime = new Date(lastMsg.timestamp).getTime();
    const currTime = new Date(optimisticMsg.timestamp).getTime();
    if (currTime - prevTime > 5 * 60 * 1000) {
      optimisticMsg.showTime = true;
    }
  }
  messagesMap[cid].push(optimisticMsg);
  const conv = conversations.value.find(c => c.id === cid);
  if (conv) {
    conv.lastMessage = '[图片]';
    conv.lastTime = nowStr;
  }
  scrollToBottom();
  
  const myUserId = userStore.id;
  chatApi.upload({ myUserId, peerUserId, file })
    .then(() => { 
      message.success({ content: '发送成功', key: 'upload' });
    })
    .catch(() => {
      message.error({ content: '发送失败', key: 'upload' });
    });
};

const handleFileUpload = (e: Event) => {
  const file = (e.target as HTMLInputElement).files?.[0];
  if (!file || !currentConversation.value) return;

  const peerUserId = Number(currentConversation.value.id);
  if (isNaN(peerUserId)) {
    message.warning('该会话不支持发送文件');
    return;
  }

  message.loading({ content: '文件上传中...', key: 'upload' });

  // 乐观更新：先在本地展示一条文件消息（链接稍后由服务器回显填充）
  const tempId = Date.now().toString();
  const cid = currentConversation.value.id;
  const nowStr = new Date().toLocaleString();
  const optimisticMsg: Message = {
    id: tempId,
    senderId: 'me',
    senderAvatar: userAvatarUrl.value,
    content: '#',
    type: 'file',
    fileName: file.name,
    fileSize: `${Math.round(file.size / 1024)}KB`,
    timestamp: nowStr,
    isSelf: true,
    showTime: false
  };
  if (!messagesMap[cid]) messagesMap[cid] = [];
  const list = messagesMap[cid];
  const lastMsg = list.length > 0 ? list[list.length - 1] : null;
  if (!lastMsg) {
    optimisticMsg.showTime = true;
  } else {
    const prevTime = new Date(lastMsg.timestamp).getTime();
    const currTime = new Date(optimisticMsg.timestamp).getTime();
    if (currTime - prevTime > 5 * 60 * 1000) {
      optimisticMsg.showTime = true;
    }
  }
  messagesMap[cid].push(optimisticMsg);
  const conv = conversations.value.find(c => c.id === cid);
  if (conv) {
    conv.lastMessage = '[文件]';
    conv.lastTime = nowStr;
  }
  scrollToBottom();

  const myUserId = userStore.id;
  chatApi.upload({ myUserId, peerUserId, file })
    .then(() => { 
      message.success({ content: '发送成功', key: 'upload' });
    })
    .catch(() => {
      message.error({ content: '发送失败', key: 'upload' });
    });
};

const handleDeleteHistory = async () => {
  if (!currentConversation.value || !userStore.id) return;
  
  const myUserId = userStore.id;
  const peerUserId = Number(currentConversation.value.id);
  
  if (isNaN(peerUserId)) {
    message.warning('无法删除该类型会话记录');
    return;
  }

  try {
    await chatApi.deleteHistory({ myUserId, peerUserId });
    message.success('聊天记录已清空');
    
    // Clear local messages
    if (messagesMap[currentConversation.value.id]) {
      messagesMap[currentConversation.value.id] = [];
    }
    
    // Update conversation last message
    const conv = conversations.value.find(c => c.id === currentConversation.value?.id);
    if (conv) {
      conv.lastMessage = '';
      conv.lastTime = ''; // Or keep last time? Usually empty if no messages.
    }
  } catch (error) {
    console.error(error);
    message.error('清空失败');
  }
};

const handleDeleteSingleMessage = async (msgId: string) => {
  try {
    // The interceptor returns res.data directly if code === 200, otherwise it throws.
    // So if we get here, it means success.
    await chatApi.deleteMessage(msgId);
    message.success('删除成功');
    // Clear from UI
    if (currentConversation.value?.id) {
      const cid = currentConversation.value.id;
      if (messagesMap[cid]) {
        const oldList = messagesMap[cid];
        const newList = oldList.filter(m => m.id !== msgId);
        messagesMap[cid] = newList;

        // Update conversation last message preview if needed
        const conv = conversations.value.find(c => c.id === cid);
        if (conv) {
          if (newList.length > 0) {
            const lastMsg = newList[newList.length - 1];
            if (lastMsg) {
              conv.lastMessage = lastMsg.type === 'image' ? '[图片]' : (lastMsg.type === 'file' ? '[文件]' : lastMsg.content);
              conv.lastTime = lastMsg.timestamp;
            }
          } else {
            conv.lastMessage = '';
            conv.lastTime = '';
          }
        }
      }
    }
  } catch (error) {
    console.error(error);
    // Error message is already handled by interceptor usually, but we can keep a fallback
    // message.error('删除失败'); 
  }
};

// 监听会话切换，滚动到底部
watch(() => currentConversation.value, () => {
  scrollToBottom();
});

const route = useRoute();

// Handle external navigation to chat
watch(() => route.query, (query) => {
  if (query.chatWith && query.type === 'private') {
    const targetId = String(query.chatWith);
    const userName = query.userName as string || 'Unknown';
    const myUserId = Number(query.myUserId as string) || userStore.id;
    
    let conv = conversations.value.find(c => c.id === targetId);
    if (!conv) {
      // Create new temporary conversation
      conv = {
        id: targetId,
        type: 'private',
        name: userName,
        avatar: undefined,
        icon: UserOutlined,
        bgColor: getAvatarColor(userName),
        lastMessage: '开始聊天吧',
        lastTime: new Date().toLocaleString(),
        unreadCount: 0
      };
      conversations.value.unshift(conv);
    }
    selectConversation(conv);
    
    // Load history
    const peerUserId = Number(targetId);
    if (myUserId && !isNaN(peerUserId)) {
      chatApi.getHistory({ myUserId, peerUserId, page: 1, pageSize: 100 })
        .then(res => {
          const items = res.items || [];
          messagesMap[targetId] = items.map((m: ChatMessageDto, index: number) => {
            let showTime = false;
            if (index === 0) {
              showTime = true;
            } else {
              const prev = items[index - 1];
              if (prev) {
                const prevTime = new Date(prev.createdAt).getTime();
                const currTime = new Date(m.createdAt).getTime();
                if (currTime - prevTime > 5 * 60 * 1000) {
                  showTime = true;
                }
              } else {
                showTime = true;
              }
            }
            return {
              id: String(m.id),
              senderId: String(m.senderUserId),
              senderName: m.senderName,
              senderAvatar: m.senderAvatar,
              content: m.content,
              type: m.type,
              fileName: m.fileName,
              fileSize: m.fileSize,
              timestamp: m.createdAt,
              isSelf: m.isSelf,
              showTime
            };
          });
          scrollToBottom();
          scheduleAutoScroll();
        })
        .catch(() => {});
    }
  }
}, { immediate: true });

// Connect to UserHub for receiving messages
const connectChatHub = async () => {
  if (chatConnection) return;
  const token = userStore.token;
  chatConnection = new HubConnectionBuilder()
    .withUrl('/hubs/user', { accessTokenFactory: () => token || '' })
    .withAutomaticReconnect()
    .build();
  chatConnection.on('ReceivePrivateMessage', (dto: ChatMessageDto) => {
    // Ignore duplicate non-self echoes to my own connection
    if (String(dto.senderUserId) === String(userStore.id) && !dto.isSelf) return;

    const myId = String(userStore.id);
    const parts = (dto.conversationKey || '').split('|');
    if (parts.length !== 2) return;
    const peerIdFromKey = parts[0] === myId ? parts[1] : (parts[1] === myId ? parts[0] : '');
    if (!peerIdFromKey) return;

    // 如果当前不是该会话，也要更新左侧会话预览
    let conv = conversations.value.find(c => c.id === peerIdFromKey);
    if (!conv) {
      // 创建一个简易会话条目（缺少名称时用用户ID占位）
      // 如果是对方发来的消息，可以直接使用消息中的发送者姓名
      const displayName = (!dto.isSelf && dto.senderName) ? dto.senderName : `用户 ${peerIdFromKey}`;
      conv = {
        id: peerIdFromKey,
        type: 'private',
        name: displayName,
        avatar: dto.senderAvatar,
        icon: UserOutlined,
        bgColor: getAvatarColor(displayName),
        lastMessage: dto.type === 'image' ? '[图片]' : (dto.type === 'file' ? '[文件]' : dto.content),
        lastTime: dto.createdAt,
        unreadCount: 1
      };
      conversations.value.unshift(conv);
    } else {
      // 移动到顶部
      conversations.value = conversations.value.filter(c => c.id !== peerIdFromKey);
      conversations.value.unshift(conv);
      
      conv.lastMessage = dto.type === 'image' ? '[图片]' : (dto.type === 'file' ? '[文件]' : dto.content);
      conv.lastTime = dto.createdAt;
      if (currentConversation.value?.id !== peerIdFromKey) {
        conv.unreadCount++;
      }
    }

    // 自发消息的去重更新（文本、图片、文件）
    if (dto.isSelf) {
      const list = messagesMap[peerIdFromKey] || [];
      const matchIndex = list.findIndex(m => 
        m.isSelf &&
        m.id.length >= 13 &&
        (
          (dto.type === 'text' && m.type === 'text' && m.content === dto.content) ||
          ((dto.type === 'image' || dto.type === 'file') && m.type === dto.type && m.fileName === dto.fileName)
        )
      );
      if (matchIndex !== -1) {
        const pendingMsg = list[matchIndex];
        if (pendingMsg) {
          const oldUrl = pendingMsg.content;
          pendingMsg.id = String(dto.id);
          pendingMsg.timestamp = dto.createdAt;
          pendingMsg.content = dto.content;
          pendingMsg.fileName = dto.fileName;
          pendingMsg.fileSize = dto.fileSize;
          if (oldUrl && oldUrl.startsWith('blob:') && oldUrl !== dto.content) {
            try { URL.revokeObjectURL(oldUrl); } catch {}
          }
          conv.lastMessage = dto.type === 'image' ? '[图片]' : (dto.type === 'file' ? '[文件]' : dto.content);
          conv.lastTime = dto.createdAt;
          return;
        }
      }
    }

    const msg = {
      id: String(dto.id),
      senderId: String(dto.senderUserId),
      senderName: dto.senderName, // Use senderName from DTO
      senderAvatar: dto.senderAvatar,
      content: dto.content,
      type: dto.type,
      fileName: dto.fileName,
      fileSize: dto.fileSize,
      timestamp: dto.createdAt,
      isSelf: dto.isSelf,
      showTime: false
    } as Message;
    
    // 将消息归入对应会话
    if (!messagesMap[peerIdFromKey]) messagesMap[peerIdFromKey] = [];
    const list = messagesMap[peerIdFromKey];
    const lastMsg = list.length > 0 ? list[list.length - 1] : null;
    
    if (!lastMsg) {
      msg.showTime = true;
    } else {
      const prevTime = new Date(lastMsg.timestamp).getTime();
      const currTime = new Date(msg.timestamp).getTime();
      if (currTime - prevTime > 5 * 60 * 1000) {
        msg.showTime = true;
      }
    }
    
    // 追加并滚动
    list.push(msg);
    if (currentConversation.value?.id === peerIdFromKey) {
      scrollToBottom();
    }

    // 更新会话预览
    conv.lastMessage = msg.type === 'image' ? '[图片]' : (msg.type === 'file' ? '[文件]' : msg.content);
    conv.lastTime = msg.timestamp;
  });
  try { await chatConnection.start(); } catch (e) { console.error(e); }
};

onMounted(async () => {
  await fetchConversations();
  if (conversations.value.length === 0 && String(userStore.id) === '10') {
    try {
      await chatApi.seedMock(10);
      await fetchConversations();
    } catch (e) {
      console.warn('插入Mock数据失败', e);
    }
  }
  connectChatHub();
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

.header-info {
  display: flex;
  align-items: center;
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
  flex-direction: row;
  justify-content: flex-end;
}

.msg-avatar {
  margin: 0 10px;
  flex-shrink: 0;
  order: 0; /* Avatar always first for received, will adjust for self */
}

.is-self .msg-avatar {
  order: 3; /* Avatar last for self messages */
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

.emoji-panel {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  max-width: 260px;
}

.emoji-item {
  font-size: 20px;
  line-height: 24px;
  cursor: pointer;
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

/* Message Actions */
.message-actions {
  opacity: 0;
  transition: opacity 0.2s;
  display: flex;
  align-items: center;
  padding: 4px;
  order: 2; /* Default order for received messages (after body) */
}

.message-actions.is-self {
  order: 1; /* Order for self messages (before body) */
}

.msg-body {
  order: 1; /* Default order for received messages */
}

.is-self .msg-body {
  order: 2; /* Order for self messages */
}

.message-bubble:hover .message-actions {
  opacity: 1;
}

.delete-icon {
  color: #ff4d4f;
  cursor: pointer;
  font-size: 14px;
  padding: 4px;
  border-radius: 4px;
}

.delete-icon:hover {
  background-color: rgba(255, 77, 79, 0.1);
}
</style>
