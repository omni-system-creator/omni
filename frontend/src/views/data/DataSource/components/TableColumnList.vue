<template>
  <div>
    <div style="padding: 12px">
      <a-button type="primary" @click="$emit('addColumn')">
        <template #icon><PlusOutlined /></template> 添加列
      </a-button>
    </div>
    <a-table 
      :columns="columnDefs" 
      :data-source="columnData" 
      :pagination="false" 
      size="small" 
      bordered 
      :loading="loadingColumns"
    >
      <template #bodyCell="{ column, record }">
        <template v-if="['isPrimaryKey', 'isNullable'].includes(column.key)">
          <a-checkbox :checked="record[column.key]" disabled />
        </template>
        <template v-if="column.key === 'action'">
          <a-space>
            <a-button type="text" size="small" @click="$emit('editColumn', record)">
               <template #icon><EditOutlined /></template>
            </a-button>
            <a-popconfirm title="确定删除该列吗？" @confirm="$emit('deleteColumn', record)">
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
  columnDefs: any[];
  columnData: any[];
  loadingColumns: boolean;
}>();

defineEmits<{
  (e: 'addColumn'): void;
  (e: 'editColumn', record: any): void;
  (e: 'deleteColumn', record: any): void;
}>();
</script>
