<template>
  <div class="dict-type-tree">
    <a-card class="full-height-card" :bordered="false" :body-style="{ padding: '10px', display: 'flex', flexDirection: 'column', flex: 1, overflow: 'hidden' }">
      <template #title>
        <div class="tree-header">
          <span>字典分类</span>
          <a-dropdown trigger="click">
            <a-button type="link" size="small">
              <template #icon><PlusOutlined /></template>
            </a-button>
            <template #overlay>
              <a-menu>
                <a-menu-item key="add-category" @click="handleAddCategory">
                  <FolderAddOutlined /> 新增分类
                </a-menu-item>
                <a-menu-item key="add-type" @click="handleAddType" :disabled="!selectedCategoryId">
                  <FileAddOutlined /> 新增字典
                </a-menu-item>
              </a-menu>
            </template>
          </a-dropdown>
        </div>
      </template>

      <div class="search-box">
        <a-input-search
          v-model:value="searchValue"
          placeholder="搜索分类或字典"
          style="margin-bottom: 8px"
          @change="onSearch"
        />
      </div>

      <div class="tree-container">
        <a-spin :spinning="loading">
          <a-tree
            v-if="treeData.length > 0"
            :tree-data="treeData"
            :expanded-keys="expandedKeys"
            :auto-expand-parent="autoExpandParent"
            :selected-keys="selectedKeys"
            block-node
            @expand="onExpand"
            @select="onSelect"
          >
            <template #title="{ title, key, isLeaf, data, expanded }">
            <div class="tree-node-title">
              <span class="node-content">
                <component 
                  :is="key.toString().startsWith('cat_') ? (expanded ? FolderOpenOutlined : FolderOutlined) : FileTextOutlined" 
                  :style="{ marginRight: '4px', color: key.toString().startsWith('cat_') ? '#faad14' : '#1890ff' }"
                />
                <span v-if="title.toLowerCase().indexOf(searchValue.toLowerCase()) > -1">
                  {{ title.substr(0, title.toLowerCase().indexOf(searchValue.toLowerCase())) }}
                  <span style="color: #f50">{{ searchValue }}</span>
                  {{ title.substr(title.toLowerCase().indexOf(searchValue.toLowerCase()) + searchValue.length) }}
                </span>
                <span v-else>{{ title }}</span>
              </span>
              
              <span class="node-actions" @click.stop>
                  <a-dropdown :trigger="['click']">
                    <MoreOutlined class="action-icon" />
                    <template #overlay>
                      <a-menu>
                        <a-menu-item v-if="!isLeaf" @click="handleEditCategory(data.dataRef.id)">
                          <EditOutlined /> 编辑分类
                        </a-menu-item>
                         <a-menu-item v-if="!isLeaf" @click="handleAddTypeToCategory(data.dataRef.id)">
                          <FileAddOutlined /> 新增字典
                        </a-menu-item>
                        <a-menu-item v-if="!isLeaf" @click="handleDeleteCategory(data.dataRef.id)">
                          <DeleteOutlined /> 删除分类
                        </a-menu-item>

                        <a-menu-item v-if="isLeaf" @click="handleEditType(data.dataRef.id)">
                          <EditOutlined /> 编辑字典
                        </a-menu-item>
                        <a-menu-item v-if="isLeaf" @click="handleDeleteType(data.dataRef.id)">
                          <DeleteOutlined /> 删除字典
                        </a-menu-item>
                      </a-menu>
                    </template>
                  </a-dropdown>
                </span>
              </div>
            </template>
          </a-tree>
          <a-empty v-else description="暂无数据" />
        </a-spin>
      </div>
    </a-card>

    <!-- Category Modal -->
    <DraggableModal
      v-model:visible="categoryModalVisible"
      :title="categoryModalTitle"
      @ok="handleCategorySubmit"
      :confirmLoading="modalLoading"
      :resizable="false"
      :maximizable="false"
      :maskClosable="false"
      width="500px"
      :footer="true"
    >
      <a-form :model="categoryForm" layout="vertical">
        <a-form-item label="分类编码" required>
          <a-input v-model:value="categoryForm.code" :disabled="!!categoryForm.id" />
        </a-form-item>
        <a-form-item label="分类名称" required>
          <a-input v-model:value="categoryForm.name" />
        </a-form-item>
        <a-form-item label="排序">
          <a-input-number v-model:value="categoryForm.sort" :min="0" style="width: 100%" />
        </a-form-item>
        <a-form-item label="备注">
          <a-textarea v-model:value="categoryForm.remark" />
        </a-form-item>
      </a-form>
    </DraggableModal>

    <!-- Type Modal -->
    <DraggableModal
      v-model:visible="typeModalVisible"
      :title="typeModalTitle"
      @ok="handleTypeSubmit"
      :confirmLoading="modalLoading"
      :resizable="false"
      :maximizable="false"
      :maskClosable="false"
      width="500px"
      :footer="true"
    >
      <a-form :model="typeForm" layout="vertical">
        <a-form-item label="所属分类" required>
          <a-select
            v-model:value="typeForm.categoryId"
            :options="categoryOptions"
            :disabled="!!typeForm.id" 
          />
        </a-form-item>
        <a-form-item label="字典编码" required>
          <a-input v-model:value="typeForm.code" :disabled="!!typeForm.id" />
        </a-form-item>
        <a-form-item label="字典名称" required>
          <a-input v-model:value="typeForm.name" />
        </a-form-item>
        <a-form-item label="状态">
          <a-radio-group v-model:value="typeForm.status">
            <a-radio value="normal">正常</a-radio>
            <a-radio value="disabled">停用</a-radio>
          </a-radio-group>
        </a-form-item>
        <a-form-item label="排序">
          <a-input-number v-model:value="typeForm.sort" :min="0" style="width: 100%" />
        </a-form-item>
        <a-form-item label="备注">
          <a-textarea v-model:value="typeForm.remark" />
        </a-form-item>
      </a-form>
    </DraggableModal>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue';
