import { fileURLToPath, URL } from 'node:url'
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vite.dev/config/
export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  },
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:5016',
        changeOrigin: true,
        secure: false
      },
      '/uploads': {
        target: 'http://localhost:5016',
        changeOrigin: true,
        secure: false
      },
      '/bigview': {
        target: 'https://oms.jinlan.info',
        changeOrigin: true,
        secure: false
      }
    }
  },
  build: {
    chunkSizeWarningLimit: 10000,
    rollupOptions: {
      output: {
        manualChunks: {
          'ant-design-vue': ['ant-design-vue', '@ant-design/icons-vue'],
          'echarts': ['echarts'],
          'leafer-ui': ['leafer-ui', '@leafer-in/find', '@leafer-in/arrow'],
        }
      }
    }
  }
})
