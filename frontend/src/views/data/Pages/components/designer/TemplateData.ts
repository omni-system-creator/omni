import { generateId, type PageConfig } from './types';

export const getDataListTemplate = (): PageConfig => {
  return {
    root: {
      id: 'root',
      type: 'div',
      props: {},
      style: { padding: '24px', height: '100%', display: 'flex', flexDirection: 'column', background: '#f0f2f5' },
      events: {},
      children: [
        {
          id: generateId(),
          type: 'ACard',
          props: { bordered: false },
          style: { marginBottom: '16px', flexShrink: '0' },
          events: {},
          children: [
            {
              id: generateId(),
              type: 'AForm',
              props: { layout: 'inline' },
              style: { marginBottom: '16px' },
              events: {},
              children: [
                {
                  id: generateId(),
                  type: 'AFormItem',
                  props: { label: '关键词' },
                  style: {},
                  events: {},
                  children: [{
                    id: generateId(),
                    type: 'AInput',
                    props: { placeholder: '请输入搜索关键词', allowClear: true },
                    model: 'query.keyword',
                    style: { width: '200px' },
                    children: [],
                    events: {}
                  }]
                },
                {
                  id: generateId(),
                  type: 'AFormItem',
                  props: { label: '状态' },
                  style: {},
                  events: {},
                  children: [{
                    id: generateId(),
                    type: 'ASelect',
                    props: { placeholder: '请选择状态', allowClear: true, options: [{label:'启用',value:'1'}, {label:'禁用',value:'0'}] },
                    model: 'query.status',
                    style: { width: '150px' },
                    children: [],
                    events: {}
                  }]
                },
                {
                  id: generateId(),
                  type: 'AFormItem',
                  props: {},
                  style: {},
                  events: {},
                  children: [
                    {
                      id: generateId(),
                      type: 'ASpace',
                      props: {},
                      style: {},
                      events: {},
                      children: [
                         { id: generateId(), type: 'AButton', props: { type: 'primary' }, text: '查询', events: { click: 'handleSearch' }, style: {}, children: [] },
                         { id: generateId(), type: 'AButton', props: {}, text: '重置', events: { click: 'handleReset' }, style: {}, children: [] }
                      ]
                    }
                  ]
                }
              ]
            },
            {
              id: generateId(),
              type: 'ASpace',
              props: {},
              style: { width: '100%', justifyContent: 'space-between' },
              events: {},
              children: [
                {
                  id: generateId(),
                  type: 'ASpace',
                  props: {},
                  style: {},
                  events: {},
                  children: [
                    { id: generateId(), type: 'AButton', props: { type: 'primary' }, text: '新增', events: { click: 'handleAdd' }, style: {}, children: [] },
                    { id: generateId(), type: 'AButton', props: {}, text: '修改', events: { click: 'handleEdit' }, style: {}, children: [] },
                    { id: generateId(), type: 'AButton', props: { danger: true }, text: '批量删除', events: { click: 'handleBatchDelete' }, style: {}, children: [] },
                    { id: generateId(), type: 'AButton', props: {}, text: '导入', events: { click: 'handleImport' }, style: {}, children: [] },
                    { id: generateId(), type: 'AButton', props: {}, text: '导出', events: { click: 'handleExport' }, style: {}, children: [] }
                  ]
                },
                {
                  id: generateId(),
                  type: 'ASpace',
                  props: {},
                  style: {},
                  events: {},
                  children: [
                     { id: generateId(), type: 'AButton', props: {}, text: '刷新', events: { click: 'handleRefresh' }, style: {}, children: [] }
                  ]
                }
              ]
            }
          ]
        },
        {
          id: generateId(),
          type: 'ACard',
          props: { bordered: false, bodyStyle: { padding: '0', flex: '1', display: 'flex', flexDirection: 'column', overflow: 'hidden' } },
          style: { flex: '1', overflow: 'hidden', display: 'flex', flexDirection: 'column' },
          events: {},
          children: [
            {
              id: generateId(),
              type: 'ATable',
              props: {
                columns: [
                  { title: 'ID', dataIndex: 'id', width: 80 },
                  { title: '名称', dataIndex: 'name' },
                  { title: '状态', dataIndex: 'status' },
                  { title: '创建时间', dataIndex: 'createTime' },
                  { title: '操作', key: 'action', width: 200, fixed: 'right' }
                ],
                dataSource: [],
                scroll: { y: 'calc(100vh - 250px)' },
                pagination: {
                   position: ['bottomRight'],
                   showSizeChanger: true,
                   showQuickJumper: true,
                   pageSize: 10,
                   pageSizeOptions: ['10', '20', '50', '100'],
                   showTotal: (total: number) => `共 ${total} 条数据`,
                   total: 100
                },
                rowSelection: { type: 'checkbox' },
                rowKey: 'id'
              },
              model: 'tableData',
              style: { flex: '1' },
              events: { change: 'handleTableChange' },
              children: []
            }
          ]
        }
      ]
    },
    script: `
import { ref, reactive, onMounted } from 'vue';
import { message } from 'ant-design-vue';

// 查询条件
const query = reactive({
  keyword: '',
  status: undefined,
  page: 1,
  pageSize: 10
});

// 分页配置
const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0,
  showSizeChanger: true,
  pageSizeOptions: ['10', '20', '50', '100'],
  showTotal: (total) => \`共 \${total} 条数据\`
});

// 表格数据
const tableData = ref([]);
const loading = ref(false);

// 方法
const handleSearch = () => {
  loading.value = true;
  message.info('执行查询: ' + JSON.stringify(query));
  // 模拟API调用
  setTimeout(() => {
    // 模拟总数
    const total = 100;
    pagination.total = total;
    
    tableData.value = Array.from({ length: query.pageSize }).map((_, i) => ({
      id: (query.page - 1) * query.pageSize + i + 1,
      name: '测试数据 ' + ((query.page - 1) * query.pageSize + i + 1),
      status: i % 2 === 0 ? '启用' : '禁用',
      createTime: '2023-12-' + (i + 1).toString().padStart(2, '0')
    }));
    loading.value = false;
  }, 500);
};

const handleTableChange = (pag) => {
  pagination.current = pag.current;
  pagination.pageSize = pag.pageSize;
  query.page = pag.current;
  query.pageSize = pag.pageSize;
  handleSearch();
};

const handleReset = () => {
  query.keyword = '';
  query.status = undefined;
  query.page = 1;
  handleSearch();
};

const handleAdd = () => {
  message.success('点击新增');
};

const handleEdit = () => {
  message.success('点击修改');
};

const handleBatchDelete = () => {
  message.error('点击批量删除');
};

const handleImport = () => {
  message.success('点击导入');
};

const handleExport = () => {
  message.success('点击导出');
};

const handleRefresh = () => {
  handleSearch();
};

onMounted(() => {
  handleSearch();
});
    `.trim(),
    css: ''
  };
};

