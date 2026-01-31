<template>
  <draggable-modal
    ref="modalRef"
    v-model:visible="visible"
    title="任务详情"
    :width="1000"
    :height="700"
    :confirm-loading="loading"
    body-padding="0px"
    @cancel="handleCancel"
  >
    <template #footer>
      <div style="display: flex; justify-content: space-between; align-items: center;">
        <div style="text-align: left; display: flex; flex-direction: row; gap: 8px;">
          <a-button v-if="task.status !== 'completed' && canManage" @click="openEditModal">
            <edit-outlined /> 编辑
          </a-button>
          <a-button 
            v-if="task?.status !== 'completed' && canManage" 
            type="primary" 
            ghost 
            @click="() => openProcessForm('complete')"
          >
            <check-circle-outlined /> 完成任务
          </a-button>
          <a-button 
            v-if="task?.status === 'completed' && canManage" 
            type="primary" 
            ghost 
            @click="() => openProcessForm('reopen')" 
          >
            <redo-outlined /> 重新激活
          </a-button>
        </div>
        <div style="text-align: right;">
           <a-button @click="handleCancel">关闭</a-button>
        </div>
      </div>
    </template>
    <div v-if="task" class="task-process-layout">
      <!-- 左侧：任务基本信息 -->
      <div class="left-pane">
        <div class="task-info-view">
          
          <!-- 头部布局：优先级 | 标题+元数据 | 状态 -->
          <div class="task-header-layout">
            <!-- 左侧：优先级 (大Tag) -->
            <div class="header-left">
              <div class="priority-badge" :class="task.priority">
                {{ getPriorityText(task.priority) }}
              </div>
            </div>

            <!-- 中间：标题、编辑按钮、类型、创建人 -->
            <div class="header-center">
              <div class="title-row">
                <div class="info-title">{{ task.title }}</div>
              </div>
              <div class="meta-row">
                <a-tag class="type-tag" color="blue">{{ getTypeText(task.type) }}</a-tag>
                <span class="info-creator">{{ creatorInfo }}</span>
              </div>
            </div>

            <!-- 右侧：状态 -->
            <div class="header-right">
              <a-tag class="status-tag" :color="getStatusColor(task.status)">{{ getStatusText(task.status) }}</a-tag>
            </div>
          </div>

          <div class="task-meta-card">
            <!-- 负责人 -->
            <div class="meta-owner">
              <span class="label">负责人：</span>
              <a-avatar size="small" :src="task.assigneeAvatar" style="background-color: #87d068; margin-right: 8px;">
                {{ task.assigneeName?.[0]?.toUpperCase() || 'U' }}
              </a-avatar>
              <span class="value">{{ task.assigneeName || '未分配' }}</span>
            </div>

            <!-- 成员 -->
            <div class="meta-members" v-if="task.members && task.members.length" style="display: flex; align-items: center;">
              <span class="label" style="color: #8c8c8c; margin-right: 8px; flex-shrink: 0;">成员：</span>
              <div v-if="task.members.length < 3" style="display: flex; align-items: center; gap: 12px; flex-wrap: wrap;">
                <span v-for="member in task.members" :key="member.userId" style="display: inline-flex; align-items: center;">
                  <a-avatar :src="member.avatar" size="small" style="background-color: #1890ff; margin-right: 4px; flex-shrink: 0;">
                    {{ member.name?.[0]?.toUpperCase() || 'M' }}
                  </a-avatar>
                  <span>{{ member.name }}</span>
                </span>
              </div>
              <div v-else style="display: flex; align-items: center; gap: 12px; flex-wrap: wrap;">
                <span v-for="member in task.members.slice(0, 2)" :key="member.userId" style="display: inline-flex; align-items: center;">
                  <a-avatar :src="member.avatar" size="small" style="background-color: #1890ff; margin-right: 4px; flex-shrink: 0;">
                    {{ member.name?.[0]?.toUpperCase() || 'M' }}
                  </a-avatar>
                  <span>{{ member.name }}</span>
                </span>
                <span style="color: #8c8c8c; display: inline-flex; align-items: center;">等{{ task.members.length }}人</span>
              </div>
            </div>

            <!-- 时间轴/进度条 -->
            <div class="meta-timeline" v-if="task.deadline && !timeProgress.notStarted">
              <div class="time-labels">
                <span class="time-start">{{ formatDate(task.startTime || task.createTime) }}</span>
                <span class="time-end">{{ formatDate(task.deadline) }}</span>
              </div>
              <a-progress
                :percent="timeProgress.percent"
                :status="timeProgress.status"
                :stroke-color="timeProgress.color"
                :show-info="false"
                size="small"
              />
              <div class="time-info">
                <span>已过去 {{ timeProgress.elapsed }}</span>
                <span :class="{ overdue: timeProgress.isOverdue }">
                  {{ timeProgress.remaining }}
                </span>
              </div>
            </div>
            <div class="meta-timeline" v-else-if="timeProgress.notStarted">
              <div class="no-deadline">
                <span class="time-start">开始时间：{{ formatDate(task.startTime) }}</span>
                <span class="time-elapsed" style="color: #faad14">{{ timeProgress.remaining }}</span>
              </div>
            </div>
            <div class="meta-timeline" v-else>
              <div class="no-deadline">
                <span class="time-start">创建于 {{ formatDate(task.createTime) }}</span>
                <span class="time-elapsed">已过去 {{ timeProgress.elapsed }}</span>
                <span class="no-limit">无截止时间</span>
              </div>
            </div>
          </div>

          <div class="info-section">
            <div class="section-label">任务描述</div>
            <div class="section-content task-desc">{{ task.description || '无描述' }}</div>
          </div>

          <div class="info-section" v-if="task.attachments && task.attachments.length">
            <div class="section-label">任务附件</div>
            <div class="attachment-list">
              <div v-for="file in task.attachments" :key="file.id" class="attachment-item">
                <div class="file-info" @click="handlePreview(file)">
                  <paper-clip-outlined class="file-icon" />
                  <div class="file-details">
                    <span class="file-name" :title="file.name">{{ file.name }}</span>
                    <div class="file-meta">
                      <span class="file-size">{{ formatSize(file.size) }}</span>
                      <span class="file-time">{{ formatDate(file.createdAt) }}</span>
                    </div>
                  </div>
                </div>
                <div class="file-actions">
                  <a-tooltip title="预览">
                    <a-button type="text" size="small" @click.stop="handlePreview(file)">
                      <eye-outlined />
                    </a-button>
                  </a-tooltip>
                  <a-tooltip title="下载">
                    <a-button type="text" size="small" @click.stop="handleDownload(file)">
                      <download-outlined />
                    </a-button>
                  </a-tooltip>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 右侧：进展记录与新增 -->
      <div class="right-pane">
        <!-- 上半部分：进展记录 -->
        <div class="process-section">
          <div class="pane-title" style="display: flex; justify-content: space-between; align-items: center;">
            <span>进展记录</span>
            <a-button v-if="task.status !== 'completed'" type="link" size="small" @click="() => openProcessForm('process')">
              <plus-outlined /> 新增
            </a-button>
            <a-button v-else type="link" size="small" @click="() => openProcessForm('reopen')">
              <redo-outlined /> 重新激活
            </a-button>
          </div>
          <div class="process-timeline">
            <div v-if="processes.length === 0" class="empty-process">
               <a-empty description="暂无进展记录" />
            </div>
            <a-timeline v-else>
               <a-timeline-item v-for="item in processes" :key="item.id" :color="getActionColor(item.action)">
                 <template #dot>
                    <check-circle-outlined v-if="item.action === 'complete'" />
                    <clock-circle-outlined v-else-if="item.action === 'process'" />
                    <redo-outlined v-else-if="item.action === 'reopen'" />
                 </template>
                 <div class="timeline-content">
                   <div class="timeline-header">
                     <span class="operator">{{ item.operatorName }}</span>
                     <span v-if="item.action !== 'process'" class="action-tag" :class="item.action">{{ getActionText(item.action) }}</span>
                     <span class="time">{{ formatDate(item.createTime) }}</span>
                   </div>
                   <div v-if="item.comment" class="timeline-comment">{{ item.comment }}</div>
                   <div v-if="item.attachments && item.attachments.length > 0" class="timeline-attachments">
                     <div class="attachment-list mini">
                       <div v-for="file in item.attachments" :key="file.id" class="attachment-item mini">
                         <div class="file-info" @click="handlePreview(file)">
                           <paper-clip-outlined class="file-icon" />
                           <div class="file-details">
                              <span class="file-name" :title="file.name">{{ file.name }}</span>
                              <div class="file-meta">
                                <span class="file-size">{{ formatSize(file.size) }}</span>
                                <span class="file-time">{{ formatDate(file.createdAt) }}</span>
                              </div>
                           </div>
                         </div>
                         <div class="file-actions">
                           <a-tooltip title="预览">
                             <a-button type="text" size="small" @click.stop="handlePreview(file)">
                               <eye-outlined />
                             </a-button>
                           </a-tooltip>
                           <a-tooltip title="下载">
                             <a-button type="text" size="small" @click.stop="handleDownload(file)">
                               <download-outlined />
                             </a-button>
                           </a-tooltip>
                         </div>
                       </div>
                     </div>
                  </div>
                   <div v-else-if="item.attachmentIds" class="timeline-attachments">
                      <a-space wrap>
                        <a-tag v-for="fileId in item.attachmentIds.split(',')" :key="fileId">
                          <paper-clip-outlined /> 附件ID: {{ fileId }}
                        </a-tag>
                      </a-space>
                   </div>
                 </div>
               </a-timeline-item>
            </a-timeline>
          </div>
        </div>
      </div>
    </div>
    <task-process-form-modal
      v-model:visible="formVisible"
      :task-id="task.id"
      :initial-x="formX"
      :initial-y="formY"
      :default-action="processAction"
      @success="handleFormSuccess"
    />
    <task-edit-modal
      v-model:visible="editModalVisible"
      :task="task"
      @success="handleEditSuccess"
    />
  </draggable-modal>
