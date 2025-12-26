<template>
  <div class="canvas-panel">
    <draggable
      class="canvas-area"
      :list="modelValue"
      :group="canvasGroup"
      item-key="id"
      :move="checkMove"
      @change="onCanvasChange"
      ghost-class="ghost"
    >
      <template #item="{ element, index }">
        <div 
          class="grid-col"
          :style="{ width: ((element.span || 24) / 24 * 100 - 0.01) + '%' }"
          @click.stop="onItemClick(index)"
        >
          <div 
            class="form-item-wrapper" 
            :class="{ active: selectedIndex === index }"
            :style="{ opacity: element.hidden ? 0.5 : 1 }"
          >
            <div class="form-label" v-if="element.showLabel !== false">
              <span v-if="element.required" style="color: red; margin-right: 4px">*</span>
              {{ element.label }}
              <span v-if="element.hidden" style="font-size: 12px; color: #999; margin-left: 5px;">(已隐藏)</span>
            </div>
            <div class="form-input-mock">
              <a-input v-if="element.type === 'input'" :placeholder="element.placeholder || '单行文本'" disabled />
              <a-textarea v-else-if="element.type === 'textarea'" :placeholder="element.placeholder || '多行文本'" disabled />
              <a-input-number v-else-if="element.type === 'number'" placeholder="数字" disabled style="width: 100%" />
              <a-date-picker v-else-if="element.type === 'date'" placeholder="日期" disabled style="width: 100%" />
              <a-select v-else-if="element.type === 'select'" placeholder="下拉选择" disabled style="width: 100%" />
              <div v-else-if="element.type === 'text'" :style="{ fontSize: element.fontSize + 'px', fontWeight: element.bold ? 'bold' : 'normal', textAlign: element.align, color: element.color }">
                {{ element.content }}
              </div>
              <div v-else-if="element.type === 'rich-text'" class="rich-text-display" v-html="element.content" style="overflow: auto;"></div>
              <a-divider v-else-if="element.type === 'divider'" :dashed="element.dashed" :orientation="element.orientation" :style="{ marginTop: element.marginTop + 'px', marginBottom: element.marginBottom + 'px' }">
                 {{ element.text }}
              </a-divider>
              <div v-else-if="element.type === 'subtable'" class="subtable-designer">
                <div class="subtable-header-tip">拖拽组件至此处添加/排序列</div>
                <draggable
                  class="subtable-column-list"
                  :list="element.columns"
                  group="people"
                  item-key="id"
                  :animation="200"
                  :move="checkMove"
                  @change="onSubtableChange($event, element)"
                  ghost-class="ghost"
                >
                  <template #item="{ element: col, index: colIndex }">
                    <div 
                      class="subtable-column-item" 
                      :class="{ active: selectedIndex === index && selectedSubtableColumnIndex === colIndex }"
                      :style="{ width: col.width ? (col.widthType === 'percent' ? col.width + '%' : col.width + 'px') : undefined, flex: col.width ? 'none' : '1' }"
                      @click.stop="onSubtableColumnClick(index, colIndex)"
                    >
                      <span class="col-label">{{ col.label }}</span>
                      <span class="col-type">({{ col.type === 'textarea' ? '多行' : col.type === 'select' ? '下拉' : col.type === 'date' ? '日期' : col.type === 'number' ? '数字' : '文本' }})</span>
                      <DeleteOutlined class="col-delete" @click.stop="handleDeleteColumn(element, colIndex)" />
                    </div>
                  </template>
                </draggable>
                <div class="subtable-empty-row">
                  <div 
                    v-for="col in element.columns" 
                    :key="col.id" 
                    class="empty-cell"
                    :style="{ width: col.width ? (col.widthType === 'percent' ? col.width + '%' : col.width + 'px') : undefined, flex: col.width ? 'none' : '1' }"
                  ></div>
                </div>
              </div>
            </div>
            <div class="item-actions">
              <a-tooltip :title="element.field">
                <div class="field-name-tag">{{ element.field }}</div>
              </a-tooltip>
              <DeleteOutlined v-if="selectedIndex === index" @click.stop="handleRemove(index)" />
            </div>
          </div>
        </div>
      </template>
    </draggable>
    <div v-if="modelValue.length === 0" class="empty-canvas">
      请从左侧拖拽组件添加
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import draggable from 'vuedraggable';
import { DeleteOutlined } from '@ant-design/icons-vue';