export const getAddEditTemplate = (): PageConfig => {
  return {
    root: {
      id: 'root',
      type: 'div',
      props: {},
      style: { padding: '24px', minHeight: '100%', background: '#fff' },
      events: {},
      children: [
        {
          id: generateId(),
          type: 'h2',
          text: '新增/编辑 用户',
          props: {},
          style: { marginBottom: '24px', borderBottom: '1px solid #eee', paddingBottom: '16px' },
          children: [],
          events: {}
        },
        {
          id: generateId(),
          type: 'AForm',
          props: { layout: 'vertical', labelCol: { span: 6 }, wrapperCol: { span: 18 } },
          style: { maxWidth: '800px' },
          events: {},
          children: [
            {
              id: generateId(),
              type: 'ARow',
              props: { gutter: 24 },
              style: {},
              events: {},
              children: [
                {
                   id: generateId(),
                   type: 'ACol',
                   props: { span: 12 },
                   style: {},
                   events: {},
                   children: [
                     {
                       id: generateId(),
                       type: 'AFormItem',
                       props: { label: '用户名称', required: true },
                       style: {},
                       events: {},
                       children: [
                         {
                           id: generateId(),
                           type: 'AInput',
                           props: { placeholder: '请输入用户名称' },
                           model: 'formData.name',
                           style: {},
                           children: [],
                           events: {}
                         }
                       ]
                     }
                   ]
                },
                {
                   id: generateId(),
                   type: 'ACol',
                   props: { span: 12 },
                   style: {},
                   events: {},
                   children: [
                     {
                       id: generateId(),
                       type: 'AFormItem',
                       props: { label: '登录账号', required: true },
                       style: {},
                       events: {},
                       children: [
                         {
                           id: generateId(),
                           type: 'AInput',
                           props: { placeholder: '请输入登录账号' },
                           model: 'formData.account',
                           style: {},
                           children: [],
                           events: {}
                         }
                       ]
                     }
                   ]
                }
              ]
            },
            {
              id: generateId(),
              type: 'AFormItem',
              props: { label: '状态' },
              style: {},
              events: {},
              children: [
                {
                  id: generateId(),
                  type: 'ARadioGroup',
                  props: { options: [{ label: '启用', value: '1' }, { label: '禁用', value: '0' }] },
                  model: 'formData.status',
                  style: {},
                  children: [],
                  events: {}
                }
              ]
            },
            {
              id: generateId(),
              type: 'AFormItem',
              props: { label: '备注' },
              style: {},
              events: {},
              children: [
                {
                  id: generateId(),
                  type: 'ATextarea',
                  props: { placeholder: '请输入备注信息', rows: 4 },
                  model: 'formData.remark',
                  style: {},
                  children: [],
                  events: {}
                }
              ]
            },
            {
              id: generateId(),
              type: 'AFormItem',
              props: {},
              style: { marginTop: '24px' },
              events: {},
              children: [
                {
                  id: generateId(),
                  type: 'ASpace',
                  props: {},
                  style: {},
                  events: {},
                  children: [
                    {
                      id: generateId(),
                      type: 'AButton',
                      props: { type: 'primary' },
                      text: '提交保存',
                      style: {},
                      children: [],
                      events: { click: 'handleSubmit' }
                    },
                    {
                      id: generateId(),
                      type: 'AButton',
                      props: {},
                      text: '取消返回',
                      style: {},
                      children: [],
                      events: { click: 'handleCancel' }
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    },
    script: `
import { reactive } from 'vue';
import { message } from 'ant-design-vue';

const formData = reactive({
  name: '',
  account: '',
  status: '1',
  remark: ''
});

const handleSubmit = () => {
  if (!formData.name) {
    message.warning('请输入用户名称');
    return;
  }
  if (!formData.account) {
    message.warning('请输入登录账号');
    return;
  }
  
  message.success('提交成功: ' + JSON.stringify(formData));
  // TODO: 调用API保存数据
};

const handleCancel = () => {
  message.info('取消操作，返回上一页');
  // router.back();
};
    `.trim(),
    css: ''
  };
};

export const getViewTemplate = (): PageConfig => {
  return {
    root: {
      id: 'root',
      type: 'div',
      props: {},
      style: { padding: '24px', minHeight: '100%', background: '#fff' },
      events: {},
      children: [
        {
          id: generateId(),
          type: 'div',
          props: {},
          style: { display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px', borderBottom: '1px solid #eee', paddingBottom: '16px' },
          events: {},
          children: [
            {
              id: generateId(),
              type: 'h2',
              text: '用户详情',
              props: {},
              style: { margin: 0 },
              children: [],
              events: {}
            },
            {
               id: generateId(),
               type: 'AButton',
               props: {},
               text: '返回列表',
               style: {},
               children: [],
               events: { click: 'handleBack' }
            }
          ]
        },
        {
          id: generateId(),
          type: 'ADescriptions',
          props: { title: '基本信息', bordered: true, column: 2 },
          style: { marginBottom: '24px' },
          events: {},
          children: [
            {
              id: generateId(),
              type: 'ADescriptionsItem',
              props: { label: '用户名称' },
              text: '张三',
              style: {},
              children: [],
              events: {}
            },
            {
              id: generateId(),
              type: 'ADescriptionsItem',
              props: { label: '登录账号' },
              text: 'zhangsan',
              style: {},
              children: [],
              events: {}
            },
            {
              id: generateId(),
              type: 'ADescriptionsItem',
              props: { label: '状态' },
              text: '启用',
              style: {},
              children: [],
              events: {}
            },
            {
              id: generateId(),
              type: 'ADescriptionsItem',
              props: { label: '创建时间' },
              text: '2023-12-01 12:00:00',
              style: {},
              children: [],
              events: {}
            },
            {
              id: generateId(),
              type: 'ADescriptionsItem',
              props: { label: '备注', span: 2 },
              text: '这是一个测试用户账号',
              style: {},
              children: [],
              events: {}
            }
          ]
        },
        {
          id: generateId(),
          type: 'ADescriptions',
          props: { title: '其他信息', bordered: true, column: 1 },
          style: {},
          events: {},
          children: [
            {
              id: generateId(),
              type: 'ADescriptionsItem',
              props: { label: '最后登录IP' },
              text: '192.168.1.100',
              style: {},
              children: [],
              events: {}
            },
            {
              id: generateId(),
              type: 'ADescriptionsItem',
              props: { label: '最后登录时间' },
              text: '2023-12-28 09:30:00',
              style: {},
              children: [],
              events: {}
            }
          ]
        }
      ]
    },
    script: `
import { onMounted } from 'vue';
import { message } from 'ant-design-vue';

const handleBack = () => {
  message.info('返回上一页');
  // router.back();
};

onMounted(() => {
  // TODO: 从路由参数获取ID并调用API加载详情
  console.log('加载详情数据...');
});
    `.trim(),
    css: ''
  };
};
