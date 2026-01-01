<script setup lang="ts">
import { useProjectStore } from "../stores/projectStore";
import { ref, computed } from "vue";
import ProjectPropertiesDialog from './ProjectPropertiesDialog.vue';
import {
  NPopover,
  NButton,
  NCheckbox,
  NCheckboxGroup,
  NSpace,
  NDropdown,
  NModal,
  NCard,
  NInput,
  useDialog,
  useNotification,
  useMessage,
} from "naive-ui";
import type { TaskStatus } from "../types";
import { onMounted, onUnmounted } from 'vue';

const store = useProjectStore();
const dialog = useDialog();
const notification = useNotification();
const message = useMessage();
const fileInput = ref<HTMLInputElement | null>(null);
const activeCategory = ref<"status" | "phase" | "swimlane">("status");

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

const getCategoryCount = (key: "status" | "phase" | "swimlane") => {
  switch (key) {
    case "status":
      return store.viewSettings.filterStatuses.length;
    case "phase":
      return store.viewSettings.filterPhases.length;
    case "swimlane":
      return store.viewSettings.filterSwimlanes.length;
    default:
      return 0;
  }
};

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
      store.viewSettings.filterSwimlanes = swimlaneOptions.value.map(
        (o) => o.value
      );
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

const saveProject = async () => {
  if (store.projectInfo.code) {
    const success = await store.saveProjectToServer(store.projectInfo.code);
    if (success) {
      message.success("保存成功");
    } else {
      message.error("保存失败");
    }
  } else {
    message.warning("无法保存：未找到项目ID");
  }
};

const exportProjectFile = () => {
  const data = store.exportProjectData();
  if (data) {
    try {
      const blob = new Blob([data], { type: "application/json" });
      const url = URL.createObjectURL(blob);
      const link = document.createElement("a");
      link.href = url;
      link.download = `project-${store.projectInfo.code}-${
        new Date().toISOString().split("T")[0]
      }.json`;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      URL.revokeObjectURL(url);
      // 显示成功提示
      notification.success({
        title: "导出成功",
        content: "项目已成功导出为 JSON 文件",
        duration: 3000,
      });
    } catch (e) {
      console.error("Export failed:", e);
      notification.error({
        title: "导出失败",
        content: "导出文件失败，请查看控制台",
        duration: 5000,
      });
    }
  }
};

const handleKeydown = async (e: KeyboardEvent) => {
  if ((e.ctrlKey || e.metaKey) && e.key === 's') {
    e.preventDefault()
    await saveProject()
  }
}

onMounted(() => {
  window.addEventListener('keydown', handleKeydown)
})

onUnmounted(() => {
  window.removeEventListener('keydown', handleKeydown)
})

const loadProject = () => {
  fileInput.value?.click();
};

const exportImage = async () => {
  try {
    if (store.exportImageHandler) {
      await store.exportImageHandler();
    } else {
      dialog.warning({
        title: "无法导出",
        content: "画布未初始化，无法导出图片",
        positiveText: "确定",
        positiveButtonProps: { autofocus: true } as any,
      });
    }
  } catch (e) {
    console.error("Export image failed:", e);
    dialog.error({
      title: "导出失败",
      content: "导出图片失败，请查看控制台",
      positiveText: "确定",
      positiveButtonProps: { autofocus: true } as any,
    });
  }
};