const props = defineProps({
  modelValue: {
    type: Array as () => any[],
    required: true
  },
  selectedIndex: {
    type: Number,
    required: true
  },
  selectedSubtableColumnIndex: {
    type: Number,
    required: true
  },
  canvasGroup: {
    type: Object,
    required: true
  }
});

const emit = defineEmits(['update:modelValue', 'update:selectedIndex', 'update:selectedSubtableColumnIndex']);

const selectedItem = computed(() => {
  if (props.selectedIndex > -1 && props.selectedIndex < props.modelValue.length) {
    return props.modelValue[props.selectedIndex];
  }
  return null;
});

const onItemClick = (index: number) => {
  emit('update:selectedIndex', index);
  // Reset subtable column selection when selecting main item
  if (props.selectedIndex !== index) {
    // If we were selecting a column, deselect it?
    // Actually standard behavior: clicking item selects it.
  }
};

const onSubtableColumnClick = (itemIndex: number, colIndex: number) => {
  emit('update:selectedIndex', itemIndex);
  emit('update:selectedSubtableColumnIndex', colIndex);
};

const handleRemove = (index: number) => {
  const newList = [...props.modelValue];
  newList.splice(index, 1);
  emit('update:modelValue', newList);
  
  if (props.selectedIndex === index) {
    emit('update:selectedIndex', -1);
  } else if (props.selectedIndex > index) {
    emit('update:selectedIndex', props.selectedIndex - 1);
  }
};

const handleDeleteColumn = (element: any, colIndex: number) => {
  element.columns.splice(colIndex, 1);
  emit('update:selectedSubtableColumnIndex', -1);
};

const checkMove = (evt: any) => {
  // Prevent dragging 'subtable' type into a subtable column list
  if (evt.draggedContext.element.type === 'subtable') {
    if (evt.to.classList.contains('subtable-column-list')) {
      return false;
    }
  }
  return true;
};

const onCanvasChange = (evt: any) => {
  if (evt.added) {
    emit('update:selectedIndex', evt.added.newIndex);
    emit('update:selectedSubtableColumnIndex', -1);
    
    // Ensure span is present
    const item = props.modelValue[evt.added.newIndex];
    if (!item.span) {
      item.span = 24;
    }
  }
  if (evt.moved) {
    emit('update:selectedIndex', evt.moved.newIndex);
  }
};

const onSubtableChange = (evt: any, subtableItem: any) => {
  if (evt.added) {
    // Select the subtable itself
    const subtableIndex = props.modelValue.indexOf(subtableItem);
    if (subtableIndex > -1) {
      emit('update:selectedIndex', subtableIndex);
    }
    // Select the new column
    emit('update:selectedSubtableColumnIndex', evt.added.newIndex);
    
    // Set default widthType for new column
    if (subtableItem.columns[evt.added.newIndex]) {
      subtableItem.columns[evt.added.newIndex].widthType = 'px';
    }

    // Handle move from Canvas (simulate move by removing original)
    const addedItem = evt.added.element;
    const originalIndex = props.modelValue.findIndex(item => item.id === addedItem.id);
    
    if (originalIndex > -1) {
      // Remove the original item from Canvas
      // Need to be careful not to mutate prop directly if we want to follow one-way data flow strictly,
      // but modifying the array content is what we do here.
      // To trigger update:modelValue properly:
      const newList = [...props.modelValue];
      newList.splice(originalIndex, 1);
      emit('update:modelValue', newList);
    }
  }
  if (evt.moved) {
     emit('update:selectedSubtableColumnIndex', evt.moved.newIndex);
  }
};
</script>

<style scoped>
.canvas-panel {
  flex: 1;
  margin: 10px;
  background: #fff;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  box-shadow: 0 0 10px rgba(0,0,0,0.05);
  position: relative;
}

