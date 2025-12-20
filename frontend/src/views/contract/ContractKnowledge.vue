<template>
  <div class="knowledge-container">
    <!-- 左侧目录树 -->
    <div class="sidebar">
      <div class="sidebar-header">
        <a-input-search
          v-model:value="searchValue"
          placeholder="搜索文件夹"
          style="margin-bottom: 8px"
        />
      </div>
      <div class="tree-container">
        <a-tree
          v-if="treeData.length"
          :tree-data="treeData"
          :default-expanded-keys="expandedKeys"
          :selected-keys="selectedKeys"
          @select="onSelect"
          block-node
        >
          <template #title="{ title, key }">
            <span v-if="key === '0-0'">{{ title }}</span>
            <span v-else>{{ title }}</span>
          </template>
          <template #icon>
            <FolderOutlined />
          </template>
        </a-tree>
      </div>
    </div>

    <!-- 右侧内容区 -->
    <div class="main-content">
      <div class="content-header">
        <div class="breadcrumb-area">
          <a-breadcrumb>
            <a-breadcrumb-item>合同知识库</a-breadcrumb-item>
            <a-breadcrumb-item v-for="(item, index) in breadcrumbList" :key="index">
              {{ item }}
            </a-breadcrumb-item>
          </a-breadcrumb>
        </div>
        <div class="action-area">
          <a-input-search
            v-model:value="fileSearchValue"
            placeholder="搜索文档"
            style="width: 250px; margin-right: 16px"
            @search="onFileSearch"
          />
          <a-button type="primary">
            <template #icon><UploadOutlined /></template>
            上传文档
          </a-button>
        </div>
      </div>

      <div class="file-list-container">
        <a-table
          :columns="columns"
          :data-source="fileList"
          :pagination="pagination"
          row-key="id"
        >
          <template #bodyCell="{ column, record }">
            <template v-if="column.key === 'name'">
              <div class="file-name-cell">
                <FilePdfOutlined v-if="record.type === 'pdf'" style="color: #ff4d4f; margin-right: 8px" />
                <FileWordOutlined v-else-if="record.type === 'doc'" style="color: #1890ff; margin-right: 8px" />
                <FileExcelOutlined v-else-if="record.type === 'xls'" style="color: #52c41a; margin-right: 8px" />
                <FileTextOutlined v-else style="color: #faad14; margin-right: 8px" />
                <span>{{ record.name }}</span>
              </div>
            </template>
            <template v-else-if="column.key === 'action'">
              <a-space>
                <a @click="viewFile(record)">预览</a>
                <a @click="downloadFile(record)">下载</a>
                <a-divider type="vertical" />
                <a class="delete-btn" @click="deleteFile(record)">删除</a>
              </a-space>
            </template>
          </template>
        </a-table>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue';
import {
  FolderOutlined,
  FilePdfOutlined,
  FileWordOutlined,
  FileExcelOutlined,
  FileTextOutlined,
  UploadOutlined
} from '@ant-design/icons-vue';
import type { TreeProps } from 'ant-design-vue';

// 侧边栏搜索
const searchValue = ref('');
const expandedKeys = ref<string[]>(['0-0', '0-0-0', '0-0-1']);
const selectedKeys = ref<string[]>(['0-0-0']);
const breadcrumbList = ref<string[]>(['法律法规', '民法典']);

// 树形数据
const treeData: TreeProps['treeData'] = [
  {
    title: '合同知识库',
    key: '0-0',
    children: [
      {
        title: '法律法规',
        key: '0-0-0',
        children: [
          { title: '民法典', key: '0-0-0-0', isLeaf: true },
          { title: '招标投标法', key: '0-0-0-1', isLeaf: true },
          { title: '建筑法', key: '0-0-0-2', isLeaf: true },
        ],
      },
      {
        title: '公司制度',
        key: '0-0-1',
        children: [
          { title: '合同管理制度', key: '0-0-1-0', isLeaf: true },
          { title: '印章使用规范', key: '0-0-1-1', isLeaf: true },
        ],
      },
      {
        title: '合同范本',
        key: '0-0-2',
        children: [
          { title: '采购类', key: '0-0-2-0', isLeaf: true },
          { title: '销售类', key: '0-0-2-1', isLeaf: true },
          { title: '租赁类', key: '0-0-2-2', isLeaf: true },
        ],
      },
      {
        title: '风险案例',
        key: '0-0-3',
        isLeaf: true,
      },
    ],
  },
];

