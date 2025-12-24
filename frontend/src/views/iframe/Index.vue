<template>
  <div class="iframe-placeholder">
    <!-- 
      This is a placeholder. The actual iframe is rendered in MainLayout.vue -> IframeView.vue
      to support KeepAlive functionality without reloading on tab switch.
    -->
  </div>
</template>

<script lang="ts" setup>
// No logic needed here as it's handled globally
</script>

<style scoped>
.iframe-placeholder {
  width: 100%;
  height: 100%;
}
</style>