import * as Antd from 'ant-design-vue';

export interface ComponentGroupItem {
  type: string;
  label: string;
  defaultProps: Record<string, any>;
  text?: string;
  events: string[];
}

export interface PropSchema {
  label: string;
  type: 'string' | 'number' | 'boolean' | 'select' | 'json' | 'color';
  options?: { label: string; value: any }[];
  defaultValue?: any;
}

const commonAntdProps: Record<string, PropSchema> = {
  size: {
    label: '尺寸',
    type: 'select',
    options: [
      { label: '大', value: 'large' },
      { label: '中', value: 'middle' },
      { label: '小', value: 'small' },
      { label: '默认', value: 'default' }
    ]
  },
  disabled: { label: '禁用', type: 'boolean' },
  loading: { label: '加载中', type: 'boolean' },
  bordered: { label: '边框', type: 'boolean' },
};

const componentPropsSchema: Record<string, Record<string, PropSchema>> = {
  'AButton': {
    type: { 
      label: '按钮类型', 
      type: 'select', 
      options: [
        { label: '主按钮', value: 'primary' },
        { label: '默认按钮', value: 'default' },
        { label: '虚线按钮', value: 'dashed' },
        { label: '文本按钮', value: 'text' },
        { label: '链接按钮', value: 'link' }
      ] 
    },
    ...commonAntdProps,
    ghost: { label: '幽灵按钮', type: 'boolean' },
    block: { label: '块级按钮', type: 'boolean' },
    shape: { 
      label: '形状', 
      type: 'select', 
      options: [
        { label: '默认', value: 'default' },
        { label: '圆形', value: 'circle' },
        { label: '圆角', value: 'round' }
      ] 
    },
    href: { label: '链接地址', type: 'string' },
    target: { label: '链接目标', type: 'string' },
  },
  'AInput': {
    ...commonAntdProps,
    placeholder: { label: '占位符', type: 'string' },
    allowClear: { label: '允许清除', type: 'boolean' },
    maxLength: { label: '最大长度', type: 'number' },
    type: { label: '类型', type: 'string', defaultValue: 'text' },
    addonBefore: { label: '前置标签', type: 'string' },
    addonAfter: { label: '后置标签', type: 'string' },
    prefix: { label: '前缀', type: 'string' },
    suffix: { label: '后缀', type: 'string' },
  },
  'ASelect': {
    ...commonAntdProps,
    placeholder: { label: '占位符', type: 'string' },
    allowClear: { label: '允许清除', type: 'boolean' },
    mode: { 
      label: '模式', 
      type: 'select',
      options: [
        { label: '单选', value: 'default' },
        { label: '多选', value: 'multiple' },
        { label: '标签', value: 'tags' }
      ]
    },
    showSearch: { label: '支持搜索', type: 'boolean' },
    options: { label: '选项数据', type: 'json' },
  },
  'ASwitch': {
    ...commonAntdProps,
    checkedChildren: { label: '选中时内容', type: 'string' },
    unCheckedChildren: { label: '非选中内容', type: 'string' },
  },
  'ACheckbox': {
    ...commonAntdProps,
    checked: { label: '选中状态', type: 'boolean' },
  },
  'ARadio': {
    ...commonAntdProps,
    checked: { label: '选中状态', type: 'boolean' },
    value: { label: '值', type: 'string' },
  },
  'ADatePicker': {
    ...commonAntdProps,
    placeholder: { label: '占位符', type: 'string' },
    format: { label: '格式', type: 'string' },
    showTime: { label: '显示时间', type: 'boolean' },
    picker: {
      label: '选择器类型',
      type: 'select',
      options: [
        { label: '日期', value: 'date' },
        { label: '周', value: 'week' },
        { label: '月', value: 'month' },
        { label: '季度', value: 'quarter' },
        { label: '年', value: 'year' }
      ]
    }
  },
  'AForm': {
    layout: {
      label: '布局',
      type: 'select',
      options: [
        { label: '水平', value: 'horizontal' },
        { label: '垂直', value: 'vertical' },
        { label: '内联', value: 'inline' }
      ]
    },
    labelCol: { label: '标签布局', type: 'json' },
    wrapperCol: { label: '控件布局', type: 'json' },
  },
  'AFormItem': {
    label: { label: '标签', type: 'string' },
    name: { label: '字段名', type: 'string' },
    required: { label: '必填', type: 'boolean' },
    rules: { label: '校验规则', type: 'json' },
    extra: { label: '额外提示', type: 'string' },
  },
  'ATag': {
    color: { label: '颜色', type: 'color' },
    closable: { label: '可关闭', type: 'boolean' },
  },
  'AAvatar': {
    ...commonAntdProps,
    src: { label: '图片地址', type: 'string' },
    icon: { label: '图标', type: 'string' },
    shape: { 
      label: '形状', 
      type: 'select',
      options: [
        { label: '圆形', value: 'circle' },
        { label: '方形', value: 'square' }
      ]
    }
  },
  'ABadge': {
    count: { label: '数量', type: 'number' },
    dot: { label: '红点', type: 'boolean' },
    overflowCount: { label: '封顶数字', type: 'number' },
    status: {
      label: '状态',
      type: 'select',
      options: [
        { label: 'Success', value: 'success' },
        { label: 'Processing', value: 'processing' },
        { label: 'Default', value: 'default' },
        { label: 'Error', value: 'error' },
        { label: 'Warning', value: 'warning' }
      ]
    },
    text: { label: '状态文本', type: 'string' }
  },
  'ASpace': {
    size: { label: '间距', type: 'number' },
    direction: {
      label: '方向',
      type: 'select',
      options: [
        { label: '水平', value: 'horizontal' },
        { label: '垂直', value: 'vertical' }
      ]
    },
    align: {
      label: '对齐',
      type: 'select',
      options: [
        { label: 'Start', value: 'start' },
        { label: 'End', value: 'end' },
        { label: 'Center', value: 'center' },
        { label: 'Baseline', value: 'baseline' }
      ]
    }
  },
  'ADivider': {
    type: {
      label: '类型',
      type: 'select',
      options: [
        { label: '水平', value: 'horizontal' },
        { label: '垂直', value: 'vertical' }
      ]
    },
    orientation: {
      label: '标题位置',
      type: 'select',
      options: [
        { label: '左', value: 'left' },
        { label: '右', value: 'right' },
        { label: '中', value: 'center' }
      ]
    },
    dashed: { label: '虚线', type: 'boolean' }
  },
  'ATable': {
    ...commonAntdProps,
    columns: { label: '列定义', type: 'json' },
    dataSource: { label: '数据源', type: 'json' },
    pagination: { label: '分页配置', type: 'json' },
    rowKey: { label: 'Row Key', type: 'string', defaultValue: 'key' },
    showHeader: { label: '显示表头', type: 'boolean', defaultValue: true },
    scroll: { label: '滚动配置', type: 'json' },
  },
  'ADescriptions': {
    title: { label: '标题', type: 'string' },
    bordered: { label: '边框', type: 'boolean' },
    column: { label: '列数', type: 'number', defaultValue: 3 },
    size: { 
      label: '尺寸', 
      type: 'select', 
      options: [
        { label: '默认', value: 'default' },
        { label: '中等', value: 'middle' },
        { label: '小', value: 'small' }
      ]
    },
    layout: {
      label: '布局',
      type: 'select',
      options: [
        { label: '水平', value: 'horizontal' },
        { label: '垂直', value: 'vertical' }
      ]
    },
    colon: { label: '冒号', type: 'boolean', defaultValue: true }
  },
  'ADescriptionsItem': {
    label: { label: '标签', type: 'string' },
    span: { label: '跨列数', type: 'number', defaultValue: 1 }
  },
  'ACard': {
    ...commonAntdProps,
    title: { label: '标题', type: 'string' },
    hoverable: { label: '悬停浮起', type: 'boolean' },
    extra: { label: '右上角内容', type: 'string' },
  },
  'ARow': {
    gutter: { label: '栅格间隔', type: 'number' },
    align: { 
      label: '垂直对齐', 
      type: 'select',
      options: [
        { label: '顶部', value: 'top' },
        { label: '居中', value: 'middle' },
        { label: '底部', value: 'bottom' }
      ]
    },
    justify: {
      label: '水平排列',
      type: 'select',
      options: [
        { label: '居左', value: 'start' },
        { label: '居末', value: 'end' },
        { label: '居中', value: 'center' },
        { label: 'Space Around', value: 'space-around' },
        { label: 'Space Between', value: 'space-between' }
      ]
    }
  },
  'ACol': {
    span: { label: '栅格占位', type: 'number' },
    offset: { label: '栅格偏移', type: 'number' },
    push: { label: '向右移动', type: 'number' },
    pull: { label: '向左移动', type: 'number' },
  },
  // Basic HTML Elements
  'div': {
    title: { label: '提示文本', type: 'string' },
  },
  'span': {
    title: { label: '提示文本', type: 'string' },
  },
  'p': {
    title: { label: '提示文本', type: 'string' },
  },
  'h1': {
    title: { label: '提示文本', type: 'string' },
  }
};

