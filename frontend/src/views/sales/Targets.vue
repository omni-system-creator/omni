<template>
  <div class="page-container">
    <!-- 顶部筛选区 -->
    <a-card class="filter-section">
      <a-row :gutter="16">
        <a-col :span="5">
          <a-form-item label="时间维度" :label-col="{ span: 6 }" :wrapper-col="{ span: 18 }">
            <a-select v-model:value="filters.period" @change="handleFilterChange">
              <a-select-option v-for="item in periodOptions" :key="item.value" :value="item.value">
                {{ item.label }}
              </a-select-option>
            </a-select>
          </a-form-item>
        </a-col>
        <a-col :span="5">
          <a-form-item label="销售组" :label-col="{ span: 6 }" :wrapper-col="{ span: 18 }">
            <a-select v-model:value="filters.group" @change="handleFilterChange" allow-clear>
              <a-select-option value="">全部</a-select-option>
              <a-select-option v-for="item in groupOptions" :key="item.value" :value="item.value">
                {{ item.label }}
              </a-select-option>
            </a-select>
          </a-form-item>
        </a-col>
        <a-col :span="5">
          <a-form-item label="产品线" :label-col="{ span: 6 }" :wrapper-col="{ span: 18 }">
            <a-select v-model:value="filters.product" @change="handleFilterChange" allow-clear>
              <a-select-option value="">全部</a-select-option>
              <a-select-option v-for="item in productOptions" :key="item.value" :value="item.value">
                {{ item.label }}
              </a-select-option>
            </a-select>
          </a-form-item>
        </a-col>
        <a-col :span="5">
          <a-form-item label="区域" :label-col="{ span: 6 }" :wrapper-col="{ span: 18 }">
            <a-select v-model:value="filters.region" @change="handleFilterChange" allow-clear>
              <a-select-option value="">全部</a-select-option>
              <a-select-option v-for="item in regionOptions" :key="item.value" :value="item.value">
                {{ item.label }}
              </a-select-option>
            </a-select>
          </a-form-item>
        </a-col>
        <a-col :span="4">
          <a-form-item label="行业" :label-col="{ span: 6 }" :wrapper-col="{ span: 18 }">
            <a-select v-model:value="filters.industry" @change="handleFilterChange" allow-clear>
              <a-select-option value="">全部</a-select-option>
              <a-select-option v-for="item in industryOptions" :key="item.value" :value="item.value">
                {{ item.label }}
              </a-select-option>
            </a-select>
          </a-form-item>
        </a-col>
      </a-row>
    </a-card>

    <!-- 目标总览卡片 -->
    <a-row :gutter="16" style="margin-top: 16px">
      <a-col :span="6">
        <a-card class="full-height-card">
          <a-statistic title="当前周期目标总额" :value="overview.totalTarget" prefix="¥" :precision="2" />
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card class="full-height-card">
          <a-statistic title="已完成金额" :value="overview.completedAmount" prefix="¥" :precision="2" />
          <div :style="{ color: overview.progressRate >= 50 ? 'green' : 'red', marginTop: '8px' }">
            进度: {{ overview.progressRate }}%
          </div>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card class="full-height-card">
          <a-statistic title="完成率" :value="overview.progressRate" :precision="1" suffix="%" />
          <a-progress :percent="overview.progressRate" status="active" />
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card class="full-height-card">
          <a-statistic title="剩余天数" :value="overview.remainingDays" suffix="天" />
          <div :style="{ marginTop: '8px', color: '#999' }">
            截止: {{ overview.deadline }}
          </div>
        </a-card>
      </a-col>
    </a-row>

    <!-- 目标明细表格 -->
    <a-card title="目标明细" style="margin-top: 16px">
      <template #extra>
        <a-space>
          <a-button type="primary" @click="showTargetModal = true">设置目标</a-button>
          <a-button @click="exportTargets">导出报表</a-button>
        </a-space>
      </template>
      <a-table
        :columns="columns"
        :data-source="targetData"
        :pagination="pagination"
        :loading="loading"
        @change="handleTableChange"
        :scroll="{ x: 1200 }"
        row-key="id"
        :expandable="{
          expandedRowRender: (record: any) => renderChildren(record.children),
          rowExpandable: (record: any) => record.children && record.children.length > 0
        }"
      >
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'progress'">
            <a-progress :percent="record.progressRate" :status="getProgressStatus(record.progressRate)" />
          </template>
          <template v-if="column.key === 'status'">
            <a-tag :color="getStatusColor(record.status)">{{ getStatusText(record.status) }}</a-tag>
          </template>
          <template v-if="column.key === 'action'">
            <a-space>
              <a-button type="link" size="small" @click="handleEdit(record)">调整</a-button>
              <a-button type="link" size="small" @click="handleViewDetail(record)">详情</a-button>
            </a-space>
          </template>
        </template>
      </a-table>
    </a-card>

    <!-- 设置目标弹窗 -->
    <a-modal
      v-model:open="showTargetModal"
      title="设置销售目标"
      @ok="handleSetTarget"
      @cancel="showTargetModal = false"
      width="600px"
    >
      <a-form :model="targetForm" layout="vertical">
        <a-form-item label="时间维度" name="period" :rules="[{ required: true, message: '请选择时间维度' }]">
          <a-select v-model:value="targetForm.period">
            <a-select-option v-for="item in periodOptions" :key="item.value" :value="item.value">
              {{ item.label }}
            </a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="目标类型" name="targetType" :rules="[{ required: true, message: '请选择目标类型' }]">
          <a-select v-model:value="targetForm.targetType">
            <a-select-option v-for="item in targetTypeOptions" :key="item.value" :value="item.value">
              {{ item.label }}
            </a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="选择对象" name="targetId" v-if="targetForm.targetType !== 'total'">
          <a-select v-model:value="targetForm.targetId" allow-clear>
            <a-select-option v-for="item in getTargetOptions()" :key="item.value" :value="item.value">
              {{ item.label }}
            </a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="目标金额" name="targetAmount" :rules="[{ required: true, message: '请输入目标金额' }]">
          <a-input-number v-model:value="targetForm.targetAmount" :min="0" :precision="2" style="width: 100%" />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue';
