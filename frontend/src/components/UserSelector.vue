<template>
  <div class="user-selector">
    <div class="selector-display" @click="openDialog" v-if="showTrigger">
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
          :loading="searching"
          @search="onSearch"
        />
        <div v-if="searching" class="loading-tree">
          <a-spin />
        </div>
        <a-tree
          v-else-if="treeData.length > 0"
          v-model:checkedKeys="checkedKeys"
          v-model:selectedKeys="selectedKeys"
          v-model:expandedKeys="expandedKeys"
          :class="{ 'search-mode': isSearchResult }"
          :tree-data="treeData"
          :load-data="onLoadData"
          :checkable="multiple"
          :checkStrictly="false"
          :selectable="!multiple"
          :height="400"
          @check="onCheck"
          @select="onSelect"
        >
          <template #title="{ title, isLeaf, organization, dataRef, dataType }">
            <span v-if="isLeaf" class="tree-node-content">
              <UserOutlined style="color: #1890ff; margin: 0 6px" />
              <div class="tree-node-text">
                <span class="tree-node-title">
                  {{ title }}
                </span>
                <div v-if="organization || (dataRef && dataRef.organization)" class="tree-node-subtitle">
                  {{ organization || dataRef?.organization }}
                </div>
              </div>
            </span>
            <span v-else class="tree-node-title">
               <span v-if="dataType == 1">
                 <BankOutlined style="color: #faad14; margin: 0 6px" />
               </span>
               <span v-else-if="dataType == 2">
                 <ApartmentOutlined style="color: #1890ff; margin: 0 6px" />
               </span>
               <span v-else-if="dataType === 'global'">
                <GlobalOutlined style="color: #722ed1; margin: 0 6px" />
               </span>
               <span v-else>
                 <ClusterOutlined style="color: #8c8c8c; margin: 0 6px" />
               </span>
               {{ title }}
             </span>
          </template>
        </a-tree>
        <div v-else class="empty-tip">
          暂无数据
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
import { ref, computed, watch } from 'vue';
import { 
  SearchOutlined, 
  CloseOutlined,
  BankOutlined,
  ApartmentOutlined,
  ClusterOutlined,
  UserOutlined,
  GlobalOutlined
} from '@ant-design/icons-vue';
import { getDeptTree, type Dept } from '@/api/dept';
import { getUserList } from '@/api/user';
import { useUserStore } from '@/stores/user';
import { useDraggableModal } from '@/hooks/useDraggableModal';

const GLOBAL_DEPT_ID = -1;

interface UserInfo {
  id?: number;
  username: string;
  name: string;
  organization: string;
  deptId?: number;
}

const userStore = useUserStore();

const props = withDefaults(defineProps<{
  value?: string | string[];
  multiple?: boolean;
  placeholder?: string;
  title?: string;
  initialDisplayData?: UserInfo[]; // Pass existing user details to populate display
  showTrigger?: boolean;
}>(), {
  showTrigger: true
});

const emit = defineEmits(['update:value', 'change']);

const visible = ref(false);
const { wrapClassName, handleTitleMouseDown } = useDraggableModal(visible);

const open = () => {
  openDialog();
};

defineExpose({
  open
});

const treeData = ref<any[]>([]);
const cachedDeptTree = ref<Dept[]>([]);
const searchValue = ref('');
const searching = ref(false);
const isSearchResult = ref(false);

// Internal state for the modal
const tempSelectedUsers = ref<UserInfo[]>([]);
const checkedKeys = ref<string[]>([]); // For checkbox mode (multiple)
const selectedKeys = ref<string[]>([]); // For select mode (single)

const expandedKeys = ref<string[]>([]);
const pendingDeptActions = ref<Record<string, boolean>>({});

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

// Helper to find path to dept
const findDeptPathIds = (depts: Dept[], targetId: number, path: number[] = []): number[] | null => {
    for (const dept of depts) {
        const currentPath = [...path, dept.id];
        if (dept.id === targetId) {
            return currentPath;
        }
        if (dept.children) {
            const result = findDeptPathIds(dept.children, targetId, currentPath);
            if (result) return result;
        }
    }
    return null;
};

