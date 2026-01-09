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
            <template v-if="column.key === 'type'">
              <a-tag color="blue">{{ configTypeMap[record.type] || '未知' }}</a-tag>
            </template>
            <template v-if="column.key === 'value'">
              <a-image v-if="record.type === ConfigType.Image" :src="record.value" :width="50" />
              <a v-else-if="record.type === ConfigType.File" :href="record.value" target="_blank">下载文件</a>
              <span v-else-if="record.type === ConfigType.Boolean">{{ record.value === 'true' ? '是' : '否' }}</span>
              <span v-else>{{ record.value }}</span>
            </template>
            <template v-if="column.key === 'action'">
              <a @click="handleEdit(record as SystemConfigDto)">编辑</a>
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
      <template #footer>
        <div style="display: flex; justify-content: space-between; align-items: center;">
          <div style="flex: 1; text-align: left;">
             <a-button 
              v-if="isOrgContext && currentConfig?.orgId" 
              danger 
              @click="handleReset"
              :loading="resetting"
            >
              恢复默认
            </a-button>
          </div>
          <div>
            <a-button @click="modalVisible = false">取消</a-button>
            <a-button type="primary" :loading="saving" @click="handleModalOk">确定</a-button>
          </div>
        </div>
      </template>
      <a-form layout="vertical" :model="formState" v-if="currentConfig">
        <a-form-item label="配置键名">
          <a-input :value="currentConfig.key" disabled />
        </a-form-item>
        <a-form-item label="配置说明">
          <a-input v-model:value="formState.description" />
        </a-form-item>
        <a-form-item label="配置值" required>
          <!-- Boolean -->
          <a-switch 
            v-if="currentConfig.type === ConfigType.Boolean"
            v-model:checked="formState.value"
            checked-value="true"
            un-checked-value="false"
            :disabled="isOrgContext && !currentConfig.orgId && !currentConfig.isOverridable"
          />

          <!-- Number -->
          <a-input-number
            v-else-if="currentConfig.type === ConfigType.Number"
            v-model:value="formState.value"
            style="width: 100%"
            :disabled="isOrgContext && !currentConfig.orgId && !currentConfig.isOverridable"
          />

          <!-- Text (Long) -->
          <a-textarea
             v-else-if="currentConfig.type === ConfigType.Text"
             v-model:value="formState.value"
             :rows="4"
             :disabled="isOrgContext && !currentConfig.orgId && !currentConfig.isOverridable"
          />

          <!-- Image -->
          <div v-else-if="currentConfig.type === ConfigType.Image">
             <a-upload
                v-model:file-list="fileList"
                name="file"
                list-type="picture-card"
                class="avatar-uploader"
                :show-upload-list="false"
                action="/api/systemconfig/upload"
                :headers="uploadHeaders"
                @change="handleUploadChange"
                :disabled="isOrgContext && !currentConfig.orgId && !currentConfig.isOverridable"
              >
                <img v-if="formState.value" :src="formState.value" alt="avatar" style="width: 100%" />
                <div v-else>
                  <loading-outlined v-if="uploadLoading" />
                  <plus-outlined v-else />
                  <div class="ant-upload-text">Upload</div>
                </div>
              </a-upload>
          </div>

          <!-- File -->
          <div v-else-if="currentConfig.type === ConfigType.File">
             <a-upload
                v-model:file-list="fileList"
                name="file"
                action="/api/systemconfig/upload"
                :headers="uploadHeaders"
                @change="handleUploadChange"
                :maxCount="1"
                :disabled="isOrgContext && !currentConfig.orgId && !currentConfig.isOverridable"
              >
                <a-button>
                  <upload-outlined />
                  Click to Upload
                </a-button>
              </a-upload>
              <div v-if="formState.value" style="margin-top: 8px">当前文件: {{ formState.value }}</div>
          </div>

          <!-- String (Default) -->
          <a-input
            v-else
            v-model:value="formState.value"
            :placeholder="'请输入' + (currentConfig.description || currentConfig.key)"
            :disabled="isOrgContext && !currentConfig.orgId && !currentConfig.isOverridable"
          />

          <div
            v-if="isOrgContext && !currentConfig.orgId && !currentConfig.isOverridable"
            style="color: #ff4d4f; font-size: 12px; margin-top: 4px;"
          >
            该配置项为全局强制配置，无法修改
          </div>
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted, computed, reactive } from 'vue';
import { message } from 'ant-design-vue';

