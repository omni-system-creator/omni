<template>
  <div class="category-tree-container">
    <div class="tree-header">
      <span class="title">接口分类</span>
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
        <a-form-item label="父级分类">
          <a-tree-select
            v-model:value="formState.parentId"
            :tree-data="treeData"
            :field-names="{ children: 'children', label: 'name', value: 'id' }"
            placeholder="请选择父级分类（留空为根分类）"
            tree-default-expand-all
            allow-clear
            style="width: 100%"
          />
        </a-form-item>
        <a-form-item label="分类名称" required>
          <a-input v-model:value="formState.name" placeholder="请输入分类名称" />
        </a-form-item>
        <a-form-item label="URL前缀" required>
          <a-input v-model:value="formState.urlPrefix" placeholder="必须以/开头，例如 /system" />
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
import { interfaceApi, type InterfaceCategory } from '@/api/interface';

const emit = defineEmits(['select']);

const searchValue = ref('');
const treeData = ref<InterfaceCategory[]>([]);
const selectedKeys = ref<number[]>([]);

const dialogVisible = ref(false);
const dialogTitle = ref('新建分类');
const confirmLoading = ref(false);
const formState = reactive<{
  id?: number;
  name: string;
  urlPrefix: string;
  sortOrder: number;
  parentId?: number;
}>({
  name: '',
  urlPrefix: '/',
  sortOrder: 0,
  parentId: undefined
});

// Load Tree Data
const loadData = async () => {
  try {
    const res = await interfaceApi.getCategoryTree();
    const data = (res as any).data || res;
    
    if (Array.isArray(data)) {
        treeData.value = data;
    } else if (data && Array.isArray(data.children)) {
         treeData.value = [data];
    } else {
        treeData.value = [];
    }
    
  } catch (error) {
    console.error('Failed to load categories:', error);
    message.error('加载分类失败');
  }
};

const onSelect = (keys: number[], info: any) => {
  selectedKeys.value = keys;
  if (keys.length > 0) {
    emit('select', info.node.dataRef);
  } else {
    emit('select', null);
  }
};

// Dialog Actions
const handleAddRoot = () => {
  formState.id = undefined;
  formState.name = '';
  formState.urlPrefix = '/';
  formState.sortOrder = 0;
  formState.parentId = undefined;
  dialogTitle.value = '新建根分类';
  dialogVisible.value = true;
};

const handleAddChild = (parentId: number) => {
  formState.id = undefined;
  formState.name = '';
  formState.urlPrefix = '/';
  formState.sortOrder = 0;
  formState.parentId = parentId;
  dialogTitle.value = '新建子分类';
  dialogVisible.value = true;
};

const handleEdit = (category: any) => {
  formState.id = category.id;
  formState.name = category.name;
  formState.urlPrefix = category.urlPrefix || '/';
  formState.sortOrder = category.sortOrder || 0;
  formState.parentId = category.parentId;
  dialogTitle.value = '编辑分类';
  dialogVisible.value = true;
};

const handleDelete = (id: number) => {
  Modal.confirm({
    title: '确认删除',
    content: '确定要删除该分类及其子分类吗？',
    onOk: async () => {
      try {
        await interfaceApi.deleteCategory(id);
        message.success('删除成功');
        loadData();
      } catch (e) {
        // error handled by request interceptor usually, or specific catch
        message.error('删除失败，请确保该分类下没有子分类或接口');
      }
    }
  });
};

const handleDialogOk = async () => {
  if (!formState.name) {
    message.warning('请输入分类名称');
    return;
  }
  if (!formState.urlPrefix || !formState.urlPrefix.startsWith('/')) {
    message.warning('URL前缀必须以/开头');
    return;
  }
  
  // Prevent circular dependency: cannot set parent to itself or its children
  if (formState.id && formState.parentId === formState.id) {
      message.warning('不能将分类的父级设置为自己');
      return;
  }
  
  confirmLoading.value = true;
  try {
    if (formState.id) {
      await interfaceApi.updateCategory(formState.id, {
        name: formState.name,
        urlPrefix: formState.urlPrefix,
        parentId: formState.parentId,
        sortOrder: formState.sortOrder
      });
    } else {
      await interfaceApi.createCategory({
        name: formState.name,
        urlPrefix: formState.urlPrefix,
        parentId: formState.parentId,
        sortOrder: formState.sortOrder
      });
    }
    message.success('保存成功');
    dialogVisible.value = false;
    loadData();
  } catch (e) {
    console.error(e);
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
  padding: 16px;
  background: #fff;
  border-right: 1px solid #f0f0f0;
}

.tree-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.title {
  font-weight: 600;
  font-size: 16px;
}

.tree-content {
  flex: 1;
  overflow-y: auto;
}

.tree-node {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex: 1;
  width: 100%; /* Ensure it takes full width in block-node mode */
  min-width: 0;
}

.node-title {
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.node-actions {
  display: none;
  margin-left: 8px;
  flex-shrink: 0;
}

.tree-node:hover .node-actions {
  display: inline-flex;
  align-items: center;
}

.action-icon {
  margin-left: 8px;
  color: #666;
  font-size: 14px;
}

.action-icon:hover {
  color: #1890ff;
}

:deep(.ant-tree-node-content-wrapper) {
  display: flex;
  align-items: center;
  min-height: 36px;
}

:deep(.ant-tree-switcher) {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 36px;
}

:deep(.ant-tree-title) {
  flex: 1;
  overflow: hidden;
  min-width: 0;
}
</style>
