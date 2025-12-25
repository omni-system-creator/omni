import { defineConfig, loadEnv } from 'vite'
import vue from '@vitejs/plugin-vue'
import vueJsx from '@vitejs/plugin-vue-jsx'
import { resolve } from 'path'
import { OUTPUT_DIR, brotliSize, chunkSizeWarningLimit, terserOptions, rollupOptions } from './build/constant'
import viteCompression from 'vite-plugin-compression'
import { axiosPre } from './src/settings/httpSetting'
import { viteMockServe } from 'vite-plugin-mock'
import monacoEditorPlugin from 'vite-plugin-monaco-editor'

function pathResolve(dir: string) {
  return resolve(process.cwd(), '.', dir)
}

export default ({ mode }) => defineConfig({
  base: process.env.NODE_ENV === 'production' ? './' : '/',
  // 路径重定向
  resolve: {
    alias: [
      {
        find: /\/#\//,
        replacement: pathResolve('types')
      },
      {
        find: '@',
        replacement: pathResolve('src')
      },
      {
        find: 'vue-i18n',
        replacement: 'vue-i18n/dist/vue-i18n.cjs.js' //解决i8n警告
      }
    ],
    dedupe: ['vue']
  },
  // 全局 css 注册
  css: {
    preprocessorOptions: {
      scss: {
        javascriptEnabled: true,
        additionalData: `@import "src/styles/common/style.scss";`
      }
    }
  },
  // 开发服务器配置
  server: {
    host: true,
    open: true,
    port: 3000,
    proxy: {
      [axiosPre]: {
        // @ts-ignore
        // target: 'https://fwq.kp.psy.cool/prod-api', // 后端电脑 /prod-api
        // target: 'http://192.168.2.222:90/prod-api',  // 公司局域网环境
        //  target: 'https://bd-back.kp.psy.cool/prod-api',    // 公司互联网环境
        //  target: 'https://crrcdev.dingzhi.info/prod-api',    // 新互联网环境
        //  target: 'http://localhost:8080',
        // target: 'http://192.168.2.109:8080',
        changeOrigin: true,
        ws: true,
        // rewrite: (path) => path.replace(new RegExp(`^/api`), ''),
        // rewrite: (path) => path.replace(new RegExp(`^${axiosPre}`), ''),
      }
    }
  },
  plugins: [
    vue({
      template: {
        compilerOptions: {
          // 排除 iconify 图标影子组件编译报错
          isCustomElement: tag => tag.startsWith('iconify-icon')
        }
      }
    }),
    vueJsx(),
    monacoEditorPlugin({
      languageWorkers: ['editorWorkerService', 'typescript', 'json', 'html']
    }),
    viteMockServe({
      mockPath: '/src/api/mock',
      // 开发打包开关
      localEnabled: true,
      // 生产打包开关
      prodEnabled: true,
      // 打开后，可以读取 ts 文件模块。 请注意，打开后将无法监视.js 文件
      supportTs: true,
      // 监视文件更改
      watchFiles: true
    }),
    // 压缩
    viteCompression({
      verbose: true,
      disable: false,
      threshold: 10240,
      algorithm: 'gzip',
      ext: '.gz'
    })
  ],
  build: {
    target: 'es2020',
    outDir: OUTPUT_DIR,
    // minify: 'terser', // 如果需要用terser混淆，可打开这两行
    // terserOptions: terserOptions,
    rollupOptions: rollupOptions,
    reportCompressedSize: brotliSize,
    chunkSizeWarningLimit: chunkSizeWarningLimit
  }
})
