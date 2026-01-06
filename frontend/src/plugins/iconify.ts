import { addCollection } from '@iconify/vue';
import AntDesignIcons from '@iconify-json/ant-design/icons.json';
import CarbonIcons from '@iconify-json/carbon/icons.json';
import FaIcons from '@iconify-json/fa/icons.json';
import MdiIcons from '@iconify-json/mdi/icons.json';
import RiIcons from '@iconify-json/ri/icons.json';
import SimpleIcons from '@iconify-json/simple-icons/icons.json';

export function setupIcons() {
  // 注册所有图标库到 Iconify，避免请求在线 API
  addCollection(AntDesignIcons);
  addCollection(CarbonIcons);
  addCollection(FaIcons);
  addCollection(MdiIcons);
  addCollection(RiIcons);
  addCollection(SimpleIcons);
}
