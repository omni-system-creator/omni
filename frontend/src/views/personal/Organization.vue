<template>
  <div class="organization-container">
    <div class="left-sider">
      <div class="sider-header">
        <a-input-search
          v-model:value="deptSearch"
          placeholder="搜索部门"
          style="margin-bottom: 8px"
        />
      </div>
      <div class="tree-wrapper">
        <a-tree
          v-model:expandedKeys="expandedKeys"
          v-model:selectedKeys="selectedKeys"
          :tree-data="deptTree"
          :field-names="{ title: 'name', key: 'id' }"
          block-node
          @select="handleSelect"
        >
          <template #title="{ name, type }">
            <span v-if="type === DeptType.Group">
               <BankOutlined style="color: #faad14; margin-right: 4px" />
            </span>
            <span v-else-if="type === DeptType.Company">
               <ApartmentOutlined style="color: #1890ff; margin-right: 4px" />
            </span>
            <span v-else>
               <ClusterOutlined style="color: #8c8c8c; margin-right: 4px" />
            </span>
            <span v-if="name.indexOf(deptSearch) > -1">
              {{ name.substr(0, name.indexOf(deptSearch)) }}
              <span style="color: #f50">{{ deptSearch }}</span>
              {{ name.substr(name.indexOf(deptSearch) + deptSearch.length) }}
            </span>
            <span v-else>{{ name }}</span>
          </template>
        </a-tree>
      </div>
    </div>
    <div class="right-content">
      <div class="content-header">
        <div class="header-left">
          <h2>{{ currentDept ? currentDept.name : '全部成员' }}</h2>
          <span class="member-count">共 {{ filteredMembers.length }} 人</span>
        </div>
        <div class="header-right">
          <a-input-search
            v-model:value="memberSearch"
            placeholder="搜索姓名/职位/手机号"
            style="width: 300px"
            enter-button
          />
          <a-radio-group v-model:value="viewMode" style="margin-left: 16px">
            <a-radio-button value="card">
              <template #icon><AppstoreOutlined /></template>
              卡片
            </a-radio-button>
            <a-radio-button value="list">
              <template #icon><BarsOutlined /></template>
              列表
            </a-radio-button>
          </a-radio-group>
        </div>
      </div>
      
      <div class="content-body">
        <a-empty v-if="filteredMembers.length === 0" description="暂无成员" />
        
        <!-- Card View -->
        <div v-else-if="viewMode === 'card'" class="card-grid">
          <a-card v-for="member in filteredMembers" :key="member.id" hoverable class="member-card">
            <div class="member-info">
              <a-avatar :size="64" :src="member.avatar" :style="{ backgroundColor: member.avatar ? 'transparent' : '#1890ff' }">
                {{ getAvatarText(member) }}
              </a-avatar>
              <div class="info-text">
                <div class="name">
                  {{ getDisplayName(member) }}
                  <!-- <a-tag v-if="member.isLeader" color="blue">负责人</a-tag> -->
                  <a-tag :color="member.isActive ? statusMap['online']?.color : statusMap['leave']?.color" style="margin-left: 8px;">
                    {{ member.isActive ? '在岗' : '离职/休假' }}
                  </a-tag>
                </div>
                <div class="position">{{ member.posts?.[0]?.postName || '未分配职位' }}</div>
                <div class="dept" :title="getDeptPath(member.dept?.id)">{{ getDeptPath(member.dept?.id) }}</div>
              </div>
            </div>
            <div class="contact-info">
              <div class="contact-item">
                <MailOutlined /> {{ member.email || '无邮箱' }}
              </div>
              <div class="contact-item">
                <PhoneOutlined /> {{ member.phone || '无电话' }}
              </div>
            </div>
            <template #actions>
              <MessageOutlined key="message" />
              <MailOutlined key="mail" />
              <ProfileOutlined key="profile" />
            </template>
          </a-card>
        </div>

        <!-- List View -->
        <a-table
          v-else
          :columns="columns"
          :data-source="filteredMembers"
          row-key="id"
          :pagination="{ pageSize: 10 }"
        >
          <template #bodyCell="{ column, record }">
            <template v-if="column.key === 'name'">
              <a-space>
                <a-avatar :size="32" :src="record.avatar" :style="{ backgroundColor: record.avatar ? 'transparent' : '#1890ff' }">
                  {{ getAvatarText(record) }}
                </a-avatar>
                {{ getDisplayName(record) }}
                <!-- <a-tag v-if="record.isLeader" color="blue">负责人</a-tag> -->
              </a-space>
            </template>
            <template v-else-if="column.key === 'position'">
               {{ record.posts?.[0]?.postName }}
            </template>
            <template v-else-if="column.key === 'deptName'">
               <span :title="getDeptPath(record.dept?.id)">{{ record.dept?.name }}</span>
            </template>
            <template v-else-if="column.key === 'status'">
              <a-badge :status="record.isActive ? 'success' : 'error'" :text="record.isActive ? '在岗' : '离职/休假'" />
            </template>
            <template v-else-if="column.key === 'action'">
              <a-space>
                <a>查看</a>
                <a>发消息</a>
              </a-space>
            </template>
          </template>
        </a-table>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { ref, computed, onMounted, watch } from 'vue';
