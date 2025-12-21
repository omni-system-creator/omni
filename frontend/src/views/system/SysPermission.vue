<template>
  <div class="sys-permission-container">
    <div class="header-actions">
      <a-button type="primary" @click="handleAdd(null)">
        <template #icon><PlusOutlined /></template>
        新增权限
      </a-button>
      <a-button @click="loadData" :loading="loading" style="margin-left: 8px">
        <template #icon><ReloadOutlined /></template>
        刷新
      </a-button>
      <a-button @click="handleSort" style="margin-left: 8px">
        <template #icon><DragOutlined /></template>
        调整结构/排序
      </a-button>
    </div>

    <a-table
      :columns="columns"
      :data-source="permissions"
      :loading="loading"
      row-key="id"
      :pagination="false"
      defaultExpandAllRows
      size="middle"
      :scroll="{ x: 1200 }"
    >
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'name'">
            <DynamicIcon :icon="record.icon" v-if="record.icon" style="margin-right: 8px"/>
            {{ record.name }}
        </template>
        <template v-else-if="column.key === 'type'">
          <a-tag :color="record.type === 'MENU' ? 'blue' : 'purple'">
            {{ record.type === 'MENU' ? '菜单' : '按钮' }}
          </a-tag>
        </template>
        <template v-else-if="column.key === 'code'">
          <a-typography-text code>{{ record.code }}</a-typography-text>
        </template>
        <template v-else-if="column.key === 'isVisible'">
           <a-badge :status="record.isVisible ? 'success' : 'default'" :text="record.isVisible ? '显示' : '隐藏'" />
        </template>
        <template v-else-if="column.key === 'action'">
          <a-space>
            <a-tooltip title="新增子项" v-if="record.type === 'MENU'">
              <a-button type="link" size="small" @click="handleAdd(record.id)">
                <template #icon><AppstoreAddOutlined /></template>
              </a-button>
            </a-tooltip>
            <a-tooltip title="编辑">
              <a-button type="link" size="small" @click="handleEdit(record)">
                <template #icon><EditOutlined /></template>
              </a-button>
            </a-tooltip>
            <a-tooltip title="删除">
              <a-popconfirm
                title="确定要删除该权限吗？"
                ok-text="删除"
                cancel-text="取消"
                ok-type="danger"
                @confirm="handleDelete(record)"
              >
                <a-button type="link" size="small" danger>
                  <template #icon><DeleteOutlined /></template>
                </a-button>
              </a-popconfirm>
            </a-tooltip>
          </a-space>
        </template>
      </template>
    </a-table>

    <!-- 权限表单弹窗 -->
    <a-modal
      v-model:open="modalVisible"
      :title="modalTitle"
      @ok="handleModalOk"
      :confirmLoading="confirmLoading"
      width="600px"
    >
      <a-form
        ref="formRef"
        :model="formState"
        :rules="rules"
        layout="vertical"
      >
        <a-row :gutter="16">
          <a-col :span="24">
            <a-form-item label="上级权限" name="parentId">
              <a-tree-select
                v-model:value="formState.parentId"
                :tree-data="permissions"
                :field-names="{ children: 'children', label: 'name', value: 'id' }"
                placeholder="请选择上级权限 (留空为顶级)"
                tree-default-expand-all
                allow-clear
              />
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="权限类型" name="type">
              <a-radio-group v-model:value="formState.type">
                <a-radio value="MENU">菜单</a-radio>
                <a-radio value="BUTTON">按钮</a-radio>
              </a-radio-group>
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="显示状态" name="isVisible">
               <a-switch v-model:checked="formState.isVisible" checked-children="显示" un-checked-children="隐藏" />
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="权限名称" name="name">
              <a-input v-model:value="formState.name" placeholder="请输入名称" />
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="权限标识 (Code)" name="code">
              <a-input v-model:value="formState.code" placeholder="如: system:user:add" />
            </a-form-item>
          </a-col>
        </a-row>

        <template v-if="formState.type === 'MENU'">
          <a-row :gutter="16">
            <a-col :span="12">
              <a-form-item label="路由路径 (Path)" name="path">
                <a-input v-model:value="formState.path" placeholder="如: /system/user" />
              </a-form-item>
            </a-col>
            <a-col :span="12">
              <a-form-item label="组件路径" name="component">
                <a-input v-model:value="formState.component" placeholder="如: views/system/SysUser.vue" />
              </a-form-item>
            </a-col>
          </a-row>
          <a-row :gutter="16">
            <a-col :span="12">
              <a-form-item label="图标 (Icon)" name="icon">
                <a-input v-model:value="formState.icon" placeholder="点击右侧按钮选择图标">
                   <template #addonAfter>
                      <SearchOutlined @click="showIconSelector" style="cursor: pointer" />
                   </template>
                   <template #prefix v-if="formState.icon">
                      <DynamicIcon :icon="formState.icon" />
                   </template>
                </a-input>
              </a-form-item>
            </a-col>
            <a-col :span="12">
              <a-form-item label="排序" name="sortOrder">
                <a-input-number v-model:value="formState.sortOrder" style="width: 100%" :min="0" />
              </a-form-item>
            </a-col>
          </a-row>
        </template>
        <!-- 当类型为 BUTTON 时，也允许编辑排序，并且可见性默认为隐藏或不适用，但这里我们统一放开 -->
        <template v-else>
           <a-row :gutter="16">
            <a-col :span="12">
              <a-form-item label="排序" name="sortOrder">
                <a-input-number v-model:value="formState.sortOrder" style="width: 100%" :min="0" />
              </a-form-item>
            </a-col>
           </a-row>
        </template>
      </a-form>
    </a-modal>

    <!-- 排序调整弹窗 -->
    <a-modal
      v-model:open="sortModalVisible"
      title="调整结构/排序"
      @ok="handleSortOk"
      :confirmLoading="sortSaving"
      width="600px"
    >
      <div class="sort-tip">
        <a-alert message="拖拽节点可调整顺序和层级结构" type="info" show-icon />
      </div>
      <div class="tree-container">
        <a-tree
          v-if="sortTreeData.length > 0"
          draggable
          :tree-data="sortTreeData"
          :field-names="{ children: 'children', title: 'name', key: 'id' }"
          defaultExpandAll
          @drop="onDrop"
        >
          <template #title="{ name, type }">
            <span>
              <a-tag v-if="type === 'MENU'" color="blue" style="margin-right: 4px;">菜单</a-tag>
              <a-tag v-else color="purple" style="margin-right: 4px;">按钮</a-tag>
              {{ name }}
            </span>
          </template>
        </a-tree>
      </div>
    </a-modal>
    <!-- 图标选择弹窗 -->
    <a-modal
      v-model:open="iconSelectorVisible"
      title="选择图标"
      :footer="null"
      width="800px"
    >
      <IconSelector v-model="formState.icon" @select="handleIconSelect" />
    </a-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted, reactive } from 'vue';
