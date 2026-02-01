<template>
  <DraggableModal
    v-model:visible="visible"
    title="选择客户"
    width="800px"
    @ok="handleOk"
    @cancel="handleCancel"
    :footer="true"
  >
    <div class="search-bar">
      <a-input-search
        v-model:value="searchText"
        placeholder="搜索客户名称/联系人"
        enter-button
        @search="onSearch"
        style="width: 300px"
      />
    </div>

    <a-table
      :columns="columns"
      :data-source="dataSource"
      :loading="loading"
      :pagination="pagination"
      row-key="id"
      :row-selection="{ type: 'radio', selectedRowKeys: selectedRowKeys, onChange: onSelectChange }"
      @change="handleTableChange"
      size="small"
      :scroll="{ y: 400 }"
    >
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'status'">
          <a-tag :color="record.status === 'active' ? 'green' : 'orange'">
            {{ record.status === 'active' ? '合作中' : '潜在' }}
          </a-tag>
        </template>
      </template>
    </a-table>
  </DraggableModal>
</template>

<script setup lang="ts">
import { ref, reactive, watch } from 'vue';
import DraggableModal from '@/components/DraggableModal.vue';
import { getCustomers, type CustomerDto } from '@/api/sales';

const props = defineProps<{
  visible: boolean;
}>();

const emit = defineEmits(['update:visible', 'select']);

const visible = ref(props.visible);
const searchText = ref('');
const loading = ref(false);
const dataSource = ref<CustomerDto[]>([]);
const selectedRowKeys = ref<string[]>([]);
const selectedRows = ref<CustomerDto[]>([]);

const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0,
  showSizeChanger: true,
  showQuickJumper: true,
});

const columns = [
  { title: '客户名称', dataIndex: 'name', key: 'name', width: 200 },
  { title: '联系人', dataIndex: 'contact', key: 'contact', width: 100 },
  { title: '电话', dataIndex: 'phone', key: 'phone', width: 120 },
  { title: '状态', dataIndex: 'status', key: 'status', width: 80 },
  { title: '所属行业', dataIndex: 'industry', key: 'industry', width: 120 },
];

watch(
  () => props.visible,
  (val) => {
    visible.value = val;
    if (val && dataSource.value.length === 0) {
      fetchData();
    }
  }
);

watch(visible, (val) => {
  emit('update:visible', val);
});

const fetchData = async () => {
  loading.value = true;
  try {
    const res = await getCustomers({
      searchText: searchText.value,
      page: pagination.current,
      pageSize: pagination.pageSize,
    });
    dataSource.value = res.items || [];
    pagination.total = res.total || 0;
  } finally {
    loading.value = false;
  }
};

const onSearch = () => {
  pagination.current = 1;
  fetchData();
};

const handleTableChange = (pag: any) => {
  pagination.current = pag.current;
  pagination.pageSize = pag.pageSize;
  fetchData();
};

const onSelectChange = (keys: any[], rows: CustomerDto[]) => {
  selectedRowKeys.value = keys;
  selectedRows.value = rows;
};

const handleOk = () => {
  if (selectedRows.value.length > 0) {
    emit('select', selectedRows.value[0]);
    visible.value = false;
  } else {
    // If nothing selected but user clicked OK, maybe warn?
    // Or just close.
    visible.value = false;
  }
};

const handleCancel = () => {
  visible.value = false;
};
</script>

<style scoped>
.search-bar {
  margin-bottom: 16px;
}
</style>
