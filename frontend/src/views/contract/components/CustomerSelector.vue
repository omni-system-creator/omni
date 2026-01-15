<template>
  <a-modal
    :visible="visible"
    title="选择客户"
    width="800px"
    @cancel="handleCancel"
    @ok="handleOk"
  >
    <div class="customer-selector">
      <!-- Search Bar -->
      <div class="search-bar">
        <a-input-search
          v-model:value="searchText"
          placeholder="搜索客户名称或联系人"
          style="width: 300px"
          @search="handleSearch"
          enter-button
        />
      </div>

      <!-- Customer List Table -->
      <a-table
        :columns="columns"
        :data-source="customerList"
        :loading="loading"
        :pagination="{ pageSize: 5 }"
        row-key="id"
        :row-selection="{ selectedRowKeys: selectedRowKeys, onChange: onSelectChange, type: 'radio' }"
        size="small"
        :scroll="{ y: 300 }"
      >
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'level'">
            <a-tag :color="getLevelColor(record.level)">{{ record.level }}</a-tag>
          </template>
        </template>
      </a-table>
    </div>
  </a-modal>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue';
import { message } from 'ant-design-vue';
import type { ColumnType } from 'ant-design-vue/es/table';
import { getContractCustomers, type ContractCustomerSelectDto } from '@/api/contract';

const props = defineProps<{
  visible: boolean;
}>();

const emit = defineEmits(['update:visible', 'select']);

const searchText = ref('');
const loading = ref(false);
const customerList = ref<ContractCustomerSelectDto[]>([]);
const selectedRowKeys = ref<string[]>([]);
const selectedRows = ref<ContractCustomerSelectDto[]>([]);

const columns: ColumnType<ContractCustomerSelectDto>[] = [
  {
    title: '客户名称',
    dataIndex: 'name',
    key: 'name',
    width: 200,
    ellipsis: true
  },
  {
    title: '行业',
    dataIndex: 'industry',
    key: 'industry',
    width: 120
  },
  {
    title: '联系人',
    dataIndex: 'contact',
    key: 'contact',
    width: 100
  },
  {
    title: '电话',
    dataIndex: 'phone',
    key: 'phone',
    width: 120
  },
  {
    title: '等级',
    dataIndex: 'level',
    key: 'level',
    width: 80,
    align: 'center'
  }
];

const getLevelColor = (level: string) => {
  switch (level) {
    case 'A': return 'green';
    case 'B': return 'blue';
    case 'C': return 'orange';
    default: return 'default';
  }
};

const fetchCustomers = async () => {
  loading.value = true;
  try {
    const res = await getContractCustomers(searchText.value);
    customerList.value = res || [];
  } catch (error) {
    console.error(error);
    message.error('获取客户列表失败');
  } finally {
    loading.value = false;
  }
};

const handleSearch = () => {
  fetchCustomers();
};

const onSelectChange = (keys: any[], rows: any[]) => {
  selectedRowKeys.value = keys;
  selectedRows.value = rows;
};

const handleOk = () => {
  if (selectedRows.value.length > 0) {
    emit('select', selectedRows.value[0]);
    handleCancel();
  } else {
    message.warning('请选择一个客户');
  }
};

const handleCancel = () => {
  emit('update:visible', false);
};

watch(() => props.visible, (newVal) => {
  if (newVal) {
    fetchCustomers();
    selectedRowKeys.value = [];
    selectedRows.value = [];
    searchText.value = '';
  }
});
</script>

<style scoped>
.search-bar {
  margin-bottom: 16px;
  display: flex;
  justify-content: flex-end;
}
</style>
