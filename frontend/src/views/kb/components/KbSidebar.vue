<template>
  <div class="kb-sider">
    <div class="sider-header">
      <span class="title">知识库</span>
      <a-tooltip title="新建知识库" v-if="isAdmin">
        <a-button type="primary" size="small" @click="showCreateModal">
          <template #icon><PlusOutlined /></template>
          新建
        </a-button>
      </a-tooltip>
    </div>
    
    <div class="search-box">
      <a-input-search v-model:value="localSearchText" placeholder="搜索知识库..." />
    </div>

    <div class="kb-list">
      <div 
        v-for="(kb, index) in filteredKbs" 
        :key="kb.id"
        class="kb-card"
        :class="{ active: selectedKbId === kb.id }"
        @click="handleSelect(kb)"
      >
        <div class="kb-card-content">
          <div class="kb-card-header">
            <span class="kb-icon">
              <FolderOutlined v-if="kb.type === 'general'" />
              <CodeOutlined v-else-if="kb.type === 'code'" />
              <BookOutlined v-else />
            </span>
            <span class="kb-name" :title="kb.name">{{ kb.name }}</span>
          </div>
          <div class="kb-card-meta">
            <span class="meta-item">{{ kb.fileCount }} 文件</span>
            <span class="meta-divider">|</span>
            <span class="meta-item">{{ kb.wordCount || 0 }} 字数</span>
          </div>
          <div class="kb-card-time">
            更新于 {{ formatTime(kb.updatedAt) }}
          </div>
        </div>

        <a-dropdown :trigger="['contextmenu']" v-if="isAdmin">
          <span class="context-trigger"></span>
          <template #overlay>
            <a-menu>
              <a-menu-item key="rename" @click.stop="showEditModal(kb)">
                <template #icon><EditOutlined /></template>
                重命名
              </a-menu-item>
              <a-menu-item key="up" :disabled="index === 0" @click.stop="handleMoveKb(kb, -1)">
                <template #icon><ArrowUpOutlined /></template>
                上移
              </a-menu-item>
              <a-menu-item key="down" :disabled="index === filteredKbs.length - 1" @click.stop="handleMoveKb(kb, 1)">
                <template #icon><ArrowDownOutlined /></template>
                下移
              </a-menu-item>
              <a-menu-divider />
              <a-menu-item key="delete" danger @click.stop="handleDeleteConfirm(kb.id)">
                <template #icon><DeleteOutlined /></template>
                删除
              </a-menu-item>
            </a-menu>
          </template>
        </a-dropdown>
      </div>
    </div>

    <!-- 新建/编辑知识库 -->
    <a-modal
      v-model:open="isCreateModalVisible"
      :title="modalTitle"
      @ok="handleSaveKb"
      :confirmLoading="confirmLoading"
    >
      <a-form :model="newKbForm" layout="vertical">
        <a-form-item label="名称" required>
          <a-input v-model:value="newKbForm.name" placeholder="请输入知识库名称" />
        </a-form-item>
        <a-form-item label="描述">
          <a-textarea v-model:value="newKbForm.description" placeholder="请输入描述" />
        </a-form-item>
        <a-form-item label="类型">
          <a-select v-model:value="newKbForm.category">
            <a-select-option v-for="type in kbTypeOptions" :key="type.value" :value="type.value">
              {{ type.label }}
            </a-select-option>
          </a-select>
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, reactive, onMounted } from 'vue';
import dayjs from 'dayjs';
import { Modal, message } from 'ant-design-vue';
import { 
  PlusOutlined, 
  FolderOutlined, 
  CodeOutlined, 
  BookOutlined,
  EditOutlined,
  DeleteOutlined,
  ArrowUpOutlined,
  ArrowDownOutlined
} from '@ant-design/icons-vue';
import type { KbInfoDto } from '@/types/kb';
import { getKbs as getKbList, createKb, updateKb, deleteKb } from '@/api/kb';
import { getDictDataByCode } from '@/api/dict';
import type { DictDataDto } from '@/api/dict';
import { usePermissionStore } from '@/stores/permission';

const props = defineProps<{ selectedKey?: string | null }>();

const emit = defineEmits<{ (e: 'update:selectedKey', key: string): void; (e: 'select', kb: KbInfoDto): void }>();
const permissionStore = usePermissionStore();
const isAdmin = computed(() => permissionStore.hasPermission('KBAdmin'));
const localSearchText = ref('');
const isCreateModalVisible = ref(false);
const confirmLoading = ref(false);
const kbTypeOptions = ref<DictDataDto[]>([]);
const kbs = ref<KbInfoDto[]>([]);
const selectedKbId = ref<string | null>(null);

const modalType = ref<'create' | 'edit'>('create');
const editingKbId = ref<string | null>(null);
const modalTitle = computed(() => modalType.value === 'create' ? '新建知识库' : '编辑知识库');

const newKbForm = reactive({
  name: '',
  description: '',
  category: 'general',
  type: 'private'
});

const filteredKbs = computed(() => {
  if (!localSearchText.value) return kbs.value;
  return kbs.value.filter(kb => kb.name.toLowerCase().includes(localSearchText.value.toLowerCase()));
});

onMounted(() => {
  fetchKbs();
  fetchDicts();
});

