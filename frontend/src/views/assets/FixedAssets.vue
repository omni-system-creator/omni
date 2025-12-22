<template>
  <div class="fixed-assets-container">
    <a-card :bordered="false">
      <!-- Search -->
      <a-form layout="inline" :model="searchForm" class="search-form">
        <a-form-item label="资产名称/编号">
          <a-input v-model:value="searchForm.keyword" placeholder="请输入" allow-clear />
        </a-form-item>
        <a-form-item label="资产类别">
          <a-select v-model:value="searchForm.category" placeholder="请选择" style="width: 150px" allow-clear>
            <a-select-option value="computer">计算机/笔记本</a-select-option>
            <a-select-option value="server">服务器</a-select-option>
            <a-select-option value="peripheral">外设</a-select-option>
            <a-select-option value="mobile">移动设备</a-select-option>
            <a-select-option value="furniture">办公家具</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="使用部门">
          <a-select v-model:value="searchForm.dept" placeholder="请选择" style="width: 150px" allow-clear>
            <a-select-option value="rd">研发部</a-select-option>
            <a-select-option value="product">产品部</a-select-option>
            <a-select-option value="ops">运维部</a-select-option>
            <a-select-option value="admin">行政部</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="状态">
          <a-select v-model:value="searchForm.status" placeholder="请选择" style="width: 120px" allow-clear>
            <a-select-option value="in_use">使用中</a-select-option>
            <a-select-option value="idle">闲置</a-select-option>
            <a-select-option value="maintenance">维修中</a-select-option>
            <a-select-option value="scrapped">已报废</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item>
          <a-button type="primary" @click="handleSearch">
            <template #icon><SearchOutlined /></template>
            查询
          </a-button>
          <a-button style="margin-left: 8px" @click="resetSearch">重置</a-button>
        </a-form-item>
      </a-form>

      <!-- Toolbar -->
      <div class="table-operations">
        <a-button type="primary" @click="handleAdd">
          <template #icon><PlusOutlined /></template>
          新增资产
        </a-button>
        <a-button>
          <template #icon><ExportOutlined /></template>
          导出
        </a-button>
        <a-button>
          <template #icon><ImportOutlined /></template>
          导入
        </a-button>
      </div>

      <!-- Table -->
      <a-table 
        :columns="columns" 
        :data-source="data" 
        :pagination="pagination"
        :loading="loading"
        row-key="id"
      >
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'status'">
            <a-tag :color="getStatusColor(record.status)">
              {{ getStatusText(record.status) }}
            </a-tag>
          </template>
          <template v-if="column.key === 'price'">
            ¥ {{ record.price.toLocaleString() }}
          </template>
          <template v-if="column.key === 'action'">
            <a-space>
              <a @click="handleEdit(record)">编辑</a>
              <a @click="handleView(record)">详情</a>
              <a-dropdown>
                <a class="ant-dropdown-link" @click.prevent>
                  更多 <DownOutlined />
                </a>
                <template #overlay>
                  <a-menu>
                    <a-menu-item>
                      <a @click="handleTransfer(record)">领用/调拨</a>
                    </a-menu-item>
                    <a-menu-item>
                      <a @click="handleRepair(record)">报修</a>
                    </a-menu-item>
                    <a-menu-item>
                      <a @click="handleScrap(record)" style="color: red">报废</a>
                    </a-menu-item>
                  </a-menu>
                </template>
              </a-dropdown>
            </a-space>
          </template>
        </template>
      </a-table>
    </a-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue';
import { 
  SearchOutlined, 
  PlusOutlined, 
  ExportOutlined, 
  ImportOutlined,
  DownOutlined 
} from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';

const loading = ref(false);

const searchForm = reactive({
  keyword: '',
  category: undefined,
  dept: undefined,
  status: undefined
});