export const getComponentPropsSchema = (type: string): Record<string, PropSchema> => {
  return componentPropsSchema[type] || {};
};

export const commonStyleSchema: Record<string, PropSchema> = {
  width: { label: '宽度', type: 'string' },
  height: { label: '高度', type: 'string' },
  margin: { label: '外边距', type: 'string' },
  padding: { label: '内边距', type: 'string' },
  color: { label: '字体颜色', type: 'color' },
  backgroundColor: { label: '背景颜色', type: 'color' },
  fontSize: { label: '字体大小', type: 'string' },
  fontWeight: { label: '字体粗细', type: 'select', options: [
    { label: '正常', value: 'normal' },
    { label: '粗体', value: 'bold' },
    { label: '100', value: '100' },
    { label: '200', value: '200' },
    { label: '300', value: '300' },
    { label: '400', value: '400' },
    { label: '500', value: '500' },
    { label: '600', value: '600' },
    { label: '700', value: '700' },
    { label: '800', value: '800' },
    { label: '900', value: '900' }
  ]},
  textAlign: { label: '文本对齐', type: 'select', options: [
    { label: '左对齐', value: 'left' },
    { label: '居中', value: 'center' },
    { label: '右对齐', value: 'right' }
  ]},
  display: { label: '显示模式', type: 'select', options: [
    { label: 'Block', value: 'block' },
    { label: 'Inline Block', value: 'inline-block' },
    { label: 'Flex', value: 'flex' },
    { label: 'None', value: 'none' }
  ]},
  flex: { label: 'Flex', type: 'string' },
};

