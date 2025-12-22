<template>
  <div class="paper-archive-container">
    <SplitLayout>
      <template #left>
        <div class="left-tree-container">
          <a-card title="档案分类" :bordered="false" class="tree-card">
            <a-input-search style="margin-bottom: 8px" placeholder="搜索分类" allow-clear />
            <a-tree
              :tree-data="treeData"
              :default-expand-all="true"
              :show-line="true"
              @select="onSelectTree"
            >
            </a-tree>
          </a-card>
        </div>
      </template>
      <template #right>
        <div class="right-content-container">
          <a-card :bordered="false" class="search-card">
            <a-form layout="inline" :model="searchForm">
              <a-form-item label="关键词">
                <a-input v-model:value="searchForm.keyword" placeholder="题名/档号/盒号" allow-clear />
              </a-form-item>
              <a-form-item label="档案状态">
                <a-select v-model:value="searchForm.status" placeholder="请选择" style="width: 120px" allow-clear>
                  <a-select-option value="in_storage">在库</a-select-option>
                  <a-select-option value="borrowed">借出</a-select-option>
                  <a-select-option value="missing">缺失</a-select-option>
                  <a-select-option value="destroyed">销毁</a-select-option>
                </a-select>
              </a-form-item>
              <a-form-item label="密级">
                <a-select v-model:value="searchForm.securityLevel" placeholder="请选择" style="width: 100px" allow-clear>
                  <a-select-option value="绝密">绝密</a-select-option>
                  <a-select-option value="机密">机密</a-select-option>
                  <a-select-option value="秘密">秘密</a-select-option>
                  <a-select-option value="公开">公开</a-select-option>
                </a-select>
              </a-form-item>
              <a-form-item label="存放位置">
                <a-input v-model:value="searchForm.location" placeholder="库房/密集架号" allow-clear />
              </a-form-item>
              <a-form-item>
                <a-button type="primary" @click="handleSearch">
                  <template #icon><SearchOutlined /></template>
                  查询
                </a-button>
                <a-button style="margin-left: 8px" @click="resetSearch">重置</a-button>
              </a-form-item>
            </a-form>
          </a-card>

          <a-card :bordered="false" class="table-card" style="margin-top: 16px">
            <template #extra>
              <a-space>
                <a-button type="primary">
                  <template #icon><PlusOutlined /></template>
                  新增档案
                </a-button>
                <a-button>
                  <template #icon><PrinterOutlined /></template>
                  打印标签
                </a-button>
                <a-button>导出Excel</a-button>
              </a-space>
            </template>
            
            <a-table 
              :columns="columns" 
              :data-source="data" 
              :pagination="pagination"
              :row-selection="{ selectedRowKeys: selectedRowKeys, onChange: onSelectChange }"
            >
              <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'securityLevel'">
                   <a-tag color="red" v-if="record.securityLevel === '绝密'">绝密</a-tag>
                   <a-tag color="orange" v-else-if="record.securityLevel === '机密'">机密</a-tag>
                   <a-tag color="blue" v-else-if="record.securityLevel === '秘密'">秘密</a-tag>
                   <a-tag color="green" v-else>公开</a-tag>
                </template>
                <template v-if="column.key === 'status'">
                  <a-badge status="success" text="在库" v-if="record.status === 'in_storage'" />
                  <a-badge status="warning" text="借出" v-else-if="record.status === 'borrowed'" />
                  <a-badge status="error" text="缺失" v-else-if="record.status === 'missing'" />
                  <a-badge status="default" text="销毁" v-else />
                </template>
                <template v-if="column.key === 'action'">
                  <a-space>
                    <a-tooltip title="查看">
                      <a-button type="text" size="small" @click="handleView(record)">
                        <template #icon><EyeOutlined /></template>
                      </a-button>
                    </a-tooltip>
                    <a-tooltip title="编辑">
                      <a-button type="text" size="small" @click="handleEdit(record)">
                        <template #icon><EditOutlined /></template>
                      </a-button>
                    </a-tooltip>
                    <a-tooltip title="打印标签">
                      <a-button type="text" size="small" @click="handlePrint(record)">
                        <template #icon><PrinterOutlined /></template>
                      </a-button>
                    </a-tooltip>
                  </a-space>
                </template>
              </template>
            </a-table>
          </a-card>
        </div>
      </template>
    </SplitLayout>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue';
