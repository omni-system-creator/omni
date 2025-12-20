<template>
  <a-drawer
    v-model:open="visible"
    :title="title"
    width="80%"
    placement="right"
    @close="onClose"
    :bodyStyle="{ padding: 0, display: 'flex', flexDirection: 'column', height: '100vh' }"
  >
    <div class="drawer-content">
        <a-tabs v-model:activeKey="activeTab" class="custom-tabs">
            <a-tab-pane key="basic" tab="基础配置">
                <div class="tab-content">
                    <EtlBasicInfo :formState="formState" />
                </div>
            </a-tab-pane>
            <a-tab-pane key="design" tab="流程设计">
                <div class="tab-content designer-content">
                    <EtlDesigner :nodes="formState.nodes" :edges="formState.edges" />
                </div>
            </a-tab-pane>
            <a-tab-pane key="history" tab="运行历史">
                <div class="tab-content">
                    <EtlHistory :editingId="editingId" />
                </div>
            </a-tab-pane>
        </a-tabs>
    </div>
    <template #footer>
      <a-space style="float: right">
        <a-button @click="onClose">取消</a-button>
        <a-button type="primary" @click="handleSave">保存</a-button>
      </a-space>
    </template>
  </a-drawer>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue';
import EtlBasicInfo from './EtlBasicInfo.vue';
import EtlDesigner from './EtlDesigner.vue';
import EtlHistory from './EtlHistory.vue';

const props = defineProps<{
  visible: boolean;
  editingId: string | null;
  initialData?: any;
}>();

const emit = defineEmits(['update:visible', 'save']);

const activeTab = ref('basic');

// Form State
const formState = ref({
  name: '',
  cron: '',
  desc: '',
  notifications: [] as string[],
  nodes: [] as any[],
  edges: [] as any[]
});

const title = computed(() => props.editingId ? '编辑ETL任务' : '新建ETL任务');

const visible = computed({
  get: () => props.visible,
  set: (val) => emit('update:visible', val)
});

watch(() => props.visible, (val) => {
    if (val) {
        if (props.editingId && props.initialData) {
            // Edit Mode: Load data
            formState.value = JSON.parse(JSON.stringify(props.initialData));
            activeTab.value = 'basic';
        } else {
            // Create Mode: Reset
            resetForm();
            activeTab.value = 'basic';
        }
    }
});

const resetForm = () => {
    formState.value = {
        name: '',
        cron: '',
        desc: '',
        notifications: [],
        nodes: [],
        edges: []
    };
};

const onClose = () => {
    visible.value = false;
};

const handleSave = () => {
    // Validate?
    emit('save', {
        ...formState.value,
        id: props.editingId
    });
    onClose();
};
</script>

<style scoped>
.drawer-content {
    height: 100%;
    display: flex;
    flex-direction: column;
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

.tab-content {
    height: 100%;
    padding: 24px;
    overflow-y: auto;
}

.designer-content {
    padding: 0;
    overflow: hidden;
}
</style>