// 文件搜索
const fileSearchValue = ref('');
const onFileSearch = (val: string) => {
  console.log('Search file:', val);
};

// 表格列定义
const columns = [
  {
    title: '文档名称',
    dataIndex: 'name',
    key: 'name',
    width: '40%',
  },
  {
    title: '上传人',
    dataIndex: 'uploader',
    key: 'uploader',
    width: '15%',
  },
  {
    title: '上传时间',
    dataIndex: 'uploadTime',
    key: 'uploadTime',
    width: '20%',
  },
  {
    title: '大小',
    dataIndex: 'size',
    key: 'size',
    width: '10%',
  },
  {
    title: '操作',
    key: 'action',
    width: '15%',
  },
];

// 模拟文件数据
const fileList = ref([
  {
    id: '1',
    name: '中华人民共和国民法典.pdf',
    type: 'pdf',
    uploader: '系统管理员',
    uploadTime: '2023-01-01 10:00:00',
    size: '5.2 MB',
  },
  {
    id: '2',
    name: '合同审查要点指南.docx',
    type: 'doc',
    uploader: '法务部',
    uploadTime: '2023-05-12 14:30:00',
    size: '1.5 MB',
  },
  {
    id: '3',
    name: '2023年度合同台账模板.xlsx',
    type: 'xls',
    uploader: '财务部',
    uploadTime: '2023-06-20 09:15:00',
    size: '45 KB',
  },
  {
    id: '4',
    name: '常见合同风险提示.txt',
    type: 'txt',
    uploader: '风控部',
    uploadTime: '2023-08-05 16:45:00',
    size: '12 KB',
  },
  {
    id: '5',
    name: '建设工程施工合同(示范文本).docx',
    type: 'doc',
    uploader: '工程部',
    uploadTime: '2023-09-10 11:20:00',
    size: '2.8 MB',
  },
]);

const pagination = {
  pageSize: 10,
  showSizeChanger: true,
  showQuickJumper: true,
};

// 树节点选择
const onSelect = (selectedKeys: string[], info: any) => {
  console.log('selected', selectedKeys, info);
  // 更新面包屑
  // 实际项目中应根据 key 查找路径，这里简单模拟
  if (info.node.title) {
    breadcrumbList.value = ['当前目录', info.node.title];
  }
};

const viewFile = (record: any) => {
  console.log('View file:', record.name);
};

const downloadFile = (record: any) => {
  console.log('Download file:', record.name);
};

const deleteFile = (record: any) => {
  console.log('Delete file:', record.name);
};
</script>

<style scoped>
.knowledge-container {
  display: flex;
  flex: 1;
  height: 100%;
  width: 100%;
  background-color: #f0f2f5;
  gap: 16px;
  overflow: hidden; /* 防止整体滚动 */
  padding: 16px;
  box-sizing: border-box;
}

.sidebar {
  width: 280px;
  background: #fff;
  border-radius: 4px;
  display: flex;
  flex-direction: column;
  padding: 16px;
  box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.03);
}

.sidebar-header {
  margin-bottom: 12px;
}

.tree-container {
  flex: 1;
  overflow-y: auto;
}

.main-content {
  flex: 1;
  background: #fff;
  border-radius: 4px;
  display: flex;
  flex-direction: column;
  padding: 24px;
  box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.03);
  overflow: hidden;
}

.content-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  padding-bottom: 16px;
  border-bottom: 1px solid #f0f0f0;
}

.file-list-container {
  flex: 1;
  overflow-y: auto;
}

.file-name-cell {
  display: flex;
  align-items: center;
}

.delete-btn {
  color: #ff4d4f;
}

.delete-btn:hover {
  color: #ff7875;
}

/* 自定义滚动条样式 */
::-webkit-scrollbar {
  width: 6px;
  height: 6px;
}

::-webkit-scrollbar-thumb {
  background: #ccc;
  border-radius: 3px;
}

::-webkit-scrollbar-track {
  background: transparent;
}
</style>