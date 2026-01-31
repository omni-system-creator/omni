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
            <template v-if="column.key === 'global'">
              <template v-if="record.globalValue">
                <a-image v-if="record.type === ConfigType.Image" :src="record.globalValue" :width="50">
                  <template #previewMask>
                    <EyeOutlined />
                  </template>
                </a-image>
                <a v-else-if="record.type === ConfigType.File" :href="record.globalValue" target="_blank">下载文件</a>
                <span v-else-if="record.type === ConfigType.Boolean">{{ record.globalValue === 'true' ? '是' : '否' }}</span>
                <span v-else>{{ record.globalValue }}</span>
              </template>
              <span v-else>-</span>
            </template>
            <template v-if="column.key === 'org'">
              <template v-if="record.orgValue">
                <a-image v-if="record.type === ConfigType.Image" :src="record.orgValue" :width="50">
                  <template #previewMask>
                    <EyeOutlined />
                  </template>
                </a-image>
                <a v-else-if="record.type === ConfigType.File" :href="record.orgValue" target="_blank">下载文件</a>
                <span v-else-if="record.type === ConfigType.Boolean">{{ record.orgValue === 'true' ? '是' : '否' }}</span>
                <span v-else>{{ record.orgValue }}</span>
              </template>
              <span v-else>-</span>
            </template>
            <template v-if="column.key === 'action'">
              <a
                v-if="canEditConfig(record as SystemConfigDto)"
                @click="handleEdit(record as SystemConfigDto)"
                title="编辑"
              >
                <EditOutlined />
              </a>
              <span v-else style="color: #999;" title="仅查看">
                <EyeOutlined />
              </span>
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
          <a-input :value="currentConfig.key" readonly class="input-readonly" />
        </a-form-item>
        <a-form-item label="配置说明">
          <a-input v-model:value="formState.description" :readonly="!userStore.isAdmin" :class="{ 'input-readonly': !userStore.isAdmin }" />
        </a-form-item>
        <a-form-item label="全局配置值">
          <template v-if="globalConfig">
            <a-switch 
              v-if="globalConfig.type === ConfigType.Boolean"
              v-model:checked="formState.globalValue"
              checked-value="true"
              un-checked-value="false"
              :disabled="!canEditConfig(globalConfig as SystemConfigDto)"
            />
            <a-input-number
              v-else-if="globalConfig.type === ConfigType.Number"
              v-model:value="formState.globalValue"
              style="width: 100%"
              :readonly="!canEditConfig(globalConfig as SystemConfigDto)"
              :class="{ 'input-readonly': !canEditConfig(globalConfig as SystemConfigDto) }"
            />
            <a-textarea
              v-else-if="globalConfig.type === ConfigType.Text"
              v-model:value="formState.globalValue"
              :rows="4"
              :readonly="!canEditConfig(globalConfig as SystemConfigDto)"
              :class="{ 'input-readonly': !canEditConfig(globalConfig as SystemConfigDto) }"
            />
            <div v-else-if="globalConfig.type === ConfigType.Image">
              <a-upload
                v-model:file-list="globalFileList"
                name="file"
                list-type="picture-card"
                class="avatar-uploader"
                :show-upload-list="false"
                action="/api/systemconfig/upload"
                :headers="uploadHeaders"
                @change="handleGlobalUploadChange"
                :disabled="!canEditConfig(globalConfig as SystemConfigDto)"
              >
                <img v-if="formState.globalValue" :src="formState.globalValue" alt="avatar" style="width: 100%" />
                <div v-else>
                  <loading-outlined v-if="uploadLoading" />
                  <plus-outlined v-else />
                  <div class="ant-upload-text">Upload</div>
                </div>
              </a-upload>
            </div>
            <div v-else-if="globalConfig.type === ConfigType.File">
              <a-upload
                v-model:file-list="globalFileList"
                name="file"
                action="/api/systemconfig/upload"
                :headers="uploadHeaders"
                @change="handleGlobalUploadChange"
                :maxCount="1"
                :disabled="!canEditConfig(globalConfig as SystemConfigDto)"
              >
                <a-button>
                  <upload-outlined />
                  Click to Upload
                </a-button>
              </a-upload>
              <div v-if="formState.globalValue" style="margin-top: 8px">当前文件: {{ formState.globalValue }}</div>
            </div>
            <a-input
              v-else
              v-model:value="formState.globalValue"
              :placeholder="'请输入' + (globalConfig.description || globalConfig.key)"
              :readonly="!canEditConfig(globalConfig as SystemConfigDto)"
              :class="{ 'input-readonly': !canEditConfig(globalConfig as SystemConfigDto) }"
            />
          </template>
          <span v-else>-</span>
        </a-form-item>
        <a-form-item v-if="isOrgContext && currentConfig?.isOverridable" :label="`组织配置值 (${userStore.currentOrg?.name})`">
          <template v-if="orgConfig">
            <a-switch 
              v-if="orgConfig.type === ConfigType.Boolean"
              v-model:checked="formState.orgValue"
              checked-value="true"
              un-checked-value="false"
              :disabled="!canEditConfig(orgConfig as SystemConfigDto)"
            />
            <a-input-number
              v-else-if="orgConfig.type === ConfigType.Number"
              v-model:value="formState.orgValue"
              style="width: 100%"
              :readonly="!canEditConfig(orgConfig as SystemConfigDto)"
              :class="{ 'input-readonly': !canEditConfig(orgConfig as SystemConfigDto) }"
            />
            <a-textarea
              v-else-if="orgConfig.type === ConfigType.Text"
              v-model:value="formState.orgValue"
              :rows="4"
              :readonly="!canEditConfig(orgConfig as SystemConfigDto)"
              :class="{ 'input-readonly': !canEditConfig(orgConfig as SystemConfigDto) }"
            />
            <div v-else-if="orgConfig.type === ConfigType.Image">
              <a-upload
                v-model:file-list="orgFileList"
                name="file"
                list-type="picture-card"
                class="avatar-uploader"
                :show-upload-list="false"
                action="/api/systemconfig/upload"
                :headers="uploadHeaders"
                @change="handleOrgUploadChange"
                :disabled="!canEditConfig(orgConfig as SystemConfigDto)"
              >
                <img v-if="formState.orgValue" :src="formState.orgValue" alt="avatar" style="width: 100%" />
                <div v-else>
                  <loading-outlined v-if="uploadLoading" />
                  <plus-outlined v-else />
                  <div class="ant-upload-text">Upload</div>
                </div>
              </a-upload>
            </div>
            <div v-else-if="orgConfig.type === ConfigType.File">
              <a-upload
                v-model:file-list="orgFileList"
                name="file"
                action="/api/systemconfig/upload"
                :headers="uploadHeaders"
                @change="handleOrgUploadChange"
                :maxCount="1"
                :disabled="!canEditConfig(orgConfig as SystemConfigDto)"
              >
                <a-button>
                  <upload-outlined />
                  Click to Upload
                </a-button>
              </a-upload>
              <div v-if="formState.orgValue" style="margin-top: 8px">当前文件: {{ formState.orgValue }}</div>
            </div>
            <a-input
              v-else
              v-model:value="formState.orgValue"
              :placeholder="'请输入' + (orgConfig.description || orgConfig.key)"
              :readonly="!canEditConfig(orgConfig as SystemConfigDto)"
              :class="{ 'input-readonly': !canEditConfig(orgConfig as SystemConfigDto) }"
            />
            <div
              v-if="!userStore.isAdmin && !orgConfig.isOverridable"
              style="color: #ff4d4f; font-size: 12px; margin-top: 4px;"
            >
              该配置项不允许组织覆盖，仅使用全局配置
            </div>
          </template>
          <template v-else-if="userStore.isAdmin && globalConfig">
            <a-switch 
              v-if="globalConfig.type === ConfigType.Boolean"
              v-model:checked="formState.orgValue"
              checked-value="true"
              un-checked-value="false"
            />
            <a-input-number
              v-else-if="globalConfig.type === ConfigType.Number"
              v-model:value="formState.orgValue"
              style="width: 100%"
            />
            <a-textarea
              v-else-if="globalConfig.type === ConfigType.Text"
              v-model:value="formState.orgValue"
              :rows="4"
            />
            <div v-else-if="globalConfig.type === ConfigType.Image">
              <a-upload
                v-model:file-list="orgFileList"
                name="file"
                list-type="picture-card"
                class="avatar-uploader"
                :show-upload-list="false"
                action="/api/systemconfig/upload"
                :headers="uploadHeaders"
                @change="handleOrgUploadChange"
              >
                <img v-if="formState.orgValue" :src="formState.orgValue" alt="avatar" style="width: 100%" />
                <div v-else>
                  <loading-outlined v-if="uploadLoading" />
                  <plus-outlined v-else />
                  <div class="ant-upload-text">Upload</div>
                </div>
              </a-upload>
            </div>
            <div v-else-if="globalConfig.type === ConfigType.File">
              <a-upload
                v-model:file-list="orgFileList"
                name="file"
                action="/api/systemconfig/upload"
                :headers="uploadHeaders"
                @change="handleOrgUploadChange"
                :maxCount="1"
              >
                <a-button>
                  <upload-outlined />
                  Click to Upload
                </a-button>
              </a-upload>
              <div v-if="formState.orgValue" style="margin-top: 8px">当前文件: {{ formState.orgValue }}</div>
            </div>
            <a-input
              v-else
              v-model:value="formState.orgValue"
              :placeholder="'请输入' + (globalConfig.description || globalConfig.key)"
            />
          </template>
          <span v-else>-</span>
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted, computed, reactive, watch } from 'vue';
import { message } from 'ant-design-vue';

