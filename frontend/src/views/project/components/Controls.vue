<script setup lang="ts">
import { useProjectFlowStore } from "@/stores/projectFlowStore";
import { ref, computed } from "vue";
import ProjectPropertiesDialog from './ProjectPropertiesDialog.vue';

import { Modal, message } from 'ant-design-vue';
import type { TaskStatus } from "@/types/project";
import { onMounted, onUnmounted } from 'vue';

const mounted = ref(false);

const handleKeydown = async (e: KeyboardEvent) => {
  if ((e.ctrlKey || e.metaKey) && e.key === 's') {
    e.preventDefault();
    await handleSaveProject();
  }
};

const isClipboardSupported = typeof window !== 'undefined' && 
                           window.isSecureContext && 
                           navigator.clipboard && 
                           typeof ClipboardItem !== 'undefined';
console.log('Clipboard Support:', isClipboardSupported);

onMounted(() => {
  window.addEventListener('keydown', handleKeydown);
  setTimeout(() => {
    mounted.value = true;
  }, 100);
});

onUnmounted(() => {
  window.removeEventListener('keydown', handleKeydown);
});

const props = defineProps<{
  isActive: boolean;
}>();

const store = useProjectFlowStore();
const fileInput = ref<HTMLInputElement | null>(null);
const activeCategory = ref<"status" | "phase" | "swimlane">("status");
const showProjectProperties = ref(false);

const showInputModal = ref(false);
const inputModalTitle = ref("");
const inputValue = ref("");
const inputConfirmAction = ref<((val: string) => void) | null>(null);

const openInputModal = (
  title: string,
  defaultValue: string,
  confirmAction: (val: string) => void
) => {
  inputModalTitle.value = title;
  inputValue.value = defaultValue;
  inputConfirmAction.value = confirmAction;
  showInputModal.value = true;
};

const showNewProjectDialog = ref(false);
const confirmNewProject = () => {
  store.newProject();
  setTimeout(() => {
    store.fitView();
  }, 100);
  showNewProjectDialog.value = false;
};

const handleInputConfirm = () => {
  if (inputConfirmAction.value && inputValue.value) {
    inputConfirmAction.value(inputValue.value);
  }
  showInputModal.value = false;
};

const categories = [
  { label: "状态", key: "status" as const },
  { label: "阶段", key: "phase" as const },
  { label: "专业", key: "swimlane" as const },
];

const statusOptions = [
  { label: "未开始", value: "pending" },
  { label: "进行中", value: "in_progress" },
  { label: "已完成", value: "completed" },
  { label: "延期", value: "delayed" },
];

const phaseOptions = computed(() =>
  store.phases.map((p) => ({ label: p.name, value: p.id }))
);
const swimlaneOptions = computed(() =>
  store.swimlanes.map((s) => ({ label: s.name, value: s.id }))
);

const handleSelectAll = (category: "status" | "phase" | "swimlane") => {
  switch (category) {
    case "status":
      store.viewSettings.filterStatuses = statusOptions.map(
        (o) => o.value as TaskStatus
      );
      break;
    case "phase":
      store.viewSettings.filterPhases = phaseOptions.value.map((o) => o.value);
      break;
    case "swimlane":
      store.viewSettings.filterSwimlanes = swimlaneOptions.value.map((o) => o.value);
      break;
  }
};

const handleDeselectAll = (category: "status" | "phase" | "swimlane") => {
  switch (category) {
    case "status":
      store.viewSettings.filterStatuses = [];
      break;
    case "phase":
      store.viewSettings.filterPhases = [];
      break;
    case "swimlane":
      store.viewSettings.filterSwimlanes = [];
      break;
  }
};

const addPhase = () => {
  openInputModal("新增阶段", "", (val) => {
    store.addPhase({
      id: "p_" + Date.now(),
      name: val,
      color: "#E3F2FD",
    });
  });
};

const addSwimlane = () => {
  openInputModal("新增专业", "", (val) => {
    store.addSwimlane({
      id: "sl_" + Date.now(),
      name: val,
      color: "#F5F5F5",
    });
  });
};

const addTask = () => {
  const newTask = {
    id: "t_" + Date.now(),
    name: "新任务",
    phaseId: store.phases[0]?.id || "",
    swimlaneId: store.swimlanes[0]?.id || "",
    status: "pending" as const,
    progress: 0,
    owner: "",
    startDate: new Date().toISOString().split("T")[0] || "",
    endDate: new Date().toISOString().split("T")[0] || "",
    dependencies: [],
    type: "task" as const,
  };
  store.addTask(newTask);
  store.selectedElement = { type: 'task', id: newTask.id };
};

