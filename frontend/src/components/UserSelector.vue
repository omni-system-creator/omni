<template>
  <div class="user-selector">
    <div class="selector-display" @click="openDialog">
      <a-input
        readonly
        :value="displayValue"
        :placeholder="placeholder"
        class="pointer-input"
      >
        <template #suffix>
          <SearchOutlined class="selector-icon" />
        </template>
      </a-input>
    </div>

    <a-modal
      v-model:visible="visible"
      width="800px"
      @ok="handleOk"
      @cancel="handleCancel"
      :body-style="{ padding: '0' }"
      :wrap-class-name="wrapClassName"
    >
      <template #title>
        <div style="width: 100%; cursor: move" @mousedown="handleTitleMouseDown">
          {{ title || '选择人员' }}
        </div>
      </template>
      <div class="selector-content">
        <div class="left-panel">
          <div class="panel-header">组织架构</div>
          <div class="panel-body">
            <a-input-search
              v-model:value="searchValue"
              style="margin-bottom: 8px"
              placeholder="搜索部门或人员"
              allow-clear
            />
            <a-tree
              v-if="treeData.length > 0"
              v-model:checkedKeys="checkedKeys"
              v-model:selectedKeys="selectedKeys"
              :tree-data="treeData"
              :load-data="onLoadData"
              :checkable="multiple"
              :checkStrictly="true"
              :selectable="!multiple"
              :height="400"
              @check="onCheck"
              @select="onSelect"
            >
              <template #title="{ title, isLeaf }">
                <span v-if="isLeaf">
                  {{ title }}
                </span>
                <span v-else>
                  {{ title }}
                </span>
              </template>
            </a-tree>
            <div v-else class="loading-tree">
              <a-spin />
            </div>
          </div>
        </div>
        <div class="right-panel">
          <div class="panel-header">
            已选择 ({{ tempSelectedUsers.length }})
            <a v-if="tempSelectedUsers.length > 0" @click="clearSelection" style="float: right">清空</a>
          </div>
          <div class="selected-list">
            <div v-for="user in tempSelectedUsers" :key="user.username" class="selected-item">
              <div class="user-info">
                <div class="user-name">{{ user.name }}</div>
                <div class="user-org" v-if="user.organization !== userStore.currentOrg?.name">{{ user.organization }}</div>
              </div>
              <CloseOutlined class="remove-icon" @click="removeUser(user)" />
            </div>
            <div v-if="tempSelectedUsers.length === 0" class="empty-tip">
              暂无选择
            </div>
          </div>
        </div>
      </div>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import { SearchOutlined, CloseOutlined } from '@ant-design/icons-vue';
import { getDeptTree, type Dept } from '@/api/dept';
import { getUserList } from '@/api/user';
import { useUserStore } from '@/stores/user';
import { useDraggableModal } from '@/hooks/useDraggableModal';

interface UserInfo {
  username: string;
  name: string;
  organization: string;
}

const userStore = useUserStore();

const props = defineProps<{
  value?: string | string[];
  multiple?: boolean;
  placeholder?: string;
  title?: string;
  initialDisplayData?: UserInfo[]; // Pass existing user details to populate display
}>();

const emit = defineEmits(['update:value', 'change']);

const visible = ref(false);
const { wrapClassName, handleTitleMouseDown } = useDraggableModal(visible);

const treeData = ref<any[]>([]);
const cachedDeptTree = ref<Dept[]>([]);
const searchValue = ref('');

// Internal state for the modal
const tempSelectedUsers = ref<UserInfo[]>([]);
const checkedKeys = ref<string[]>([]); // For checkbox mode (multiple)
const selectedKeys = ref<string[]>([]); // For select mode (single)

// Helper to find dept in cache
const findDept = (depts: Dept[], id: number): Dept | null => {
  for (const dept of depts) {
    if (dept.id === id) return dept;
    if (dept.children) {
      const found = findDept(dept.children, id);
      if (found) return found;
    }
  }
  return null;
};

