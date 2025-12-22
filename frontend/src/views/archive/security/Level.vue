<template>
  <div class="security-level-content">
    <a-card :bordered="false">
      <template #extra>
        <a-button type="primary" @click="handleAdd">
          <template #icon><PlusOutlined /></template>
          新增密级
        </a-button>
      </template>
      
      <a-table :columns="columns" :data-source="data">
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'level'">
            <a-tag color="red" v-if="record.level >= 80">{{ record.level }}</a-tag>
            <a-tag color="orange" v-else-if="record.level >= 50">{{ record.level }}</a-tag>
            <a-tag color="blue" v-else>{{ record.level }}</a-tag>
          </template>
          <template v-if="column.key === 'action'">
            <a-space>
              <a-tooltip title="编辑">
                <a-button type="text" size="small" @click="handleEdit(record)">
                  <template #icon><EditOutlined /></template>
                </a-button>
              </a-tooltip>
              <a-tooltip title="删除">
                <a-button type="text" danger size="small" @click="handleDelete(record)">
                  <template #icon><DeleteOutlined /></template>
                </a-button>
              </a-tooltip>
            </a-space>
          </template>
        </template>
      </a-table>
    </a-card>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { PlusOutlined, EditOutlined, DeleteOutlined } from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';

const columns = [
  { title: '密级名称', dataIndex: 'name', key: 'name' },
  { title: '密级权重', dataIndex: 'level', key: 'level', width: 100 },
  { title: '说明', dataIndex: 'description', key: 'description' },
  { title: '关联档案数量', dataIndex: 'count', key: 'count', width: 150 },
  { title: '创建时间', dataIndex: 'createTime', key: 'createTime', width: 180 },
  { title: '操作', key: 'action', width: 150 }
];

const data = ref([
  { key: '1', name: '绝密', level: 100, description: '最高安全级别，仅特定人员可访问', count: 12, createTime: '2024-01-01 10:00:00' },
  { key: '2', name: '机密', level: 80, description: '涉及国家/商业机密，严格控制访问', count: 156, createTime: '2024-01-01 10:00:00' },
  { key: '3', name: '秘密', level: 60, description: '一般性秘密文件，内部公开', count: 532, createTime: '2024-01-01 10:00:00' },
  { key: '4', name: '公开', level: 10, description: '全员可见，无特殊限制', count: 2400, createTime: '2024-01-01 10:00:00' },
]);

const handleAdd = () => {
  message.info('新增密级弹窗');
};

const handleEdit = (record: any) => {
  message.info(`编辑密级：${record.name}`);
};

const handleDelete = (record: any) => {
  message.warning(`删除密级：${record.name}`);
};
</script>

<style scoped>
.security-level-content {
  padding: 0;
}
</style>
