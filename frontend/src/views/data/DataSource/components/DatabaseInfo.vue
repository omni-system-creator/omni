<template>
  <div class="pane-content">
    <div class="pane-header">
      <h3>{{ title }} - 表列表</h3>
      <a-space>
        <a-button type="primary" @click="$emit('createTable')">
          <template #icon><PlusOutlined /></template> 新建表
        </a-button>
        <a-button @click="$emit('refresh')">
          <template #icon><ReloadOutlined /></template> 刷新
        </a-button>
      </a-space>
    </div>
    <a-table 
      :columns="columns" 
      :data-source="data" 
      :loading="loading"
      :pagination="{ pageSize: 15 }"
      size="middle"
    >
       <template #bodyCell="{ column, record }">
         <template v-if="column.key === 'action'">
           <a @click="$emit('openTable', record)">查看数据</a>
         </template>
       </template>
    </a-table>
  </div>
</template>

<script setup lang="ts">
import { PlusOutlined, ReloadOutlined } from '@ant-design/icons-vue';

defineProps<{
  title: string;
  data: any[];
  loading: boolean;
  columns: any[];
}>();

defineEmits(['createTable', 'refresh', 'openTable']);
</script>

<style scoped>
.pane-content {
  padding: 16px;
}
.pane-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}
</style>