import { SearchOutlined, PlusOutlined, PrinterOutlined, EyeOutlined, EditOutlined } from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import SplitLayout from '@/components/SplitLayout/index.vue';

const searchForm = reactive({
  keyword: '',
  status: undefined,
  securityLevel: undefined,
  location: ''
});

const treeData = [
  {
    title: '全部档案',
    key: 'all',
    children: [
      {
        title: '文书档案',
        key: 'doc',
        children: [
          { title: '行政类', key: 'doc-admin' },
          { title: '人事类', key: 'doc-hr' },
        ]
      },
      {
        title: '科技档案',
        key: 'tech',
        children: [
          { title: '基建', key: 'tech-infra' },
          { title: '设备', key: 'tech-equipment' },
        ]
      },
      {
        title: '财务档案',
        key: 'finance',
        children: [
          { title: '报表', key: 'finance-report' },
          { title: '凭证', key: 'finance-voucher' },
        ]
      }
    ]
  }
];

const onSelectTree = (_selectedKeys: any, info: any) => {
  message.info(`选择了分类: ${info.node.title}`);
};

const columns = [
  { title: '档案题名', dataIndex: 'title', key: 'title', ellipsis: true },
  { title: '档号', dataIndex: 'archCode', key: 'archCode', width: 140 },
  { title: '来源', dataIndex: 'source', key: 'source', width: 150 },
  { title: '密级', dataIndex: 'securityLevel', key: 'securityLevel', width: 80 },
  { title: '存档年限', dataIndex: 'retentionPeriod', key: 'retentionPeriod', width: 100 },
  { title: '盒号', dataIndex: 'boxCode', key: 'boxCode', width: 80 },
  { title: '存放位置', dataIndex: 'location', key: 'location', width: 200 },
  { title: '状态', dataIndex: 'status', key: 'status', width: 100 },
  { title: '归档日期', dataIndex: 'archDate', key: 'archDate', width: 120 },
  { title: '操作', key: 'action', width: 180, fixed: 'right' }
];

const data = ref([
  { 
    key: '1', 
    title: '2023年人事档案卷宗', 
    archCode: 'RS-2023-001', 
    source: '人力资源部',
    securityLevel: '机密',
    retentionPeriod: '50年',
    boxCode: '001', 
    location: '1号库房-A区-01架-1层', 
    status: 'in_storage', 
    archDate: '2023-12-30' 
  },
  { 
    key: '2', 
    title: '2024年财务凭证一月份', 
    archCode: 'CW-2024-01-001', 
    source: '财务部',
    securityLevel: '秘密',
    retentionPeriod: '30年',
    boxCode: '005', 
    location: '2号库房-B区-03架-2层', 
    status: 'borrowed', 
    archDate: '2024-02-15' 
  },
  { 
    key: '3', 
    title: '基建项目合同书原件', 
    archCode: 'HT-2024-009', 
    source: '基建办',
    securityLevel: '普通',
    retentionPeriod: '永久',
    boxCode: '012', 
    location: '1号库房-A区-05架-3层', 
    status: 'in_storage', 
    archDate: '2024-03-20' 
  },
]);

const pagination = {
  total: 50,
  current: 1,
  pageSize: 10,
  showSizeChanger: true,
  showQuickJumper: true,
};

const selectedRowKeys = ref([]);
const onSelectChange = (keys: any) => {
  selectedRowKeys.value = keys;
};

const handleSearch = () => {
  message.loading('正在查询...', 1);
};

const resetSearch = () => {
  searchForm.keyword = '';
  searchForm.status = undefined;
  searchForm.securityLevel = undefined;
  searchForm.location = '';
};

const handleView = (record: any) => message.info(`查看档案：${record.title}`);
const handleEdit = (record: any) => message.info(`编辑档案：${record.title}`);
const handlePrint = (record: any) => message.success(`打印标签：${record.archCode}`);

</script>

<style scoped>
.paper-archive-container {
  height: 100%;
  padding: 0;
}
.left-tree-container {
  height: 100%;
  padding: 16px;
  overflow-y: auto;
  background-color: #fff;
  border-right: 1px solid #f0f0f0;
}
.right-content-container {
  height: 100%;
  padding: 24px;
  overflow-y: auto;
}
:deep(.ant-card-body) {
  padding: 12px;
}
</style>