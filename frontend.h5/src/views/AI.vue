<template>
  <div class="ai-container">
    <van-nav-bar title="AI 助手" fixed placeholder />
    <div class="chat-content" ref="chatContentRef">
      <div 
        v-for="msg in messages" 
        :key="msg.id" 
        class="message"
        :class="msg.type"
      >
        <div class="avatar" v-if="msg.type === 'system'">
          <!-- Robot Icon SVG -->
          <svg viewBox="0 0 1024 1024" width="24" height="24" fill="currentColor">
            <path d="M832 512h-64v-128c0-70.4-57.6-128-128-128h-96v-64c0-17.6-14.4-32-32-32s-32 14.4-32 32v64h-96c-70.4 0-128 57.6-128 128v128h-64c-35.2 0-64 28.8-64 64v192c0 35.2 28.8 64 64 64h640c35.2 0 64-28.8 64-64v-192c0-35.2-28.8-64-64-64z m-544-128c0-35.2 28.8-64 64-64h256c35.2 0 64 28.8 64 64v128H288v-128z m448 384H192v-192h640v192zM320 640a64 64 0 1 1 128 0 64 64 0 0 1-128 0z m256 0a64 64 0 1 1 128 0 64 64 0 0 1-128 0z" />
          </svg>
        </div>
        <div class="bubble">
          {{ msg.content }}
        </div>
        <div class="avatar user-avatar" v-if="msg.type === 'user'">
          <van-image
            v-if="userStore.avatar"
            round
            width="40px"
            height="40px"
            :src="getFileUrl(userStore.avatar)"
          >
            <template v-slot:error>
              <van-icon name="user-o" size="20" color="#ccc" />
            </template>
          </van-image>
          <div v-else class="avatar-placeholder">
            <van-icon name="user-o" size="20" color="#fff" />
          </div>
        </div>
      </div>
    </div>
    <div class="input-area">
      <van-field
        v-model="inputText"
        type="textarea"
        rows="1"
        :autosize="{ maxHeight: 200, minHeight: 24 }"
        center
        clearable
        placeholder="请输入您的问题..."
        class="chat-input"
      >
        <template #button>
          <van-button size="small" type="primary" @click="onSend" :disabled="!inputText">发送</van-button>
        </template>
      </van-field>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, nextTick, onMounted, watch } from 'vue';
import { useUserStore } from '@/stores/user';
import { getFileUrl } from '@/utils/file';

const userStore = useUserStore();

interface Message {
  id: number;
  type: 'system' | 'user';
  content: string;
}

const inputText = ref('');
const chatContentRef = ref<HTMLElement>();

const messages = ref<Message[]>([
  { id: 1, type: 'system', content: '你好！我是你的 AI 办公助手，有什么可以帮你的吗？' },
  { id: 2, type: 'user', content: '帮我查询一下年假余额' },
  { id: 3, type: 'system', content: '好的，正在为您查询... 您的年假余额为 5 天。' },
  { id: 4, type: 'user', content: '最近有什么公司通告吗？' },
  { id: 5, type: 'system', content: '最近的一条通告是关于《2024年中秋节放假安排》，请注意查收邮件。' },
  { id: 6, type: 'user', content: '怎么申请会议室？' },
  { id: 7, type: 'system', content: '您可以在工作台点击“会议室”图标，选择空闲的时间段和会议室进行预约。' },
  { id: 8, type: 'user', content: 'IT 报修找谁？' },
  { id: 9, type: 'system', content: '您可以直接在“常用服务”中点击“IT报修”提交工单，或拨打内线 8080 联系 IT 部门。' }
]);

const scrollToBottom = () => {
  nextTick(() => {
    if (chatContentRef.value) {
      chatContentRef.value.scrollTop = chatContentRef.value.scrollHeight;
    }
  });
};

const onSend = () => {
  if (!inputText.value) return;
  
  messages.value.push({
    id: Date.now(),
    type: 'user',
    content: inputText.value
  });
  
  const question = inputText.value;
  inputText.value = '';
  scrollToBottom();

  // Simulate AI response
  setTimeout(() => {
    messages.value.push({
      id: Date.now() + 1,
      type: 'system',
      content: `收到您的问题：“${question}”。\n(这是模拟的自动回复，AI 功能接入中...)`
    });
    scrollToBottom();
  }, 1000);
};

onMounted(() => {
  scrollToBottom();
});
</script>

<style scoped>
.ai-container {
  height: calc(100vh - 50px); /* 减去底部 tabbar 高度 */
  background-color: #f7f8fa;
  display: flex;
  flex-direction: column;
}

.chat-content {
  flex: 1;
  padding: 20px;
  overflow-y: auto; /* 允许内容滚动 */
}

.message {
  display: flex;
  margin-bottom: 20px;
}

.message.user {
  justify-content: flex-end;
}

.avatar {
  width: 40px;
  height: 40px;
  background: linear-gradient(135deg, #7232dd, #1989fa);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 24px;
  margin-right: 12px;
  flex-shrink: 0;
}

.user-avatar {
  background: none;
  margin-right: 0;
  margin-left: 12px;
}

.avatar-placeholder {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background-color: #bfbfbf;
  display: flex;
  align-items: center;
  justify-content: center;
}

.bubble {
  background: #fff;
  padding: 12px 16px;
  border-radius: 0 12px 12px 12px;
  max-width: 70%;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
  font-size: 14px;
  color: #333;
  line-height: 1.5;
  word-break: break-all;
}

.message.user .bubble {
  background: #1989fa;
  color: #fff;
  border-radius: 12px 12px 0 12px;
}

.input-area {
  background: #fff;
  padding: 10px 16px 34px; /* 增加底部内边距，避开 Tabbar 中突出的 AI 图标 */
  border-top: 1px solid #ebedf0;
}

:deep(.chat-input) {
  padding: 0;
}

:deep(.chat-input .van-field__control) {
  padding: 4px 0;
}
</style>