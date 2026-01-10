<template>
  <div class="blacklist-manager">
    <a-card :bordered="false">
      <a-tabs v-model:activeKey="activeTab">
        <a-tab-pane key="person" tab="自然人黑名单">
           <div class="table-operations">
             <a-button type="primary" danger>
               <UserDeleteOutlined /> 新增黑名单人员
             </a-button>
             <a-input-search placeholder="搜索姓名/身份证号" style="width: 250px; margin-left: 10px" />
           </div>
           <a-table :columns="personColumns" :data-source="personData" style="margin-top: 15px">
              <template #bodyCell="{ column }">
                 <template v-if="column.key === 'status'">
                    <a-tag color="red">已拉黑</a-tag>
                 </template>
                 <template v-else-if="column.key === 'action'">
                    <a>解除</a>
                 </template>
              </template>
           </a-table>
        </a-tab-pane>
        
        <a-tab-pane key="company" tab="法人组织黑名单">
           <div class="table-operations">
             <a-button type="primary" danger>
               <StopOutlined /> 新增黑名单企业
             </a-button>
             <a-input-search placeholder="搜索企业名称/信用代码" style="width: 250px; margin-left: 10px" />
           </div>
           <a-table :columns="companyColumns" :data-source="companyData" style="margin-top: 15px">
              <template #bodyCell="{ column }">
                 <template v-if="column.key === 'status'">
                    <a-tag color="red">已拉黑</a-tag>
                 </template>
                 <template v-else-if="column.key === 'action'">
                    <a>解除</a>
                 </template>
              </template>
           </a-table>
        </a-tab-pane>
      </a-tabs>
    </a-card>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { UserDeleteOutlined, StopOutlined } from '@ant-design/icons-vue';

const activeTab = ref('person');

const personColumns = [
  { title: '姓名', dataIndex: 'name', key: 'name' },
  { title: '身份证号', dataIndex: 'idCard', key: 'idCard' },
  { title: '列入原因', dataIndex: 'reason', key: 'reason' },
  { title: '列入日期', dataIndex: 'date', key: 'date' },
  { title: '状态', key: 'status' },
  { title: '操作', key: 'action' }
];

const companyColumns = [
  { title: '企业名称', dataIndex: 'name', key: 'name' },
  { title: '统一社会信用代码', dataIndex: 'code', key: 'code' },
  { title: '法定代表人', dataIndex: 'legalPerson', key: 'legalPerson' },
  { title: '列入原因', dataIndex: 'reason', key: 'reason' },
  { title: '状态', key: 'status' },
  { title: '操作', key: 'action' }
];

const personData = ref([
  { id: 1, name: '张三', idCard: '3201**********1234', reason: '行贿受贿', date: '2023-11-11' },
  { id: 2, name: '李四', idCard: '1101**********5678', reason: '严重失信', date: '2023-12-01' },
]);

const companyData = ref([
  { id: 1, name: '某虚假皮包公司', code: '91320000XXXXXXX', legalPerson: '王五', reason: '围标串标' },
]);
</script>

<style scoped>
.table-operations {
  margin-bottom: 10px;
}
</style>
