<script setup lang="ts">
import { NDialogProvider, NNotificationProvider, NMessageProvider } from 'naive-ui'
import { onMounted } from 'vue'
import { useProjectStore } from './stores/projectStore'
import Login from './components/Login.vue'
import ProjectList from './components/ProjectList.vue'
import ProjectDetail from './components/ProjectDetail.vue'

const store = useProjectStore()
// App.vue entry point

onMounted(() => {
  store.checkAuth()
  
  // Check if URL has project ID, if so, we might want to load it directly IF logged in
  const path = window.location.pathname
  const match = path.match(/\/project\/([^/]+)/)
  if (match && match[1] && store.isAuthenticated) {
    store.loadProjectFromServer(match[1])
  }
})
</script>

<template>
<n-message-provider>
  <n-notification-provider placement="top">
    <n-dialog-provider>
      <div class="app-container">
        <Login v-if="store.currentView === 'login'" />
        <ProjectList v-else-if="store.currentView === 'projectList'" />
        <ProjectDetail v-else />
      </div>
    </n-dialog-provider>
  </n-notification-provider>
</n-message-provider>
</template>

<style scoped>
.app-container {
  display: flex;
  flex-direction: column;
  width: 100vw;
  height: 100vh;
  overflow: hidden;
}
</style>
