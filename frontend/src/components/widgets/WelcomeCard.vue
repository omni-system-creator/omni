<template>
  <div class="widget-card welcome-card">
    <h3>欢迎回来，{{ userStore.nickname || userStore.username || 'Admin' }}</h3>
    <p>今天是 {{ currentDate }}，{{ greeting }}</p>
    <div style="margin-top: 10px;">
      <a-tag color="blue">V1.0.0</a-tag>
      <span style="font-size: 12px; color: #666;">系统运行正常</span>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref, onMounted } from 'vue';
import dayjs from 'dayjs';
import { getAiGreeting } from '@/api/dashboard';
import { useUserStore } from '@/stores/user';

const userStore = useUserStore();
const currentDate = computed(() => dayjs().format('YYYY年MM月DD日'));
const greeting = ref('祝您工作愉快！');

onMounted(async () => {
  try {
    const res = await getAiGreeting();
    if (res) {
      greeting.value = res as unknown as string;
    }
  } catch (error) {
    console.error('Failed to get AI greeting', error);
  }
});
</script>

<style scoped>
.widget-card {
  height: 100%;
  padding: 20px;
  background: #fff;
  border-radius: 8px;
  display: flex;
  flex-direction: column;
  justify-content: center;
}
.welcome-card {
  background: #fff;
  color: #333;
  border: 1px solid #f0f0f0;
}
h3 {
  color: #333;
  margin-bottom: 8px;
}
</style>
