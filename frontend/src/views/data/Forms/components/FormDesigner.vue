<template>
  <div class="form-designer">
    <div class="designer-header">
      <div class="left">
        <a-button type="link" @click="$emit('back')">
          <template #icon><ArrowLeftOutlined /></template>
          返回
        </a-button>
        <span class="form-name">{{ formName }}</span>
      </div>
      <div class="right">
        <a-upload
          name="file"
          :showUploadList="false"
          :beforeUpload="beforeImportDesign"
          accept=".json"
        >
          <a-button type="default" style="margin-right: 10px">
            <template #icon><UploadOutlined /></template>
            导入设计
          </a-button>
        </a-upload>
        <a-button type="default" @click="exportDesign" style="margin-right: 10px">
          <template #icon><DownloadOutlined /></template>
          导出设计
        </a-button>
        <a-button type="default" @click="handlePreview" style="margin-right: 10px">
          <template #icon><EyeOutlined /></template>
          预览
        </a-button>
        <a-button type="primary" @click="handleSave">保存</a-button>
      </div>
    </div>
    
    <div class="designer-body">
      <!-- Components Palette -->
      <ComponentsPanel :cloneComponent="cloneComponent" />
      
      <!-- Canvas -->
      <FormCanvas
        v-model="formItems"
        v-model:selectedIndex="selectedIndex"
        v-model:selectedSubtableColumnIndex="selectedSubtableColumnIndex"
        :canvasGroup="canvasGroup"
      />
      
      <!-- Properties Panel -->
      <PropertiesPanel
        :selectedItem="selectedItem"
        :selectedSubtableColumn="selectedSubtableColumn"
        :formItems="formItems"
        @open-rich-text-modal="openRichTextModal"
      />
    </div>
  </div>

  <FormPreviewModal
    v-model:visible="previewVisible"
    :formItems="formItems"
  />

  <DraggableModal
    v-model:visible="richTextModalVisible"
    title="富文本编辑器"
    width="80%"
    height="80%"
  >
    <RichTextPropertyEditor 
      v-if="selectedItem" 
      v-model="selectedItem.content" 
    />
  </DraggableModal>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue';
import RichTextPropertyEditor from './RichTextPropertyEditor.vue';
import DraggableModal from '../../../../components/DraggableModal.vue';
import ComponentsPanel from './ComponentsPanel.vue';
import FormCanvas from './FormCanvas.vue';
import PropertiesPanel from './PropertiesPanel.vue';
import FormPreviewModal from './FormPreviewModal.vue';
import { ArrowLeftOutlined, DownloadOutlined, UploadOutlined, EyeOutlined } from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';

const props = defineProps({
  formId: Number,
  formName: String,
  initialContent: {
    type: String,
    default: '[]'
  }
});

const emit = defineEmits(['back', 'save']);

// Rich Text Modal State
const richTextModalVisible = ref(false);

const openRichTextModal = () => {
  richTextModalVisible.value = true;
};

const formItems = ref<any[]>([]);

let idCounter = 1;

try {
  if (props.initialContent) {
    const parsed = JSON.parse(props.initialContent);
    if (Array.isArray(parsed)) {
      // Ensure existing items have properties
      formItems.value = parsed.map(item => ({ 
        ...item, 
        span: item.span || 24,
        showLabel: item.showLabel !== false,
        hidden: item.hidden || false,
        columns: item.columns ? item.columns.map((col: any) => ({
          ...col,
          widthType: col.widthType || 'px',
          id: col.id || (Date.now() + '_' + (idCounter++))
        })) : []
      }));
    }
  }
} catch (e) {
  console.error('Failed to parse form content');
}

const selectedIndex = ref(-1);
const selectedSubtableColumnIndex = ref(-1);

const selectedItem = computed(() => {
  if (selectedIndex.value > -1 && selectedIndex.value < formItems.value.length) {
    return formItems.value[selectedIndex.value];
  }
  return null;
});

const selectedSubtableColumn = computed(() => {
  if (selectedItem.value && selectedItem.value.type === 'subtable' && selectedSubtableColumnIndex.value > -1) {
    return selectedItem.value.columns[selectedSubtableColumnIndex.value];
  }
  return null;
});

