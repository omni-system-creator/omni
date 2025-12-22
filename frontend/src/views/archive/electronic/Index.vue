<template>
  <div class="electronic-archive-container">
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
                <a-input v-model:value="searchForm.keyword" placeholder="请输入文件名/档号" allow-clear />
              </a-form-item>
              <a-form-item label="文件类型">
                <a-select v-model:value="searchForm.type" placeholder="请选择" style="width: 120px" allow-clear>
                  <a-select-option value="pdf">PDF</a-select-option>
                  <a-select-option value="doc">Word</a-select-option>
                  <a-select-option value="img">图片</a-select-option>
                  <a-select-option value="video">视频</a-select-option>
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
              <a-form-item label="上传时间">
                <a-range-picker v-model:value="searchForm.dateRange" />
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
                <a-button type="primary" @click="handleAdd">
                  <template #icon><UploadOutlined /></template>
                  上传文件
                </a-button>
                <a-button danger>批量删除</a-button>
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
                <template v-if="column.key === 'type'">
                  <a-tag color="blue" v-if="record.type === 'pdf'">PDF</a-tag>
                  <a-tag color="green" v-else-if="record.type === 'doc'">WORD</a-tag>
                  <a-tag color="orange" v-else-if="record.type === 'img'">IMG</a-tag>
                  <a-tag color="cyan" v-else>{{ record.type.toUpperCase() }}</a-tag>
                </template>
                <template v-if="column.key === 'size'">
                  {{ formatSize(record.size) }}
                </template>
                <template v-if="column.key === 'action'">
                  <a-space>
                    <a-tooltip title="预览">
                      <a-button type="text" size="small" @click="handlePreview(record)">
                        <template #icon><EyeOutlined /></template>
                      </a-button>
                    </a-tooltip>
                    <a-tooltip title="下载">
                      <a-button type="text" size="small" @click="handleDownload(record)">
                        <template #icon><DownloadOutlined /></template>
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
    </SplitLayout>
    <a-modal
      v-model:open="visible"
      title="新增档案"
      @ok="handleOk"
      @cancel="handleCancel"
      width="600px"
    >
      <Save ref="saveRef" />
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue';
import { SearchOutlined, UploadOutlined, EyeOutlined, DownloadOutlined, DeleteOutlined } from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import SplitLayout from '@/components/SplitLayout/index.vue';
import Save from './Save.vue';

const visible = ref(false);
const saveRef = ref();

const handleAdd = () => {
  visible.value = true;
};

const handleOk = () => {
  saveRef.value.formRef.validate().then(() => {
    message.success('提交成功');
    visible.value = false;
    // console.log(saveRef.value.formState);
  }).catch((error: any) => {
    console.log('error', error);
  });
};

const handleCancel = () => {
  visible.value = false;
};

const searchForm = reactive({
  keyword: '',
  type: undefined,
  securityLevel: undefined,
  dateRange: []
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
  { title: '文件名称', dataIndex: 'name', key: 'name' },
  { title: '档号', dataIndex: 'code', key: 'code', width: 150 },
  { title: '来源', dataIndex: 'source', key: 'source', width: 100 },
  { title: '密级', dataIndex: 'securityLevel', key: 'securityLevel', width: 80 },
  { title: '存档年限', dataIndex: 'retentionPeriod', key: 'retentionPeriod', width: 100 },
  { title: '类型', dataIndex: 'type', key: 'type', width: 80 },
  { title: '大小', dataIndex: 'size', key: 'size', width: 100 },
  { title: '上传人', dataIndex: 'uploader', key: 'uploader', width: 100 },
  { title: '上传时间', dataIndex: 'uploadTime', key: 'uploadTime', width: 170 },
  { title: '操作', key: 'action', width: 180, fixed: 'right' }
];

const data = ref([
  { 
    key: '1', 
    name: '2024年度工作总结.pdf', 
    code: 'WS-2024-001', 
    source: '行政部',
    securityLevel: '秘密',
    retentionPeriod: '10年',
    type: 'pdf', 
    size: 1024 * 1024 * 2.5, 
    uploader: '张三', 
    uploadTime: '2024-12-20 10:00:00' 
  },
  { 
    key: '2', 
    name: '项目设计图纸.png', 
    code: 'JS-2024-002', 
    source: '研发部',
    securityLevel: '机密',
    retentionPeriod: '永久',
    type: 'img', 
    size: 1024 * 500, 
    uploader: '李四', 
    uploadTime: '2024-12-21 14:30:00' 
  },
  { 
    key: '3', 
    name: '会议纪要.docx', 
    code: 'WS-2024-003', 
    source: '总经办',
    securityLevel: '公开',
    retentionPeriod: '5年',
    type: 'doc', 
    size: 1024 * 20, 
    uploader: '王五', 
    uploadTime: '2024-12-22 09:15:00' 
  },
]);

const pagination = {
  total: 100,
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
  searchForm.type = undefined;
  searchForm.securityLevel = undefined;
  searchForm.dateRange = [];
};

const formatSize = (bytes: number) => {
  if (bytes === 0) return '0 B';
  const k = 1024;
  const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
};

const handlePreview = (record: any) => message.info(`预览文件：${record.name}`);
const handleDownload = (record: any) => message.success(`开始下载：${record.name}`);
const handleDelete = (record: any) => message.warning(`确认删除：${record.name}？`);

</script>

<style scoped>
.electronic-archive-container {
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
.danger-text {
  color: #ff4d4f;
  cursor: pointer;
}
.danger-text:hover {
  color: #cf1322;
}
:deep(.ant-card-body) {
  padding: 12px;
}
</style>