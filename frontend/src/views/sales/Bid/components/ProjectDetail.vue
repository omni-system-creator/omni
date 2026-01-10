<template>
  <div class="project-detail">
    <div class="content-body">
      <a-tabs v-model:activeKey="activeTab" :tabBarStyle="{ margin: 0 }">
        <a-tab-pane key="info" tab="基本信息">
          <a-card :bordered="false" title="项目基本信息">
            <template #extra>
              <a-button type="primary" ghost @click="handleEdit">
                <template #icon><EditOutlined /></template>
                编辑
              </a-button>
            </template>
            <a-descriptions bordered :column="2">
              <a-descriptions-item label="项目编号">{{ project?.code || '-' }}</a-descriptions-item>
              <a-descriptions-item label="项目名称">{{ project?.name || '-' }}</a-descriptions-item>
              <a-descriptions-item label="客户名称">{{ project?.customer || '-' }}</a-descriptions-item>
              <a-descriptions-item label="所属地区">{{ project?.region || '-' }}</a-descriptions-item>
              <a-descriptions-item label="项目类型">
                <a-tag v-if="project?.type" color="cyan">{{ getTypeName(project.type) }}</a-tag>
                <span v-else>-</span>
              </a-descriptions-item>
              <a-descriptions-item label="预算金额">{{ project?.budget || '-' }}</a-descriptions-item>
              <a-descriptions-item label="预计开标时间">{{ project?.bidTime ? dayjs(project.bidTime).format('YYYY-MM-DD HH:mm') : '-' }}</a-descriptions-item>
              <a-descriptions-item label="负责人">{{ project?.leader || '-' }}</a-descriptions-item>
              <a-descriptions-item label="投标状态">
                <a-tag color="blue">{{ project?.status || '进行中' }}</a-tag>
              </a-descriptions-item>
              <a-descriptions-item label="创建时间">{{ project?.createdAt ? dayjs(project.createdAt).format('YYYY-MM-DD') : '-' }}</a-descriptions-item>
              <a-descriptions-item label="项目背景" :span="2">
                {{ project?.description || '-' }}
              </a-descriptions-item>
            </a-descriptions>
          </a-card>
        </a-tab-pane>
        <a-tab-pane key="1" tab="招标文件分析">
          <TenderAnalysis :project-type="project?.type" />
        </a-tab-pane>
        <a-tab-pane key="2" tab="投标文件编写">
          <ProposalWriter />
        </a-tab-pane>
        <a-tab-pane key="3" tab="投标文件分析">
          <SupplierAnalysis />
        </a-tab-pane>
      </a-tabs>
    </div>

    <DraggableModal
      v-model:visible="editVisible"
      title="编辑项目信息"
      width="700px"
      :footer="true"
      @ok="handleSave"
    >
      <BidProjectForm
        ref="editFormRef"
        v-model="formState"
        :is-edit="true"
      />
    </DraggableModal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue';
import { EditOutlined } from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import dayjs from 'dayjs';
import TenderAnalysis from './AIAnalysis/TenderAnalysis.vue';
import ProposalWriter from './AIAnalysis/ProposalWriter.vue';
import SupplierAnalysis from './AIAnalysis/SupplierAnalysis.vue';
import DraggableModal from '@/components/DraggableModal.vue';
import BidProjectForm from './BidProjectForm.vue';
import { updateBidProject, type UpdateBidProjectDto } from '@/api/sales';
import { getDictDataByCode, type DictDataDto } from '@/api/dict';

const props = defineProps<{
  project: any
}>();

const emit = defineEmits(['refresh']);

const activeTab = ref('info');
const editVisible = ref(false);
const editFormRef = ref();
const tenderTypes = ref<DictDataDto[]>([]);

const formState = reactive({
  code: '',
  name: '',
  customer: '',
  region: undefined as string | undefined,
  type: undefined as string | undefined,
  budget: '',
  bidTime: undefined as any,
  leader: '',
  status: '',
  description: ''
});

onMounted(async () => {
  const res = await getDictDataByCode('sales_bid_type');
  tenderTypes.value = res;
});

const getTypeName = (value: string) => {
  const found = tenderTypes.value.find(item => item.value === value);
  return found ? found.label : value;
};

const handleEdit = () => {
  // Populate form with current data
  if (props.project) {
    Object.assign(formState, {
      code: props.project.code || '',
      name: props.project.name,
      customer: props.project.customer || '',
      region: props.project.region || undefined,
      type: props.project.type || undefined,
      budget: props.project.budget || '',
      bidTime: props.project.bidTime ? dayjs(props.project.bidTime) : undefined,
      leader: props.project.leader || '',
      status: props.project.status || '进行中',
      description: props.project.description || ''
    });
  }
  editVisible.value = true;
};

const handleSave = () => {
  editFormRef.value?.validate().then(async () => {
    try {
      const updateData: UpdateBidProjectDto = {
        name: formState.name,
        customer: formState.customer,
        region: formState.region,
        type: formState.type,
        budget: formState.budget,
        bidTime: formState.bidTime ? formState.bidTime.toISOString() : undefined,
        leader: formState.leader,
        status: formState.status,
        description: formState.description
      };
      
      await updateBidProject(props.project.id, updateData);
      message.success('更新成功');
      editVisible.value = false;
      emit('refresh');
    } catch (error) {
      console.error(error);
    }
  });
};
</script>

<style scoped>
.project-detail {
  background: #fff;
  padding: 0;
  height: 100%;
  display: flex;
  flex-direction: column;
}

.content-body {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

:deep(.ant-tabs) {
  height: 100%;
  display: flex;
  flex-direction: column;
}

:deep(.ant-tabs-content) {
  flex: 1;
  height: 100%;
}

:deep(.ant-tabs-tabpane) {
  height: 100%;
  overflow: auto;
}

:deep(.ant-tabs-tab) {
  padding: 12px 24px !important;
  margin: 0 !important;
}
</style>
