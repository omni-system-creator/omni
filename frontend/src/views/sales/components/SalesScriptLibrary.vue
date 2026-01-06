<template>
  <div class="script-container">
    <div class="scene-list-wrapper">
      <div class="scene-header">场景列表</div>
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
      <div v-if="selectedScript" class="dialog-list">
        <div
          v-for="(dialog, index) in parseDialogContent(selectedScript.content)"
          :key="index"
          :class="['dialog-item', dialog.role]"
        >
          <div v-if="dialog.role === 'customer'" class="dialog-avatar">客</div>
          <div class="dialog-message">
            <div class="dialog-text">{{ dialog.text }}</div>
          </div>
          <div v-if="dialog.role === 'salesman'" class="dialog-avatar">销</div>
        </div>
      </div>
      <a-empty v-else description="请选择左侧场景查看对话记录" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch, onMounted } from 'vue';
import type { SalesScriptDto } from '@/api/sales';
import { getSalesScripts } from '@/api/sales';

const emit = defineEmits(['select']);

const selectedScriptId = ref('');
const selectedScript = ref<SalesScriptDto | null>(null);
const scripts = ref<SalesScriptDto[]>([]);

const loadData = async () => {
  try {
    scripts.value = await getSalesScripts();
  } catch (e) {
    console.error('加载话术库失败:', e);
  }
};

onMounted(() => {
  loadData();
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
  emit('select', script);
};

const parseDialogContent = (content: string) => {
  const lines = content.split('\n').filter(line => line.trim());
  const dialogs: { role: 'salesman' | 'customer'; text: string }[] = [];

  lines.forEach(line => {
    if (line.startsWith('[销售]')) {
      dialogs.push({
        role: 'salesman',
        text: line.replace('[销售]', '').trim()
      });
    } else if (line.startsWith('[客户]')) {
      dialogs.push({
        role: 'customer',
        text: line.replace('[客户]', '').trim()
      });
    } else {
      dialogs.push({
        role: 'salesman',
        text: line.trim()
      });
    }
  });

  return dialogs;
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
}

.dialog-header h3 {
  margin: 0;
}

.dialog-list {
  flex: 1;
  overflow-y: auto;
  padding: 16px;
  background: #f5f5f5;
}

.dialog-item {
  display: flex;
  margin-bottom: 16px;
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

.dialog-role {
  font-size: 12px;
  color: #8c8c8c;
  margin-bottom: 4px;
}

.dialog-text {
  line-height: 1.5;
}

.scene-empty {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100%;
  min-height: 200px;
}
</style>