import { message } from 'ant-design-vue';
import type { DictDataDto } from '@/api/dict';
import { getDictDataByCode } from '@/api/dict';
import { getSalesTargets } from '@/api/sales';

// 数据字典选项
const periodOptions = ref<DictDataDto[]>([]);
const groupOptions = ref<DictDataDto[]>([]);
const productOptions = ref<DictDataDto[]>([]);
const regionOptions = ref<DictDataDto[]>([]);
const industryOptions = ref<DictDataDto[]>([]);
const targetTypeOptions = ref<DictDataDto[]>([]);
const targetStatusOptions = ref<DictDataDto[]>([]);

// 筛选条件
const filters = reactive({
  period: 'quarter',
  group: '',
  product: '',
  region: '',
  industry: ''
});

// 目标总览
const overview = reactive({
  totalTarget: 0,
  completedAmount: 0,
  progressRate: 0,
  remainingDays: 0,
  deadline: ''
});

// 目标数据
const targetData = ref<any[]>([]);
const loading = ref(false);
const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0
});

// 设置目标弹窗
const showTargetModal = ref(false);
const targetForm = reactive({
  period: 'quarter',
  targetType: 'group',
  targetId: '',
  targetAmount: 0
});

// 表格列定义
const columns: ColumnType[] = [
  { title: '目标名称', dataIndex: 'targetName', key: 'targetName', fixed: 'left' as const, width: 180 },
  { title: '目标类型', dataIndex: 'targetType', key: 'targetType', width: 120 },
  { title: '目标金额', dataIndex: 'targetAmount', key: 'targetAmount', width: 120, align: 'right' as const },
  { title: '已完成金额', dataIndex: 'completedAmount', key: 'completedAmount', width: 120, align: 'right' as const },
  { title: '完成率', dataIndex: 'progressRate', key: 'progress', width: 150 },
  { title: '状态', dataIndex: 'status', key: 'status', width: 100 },
  { title: '操作', key: 'action', width: 150, fixed: 'right' as const }
];