// Helper to update tree data reactively
const updateTreeData = (list: any[], key: string, children: any[]): boolean => {
  for (let node of list) {
    if (node.key === key) {
      node.children = children;
      return true;
    }
    if (node.children) {
      if (updateTreeData(node.children, key, children)) {
        return true;
      }
    }
  }
  return false;
};

// Load initial tree
const loadTree = async () => {
  if (treeData.value.length > 0) return;
  try {
    const res = await getDeptTree();
    cachedDeptTree.value = res || [];
    treeData.value = (res || []).map(d => ({
      title: d.name,
      value: `dept-${d.id}`,
      key: `dept-${d.id}`,
      isLeaf: false,
      dataRef: d
    }));
  } catch (e) {
    console.error(e);
  }
};

const onLoadData = async (treeNode: any) => {
  const { value } = treeNode;
  if (!value || !value.startsWith('dept-')) return;
  
  const deptId = parseInt(value.split('-')[1]);
  if (isNaN(deptId)) return;

  // Avoid reloading if already loaded
  // We check if the node already has children populated in the tree structure
  // if (treeNode.children && treeNode.children.length > 0) {
  //     return;
  // }

  try {
      const users = await getUserList({ deptId });
      
      // We use dataRef to access the original Dept object to find sub-departments
      // Note: treeNode.dataRef refers to the 'dataRef' property we added to the tree data item
      const currentDept = findDept(cachedDeptTree.value, deptId);
      const subDepts = currentDept?.children || [];

      const deptNodes = subDepts.map(d => ({
        title: d.name,
        value: `dept-${d.id}`,
        key: `dept-${d.id}`,
        isLeaf: false,
        selectable: false,
        disableCheckbox: true,
        disabled: true,
        dataRef: d
      }));

      const userNodes = users.map(u => {
          const postNames = u.posts && u.posts.length > 0 ? ` - ${u.posts.map(p => p.postName).join(', ')}` : '';
          return {
              title: `${u.nickname || u.username} (${u.username})${postNames}`,
              value: u.username,
              key: u.username,
              isLeaf: true,
              isUser: true,
              userData: {
                  username: u.username,
                  name: u.nickname || u.username,
                  organization: currentDept?.name || ''
              }
          };
      });

      // Update the tree node's children directly
      const childNodes = [...deptNodes, ...userNodes];
      updateTreeData(treeData.value, treeNode.key, childNodes);
      // Force update treeData to trigger reactivity if needed
      treeData.value = [...treeData.value];
  } catch (e) {
      console.error(e);
  }
};

const openDialog = async () => {
  visible.value = true;
  await loadTree();
  
  // Initialize temp state from props
  tempSelectedUsers.value = [];
  
  // If we have initialDisplayData, use it.
  if (props.initialDisplayData) {
      // Filter based on current value
      const values = Array.isArray(props.value) ? props.value : (props.value ? [props.value] : []);
      tempSelectedUsers.value = props.initialDisplayData.filter(u => values.includes(u.username));
  }
  
  // Sync keys
  const keys = tempSelectedUsers.value.map(u => u.username);
  if (props.multiple) {
      checkedKeys.value = keys;
  } else {
      selectedKeys.value = keys;
  }
};

const handleOk = () => {
  const values = tempSelectedUsers.value.map(u => u.username);
  if (props.multiple) {
    emit('update:value', values);
    emit('change', tempSelectedUsers.value);
  } else {
    emit('update:value', values[0] || '');
    emit('change', tempSelectedUsers.value[0] || null);
  }
  visible.value = false;
};

const handleCancel = () => {
  visible.value = false;
};