import { 
  PlusOutlined, FolderAddOutlined, FileAddOutlined, 
  MoreOutlined, EditOutlined, DeleteOutlined,
  FolderOutlined, FolderOpenOutlined, FileTextOutlined
} from '@ant-design/icons-vue';
import { message, Modal } from 'ant-design-vue';
import DraggableModal from '@/components/DraggableModal.vue';
import { 
  getDictCategories, getDictTypes, 
  createDictCategory, updateDictCategory, deleteDictCategory,
  createDictType, updateDictType, deleteDictType,
  type DictCategoryDto, type DictTypeDto
} from '@/api/dict';

const emit = defineEmits(['select']);

// State
const loading = ref(false);
const categories = ref<DictCategoryDto[]>([]);
const types = ref<DictTypeDto[]>([]);
const searchValue = ref('');
const expandedKeys = ref<(string | number)[]>([]);
const selectedKeys = ref<(string | number)[]>([]);
const autoExpandParent = ref(true);

// Modals
const modalLoading = ref(false);

// Category Modal
const categoryModalVisible = ref(false);
const categoryModalTitle = ref('新增分类');
const categoryForm = ref({
  id: 0,
  code: '',
  name: '',
  sort: 0,
  remark: ''
});

// Type Modal
const typeModalVisible = ref(false);
const typeModalTitle = ref('新增字典');
const typeForm = ref({
  id: 0,
  categoryId: undefined as number | undefined,
  code: '',
  name: '',
  sort: 0,
  status: 'normal',
  remark: ''
});

// Tree Data Construction
const treeData = computed(() => {
  const data: any[] = [];
  
  categories.value.forEach(cat => {
    const catNode = {
      title: cat.name,
      key: `cat_${cat.id}`,
      isLeaf: false,
      dataRef: { ...cat, type: 'category' },
      isCategory: true,
      children: [] as any[]
    };
    
    const catTypes = types.value.filter(t => t.categoryId === cat.id);
    catTypes.forEach(t => {
      catNode.children.push({
        title: t.name,
        key: `type_${t.id}`,
        isLeaf: true,
        dataRef: { ...t, type: 'type' },
        isCategory: false
      });
    });
    
    data.push(catNode);
  });
  
  return data;
});

const categoryOptions = computed(() => {
  return categories.value.map(c => ({ label: c.name, value: c.id }));
});

const selectedCategoryId = computed(() => {
  if (selectedKeys.value.length === 0) return undefined;
  const key = selectedKeys.value[0] as string;
  if (!key) return undefined;
  if (key.startsWith('cat_')) {
    return parseInt(key.split('_')[1] || '0');
  } else if (key.startsWith('type_')) {
    const typeId = parseInt(key.split('_')[1] || '0');
    const type = types.value.find(t => t.id === typeId);
    return type?.categoryId;
  }
  return undefined;
});

// Methods
const loadData = async () => {
  loading.value = true;
  try {
    const [catsRes, typesRes] = await Promise.all([
      getDictCategories(),
      getDictTypes()
    ]);
    categories.value = catsRes || [];
    types.value = typesRes || [];
    
    // Expand all categories by default if not many
    if (expandedKeys.value.length === 0) {
      expandedKeys.value = categories.value.map(c => `cat_${c.id}`);
    }
  } catch (error) {
    console.error(error);
  } finally {
    loading.value = false;
  }
};

const onExpand = (keys: (string | number)[]) => {
  expandedKeys.value = keys;
  autoExpandParent.value = false;
};

const onSelect = (keys: (string | number)[]) => {
  selectedKeys.value = keys;
  if (keys.length > 0) {
    const key = keys[0] as string;
    if (key.startsWith('type_')) {
      const typeId = parseInt(key.split('_')[1] || '0');
      const type = types.value.find(t => t.id === typeId);
      emit('select', type);
    } else {
      emit('select', null);
    }
  } else {
    emit('select', null);
  }
};