</template>

<script lang="ts" setup>
import { ref, watch, computed } from 'vue';
import { 
  CheckCircleOutlined, 
  ClockCircleOutlined, 
  RedoOutlined, 
  PaperClipOutlined, 
  PlusOutlined,
  EditOutlined,
  EyeOutlined,
  DownloadOutlined
} from '@ant-design/icons-vue';
import dayjs from 'dayjs';
import { getKkViewUrl } from '@/utils/kkview';
import { useUserStore } from '@/stores/user';
import { 
  getTaskProcesses, 
  type TaskProcessItem
} from '@/api/task';
import DraggableModal from '@/components/DraggableModal.vue';
import TaskProcessFormModal from './TaskProcessFormModal.vue';
import TaskEditModal from './TaskEditModal.vue';

const props = defineProps<{
  visible: boolean;
  task: any;
}>();

const emit = defineEmits(['update:visible', 'success']);

const visible = ref(props.visible);
const loading = ref(false);
const formVisible = ref(false);
const editModalVisible = ref(false);
const processes = ref<TaskProcessItem[]>([]);
const modalRef = ref();
const formX = ref<number | undefined>(undefined);
const formY = ref<number | undefined>(undefined);
const processAction = ref('process');

// Edit Mode State
const timeProgress = computed(() => {
  // Format helpers
  const formatDuration = (ms: number) => {
    const hours = Math.floor(ms / (1000 * 60 * 60));
    const days = Math.floor(hours / 24);
    if (days > 0) return `${days}天${hours % 24}小时`;
    return `${hours}小时`;
  };

  if (!props.task) return { percent: 0, elapsed: '', remaining: '', status: 'normal' as const, color: '#1890ff' };

  const start = props.task.startTime ? dayjs(props.task.startTime) : dayjs(props.task.createTime);
  const now = dayjs();
  
  if (props.task.startTime && now.isBefore(start)) {
      return { 
          percent: 0, 
          elapsed: '尚未开始', 
          remaining: `将在 ${formatDuration(start.diff(now))} 后开始`, 
          status: 'normal' as const, 
          color: '#d9d9d9', 
          isOverdue: false, 
          hasDeadline: !!props.task.deadline,
          notStarted: true 
      };
  }

  const elapsedMs = now.diff(start);
  const elapsed = formatDuration(elapsedMs);

  if (!props.task.deadline) {
    return { percent: 0, elapsed, remaining: '无截止时间', status: 'normal' as const, color: '#1890ff', isOverdue: false };
  }

  const end = dayjs(props.task.deadline);
  const totalMs = end.diff(start);
  const remainingMs = end.diff(now);

  let percent = 0;
  if (totalMs > 0) {
    percent = Math.floor((elapsedMs / totalMs) * 100);
  }

  const isOverdue = remainingMs < 0;
  const remaining = isOverdue
    ? `已逾期 ${formatDuration(Math.abs(remainingMs))}`
    : `还剩 ${formatDuration(remainingMs)}`;

  let status: 'active' | 'success' | 'normal' | 'exception' = 'active';
  let color = '#1890ff'; // Blue

  if (isOverdue) {
    percent = 100;
    status = 'exception';
    color = '#ff4d4f'; // Red
  } else if (percent > 80) {
    color = '#fa8c16'; // Orange
  }

  return { percent, elapsed, remaining, status, color, isOverdue, hasDeadline: true };
});

