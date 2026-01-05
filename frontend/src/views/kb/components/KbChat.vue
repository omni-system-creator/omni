<template>
  <div class="chat-panel">
    <div class="chat-view">
      <div class="chat-history" ref="chatHistoryRef">
        <div v-for="(msg, index) in messages" :key="index">
          <div v-if="shouldShowTime(index)" class="message-time">
            {{ formatTime(msg.createdAt) }}
          </div>
          <div :class="['chat-message', msg.role]">
          <div class="avatar">
            <template v-if="msg.role === 'user'">
              <a-avatar v-if="userStore.avatar" :src="userStore.avatar" :size="32" />
              <a-avatar v-else :size="32" style="background-color: #87d068">
                <template #icon><UserOutlined /></template>
              </a-avatar>
            </template>
            <a-avatar v-else :size="32" style="background-color: #1890ff">
              <template #icon><RobotOutlined /></template>
            </a-avatar>
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
          <a-select 
            v-model:value="selectedModel" 
            style="width: 200px" 
            size="small" 
            :options="models.map((m: DictDataDto) => ({ label: m.label, value: m.value }))" 
          />
        </div>
        <div style="display: flex; gap: 12px; align-items: flex-end; width: 100%;">
          <a-textarea
            v-model:value="userInput"
            placeholder="请输入您的问题，例如：该产品的核心功能有哪些？"
            :auto-size="{ minRows: 2, maxRows: 6 }"
            @pressEnter.prevent="handleSend"
          />
          <a-button type="primary" class="send-btn" @click="handleSend" :loading="isThinking">
            <template #icon><SendOutlined /></template>
            发送
          </a-button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, nextTick, watch, onMounted } from 'vue';
import { 
  UserOutlined, 
  RobotOutlined, 
  SendOutlined 
} from '@ant-design/icons-vue';
import type { ChatMessageDto, KbInfoDto, SendMessageDto, SiliconModelDto } from '@/types/kb';
import type { DictDataDto } from '../../../api/dict';
import { getChatHistory, sendChatMessage, getAvailableModels } from '@/api/kb';
import { useUserStore } from '@/stores/user';
import MarkdownIt from 'markdown-it';
import hljs from 'highlight.js';
import 'highlight.js/styles/github.css';

const props = defineProps<{ currentKb: KbInfoDto | null }>();
const userStore = useUserStore();

const chatBottomRef = ref<HTMLElement | null>(null);
const messages = ref<ChatMessageDto[]>([]);
const isThinking = ref(false);
const userInput = ref('');
const selectedModel = ref<string>('');
const models = ref<DictDataDto[]>([]);

const fetchModels = async () => {
  try {
    const res = await getAvailableModels();
    models.value = res.map((m: SiliconModelDto, index: number) => ({
      id: index,
      dictTypeId: 0,
      label: m.id,
      value: m.id,
      sort: index,
      isDefault: false,
      status: 'normal',
      createdAt: '',
      updatedAt: ''
    } as unknown as DictDataDto));
    if (models.value.length > 0) {
      selectedModel.value = models.value[0]?.value || '';
    }
  } catch (error) {
    console.error('Failed to fetch models:', error);
  }
};

onMounted(() => {
  fetchModels();
});

const handleSend = () => {
  sendMessage();
};

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

const scrollToBottom = () => {
  nextTick(() => {
    if (chatBottomRef.value) {
      chatBottomRef.value.scrollIntoView({ behavior: 'smooth', block: 'end' });
    }
  });
};

const formatTime = (timeStr?: string) => {
  if (!timeStr) return '';
  const date = new Date(timeStr);
  const now = new Date();
  
  const isToday = date.getDate() === now.getDate() && 
                  date.getMonth() === now.getMonth() && 
                  date.getFullYear() === now.getFullYear();
                  
  const isThisYear = date.getFullYear() === now.getFullYear();
  
  if (isToday) {
    return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  } else if (isThisYear) {
    return date.toLocaleDateString([], { month: '2-digit', day: '2-digit' }) + ' ' + 
           date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  } else {
    return date.toLocaleDateString([], { year: 'numeric', month: '2-digit', day: '2-digit' }) + ' ' +
           date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  }
};

const shouldShowTime = (index: number) => {
  if (index === 0) return true;
  const currentMsg = messages.value[index];
  const prevMsg = messages.value[index - 1];
  
  if (!currentMsg || !prevMsg) return false;

  if (!currentMsg.createdAt) return false;
  if (!prevMsg.createdAt) return true; // If prev has no timestamp, show current
  
  const currTime = new Date(currentMsg.createdAt).getTime();
  const prevTime = new Date(prevMsg.createdAt).getTime();
  
  return (currTime - prevTime) > 5 * 60 * 1000; // 5 minutes
};

