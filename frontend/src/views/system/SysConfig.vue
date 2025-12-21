<template>
  <div class="sys-config-container">
    <a-tabs v-model:activeKey="activeTab">
      <a-tab-pane v-for="category in categories" :key="category" :tab="categoryMap[category] || category">
        <a-table
          :columns="columns"
          :data-source="getConfigsByCategory(category)"
          :pagination="false"
          row-key="id"
        >
          <template #bodyCell="{ column, record }">
            <template v-if="column.key === 'action'">
              <a @click="handleEdit(record)">编辑</a>
            </template>
          </template>
        </a-table>
      </a-tab-pane>
    </a-tabs>

    <!-- 编辑配置弹窗 -->
    <a-modal
      v-model:open="modalVisible"
      :title="'编辑配置 - ' + (currentConfig?.description || currentConfig?.key)"
      @ok="handleModalOk"
      :confirmLoading="saving"
    >
      <a-form layout="vertical" :model="formState" v-if="currentConfig">
        <a-form-item label="配置键名">
          <a-input :value="currentConfig.key" disabled />
        </a-form-item>
        <a-form-item label="配置说明">
          <a-input v-model:value="formState.description" />
        </a-form-item>
        <a-form-item label="配置值" required>
          <a-input
            v-if="currentConfig.key !== 'SessionTimeout' && currentConfig.key !== 'PasswordMinLength'"
            v-model:value="formState.value"
            :placeholder="'请输入' + (currentConfig.description || currentConfig.key)"
          />
          <a-input-number
            v-else
            v-model:value="formState.value"
            style="width: 100%"
            :min="1"
          />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted, computed, reactive } from 'vue';
import { message } from 'ant-design-vue';
import { getAllConfigs, updateConfig, type SystemConfigDto } from '@/api/systemConfig';

const configs = ref<SystemConfigDto[]>([]);
const activeTab = ref('Basic');

// 弹窗相关状态
const modalVisible = ref(false);
const saving = ref(false);
const currentConfig = ref<SystemConfigDto | null>(null);
const formState = reactive({
  value: '',
  description: ''
});

const columns = [
  {
    title: '配置项说明',
    dataIndex: 'description',
    key: 'description',
    width: '30%',
  },
  {
    title: '配置键名 (Key)',
    dataIndex: 'key',
    key: 'key',
    width: '20%',
  },
  {
    title: '配置值',
    dataIndex: 'value',
    key: 'value',
    width: '35%',
  },
  {
    title: '操作',
    key: 'action',
    width: '15%',
  },
];

const categoryMap: Record<string, string> = {
  'Basic': '基本设置',
  'Security': '安全设置',
  'Email': '邮件设置',
  'Other': '其他设置'
};

const categories = computed(() => {
  const cats = new Set(configs.value.map(c => c.category));
  return Array.from(cats);
});

const getConfigsByCategory = (category: string) => {
  return configs.value.filter(c => c.category === category);
};

const loadConfigs = async () => {
  try {
    const res = await getAllConfigs();
    configs.value = res;
    if (configs.value.length > 0 && !activeTab.value) {
      activeTab.value = configs.value[0]?.category || '';
    }
  } catch (error) {
    console.error(error);
  }
};

const handleEdit = (record: SystemConfigDto) => {
  currentConfig.value = record;
  formState.value = record.value;
  formState.description = record.description || '';
  modalVisible.value = true;
};

const handleModalOk = async () => {
  if (!currentConfig.value) return;
  
  saving.value = true;
  try {
    await updateConfig(currentConfig.value.id, {
      value: formState.value,
      description: formState.description
    });
    
    message.success('更新成功');
    modalVisible.value = false;
    await loadConfigs(); // 刷新数据
  } catch (error) {
    // 错误处理已在拦截器中
  } finally {
    saving.value = false;
  }
};

onMounted(() => {
  loadConfigs();
});
</script>

<style scoped>
.sys-config-container {
  padding: 24px;
}
</style>