const userStore = useUserStore();

const creatorInfo = computed(() => {
  if (!props.task) return '';
  const isMe = String(props.task.creatorId) === String(userStore.id);
  const time = formatDate(props.task.createTime);
  return isMe ? `我创建于 ${time}` : `${props.task.creatorName || '未知用户'} 创建于 ${time}`;
});

const canManage = computed(() => {
  if (!props.task) return false;
  const userId = String(userStore.id);
  const isCreator = String(props.task.creatorId) === userId;
  const isAssignee = String(props.task.assigneeId) === userId;
  return isCreator || isAssignee;
});

// Watchers
watch(() => props.visible, (val) => {
  visible.value = val;
  if (val) {
    if (props.task) {
      loadProcesses();
    }
  }
});

watch(visible, (val) => {
  emit('update:visible', val);
});

// Methods
const openProcessForm = (action = 'process') => {
  processAction.value = action;
  if (modalRef.value?.modalState) {
    const parentState = modalRef.value.modalState;
    const parentWidth = typeof parentState.width === 'number' ? parentState.width : 1000;
    const parentHeight = typeof parentState.height === 'number' ? parentState.height : 700;
    
    // Child modal width is 600
    // Estimate child height or just center vertically
    const childWidth = 600;
    const childHeight = 400; // Estimated
    
    formX.value = parentState.x + (parentWidth - childWidth) / 2;
    formY.value = parentState.y + (parentHeight - childHeight) / 2;
  }
  formVisible.value = true;
};

