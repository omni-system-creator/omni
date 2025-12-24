<template>
  <div class="iframe-container">
    <iframe :src="url" frameborder="0" width="100%" height="100%"></iframe>
  </div>
</template>

<script lang="ts" setup>
import { useRouter } from "vue-router";

const router = useRouter();
const { currentRoute } = router;

const url = currentRoute.value.query.url + "";
</script>
<style lang="scss" scoped>
.iframe-container {
  flex: 1;
  display: flex;
  
  iframe {
    flex: 1;
  }
}
</style>
