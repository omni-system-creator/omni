<template>
  <div class="script-container">
    <div class="scene-list-wrapper">
      <div class="scene-header">
        <span>场景列表</span>
        <a-button type="primary" size="small" @click="showAddScriptModal">
          <template #icon><PlusOutlined /></template>
          新增
        </a-button>
      </div>
      <div class="scene-list" v-if="scripts.length > 0">
        <div
          v-for="script in scripts"
          :key="script.id"
          :class="['scene-item', { active: selectedScriptId === script.id }]"
          @click="selectScript(script)"
        >
          <div class="scene-title">{{ script.title }}</div>
          <div class="scene-desc">{{ script.description || '暂无描述' }}</div>
        </div>
      </div>
      <div class="scene-empty" v-else>
        <a-spin :spinning="true" size="large" />
      </div>
    </div>
    <div class="dialog-content">
      <div v-if="selectedScript" class="dialog-header">
        <h3>{{ selectedScript.title }}</h3>
      </div>
      <div v-if="selectedScript" class="dialog-list" ref="dialogListRef">
        <div
          v-for="(msg, index) in chatMessages"
          :key="index"
          :class="['dialog-item', msg.role === 'salesman' ? 'salesman' : 'customer']"
        >
          <div v-if="msg.role === 'customer'" class="dialog-avatar">客</div>
          
          <!-- Delete Button for Salesman (Left of Message) -->
          <div v-if="userStore.isAdmin && msg.role === 'salesman'" class="message-actions">
            <a-popconfirm
              title="确定删除这条对话吗？这将更新话术库内容。"
              @confirm="handleDeleteMessage(index)"
            >
              <CloseOutlined class="delete-icon" />
            </a-popconfirm>
          </div>

          <div class="dialog-message">
            <div class="dialog-text markdown-body" v-html="md.render(msg.content)"></div>
          </div>

          <!-- Delete Button for Customer (Right of Message) -->
          <div v-if="userStore.isAdmin && msg.role === 'customer'" class="message-actions">
            <a-popconfirm
              title="确定删除这条对话吗？这将更新话术库内容。"
              @confirm="handleDeleteMessage(index)"
            >
              <CloseOutlined class="delete-icon" />
            </a-popconfirm>
          </div>

          <div v-if="msg.role === 'salesman'" class="dialog-avatar">销</div>
        </div>
        
        <div v-if="isThinking" :class="['dialog-item', userRole === 'salesman' ? 'customer' : 'salesman']">
          <div :class="['dialog-avatar', userRole === 'salesman' ? 'customer' : 'salesman']">{{ userRole === 'salesman' ? '客' : '销' }}</div>
          <div class="dialog-message">
            <div class="dialog-text thinking">AI {{ userRole === 'salesman' ? '客户' : '销售' }}正在思考中...</div>
          </div>
        </div>
        <div ref="chatBottomRef"></div>
      </div>
      <a-empty v-else description="请选择左侧场景查看对话记录" />

      <!-- 输入区域 -->
      <div v-if="selectedScript" class="dialog-input-area">
        <div class="input-controls">
          <div class="model-selector">
            <span style="margin-right: 8px; color: #666;">AI模型:</span>
            <a-select
              v-model:value="selectedModel"
              style="width: 250px"
              size="small"
              :options="models.map((m: any) => ({ label: m.id, value: m.id }))"
            />
          </div>
          <div class="role-selector">
            <span style="margin-right: 8px; color: #666;">我扮演:</span>
            <a-radio-group v-model:value="userRole" size="small">
              <a-radio-button value="salesman">销售人员</a-radio-button>
              <a-radio-button value="customer">客户</a-radio-button>
            </a-radio-group>
          </div>
        </div>
        <div style="display: flex; gap: 12px; align-items: flex-end; width: 100%;">
          <a-textarea
            v-model:value="userInput"
            :placeholder="userRole === 'salesman' ? '输入您的销售话术，AI将扮演客户角色进行对话练习...' : '输入您的问题，AI将扮演销售人员为您解答...'"
            :auto-size="{ minRows: 2, maxRows: 4 }"
            @pressEnter.prevent="handleSend"
          />
          <a-button type="primary" class="send-btn" @click="handleSend" :loading="isThinking">
            <template #icon><SendOutlined /></template>
            发送
          </a-button>
        </div>
      </div>
    </div>

    <!-- 新增场景弹窗 -->
    <a-modal
      v-model:open="showAddModal"
      title="新增销售场景"
      :confirm-loading="isSaving"
      @ok="handleAddScript"
      @cancel="resetAddModal"
      width="600px"
    >
      <a-form layout="vertical">
        <a-form-item label="场景标题" required>
          <div style="display: flex; gap: 8px;">
            <a-input v-model:value="newScriptTitle" placeholder="请输入场景标题" />
            <a-button @click="handleGenerate('title')" :loading="isGeneratingTitle" title="根据其他内容生成标题">
               <template #icon><ThunderboltOutlined /></template>
            </a-button>
          </div>
        </a-form-item>
        <a-form-item label="场景描述">
          <div style="display: flex; gap: 8px; align-items: flex-start;">
            <a-textarea
                v-model:value="newScriptDescription"
                placeholder="请输入场景描述（可选）"
                :auto-size="{ minRows: 2, maxRows: 4 }"
            />
            <a-button @click="handleGenerate('description')" :loading="isGeneratingDesc" title="根据标题和内容生成描述">
                <template #icon><ThunderboltOutlined /></template>
            </a-button>
          </div>
        </a-form-item>
        <a-form-item label="初始对话内容">
          <div style="display: flex; gap: 8px; margin-bottom: 8px;">
            <a-button size="small" @click="fillExampleContent">填入示例</a-button>
            <a-button size="small" type="primary" ghost @click="handleGenerate('content')" :loading="isGeneratingContent">
                <template #icon><ThunderboltOutlined /></template>
                AI生成
            </a-button>
          </div>
          <a-textarea
            v-model:value="newScriptContent"
            placeholder="请输入初始对话内容，格式：[销售] 或 [客户] 开头"
            :auto-size="{ minRows: 6, maxRows: 10 }"
          />
          <div class="form-tip">提示：使用 [销售] 和 [客户] 标记角色，每行表示一段对话</div>
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, watch, onMounted, nextTick } from 'vue';
import { SendOutlined, PlusOutlined, ThunderboltOutlined, CloseOutlined } from '@ant-design/icons-vue';
import type { SalesScriptDto } from '@/api/sales';
import { getSalesScripts, createSalesScript, updateSalesScript } from '@/api/sales';
import { getAvailableModels } from '@/api/kb';
import type { SiliconModelDto } from '@/types/kb';
import MarkdownIt from 'markdown-it';
import { message } from 'ant-design-vue';
import { useUserStore } from '@/stores/user';

