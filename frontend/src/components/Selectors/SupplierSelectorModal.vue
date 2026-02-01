<template>
  <DraggableModal
    v-model:visible="visible"
    title="选择供应商"
    width="800px"
    @ok="handleOk"
    @cancel="handleCancel"
    :footer="true"
  >
    <div class="search-bar">
      <a-input-search
        v-model:value="searchText"
        placeholder="搜索供应商名称/联系人"
        enter-button
        @search="onSearch"
        style="width: 300px"
      />
    </div>

    <a-table
      :columns="columns"
      :data-source="filteredDataSource"
      :loading="loading"
      :pagination="pagination"
      row-key="id"
      :row-selection="{ type: 'radio', selectedRowKeys: selectedRowKeys, onChange: onSelectChange }"
      size="small"
      :scroll="{ y: 400 }"
    >
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'status'">
          <a-tag :color="record.status === 'active' ? 'green' : 'orange'">
            {{ record.status === 'active' ? '合作中' : '暂停' }}
          </a-tag>
        </template>
      </template>
    </a-table>
  </DraggableModal>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue';
import DraggableModal from '@/components/DraggableModal.vue';

// Mock Interface
interface SupplierDto {
  id: string;
  name: string;
  contact: string;
  phone: string;
  category: string;
  status: string;
}

const props = defineProps<{
  visible: boolean;
}>();

const emit = defineEmits(['update:visible', 'select']);

const visible = ref(props.visible);
const searchText = ref('');
const loading = ref(false);
const selectedRowKeys = ref<any[]>([]);
const selectedRows = ref<SupplierDto[]>([]);

const pagination = {
  pageSize: 10,
};

const columns = [
  { title: '供应商名称', dataIndex: 'name', key: 'name', width: 200 },
  { title: '主营类别', dataIndex: 'category', key: 'category', width: 120 },
  { title: '联系人', dataIndex: 'contact', key: 'contact', width: 100 },
  { title: '电话', dataIndex: 'phone', key: 'phone', width: 120 },
  { title: '状态', dataIndex: 'status', key: 'status', width: 80 },
];

// Mock Data
const mockData: SupplierDto[] = [
  { id: '1', name: 'XX电子元器件有限公司', category: '原材料', contact: '张经理', phone: '13812345678', status: 'active' },
  { id: '2', name: 'YY办公设备有限公司', category: '设备设施', contact: '李主管', phone: '13987654321', status: 'active' },
  { id: '3', name: 'ZZ人力资源服务公司', category: '服务外包', contact: '王专员', phone: '13766668888', status: 'suspended' },
  { id: '4', name: 'ABC钢铁集团', category: '原材料', contact: '刘总', phone: '13666666666', status: 'active' },
  { id: '5', name: 'DEF物流配送中心', category: '物流运输', contact: '陈调度', phone: '13555555555', status: 'active' },
];

const filteredDataSource = computed(() => {
  if (!searchText.value) return mockData;
  const lower = searchText.value.toLowerCase();
  return mockData.filter(item => 
    item.name.toLowerCase().includes(lower) || 
    item.contact.toLowerCase().includes(lower)
  );
});

watch(
  () => props.visible,
  (val) => {
    visible.value = val;
  }
);

watch(visible, (val) => {
  emit('update:visible', val);
});

const onSearch = () => {
  // Client-side filtering handled by computed
};

const onSelectChange = (keys: any[], rows: SupplierDto[]) => {
  selectedRowKeys.value = keys;
  selectedRows.value = rows;
};

const handleOk = () => {
  if (selectedRows.value.length > 0) {
    emit('select', selectedRows.value[0]);
    visible.value = false;
  } else {
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
