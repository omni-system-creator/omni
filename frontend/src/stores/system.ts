import { defineStore } from 'pinia';
import { ref, computed } from 'vue';
import { getAllConfigs, getPublicConfigs, type SystemConfigDto } from '@/api/systemConfig';
import defaultLogo from '@/assets/logo.svg';

export const useSystemStore = defineStore('system', () => {
  const configs = ref<SystemConfigDto[]>([]);
  const loading = ref(false);

  const fetchConfigs = async () => {
    if (loading.value) return;
    loading.value = true;
    try {
      // Check if user is logged in
      const authData = localStorage.getItem('oms.auth');
      const hasToken = authData && JSON.parse(authData).token;
      
      if (hasToken) {
        configs.value = await getAllConfigs();
      } else {
        configs.value = await getPublicConfigs();
      }
    } catch (error) {
      console.error('Failed to fetch system configs:', error);
    } finally {
      loading.value = false;
    }
  };

  const getConfig = (key: string) => {
    return configs.value.find(c => c.key === key)?.value;
  };

  const systemName = computed(() => getConfig('SystemName') || '综合信息管理系统');
  const systemLogo = computed(() => {
    const logo = getConfig('SystemLogo');
    if (logo && typeof logo === 'string') {
      if (!logo.startsWith('/') && !logo.startsWith('http') && !logo.startsWith('data:')) {
        return `/${logo}`;
      }
      return logo;
    }
    return defaultLogo;
  });

  return {
    configs,
    loading,
    fetchConfigs,
    getConfig,
    systemName,
    systemLogo
  };
});
