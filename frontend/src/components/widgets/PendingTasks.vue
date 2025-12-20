<template>
  <div class="widget-card">
    <div class="card-header">
      <h3>待办任务</h3>
      <a-tag color="red">{{ tasks.length }}</a-tag>
    </div>
    <div class="tasks-container">
      <a-list item-layout="horizontal" :data-source="tasks" size="small">
        <template #renderItem="{ item }">
          <a-list-item>
            <template #actions>
              <a key="edit" @click="handleProcess(item)">处理</a>
            </template>
            <a-list-item-meta>
              <template #title>
                <span :class="{ 'completed': item.status === 'done' }">{{ item.title }}</span>
              </template>
              <template #avatar>
                <a-avatar :style="{ backgroundColor: getPriorityColor(item.priority) }" size="small">
                  {{ getPriorityLabel(item.priority) }}
                </a-avatar>
              </template>
            </a-list-item-meta>
          </a-list-item>
        </template>
      </a-list>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { message } from 'ant-design-vue';

interface Task {
  id: string;
  title: string;
  priority: 'high' | 'medium' | 'low';
  status: 'todo' | 'done';
}

const tasks = ref<Task[]>([
  { id: '1', title: '审核新注册用户申请', priority: 'high', status: 'todo' },
  { id: '2', title: '修复报表导出 Bug', priority: 'high', status: 'todo' },
  { id: '3', title: '更新 Q3 季度销售数据', priority: 'medium', status: 'todo' },
  { id: '4', title: '团队周报汇总', priority: 'low', status: 'todo' },
  { id: '5', title: '服务器例行维护确认', priority: 'medium', status: 'todo' },
]);

const getPriorityColor = (p: string) => {
  switch(p) {
    case 'high': return '#f5222d';
    case 'medium': return '#faad14';
    case 'low': return '#52c41a';
    default: return '#1890ff';
  }
};

const getPriorityLabel = (p: string) => {
  switch(p) {
    case 'high': return '高';
    case 'medium': return '中';
    case 'low': return '低';
    default: return '普';
  }
};

const handleProcess = (item: Task) => {
  message.info(`开始处理任务: ${item.title}`);
};
</script>

<style scoped>
.widget-card {
  height: 100%;
  padding: 16px;
  background: #fff;
  border-radius: 8px;
  display: flex;
  flex-direction: column;
}
.card-header {
  margin-bottom: 12px;
  border-bottom: 1px solid #f0f0f0;
  padding-bottom: 8px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.card-header h3 {
  margin: 0;
  font-size: 16px;
  color: #333;
}
.tasks-container {
  flex: 1;
  overflow-y: auto;
}
.completed {
  text-decoration: line-through;
  color: #999;
}
:deep(.ant-list-item) {
  padding: 8px 0;
}
:deep(.ant-list-item-meta-title) {
  margin-bottom: 0 !important;
  font-size: 13px;
}
</style>