const handleFileUpload = (event: Event) => {
  const target = event.target as HTMLInputElement;
  if (target.files && target.files.length > 0) {
    const file = target.files[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = (e) => {
      const content = e.target?.result as string;
      if (content) {
        if (store.importProjectData(content)) {
          setTimeout(() => {
            store.fitView();
          }, 100);
        } else {
          dialog.error({
            title: "导入失败",
            content: "项目文件格式错误",
            positiveText: "确定",
            positiveButtonProps: { autofocus: true } as any,
          });
        }
      }
    };
    reader.readAsText(file);
    // Clear input so same file can be selected again
    target.value = "";
  }
};

const addPhase = () => {
  openInputModal("请输入阶段名称", "新阶段", (name) => {
    store.addPhase({
      id: "p" + Date.now(),
      name,
      color: "#F5F5F5",
    });
  });
};

const addSwimlane = () => {
  openInputModal("请输入专业名称", "新专业", (name) => {
    store.addSwimlane({
      id: "sl" + Date.now(),
      name,
      color: "#FFFFFF",
    });
  });
};

const addTask = () => {
  const newTask = {
    id: "t" + Date.now(),
    name: "新任务",
    phaseId: store.phases[0]?.id || "p1",
    swimlaneId: store.swimlanes[0]?.id || "sl1",
    status: "pending" as const,
    progress: 0,
    owner: "待定",
    startDate: new Date().toISOString().split("T")[0] || "",
    endDate: new Date().toISOString().split("T")[0] || "",
    dependencies: [],
    type: "task" as const,
  };
  store.addTask(newTask);
  store.selectElement("task", newTask.id);
};

const addOptions = [
  { label: "新增任务", key: "task" },
  { label: "新增阶段", key: "phase" },
  { label: "新增专业", key: "swimlane" },
];

const handleAddSelect = (key: string) => {
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

const fileOptions = computed(() => {
  const options = [
    { label: "新建项目", key: "new" },
    { type: "divider", key: "d1" },
    { label: "项目属性", key: "properties" },
    { type: "divider", key: "d2" },
    { label: "保存项目", key: "save" },
    { label: "导出文件", key: "exportFile" },
    { label: "加载项目", key: "load" },
    { type: "divider", key: "d3" },
    { label: "导出图片", key: "export" },
  ];

  const isClipboardSupported = typeof window !== 'undefined' && 
                             window.isSecureContext && 
                             navigator.clipboard && 
                             typeof ClipboardItem !== 'undefined';

  if (isClipboardSupported) {
    options.push({ label: "复制为图片", key: "copyImage" });
  }

  return options;
});

const handleFileSelect = (key: string) => {
  switch (key) {
    case "new":
      showNewProjectDialog.value = true;
      break;
    case "properties":
      store.showProjectProperties = true;
      break;
    case "save":
      saveProject();
      break;
    case "exportFile":
      exportProjectFile();
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
</script>

<template>
  <div class="controls-bar">
    <div class="left-controls">
      <n-button size="small" @click="store.returnToProjectList()" style="margin-right: 16px">
        返回列表
      </n-button>
      <div class="project-info">
        <div class="project-code">{{ store.projectInfo.code }}</div>
        <div class="project-name">{{ store.projectInfo.name }}</div>
      </div>
    </div>
    <div class="right-controls">
      <div class="control-group">
        <n-dropdown
          trigger="hover"
          :options="fileOptions"
          @select="handleFileSelect"
        >
          <n-button>文件</n-button>
        </n-dropdown>
        <input
          ref="fileInput"
          type="file"
          accept="application/json"
          style="display: none"
          @change="handleFileUpload"
        />
      </div>

      <div class="control-group">
        <n-dropdown
          trigger="hover"
          :options="addOptions"
          @select="handleAddSelect"
        >
          <n-button>新增</n-button>
        </n-dropdown>
      </div>

      <div class="control-group">
        <n-popover
          trigger="hover"
          placement="bottom"
          :show-arrow="false"
          style="padding: 10px"
        >
          <template #trigger>
            <n-button>视图</n-button>
          </template>
          <div class="zoom-control">
            <div class="zoom-header">
              <label
                >缩放:
                {{ Math.round(store.viewSettings.zoomLevel * 100) }}%</label
              >
              <n-button
                size="tiny"
                text
                type="primary"
                @click="store.fitView()"
                >适应画布</n-button
              >
            </div>
            <input
              type="range"
              min="0.5"
              max="2"
              step="0.1"
              :value="store.viewSettings.zoomLevel"
              @input="e => store.setZoom(parseFloat((e.target as HTMLInputElement).value))"
            />
          </div>
        </n-popover>
      </div>

      <n-popover
        trigger="hover"
        placement="bottom-end"
        :show-arrow="false"
        raw
        :style="{ padding: 0 }"
      >
        <template #trigger>
          <n-button>筛选</n-button>
        </template>
        <div class="filter-container">
          <!-- 左侧一级菜单 -->
          <div class="filter-sidebar">
            <div
              v-for="cat in categories"
              :key="cat.key"
              class="filter-category-item"
              :class="{ active: activeCategory === cat.key }"
              @mouseenter="activeCategory = cat.key"
            >
              <div class="category-label">
                {{ cat.label }}
                <span v-if="getCategoryCount(cat.key) > 0" class="count-badge">
                  {{ getCategoryCount(cat.key) }}
                </span>
              </div>
              <span class="arrow">›</span>
            </div>
          </div>

          <!-- 右侧二级内容 -->
          <div class="filter-content">
            <div v-if="activeCategory === 'status'">
              <div class="filter-actions">
                <n-button
                  size="tiny"
                  text
                  type="primary"
                  @click="handleSelectAll('status')"
                  >全选</n-button
                >
                <div class="divider"></div>
                <n-button size="tiny" text @click="handleDeselectAll('status')"
                  >全不选</n-button
                >
              </div>
              <n-checkbox-group
                v-model:value="store.viewSettings.filterStatuses"
              >
                <n-space vertical>
                  <n-checkbox
                    v-for="opt in statusOptions"
                    :key="opt.value"
                    :value="opt.value"
                  >
                    {{ opt.label }}
                  </n-checkbox>
                </n-space>
              </n-checkbox-group>
            </div>

            <div v-if="activeCategory === 'phase'">
              <div class="filter-actions">
                <n-button
                  size="tiny"
                  text
                  type="primary"
                  @click="handleSelectAll('phase')"
                  >全选</n-button
                >
                <div class="divider"></div>
                <n-button size="tiny" text @click="handleDeselectAll('phase')"
                  >全不选</n-button
                >
              </div>
              <n-checkbox-group v-model:value="store.viewSettings.filterPhases">
                <n-space vertical>
                  <n-checkbox
                    v-for="opt in phaseOptions"
                    :key="opt.value"
                    :value="opt.value"
                  >
                    {{ opt.label }}
                  </n-checkbox>
                </n-space>
              </n-checkbox-group>
            </div>

            <div v-if="activeCategory === 'swimlane'">
              <div class="filter-actions">
                <n-button
                  size="tiny"
                  text
                  type="primary"
                  @click="handleSelectAll('swimlane')"
                  >全选</n-button
                >
                <div class="divider"></div>
                <n-button
                  size="tiny"
                  text
                  @click="handleDeselectAll('swimlane')"
                  >全不选</n-button
                >
              </div>
              <n-checkbox-group
                v-model:value="store.viewSettings.filterSwimlanes"
              >
                <n-space vertical>
                  <n-checkbox
                    v-for="opt in swimlaneOptions"
                    :key="opt.value"
                    :value="opt.value"
                  >
                    {{ opt.label }}
                  </n-checkbox>
                </n-space>
              </n-checkbox-group>
            </div>
          </div>
        </div>
      </n-popover>
    </div>

    <ProjectPropertiesDialog v-model:show="store.showProjectProperties" />
    <n-modal v-model:show="showInputModal">
      <n-card
        style="width: 400px"
        :title="inputModalTitle"
        :bordered="false"
        size="huge"
        role="dialog"
        aria-modal="true"
      >
        <n-space vertical>
          <n-input
            v-model:value="inputValue"
            placeholder="请输入名称"
            @keydown.enter="handleInputConfirm"
            autofocus
          />
          <n-space justify="end">
            <n-button @click="showInputModal = false">取消</n-button>
            <n-button type="primary" @click="handleInputConfirm">确定</n-button>
          </n-space>
        </n-space>
      </n-card>
    </n-modal>

    <n-modal
      v-model:show="showNewProjectDialog"
      preset="dialog"
      title="确认"
      content="确定要新建项目吗？当前未保存的内容将丢失。"
      positive-text="确定"
      negative-text="取消"
      @positive-click="confirmNewProject"
      @negative-click="showNewProjectDialog = false"
      :positive-button-props="{ autofocus: true } as any"
      @keydown.enter.prevent="confirmNewProject"
    ></n-modal>
  </div>
</template>

<style scoped>
.zoom-control {
  display: flex;
  flex-direction: column;
  gap: 8px;
  min-width: 150px;
}

.zoom-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
  gap: 8px;
}

.divider-v {
  width: 1px;
  height: 12px;
  background: #e0e0e0;
}

.zoom-control label {
  font-size: 12px;
  color: #666;
}

.zoom-control input {
  width: 100%;
}

.filter-container {
  display: flex;
  background: white;
  border: 1px solid #eee;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  border-radius: 4px;
  overflow: hidden;
  height: 300px;
}

.filter-sidebar {
  width: 100px;
  background: #f5f5f5;
  border-right: 1px solid #eee;
  padding: 5px 0;
}

.filter-category-item {
  padding: 8px 12px;
  cursor: pointer;
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 14px;
  color: #333;
}

.category-label {
  display: flex;
  align-items: center;
  gap: 6px;
}

.count-badge {
  background: #2196f3;
  color: white;
  font-size: 10px;
  padding: 0 5px;
  border-radius: 10px;
  min-width: 16px;
  height: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  line-height: 1;
}

.filter-category-item:hover {
  background: #e6e6e6;
}

.filter-category-item.active {
  background: white;
  color: #2196f3;
  font-weight: 500;
}

.arrow {
  color: #999;
  font-size: 16px;
  line-height: 1;
}

.filter-actions {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 12px;
  padding-bottom: 8px;
  border-bottom: 1px solid #f0f0f0;
}

.filter-actions .divider {
  width: 1px;
  height: 12px;
  background: #e0e0e0;
}

.filter-content {
  width: 200px;
  padding: 15px;
  overflow-y: auto;
  background: white;
}

.controls-bar {
  height: 60px;
  background: white;
  border-bottom: 1px solid #e0e0e0;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 20px;
}

.left-controls { 
  display: flex;
  flex-direction: row;
  align-items: center;
  gap: 12px;
}

.project-info {
  display: flex;
  flex-direction: column;
}

.project-code {
  font-size: 12px;
  color: #666;
}

.project-name {
  font-weight: bold;
  font-size: 16px;
  color: #333;
}

.right-controls {
  display: flex;
  align-items: center;
  gap: 12px;
}

.control-group {
  display: flex;
  align-items: center;
  gap: 8px;
}
</style>