const getNextLabel = (baseLabel: string) => {
  const regex = new RegExp(`^${baseLabel}(\\d*)$`);
  let maxNum = 0;
  
  const checkLabel = (label: string) => {
    const match = label.match(regex);
    if (match) {
      const num = match[1] ? parseInt(match[1]) : 0;
      if (num > maxNum) maxNum = num;
      if (label === baseLabel && maxNum === 0) maxNum = 0; 
    }
  };

  formItems.value.forEach(item => {
    checkLabel(item.label);
    if (item.type === 'subtable' && item.columns) {
      item.columns.forEach((col: any) => checkLabel(col.label));
    }
  });

  return baseLabel + (maxNum + 1);
};

const cloneComponent = (origin: any) => {
  const cloned = {
    ...origin,
    id: Date.now() + '_' + (idCounter++),
    field: origin.type + '_' + Date.now(),
    label: getNextLabel(origin.label)
  };
  
  if (origin.type === 'subtable') {
    cloned.columns = [
      { label: '列1', field: 'col_1', type: 'input', widthType: 'px', id: Date.now() + '_' + (idCounter++) },
      { label: '列2', field: 'col_2', type: 'input', widthType: 'px', id: Date.now() + '_' + (idCounter++) }
    ];
    cloned.showRowNumber = true;
    cloned.showSummary = false;
  }
  
  return cloned;
};

const canvasGroup = {
  name: 'people',
  pull: (to: any, from: any, dragEl: any, evt: any) => {
    // When dragging to subtable, use clone to prevent layout shift (flickering)
    if (to.el.classList.contains('subtable-column-list')) {
      return 'clone';
    }
    return true;
  },
  put: true
};

const handleRemove = (index: number) => {
  formItems.value.splice(index, 1);
  if (selectedIndex.value === index) {
    selectedIndex.value = -1;
  } else if (selectedIndex.value > index) {
    selectedIndex.value--;
  }
};

const handleKeyDown = (e: KeyboardEvent) => {
  // If Rich Text Modal is open, do not handle global delete/backspace for component deletion
  if (richTextModalVisible.value) {
    return;
  }

  if (e.key === 'Delete' || e.key === 'Backspace') {
    // Check if we are editing an input
    if (document.activeElement?.tagName === 'INPUT' || document.activeElement?.tagName === 'TEXTAREA') {
      return;
    }

    if (selectedItem.value?.type === 'subtable' && selectedSubtableColumnIndex.value > -1) {
      // Delete subtable column
      selectedItem.value.columns.splice(selectedSubtableColumnIndex.value, 1);
      selectedSubtableColumnIndex.value = -1;
    } else if (selectedIndex.value > -1) {
      // Delete form item
      handleRemove(selectedIndex.value);
    }
  }
};

onMounted(() => {
  window.addEventListener('keydown', handleKeyDown);
});

onUnmounted(() => {
  window.removeEventListener('keydown', handleKeyDown);
});

const handleSave = () => {
  const content = JSON.stringify(formItems.value);
  emit('save', content);
};

// Preview Logic
const previewVisible = ref(false);

const handlePreview = () => {
  previewVisible.value = true;
};

// Import/Export Logic
const exportDesign = () => {
  const content = JSON.stringify(formItems.value, null, 2);
  const blob = new Blob([content], { type: 'application/json' });
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = `form_design_${Date.now()}.json`;
  link.click();
  URL.revokeObjectURL(url);
  message.success('导出设计成功');
};

const beforeImportDesign = (file: File) => {
  const reader = new FileReader();
  reader.onload = (e) => {
    try {
      const content = JSON.parse(e.target?.result as string);
      if (Array.isArray(content)) {
        formItems.value = content.map(item => ({
          ...item,
          span: item.span || 24,
          showLabel: item.showLabel !== false,
          hidden: item.hidden || false,
          columns: item.columns ? item.columns.map((col: any) => ({
            ...col,
            widthType: col.widthType || 'px'
          })) : []
        }));
        message.success('导入设计成功');
      } else {
        message.error('文件格式不正确');
      }
    } catch (err) {
      message.error('解析文件失败');
    }
  };
  reader.readAsText(file);
  return false; // Prevent upload
};
</script>

<style scoped>
.form-designer {
  height: 100%;
  display: flex;
  flex-direction: column;
  background: #f0f2f5;
}

.designer-header {
  height: 50px;
  background: #fff;
  border-bottom: 1px solid #ddd;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 16px;
}

.form-name {
  font-weight: bold;
  margin-left: 16px;
}

.designer-body {
  flex: 1;
  display: flex;
  overflow: hidden;
}
</style>