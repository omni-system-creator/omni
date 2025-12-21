export interface MenuItem {
  key: string;
  title: string;
  icon?: string;
  path?: string;
  component?: string;
  children?: MenuItem[];
}