// 加载数据字典
const loadDictOptions = async () => {
  try {
    const [
      period,
      groups,
      products,
      regions,
      industries,
      targetTypes,
      targetStatus
    ] = await Promise.all([
      getDictDataByCode('sales_target_period'),
      getDictDataByCode('sales_group'),
      getDictDataByCode('sales_product_line'),
      getDictDataByCode('sales_region'),
      getDictDataByCode('sales_industry'),
      getDictDataByCode('sales_target_type'),
      getDictDataByCode('sales_target_status')
    ]);

    periodOptions.value = period || [];
    groupOptions.value = groups || [];
    productOptions.value = products || [];
    regionOptions.value = regions || [];
    industryOptions.value = industries || [];
    targetTypeOptions.value = targetTypes || [];
    targetStatusOptions.value = targetStatus || [];
  } catch (e) {
    console.error('加载数据字典失败:', e);
    message.error('加载数据字典失败');
  }
};

// 加载目标数据
const loadTargetData = async () => {
  loading.value = true;
  try {
    const data = await getSalesTargets({
      ...filters,
      page: pagination.current,
      pageSize: pagination.pageSize
    });

    // 从API获取数据
    overview.totalTarget = data.overview?.totalTarget ?? 0;
    overview.completedAmount = data.overview?.completedAmount ?? 0;
    overview.progressRate = data.overview?.progressRate ?? 0;
    overview.remainingDays = data.overview?.remainingDays ?? 0;
    overview.deadline = data.overview?.deadline ?? '';

    targetData.value = data.items || [];
    pagination.total = data.total || 0;
  } catch (e) {
    console.error('加载目标数据失败:', e);
    message.error('加载目标数据失败');
  } finally {
    loading.value = false;
  }
};

// 筛选变化
const handleFilterChange = () => {
  pagination.current = 1;
  loadTargetData();
};

// 表格变化
const handleTableChange = (pag: any) => {
  pagination.current = pag.current;
  pagination.pageSize = pag.pageSize;
  loadTargetData();
};

// 渲染子目标
const renderChildren = (children: any[]) => {
  if (!children || children.length === 0) return '';
  return `
    <a-table
      :columns="columns"
      :data-source="children"
      :pagination="false"
      size="small"
    />
  `;
};

// 获取进度状态颜色
const getProgressStatus = (rate: number) => {
  if (rate >= 100) return 'success';
  if (rate >= 80) return 'normal';
  if (rate >= 50) return 'active';
  return 'exception';
};

// 获取状态颜色
const getStatusColor = (status: string) => {
  const colors: Record<string, string> = {
    draft: 'default',
    published: 'blue',
    in_progress: 'processing',
    completed: 'success',
    archived: 'default'
  };
  return colors[status] || 'default';
};

// 获取状态文本
const getStatusText = (status: string) => {
  const item = targetStatusOptions.value.find(d => d.value === status);
  return item?.label || status;
};

// 获取目标选项
const getTargetOptions = () => {
  const type = targetForm.targetType;
  switch (type) {
    case 'group':
      return groupOptions.value;
    case 'product':
      return productOptions.value;
    case 'region':
      return regionOptions.value;
    case 'industry':
      return industryOptions.value;
    default:
      return [];
  }
};

// 设置目标
const handleSetTarget = () => {
  message.success('目标设置成功');
  showTargetModal.value = false;
  loadTargetData();
};

// 编辑目标
const handleEdit = (_record: any) => {
  message.info('编辑功能待实现');
};

// 查看详情
const handleViewDetail = (_record: any) => {
  message.info('详情功能待实现');
};

// 导出报表
const exportTargets = () => {
  message.info('导出功能待实现');
};

onMounted(() => {
  loadDictOptions();
  loadTargetData();
});
</script>

<style scoped>
.page-container {
  padding: 16px;
  background: #f0f2f5;
  min-height: calc(100vh - 64px);
}

.filter-section {
  margin-bottom: 16px;
}

.filter-section :deep(.ant-form-item) {
  margin-bottom: 0;
}

.full-height-card {
  height: 100%;
}
</style>