import { message } from 'ant-design-vue';
import { 
  PlusOutlined, 
  ReloadOutlined, 
  DragOutlined, 
  EditOutlined, 
  DeleteOutlined, 
  AppstoreAddOutlined,
  SearchOutlined
} from '@ant-design/icons-vue';
import { 
  getPermissionList, createPermission, updatePermission, deletePermission, batchUpdateStructure,
  type PermissionTreeDto, type UpdatePermissionStructureDto
} from '@/api/permission';
import DynamicIcon from '@/components/DynamicIcon.vue';
import IconSelector from '@/components/IconSelector.vue';
import type { AntTreeNodeDropEvent } from 'ant-design-vue/es/tree';

const loading = ref(false);
const permissions = ref<PermissionTreeDto[]>([]);

const columns = [
  { title: '权限名称', dataIndex: 'name', key: 'name', width: 250, fixed: 'left' },
  { title: '权限标识', dataIndex: 'code', key: 'code', width: 200 },
  { title: '类型', key: 'type', width: 80, align: 'center' },
  { title: '路由路径', dataIndex: 'path', key: 'path', width: 200 },
  { title: '组件路径', dataIndex: 'component', key: 'component', width: 250 },
  { title: '状态', key: 'isVisible', width: 80, align: 'center' },
  { title: '排序', dataIndex: 'sortOrder', key: 'sortOrder', width: 60, align: 'center' },
  { title: '操作', key: 'action', width: 120, align: 'center', fixed: 'right' },
];

const loadData = async () => {
  loading.value = true;
  try {
    const res = await getPermissionList();
    permissions.value = res;
  } catch (error) {
    console.error(error);
  } finally {
    loading.value = false;
  }
};

// --- Modal Logic ---
const modalVisible = ref(false);
const confirmLoading = ref(false);
const modalTitle = ref('新增权限');
const currentId = ref<number | null>(null);
const formRef = ref();

const formState = reactive({
  name: '',
  code: '',
  type: 'MENU',
  parentId: undefined as number | undefined,
  path: '',
  component: '',
  icon: '',
  sortOrder: 0,
  isVisible: true
});

const rules = {
  name: [{ required: true, message: '请输入权限名称', trigger: 'blur' }],
  code: [{ required: true, message: '请输入权限标识', trigger: 'blur' }],
};

const handleAdd = (parentId: number | null) => {
  currentId.value = null;
  modalTitle.value = '新增权限';
  formState.name = '';
  formState.code = '';
  formState.type = 'MENU';
  formState.parentId = parentId || undefined;
  formState.path = '';
  formState.component = '';
  formState.icon = '';
  formState.sortOrder = 0;
  formState.isVisible = true;
  modalVisible.value = true;
};

const handleEdit = (record: PermissionTreeDto) => {
  currentId.value = record.id;
  modalTitle.value = '编辑权限';
  formState.name = record.name;
  formState.code = record.code;
  formState.type = record.type;
  formState.parentId = record.parentId || undefined;
  formState.path = record.path || '';
  formState.component = record.component || '';
  formState.icon = record.icon || '';
  formState.sortOrder = record.sortOrder;
  formState.isVisible = record.isVisible;
  modalVisible.value = true;
};