const userStore = useUserStore();
const md = new MarkdownIt({ html: true, breaks: true });

const emit = defineEmits(['select']);

const selectedScriptId = ref('');
const selectedScript = ref<SalesScriptDto | null>(null);
const scripts = ref<SalesScriptDto[]>([]);

// 对话相关
const chatMessages = ref<{ role: 'salesman' | 'customer'; content: string }[]>([]);
const userInput = ref('');
const isThinking = ref(false);
const selectedModel = ref<string>('');
const models = ref<SiliconModelDto[]>([]);
const chatBottomRef = ref<HTMLElement | null>(null);
const userRole = ref<'salesman' | 'customer'>('salesman'); // 用户扮演的角色

// 新增场景弹窗
const showAddModal = ref(false);
const newScriptTitle = ref('');
const newScriptDescription = ref('');
const newScriptContent = ref('');
const isSaving = ref(false);
const isGeneratingTitle = ref(false);
const isGeneratingDesc = ref(false);
const isGeneratingContent = ref(false);

const handleGenerate = async (field: 'title' | 'description' | 'content') => {
  let loadingRef;
  switch (field) {
    case 'title': loadingRef = isGeneratingTitle; break;
    case 'description': loadingRef = isGeneratingDesc; break;
    case 'content': loadingRef = isGeneratingContent; break;
  }
  if (loadingRef) loadingRef.value = true;

  // Clear the field before streaming
  if (field === 'title') newScriptTitle.value = '';
  if (field === 'description') newScriptDescription.value = '';
  if (field === 'content') newScriptContent.value = '';

  try {
    const response = await fetch('/api/sales/materials/scripts/generate/stream', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            targetField: field,
            title: newScriptTitle.value,
            description: newScriptDescription.value,
            content: newScriptContent.value,
            model: selectedModel.value
        })
    });

    if (!response.ok) throw new Error(response.statusText);
    if (!response.body) throw new Error('No response body');

    const reader = response.body.getReader();
    const decoder = new TextDecoder();
    
    while (true) {
        const { done, value } = await reader.read();
        if (done) break;
        
        const chunk = decoder.decode(value);
        const lines = chunk.split('\n');
        
        for (const line of lines) {
            if (line.startsWith('data: ')) {
                const data = line.slice(6);
                if (data === '[DONE]') continue;
                
                try {
                    const parsed = JSON.parse(data);
                    const content = parsed.content;
                    if (content) {
                        switch (field) {
                            case 'title': newScriptTitle.value += content; break;
                            case 'description': newScriptDescription.value += content; break;
                            case 'content': newScriptContent.value += content; break;
                        }
                    }
                } catch (e) {
                    console.error('Error parsing SSE data:', e);
                }
            }
        }
    }
    message.success('生成成功');
  } catch (e) {
    console.error('生成失败:', e);
    message.error('生成失败');
  } finally {
    if (loadingRef) loadingRef.value = false;
  }
};