const openEditModal = () => {
  editModalVisible.value = true;
};

const handleEditSuccess = (updatedTask: any) => {
  if (updatedTask) {
    Object.assign(props.task, updatedTask);
  }
  emit('success');
};

const handleFormSuccess = (data?: any) => {
  loadProcesses();
  emit('success');
  if (data?.action === 'complete') {
    visible.value = false;
  }
};

const loadProcesses = async () => {
  if (!props.task?.id) return;
  try {
    const res = await getTaskProcesses(props.task.id);
    processes.value = res || [];
  } catch (error) {
    console.error('Failed to load processes:', error);
  }
};

const handleCancel = () => {
  visible.value = false;
};

// Helpers
const getFileUrl = (id: string) => {
  return `/api/task/attachments/${id}`;
};

const formatDate = (date: string | null) => {
  if (!date) return '';
  return dayjs(date).format('YYYY-MM-DD HH:mm');
};

const formatSize = (bytes: number) => {
  if (bytes === 0) return '0 B';
  const k = 1024;
  const sizes = ['B', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
};

const handlePreview = (file: any) => {
  const url = getFileUrl(file.id);
  const previewUrl = getKkViewUrl(url, file.name);
  window.open(previewUrl, '_blank');
};

const handleDownload = (file: any) => {
  const url = getFileUrl(file.id);
  const link = document.createElement('a');
  link.href = url;
  link.download = file.name;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
};

const getStatusText = (status: string) => {
  const map: Record<string, string> = {
    'pending': '进行中',
    'completed': '已完成',
    'overdue': '已逾期'
  };
  return map[status] || status;
};

const getStatusColor = (status: string) => {
  const map: Record<string, string> = {
    'pending': 'processing',
    'completed': 'success',
    'overdue': 'error'
  };
  return map[status] || 'default';
};

const getTypeText = (type: string) => {
  const map: Record<string, string> = {
    'task': '任务',
    'todo': '待办',
    'bug': '缺陷',
    'feature': '需求'
  };
  return map[type] || type;
};

const getPriorityText = (priority: string) => {
  const map: Record<string, string> = {
    'high': '高',
    'medium': '中',
    'low': '低'
  };
  return map[priority] || priority;
};

const getActionText = (action: string) => {
  const map: Record<string, string> = {
    'process': '进度更新',
    'complete': '完成任务',
    'reopen': '重新打开'
  };
  return map[action] || action;
};

const getActionColor = (action: string) => {
  const map: Record<string, string> = {
    'process': 'blue',
    'complete': 'green',
    'reopen': 'orange'
  };
  return map[action] || 'blue';
};
</script>

<style scoped>
.task-process-layout {
  display: flex;
  height: 100%;
  gap: 8px;
  overflow: hidden;
}

.left-pane {
  flex: 0 0 450px; /* Fixed width for left pane */
  display: flex;
  flex-direction: column;
  overflow-y: auto;
  border-right: 1px solid #f0f0f0;
  padding: 8px;
}

.right-pane {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.task-info-view {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

/* 头部布局 */
.task-header-layout {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding-bottom: 12px;
  border-bottom: 1px solid #f0f0f0;
}

.header-left {
  flex-shrink: 0;
  padding-top: 4px; /* Align with title */
}

.priority-badge {
  display: flex;
  justify-content: center;
  align-items: center;
  width: 36px;
  height: 36px;
  border-radius: 6px;
  font-weight: bold;
  font-size: 16px;
  color: white;
}

.priority-badge.high { background-color: #ff4d4f; }
.priority-badge.medium { background-color: #fa8c16; }
.priority-badge.low { background-color: #52c41a; }

.header-center {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
  min-width: 0;
}

.title-row {
  display: flex;
  align-items: center;
  gap: 8px;
}

.info-title {
  font-size: 18px;
  font-weight: 600;
  color: #1f1f1f;
  line-height: 1.4;
  word-break: break-all;
}

.meta-row {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
  color: #8c8c8c;
}

.header-right {
  flex-shrink: 0;
}

/* Meta Card */
.task-meta-card {
  background: #fafafa;
  border-radius: 8px;
  padding: 12px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.meta-owner {
  display: flex;
  align-items: center;
}

.label {
  color: #8c8c8c;
  margin-right: 8px;
}

.value {
  color: #1f1f1f;
  font-weight: 500;
}

.meta-timeline {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.time-labels {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  color: #8c8c8c;
}

.time-info {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  color: #8c8c8c;
}

.overdue {
  color: #ff4d4f;
  font-weight: bold;
}

.no-deadline {
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  gap: 4px;
  font-size: 12px;
  color: #8c8c8c;
}

/* Info Sections */
.info-section {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.section-label {
  font-size: 14px;
  font-weight: 600;
  color: #1f1f1f;
  border-left: 3px solid #1890ff;
  padding-left: 8px;
}

.section-content {
  color: #595959;
  font-size: 14px;
  line-height: 1.6;
}

.task-desc {
  white-space: pre-wrap;
  background: #fff;
  padding: 8px;
  border-radius: 4px;
  border: 1px solid #f0f0f0;
  min-height: 60px;
}

/* Attachments */
.attachment-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.attachment-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px;
  background: #f5f5f5;
  border-radius: 4px;
  transition: background 0.3s;
}

.attachment-item:hover {
  background: #e6f7ff;
}

.file-info {
  display: flex;
  align-items: center;
  gap: 8px;
  flex: 1;
  cursor: pointer;
  overflow: hidden;
}

.file-icon {
  font-size: 16px;
  color: #1890ff;
}

.file-details {
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.file-name {
  font-size: 14px;
  color: #1f1f1f;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.file-meta {
  font-size: 12px;
  color: #8c8c8c;
}

.file-actions {
  display: flex;
  gap: 4px;
}

/* Process Section */
.process-section {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.pane-title {
  font-size: 16px;
  font-weight: 600;
  color: #1f1f1f;
  padding: 8px;
  border-bottom: 1px solid #f0f0f0;
}

.process-timeline {
  flex: 1;
  overflow-y: auto;
  padding: 8px;
}

.timeline-content {
  background: #f9f9f9;
  padding: 8px 12px;
  border-radius: 4px;
  border: 1px solid #f0f0f0;
}

.timeline-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 4px;
  flex-wrap: wrap;
}

.operator {
  font-weight: 600;
  color: #1f1f1f;
}

.action-tag {
  font-size: 12px;
  padding: 1px 6px;
  border-radius: 2px;
  background: #e6f7ff;
  color: #1890ff;
}

.action-tag.complete { background: #f6ffed; color: #52c41a; }
.action-tag.reopen { background: #fff7e6; color: #fa8c16; }

.time {
  font-size: 12px;
  color: #8c8c8c;
  margin-left: auto;
}

.timeline-comment {
  font-size: 14px;
  color: #595959;
  white-space: pre-wrap;
}

.timeline-attachments {
  margin-top: 8px;
}

.attachment-list.mini {
  gap: 4px;
}

.attachment-item.mini {
  padding: 4px 8px;
  background: #fff;
  border: 1px solid #f0f0f0;
}

.empty-process {
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 40px 0;
  color: rgba(0, 0, 0, 0.45);
}

:deep(.ant-timeline) {
  padding-top: 8px;
}

:deep(.ant-timeline-item) {
  padding-bottom: 12px;
}

:deep(.ant-timeline-item-last) {
  padding-bottom: 0;
}
</style>
