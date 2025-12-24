<script setup lang="ts">
// import {getByUsername} from '../../../api/modules/user'
import {componentSizeMap, useFormSize} from 'element-plus'
import {computed, onMounted, reactive} from "vue";
export interface UserTagProps {
  username: string,
  type?: 'success' | 'info' | 'warning' | 'danger'
  closable?: boolean
}

const $props = withDefaults(defineProps<UserTagProps>(), {
  closable: false,
  type: 'info'
})
const $emits = defineEmits<{
  (e: 'close', username: string): void
}>()

export interface UserInfo {
  username?: string
  avatar?: string
  name?: string
}

let userInfo = reactive<UserInfo>({
  username: undefined,
  avatar: undefined,
  name: undefined
})
onMounted(() => {
  if (!$props.username) {
    throw new Error('username is required')
  }
      userInfo.username = $props.username
      console.log($props);
    // debugger
})
const getBaseUrl = computed(() => {
  const url = import.meta.env.VITE_API_URL
  if (url.startsWith('http')) {
    return url
  } else {
    return window.location.origin + url
  }
})
const formSize = useFormSize()
const getComponentSize = computed(() => {
  return componentSizeMap[formSize.value || 'default'] - 12
})
const onClose = () => {
  $emits('close', $props.username)
}

</script>
<template>
 <n-tag round :closable="$props.closable" :type="type" :bordered="false" @close="onClose">
    <div class="flex-center" style="gap: 4px; grid-gap: 4px;">
      <!-- <n-avatar :size="getComponentSize" :src="userInfo.avatar">
        {{ (userInfo.name || username).charAt(0) }}
      </n-avatar> -->
      <span>{{ userInfo.name || username }}</span>
    </div>
  </n-tag>
</template>

<style scoped lang="scss">
:deep {
  .el-tag__content:only-child {
    margin-right: 4px;
  }
}
</style>
