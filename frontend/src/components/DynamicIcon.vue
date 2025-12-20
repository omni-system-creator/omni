<template>
  <Icon v-if="icon" :icon="icon" class="anticon" />
</template>

<script setup lang="ts">
import { Icon } from '@iconify/vue';

defineProps<{
  icon: string;
}>();
</script>

<style scoped>
.anticon {
  display: inline-block;
  color: inherit;
  font-style: normal;
  line-height: 0;
  text-align: center;
  text-transform: none;
  vertical-align: -0.125em;
  text-rendering: optimizeLegibility;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
</style>