const loadData = async () => {
  try {
    scripts.value = await getSalesScripts();
  } catch (e) {
    console.error('加载话术库失败:', e);
  }
};

const fetchModels = async () => {
  try {
    const res = await getAvailableModels();
    models.value = res || [];
    if (models.value.length > 0) {
      // 优先选中 DeepSeek-V3
      const preferredModel = models.value.find(m => m.id === 'deepseek-ai/DeepSeek-V3') 
                          || models.value.find(m => m.id.includes('DeepSeek-V3'))
                          || models.value.find(m => m.id.includes('DeepSeek'))
                          || models.value[0];
      selectedModel.value = preferredModel?.id || '';
    }
  } catch (error) {
    console.error('Failed to fetch models:', error);
  }
};

onMounted(() => {
  loadData();
  fetchModels();
});

// 监听 scripts 变化，自动选中第一个
watch(
  () => scripts.value,
  (newScripts) => {
    if (newScripts.length > 0 && newScripts[0]) {
      selectScript(newScripts[0]);
    }
  },
  { immediate: true }
);

const selectScript = (script: SalesScriptDto) => {
  selectedScriptId.value = script.id;
  selectedScript.value = script;
  userRole.value = 'salesman'; // 重置为销售人员角色
  
  // 解析脚本内容初始化对话
  chatMessages.value = parseDialogContent(script.content);
  
  emit('select', script);
};