// Define available components for the toolbar
export const componentGroups: { title: string; items: ComponentGroupItem[] }[] = [
  {
    title: '基础 HTML',
    items: [
      { type: 'div', label: 'Div 容器', defaultProps: {}, events: ['click', 'mouseenter', 'mouseleave'] },
      { type: 'span', label: 'Span 文本', defaultProps: {}, events: ['click'] },
      { type: 'p', label: '段落', defaultProps: {}, events: ['click'] },
      { type: 'h1', label: '标题 H1', defaultProps: {}, events: ['click'] },
    ]
  },
  {
    title: '通用',
    items: [
      { type: 'AButton', label: '按钮', defaultProps: { type: 'primary' }, text: 'Button', events: ['click'] },
      { type: 'AIcon', label: '图标', defaultProps: { type: 'UserOutlined' }, events: ['click'] },
      { type: 'ATypography', label: '排版', defaultProps: {}, events: [] },
    ]
  },
  {
    title: '布局',
    items: [
      { type: 'ARow', label: '行 (Row)', defaultProps: { gutter: 16 }, events: ['click'] },
      { type: 'ACol', label: '列 (Col)', defaultProps: { span: 12 }, events: ['click'] },
      { type: 'ACard', label: '卡片', defaultProps: { title: 'Card Title' }, events: ['click'] },
      { type: 'ASpace', label: '间距', defaultProps: {}, events: [] },
      { type: 'ADivider', label: '分割线', defaultProps: {}, events: [] },
    ]
  },
  {
    title: '表单',
    items: [
      { type: 'AForm', label: '表单', defaultProps: {}, events: ['finish', 'finishFailed', 'submit'] },
      { type: 'AFormItem', label: '表单项', defaultProps: { label: 'Label' }, events: [] },
      { type: 'AInput', label: '输入框', defaultProps: { placeholder: '请输入' }, events: ['change', 'input', 'focus', 'blur', 'pressEnter'] },
      { type: 'ASelect', label: '下拉选', defaultProps: { placeholder: '请选择' }, events: ['change', 'select', 'search', 'blur', 'focus', 'popupScroll', 'dropdownVisibleChange'] },
      { type: 'ASwitch', label: '开关', defaultProps: {}, events: ['change', 'click'] },
      { type: 'ADatePicker', label: '日期', defaultProps: {}, events: ['change', 'openChange', 'panelChange'] },
      { type: 'ACheckbox', label: '复选框', defaultProps: {}, events: ['change'] },
      { type: 'ARadio', label: '单选框', defaultProps: {}, events: ['change'] },
    ]
  },
  {
    title: '数据展示',
    items: [
      { 
        type: 'ATable', 
        label: '表格', 
        defaultProps: {
          columns: [
            { title: '姓名', dataIndex: 'name', key: 'name' },
            { title: '年龄', dataIndex: 'age', key: 'age' },
            { title: '住址', dataIndex: 'address', key: 'address' },
          ],
          dataSource: [
            { key: '1', name: '胡彦斌', age: 32, address: '西湖区湖底公园1号' },
            { key: '2', name: '胡彦祖', age: 42, address: '西湖区湖底公园1号' },
          ],
          pagination: { pageSize: 5 },
          rowKey: 'key',
          bordered: true
        }, 
        events: ['change', 'expandedRowsChange', 'resizeColumn'] 
      },
      { type: 'AList', label: '列表', defaultProps: {}, events: [] },
      { type: 'ATag', label: '标签', defaultProps: { color: 'blue' }, text: 'Tag', events: ['click', 'close'] },
      { type: 'AAvatar', label: '头像', defaultProps: {}, events: ['click'] },
      { type: 'ABadge', label: '徽标', defaultProps: { count: 5 }, events: [] },
      { 
        type: 'ADescriptions', 
        label: '描述列表', 
        defaultProps: { 
          title: '描述列表', 
          bordered: true 
        }, 
        events: [] 
      },
      { 
        type: 'ADescriptionsItem', 
        label: '描述项', 
        defaultProps: { label: '标签' }, 
        text: '内容', 
        events: [] 
      },
    ]
  }
];

