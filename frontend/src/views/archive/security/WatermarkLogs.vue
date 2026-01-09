<template>
  <div class="watermark-logs-content">
    <a-card :bordered="false">
      <a-form layout="inline" :model="searchForm" style="margin-bottom: 24px">
        <a-form-item label="操作人">
          <a-input v-model:value="searchForm.operator" placeholder="请输入操作人" allow-clear />
        </a-form-item>
        <a-form-item label="文件名">
          <a-input v-model:value="searchForm.fileName" placeholder="请输入文件名" allow-clear />
        </a-form-item>
        <a-form-item label="时间范围">
          <a-range-picker v-model:value="searchForm.dateRange as any" />
        </a-form-item>
        <a-form-item>
          <a-button type="primary" @click="handleSearch">查询</a-button>
          <a-button style="margin-left: 8px" @click="resetSearch">重置</a-button>
        </a-form-item>
      </a-form>
      
      <a-table :columns="columns" :data-source="data" :pagination="pagination">
        <template #bodyCell="{ column, record }">
           <template v-if="column.key === 'type'">
             <a-tag color="blue" v-if="record.type === 'view'">预览</a-tag>
             <a-tag color="green" v-else-if="record.type === 'download'">下载</a-tag>
             <a-tag color="orange" v-else>打印</a-tag>
           </template>
        </template>
      </a-table>
    </a-card>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref } from 'vue';
import { message } from 'ant-design-vue';

const searchForm = reactive({
  operator: '',
  fileName: '',
  dateRange: []
});

const columns = [
  { title: '操作时间', dataIndex: 'time', key: 'time', width: 180 },
  { title: '操作人', dataIndex: 'operator', key: 'operator', width: 120 },
  { title: '操作类型', dataIndex: 'type', key: 'type', width: 100 },
  { title: '文件名称', dataIndex: 'fileName', key: 'fileName' },
  { title: '文件密级', dataIndex: 'securityLevel', key: 'securityLevel', width: 100 },
  { title: '水印内容', dataIndex: 'watermarkContent', key: 'watermarkContent' },
  { title: '客户端IP', dataIndex: 'ip', key: 'ip', width: 140 }
];

const data = ref([
  { 
    key: '1', 
    time: '2024-12-22 10:30:25', 
    operator: '张三', 
    type: 'view', 
    fileName: '2024年度财务报表.pdf', 
    securityLevel: '机密',
    watermarkContent: '张三 2024-12-22',
    ip: '192.168.1.105'
  },
  { 
    key: '2', 
    time: '2024-12-22 11:15:00', 
    operator: '李四', 
    type: 'download', 
    fileName: '项目设计图纸.dwg', 
    securityLevel: '秘密',
    watermarkContent: '李四 2024-12-22',
    ip: '192.168.1.108'
  },
  { 
    key: '3', 
    time: '2024-12-21 15:45:12', 
    operator: '王五', 
    type: 'print', 
    fileName: '员工手册.pdf', 
    securityLevel: '公开',
    watermarkContent: '王五 2024-12-21',
    ip: '192.168.1.110'
  }
]);

const pagination = {
  total: 100,
  current: 1,
  pageSize: 10,
  showSizeChanger: true
};

const handleSearch = () => {
  message.loading('查询中...');
};

const resetSearch = () => {
  searchForm.operator = '';
  searchForm.fileName = '';
  searchForm.dateRange = [];
};
</script>

<style scoped>
.watermark-logs-content {
  padding: 0;
}
</style>
