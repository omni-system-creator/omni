
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
    children: []
  },
  script: '',
  css: ''
};
