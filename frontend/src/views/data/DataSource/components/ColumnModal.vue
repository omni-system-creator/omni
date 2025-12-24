<template>
  <a-modal
    :open="open"
    :title="mode === 'add' ? '添加列' : '修改列'"
    :confirmLoading="loading"
    @ok="handleOk"
    @cancel="handleCancel"
  >
    <a-form :model="formState" :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }">
      <a-form-item label="列名" required>
        <a-input v-model:value="formState.name" />
      </a-form-item>
      <a-form-item label="类型">
        <a-select v-model:value="formState.dataType">
          <a-select-option value="int">int</a-select-option>
          <a-select-option value="varchar">varchar</a-select-option>
          <a-select-option value="text">text</a-select-option>
          <a-select-option value="datetime">datetime</a-select-option>
          <a-select-option value="decimal">decimal</a-select-option>
          <a-select-option value="bigint">bigint</a-select-option>
          <a-select-option value="tinyint">tinyint</a-select-option>
          <a-select-option value="double">double</a-select-option>
          <a-select-option value="date">date</a-select-option>
        </a-select>
      </a-form-item>
      <a-form-item label="长度">
        <a-input-number v-model:value="formState.length" :disabled="['text', 'datetime', 'date'].includes(formState.dataType)" />
      </a-form-item>
      <a-form-item label="默认值">
        <a-input v-model:value="formState.defaultValue" />
      </a-form-item>
      <a-form-item label="注释">
        <a-input v-model:value="formState.comment" />
      </a-form-item>
      <a-form-item label="选项">
        <a-checkbox v-model:checked="formState.isNullable">允许空值</a-checkbox>
        <a-checkbox v-model:checked="formState.isPrimaryKey" :disabled="mode === 'edit'">主键</a-checkbox>
        <a-checkbox v-model:checked="formState.isAutoIncrement" :disabled="!['int', 'bigint', 'tinyint'].includes(formState.dataType)">自增</a-checkbox>
      </a-form-item>
      <a-form-item label="位置">
        <a-radio-group v-model:value="formState.positionType">
            <a-radio value="last" v-if="mode === 'add'">最后</a-radio>
            <a-radio value="first">最前</a-radio>
            <a-radio value="after">指定列后</a-radio>
            <a-radio value="current" v-if="mode === 'edit'">当前位置</a-radio>
        </a-radio-group>
        <div v-if="formState.positionType === 'after'" style="margin-top: 8px;">
            <a-select v-model:value="formState.afterColumn" placeholder="选择列" style="width: 200px">
                <a-select-option v-for="col in existingColumns" :key="col.name" :value="col.name">
                    {{ col.name }}
                </a-select-option>
            </a-select>
        </div>
      </a-form-item>
    </a-form>
  </a-modal>
</template>

<script setup lang="ts">
import { ref, reactive, watch } from 'vue';
import { message } from 'ant-design-vue';
import * as api from '@/api/dataSource';
import type { ColumnDefinitionDto } from '@/api/dataSource';

const props = defineProps<{
  open: boolean;
  mode: 'add' | 'edit';
  initialData?: ColumnDefinitionDto;
  existingColumns?: any[];
  connectionId: number;
  databaseName: string;
  tableName: string;
}>();

const emit = defineEmits(['update:open', 'success']);

const loading = ref(false);

interface ExtendedColumnForm extends ColumnDefinitionDto {
  positionType: 'first' | 'last' | 'after' | 'current';
  afterColumn?: string;
}

const formState = reactive<ExtendedColumnForm>({
  name: '',
  dataType: 'varchar',
  length: 255,
  isNullable: true,
  isPrimaryKey: false,
  isAutoIncrement: false,
  defaultValue: '',
  comment: '',
  positionType: 'last',
  afterColumn: undefined
});

watch(
  () => props.open,
  (val) => {
    if (val) {
      if (props.mode === 'edit' && props.initialData) {
        Object.assign(formState, props.initialData);
        formState.positionType = 'current'; // Default for edit
        formState.afterColumn = undefined;
      } else {
        // Reset
        formState.name = '';
        formState.dataType = 'varchar';
        formState.length = 255;
        formState.isNullable = true;
        formState.isPrimaryKey = false;
        formState.isAutoIncrement = false;
        formState.defaultValue = '';
        formState.comment = '';
        formState.positionType = 'last';
        formState.afterColumn = undefined;
      }
    }
  }
);

const handleCancel = () => {
  emit('update:open', false);
};

const handleOk = async () => {
  if (!formState.name) {
    message.warning('请输入列名');
    return;
  }
  loading.value = true;
  try {
    const commonData = {
        name: formState.name,
        dataType: formState.dataType,
        length: formState.length,
        isNullable: formState.isNullable,
        isPrimaryKey: formState.isPrimaryKey,
        isAutoIncrement: formState.isAutoIncrement,
        defaultValue: formState.defaultValue,
        comment: formState.comment,
    };

    if (props.mode === 'add') {
      const dto = {
          ...commonData,
          isFirst: formState.positionType === 'first',
          afterColumn: formState.positionType === 'after' ? formState.afterColumn : undefined
      };
      await api.addColumn(props.connectionId, props.databaseName, props.tableName, dto);
      message.success('添加成功');
    } else {
      const oldName = props.initialData?.name || formState.name;
      const dto = {
          ...commonData,
          newName: formState.name !== oldName ? formState.name : undefined,
          isFirst: formState.positionType === 'first',
          afterColumn: formState.positionType === 'after' ? formState.afterColumn : undefined
      };
      await api.modifyColumn(props.connectionId, props.databaseName, props.tableName, oldName, dto);
      message.success('修改成功');
    }
    emit('update:open', false);
    emit('success');
  } catch (error) {
    console.error(error);
    message.error('操作失败');
  } finally {
    loading.value = false;
  }
};
</script>