const fetchKbs = async () => {
  try {
    const res = await getKbList();
    kbs.value = res;
    // 如果没有选中项且有数据，默认选中第一个
    if (kbs.value.length > 0) {
       const kbToSelect = selectedKbId.value 
          ? kbs.value.find(k => k.id === selectedKbId.value) 
          : kbs.value[0];
       
       if (kbToSelect) {
         handleSelect(kbToSelect);
       }
    }
  } catch (error) {
    message.error('获取知识库列表失败');
  }
};

const fetchDicts = async () => {
  try {
    const res = await getDictDataByCode('kb_type');
    kbTypeOptions.value = res || [];
  } catch (error) {
    console.error('Failed to fetch kb_type:', error);
  }
};

const showCreateModal = () => {
  modalType.value = 'create';
  editingKbId.value = null;
  newKbForm.name = '';
  newKbForm.description = '';
  newKbForm.category = 'general';
  newKbForm.type = 'private';
  isCreateModalVisible.value = true;
};

const showEditModal = (kb: KbInfoDto) => {
  modalType.value = 'edit';
  editingKbId.value = kb.id;
  newKbForm.name = kb.name;
  newKbForm.description = kb.description || '';
  newKbForm.category = kb.category;
  newKbForm.type = kb.type;
  isCreateModalVisible.value = true;
};

const handleSaveKb = async () => {
  if (!newKbForm.name) {
    message.warning('请输入知识库名称');
    return;
  }
  confirmLoading.value = true;
  try {
    if (modalType.value === 'create') {
      await createKb(newKbForm);
      message.success('创建成功');
    } else {
      if (editingKbId.value) {
        await updateKb(editingKbId.value, { ...newKbForm });
        message.success('更新成功');
      }
    }
    isCreateModalVisible.value = false;
    fetchKbs();
  } catch (error) {
    message.error(modalType.value === 'create' ? '创建失败' : '更新失败');
  } finally {
    confirmLoading.value = false;
  }
};

const handleMoveKb = async (kb: KbInfoDto, direction: number) => {
  if (localSearchText.value) {
     message.warning('请先清空搜索条件再排序');
     return;
  }
  
  const index = kbs.value.findIndex(k => k.id === kb.id);
  if (index === -1) return;
  
  const targetIndex = index + direction;
  if (targetIndex < 0 || targetIndex >= kbs.value.length) return;
  
  const newKbs = [...kbs.value];
  const temp = newKbs[index];
  const target = newKbs[targetIndex];
  
  if (!temp || !target) return;

  newKbs[index] = target;
  newKbs[targetIndex] = temp;
  
  // Optimistic update
  kbs.value = newKbs;
  
  try {
    const updates = newKbs.map((k, i) => {
       if (k.sortOrder !== i) {
          return updateKb(k.id, { sortOrder: i });
       }
       return Promise.resolve();
    });
    
    await Promise.all(updates);
    message.success('排序已更新');
    fetchKbs();
  } catch(e) {
    message.error('排序更新失败');
    fetchKbs();
  }
};

const handleDeleteConfirm = (id: string) => {
  Modal.confirm({
    title: '确认删除',
    content: '删除知识库将清空所有数据，确认继续？',
    onOk: async () => {
      try {
        await deleteKb(id);
        message.success('删除成功');
        fetchKbs();
        if (selectedKbId.value === id) {
           selectedKbId.value = null;
           emit('update:selectedKey', '');
           emit('select', null as any); // Notify parent clear selection
        }
      } catch (error) {
        message.error('删除失败');
      }
    }
  });
};

const handleSelect = (kb: KbInfoDto) => {
  selectedKbId.value = kb.id;
  emit('update:selectedKey', kb.id);
  emit('select', kb);
};

const formatTime = (t?: string) => {
  if (!t) return '-';
  return dayjs(t).format('YYYY-MM-DD HH:mm');
};
</script>

<style scoped>
.kb-sider {
  height: 100%;
  background: #fff;
  border-right: 1px solid #e8e8e8;
  display: flex;
  flex-direction: column;
}

.sider-header {
  padding: 16px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid #f0f0f0;
}

.title {
  font-weight: 600;
  font-size: 16px;
}

.search-box {
  padding: 12px;
}

.kb-list {
  flex: 1;
  overflow-y: auto;
  padding: 12px;
  background-color: #f5f5f5;
}

.kb-card {
  position: relative;
  background: #fff;
  border-radius: 8px;
  padding: 12px;
  margin-bottom: 12px;
  cursor: pointer;
  border: 1px solid #e8e8e8;
  transition: all 0.3s;
}

.kb-card:hover {
  box-shadow: 0 2px 8px rgba(0,0,0,0.09);
  border-color: #1890ff;
}

.kb-card.active {
  border-color: #1890ff;
  background-color: #e6f7ff;
}

.kb-card-header {
  display: flex;
  align-items: center;
  margin-bottom: 8px;
}

.kb-icon {
  margin-right: 8px;
  font-size: 18px;
  color: #1890ff;
  display: flex;
  align-items: center;
}

.kb-name {
  font-weight: 600;
  font-size: 15px;
  color: #333;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.kb-card-meta {
  font-size: 12px;
  color: #666;
  margin-bottom: 6px;
  display: flex;
  align-items: center;
}

.meta-item {
  display: inline-block;
}

.meta-divider {
  margin: 0 8px;
  color: #ddd;
}

.kb-card-time {
  font-size: 12px;
  color: #999;
}

.context-trigger {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 1;
}
</style>