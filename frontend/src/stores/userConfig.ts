import { defineStore } from 'pinia';
import { ref } from 'vue';
import { userConfigApi, type UserConfigDto } from '@/api/userConfig';
import { message } from 'ant-design-vue';

export const useUserConfigStore = defineStore('userConfig', () => {
  const configs = ref<Record<string, any>>({});
  const loading = ref(false);

  // 加载所有配置（或指定前缀）
  const loadConfigs = async (prefix?: string) => {
    loading.value = true;
    try {
      const res = await userConfigApi.getConfigs(prefix);
      if (res && Array.isArray(res)) {
        res.forEach((item) => {
          try {
            // 尝试解析JSON，如果是简单字符串则保留
            configs.value[item.key] = item.value ? JSON.parse(item.value) : null;
          } catch (e) {
            configs.value[item.key] = item.value;
          }
        });
      }
    } catch (error) {
      console.error('Failed to load user configs:', error);
    } finally {
      loading.value = false;
    }
  };

  // 获取单个配置
  const getConfig = <T>(key: string, defaultValue?: T): T => {
    return (configs.value[key] as T) ?? defaultValue;
  };

  // 设置配置
  const setConfig = async (key: string, value: any, description?: string) => {
    try {
      const valueStr = typeof value === 'object' ? JSON.stringify(value) : String(value);
      await userConfigApi.setConfig({ key, value: valueStr, description });
      configs.value[key] = value; // Update local state immediately
    } catch (error) {
      console.error('Failed to save user config:', error);
      message.error('保存配置失败');
    }
  };

  // 删除配置
  const removeConfig = async (key: string) => {
    try {
      await userConfigApi.deleteConfig(key);
      delete configs.value[key];
    } catch (error) {
      console.error('Failed to delete user config:', error);
      message.error('删除配置失败');
    }
  };

  return {
    configs,
    loading,
    loadConfigs,
    getConfig,
    setConfig,
    removeConfig,
  };
});