const parseDialogContent = (content: string) => {
  if (!content) return [];
  const lines = content.split('\n');
  const dialogs: { role: 'salesman' | 'customer'; content: string }[] = [];
  
  let currentRole: 'salesman' | 'customer' | null = null;
  let currentText: string[] = [];

  lines.forEach(line => {
    const trimmedLine = line.trim();
    if (!trimmedLine) return;

    if (trimmedLine.startsWith('[销售]')) {
      if (currentRole) {
        dialogs.push({ role: currentRole, content: currentText.join('\n') });
      }
      currentRole = 'salesman';
      currentText = [trimmedLine.replace('[销售]', '').trim()];
    } else if (trimmedLine.startsWith('[客户]')) {
      if (currentRole) {
        dialogs.push({ role: currentRole, content: currentText.join('\n') });
      }
      currentRole = 'customer';
      currentText = [trimmedLine.replace('[客户]', '').trim()];
    } else {
      if (currentRole) {
        currentText.push(trimmedLine);
    } else {
      // 如果没有角色开始，默认归为销售（或者第一条消息的角色）
      // 这里假设默认为销售，或者作为一个新的段落追加到上一个（如果没有上一个就新建）
      if (dialogs.length > 0) {
           // Append to last message
           const lastDialog = dialogs[dialogs.length - 1];
           if (lastDialog) {
             lastDialog.content += '\n' + trimmedLine;
           }
      } else {
           // Default to salesman if start without tag
           currentRole = 'salesman';
           currentText.push(trimmedLine);
      }
    }
    }
  });

  // Push last message
  if (currentRole && currentText.length > 0) {
    dialogs.push({ role: currentRole, content: currentText.join('\n') });
  }

  return dialogs;
};

const serializeDialogContent = (messages: { role: 'salesman' | 'customer'; content: string }[]) => {
  return messages.map(m => {
    const roleTag = m.role === 'salesman' ? '[销售]' : '[客户]';
    return `${roleTag} ${m.content}`;
  }).join('\n');
};

const handleDeleteMessage = async (index: number) => {
  if (!selectedScript.value) return;

  const newMessages = [...chatMessages.value];
  newMessages.splice(index, 1);
  const newContent = serializeDialogContent(newMessages);

  try {
    await updateSalesScript(selectedScript.value.id, {
      content: newContent
    });
    
    // Update local state
    chatMessages.value = newMessages;
    selectedScript.value.content = newContent;
    message.success('删除成功');
  } catch (error) {
    console.error(error);
    message.error('删除失败');
  }
};

// 滚动到底部
const scrollToBottom = () => {
  nextTick(() => {
    if (chatBottomRef.value) {
      chatBottomRef.value.scrollIntoView({ behavior: 'smooth', block: 'end' });
    }
  });
};

// 监听对话消息，自动滚动
watch(() => chatMessages.value.length, () => { scrollToBottom(); });
watch(isThinking, (val) => { if (val) scrollToBottom(); });

const handleSend = async () => {
  if (!userInput.value.trim() || !selectedScript.value || isThinking.value) return;

  // 根据用户角色确定AI角色
  const aiRole: 'salesman' | 'customer' = userRole.value === 'salesman' ? 'customer' : 'salesman';

  // 添加用户消息
  chatMessages.value.push({
    role: userRole.value,
    content: userInput.value
  });

  const prompt = userInput.value;
  userInput.value = '';
  isThinking.value = true;

  // 创建 AI 回复占位
  const aiMessageIndex = chatMessages.value.length;
  chatMessages.value.push({
    role: aiRole,
    content: ''
  });

  try {
    // 使用 fetch 实现流式请求
    const response = await fetch('/api/sales/scripts/chat/stream', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        message: prompt,
        scriptId: selectedScript.value.id,
        userRole: userRole.value,
        model: selectedModel.value
      })
    });

    if (!response.ok) {
      throw new Error(response.statusText);
    }

    const reader = response.body?.getReader();
    const decoder = new TextDecoder();

    if (reader) {
      while (true) {
        const { done, value } = await reader.read();
        if (done) break;
        
        const chunk = decoder.decode(value, { stream: true });
        // 假设后端返回的是 text/event-stream 或者是直接的文本流
        // 如果是 JSON 格式的 SSE，需要解析 'data: ...'
        // 这里做一个简单的处理，尝试解析 SSE 格式，或者直接追加文本
        
        const lines = chunk.split('\n');
        for (const line of lines) {
            if (line.startsWith('data: ')) {
                try {
                    const data = JSON.parse(line.slice(6));
                    const content = data.content || data.Content;
                    if (content) {
                        const aiMessage = chatMessages.value[aiMessageIndex];
                        if (aiMessage) {
                          aiMessage.content += content;
                        }
                    }
                } catch (e) {
                    // 如果不是 JSON，可能就是纯文本
                    const aiMessage = chatMessages.value[aiMessageIndex];
                    if (aiMessage) {
                      aiMessage.content += line.replace('data: ', '');
                    }
                }
            } else if (line.trim() !== '') {
                 // 如果不是 SSE 格式，直接追加（根据实际后端实现调整）
                 // 暂时假设后端直接返回内容片段
                 const aiMessage = chatMessages.value[aiMessageIndex];
                 if (aiMessage) {
                   aiMessage.content += line;
                 }
            }
        }
        scrollToBottom();
      }
    } else {
        // Fallback specifically for non-stream response
        const data = await response.json();
        const aiMessage = chatMessages.value[aiMessageIndex];
        if (aiMessage) {
          aiMessage.content = data.content || data.message || '';
        }
    }

    // 保存对话到话术库内容
    await saveConversationToScript();
  } catch (e) {
    console.error('AI对话失败:', e);
    const aiMessage = chatMessages.value[aiMessageIndex];
    if (aiMessage) {
      aiMessage.content = '抱歉，AI回复出现问题，请稍后重试。';
    }
  } finally {
    isThinking.value = false;
  }
};

