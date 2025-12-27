<template>
  <a-alert message="数据操作" type="info" show-icon style="margin-bottom: 16px">
    <template #description>
      <div style="font-size: 12px;">
        <p>执行SQL语句，系统会自动将<strong>上下文变量</strong>注入为SQL参数。</p>
        <p><strong>使用方式:</strong> 直接使用 <code>@参数名</code> (例如请求参数为 id，则写 @id)</p>
        <p><strong>Example:</strong> SELECT * FROM production_plans WHERE plan_no = @id</p>
        <p><strong>Output:</strong> 结果数组将存入 <code>dbResult</code> 变量供后续使用</p>
      </div>
    </template>
  </a-alert>
  <a-form-item label="数据源">
    <a-select v-model:value="node.data.sourceId" @change="onChange">
      <a-select-option value="db1">主业务库 (MySQL)</a-select-option>
      <a-select-option value="db2">日志库 (MongoDB)</a-select-option>
    </a-select>
  </a-form-item>
  <a-form-item label="操作类型">
    <a-select v-model:value="node.data.opType" @change="onChange">
      <a-select-option value="select">查询 (Select)</a-select-option>
      <a-select-option value="insert">插入 (Insert)</a-select-option>
      <a-select-option value="update">更新 (Update)</a-select-option>
      <a-select-option value="delete">删除 (Delete)</a-select-option>
    </a-select>
  </a-form-item>
  <a-form-item label="SQL语句">
    <a-textarea v-model:value="node.data.sql" :rows="5" placeholder="SELECT * FROM production_plans WHERE plan_no = @id" @input="onChange" />
  </a-form-item>
</template>

<script setup lang="ts">
const props = defineProps<{
  node: any;
  readOnly?: boolean;
}>();

const emit = defineEmits(['change']);

const onChange = () => {
  emit('change');
};
</script>