import { useUserStore } from '@/stores/user';
import { getAllConfigs, updateConfig, deleteConfig, type SystemConfigDto, ConfigType } from '@/api/systemConfig';
import { Modal } from 'ant-design-vue';
import { UploadOutlined, PlusOutlined, LoadingOutlined, EditOutlined, EyeOutlined } from '@ant-design/icons-vue';
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
const globalFileList = ref<any[]>([]);
const orgFileList = ref<any[]>([]);
const formState = reactive({
  globalValue: '',
  orgValue: '',
  description: ''
});

const canEditConfig = (config: SystemConfigDto | null) => {
  if (!config) return false;
  if (userStore.isAdmin) return true;
  if (!isOrgContext.value) return false;
  if (!config.orgId) return false;
  if (!config.isOverridable) return false;
  return true;
};

const globalConfig = computed<SystemConfigDto | null>(() => {
  if (!currentConfig.value) return null;
  const cfg = currentConfig.value;
  return {
    ...cfg,
    id: cfg.globalId,
    orgId: undefined,
    value: cfg.globalValue ?? '',
  } as SystemConfigDto;
});

const orgConfig = computed<SystemConfigDto | null>(() => {
  if (!currentConfig.value || !userStore.currentOrg) return null;
  const cfg = currentConfig.value;
  if (!cfg.orgConfigId) return null;
  return {
    ...cfg,
    id: cfg.orgConfigId,
    orgId: userStore.currentOrg.id,
    value: cfg.orgValue ?? cfg.value,
  } as SystemConfigDto;
});