import { useUserStore } from '@/stores/user';
import { getAllConfigs, updateConfig, deleteConfig, type SystemConfigDto, ConfigType } from '@/api/systemConfig';
import { Modal } from 'ant-design-vue';
import { UploadOutlined, PlusOutlined, LoadingOutlined } from '@ant-design/icons-vue';
import type { UploadChangeParam } from 'ant-design-vue';

const userStore = useUserStore();
const configs = ref<SystemConfigDto[]>([]);
const activeTab = ref('Basic');

const isOrgContext = computed(() => !!userStore.currentOrg);
const uploadHeaders = computed(() => ({
  Authorization: `Bearer ${userStore.token}`
}));

const configTypeMap: Record<number, string> = {
  [ConfigType.String]: '字符串',
  [ConfigType.Number]: '数值',
  [ConfigType.Boolean]: '布尔值',
  [ConfigType.Text]: '长文本',
  [ConfigType.Image]: '图片',
  [ConfigType.File]: '文件',
  [ConfigType.Json]: 'JSON'
};

// 弹窗相关状态
const modalVisible = ref(false);
const saving = ref(false);
const resetting = ref(false);
const uploadLoading = ref(false);
const currentConfig = ref<SystemConfigDto | null>(null);
const fileList = ref<any[]>([]);
const formState = reactive({
  value: '',
  description: ''
});

const columns: ColumnType[] = [
  {
    title: '配置项说明',
    dataIndex: 'description',
    key: 'description',
    width: '25%',
  },
  {
    title: '配置键名 (Key)',
    dataIndex: 'key',
    key: 'key',
    width: '15%',
  },
  {
    title: '类型',
    key: 'type',
    width: '10%',
  },
  {
    title: '配置值',
    dataIndex: 'value',
    key: 'value',
    width: '35%',
  },
  {
    title: '来源',
    key: 'source',
    width: '10%',
    customRender: ({ record }: any) => record.orgId ? '组织' : '全局'
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
  
  if ((record.type === ConfigType.Image || record.type === ConfigType.File) && record.value) {
    fileList.value = [{
      uid: '-1',
      name: record.value.split('/').pop() || 'file',
      status: 'done',
      url: record.value
    }];
  } else {
    fileList.value = [];
  }

  modalVisible.value = true;
};

const handleUploadChange = (info: UploadChangeParam) => {
  if (info.file.status === 'uploading') {
    uploadLoading.value = true;
    return;
  }
  if (info.file.status === 'done') {
    uploadLoading.value = false;
    const url = info.file.response?.data?.url;
    if (url) {
      formState.value = url;
      message.success(`${info.file.name} 上传成功`);
    }
  } else if (info.file.status === 'error') {
    uploadLoading.value = false;
    message.error(`${info.file.name} 上传失败`);
  }
  fileList.value = info.fileList;
};

const handleReset = () => {
  if (!currentConfig.value) return;
  
  Modal.confirm({
    title: '确认恢复默认？',
    content: '恢复默认将删除当前组织的自定义配置，使用系统全局默认值。',
    onOk: async () => {
      if (!currentConfig.value) return;
      resetting.value = true;
      try {
        await deleteConfig(currentConfig.value.id);
        message.success('已恢复默认配置');
        modalVisible.value = false;
        await loadConfigs();
      } catch (error) {
        console.error(error);
      } finally {
        resetting.value = false;
      }
    }
  });
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
  padding: 10px;
}
</style>
