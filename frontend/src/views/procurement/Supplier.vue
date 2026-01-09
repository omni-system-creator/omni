<template>
  <div class="page-container">
    <div class="action-header">
      <div class="search-area">
        <a-input-search
          v-model:value="searchText"
          placeholder="搜索供应商名称/联系人"
          style="width: 250px"
          @search="onSearch"
        />
        <a-select v-model:value="filterCategory" style="width: 150px; margin-left: 8px" placeholder="供应商类别">
          <a-select-option value="all">所有类别</a-select-option>
          <a-select-option value="material">原材料</a-select-option>
          <a-select-option value="equipment">设备设施</a-select-option>
          <a-select-option value="service">服务外包</a-select-option>
        </a-select>
        <a-select v-model:value="filterStatus" style="width: 120px; margin-left: 8px" placeholder="状态">
          <a-select-option value="active">合作中</a-select-option>
          <a-select-option value="suspended">暂停</a-select-option>
          <a-select-option value="blacklisted">黑名单</a-select-option>
        </a-select>
      </div>
      <div class="btn-area">
        <a-button type="primary">
          <template #icon><PlusOutlined /></template>
          新增供应商
        </a-button>
        <a-button style="margin-left: 8px">
          <template #icon><ImportOutlined /></template>
          导入
        </a-button>
      </div>
    </div>

    <a-table :columns="columns" :data-source="supplierList" :pagination="pagination">
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'status'">
          <a-badge :status="getStatusBadge(record.status)" :text="getStatusText(record.status)" />
        </template>
        <template v-else-if="column.key === 'rating'">
          <a-rate :value="record.rating" disabled allow-half style="font-size: 14px" />
        </template>
        <template v-else-if="column.key === 'action'">
          <a-space>
            <a>详情</a>
            <a>考核</a>
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
import { PlusOutlined, ImportOutlined } from '@ant-design/icons-vue';
import type { PresetStatusColorType } from 'ant-design-vue/es/_util/colors';

const searchText = ref('');
const filterCategory = ref('all');
const filterStatus = ref('active');

const columns: ColumnType[] = [
  { title: '供应商名称', dataIndex: 'name', key: 'name', width: 200 },
  { title: '类别', dataIndex: 'category', key: 'category', width: 120 },
  { title: '主要产品/服务', dataIndex: 'products', key: 'products' },
  { title: '联系人', dataIndex: 'contact', key: 'contact', width: 100 },
  { title: '联系电话', dataIndex: 'phone', key: 'phone', width: 150 },
  { title: '评级', dataIndex: 'rating', key: 'rating', width: 150 },
  { title: '状态', dataIndex: 'status', key: 'status', width: 100 },
  { title: '操作', key: 'action', width: 180 },
];

const supplierList = ref([
  { key: '1', name: 'XX电子元器件有限公司', category: '原材料', products: '芯片, 电阻, 电容', contact: '张经理', phone: '13812345678', rating: 4.5, status: 'active' },
  { key: '2', name: 'YY办公设备有限公司', category: '设备设施', products: '打印机, 投影仪', contact: '李主管', phone: '13987654321', rating: 4.0, status: 'active' },
  { key: '3', name: 'ZZ人力资源服务公司', category: '服务外包', products: '劳务派遣, 猎头服务', contact: '王专员', phone: '13766668888', rating: 3.5, status: 'suspended' },
  { key: '4', name: '不良供应商示例', category: '原材料', products: '劣质钢材', contact: '赵四', phone: '13000000000', rating: 1.0, status: 'blacklisted' },
]);

const pagination = {
  total: 50,
  showSizeChanger: true,
  showQuickJumper: true,
};

const onSearch = () => {
  console.log('search');
};

const getStatusBadge = (status: string): PresetStatusColorType => {
  const map: Record<string, PresetStatusColorType> = {
    active: 'success',
    suspended: 'warning',
    blacklisted: 'error',
  };
  return map[status] || 'default';
};

const getStatusText = (status: string) => {
  const map: Record<string, string> = {
    active: '合作中',
    suspended: '暂停合作',
    blacklisted: '黑名单',
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