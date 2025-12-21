<template>
  <a-dropdown>
    <span class="action-item" style="display: flex; align-items: center; cursor: pointer; padding: 0 8px;">
      <a-badge :color="currentStatusColor" :text="statusOptions.find(s => s.value === userStatus)?.label" />
    </span>
    <template #overlay>
      <a-menu>
        <a-menu-item v-for="option in statusOptions" :key="option.value" @click="handleStatusChange(option.value)">
          <a-badge :status="option.color" :text="option.label" />
          <DynamicIcon v-if="userStatus === option.value" icon="ant-design:check-outlined" style="margin-left: 8px; font-size: 12px;" />
        </a-menu-item>
      </a-menu>
    </template>
  </a-dropdown>
</template>

<script lang="ts" setup>
import { ref, computed } from 'vue';
import { message } from 'ant-design-vue';
import { useUserStore } from '@/stores/user';
import { updateProfile } from '@/api/user';
import DynamicIcon from '@/components/DynamicIcon.vue';

const userStore = useUserStore();
const userStatus = ref(userStore.status || 'online');

const statusOptions = [
  { label: '在岗', value: 'online', color: 'success' },
  { label: '出差中', value: 'business', color: 'warning' },
  { label: '临时外出', value: 'out', color: 'processing' },
  { label: '休假中', value: 'leave', color: 'error' },
];

const handleStatusChange = async (status: string) => {
  try {
    await updateProfile({ status });
    userStatus.value = status;
    userStore.setUserInfo({
      username: userStore.username,
      nickname: userStore.nickname,
      avatar: userStore.avatar,
      status: status
    });
    message.success(`状态已切换为：${statusOptions.find(s => s.value === status)?.label}`);
  } catch (error) {
    console.error(error);
    message.error('状态更新失败');
  }
};

const currentStatusColor = computed(() => {
  const option = statusOptions.find(s => s.value === userStatus.value);
  switch (option?.color) {
    case 'success': return '#52c41a';
    case 'warning': return '#faad14';
    case 'processing': return '#1890ff';
    case 'error': return '#ff4d4f';
    default: return '#52c41a';
  }
});
</script>

<style scoped>
.action-item {
  display: flex;
  align-items: center;
  cursor: pointer;
  padding: 0 8px;
  transition: all 0.3s;
}
.action-item:hover {
  background: rgba(0, 0, 0, 0.025);
}
</style>
