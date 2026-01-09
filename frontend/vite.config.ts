import { fileURLToPath, URL } from 'node:url'
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import AutoImport from 'unplugin-auto-import/vite'
import Components from 'unplugin-vue-components/vite'
import { AntDesignVueResolver } from 'unplugin-vue-components/resolvers'

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    vue(),
    AutoImport({
      imports: ['vue', 'vue-router', 'pinia'],
      dts: 'src/auto-imports.d.ts',
    }),
    Components({
      resolvers: [
        AntDesignVueResolver({
          importStyle: false,
        }),
      ],
      dts: 'src/components.d.ts',
    }),
  ],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url)),
      // Force single instance of leafer packages
      'leafer-ui': fileURLToPath(new URL('./node_modules/leafer-ui', import.meta.url)),
      '@leafer/core': fileURLToPath(new URL('./node_modules/@leafer/core', import.meta.url)),
      '@leafer/interface': fileURLToPath(new URL('./node_modules/@leafer/interface', import.meta.url)),
      '@leafer/partner': fileURLToPath(new URL('./node_modules/@leafer/partner', import.meta.url))
    }
  },
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:5016',
        changeOrigin: true,
        secure: false
      },
      '/hubs': {
        target: 'http://localhost:5016',
        changeOrigin: true,
        ws: true,
        secure: false
      },
      '/uploads': {
        target: 'http://localhost:5016',
        changeOrigin: true,
        secure: false
      },
      '/m/': {
        target: 'http://localhost:5174',
        changeOrigin: true,
        secure: false
      },
      '/bigview': {
        target: 'https://os.jinlan.info',
        changeOrigin: true,
        secure: false
      }
    }
  },
  build: {
    chunkSizeWarningLimit: 10000,
    rollupOptions: {
      onwarn(warning, warn) {
        if (warning.message.includes('contains an annotation that Rollup cannot interpret') && warning.id?.includes('signalr')) {
          return
        }
        warn(warning)
      },
      output: {
        manualChunks: {
          'echarts': ['echarts'],
          'leafer-ui': ['leafer-ui', '@leafer-in/find', '@leafer-in/arrow'],
          'vendor': ['vue', 'vue-router', 'pinia', 'axios', 'uuid'],
        }
      }
    }
  }
})
