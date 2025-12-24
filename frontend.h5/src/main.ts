import { createApp } from 'vue'
import { createPinia } from 'pinia'
import { SplashScreen } from '@capacitor/splash-screen';
import App from './App.vue'
import router from './router'

// Vant styles
import 'vant/es/toast/style';
import 'vant/es/dialog/style';
import 'vant/es/notify/style';
import 'vant/es/image-preview/style';

const app = createApp(App)

app.use(createPinia())
app.use(router)

router.isReady().then(() => {
  app.mount('#app');
  // 隐藏原生启动页，由 Vue 启动页接管
  SplashScreen.hide();
});