// 将对话保存到话术库
const saveConversationToScript = async () => {
  if (!selectedScript.value) return;

  // 转换为字符串格式
  const contentText = chatMessages.value.map(d => {
    const roleText = d.role === 'salesman' ? '[销售]' : '[客户]';
    return `${roleText} ${d.content}`;
  }).join('\n');

  // 暂时更新本地数据
  selectedScript.value.content = contentText;

  // 调用后端API保存
  try {
    const response = await fetch(`/api/sales/materials/scripts/${selectedScript.value.id}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        content: contentText
      })
    });

    if (!response.ok) {
      console.error('Failed to save script:', response.statusText);
    } else {
      console.log('保存对话到话术库成功');
    }
  } catch (e) {
    console.error('保存话术失败:', e);
  }
};

// 显示新增场景弹窗
const showAddScriptModal = () => {
  showAddModal.value = true;
};

// 重置弹窗表单
const resetAddModal = () => {
  newScriptTitle.value = '';
  newScriptDescription.value = '';
  newScriptContent.value = '';
  showAddModal.value = false;
};

// 填入示例内容
const fillExampleContent = () => {
  newScriptContent.value = `[销售] 您好，我是销售顾问，请问有什么可以帮助您的？
[客户] 我对你们的产品很感兴趣，想了解更多信息。
[销售] 非常感谢您的关注！请问您具体对哪个方面比较感兴趣呢？是我们的产品功能、价格，还是其他方面？
[客户] 我主要想了解一下产品的主要功能和优势。
[销售] 好的，我们的产品主要有以下几个核心功能：第一，智能化数据分析；第二，自动化工作流程；第三，实时协作平台。这些功能可以帮助企业提高30%以上的工作效率。
[客户] 听起来不错，那价格方面呢？`;
};

// 新增场景
const handleAddScript = async () => {
  if (!newScriptTitle.value.trim()) {
    message.error('请输入场景标题');
    return;
  }

  isSaving.value = true;

  try {
    const newScript = await createSalesScript({
        title: newScriptTitle.value,
        description: newScriptDescription.value,
        content: newScriptContent.value || '[销售] 您好，我是销售顾问，请问有什么可以帮助您的？'
    });

    message.success('新增场景成功');
    resetAddModal();
    loadData(); // 重新加载列表
    
    // 选中新创建的脚本
    if (newScript) {
        selectScript(newScript);
    }
  } catch (e) {
    console.error('新增场景失败:', e);
    message.error('新增场景失败，请稍后重试');
  } finally {
    isSaving.value = false;
  }
};
</script>

<style scoped>
.script-container {
  display: flex;
  height: 100%;
  border: 1px solid #e8e8e8;
  border-radius: 4px;
  overflow: hidden;
}

.scene-list-wrapper {
  display: flex;
  flex-direction: column;
  height: 100%;
  overflow: hidden;
}

.scene-header {
  padding: 12px 16px;
  font-weight: 500;
  background: #f0f0f0;
  border-bottom: 1px solid #e8e8e8;
  flex-shrink: 0;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.scene-list {
  width: 280px;
  border-right: 1px solid #e8e8e8;
  background: #fafafa;
  overflow-y: auto;
  flex-shrink: 0;
  flex: 1;
  min-height: 0;
}

.scene-item {
  padding: 12px 16px;
  border-bottom: 1px solid #e8e8e8;
  cursor: pointer;
  transition: all 0.3s;
}

.scene-item:hover {
  background: #e6f7ff;
}

.scene-item.active {
  background: #1890ff;
  color: #fff;
}

.scene-title {
  font-weight: 500;
  margin-bottom: 4px;
}

.scene-desc {
  font-size: 12px;
  opacity: 0.85;
}

.dialog-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.dialog-header {
  padding: 16px;
  border-bottom: 1px solid #e8e8e8;
  background: #fafafa;
  flex-shrink: 0;
}

.dialog-header h3 {
  margin: 0;
}

.dialog-list {
  flex: 1;
  overflow-y: auto;
  padding: 16px;
  background: #f5f5f5;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.dialog-item {
  display: flex;
  margin-bottom: 0;
}

.dialog-item.salesman {
  justify-content: flex-end;
}

.dialog-item.customer {
  justify-content: flex-start;
}

.dialog-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  flex-shrink: 0;
}

.dialog-item.salesman .dialog-avatar {
  background: #1890ff;
  color: #fff;
}

.dialog-item.customer .dialog-avatar {
  background: #52c41a;
  color: #fff;
}

.dialog-item.salesman .dialog-avatar + .dialog-message {
  margin-right: 10px;
}

.dialog-message + .dialog-avatar {
  margin-left: 10px;
}

.dialog-item.customer .dialog-avatar + .dialog-message {
  margin-left: 10px;
}

.dialog-message {
  max-width: 70%;
}

.dialog-item.salesman .dialog-message {
  background: #1890ff;
  color: #fff;
  padding: 10px 14px;
  border-radius: 8px 8px 0 8px;
  box-shadow: 0 1px 2px rgba(0,0,0,0.1);
}

.dialog-item.customer .dialog-message {
  background: #fff;
  color: #333;
  padding: 10px 14px;
  border-radius: 8px 8px 8px 0;
  box-shadow: 0 1px 2px rgba(0,0,0,0.1);
}

.dialog-text {
  line-height: 1.5;
}

.dialog-text.markdown-body :deep(p) {
  margin-bottom: 0.5em;
}

.dialog-text.markdown-body :deep(p:last-child) {
  margin-bottom: 0;
}

.dialog-text.markdown-body :deep(ul),
.dialog-text.markdown-body :deep(ol) {
  margin-bottom: 0.5em;
  padding-left: 1.2em;
}

.dialog-text.thinking {
  color: #999;
  font-style: italic;
}

.scene-empty {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100%;
  min-height: 200px;
}

.dialog-input-area {
  padding: 16px;
  background: #fff;
  border-top: 1px solid #e8e8e8;
  display: flex;
  flex-direction: column;
  gap: 12px;
  flex-shrink: 0;
}

.input-controls {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.model-selector {
  display: flex;
  align-items: center;
}

.role-selector {
  display: flex;
  align-items: center;
}

.send-btn {
  flex-shrink: 0;
}

.form-tip {
  color: #999;
  font-size: 12px;
  margin-top: 4px;
}

/* Message Actions */
.message-actions {
  opacity: 0;
  display: flex;
  align-items: center;
  padding: 0 8px;
  transition: opacity 0.2s;
}

.dialog-item:hover .message-actions {
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
