<template>
  <div class="finance-subject-list">
    <a-card :bordered="false">
      <a-tabs v-model:activeKey="activeTab" @change="handleTabChange">
        <a-tab-pane key="income" tab="收入/应收科目" />
        <a-tab-pane key="expense" tab="支出/应付科目" />
      </a-tabs>

      <div class="table-operator my-4">
        <a-button type="primary" @click="handleAdd">
          <template #icon><PlusOutlined /></template>
          新增科目
        </a-button>
      </div>

      <a-table
        :columns="columns"
        :data-source="tableData"
        rowKey="id"
        :loading="loading"
        :pagination="false"
      >
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'isSystem'">
             <a-tag v-if="record.isSystem" color="blue">系统预设</a-tag>
             <span v-else>自定义</span>
          </template>
          <template v-if="column.key === 'isActive'">
            <a-badge :status="record.isActive ? 'success' : 'default'" :text="record.isActive ? '启用' : '停用'" />
          </template>
          <template v-if="column.key === 'action'">
            <a-space>
              <a @click="handleEdit(record as FinanceSubject)">编辑</a>
              <a-divider type="vertical" />
              <a-popconfirm
                title="确定要删除此科目吗？"
                @confirm="handleDelete(record.id)"
                :disabled="record.isSystem"
              >
                <a :disabled="record.isSystem" class="text-danger">删除</a>
              </a-popconfirm>
            </a-space>
          </template>
        </template>
      </a-table>
    </a-card>

    <!-- Create/Edit Modal -->
    <DraggableModal
      v-model:visible="modalVisible"
      :title="modalTitle"
      width="600px"
      @ok="handleModalOk"
      :confirmLoading="confirmLoading"
      :footer="true"
    >
      <a-form :model="formState" :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }">
        <a-form-item label="科目编码" required v-if="!formState.id">
          <a-input v-model:value="formState.code" placeholder="请输入唯一编码" />
        </a-form-item>
        <a-form-item label="科目编码" v-else>
          <a-input v-model:value="formState.code" disabled />
        </a-form-item>
        
        <a-form-item label="科目名称" required>
          <a-input v-model:value="formState.name" placeholder="请输入科目名称" />
        </a-form-item>

        <a-form-item label="父级科目">
          <a-tree-select
            v-model:value="formState.parentId"
            style="width: 100%"
            :dropdown-style="{ maxHeight: '400px', overflow: 'auto' }"
            :tree-data="treeData"
            placeholder="请选择父级科目（可选）"
            allow-clear
            tree-default-expand-all
          />
        </a-form-item>

        <a-form-item label="状态">
          <a-switch v-model:checked="formState.isActive" checked-children="启用" un-checked-children="停用" />
        </a-form-item>

        <a-form-item label="备注">
          <a-textarea v-model:value="formState.description" :rows="3" />
        </a-form-item>
      </a-form>
    </DraggableModal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, computed } from 'vue';
import { message } from 'ant-design-vue';
import { PlusOutlined } from '@ant-design/icons-vue';
import type { ColumnType } from 'ant-design-vue/es/table';
import DraggableModal from '@/components/DraggableModal.vue';
import { 
  getSubjects, createSubject, updateSubject, deleteSubject,
  type FinanceSubject, type CreateFinanceSubjectDto, type UpdateFinanceSubjectDto 
} from '@/api/finance';

const loading = ref(false);
const tableData = ref<FinanceSubject[]>([]);
const activeTab = ref('income');

const columns: ColumnType[] = [
  { title: '科目编码', dataIndex: 'code', key: 'code', width: 150 },
  { title: '科目名称', dataIndex: 'name', key: 'name' },
  { title: '类型', dataIndex: 'isSystem', key: 'isSystem', width: 100 },
  { title: '状态', dataIndex: 'isActive', key: 'isActive', width: 100 },
  { title: '备注', dataIndex: 'description', key: 'description' },
  { title: '操作', key: 'action', width: 150, align: 'center' }
];

// Tree data for selection (computed from tableData)
const treeData = computed(() => {
  const mapData = (items: FinanceSubject[]): any[] => {
    return items.map(item => ({
      title: item.name,
      value: item.id,
      key: item.id,
      disabled: item.id === formState.id, // Prevent selecting self
      children: item.children ? mapData(item.children as any) : undefined // Type cast if children structure differs
    }));
  };
  return buildTree(tableData.value);
});

const buildTree = (items: FinanceSubject[]) => {
  const result: any[] = [];
  const map = new Map<number, any>();
  
  items.forEach(item => {
    map.set(item.id, { ...item, title: item.name, value: item.id, key: item.id, children: [] });
  });

  items.forEach(item => {
    const node = map.get(item.id);
    if (item.parentId && map.has(item.parentId)) {
      map.get(item.parentId).children.push(node);
    } else {
      result.push(node);
    }
  });
  
  return result;
};

const fetchData = async () => {
  loading.value = true;
  try {
    const res = await getSubjects(activeTab.value);
    tableData.value = buildTree(res);
  } finally {
    loading.value = false;
  }
};

const handleTabChange = () => {
  fetchData();
};

onMounted(() => {
  fetchData();
});

// Modal Logic
const modalVisible = ref(false);
const confirmLoading = ref(false);
const modalTitle = ref('新增科目');
const formState = reactive({
  id: 0,
  code: '',
  name: '',
  parentId: undefined as number | undefined,
  direction: 'income',
  description: '',
  isActive: true,
  isSystem: false
});

const handleAdd = () => {
  modalTitle.value = '新增科目';
  formState.id = 0;
  formState.code = '';
  formState.name = '';
  formState.parentId = undefined;
  // Default direction to current tab
  formState.direction = activeTab.value;
  formState.description = '';
  formState.isActive = true;
  formState.isSystem = false;
  modalVisible.value = true;
};

const handleEdit = (record: FinanceSubject) => {
  modalTitle.value = '编辑科目';
  formState.id = record.id;
  formState.code = record.code;
  formState.name = record.name;
  formState.parentId = record.parentId;
  formState.direction = record.direction;
  formState.description = record.description || '';
  formState.isActive = record.isActive;
  formState.isSystem = record.isSystem;
  modalVisible.value = true;
};

const handleModalOk = async () => {
  if (!formState.name) {
    message.error('请输入科目名称');
    return;
  }
  if (!formState.code && formState.id === 0) {
    message.error('请输入科目编码');
    return;
  }

  confirmLoading.value = true;
  try {
    if (formState.id === 0) {
      // Create
      const dto: CreateFinanceSubjectDto = {
        code: formState.code,
        name: formState.name,
        parentId: formState.parentId,
        direction: formState.direction, // Use state direction (which defaults to tab)
        description: formState.description
      };
      await createSubject(dto);
      message.success('创建成功');
    } else {
      // Update
      const dto: UpdateFinanceSubjectDto = {
        name: formState.name,
        parentId: formState.parentId,
        direction: formState.direction,
        description: formState.description,
        isActive: formState.isActive
      };
      await updateSubject(formState.id, dto);
      message.success('更新成功');
    }
    modalVisible.value = false;
    fetchData();
  } catch (error) {
    // Error handled
  } finally {
    confirmLoading.value = false;
  }
};

const handleDelete = async (id: number) => {
  try {
    await deleteSubject(id);
    message.success('删除成功');
    fetchData();
  } catch (error) {
    // Error handled
  }
};
</script>

<style scoped>
.finance-subject-list {
  padding: 16px;
}
.my-4 {
  margin: 16px 0;
}
.text-danger {
  color: #ff4d4f;
}
</style>