watch(messages, () => { scrollToBottom(); }, { deep: true });

watch(isThinking, (val) => { if (val) scrollToBottom(); });

defineExpose({
  scrollToBottom
});

const fetchChatHistoryLocal = async (kbId: string) => {
  try {
    const res = await getChatHistory(kbId);
    messages.value = res.map(msg => ({ ...msg, sources: msg.sources || [] }));
  } catch {}
};

watch(() => props.currentKb, (kb) => {
  if (kb) {
    fetchChatHistoryLocal(kb.id);
  } else {
    messages.value = [];
  }
}, { immediate: true });

const sendMessage = async () => {
  if (!userInput.value.trim() || !props.currentKb) return;
  if (isThinking.value) return;
  const userMsg: ChatMessageDto = { role: 'user', content: userInput.value, createdAt: new Date().toISOString() };
  messages.value.push(userMsg);
  const prompt = userInput.value;
  userInput.value = '';
  isThinking.value = true;
  const aiMsg: ChatMessageDto = { role: 'ai', content: '' };
  messages.value.push(aiMsg);
  const aiIndex = messages.value.length - 1;
  try {
    const payload: SendMessageDto = { kbId: props.currentKb.id, message: prompt, model: selectedModel.value };
    const res = await sendChatMessage(payload);
    if (messages.value[aiIndex]) {
      messages.value[aiIndex].content = res.content || '';
      messages.value[aiIndex].sources = res.sources || [];
      messages.value[aiIndex].createdAt = res.createdAt;
    }
  } catch {
    if (messages.value[aiIndex]) {
      messages.value[aiIndex].content += '\n[发生错误，请重试]';
    }
  } finally {
    isThinking.value = false;
  }
};
</script>

<style scoped>
.chat-panel {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.chat-view {
  flex: 1;
  display: flex;
  flex-direction: column;
  height: 100%;
}

.chat-history {
  flex: 1;
  overflow-y: auto;
  padding: 16px;
  background: #f0f2f5;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.chat-message {
  display: flex;
  gap: 12px;
  max-width: 85%;
}

.chat-message.user {
  align-self: flex-end;
  flex-direction: row-reverse;
}

.chat-message.ai {
  align-self: flex-start;
}

.avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 1px solid #d9d9d9;
  flex-shrink: 0;
}

.chat-message.user .avatar {
  background: #1890ff;
  color: #fff;
  border: none;
}

.message-content {
  display: flex;
  flex-direction: column;
  gap: 4px;
  min-width: 0; /* Fix for flex child overflow */
}

.bubble {
  padding: 12px 16px;
  border-radius: 8px;
  background: #fff;
  box-shadow: 0 1px 2px rgba(0,0,0,0.05);
  word-break: break-word;
}

.chat-message.user .bubble {
  background: #1890ff;
  color: #fff;
}

.chat-message.user .bubble :deep(p) {
  margin-bottom: 0;
}

.thinking {
  color: #999;
  font-style: italic;
}

.chat-input {
  padding: 16px;
  background: #fff;
  border-top: 1px solid #e8e8e8;
  display: flex;
  gap: 12px;
}

.citations {
  margin-top: 8px;
  font-size: 12px;
}

.citation-title {
  color: #666;
  margin-right: 4px;
}

.citation-tag {
  cursor: pointer;
  margin-right: 4px;
  margin-bottom: 4px;
}

.message-time {
  text-align: center;
  color: #999;
  font-size: 12px;
  margin: 16px 0 8px;
}

/* Markdown Styles */
.markdown-body {
  font-size: 14px;
  line-height: 1.6;
}

.markdown-body :deep(pre) {
  background: #f6f8fa;
  border-radius: 6px;
  padding: 12px;
  overflow: auto;
}

.markdown-body :deep(code) {
  font-family: ui-monospace, SFMono-Regular, SF Mono, Menlo, Consolas, Liberation Mono, monospace;
}

.markdown-body :deep(p) {
  margin-bottom: 12px;
}

.markdown-body :deep(p:last-child) {
  margin-bottom: 0;
}

.markdown-body :deep(ul), .markdown-body :deep(ol) {
  padding-left: 20px;
  margin-bottom: 12px;
}
</style>
