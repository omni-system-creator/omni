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
          <template #title="{ name }">
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
                {{ member.name.charAt(0) }}
              </a-avatar>
              <div class="info-text">
                <div class="name">
                  {{ member.name }} 
                  <a-tag v-if="member.isLeader" color="blue">负责人</a-tag>
                  <a-tag :color="statusMap[member.status]?.color" style="margin-left: 8px;">{{ statusMap[member.status]?.text }}</a-tag>
                </div>
                <div class="position">{{ member.position }}</div>
                <div class="dept">{{ member.deptName }}</div>
              </div>
            </div>
            <div class="contact-info">
              <div class="contact-item">
                <MailOutlined /> {{ member.email }}
              </div>
              <div class="contact-item">
                <PhoneOutlined /> {{ member.phone }}
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
                  {{ record.name.charAt(0) }}
                </a-avatar>
                {{ record.name }}
                <a-tag v-if="record.isLeader" color="blue">负责人</a-tag>
              </a-space>
            </template>
            <template v-else-if="column.key === 'status'">
              <a-badge :status="statusMap[record.status]?.status" :text="statusMap[record.status]?.text" />
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
import { ref, computed, onMounted } from 'vue';
import { 
  AppstoreOutlined, 
  BarsOutlined, 
  UserOutlined, 
  MailOutlined, 
  PhoneOutlined,
  MessageOutlined,
  ProfileOutlined
} from '@ant-design/icons-vue';

// Mock Data
const deptTree = [
  {
    id: '1',
    name: '总经办',
    children: []
  },
  {
    id: '2',
    name: '研发中心',
    children: [
      { id: '2-1', name: '前端开发组' },
      { id: '2-2', name: '后端开发组' },
      { id: '2-3', name: 'UI设计组' },
      { id: '2-4', name: '测试组' }
    ]
  },
  {
    id: '3',
    name: '营销中心',
    children: [
      { id: '3-1', name: '销售一部' },
      { id: '3-2', name: '销售二部' },
      { id: '3-3', name: '市场部' }
    ]
  },
  {
    id: '4',
    name: '财务中心',
    children: [
      { id: '4-1', name: '会计部' },
      { id: '4-2', name: '出纳部' }
    ]
  },
  {
    id: '5',
    name: '人力资源中心',
    children: [
      { id: '5-1', name: '招聘组' },
      { id: '5-2', name: '薪酬绩效组' }
    ]
  }
];

const allMembers = [
  { id: '101', name: '张三', position: '总经理', deptId: '1', deptName: '总经办', email: 'zhangsan@example.com', phone: '13800138001', avatar: '', isLeader: true, status: 'online' },
  { id: '201', name: '李四', position: '研发总监', deptId: '2', deptName: '研发中心', email: 'lisi@example.com', phone: '13800138002', avatar: '', isLeader: true, status: 'business' },
  { id: '211', name: '王五', position: '前端主管', deptId: '2-1', deptName: '前端开发组', email: 'wangwu@example.com', phone: '13800138003', avatar: '', isLeader: true, status: 'online' },
  { id: '212', name: '赵六', position: '高级前端工程师', deptId: '2-1', deptName: '前端开发组', email: 'zhaoliu@example.com', phone: '13800138004', avatar: '', isLeader: false, status: 'leave' },
  { id: '213', name: '钱七', position: '前端工程师', deptId: '2-1', deptName: '前端开发组', email: 'qianqi@example.com', phone: '13800138005', avatar: '', isLeader: false, status: 'online' },
  { id: '221', name: '孙八', position: '后端主管', deptId: '2-2', deptName: '后端开发组', email: 'sunba@example.com', phone: '13800138006', avatar: '', isLeader: true, status: 'out' },
  { id: '301', name: '周九', position: '营销总监', deptId: '3', deptName: '营销中心', email: 'zhoujiu@example.com', phone: '13800138007', avatar: '', isLeader: true, status: 'online' },
  { id: '311', name: '吴十', position: '销售经理', deptId: '3-1', deptName: '销售一部', email: 'wushi@example.com', phone: '13800138008', avatar: '', isLeader: true, status: 'business' },
  { id: '312', name: '郑十一', position: '销售专员', deptId: '3-1', deptName: '销售一部', email: 'zhengshiyi@example.com', phone: '13800138009', avatar: '', isLeader: false, status: 'online' },
];

const statusMap: Record<string, { text: string; status: string; color: string }> = {
  online: { text: '在岗', status: 'success', color: '#52c41a' },
  business: { text: '出差中', status: 'warning', color: '#faad14' },
  out: { text: '临时外出', status: 'processing', color: '#1890ff' },
  leave: { text: '休假中', status: 'error', color: '#ff4d4f' },
};

// State
const deptSearch = ref('');
const memberSearch = ref('');
const expandedKeys = ref<string[]>(['2', '3']);
const selectedKeys = ref<string[]>([]);
const currentDept = ref<any>(null);
const viewMode = ref('card');

// Table Columns
const columns = [
  { title: '姓名', key: 'name', width: 200 },
  { title: '工号', dataIndex: 'id', width: 100 },
  { title: '职位', dataIndex: 'position', width: 150 },
  { title: '部门', dataIndex: 'deptName', width: 150 },
  { title: '手机', dataIndex: 'phone', width: 150 },
  { title: '邮箱', dataIndex: 'email' },
  { title: '状态', key: 'status', width: 130 },
  { title: '操作', key: 'action', width: 150 }
];

// Methods
const handleSelect = (keys: string[], info: any) => {
  if (keys.length > 0) {
    // Find dept info
    // For simplicity, we just use the node data from tree select
    // In a real app, you might traverse or have a flat map
    const findDept = (nodes: any[], key: string): any => {
      for (const node of nodes) {
        if (node.id === key) return node;
        if (node.children) {
          const found = findDept(node.children, key);
          if (found) return found;
        }
      }
      return null;
    };
    currentDept.value = findDept(deptTree, keys[0]);
  } else {
    currentDept.value = null;
  }
};

const getAllDeptIds = (deptId: string): string[] => {
  const ids = [deptId];
  const findChildren = (nodes: any[]) => {
    for (const node of nodes) {
      if (node.id === deptId) {
        // found the node, now collect all children
        const collect = (n: any) => {
          if (n.children) {
            n.children.forEach((c: any) => {
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
  findChildren(deptTree);
  return ids;
};

// Computed
const filteredMembers = computed(() => {
  let data = allMembers;

  // Filter by department
  if (selectedKeys.value.length > 0) {
    const selectedId = selectedKeys.value[0];
    // Simple logic: if selecting a parent dept, show all children?
    // Let's implement recursive check or just direct match.
    // Usually org chart shows all under the subtree.
    // For now, let's just match exact deptId or basic subtree logic if we had parent references.
    // To keep it simple and robust without parent refs, let's helper function to find all child IDs
    
    const targetIds = getAllDeptIds(selectedId);
    data = data.filter(m => targetIds.includes(m.deptId));
  }

  // Filter by search text
  if (memberSearch.value) {
    const lowerSearch = memberSearch.value.toLowerCase();
    data = data.filter(m => 
      m.name.toLowerCase().includes(lowerSearch) || 
      m.position.toLowerCase().includes(lowerSearch) ||
      m.phone.includes(lowerSearch)
    );
  }

  return data;
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
