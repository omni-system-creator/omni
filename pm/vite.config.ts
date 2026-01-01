import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vite.dev/config/
export default defineConfig({
  base: './',
  plugins: [vue()],
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:3000',
        changeOrigin: true
      },
      '/socket.io': {
        target: 'http://localhost:3000',
        ws: true,
        changeOrigin: true
      }
    }
  },
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          'leafer': ['leafer-ui', '@leafer-in/export', '@leafer-in/find'],
          'naive-ui': ['naive-ui'],
          'vue-vendor': ['vue', 'pinia', '@vueuse/core']
        }
      }
    },
    chunkSizeWarningLimit: 1000
  }
})
