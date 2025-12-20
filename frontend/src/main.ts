import { createApp } from 'vue'
import { createPinia } from 'pinia'
import Antd from 'ant-design-vue'
import 'ant-design-vue/dist/reset.css'
import './style.css'
import App from './App.vue'
import router from './router'

import { addCollection } from '@iconify/vue';
import { icons as antDesignIcons } from '@iconify-json/ant-design';
import { icons as mdiIcons } from '@iconify-json/mdi';
import { icons as riIcons } from '@iconify-json/ri';
import { icons as carbonIcons } from '@iconify-json/carbon';
import { icons as faIcons } from '@iconify-json/fa';

// Register icons locally
addCollection(antDesignIcons);
addCollection(mdiIcons);
addCollection(riIcons);
addCollection(carbonIcons);
addCollection(faIcons);

const app = createApp(App)

app.use(createPinia())
app.use(router)
app.use(Antd)

app.mount('#app')