.canvas-area {
  flex: 1;
  padding: 20px;
  overflow-y: auto;
  background: transparent;
  display: flex;
  flex-wrap: wrap;
  align-content: flex-start;
  z-index: 1;
}

.grid-col {
  padding: 5px;
  box-sizing: border-box;
}

.empty-canvas {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
  color: #999;
  font-size: 16px;
  z-index: 0;
}

.form-item-wrapper {
  padding: 15px;
  border: 1px solid transparent;
  position: relative;
  background: #fff;
  height: 100%;
}

.form-item-wrapper:hover {
  background: #f9f9f9;
}

.form-item-wrapper.active {
  border-color: #1890ff;
  background: #e6f7ff;
}

.form-label {
  margin-bottom: 8px;
  font-weight: 500;
}

.item-actions {
  position: absolute;
  right: 10px;
  top: 10px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 5px;
}

.item-actions .anticon-delete {
  color: #ff4d4f;
}

.field-name-tag {
  background: #f0f0f0;
  border: 1px solid #d9d9d9;
  border-radius: 2px;
  padding: 0 4px;
  font-size: 12px;
  color: #666;
  max-width: 150px;
  min-width: 50px;
  text-align: center;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  line-height: 20px;
}

.subtable-designer {
  border: 1px solid #ddd;
  background: #fff;
  padding: 5px;
}

.subtable-header-tip {
  font-size: 12px;
  color: #999;
  text-align: center;
  margin-bottom: 5px;
  background: #f5f5f5;
  padding: 2px;
}

.subtable-column-list {
  display: flex;
  overflow-x: auto;
  min-height: 40px;
  background: #fafafa;
  border: 1px dashed #ddd;
  padding: 5px;
  gap: 5px;
}

.subtable-column-item {
  background: #fff;
  border: 1px solid #ddd;
  padding: 5px 10px;
  display: flex;
  align-items: center;
  gap: 5px;
  cursor: move;
  white-space: nowrap;
  font-size: 12px;
  overflow: hidden;
  min-width: 60px;
}

.subtable-column-item.active {
  border-color: #1890ff;
  background-color: #e6f7ff;
}

.subtable-column-item:hover {
  border-color: #1890ff;
  color: #1890ff;
}

.col-label {
  font-weight: bold;
}

.col-type {
  color: #999;
  font-size: 10px;
}

.col-delete {
  margin-left: 5px;
  color: #ff4d4f;
  cursor: pointer;
}

.subtable-empty-row {
  display: flex;
  gap: 5px;
  margin-top: 5px;
  padding: 0 5px;
}

.empty-cell {
  flex: 1;
  height: 20px;
  background: #f5f5f5;
  border: 1px solid #eee;
}

.ghost {
  opacity: 0.5;
  background: #e6f7ff !important;
  border: 1px dashed #1890ff !important;
}

.subtable-column-list .ghost {
  width: 60px !important;
  max-width: 60px !important;
  min-width: 60px !important;
  flex: 0 0 60px !important;
  height: 32px !important;
  overflow: hidden;
  padding: 0 !important;
  margin: 0 !important;
  background: #e6f7ff !important;
  border: 1px dashed #1890ff !important;
  display: flex !important;
  align-items: center;
  justify-content: center;
  box-sizing: border-box !important;
}

.subtable-column-list .ghost * {
  display: none !important;
}

.subtable-column-list .ghost::after {
  content: '添加列';
  display: block;
  font-size: 12px;
  color: #1890ff;
}

.canvas-area .ghost.component-item {
  width: 100% !important;
  height: 60px !important;
  margin: 5px 0 !important;
  display: block !important;
}

.canvas-area .ghost.grid-col {
  height: auto !important;
  margin: 0 !important;
  padding: 5px !important;
  box-sizing: border-box !important;
}

.rich-text-display table {
  border-collapse: collapse;
}
.rich-text-display table td, .rich-text-display table th {
  border: 1px solid #ccc;
  padding: 3px 5px;
}
.rich-text-display img {
  max-width: 100%;
}
.rich-text-display blockquote {
  border-left: 8px solid #d0e5f2;
  padding: 5px 10px;
  margin: 10px 0;
  background-color: #f1f1f1;
}
</style>