const columns: ColumnType[] = [
  {
    title: '序号',
    key: 'index',
    width: 60,
    align: 'center',
    customRender: ({ index }) => index + 1,
  },
  {
    title: '配置项说明',
    dataIndex: 'description',
    key: 'description',
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
    width: 90,
    align: 'center',
  },
  {
    title: '全局',
    dataIndex: 'globalValue',
    key: 'global',
    width: '20%',
  },
  {
    title: '组织',
    dataIndex: 'orgValue',
    key: 'org',
    width: '20%',
  },
  {
    title: '操作',
    key: 'action',
    width: 90,
    align: 'center',
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
  formState.description = record.description || '';

  formState.globalValue = record.globalValue ?? '';
  formState.orgValue = record.orgValue ?? (record.globalValue ?? '');

  globalFileList.value = [];
  orgFileList.value = [];

  if (record.type === ConfigType.Image || record.type === ConfigType.File) {
    if (record.globalValue) {
      globalFileList.value = [{
        uid: '-1',
        name: record.globalValue.split('/').pop() || 'file',
        status: 'done',
        url: record.globalValue
      }];
    }

    if (record.orgValue) {
      orgFileList.value = [{
        uid: '-1',
        name: record.orgValue.split('/').pop() || 'file',
        status: 'done',
        url: record.orgValue
      }];
    }
  }

  modalVisible.value = true;
};

const handleGlobalUploadChange = (info: UploadChangeParam) => {
  if (info.file.status === 'uploading') {
    uploadLoading.value = true;
    return;
  }
  if (info.file.status === 'done') {
    uploadLoading.value = false;
    const url = info.file.response?.data?.url;
    if (url) {
      formState.globalValue = url;
      message.success(`${info.file.name} 上传成功`);
    }
  } else if (info.file.status === 'error') {
    uploadLoading.value = false;
    message.error(`${info.file.name} 上传失败`);
  }
  globalFileList.value = info.fileList;
};

const handleOrgUploadChange = (info: UploadChangeParam) => {
  if (info.file.status === 'uploading') {
    uploadLoading.value = true;
    return;
  }
  if (info.file.status === 'done') {
    uploadLoading.value = false;
    const url = info.file.response?.data?.url;
    if (url) {
      formState.orgValue = url;
      message.success(`${info.file.name} 上传成功`);
    }
  } else if (info.file.status === 'error') {
    uploadLoading.value = false;
    message.error(`${info.file.name} 上传失败`);
  }
  orgFileList.value = info.fileList;
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
    const tasks: Promise<any>[] = [];

 if (globalConfig.value && canEditConfig(globalConfig.value)) {
      // 如果全局值有变更，保存全局值
      tasks.push(updateConfig(globalConfig.value.id, {
        value: formState.globalValue,
        description: formState.description,
        updateGlobal: true
      }));
    }

    if (orgConfig.value && canEditConfig(orgConfig.value)) {
      tasks.push(updateConfig(orgConfig.value.id, {
        value: formState.orgValue,
        description: formState.description
      }));
    } else if (!orgConfig.value && currentConfig.value && userStore.isAdmin && isOrgContext.value && currentConfig.value.isOverridable) {
      tasks.push(updateConfig(currentConfig.value.globalId, {
        value: formState.orgValue,
        description: formState.description
      }));
    }

    if (tasks.length) {
      await Promise.all(tasks);
    }
    
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

watch(() => userStore.currentOrg?.id, () => {
  loadConfigs();
});
</script>

<style scoped>
.sys-config-container {
  padding: 10px;
}
.input-readonly {
  background-color: #f5f5f5;
  color: rgba(0, 0, 0, 0.85);
  cursor: not-allowed;
}
:deep(.input-readonly .ant-input-number-input),
:deep(.input-readonly .ant-input) {
  cursor: not-allowed;
  background-color: #f5f5f5;
  color: rgba(0, 0, 0, 0.85);
}
</style>