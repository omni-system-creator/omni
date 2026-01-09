<template>
  <div class="table-data-list">
     <div class="data-toolbar">
       <a-space>
          <a-button type="primary" @click="$emit('insertRow')">
            <template #icon><PlusOutlined /></template> 新增数据
          </a-button>
          <a-divider type="vertical" />
          <a-select v-model:value="queryState.filterField" style="width: 120px" placeholder="选择字段">
            <a-select-option v-for="col in columnData" :key="col.name" :value="col.name">{{ getFieldLabel(col) }}</a-select-option>
          </a-select>
          <a-select v-model:value="queryState.filterOperator" style="width: 100px">
            <a-select-option value="=">=</a-select-option>
            <a-select-option value="like">包含</a-select-option>
            <a-select-option value=">">&gt;</a-select-option>
            <a-select-option value="<">&lt;</a-select-option>
          </a-select>
          <a-input v-model:value="queryState.filterValue" placeholder="输入值" style="width: 200px" allow-clear />
          <a-button type="primary" @click="$emit('filter')">查询</a-button>
          <a-button @click="$emit('resetFilter')">重置</a-button>
       </a-space>
     </div>
     <a-table 
        :columns="previewColumns" 
        :data-source="previewData" 
        :pagination="pagination" 
        :loading="loadingData"
        size="small" 
        :scroll="{ x: 'max-content' }" 
        @change="onTableChange"
     >
        <template #bodyCell="{ column, record }">
            <template v-if="column.key === 'action'">
                <a-space>
                    <a-button type="text" size="small" @click="$emit('editRow', record)">
                        <template #icon><EditOutlined /></template>
                    </a-button>
                    <a-popconfirm title="确定删除该行吗？" @confirm="$emit('deleteRow', record)">
                        <a-button type="text" danger size="small">
                            <template #icon><DeleteOutlined /></template>
                        </a-button>
                    </a-popconfirm>
                </a-space>
            </template>
        </template>
     </a-table>
  </div>
</template>

<script setup lang="ts">
import { 
  PlusOutlined, 
  EditOutlined, 
  DeleteOutlined 
} from '@ant-design/icons-vue';

defineProps<{
  columnData: any[];
  previewColumns: any[];
  previewData: any[];
  pagination: any;
  loadingData: boolean;
  queryState: any;
}>();

const emit = defineEmits<{
  (e: 'insertRow'): void;
  (e: 'filter'): void;
  (e: 'resetFilter'): void;
  (e: 'tableChange', pagination: any, filters: any, sorter: any): void;
  (e: 'editRow', record: any): void;
  (e: 'deleteRow', record: any): void;
}>();

const getFieldLabel = (col: any) => {
  if (!col.comment) return col.name;
  let label = col.comment.split(/,|，/)[0];
  if (label.length > 8) {
    label = label.substring(0, 8) + '...';
  }
  return label;
};

const onTableChange = (pag: any, filters: any, sorter: any) => {
    emit('tableChange', pag, filters, sorter);
};
</script>

<style scoped>
.table-data-list {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.data-toolbar {
  margin-bottom: 16px;
  padding: 12px;
  background: #fafafa;
  border-radius: 4px;
}
</style>