// Handle Tree Check (Multiple)
const onCheck = (_checked: any, info: any) => {
    // checked might be { checked: [], halfChecked: [] } if checkStrictly is true
    // We only care about user nodes
    // info.checkedNodes might contain dept nodes if we didn't disable them.
    // But we disabled dept nodes.
    
    // Rebuild tempSelectedUsers based on checked nodes
    // Issue: If a node is checked but not currently loaded in tree (e.g. pre-selected but not expanded),
    // we might lose its details if we just rely on info.checkedNodes.
    // Strategy: Merge existing known users with new ones from info.checkedNodes.
    
    // Actually, AntDV Tree CheckStrictly: true returns keys.
    // info.node is the node that was checked/unchecked.
    
    const node = info.node;
    if (!node.isUser) return; // Should not happen if depts disabled
    
    const userData = node.userData;
    
    if (info.checked) {
        if (!tempSelectedUsers.value.find(u => u.username === userData.username)) {
            tempSelectedUsers.value.push(userData);
        }
    } else {
        tempSelectedUsers.value = tempSelectedUsers.value.filter(u => u.username !== userData.username);
    }
};

// Handle Tree Select (Single)
const onSelect = (_keys: any[], info: any) => {
    if (!props.multiple) {
        if (info.selected && info.node.isUser) {
            tempSelectedUsers.value = [info.node.userData];
        } else {
            // Deselect?
            // If single select, maybe enforce one? Or allow clear.
            if (!info.selected) tempSelectedUsers.value = [];
        }
    }
};

const removeUser = (user: UserInfo) => {
    tempSelectedUsers.value = tempSelectedUsers.value.filter(u => u.username !== user.username);
    // Sync keys
    if (props.multiple) {
        checkedKeys.value = checkedKeys.value.filter(k => k !== user.username);
    } else {
        selectedKeys.value = [];
    }
};

const clearSelection = () => {
    tempSelectedUsers.value = [];
    checkedKeys.value = [];
    selectedKeys.value = [];
};

const displayValue = computed(() => {
    const currentOrgName = userStore.currentOrg?.name;
    
    if (props.multiple) {
        // const users = props.initialDisplayData || [];
        // If we are outside modal, we rely on initialDisplayData or we need to persist the selected objects in parent.
        
        const vals = Array.isArray(props.value) ? props.value : (props.value ? [props.value] : []);
        if (vals.length === 0) return '';
        
        // Find names
        const names = vals.map(v => {
            const u = props.initialDisplayData?.find(d => d.username === v);
            if (!u) return v;
            return (u.organization === currentOrgName) ? u.name : `${u.name} (${u.organization})`;
        });
        return names.join(', ');
    } else {
        const val = props.value as string;
        if (!val) return '';
        const u = props.initialDisplayData?.find(d => d.username === val);
        if (!u) return val;
        return (u.organization === currentOrgName) ? u.name : `${u.name} (${u.organization})`;
    }
});

// Watch for external value changes to sync keys if needed (only if modal is open)
// But mostly we rely on openDialog to sync.

</script>

<style scoped>
.selector-display {
  width: 100%;
}
.pointer-input :deep(.ant-input) {
  cursor: pointer;
}
.selector-content {
  display: flex;
  height: 500px;
  border-top: 1px solid #f0f0f0;
}
.left-panel {
  flex: 1;
  border-right: 1px solid #f0f0f0;
  display: flex;
  flex-direction: column;
}
.right-panel {
  width: 300px;
  display: flex;
  flex-direction: column;
  background-color: #fafafa;
}
.panel-header {
  padding: 12px 16px;
  border-bottom: 1px solid #f0f0f0;
  font-weight: 500;
  background: #fff;
}
.panel-body {
  padding: 12px;
  flex: 1;
  overflow: auto;
}
.selected-list {
  padding: 12px;
  flex: 1;
  overflow: auto;
}
.selected-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px;
  background: #fff;
  border: 1px solid #e8e8e8;
  border-radius: 4px;
  margin-bottom: 8px;
}
.user-info {
  display: flex;
  flex-direction: column;
}
.user-name {
  font-weight: 500;
}
.user-org {
  font-size: 12px;
  color: #999;
}
.remove-icon {
  color: #999;
  cursor: pointer;
  padding: 4px;
}
.remove-icon:hover {
  color: #ff4d4f;
}
.empty-tip {
  color: #999;
  text-align: center;
  margin-top: 20px;
}
.loading-tree {
  text-align: center;
  padding: 20px;
}
</style>