export const resolveComponent = (name: string) => {
  if (name.startsWith('A')) {
    const realName = name.substring(1);
    if ((Antd as any)[realName]) {
      return (Antd as any)[realName];
    }
  }
  return name;
};

export const getComponentEvents = (type: string): string[] => {
  for (const group of componentGroups) {
    const item = group.items.find(i => i.type === type);
    if (item && item.events) {
      return item.events;
    }
  }
  return ['click', 'change', 'input', 'focus', 'blur']; // Fallback common events
};

// Map event names to argument signatures
const eventSignatureMap: Record<string, string> = {
  'click': 'e',
  'change': 'e',
  'input': 'e',
  'focus': 'e',
  'blur': 'e',
  'pressEnter': 'e',
  'finish': 'values',
  'finishFailed': 'errorInfo',
  'submit': 'e',
  'select': 'value, option',
  'search': 'value',
  'popupScroll': 'e',
  'dropdownVisibleChange': 'open',
  'openChange': 'open',
  'panelChange': 'value, mode',
  'expandedRowsChange': 'expandedRows',
  'resizeColumn': 'w, col',
  'close': 'e',
  'mouseenter': 'e',
  'mouseleave': 'e'
};

export const getEventSignature = (eventName: string): string => {
  return eventSignatureMap[eventName] || '...args';
};
