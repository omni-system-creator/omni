<template>
  <div class="employees-container">
    <a-card :bordered="false" class="header-stats">
      <a-row :gutter="16">
        <a-col :span="6">
          <a-statistic title="总员工数" :value="128" style="margin-right: 50px">
            <template #suffix>
              <UserOutlined />
            </template>
          </a-statistic>
        </a-col>
        <a-col :span="6">
          <a-statistic title="本月入职" :value="4" class="demo-class">
            <template #suffix>
              <span style="color: #52c41a; font-size: 14px"><ArrowUpOutlined /> 12%</span>
            </template>
          </a-statistic>
        </a-col>
        <a-col :span="6">
          <a-statistic title="研发部占比" :value="65" suffix="%">
            <template #prefix>
              <CodeOutlined />
            </template>
          </a-statistic>
        </a-col>
        <a-col :span="6">
          <a-statistic title="平均在职时长" value="2.5" suffix="年" />
        </a-col>
      </a-row>
    </a-card>

    <a-card :bordered="false" style="margin-top: 16px">
      <div class="table-operations">
        <a-space>
          <a-input-search
            v-model:value="searchText"
            placeholder="搜索姓名/工号/职位"
            style="width: 250px"
            @search="onSearch"
          />
          <a-select v-model:value="deptFilter" style="width: 150px" placeholder="部门筛选">
            <a-select-option value="">全部部门</a-select-option>
            <a-select-option value="R&D">研发部</a-select-option>
            <a-select-option value="Product">产品部</a-select-option>
            <a-select-option value="Design">设计部</a-select-option>
            <a-select-option value="QA">测试部</a-select-option>
          </a-select>
          <a-select v-model:value="statusFilter" style="width: 120px" placeholder="状态">
            <a-select-option value="">全部状态</a-select-option>
            <a-select-option value="active">在职</a-select-option>
            <a-select-option value="probation">试用期</a-select-option>
            <a-select-option value="leave">休假</a-select-option>
          </a-select>
        </a-space>
        <a-space>
          <a-button type="primary">
            <template #icon><PlusOutlined /></template>
            新增员工
          </a-button>
          <a-button>导出Excel</a-button>
        </a-space>
      </div>

      <a-table :columns="columns" :data-source="filteredData" :pagination="{ pageSize: 10 }" style="margin-top: 16px">
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'name'">
            <a-space>
              <a-avatar :style="{ backgroundColor: record.avatarColor }">{{ record.name.charAt(0) }}</a-avatar>
              <div>
                <div style="font-weight: 500">{{ record.name }}</div>
                <div style="font-size: 12px; color: #999">{{ record.id }}</div>
              </div>
            </a-space>
          </template>
          
          <template v-else-if="column.key === 'tags'">
            <span>
              <a-tag v-for="tag in record.tags" :key="tag" :color="getTagColor(tag)">
                {{ tag.toUpperCase() }}
              </a-tag>
            </span>
          </template>

          <template v-else-if="column.key === 'status'">
            <a-badge :status="getStatusBadge(record.status)" :text="getStatusText(record.status)" />
          </template>

          <template v-else-if="column.key === 'action'">
            <a-space size="middle">
              <a>详情</a>
              <a>调岗</a>
              <a style="color: #ff4d4f">离职</a>
            </a-space>
          </template>
        </template>
      </a-table>
    </a-card>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import { 
  UserOutlined, 
  ArrowUpOutlined, 
  CodeOutlined, 
  PlusOutlined 
} from '@ant-design/icons-vue';

const searchText = ref('');
const deptFilter = ref(undefined);
const statusFilter = ref(undefined);

const columns = [
  {
    title: '员工信息',
    dataIndex: 'name',
    key: 'name',
    width: 200,
  },
  {
    title: '部门',
    dataIndex: 'department',
    key: 'department',
  },
  {
    title: '职位',
    dataIndex: 'position',
    key: 'position',
  },
  {
    title: '技术栈/技能',
    key: 'tags',
    dataIndex: 'tags',
  },
  {
    title: '入职日期',
    dataIndex: 'joinDate',
    key: 'joinDate',
  },
  {
    title: '状态',
    key: 'status',
    dataIndex: 'status',
  },
  {
    title: '操作',
    key: 'action',
  },
];

const data = [
  {
    key: '1',
    id: 'EMP001',
    name: '张三',
    department: '研发部',
    position: '高级后端工程师',
    tags: ['Java', 'Spring Boot', 'K8s'],
    joinDate: '2020-03-15',
    status: 'active',
    avatarColor: '#f56a00',
  },
  {
    key: '2',
    id: 'EMP002',
    name: '李四',
    department: '研发部',
    position: '前端架构师',
    tags: ['Vue', 'TypeScript', 'WebGL'],
    joinDate: '2021-05-20',
    status: 'active',
    avatarColor: '#7265e6',
  },
  {
    key: '3',
    id: 'EMP003',
    name: '王五',
    department: '产品部',
    position: '高级产品经理',
    tags: ['SaaS', 'Axure', 'Jira'],
    joinDate: '2019-11-01',
    status: 'leave',
    avatarColor: '#ffbf00',
  },
  {
    key: '4',
    id: 'EMP004',
    name: '赵六',
    department: '测试部',
    position: '测试开发工程师',
    tags: ['Python', 'Selenium', 'Jenkins'],
    joinDate: '2022-02-14',
    status: 'probation',
    avatarColor: '#00a2ae',
  },
  {
    key: '5',
    id: 'EMP005',
    name: '钱七',
    department: '研发部',
    position: 'Golang工程师',
    tags: ['Go', 'gRPC', 'Microservices'],
    joinDate: '2023-07-01',
    status: 'active',
    avatarColor: '#87d068',
  },
  {
    key: '6',
    id: 'EMP006',
    name: '孙八',
    department: '设计部',
    position: 'UI/UX设计师',
    tags: ['Figma', 'Sketch', 'C4D'],
    joinDate: '2021-09-10',
    status: 'active',
    avatarColor: '#eb2f96',
  },
];

const filteredData = computed(() => {
  return data.filter(item => {
    const matchText = !searchText.value || 
      item.name.includes(searchText.value) || 
      item.position.includes(searchText.value);
    const matchDept = !deptFilter.value || item.department === deptFilter.value;
    const matchStatus = !statusFilter.value || item.status === statusFilter.value;
    return matchText && matchDept && matchStatus;
  });
});

const onSearch = (val: string) => {
  console.log('search:', val);
};

const getTagColor = (tag: string) => {
  const colors: Record<string, string> = {
    'java': 'red',
    'vue': 'green',
    'go': 'blue',
    'python': 'orange',
    'figma': 'pink',
  };
  return colors[tag.toLowerCase()] || 'cyan';
};

const getStatusBadge = (status: string) => {
  const map: Record<string, any> = {
    active: 'success',
    probation: 'processing',
    leave: 'warning',
    terminated: 'default',
  };
  return map[status] || 'default';
};

const getStatusText = (status: string) => {
  const map: Record<string, string> = {
    active: '正式员工',
    probation: '试用期',
    leave: '休假中',
    terminated: '已离职',
  };
  return map[status] || status;
};
</script>

<style scoped>
.employees-container {
  padding: 16px;
  flex: 1;
}

.header-stats {
  margin-bottom: 24px;
}

.table-operations {
  display: flex;
  justify-content: space-between;
  margin-bottom: 16px;
}
</style>