const handleModalOk = async () => {
  try {
    await formRef.value.validate();
    confirmLoading.value = true;
    
    const data = {
      name: formState.name,
      code: formState.code,
      type: formState.type,
      parentId: formState.parentId,
      path: formState.path,
      component: formState.component,
      icon: formState.icon,
      sortOrder: formState.sortOrder,
      isVisible: formState.isVisible
    };

    if (currentId.value) {
      await updatePermission(currentId.value, data);
      message.success('更新成功');
    } else {
      await createPermission(data);
      message.success('创建成功');
    }
    
    modalVisible.value = false;
    loadData();
  } catch (error) {
    console.error(error);
  } finally {
    confirmLoading.value = false;
  }
};

const handleDelete = async (record: PermissionTreeDto) => {
  try {
    await deletePermission(record.id);
    message.success('删除成功');
    loadData();
  } catch (error) {
    console.error(error);
  }
};

// --- Sort & Structure Logic ---
const sortModalVisible = ref(false);
const sortSaving = ref(false);
const sortTreeData = ref<PermissionTreeDto[]>([]);

const handleSort = () => {
  // 深拷贝当前权限数据用于拖拽，避免影响表格展示
  sortTreeData.value = JSON.parse(JSON.stringify(permissions.value));
  sortModalVisible.value = true;
};

const onDrop = (info: AntTreeNodeDropEvent) => {
  const dropKey = info.node.key as number;
  const dragKey = info.dragNode.key as number;
  const dropPos = (info.node.pos || '').split('-');
  const dropPosition = info.dropPosition - Number(dropPos[dropPos.length - 1]);

  const loop = (data: PermissionTreeDto[], key: number, callback: any) => {
    data.forEach((item, index) => {
      if (item.id === key) {
        return callback(item, index, data);
      }
      if (item.children) {
        return loop(item.children, key, callback);
      }
    });
  };

  const data = sortTreeData.value;

  // Find dragObject
  let dragObj: PermissionTreeDto | undefined;
  loop(data, dragKey, (item: PermissionTreeDto, index: number, arr: PermissionTreeDto[]) => {
    arr.splice(index, 1);
    dragObj = item;
  });

  if (!dragObj) return;

  if (!info.dropToGap) {
    // Drop on the content (become child)
    loop(data, dropKey, (item: PermissionTreeDto) => {
      item.children = item.children || [];
      item.children.push(dragObj!);
    });
  } else if (
    (info.node.children || []).length > 0 && // Has children
    info.node.expanded && // Is expanded
    dropPosition === 1 // On the bottom gap
  ) {
    loop(data, dropKey, (item: PermissionTreeDto) => {
      item.children = item.children || [];
      item.children.unshift(dragObj!);
    });
  } else {
    // Drop on the gap (insert before or after)
    let ar: PermissionTreeDto[] = [];
    let i = 0;
    loop(data, dropKey, (_item: PermissionTreeDto, index: number, arr: PermissionTreeDto[]) => {
      ar = arr;
      i = index;
    });
    if (dropPosition === -1) {
      ar.splice(i, 0, dragObj);
    } else {
      ar.splice(i + 1, 0, dragObj);
    }
  }
  
  sortTreeData.value = [...data];
};

const handleSortOk = async () => {
  sortSaving.value = true;
  try {
    // 扁平化树结构，并计算新的 ParentId 和 SortOrder
    const updates: UpdatePermissionStructureDto[] = [];
    
    const traverse = (nodes: PermissionTreeDto[], parentId?: number) => {
      nodes.forEach((node, index) => {
        updates.push({
          id: node.id,
          parentId: parentId,
          sortOrder: (index + 1) * 10 // 自动生成间隔为 10 的排序号
        });
        if (node.children && node.children.length > 0) {
          traverse(node.children, node.id);
        }
      });
    };
    
    traverse(sortTreeData.value);
    
    await batchUpdateStructure(updates);
    message.success('结构调整已保存');
    sortModalVisible.value = false;
    loadData(); // 重新加载表格数据
  } catch (error) {
    console.error(error);
  } finally {
    sortSaving.value = false;
  }
};

// --- Icon Selector Logic ---
const iconSelectorVisible = ref(false);

const showIconSelector = () => {
  iconSelectorVisible.value = true;
};

const handleIconSelect = (icon: string) => {
  formState.icon = icon;
  iconSelectorVisible.value = false;
};

onMounted(() => {
  loadData();
});
</script>

<style scoped>
.sys-permission-container {
  padding: 24px;
}
.header-actions {
  margin-bottom: 16px;
  display: flex;
  align-items: center;
}
.text-danger {
  color: #ff4d4f;
}
.sort-tip {
  margin-bottom: 16px;
}
.tree-container {
  max-height: 500px;
  overflow-y: auto;
  border: 1px solid #f0f0f0;
  padding: 12px;
  border-radius: 4px;
}
</style>
