
export interface ComponentNode {
  id: string;
  type: string;
  label?: string;
  props: Record<string, any>;
  style: Record<string, any>;
  class?: string;
  children: ComponentNode[];
  text?: string;
  events: Record<string, string>;
  model?: string;
}

export interface PageConfig {
  root: ComponentNode;
  script: string;
  css: string;
}

export const generateId = () => 'comp_' + Math.random().toString(36).substr(2, 9);

export const defaultPageConfig: PageConfig = {
  root: {
    id: 'root',
    type: 'div',
    props: {},
    style: { padding: '24px', minHeight: '100%', background: '#f0f2f5' },
    events: {},
    children: [
      {
        id: 'header-row',
        type: 'div',
        props: {},
        style: { marginBottom: '24px' },
        children: [
          {
            id: 'page-title',
            type: 'h2',
            text: '用户管理系统',
            props: {},
            style: { margin: '0', color: '#000000d9', fontWeight: '600' },
            children: [],
            events: {}
          }
        ],
        events: {}
      },
      {
        id: 'search-card',
        type: 'ACard',
        props: { bordered: false },
        style: { marginBottom: '24px' },
        events: {},
        children: [
          {
            id: 'search-form',
            type: 'AForm',
            props: { layout: 'inline' },
            style: {},
            events: {},
            children: [
              {
                id: 'form-item-name',
                type: 'AFormItem',
                props: { label: '用户名' },
                style: {},
                events: {},
                children: [
                  {
                    id: 'input-name',
                    type: 'AInput',
                    props: { placeholder: '请输入用户名', allowClear: true },
                    model: 'query.username',
                    style: { width: '200px' },
                    children: [],
                    events: {}
                  }
                ]
              },
              {
                id: 'form-item-role',
                type: 'AFormItem',
                props: { label: '角色' },
                style: {},
                events: {},
                children: [
                  {
                    id: 'select-role',
                    type: 'ASelect',
                    props: { 
                      placeholder: '请选择角色', 
                      style: { width: '150px' },
                      options: [
                        { value: 'admin', label: '管理员' },
                        { value: 'user', label: '普通用户' }
                      ]
                    },
                    model: 'query.role',
                    style: {},
                    children: [],
                    events: {}
                  }
                ]
              },
              {
                id: 'form-item-actions',
                type: 'AFormItem',
                props: {},
                style: {},
                events: {},
                children: [
                  {
                    id: 'btn-space',
                    type: 'ASpace',
                    props: {},
                    style: {},
                    events: {},
                    children: [
                      {
                        id: 'btn-search',
                        type: 'AButton',
                        text: '查询',
                        props: { type: 'primary' },
                        style: {},
                        children: [],
                        events: { click: 'handleSearch()' }
                      },
                      {
                        id: 'btn-reset',
                        type: 'AButton',
                        text: '重置',
                        props: {},
                        style: {},
                        children: [],
                        events: { click: 'handleReset()' }
                      }
                    ]
                  }
                ]
              }
            ]
          }
        ]
      },
      {
        id: 'list-card',
        type: 'ACard',
        props: { title: '用户列表', bordered: false },
        style: {},
        events: {},
        children: [
          {
            id: 'table-toolbar',
            type: 'div',
            props: {},
            style: { marginBottom: '16px' },
            events: {},
            children: [
              {
                id: 'toolbar-space',
                type: 'ASpace',
                props: {},
                style: {},
                events: {},
                children: [
                  {
                    id: 'btn-add',
                    type: 'AButton',
                    text: '新增用户',
                    props: { type: 'primary' },
                    style: {},
                    children: [],
                    events: { click: 'handleAdd()' }
                  },
                  {
                    id: 'btn-delete',
                    type: 'AButton',
                    text: '批量删除',
                    props: { danger: true },
                    style: {},
                    children: [],
                    events: { click: 'handleDelete()' }
                  }
                ]
              }
            ]
          },
          {
            id: 'user-table',
            type: 'ATable',
            props: {
              columns: [
                { title: 'ID', dataIndex: 'id', key: 'id' },
                { title: '用户名', dataIndex: 'name', key: 'name' },
                { title: '角色', dataIndex: 'role', key: 'role' },
                { title: '状态', dataIndex: 'status', key: 'status' },
                { title: '创建时间', dataIndex: 'createTime', key: 'createTime' }
              ],
              dataSource: [
                { id: '1', name: 'Admin', role: '管理员', status: '启用', createTime: '2023-01-01' },
                { id: '2', name: 'User001', role: '普通用户', status: '启用', createTime: '2023-01-02' },
                { id: '3', name: 'User002', role: '普通用户', status: '禁用', createTime: '2023-01-03' }
              ],
              pagination: { pageSize: 5 }
            },
            style: {},
            children: [],
            events: {}
          }
        ]
      }
    ]
  },
  script: `import { ref, reactive, onMounted } from 'vue';
import { message } from 'ant-design-vue';

// 查询条件
const query = reactive({
  username: '',
  role: undefined
});

// 表格数据
const loading = ref(false);
const tableData = ref([
  { id: '1', name: 'Admin', role: '管理员', status: '启用', createTime: '2023-01-01' },
  { id: '2', name: 'User001', role: '普通用户', status: '启用', createTime: '2023-01-02' },
  { id: '3', name: 'User002', role: '普通用户', status: '禁用', createTime: '2023-01-03' }
]);

// 事件处理
const handleSearch = () => {
  loading.value = true;
  message.loading('查询中...', 0.5);
  setTimeout(() => {
    loading.value = false;
    message.success('查询完成');
  }, 500);
};

const handleReset = () => {
  query.username = '';
  query.role = undefined;
  message.info('重置成功');
};

const handleAdd = () => {
  message.success('点击了新增用户');
};

const handleDelete = () => {
  message.warning('点击了批量删除');
};

onMounted(() => {
  console.log('User Management Page Loaded');
});`,
  css: `/* 自定义样式 */
.ant-card {
  box-shadow: 0 1px 2px 0 rgba(0,0,0,0.03);
}`
};
