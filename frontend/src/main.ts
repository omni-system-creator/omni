import { createApp } from 'vue'
import { createPinia } from 'pinia'
import Antd from 'ant-design-vue'
import 'ant-design-vue/dist/reset.css'
import './style.css'
import App from './App.vue'
import router from './router'
import { setupIcons } from './plugins/iconify'

const app = createApp(App)

setupIcons()

app.use(createPinia())
app.use(router)
app.use(Antd)

app.mount('#app')
