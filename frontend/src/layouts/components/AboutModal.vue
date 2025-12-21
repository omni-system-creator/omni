<template>
  <a-modal
    :open="open"
    title="关于系统"
    :footer="null"
    @update:open="emit('update:open', $event)"
  >
    <div style="text-align: center; padding: 20px 0;">
      <img src="@/assets/logo.svg" alt="Logo" style="width: 64px; height: 64px; margin-bottom: 16px;" />
      <h3>金兰®综合信息管理系统</h3>
      <p style="color: #999; margin-top: 24px;">©2025 Created by jinlan.info</p>
      <p style="color: #999;">Version 1.0.0</p>
    </div>
  </a-modal>
</template>

<script lang="ts" setup>
defineProps<{
  open: boolean;
}>();

const emit = defineEmits<{
  (e: 'update:open', value: boolean): void;
}>();
</script>