const handleAddSelect = ({ key }: { key: string }) => {
  switch (key) {
    case "task":
      addTask();
      break;
    case "phase":
      addPhase();
      break;
    case "swimlane":
      addSwimlane();
      break;
  }
};

const handleFileSelect = ({ key }: { key: string }) => {
  switch (key) {
    case "new":
      showNewProjectDialog.value = true;
      break;
    case "properties":
      showProjectProperties.value = true;
      break;
    case "save":
      handleSaveProject();
      break;
    case "exportJson":
      exportJson();
      break;
    case "export":
      exportImage();
      break;
    case "copyImage":
      store.copyImageHandler?.();
      break;
    case "load":
      loadProject();
      break;
  }
};

const handleSaveProject = async () => {
  try {
    await store.saveProject();
    message.success('保存成功');
  } catch (e) {
    message.error('保存失败');
  }
};

const exportJson = () => {
  try {
    const json = store.exportProjectData();
    const blob = new Blob([json], { type: "application/json" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `${store.projectInfo.code}_${store.projectInfo.name}.json`;
    a.click();
    URL.revokeObjectURL(url);
    message.success('导出成功');
  } catch (e) {
    message.error('导出失败');
  }
};

const loadProject = () => {
  fileInput.value?.click();
};

const handleFileChange = (e: Event) => {
  const file = (e.target as HTMLInputElement).files?.[0];
  if (!file) return;

  const reader = new FileReader();
  reader.onload = (e) => {
    const content = e.target?.result as string;
    if (store.importProjectData(content)) {
      setTimeout(() => {
        store.fitView();
      }, 100);
    } else {
      Modal.error({ title: "错误", content: "无法解析项目文件" });
    }
  };
  reader.readAsText(file);
  // Reset input
  if (fileInput.value) fileInput.value.value = "";
};

const exportImage = async () => {
  if (store.exportImageHandler) {
    await store.exportImageHandler();
  }
};
</script>

<template>
  <div>
    <Teleport to="#tab-toolbar-target" v-if="mounted">
      <div class="controls-toolbar" v-show="isActive">
        <div class="project-info">
          <div class="project-code">【{{ store.projectInfo.code }}】</div>
          <div class="project-name">{{ store.projectInfo.name }}</div>
        </div>
        
        <div class="divider"></div>

        <div class="control-group">
          <a-dropdown>
            <a-button size="small">文件</a-button>
            <template #overlay>
              <a-menu @click="handleFileSelect">
                <a-menu-item key="new">新建项目</a-menu-item>
                <a-menu-divider />
                <a-menu-item key="properties">项目属性</a-menu-item>
                <a-menu-divider />
                <a-menu-item key="save">保存项目</a-menu-item>
                <a-menu-item key="load">加载项目</a-menu-item>
                <a-menu-divider />
                <a-menu-item key="exportJson">导出 JSON</a-menu-item>
                <a-menu-item key="export">导出图片</a-menu-item>
                <a-menu-item key="copyImage">复制为图片</a-menu-item>
              </a-menu>
            </template>
          </a-dropdown>
          <input
            ref="fileInput"
            type="file"
            accept=".json"
            style="display: none"
            @change="handleFileChange"
          />
        </div>

        <div class="divider"></div>

        <div class="control-group">
          <a-dropdown>
            <a-button type="primary" size="small">新增</a-button>
            <template #overlay>
              <a-menu @click="handleAddSelect">
                <a-menu-item key="task">新增任务</a-menu-item>
                <a-menu-item key="phase">新增阶段</a-menu-item>
                <a-menu-item key="swimlane">新增专业</a-menu-item>
              </a-menu>
            </template>
          </a-dropdown>
        </div>

        <div class="divider"></div>

        <div class="control-group">
          <a-input-search
            v-model:value="store.viewSettings.searchText"
            placeholder="搜索..."
            style="width: 120px"
            size="small"
          />
        </div>

        <div class="divider"></div>

        <div class="control-group">
          <a-popover placement="bottomRight" trigger="click" overlayClassName="filter-popover">
            <template #content>
              <div class="filter-tabs">
                <div 
                  v-for="cat in categories" 
                  :key="cat.key"
                  class="filter-tab"
                  :class="{ active: activeCategory === cat.key }"
                  @click="activeCategory = cat.key"
                >
                  {{ cat.label }}
                </div>
              </div>

              <div class="filter-content">
                <div v-if="activeCategory === 'status'">
                   <div class="filter-actions">
                      <a @click="handleSelectAll('status')">全选</a>
                      <a @click="handleDeselectAll('status')">清空</a>
                   </div>
                   <a-checkbox-group v-model:value="store.viewSettings.filterStatuses">
                     <div v-for="opt in statusOptions" :key="opt.value" class="filter-item">
                       <a-checkbox :value="opt.value">{{ opt.label }}</a-checkbox>
                     </div>
                   </a-checkbox-group>
                </div>
                
                <div v-if="activeCategory === 'phase'">
                   <div class="filter-actions">
                      <a @click="handleSelectAll('phase')">全选</a>
                      <a @click="handleDeselectAll('phase')">清空</a>
                   </div>
                   <a-checkbox-group v-model:value="store.viewSettings.filterPhases">
                     <div v-for="opt in phaseOptions" :key="opt.value" class="filter-item">
                       <a-checkbox :value="opt.value">{{ opt.label }}</a-checkbox>
                     </div>
                   </a-checkbox-group>
                   <div style="margin-top: 8px; text-align: center">
                     <a-button type="dashed" size="small" block @click="addPhase">
                        + 新增阶段
                     </a-button>
                   </div>
                </div>

                <div v-if="activeCategory === 'swimlane'">
                   <div class="filter-actions">
                      <a @click="handleSelectAll('swimlane')">全选</a>
                      <a @click="handleDeselectAll('swimlane')">清空</a>
                   </div>
                   <a-checkbox-group v-model:value="store.viewSettings.filterSwimlanes">
                     <div v-for="opt in swimlaneOptions" :key="opt.value" class="filter-item">
                       <a-checkbox :value="opt.value">
                          {{ opt.label }}
                          <span style="font-size: 10px; color: #999; margin-left: 4px;">
                            ({{ store.tasks.filter(t => t.swimlaneId === opt.value).length }})
                          </span>
                       </a-checkbox>
                     </div>
                   </a-checkbox-group>
                   <div style="margin-top: 8px; text-align: center">
                     <a-button type="dashed" size="small" block @click="addSwimlane">
                        + 新增专业
                     </a-button>
                   </div>
                </div>
              </div>
            </template>
            <a-button size="small">筛选</a-button>
          </a-popover>
        </div>
      </div>
    </Teleport>

    <ProjectPropertiesDialog v-model:open="showProjectProperties" />
    
    <a-modal v-model:open="showInputModal" :title="inputModalTitle" @ok="handleInputConfirm">
        <a-input v-model:value="inputValue" placeholder="请输入名称" @pressEnter="handleInputConfirm" autofocus />
    </a-modal>

    <a-modal v-model:open="showNewProjectDialog" title="新建项目" @ok="confirmNewProject">
        <p>确定要新建项目吗？当前未保存的更改将会丢失。</p>
    </a-modal>
  </div>
</template>

<style scoped>
.controls-toolbar {
  display: flex;
  align-items: center;
}

.project-info {
  display: flex;
  flex-direction: row;
  align-items: center;
  margin-right: 16px;
  gap: 8px;
}

.project-code {
  font-size: 16px;
  color: #666;
  font-weight: 500;
}

.project-name {
  font-weight: bold;
  font-size: 16px;
  color: #333;
}

.control-group {
  margin: 0 4px;
}

.divider {
  width: 1px;
  height: 16px;
  background: #eee;
  margin: 0 8px;
}

.filter-popover {
  width: 240px;
}

.filter-tabs {
  display: flex;
  border-bottom: 1px solid #eee;
  margin-bottom: 8px;
}

.filter-tab {
  flex: 1;
  text-align: center;
  padding: 8px 0;
  cursor: pointer;
  font-size: 12px;
  color: #666;
}

.filter-tab.active {
  color: #1890ff;
  border-bottom: 2px solid #1890ff;
  font-weight: 500;
}

.filter-content {
  padding: 8px;
  max-height: 300px;
  overflow-y: auto;
}

.filter-actions {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
  padding-bottom: 8px;
  border-bottom: 1px dashed #eee;
}
</style>
