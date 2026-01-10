<template>
  <div class="law-library">
    <a-card :bordered="false" title="法律法规库管理">
      <template #extra>
        <a-button type="primary">
          <PlusOutlined /> 新增法规
        </a-button>
      </template>

      <a-table :columns="columns" :data-source="data" row-key="id">
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'action'">
             <a>查看</a>
             <a-divider type="vertical" />
             <a>编辑</a>
          </template>
          <template v-else-if="column.key === 'tags'">
             <a-tag v-for="tag in record.tags" :key="tag" color="blue">{{ tag }}</a-tag>
          </template>
        </template>
      </a-table>
    </a-card>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { PlusOutlined } from '@ant-design/icons-vue';

const columns = [
  { title: '法规名称', dataIndex: 'title', key: 'title', width: '30%' },
  { title: '发布机构', dataIndex: 'publisher', key: 'publisher' },
  { title: '实施日期', dataIndex: 'date', key: 'date' },
  { title: '适用标签', dataIndex: 'tags', key: 'tags' },
  { title: '操作', key: 'action', width: 120 }
];

const data = ref([
  { id: 1, title: '中华人民共和国招标投标法', publisher: '全国人大常委会', date: '2000-01-01', tags: ['通用', '法律'] },
  { id: 2, title: '中华人民共和国政府采购法', publisher: '全国人大常委会', date: '2003-01-01', tags: ['政府采购', '法律'] },
  { id: 3, title: '电子招标投标办法', publisher: '发改委等八部委', date: '2013-05-01', tags: ['电子招投标', '部门规章'] },
]);
</script>