import { 
  AppstoreOutlined, 
  BarsOutlined, 
  MailOutlined, 
  PhoneOutlined,
  MessageOutlined,
  ProfileOutlined,
  BankOutlined,
  ApartmentOutlined,
  ClusterOutlined
} from '@ant-design/icons-vue';
import { getDeptTree, type Dept, DeptType } from '@/api/dept';
import { getUserList, type UserListDto } from '@/api/user';
import { useUserStore } from '@/stores/user';

// Data
const deptTree = ref<Dept[]>([]);
const allMembers = ref<UserListDto[]>([]);
const loading = ref(false);
const userStore = useUserStore();
const STORAGE_VIEW_KEY = `oms_org_view_mode_${userStore.username}`;
const STORAGE_EXPAND_KEY = `oms_org_expanded_keys_${userStore.username}`;

const statusMap: Record<string, { text: string; status: string; color: string }> = {
  online: { text: '在岗', status: 'success', color: '#52c41a' },
  business: { text: '出差中', status: 'warning', color: '#faad14' },
  out: { text: '临时外出', status: 'processing', color: '#1890ff' },
  leave: { text: '休假中', status: 'error', color: '#ff4d4f' },
};

// State
const deptSearch = ref('');
const memberSearch = ref('');
const expandedKeys = ref<number[]>([]);
const selectedKeys = ref<number[]>([]);
const currentDept = ref<Dept | null>(null);
const viewMode = ref(localStorage.getItem(STORAGE_VIEW_KEY) || 'card');

watch(viewMode, (newVal) => {
  localStorage.setItem(STORAGE_VIEW_KEY, newVal);
});

watch(expandedKeys, (newVal) => {
  localStorage.setItem(STORAGE_EXPAND_KEY, JSON.stringify(newVal));
}, { deep: true });

// Helper functions
const getDisplayName = (member: UserListDto) => {
  return member.nickname || member.username || '未知用户';
};

const getAvatarText = (member: UserListDto) => {
  const name = member.nickname || member.username;
  return name ? name.charAt(0).toUpperCase() : '?';
};

const getDeptPath = (deptId: number | undefined): string => {
  if (!deptId) return '未分配部门';
  
  const findPath = (nodes: Dept[], targetId: number, currentPath: string[]): string[] | null => {
    for (const node of nodes) {
      if (node.id === targetId) {
        return [...currentPath, node.name];
      }
      if (node.children) {
        const childResult = findPath(node.children, targetId, [...currentPath, node.name]);
        if (childResult) return childResult;
      }
    }
    return null;
  };

  const path = findPath(deptTree.value, deptId, []);
  return path ? path.join(' / ') : '未知部门';
};

// Table Columns
const columns = [
  { title: '姓名', key: 'name', width: 200 },
  { title: '工号', dataIndex: 'id', width: 100 },
  { title: '职位', key: 'position', width: 150 },
  { title: '部门', key: 'deptName', width: 150 },
  { title: '手机', dataIndex: 'phone', width: 150 },
  { title: '邮箱', dataIndex: 'email' },
  { title: '状态', key: 'status', width: 130 },
  { title: '操作', key: 'action', width: 150 }
];

// Methods
const handleSelect = (keys: number[]) => {
  if (keys.length > 0 && keys[0]) {
    const findDept = (nodes: Dept[], key: number): Dept | null => {
      for (const node of nodes) {
        if (node.id === key) return node;
        if (node.children) {
          const found = findDept(node.children, key);
          if (found) return found;
        }
      }
      return null;
    };
    currentDept.value = findDept(deptTree.value, keys[0]);
  } else {
    currentDept.value = null;
  }
};

