<template>
  <a-modal
    :open="open"
    :title="mode === 'insert' ? '新增数据' : '编辑数据'"
    :confirmLoading="loading"
    @ok="handleOk"
    @cancel="handleCancel"
    width="600px"
  >
    <a-form :model="formData" :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }">
      <template v-for="col in columns" :key="col.name">
        <a-form-item 
          :label="getFieldLabel(col)"
          :required="!col.isNullable && col.defaultValue === null && !col.isAutoIncrement"
        >
          <a-input 
            v-if="['varchar', 'char', 'text', 'longtext'].includes(col.columnType) || col.dataType === 'string'"
            v-model:value="formData[col.name]" 
            :disabled="mode === 'edit' && col.isPrimaryKey"
          />
          
          <a-input-number 
            v-else-if="['int', 'bigint', 'tinyint', 'smallint', 'decimal', 'double', 'float'].includes(col.columnType) || col.dataType === 'number'"
            v-model:value="formData[col.name]"
            style="width: 100%"
            :disabled="(col.isAutoIncrement && mode === 'insert') || (mode === 'edit' && col.isPrimaryKey)"
          />
          
          <a-date-picker 
            v-else-if="['datetime', 'timestamp'].includes(col.columnType)"
            v-model:value="formData[col.name]"
            show-time
            value-format="YYYY-MM-DD HH:mm:ss"
            style="width: 100%"
            :disabled="mode === 'edit' && col.isPrimaryKey"
          />
           <a-date-picker 
            v-else-if="['date'].includes(col.columnType)"
            v-model:value="formData[col.name]"
            value-format="YYYY-MM-DD"
            style="width: 100%"
            :disabled="mode === 'edit' && col.isPrimaryKey"
          />

          <a-switch 
             v-else-if="['bit', 'boolean'].includes(col.columnType)"
             v-model:checked="formData[col.name]"
             :disabled="mode === 'edit' && col.isPrimaryKey"
          />

          <a-input 
            v-else 
            v-model:value="formData[col.name]"
            :disabled="mode === 'edit' && col.isPrimaryKey"
          />
          
          <div v-if="col.comment" style="font-size: 12px; color: #999">{{ col.comment }}</div>
        </a-form-item>
      </template>
    </a-form>
  </a-modal>
</template>

<script setup lang="ts">
import { ref, reactive, watch } from 'vue';
import { message } from 'ant-design-vue';
import * as api from '@/api/dataSource';

const props = defineProps<{
  open: boolean;
  mode: 'insert' | 'edit';
  columns: any[];
  initialData?: any;
  connectionId: number;
  databaseName: string;
  tableName: string;
}>();

const emit = defineEmits(['update:open', 'success']);

const loading = ref(false);
const formData = reactive<any>({});

const getFieldLabel = (col: any) => {
  if (!col.comment) return col.name;
  let label = col.comment.split(/,|，/)[0];
  if (label.length > 8) {
    label = label.substring(0, 8) + '...';
  }
  return label;
};

watch(
  () => props.open,
  (val) => {
    if (val) {
      // Initialize form data
      Object.keys(formData).forEach(key => delete formData[key]);
      
      if (props.mode === 'edit' && props.initialData) {
        Object.assign(formData, props.initialData);
      } else {
        // Initialize with default values if insert
        props.columns.forEach(col => {
           if (col.defaultValue !== undefined && col.defaultValue !== null) {
             formData[col.name] = col.defaultValue;
           } else {
             formData[col.name] = null;
           }
        });
      }
    }
  }
);

const handleCancel = () => {
  emit('update:open', false);
};

const handleOk = async () => {
  loading.value = true;
  try {
    if (props.mode === 'insert') {
      // Filter out nulls if needed, or backend handles it.
      // Usually we send all fields.
      await api.insertRow(props.connectionId, props.databaseName, props.tableName, formData);
      message.success('新增成功');
    } else {
      // Extract Primary Keys from initialData
      const keys: Record<string, any> = {};
      props.columns.filter(c => c.isPrimaryKey).forEach(c => {
          if (props.initialData) {
            keys[c.name] = props.initialData[c.name];
          }
      });

      if (Object.keys(keys).length === 0) {
        message.warning('未找到主键，可能无法精确更新');
        // Fallback or proceed? Original code warned.
      }

      await api.updateRow(props.connectionId, props.databaseName, props.tableName, keys, formData);
      message.success('更新成功');
    }
    emit('update:open', false);
    emit('success');
  } catch (error) {
    console.error(error);
    message.error(props.mode === 'insert' ? '新增失败' : '更新失败');
  } finally {
    loading.value = false;
  }
};
</script>
