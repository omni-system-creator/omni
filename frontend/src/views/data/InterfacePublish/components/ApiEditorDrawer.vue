<template>
  <a-drawer
    v-model:open="visible"
    :title="editingId ? (formState.name ? `${formState.name} ${formState.version}` : '编辑接口') : '发布新接口'"
    width="80%"
    placement="right"
    destroyOnClose
    @close="onClose"
    :bodyStyle="{ padding: 0, display: 'flex', flexDirection: 'column', height: '100vh' }"
  >
    <div class="drawer-content">
      <a-tabs v-model:activeKey="activeTab" class="custom-tabs">
        <template #tabBarExtraContent>
          <a-space>
            <a-button @click="handleCheck">
              <template #icon><CheckCircleOutlined /></template>
              接口检查
            </a-button>
            <a-button @click="handleDebug">
              <template #icon><BugOutlined /></template>
              在线调试
            </a-button>
            <a-button type="primary" @click="handleSave">
              <template #icon><CloudUploadOutlined /></template>
              保存发布
            </a-button>
          </a-space>
        </template>
        <a-tab-pane key="basic" tab="基本信息">
          <div class="tab-panel">
            <a-form layout="vertical" :model="formState" style="max-width: 800px; margin: 0 auto; padding-top: 24px;">
              <a-row :gutter="16">
                <a-col :span="12">
                  <a-form-item label="接口名称" required>
                    <a-input v-model:value="formState.name" placeholder="例如：查询用户详情" />
                  </a-form-item>
                </a-col>
                <a-col :span="12">
                  <a-form-item label="版本号" required>
                    <a-input v-model:value="formState.version" placeholder="v1.0.0" />
                  </a-form-item>
                </a-col>
              </a-row>
              <a-row :gutter="16">
                <a-col :span="8">
                  <a-form-item label="请求方法" required>
                    <a-select v-model:value="formState.method">
                      <a-select-option value="GET">GET</a-select-option>
                      <a-select-option value="POST">POST</a-select-option>
                      <a-select-option value="PUT">PUT</a-select-option>
                      <a-select-option value="DELETE">DELETE</a-select-option>
                    </a-select>
                  </a-form-item>
                </a-col>
                <a-col :span="16">
                  <a-form-item label="请求路径" required>
                    <a-input v-model:value="formState.path" addon-before="/api/" placeholder="user/detail" />
                  </a-form-item>
                </a-col>
              </a-row>
              <a-form-item label="接口描述">
                <a-textarea v-model:value="formState.description" :rows="4" />
              </a-form-item>

              <a-divider orientation="left">安全设置</a-divider>

              <a-form-item label="认证方式">
                <a-radio-group v-model:value="formState.auth.type">
                  <a-radio value="none">公开访问 (无需认证)</a-radio>
                  <a-radio value="apikey">API Key</a-radio>
                  <a-radio value="oauth2">OAuth 2.0</a-radio>
                </a-radio-group>
              </a-form-item>
              <div v-if="formState.auth.type === 'apikey'" style="background: #f5f5f5; padding: 16px; border-radius: 4px; margin-bottom: 24px;">
                <a-form-item label="Key Header Name" style="margin-bottom: 0;">
                  <a-input v-model:value="formState.auth.keyName" placeholder="X-API-KEY" />
                </a-form-item>
              </div>
            </a-form>
          </div>
        </a-tab-pane>

        <a-tab-pane key="flow" tab="接口编排">
          <div class="tab-panel" style="padding: 0; height: 100%;">
            <ApiFlowDesigner 
              ref="designerRef" 
              :initialData="formState.flow" 
            />
          </div>
        </a-tab-pane>
      </a-tabs>
    </div>

    <!-- Debug Modal -->
    <a-modal
      v-model:open="debugVisible"
      title="在线调试"
      width="800px"
      :footer="null"
    >
      <div style="padding: 24px; text-align: center;">
        <a-empty description="请先保存接口配置，然后在此进行调试" />
        <div style="margin-top: 16px; color: #999;">
          调试功能正在开发中...
        </div>
      </div>
    </a-modal>
  </a-drawer>
</template>

<script setup lang="ts">
import { ref, watch, computed } from 'vue';
import { message } from 'ant-design-vue';
import { 
  CheckCircleOutlined, 
  BugOutlined, 
  CloudUploadOutlined 
} from '@ant-design/icons-vue';
import ApiFlowDesigner from './ApiFlowDesigner.vue';

const props = defineProps<{
  visible: boolean;
  editingId: string | null;
  initialData: any;
}>();

const emit = defineEmits(['update:visible', 'save']);

const activeTab = ref('basic');
const designerRef = ref<any>(null);

const defaultFormState = {
  name: '',
  version: 'v1.0.0',
  method: 'GET',
  path: '',
  description: '',
  auth: {
    type: 'none',
    keyName: 'X-API-KEY'
  },
  flow: null
};

const formState = ref({ ...defaultFormState });

watch(
  () => props.visible,
  (val) => {
    if (val) {
      activeTab.value = 'basic';
      if (props.initialData) {
        formState.value = {
          ...defaultFormState,
          ...props.initialData,
          auth: {
            ...defaultFormState.auth,
            ...(props.initialData.auth || {})
          }
        };
      } else {
        // Reset form
        formState.value = { 
          ...defaultFormState,
          auth: { ...defaultFormState.auth }
        };
      }
    }
  }
);

const visible = computed({
  get: () => props.visible,
  set: (val) => emit('update:visible', val)
});

const debugVisible = ref(false);

const handleCheck = () => {
  // Validate basic info
  if (!formState.value.name || !formState.value.path) {
    message.error('请完善接口基本信息（名称、路径等）');
    activeTab.value = 'basic';
    return;
  }

  // Validate flow
  if (designerRef.value) {
    const nodes = designerRef.value.nodes;
    if (!nodes || nodes.length === 0) {
      message.warning('接口编排为空，请添加节点');
      return;
    }
    // Simple validation: Check if there is a Response node
    const hasResponse = nodes.some((n: any) => n.type === 'response');
    if (!hasResponse) {
      message.warning('流程中缺少 "发送响应" 节点');
      return;
    }
    
    message.success('接口配置检查通过');
  }
};

const handleDebug = () => {
  if (!formState.value.name) {
    message.warning('请先完善并保存接口信息');
    return;
  }
  debugVisible.value = true;
};

const onClose = () => {
  visible.value = false;
};

const handleSave = () => {
  const flowData = designerRef.value ? {
    nodes: designerRef.value.nodes,
    edges: designerRef.value.edges
  } : null;

  emit('save', {
    ...formState.value,
    flow: flowData
  });
};
</script>

<style scoped>
.drawer-content {
  height: 100%;
  display: flex;
  flex-direction: column;
  background: #fcfcfc;
}

.custom-tabs {
  flex: 1;
  display: flex;
  flex-direction: column;
}

:deep(.ant-tabs-nav) {
  padding: 0 24px;
  margin: 0;
}

:deep(.ant-tabs-content) {
  flex: 1;
  height: 100%;
}

.tab-panel {
  height: 100%;
  overflow-y: auto;
  padding: 24px;
}
</style>
