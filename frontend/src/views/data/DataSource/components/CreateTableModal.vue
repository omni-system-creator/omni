<template>
  <a-modal
    :visible="visible"
    title="新建表"
    width="900px"
    :confirmLoading="loading"
    @ok="handleOk"
    @cancel="handleCancel"
  >
    <a-form :model="formState" layout="inline" style="margin-bottom: 16px">
      <a-form-item label="表名" required>
        <a-input v-model:value="formState.name" placeholder="表名" />
      </a-form-item>
      <a-form-item label="引擎">
        <a-select v-model:value="formState.engine" style="width: 100px">
          <a-select-option value="InnoDB">InnoDB</a-select-option>
          <a-select-option value="MyISAM">MyISAM</a-select-option>
        </a-select>
      </a-form-item>
      <a-form-item label="字符集">
        <a-select v-model:value="formState.charSet" style="width: 120px">
          <a-select-option value="utf8mb4">utf8mb4</a-select-option>
          <a-select-option value="utf8">utf8</a-select-option>
        </a-select>
      </a-form-item>
      <a-form-item label="备注">
        <a-input v-model:value="formState.comment" placeholder="备注" />
      </a-form-item>
    </a-form>

    <div class="table-columns-editor">
      <div style="margin-bottom: 8px">
        <a-button type="dashed" block @click="addColumn">
          <template #icon><PlusOutlined /></template> 添加列
        </a-button>
      </div>
      <a-table :data-source="formState.columns" :pagination="false" size="small" bordered :scroll="{ y: 400 }">
        <a-table-column title="列名" width="150px">
          <template #default="{ record }">
            <a-input v-model:value="record.name" />
          </template>
        </a-table-column>
        <a-table-column title="类型" width="120px">
          <template #default="{ record }">
            <a-select v-model:value="record.dataType" style="width: 100%">
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
          </template>
        </a-table-column>
        <a-table-column title="长度" width="80px">
          <template #default="{ record }">
            <a-input-number v-model:value="record.length" style="width: 100%" :disabled="['text', 'datetime', 'date'].includes(record.dataType)" />
          </template>
        </a-table-column>
        <a-table-column title="主键" width="60px" align="center">
          <template #default="{ record }">
            <a-checkbox v-model:checked="record.isPrimaryKey" />
          </template>
        </a-table-column>
        <a-table-column title="非空" width="60px" align="center">
          <template #default="{ record }">
            <a-checkbox v-model:checked="record.isNullable" :disabled="record.isPrimaryKey">
              <template #checkedChildren>空</template>
              <template #unCheckedChildren>非</template>
            </a-checkbox>
          </template>
        </a-table-column>
        <a-table-column title="自增" width="60px" align="center">
          <template #default="{ record }">
            <a-checkbox v-model:checked="record.isAutoIncrement" :disabled="!['int', 'bigint', 'tinyint'].includes(record.dataType) || !record.isPrimaryKey" />
          </template>
        </a-table-column>
        <a-table-column title="默认值" width="100px">
          <template #default="{ record }">
            <a-input v-model:value="record.defaultValue" />
          </template>
        </a-table-column>
        <a-table-column title="注释">
          <template #default="{ record }">
            <a-input v-model:value="record.comment" />
          </template>
        </a-table-column>
        <a-table-column title="操作" width="60px" align="center">
          <template #default="{ index }">
            <a-button type="text" danger size="small" @click="removeColumn(index)">
              <template #icon><DeleteOutlined /></template>
            </a-button>
          </template>
        </a-table-column>
      </a-table>
    </div>
  </a-modal>
</template>

<script setup lang="ts">
import { ref, reactive, watch } from 'vue';
import { message } from 'ant-design-vue';
import { PlusOutlined, DeleteOutlined } from '@ant-design/icons-vue';
import * as api from '@/api/dataSource';
import type { CreateTableDto, ColumnDefinitionDto } from '@/api/dataSource';

const props = defineProps<{
  visible: boolean;
  connectionId: number;
  databaseName: string;
}>();

const emit = defineEmits(['update:visible', 'success']);

const loading = ref(false);
const formState = reactive<CreateTableDto>({
  name: '',
  comment: '',
  engine: 'InnoDB',
  charSet: 'utf8mb4',
  collation: 'utf8mb4_general_ci',
  columns: []
});

const newColumn = (): ColumnDefinitionDto => ({
  name: '',
  dataType: 'varchar',
  length: 255,
  isNullable: true,
  isPrimaryKey: false,
  isAutoIncrement: false,
  defaultValue: '',
  comment: ''
});

watch(
  () => props.visible,
  (val) => {
    if (val) {
      formState.name = '';
      formState.comment = '';
      formState.columns = [
        { ...newColumn(), name: 'id', dataType: 'int', length: 11, isPrimaryKey: true, isAutoIncrement: true, isNullable: false }
      ];
    }
  }
);

const addColumn = () => {
  formState.columns.push(newColumn());
};

const removeColumn = (index: number) => {
  if (formState.columns.length > 1) {
    formState.columns.splice(index, 1);
  } else {
    message.warning('至少保留一列');
  }
};

const handleCancel = () => {
  emit('update:visible', false);
};

const handleOk = async () => {
  if (!formState.name) {
    message.warning('请输入表名');
    return;
  }
  if (formState.columns.length === 0) {
    message.warning('请至少添加一列');
    return;
  }
  for(const col of formState.columns) {
    if (!col.name) {
       message.warning('列名不能为空');
       return;
    }
  }

  loading.value = true;
  try {
    await api.createTable(props.connectionId, props.databaseName, formState);
    message.success('表创建成功');
    emit('update:visible', false);
    emit('success');
  } catch (error) {
    console.error(error);
    message.error('创建失败');
  } finally {
    loading.value = false;
  }
};
</script>
