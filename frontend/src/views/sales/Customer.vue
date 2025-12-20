<template>
  <div class="page-container">
    <div class="action-header">
      <div class="search-area">
        <a-input-search
          v-model:value="searchText"
          placeholder="搜索客户名称/联系人"
          style="width: 250px"
          @search="onSearch"
        />
        <a-select v-model:value="filterStatus" style="width: 120px; margin-left: 8px">
          <a-select-option value="all">所有状态</a-select-option>
          <a-select-option value="active">活跃</a-select-option>
          <a-select-option value="potential">潜在</a-select-option>
          <a-select-option value="lost">流失</a-select-option>
        </a-select>
      </div>
      <div class="btn-area">
        <a-button type="primary">
          <template #icon><PlusOutlined /></template>
          新增客户
        </a-button>
        <a-button>
          <template #icon><ExportOutlined /></template>
          导出
        </a-button>
      </div>
    </div>

    <a-table :columns="columns" :data-source="customerList" :pagination="pagination">
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'status'">
          <a-tag :color="getStatusColor(record.status)">
            {{ getStatusText(record.status) }}
          </a-tag>
        </template>
        <template v-else-if="column.key === 'action'">
          <a-space>
            <a>详情</a>
            <a>编辑</a>
            <a-divider type="vertical" />
            <a class="delete-btn">删除</a>
          </a-space>
        </template>
      </template>
    </a-table>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { PlusOutlined, ExportOutlined } from '@ant-design/icons-vue';

const searchText = ref('');
const filterStatus = ref('all');

const columns = [
  { title: '客户名称', dataIndex: 'name', key: 'name' },
  { title: '行业', dataIndex: 'industry', key: 'industry' },
  { title: '联系人', dataIndex: 'contact', key: 'contact' },
  { title: '电话', dataIndex: 'phone', key: 'phone' },
  { title: '客户等级', dataIndex: 'level', key: 'level' },
  { title: '状态', dataIndex: 'status', key: 'status' },
  { title: '负责人', dataIndex: 'owner', key: 'owner' },
  { title: '操作', key: 'action', width: 200 },
];

const customerList = ref([
  { key: '1', name: '某某科技股份有限公司', industry: '互联网', contact: '张总', phone: '13800138000', level: 'A级', status: 'active', owner: '李四' },
  { key: '2', name: '上海某某贸易有限公司', industry: '零售', contact: '王经理', phone: '13900139000', level: 'B级', status: 'potential', owner: '王五' },
  { key: '3', name: '北京某某咨询中心', industry: '咨询', contact: '赵老师', phone: '13700137000', level: 'C级', status: 'lost', owner: '赵六' },
]);

const pagination = {
  total: 100,
  showSizeChanger: true,
  showQuickJumper: true,
};

const onSearch = () => {
  console.log('search');
};

const getStatusColor = (status: string) => {
  const map: Record<string, string> = {
    active: 'green',
    potential: 'blue',
    lost: 'red',
  };
  return map[status] || 'default';
};

const getStatusText = (status: string) => {
  const map: Record<string, string> = {
    active: '活跃',
    potential: '潜在',
    lost: '流失',
  };
  return map[status] || status;
};
</script>

<style scoped>
.page-container {
  padding: 24px;
  background: #fff;
  min-height: 100%;
}

.action-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 16px;
}

.delete-btn {
  color: #ff4d4f;
}
</style>