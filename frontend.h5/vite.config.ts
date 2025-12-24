import { fileURLToPath, URL } from 'node:url'
import { defineConfig, loadEnv } from 'vite'
import vue from '@vitejs/plugin-vue'
import Components from 'unplugin-vue-components/vite';
import { VantResolver } from 'unplugin-vue-components/resolvers';

export default defineConfig(({ mode }) => {
  // const env = loadEnv(mode, process.cwd(), '')
  const buildTarget = process.env.BUILD_TARGET
  console.log('Build Target:', buildTarget)
  
  return {
    define: {
      __APP_MODE__: JSON.stringify(buildTarget === 'app')
    },
    base: buildTarget === 'app' ? './' : '/m/',
    build: {
      outDir: buildTarget === 'app' ? 'dist_app' : 'dist',
    },
    plugins: [
      vue(),
      Components({
        resolvers: [VantResolver()],
      }),
    ],
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
        }
      }
    }
  }
})
