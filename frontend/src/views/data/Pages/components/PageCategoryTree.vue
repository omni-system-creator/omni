<template>
  <div class="category-tree-container">
    <div class="tree-header">
      <span class="title">页面分类</span>
      <a-button type="link" size="small" @click="handleAddRoot">
        <template #icon><PlusOutlined /></template>
      </a-button>
    </div>
    
    <div class="tree-content">
      <a-input-search
        v-model:value="searchValue"
        placeholder="搜索分类"
        style="margin-bottom: 8px"
        size="small"
      />
      
      <a-tree
        v-if="treeData && treeData.length > 0"
        :tree-data="treeData"
        :field-names="{ children: 'children', title: 'name', key: 'id' }"
        :default-expand-all="true"
        show-line
        show-icon
        @select="onSelect"
        block-node
      >
        <template #icon="{ expanded, dataRef }">
          <template v-if="dataRef.children && dataRef.children.length > 0">
            <FolderOpenOutlined v-if="expanded" />
            <FolderOutlined v-else />
          </template>
        </template>
        <template #title="{ name, id, dataRef }">
          <div class="tree-node">
            <span class="node-title">{{ name }}</span>
            <span class="node-actions" @click.stop>
              <EditOutlined class="action-icon" @click="handleEdit(dataRef)" />
              <DeleteOutlined class="action-icon" @click="handleDelete(id)" />
              <PlusOutlined class="action-icon" @click="handleAddChild(id)" />
            </span>
          </div>
        </template>
      </a-tree>
      <a-empty v-else description="暂无分类" />
    </div>

    <!-- Category Dialog -->
    <a-modal
      v-model:open="dialogVisible"
      :title="dialogTitle"
      @ok="handleDialogOk"
      :confirmLoading="confirmLoading"
    >
      <a-form :model="formState" layout="vertical">
        <a-form-item label="分类名称" required>
          <a-input v-model:value="formState.name" placeholder="请输入分类名称" />
        </a-form-item>
        <a-form-item label="父级分类">
          <a-tree-select
            v-model:value="formState.parentId"
            :tree-data="treeData"
            :field-names="{ label: 'name', value: 'id', children: 'children' }"
            placeholder="请选择父级分类（留空为根分类）"
            allow-clear
            tree-default-expand-all
            :disabled="false"
          />
        </a-form-item>
        <a-form-item label="排序">
          <a-input-number v-model:value="formState.sortOrder" style="width: 100%" :min="0" />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, reactive } from 'vue';
import { 
  PlusOutlined, 
  EditOutlined, 
  DeleteOutlined,
  FolderOutlined,
  FolderOpenOutlined
} from '@ant-design/icons-vue';
import { message, Modal } from 'ant-design-vue';
import { getPageCategoryTree, createPageCategory, updatePageCategory, deletePageCategory, type PageCategory } from '@/api/page';

const emit = defineEmits(['select']);

const searchValue = ref('');
const treeData = ref<PageCategory[]>([]);

const dialogVisible = ref(false);
const dialogTitle = ref('新建分类');
const confirmLoading = ref(false);
const formState = reactive<any>({
  name: '',
  sortOrder: 0,
  parentId: null,
  id: null
});

// Load Tree Data
const loadData = async () => {
  try {
    const res = await getPageCategoryTree();
    treeData.value = res as any;
  } catch (error) {
    message.error('加载分类失败');
  }
};

const onSelect = (selectedKeys: any[], info: any) => {
  if (selectedKeys.length > 0) {
    emit('select', selectedKeys[0], info.node);
  } else {
    emit('select', null, null);
  }
};

const handleAddRoot = () => {
  formState.id = null;
  formState.name = '';
  formState.sortOrder = 0;
  formState.parentId = null;
  dialogTitle.value = '新建根分类';
  dialogVisible.value = true;
};

const handleAddChild = (parentId: number) => {
  formState.id = null;
  formState.name = '';
  formState.sortOrder = 0;
  formState.parentId = parentId;
  dialogTitle.value = '新建子分类';
  dialogVisible.value = true;
};

const handleEdit = (node: any) => {
  formState.id = node.id;
  formState.name = node.name;
  formState.sortOrder = node.sortOrder || 0;
  formState.parentId = node.parentId;
  dialogTitle.value = '编辑分类';
  dialogVisible.value = true;
};

const handleDelete = (id: number) => {
  Modal.confirm({
    title: '确认删除',
    content: '确定要删除该分类吗？如果包含子分类或页面将无法删除。',
    onOk: async () => {
      try {
        await deletePageCategory(id);
        message.success('删除成功');
        loadData();
      } catch (error) {
        message.error('删除失败');
      }
    }
  });
};

const handleDialogOk = async () => {
  if (!formState.name) {
    message.warning('请输入分类名称');
    return;
  }
  
  confirmLoading.value = true;
  try {
    if (formState.id) {
      await updatePageCategory(formState.id, formState);
    } else {
      await createPageCategory(formState);
    }
    message.success('保存成功');
    dialogVisible.value = false;
    loadData();
  } catch (error) {
    message.error('保存失败');
  } finally {
    confirmLoading.value = false;
  }
};

onMounted(() => {
  loadData();
});
</script>

<style scoped>
.category-tree-container {
  height: 100%;
  display: flex;
  flex-direction: column;
  background: #fff;
  border-right: 1px solid #f0f0f0;
}

.tree-header {
  padding: 10px 16px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid #f0f0f0;
}

.tree-header .title {
  font-weight: 600;
  font-size: 14px;
}

.tree-content {
  flex: 1;
  overflow: auto;
  padding: 10px;
}

.tree-node {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
  padding-right: 4px;
  white-space: nowrap;
}

.node-title {
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

:deep(.ant-tree-node-content-wrapper) {
  display: flex !important;
  align-items: center;
  white-space: nowrap;
  overflow: hidden;
}

:deep(.ant-tree-title) {
  flex: 1;
  overflow: hidden;
}

.tree-node:hover .node-actions {
  display: inline-flex;
}

.node-actions {
  display: none;
  gap: 4px;
}

.action-icon {
  padding: 2px;
  color: #666;
  font-size: 12px;
}

.action-icon:hover {
  color: #1890ff;
}
</style>
