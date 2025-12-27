<template>
  <a-alert message="外部接口" type="info" show-icon style="margin-bottom: 16px">
    <template #description>
      <div style="font-size: 12px;">
        <p>调用外部HTTP服务。</p>
        <p><strong>参数传递:</strong> 默认将所有上下文变量作为参数发送。也可自定义映射。</p>
        <p><strong>Example:</strong> http://mes-system/api/check_stock</p>
      </div>
    </template>
  </a-alert>
  <a-form-item label="目标URL">
    <a-input v-model:value="node.data.url" @change="onChange" @input="onChange" />
  </a-form-item>
  <a-form-item label="方法">
    <a-select v-model:value="node.data.method" defaultValue="GET" @change="onChange">
      <a-select-option value="GET">GET</a-select-option>
      <a-select-option value="POST">POST</a-select-option>
      <a-select-option value="PUT">PUT</a-select-option>
      <a-select-option value="DELETE">DELETE</a-select-option>
    </a-select>
  </a-form-item>

  <a-divider style="margin: 12px 0" />

  <div style="margin-bottom: 8px; font-weight: 500;">请求头 (Headers)</div>
  <div v-for="(header, index) in (node.data.headers || [])" :key="index" style="display: flex; gap: 8px; margin-bottom: 8px;">
    <a-input v-model:value="header.key" placeholder="Key" style="flex: 1" />
    <a-input v-model:value="header.value" placeholder="Value" style="flex: 1" />
    <a-button type="text" danger @click="removeHeader(Number(index))">
      <template #icon><CloseOutlined /></template>
    </a-button>
  </div>
  <a-button type="dashed" block @click="addHeader" style="margin-bottom: 16px">
    <PlusOutlined /> 添加Header
  </a-button>

  <div style="margin-bottom: 8px; font-weight: 500;">参数传递</div>
  <a-radio-group v-model:value="node.data.paramMode" style="margin-bottom: 12px" name="paramMode">
    <a-radio-button value="all">全部上下文</a-radio-button>
    <a-radio-button value="custom">自定义映射</a-radio-button>
  </a-radio-group>

  <template v-if="node.data.paramMode === 'custom'">
    <div v-for="(param, index) in (node.data.params || [])" :key="index" style="display: flex; gap: 8px; margin-bottom: 8px;">
      <a-input v-model:value="param.key" placeholder="参数名" style="flex: 1" />
      <a-input v-model:value="param.value" placeholder="取值 (e.g. @dbResult[0].id)" style="flex: 1" />
      <a-button type="text" danger @click="removeParam(Number(index))">
        <template #icon><CloseOutlined /></template>
      </a-button>
    </div>
    <a-button type="dashed" block @click="addParam">
      <PlusOutlined /> 添加参数
    </a-button>
  </template>
</template>

<script setup lang="ts">
import { CloseOutlined, PlusOutlined } from '@ant-design/icons-vue';

const props = defineProps<{
  node: any;
  readOnly?: boolean;
}>();

const emit = defineEmits(['change']);

const onChange = () => {
  emit('change');
};

const addHeader = () => {
  if (!props.node.data.headers) {
    props.node.data.headers = [];
  }
  props.node.data.headers.push({ key: '', value: '' });
};

const removeHeader = (index: number) => {
  if (!props.node.data.headers) return;
  props.node.data.headers.splice(index, 1);
};

const addParam = () => {
  if (!props.node.data.params) {
    props.node.data.params = [];
  }
  props.node.data.params.push({ key: '', value: '' });
};

const removeParam = (index: number) => {
  if (!props.node.data.params) return;
  props.node.data.params.splice(index, 1);
};
</script>
