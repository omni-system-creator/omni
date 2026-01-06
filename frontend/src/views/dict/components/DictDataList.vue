<template>
  <div class="dict-data-list">
    <a-card class="full-height-card" :bordered="false" :body-style="{ padding: '16px', display: 'flex', flexDirection: 'column', flex: 1, overflow: 'hidden' }">
      <template #title v-if="selectedType">
        <div class="list-header">
          <span>{{ selectedType.name }} ({{ selectedType.code }})</span>
        </div>
      </template>
      <template #extra v-if="selectedType">
          <a-button type="primary" @click="handleAdd">
            <template #icon><PlusOutlined /></template>
            新增数据
          </a-button>
      </template>

      <div v-if="selectedType" style="flex: 1; overflow: auto;">
        <a-table
          :columns="columns"
          :data-source="dataList"
          :loading="loading"
          row-key="id"
          :pagination="false"
        >
          <template #bodyCell="{ column, record, index }">
            <template v-if="column.key === 'index'">
              {{ index + 1 }}
            </template>
            <template v-else-if="column.key === 'isDefault'">
              <a-tag v-if="record.isDefault" color="green">是</a-tag>
              <span v-else>否</span>
            </template>
            
            <template v-else-if="column.key === 'status'">
              <a-tag :color="record.status === 'normal' ? 'success' : 'error'">
                {{ record.status === 'normal' ? '正常' : '停用' }}
              </a-tag>
            </template>
            
            <template v-else-if="column.key === 'action'">
              <a-space divider type="vertical">
                <a @click="handleEdit(record)">编辑</a>
                <a-popconfirm
                  title="确定要删除该数据吗？"
                  ok-text="删除"
                  cancel-text="取消"
                  ok-type="danger"
                  @confirm="handleDelete(record)"
                >
                  <a class="text-danger">删除</a>
                </a-popconfirm>
              </a-space>
            </template>
          </template>
        </a-table>
      </div>
      <div v-else class="empty-state">
        <a-empty description="请选择左侧字典类型查看数据" />
      </div>
    </a-card>

    <!-- Data Modal -->
    <DraggableModal
      v-model:visible="modalVisible"
      :title="modalTitle"
      @ok="handleSubmit"
      :confirmLoading="modalLoading"
      :resizable="false"
      :maximizable="false"
      :maskClosable="false"
      width="600px"
      :footer="true"
    >
      <a-form :model="formState" layout="vertical">
        <a-row :gutter="16">
            <a-col :span="12">
                <a-form-item label="标签 (Label)" required>
                <a-input v-model:value="formState.label" placeholder="展示名称" />
                </a-form-item>
            </a-col>
            <a-col :span="12">
                 <a-form-item label="键值 (Value)" required>
                <a-input v-model:value="formState.value" placeholder="存储值" />
                </a-form-item>
            </a-col>
        </a-row>
       
        <a-row :gutter="16">
            <a-col :span="12">
                <a-form-item label="排序">
                <a-input-number v-model:value="formState.sort" :min="0" style="width: 100%" />
                </a-form-item>
            </a-col>
            <a-col :span="12">
                <a-form-item label="状态">
                <a-radio-group v-model:value="formState.status">
                    <a-radio value="normal">正常</a-radio>
                    <a-radio value="disabled">停用</a-radio>
                </a-radio-group>
                </a-form-item>
            </a-col>
        </a-row>

        <a-form-item label="是否默认">
          <a-switch v-model:checked="formState.isDefault" />
        </a-form-item>
        
        <a-form-item label="备注">
          <a-textarea v-model:value="formState.remark" />
        </a-form-item>
      </a-form>
    </DraggableModal>
  </div>
</template>

<script setup lang="ts">
import { ref, watch, type PropType } from 'vue';
import { PlusOutlined } from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import DraggableModal from '@/components/DraggableModal.vue';
import { 
  getDictData, createDictData, updateDictData, deleteDictData,
  type DictTypeDto, type DictDataDto 
} from '@/api/dict';

const props = defineProps({
  selectedType: {
    type: Object as PropType<DictTypeDto | null>,
    default: null
  }
});

const loading = ref(false);
const dataList = ref<DictDataDto[]>([]);

const modalVisible = ref(false);
const modalLoading = ref(false);
const modalTitle = ref('新增数据');
const formState = ref({
  id: 0,
  dictTypeId: 0,
  label: '',
  value: '',
  sort: 0,
  isDefault: false,
  status: 'normal',
  remark: ''
});

const columns = [
  { title: '#', key: 'index', width: 50, align: 'center' },
  { title: '标签', dataIndex: 'label', key: 'label' },
  { title: '键值', dataIndex: 'value', key: 'value' },
  { title: '备注', dataIndex: 'remark', key: 'remark', ellipsis: true },
  { title: '排序', dataIndex: 'sort', key: 'sort', width: 80 },
  { title: '默认', key: 'isDefault', width: 80 },
  { title: '状态', key: 'status', width: 80 },
  { title: '操作', key: 'action', width: 150, align: 'center' }
];

watch(() => props.selectedType, (newVal) => {
  if (newVal) {
    loadData(newVal.id);
  } else {
    dataList.value = [];
  }
}, { immediate: true });

const loadData = async (typeId: number) => {
  loading.value = true;
  try {
    const res = await getDictData(typeId);
    dataList.value = res || [];
  } catch (error) {
    console.error(error);
  } finally {
    loading.value = false;
  }
};

const handleAdd = () => {
  if (!props.selectedType) return;
  formState.value = {
    id: 0,
    dictTypeId: props.selectedType.id,
    label: '',
    value: '',
    sort: 0,
    isDefault: false,
    status: 'normal',
    remark: ''
  };
  modalTitle.value = '新增数据';
  modalVisible.value = true;
};

const handleEdit = (record: DictDataDto) => {
  formState.value = { ...record, remark: record.remark || '' };
  modalTitle.value = '编辑数据';
  modalVisible.value = true;
};

const handleDelete = async (record: DictDataDto) => {
  try {
    await deleteDictData(record.id);
    message.success('删除成功');
    if (props.selectedType) {
      loadData(props.selectedType.id);
    }
  } catch (error) {
    // handled
  }
};

const handleSubmit = async () => {
  if (!formState.value.label || !formState.value.value) {
    message.warning('请填写标签和键值');
    return;
  }
  
  modalLoading.value = true;
  try {
    if (formState.value.id) {
      await updateDictData(formState.value.id, formState.value);
      message.success('更新成功');
    } else {
      await createDictData(formState.value);
      message.success('创建成功');
    }
    modalVisible.value = false;
    if (props.selectedType) {
      loadData(props.selectedType.id);
    }
  } catch (error) {
    console.error(error);
  } finally {
    modalLoading.value = false;
  }
};
</script>

<style scoped>
.dict-data-list {
  height: 100%;
}
:deep(.full-height-card) {
  height: 100%;
  display: flex;
  flex-direction: column;
}
.empty-state {
  height: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
}
.text-danger {
  color: #ff4d4f;
}
</style>