// Helper to get full dept path
const getDeptFullPath = (depts: Dept[], id: number): string | null => {
  for (const dept of depts) {
    if (dept.id === id) {
      return dept.name;
    }
    if (dept.children) {
      const childPath = getDeptFullPath(dept.children, id);
      if (childPath) {
        return `${dept.name}-${childPath}`;
      }
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
  if (treeData.value.length > 0 && !searchValue.value) return;
  
  isSearchResult.value = false;
  searching.value = true;
  try {
      let res = cachedDeptTree.value;
      if (res.length === 0) {
          try {
            res = await getDeptTree();
            cachedDeptTree.value = res || [];
          } catch (e) {
            console.error(e);
            return;
          }
      }

      treeData.value = (res || []).map(d => ({
        title: d.name,
        value: `dept-${d.id}`,
        key: `dept-${d.id}`,
        isLeaf: false,
        selectable: false,
        dataType: d.type,
        dataRef: d
      }));

      // Add Global Node for Admins
      if (userStore.isAdmin) {
          treeData.value = [{
              title: '全局用户',
              value: `dept-${GLOBAL_DEPT_ID}`,
              key: `dept-${GLOBAL_DEPT_ID}`,
              isLeaf: false,
              selectable: false,
              dataType: 'global',
              children: []
          }, ...treeData.value];
      }
  } finally {
      searching.value = false;
  }
};

const onSearch = async (val: string) => {
    if (!val) {
        treeData.value = [];
        await loadTree();
        return;
    }

    // Ensure tree is loaded for path lookup
    if (cachedDeptTree.value.length === 0) {
        await loadTree();
    }

    searching.value = true;
    try {
        const users = await getUserList({ keyword: val });
        treeData.value = users.map(u => {
             const postNames = u.posts && u.posts.length > 0 ? ` - ${u.posts.map(p => p.postName).join(', ')}` : '';
             
             const currentOrgName = userStore.currentOrg?.name;
             const currentOrgId = userStore.currentOrg?.id;
             
             let orgDisplayName = u.dept?.name || '';
             if (u.dept?.id) {
                 const fullPath = getDeptFullPath(cachedDeptTree.value, u.dept.id);
                 if (fullPath) orgDisplayName = fullPath;
             }

             let isSame = false;
             if (currentOrgId && u.dept?.id) {
                 isSame = u.dept.id === currentOrgId;
             } else {
                 isSame = u.dept?.name === currentOrgName;
             }

             const showOrg = !isSame && orgDisplayName;
             // const orgSuffix = showOrg ? ` - ${orgDisplayName}` : '';

             return {
                  title: `${u.nickname || u.username} (${u.username})${postNames}`,
                  value: u.username,
                  key: `user-${u.username}-${u.dept?.id || '0'}`, // Ensure unique key for user nodes
                  isLeaf: true,
                  isUser: true,
                  organization: showOrg ? orgDisplayName : '',
                  dataRef: {
                      organization: showOrg ? orgDisplayName : ''
                  },
                  userData: {
                      id: u.id,
                      username: u.username,
                      name: u.nickname || u.username,
                      organization: showOrg ? orgDisplayName : '',
                      deptId: u.dept?.id
                  }
             };
        });
        isSearchResult.value = true;
    } catch (e) {
        console.error(e);
    } finally {
        searching.value = false;
    }
};

watch(searchValue, (val) => {
    if (!val) {
        isSearchResult.value = false;
        treeData.value = [];
        loadTree();
    }
});

const onLoadData = async (treeNode: any) => {
  const { value } = treeNode;
  if (!value || !value.startsWith('dept-')) return;
  
  const deptId = parseInt(value.replace('dept-', ''));
  if (isNaN(deptId)) return;

  // Avoid reloading if already loaded
  // We check if the node already has children populated in the tree structure
  if (treeNode.children && treeNode.children.length > 0) {
      return;
  }

  try {
      let users: any[] = [];
      let subDepts: Dept[] = [];
      let deptPath = '';

      if (deptId === GLOBAL_DEPT_ID) {
          users = await getUserList({ noDept: true });
          deptPath = '全局用户';
      } else {
          users = await getUserList({ deptId });
      
          // We use dataRef to access the original Dept object to find sub-departments
          // Note: treeNode.dataRef refers to the 'dataRef' property we added to the tree data item
          const currentDept = findDept(cachedDeptTree.value, deptId);
          subDepts = currentDept?.children || [];

          // Calculate full path for currentDept
          deptPath = currentDept?.name || '';
          if (currentDept) {
              const fullPath = getDeptFullPath(cachedDeptTree.value, currentDept.id);
              if (fullPath) deptPath = fullPath;
          }
      }

      const deptNodes = subDepts.map(d => ({
        title: d.name,
        value: `dept-${d.id}`,
        key: `dept-${d.id}`,
        isLeaf: false,
        selectable: false,
        type: d.type,
        dataType: d.type,
        dataRef: d
      }));

      const userNodes = users.map((u: any) => {
          const postNames = u.posts && u.posts.length > 0 ? ` - ${u.posts.map((p: any) => p.postName).join(', ')}` : '';
          return {
              title: `${u.nickname || u.username} (${u.username})${postNames}`,
              value: u.username,
              key: `user-${u.username}-${deptId}`,
              isLeaf: true,
              isUser: true,
              userData: {
                  id: u.id,
                  username: u.username,
                  name: u.nickname || u.username,
                  organization: deptPath,
                  deptId: deptId
              }
          };
      });

      // Update the tree node's children directly
      const childNodes = [...deptNodes, ...userNodes];
      updateTreeData(treeData.value, treeNode.key, childNodes);
      // Force update treeData to trigger reactivity if needed
      treeData.value = [...treeData.value];
      
      // Check for pending actions on this node (from onCheck)
      if (treeNode.key in pendingDeptActions.value) {
          const shouldCheck = pendingDeptActions.value[treeNode.key];
          delete pendingDeptActions.value[treeNode.key];
          
          if (shouldCheck) {
              // Select all loaded users
              userNodes.forEach(u => {
                  if (u.userData && !tempSelectedUsers.value.find(existing => existing.username === u.userData.username)) {
                      tempSelectedUsers.value.push(u.userData);
                  }
              });
          } else {
              // Deselect all loaded users
              const usernamesToRemove = userNodes.map(u => u.userData.username);
              tempSelectedUsers.value = tempSelectedUsers.value.filter(u => !usernamesToRemove.includes(u.username));
          }
      }

      // Sync checked keys after loading new nodes
      syncCheckedKeys();
  } catch (e) {
      console.error(e);
  }
};

const getAllKeysFromTree = (tree: any[], usernames: string[]): string[] => {
    let keys: string[] = [];
    for (const node of tree) {
        if (node.isUser && node.userData && usernames.includes(node.userData.username)) {
            keys.push(node.key);
        }
        if (node.children && node.children.length > 0) {
            keys = keys.concat(getAllKeysFromTree(node.children, usernames));
        }
    }
    return keys;
};

const syncCheckedKeys = () => {
    if (!props.multiple) return;
    const usernames = tempSelectedUsers.value.map(u => u.username);
    const keys = getAllKeysFromTree(treeData.value, usernames);
    checkedKeys.value = keys;
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
  
  // Auto expand depts of selected users
  const keysToExpand = new Set<string>();
  
  // Also expand root nodes by default if needed, but AntDV might do it.
  // Let's expand based on selection.
  if (treeData.value.length > 0) {
     // Optional: expand root
     // treeData.value.forEach(node => keysToExpand.add(node.key));
  }

  tempSelectedUsers.value.forEach(u => {
      if (u.deptId === GLOBAL_DEPT_ID) {
          keysToExpand.add(`dept-${GLOBAL_DEPT_ID}`);
      } else if (u.deptId) {
          const pathIds = findDeptPathIds(cachedDeptTree.value, u.deptId);
          if (pathIds) {
              pathIds.forEach(id => keysToExpand.add(`dept-${id}`));
          }
      }
  });
  
  if (keysToExpand.size > 0) {
      expandedKeys.value = Array.from(keysToExpand);
  }

  // Sync keys
  if (props.multiple) {
      syncCheckedKeys();
  } else {
      const keys = tempSelectedUsers.value.map(u => u.username);
      selectedKeys.value = keys;
  }
};

watch(tempSelectedUsers, () => {
    syncCheckedKeys();
}, { deep: true });

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
    const { node, checked } = info;
    
    // Helper to collect all users from a node (recursive)
    // We traverse the node structure to find all user nodes under the checked node
    const collectUsers = (n: any): UserInfo[] => {
        let users: UserInfo[] = [];
        // AntDV node might have dataRef or be the data itself depending on usage.
        // But here we rely on the properties we set in treeData (isUser, userData, children)
        // Note: info.node is the EventDataNode which wraps the data. 
        // We should access dataRef or the properties directly if they are exposed.
        // In AntDV 3/4, custom props are usually spread onto the node.
        
        if (n.isUser && n.userData) {
            users.push(n.userData);
        }
        
        // Check children
        // info.node.children might be the VNode children or data children. 
        // Safer to check dataRef.children if available, or children from the tree data.
        // However, AntDV passes the tree node instance. 
        // Let's try to access children from the node directly as we populated them in treeData.
        
        const children = n.children || (n.dataRef && n.dataRef.children);
        if (children && Array.isArray(children)) {
            children.forEach((child: any) => {
                users = users.concat(collectUsers(child));
            });
        }
        
        return users;
    };

    const affectedUsers = collectUsers(node);
    
    // If it's a dept node, we might need to load its children to select them
    if (!node.isUser) {
        // Record the intent
        pendingDeptActions.value[node.key] = checked;
        
        // Auto expand if not already expanded
        if (!expandedKeys.value.includes(node.key)) {
            expandedKeys.value = [...expandedKeys.value, node.key];
        }
        // If it's already expanded (loaded), the collectUsers logic below handles visible children.
        // But we also kept the logic below for immediate feedback on already loaded nodes.
    }

    if (checked) {
        // Add users if not exists
        affectedUsers.forEach(u => {
            if (!tempSelectedUsers.value.find(existing => existing.username === u.username)) {
                tempSelectedUsers.value.push(u);
            }
        });
    } else {
        // Remove users
        const usernamesToRemove = affectedUsers.map(u => u.username);
        tempSelectedUsers.value = tempSelectedUsers.value.filter(u => !usernamesToRemove.includes(u.username));
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
  overflow: hidden;
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
.tree-node-content {
  display: flex;
  flex-direction: row;
  align-items: center;
  padding: 4px 0;
  width: 100%;
}
.tree-node-text {
  display: flex;
  flex-direction: column;
  justify-content: center;
  flex: 1;
}
.tree-node-title {
  display: flex;
  align-items: center;
  line-height: 1.5;
}
.tree-node-subtitle {
  color: #999;
  font-size: 12px;
  line-height: 1.2;
}
:deep(.ant-tree-treenode) {
  width: 100%;
  display: flex;
  align-items: center;
  padding: 4px 0;
}
:deep(.ant-tree-node-content-wrapper) {
  flex: 1;
  display: flex;
  align-items: center;
  min-height: 32px;
  line-height: 32px;
  height: auto !important;
}
:deep(.ant-tree-title) {
  flex: 1;
  display: flex;
  align-items: center;
}
:deep(.search-mode .ant-tree-indent) {
  display: none;
}
:deep(.search-mode .ant-tree-switcher) {
  display: none;
}
:deep(.ant-tree-switcher),
:deep(.ant-tree-checkbox) {
  margin: 0;
  align-self: center;
}
</style>