const onSearch = () => {
  // Simple search logic - expansion handled by filter
  // For better search, we might want to filter the treeData itself or just highlight
  // Current implementation just highlights
};

// Category Actions
const handleAddCategory = () => {
  categoryForm.value = { id: 0, code: '', name: '', sort: 0, remark: '' };
  categoryModalTitle.value = '新增分类';
  categoryModalVisible.value = true;
};

const handleEditCategory = (id: number) => {
  console.log('handleEditCategory', id);
  const data = categories.value.find(c => c.id === id);
  console.log('found data', data);
  if (data) {
    categoryForm.value = { ...data, remark: data.remark || '' };
    categoryModalTitle.value = '编辑分类';
    categoryModalVisible.value = true;
    console.log('visible set to true');
  }
};

const handleDeleteCategory = (id: number) => {
  console.log('handleDeleteCategory', id);
  const data = categories.value.find(c => c.id === id);
  if (!data) return;
  
  Modal.confirm({
    title: '确认删除',
    content: `确定要删除分类"${data.name}"吗？这将同时删除该分类下的所有字典类型！`,
    okType: 'danger',
    onOk: async () => {
      try {
        await deleteDictCategory(data.id);
        message.success('删除成功');
        loadData();
      } catch (error) {
        // error handled by request interceptor usually
      }
    }
  });
};

const handleCategorySubmit = async () => {
  if (!categoryForm.value.code || !categoryForm.value.name) {
    message.warning('请填写必填项');
    return;
  }
  
  modalLoading.value = true;
  try {
    if (categoryForm.value.id) {
      await updateDictCategory(categoryForm.value.id, categoryForm.value);
      message.success('更新成功');
    } else {
      await createDictCategory(categoryForm.value);
      message.success('创建成功');
    }
    categoryModalVisible.value = false;
    loadData();
  } catch (error) {
    console.error(error);
  } finally {
    modalLoading.value = false;
  }
};

// Type Actions
const handleAddType = () => {
  const defaultCatId = selectedCategoryId.value || (categories.value.length > 0 ? categories.value[0]?.id : undefined);
  typeForm.value = { 
    id: 0, 
    categoryId: defaultCatId, 
    code: '', 
    name: '', 
    sort: 0, 
    status: 'normal', 
    remark: '' 
  };
  typeModalTitle.value = '新增字典';
  typeModalVisible.value = true;
};

const handleAddTypeToCategory = (catId: number) => {
  typeForm.value = { 
    id: 0, 
    categoryId: catId, 
    code: '', 
    name: '', 
    sort: 0, 
    status: 'normal', 
    remark: '' 
  };
  typeModalTitle.value = '新增字典';
  typeModalVisible.value = true;
}

const handleEditType = (id: number) => {
  const data = types.value.find(t => t.id === id);
  if (data) {
    typeForm.value = { ...data, remark: data.remark || '' };
    typeModalTitle.value = '编辑字典';
    typeModalVisible.value = true;
  }
};

const handleDeleteType = (id: number) => {
  const data = types.value.find(t => t.id === id);
  if (!data) return;

  Modal.confirm({
    title: '确认删除',
    content: `确定要删除字典"${data.name}"吗？这将同时删除该字典下的所有数据！`,
    okType: 'danger',
    onOk: async () => {
      try {
        await deleteDictType(data.id);
        message.success('删除成功');
        loadData();
        // If deleted selected type, emit select null
        const key = `type_${data.id}`;
        if (selectedKeys.value.includes(key)) {
            selectedKeys.value = [];
            emit('select', null);
        }
      } catch (error) {
        // error handled by request interceptor usually
      }
    }
  });
};

const handleTypeSubmit = async () => {
  if (!typeForm.value.categoryId || !typeForm.value.code || !typeForm.value.name) {
    message.warning('请填写必填项');
    return;
  }
  
  modalLoading.value = true;
  try {
    if (typeForm.value.id) {
      await updateDictType(typeForm.value.id, typeForm.value);
      message.success('更新成功');
    } else {
      await createDictType(typeForm.value as any);
      message.success('创建成功');
    }
    typeModalVisible.value = false;
    loadData();
  } catch (error) {
    console.error(error);
  } finally {
    modalLoading.value = false;
  }
};

onMounted(() => {
  loadData();
});
</script>

<style scoped>
.dict-type-tree {
  height: 100%;
}
:deep(.full-height-card) {
  height: 100%;
  display: flex;
  flex-direction: column;
}
.tree-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.tree-container {
  flex: 1;
  overflow: auto;
}
.tree-node-title {
  display: flex;
  justify-content: space-between;
  width: 100%;
  /* Ensure actions are visible on hover */
}
.tree-node-title:hover .node-actions {
  display: inline-block;
}
.node-actions {
  display: none;
  margin-left: 8px;
}
.action-icon {
  color: #1890ff;
  cursor: pointer;
}
</style>
