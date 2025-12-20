<template>
  <a-timeline>
    <a-timeline-item color="green">
      <p>运行成功 2023-10-25 01:05:00</p>
      <p>耗时: 45s, 处理数据: 12,500 条</p>
    </a-timeline-item>
    <a-timeline-item color="green">
      <p>运行成功 2023-10-24 01:05:00</p>
      <p>耗时: 42s, 处理数据: 11,200 条</p>
    </a-timeline-item>
    <a-timeline-item color="red">
      <p>运行失败 2023-10-23 01:05:00</p>
      <p>错误信息: Connection timeout to Source DB</p>
    </a-timeline-item>
  </a-timeline>
</template>

<script setup lang="ts">
defineProps<{
    editingId: string | null
}>();
</script>