const columns = [
  { title: '资产编号', dataIndex: 'assetNo', key: 'assetNo', width: 120 },
  { title: '资产名称', dataIndex: 'name', key: 'name' },
  { title: '类别', dataIndex: 'categoryName', key: 'categoryName', width: 150 },
  { title: '型号/规格', dataIndex: 'model', key: 'model' },
  { title: '使用部门', dataIndex: 'deptName', key: 'deptName', width: 100 },
  { title: '使用人', dataIndex: 'userName', key: 'userName', width: 100 },
  { title: '原值', dataIndex: 'price', key: 'price', width: 100, align: 'right' },
  { title: '购入日期', dataIndex: 'purchaseDate', key: 'purchaseDate', width: 120 },
  { title: '状态', dataIndex: 'status', key: 'status', width: 100 },
  { title: '操作', key: 'action', width: 200, fixed: 'right' }
];

const data = ref([
  {
    id: 1,
    assetNo: 'FA-2024001',
    name: 'MacBook Pro 16"',
    categoryName: '笔记本电脑',
    model: 'M3 Max / 64GB / 2TB',
    deptName: '研发部',
    userName: '张三',
    price: 32000,
    purchaseDate: '2024-01-15',
    status: 'in_use'
  },
  {
    id: 2,
    assetNo: 'FA-2024002',
    name: 'Dell PowerEdge R750',
    categoryName: '服务器',
    model: 'Xeon Gold / 512GB',
    deptName: '运维部',
    userName: '李四',
    price: 85000,
    purchaseDate: '2024-02-10',
    status: 'in_use'
  },
  {
    id: 3,
    assetNo: 'FA-2023055',
    name: 'Dell UltraSharp 27"',
    categoryName: '显示器',
    model: 'U2723QE 4K',
    deptName: '设计部',
    userName: '王五',
    price: 4500,
    purchaseDate: '2023-11-05',
    status: 'in_use'
  },
  {
    id: 4,
    assetNo: 'FA-2023012',
    name: 'Herman Miller Aeron',
    categoryName: '办公家具',
    model: 'Size B / Graphite',
    deptName: '总经办',
    userName: '赵六',
    price: 12000,
    purchaseDate: '2023-03-20',
    status: 'in_use'
  },
  {
    id: 5,
    assetNo: 'FA-2022100',
    name: 'ThinkPad X1 Carbon',
    categoryName: '笔记本电脑',
    model: 'Gen 10 / i7 / 16GB',
    deptName: '资产库',
    userName: '-',
    price: 14000,
    purchaseDate: '2022-06-15',
    status: 'idle'
  },
  {
    id: 6,
    assetNo: 'FA-2021005',
    name: 'HP LaserJet Pro',
    categoryName: '打印机',
    model: 'M404dn',
    deptName: '行政部',
    userName: '公共',
    price: 3500,
    purchaseDate: '2021-02-10',
    status: 'maintenance'
  }
]);

const pagination = {
  total: data.value.length,
  pageSize: 10,
  showSizeChanger: true,
  showQuickJumper: true
};

const getStatusColor = (status: string) => {
  const map: Record<string, string> = {
    in_use: 'green',
    idle: 'orange',
    maintenance: 'red',
    scrapped: 'default'
  };
  return map[status] || 'default';
};

const getStatusText = (status: string) => {
  const map: Record<string, string> = {
    in_use: '使用中',
    idle: '闲置',
    maintenance: '维修中',
    scrapped: '已报废'
  };
  return map[status] || status;
};

const handleSearch = () => {
  loading.value = true;
  setTimeout(() => loading.value = false, 500);
};

const resetSearch = () => {
  searchForm.keyword = '';
  searchForm.category = undefined;
  searchForm.dept = undefined;
  searchForm.status = undefined;
};

const handleAdd = () => message.info('打开新增资产弹窗');
const handleEdit = (record: any) => message.info(`编辑资产: ${record.name}`);
const handleView = (record: any) => message.info(`查看资产详情: ${record.name}`);
const handleTransfer = (record: any) => message.info(`领用/调拨: ${record.name}`);
const handleRepair = (record: any) => message.info(`报修: ${record.name}`);
const handleScrap = (record: any) => message.info(`报废申请: ${record.name}`);
</script>

<style scoped>
.fixed-assets-container {
  padding: 16px;
  background-color: #f0f2f5;
  min-height: 100%;
}
.search-form {
  margin-bottom: 24px;
}
.table-operations {
  margin-bottom: 16px;
}
.table-operations > button {
  margin-right: 8px;
}
</style>