const getAllDeptIds = (deptId: number): number[] => {
  const ids = [deptId];
  const findChildren = (nodes: Dept[]) => {
    for (const node of nodes) {
      if (node.id === deptId) {
        const collect = (n: Dept) => {
          if (n.children) {
            n.children.forEach((c: Dept) => {
              ids.push(c.id);
              collect(c);
            });
          }
        };
        collect(node);
        return true;
      }
      if (node.children) {
        if (findChildren(node.children)) return true;
      }
    }
    return false;
  };
  findChildren(deptTree.value);
  return ids;
};

// Computed
const filteredMembers = computed(() => {
  let data = allMembers.value;

  // Filter by department
  if (selectedKeys.value.length > 0 && selectedKeys.value[0]) {
    const selectedId = selectedKeys.value[0];
    const targetIds = getAllDeptIds(selectedId);
    // UserListDto has dept: { id, name }
    data = data.filter(m => m.dept && targetIds.includes(m.dept.id));
  }

  // Filter by search text
  if (memberSearch.value) {
    const lowerSearch = memberSearch.value.toLowerCase();
    data = data.filter(m => 
      (m.nickname && m.nickname.toLowerCase().includes(lowerSearch)) || 
      (m.username && m.username.toLowerCase().includes(lowerSearch)) ||
      (m.phone && m.phone.includes(lowerSearch)) ||
      (m.posts && m.posts.some(p => p.postName.toLowerCase().includes(lowerSearch)))
    );
  }

  return data;
});

const fetchData = async () => {
  loading.value = true;
  try {
    const [deptRes, userRes] = await Promise.all([
      getDeptTree(),
      getUserList()
    ]);
    deptTree.value = deptRes || [];
    allMembers.value = userRes || [];
    
    // Restore expanded keys or default to root
    const storedExpandedKeys = localStorage.getItem(STORAGE_EXPAND_KEY);
    if (storedExpandedKeys) {
      try {
        expandedKeys.value = JSON.parse(storedExpandedKeys);
      } catch (e) {
        // Fallback if JSON parse fails
        if (deptTree.value.length > 0) {
          expandedKeys.value = deptTree.value.map(d => d.id);
        }
      }
    } else if (deptTree.value.length > 0) {
      expandedKeys.value = deptTree.value.map(d => d.id);
    }
  } catch (error) {
    console.error('Failed to fetch data:', error);
  } finally {
    loading.value = false;
  }
};

onMounted(() => {
  fetchData();
});

</script>

<style scoped>
.organization-container {
  display: flex;
  height: 100%;
  background-color: #f0f2f5;
  gap: 16px;
  padding: 16px;
}

.left-sider {
  width: 280px;
  background: #fff;
  border-radius: 4px;
  display: flex;
  flex-direction: column;
  padding: 16px;
  flex-shrink: 0;
}

.tree-wrapper {
  flex: 1;
  overflow-y: auto;
  margin-top: 8px;
}

.right-content {
  flex: 1;
  background: #fff;
  border-radius: 4px;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.content-header {
  padding: 16px 24px;
  border-bottom: 1px solid #f0f0f0;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-left {
  display: flex;
  align-items: baseline;
  gap: 12px;
}

.header-left h2 {
  margin: 0;
  font-size: 20px;
  font-weight: 500;
}

.member-count {
  color: #999;
}

.header-right {
  display: flex;
  align-items: center;
}

.content-body {
  flex: 1;
  padding: 24px;
  overflow-y: auto;
}

.card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 16px;
}

.member-card {
  border-radius: 8px;
}

.member-info {
  display: flex;
  gap: 16px;
  margin-bottom: 16px;
}

.info-text {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.info-text .name {
  font-size: 16px;
  font-weight: 500;
  margin-bottom: 4px;
}

.info-text .position {
  color: #666;
  margin-bottom: 2px;
}

.info-text .dept {
  color: #999;
  font-size: 12px;
}

.contact-info {
  border-top: 1px solid #f0f0f0;
  padding-top: 12px;
  font-size: 13px;
  color: #666;
}

.contact-item {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 4px;
}

:deep(.ant-tree-node-content-wrapper) {
  padding: 4px 0;
}
</style>
