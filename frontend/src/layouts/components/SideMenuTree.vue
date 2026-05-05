<template>
  <template v-for="item in items" :key="item.key">
    <a-sub-menu v-if="item.children && item.children.length > 0" :key="item.key + '_sub'" popupClassName="sider-popup-menu">
      <template #title>
        <span>
          <DynamicIcon :icon="item.icon" v-if="item.icon" />
          <span>{{ item.title }}</span>
        </span>
      </template>
      <SideMenuTree :items="item.children" :on-item-click="onItemClick" />
    </a-sub-menu>
    <a-menu-item v-else :key="item.key" @click="onItemClick(item)">
      <DynamicIcon :icon="item.icon" v-if="item.icon" />
      <span>{{ item.title }}</span>
    </a-menu-item>
  </template>
</template>

<script setup lang="ts">
import DynamicIcon from '@/components/DynamicIcon.vue'
import type { MenuItem } from '@/types/menu'

defineProps<{
  items: readonly MenuItem[]
  onItemClick: (item: MenuItem) => void
}>()
</script>
