<template>
  <layout-header>
    <template #left>
      <slot name="left">
        <project-layout-create :collapsed="false"></project-layout-create>
      </slot>
    </template>
    <template #center>
      <slot name="center"></slot>
    </template>
    <template #ri-left>
      <slot name="ri-left"></slot>
    </template>
    <template #ri-right>
      <go-user-info></go-user-info>
      <slot name="ri-right"></slot>
    </template>
  </layout-header>
</template>
<script setup lang="ts">
import { ProjectLayoutCreate } from '@/views/project/layout/components/ProjectLayoutCreate/index'
import { LayoutHeader } from '@/layout/components/LayoutHeader'
import { GoUserInfo } from '@/components/GoUserInfo'
</script>
