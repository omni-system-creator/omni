import * as Antd from 'ant-design-vue';

export interface ComponentGroupItem {
  type: string;
  label: string;
  defaultProps: Record<string, any>;
  text?: string;
  events: string[];
}

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
      { type: 'ATable', label: '表格', defaultProps: {}, events: ['change', 'expandedRowsChange', 'resizeColumn'] },
      { type: 'AList', label: '列表', defaultProps: {}, events: [] },
      { type: 'ATag', label: '标签', defaultProps: { color: 'blue' }, text: 'Tag', events: ['click', 'close'] },
      { type: 'AAvatar', label: '头像', defaultProps: {}, events: ['click'] },
      { type: 'ABadge', label: '徽标', defaultProps: { count: 5 }, events: [] },
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
