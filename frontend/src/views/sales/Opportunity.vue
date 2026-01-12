<template>
  <div class="page-container">
    <div class="action-header">
      <div class="search-area">
        <a-input-search
          v-model:value="searchText"
          placeholder="搜索商机名称/客户"
          style="width: 250px"
          @search="onSearch"
        />
        <a-select v-model:value="filterStage" style="width: 120px; margin-left: 8px" @change="onSearch">
          <a-select-option value="all">所有阶段</a-select-option>
          <a-select-option v-for="item in stageDictOptions" :key="item.value" :value="item.value">
            {{ item.label }}
          </a-select-option>
        </a-select>
      </div>
      <div class="right-actions">
        <a-button type="primary" @click="handleAdd">
          <template #icon><PlusOutlined /></template>
          新建商机
        </a-button>
      </div>
    </div>

    <div v-if="loading" style="text-align: center; padding: 50px;">
      <a-spin />
    </div>

    <div v-else class="list-view">
      <a-table 
        :columns="columns" 
        :data-source="opportunities" 
        :pagination="pagination"
        row-key="id"
        @change="handleTableChange"
      >
        <template #bodyCell="{ column, record, index }">
          <template v-if="column.key === 'index'">
            {{ (pagination.current - 1) * pagination.pageSize + index + 1 }}
          </template>
          <template v-else-if="column.key === 'stage'">
            <a-tag :color="getStageColor(record.stage)">{{ getStageName(record.stage) }}</a-tag>
          </template>
          <template v-else-if="column.key === 'action'">
             <a @click="handleEdit(record as OpportunityDto)">编辑</a>
             <a-divider type="vertical" />
             <a @click="handleDelete(record.id)" style="color: red">删除</a>
          </template>
        </template>
      </a-table>
    </div>

    <a-modal v-model:open="modalVisible" :wrap-class-name="wrapClassName" @ok="handleModalOk">
      <template #title>
        <div style="width: 100%; cursor: move" @mousedown="handleTitleMouseDown">{{ modalTitle }}</div>
      </template>
      <div v-if="!currentId" style="margin-bottom: 16px; text-align: right; padding-right: 40px;">
        <a-button type="dashed" size="small" @click="handleAiGenerate" :loading="isGenerating">
          <template #icon><ThunderboltOutlined /></template>
          AI 自动填充
        </a-button>
      </div>
      <a-form :model="formData" :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }">
          <a-form-item label="商机名称" required>
              <a-input v-model:value="formData.title" />
          </a-form-item>
          <a-form-item label="客户名称">
              <a-input v-model:value="formData.customer" />
          </a-form-item>
          <a-form-item label="预计金额">
              <a-input-number v-model:value="formData.amount" style="width: 100%" :min="0" />
          </a-form-item>
          <a-form-item label="阶段">
               <a-select v-model:value="formData.stage">
                  <a-select-option v-for="s in stageDictOptions" :key="s.value" :value="s.value">{{s.label}}</a-select-option>
               </a-select>
          </a-form-item>
          <a-form-item label="负责人">
               <a-input v-model:value="formData.owner" />
          </a-form-item>
          <a-form-item label="预计成交日期">
               <a-date-picker v-model:value="formData.date" style="width: 100%" />
          </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, reactive } from 'vue';
import { PlusOutlined, ThunderboltOutlined } from '@ant-design/icons-vue';
import { message, Modal } from 'ant-design-vue';
import dayjs, { type Dayjs } from 'dayjs';
import { getOpportunities, createOpportunity, updateOpportunity, deleteOpportunity, generateOpportunityData, type OpportunityDto, type CreateOpportunityDto } from '@/api/sales';
import { getDictDataByCode, type DictDataDto } from '@/api/dict';
import { useDraggableModal } from '@/hooks/useDraggableModal';

const opportunities = ref<OpportunityDto[]>([]);
const loading = ref(false);
const searchText = ref('');
const filterStage = ref('all');

const stageDictOptions = ref<DictDataDto[]>([]);
const stageColors: Record<string, string> = {
  discovery: 'blue',
  needs_analysis: 'cyan',
  proposal: 'purple',
  negotiation: 'orange',
  won: 'green',
  lost: 'red',
};

const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0,
  showSizeChanger: true,
  showQuickJumper: true,
  showTotal: (total: number) => `共 ${total} 条`,
});

const loadData = async () => {
    loading.value = true;
    try {
        const res = await getOpportunities({
            searchText: searchText.value,
            stage: filterStage.value === 'all' ? undefined : filterStage.value
        });
        opportunities.value = res.map(o => ({
            ...o,
            date: o.date ? dayjs(o.date).format('YYYY-MM-DD') : ''
        }));
        pagination.total = res.length; // Backend doesn't return total for list yet? Wait, GetOpportunities returns List<Dto>, not PagedResult.
        // The user asked for "bottom show total and per page".
        // But GetOpportunities returns a list, not paged result.
        // I should probably paginate on client side or update backend to return paged result.
        // Given the time, I'll paginate on client side for now, or just show all.
        // The user asked for "show total and per page", implying pagination.
        // If I use client side pagination:
        // Update Table :pagination="pagination"
        // And use slice in template or computed? Ant Design Vue Table handles client side pagination if data-source is full list.
        // So if I pass full list to Table and provide pagination config, it works.
        // Yes.
    } catch (e) {
        console.error(e);
        message.error('获取商机列表失败');
    } finally {
        loading.value = false;
    }
};

const onSearch = () => {
  loadData();
};

const handleTableChange = (pag: any) => {
  pagination.current = pag.current;
  pagination.pageSize = pag.pageSize;
};

const loadStageDict = async () => {
  try {
    stageDictOptions.value = await getDictDataByCode('sales_opportunity_stage');
  } catch (error) {
    console.error('加载商机阶段字典失败:', error);
  }
};

onMounted(() => {
    loadStageDict();
    loadData();
});


const columns: ColumnType[] = [
  { title: '序号', key: 'index', width: 80, align: 'center' },
  { title: '商机名称', dataIndex: 'title', key: 'title' },
  { title: '客户', dataIndex: 'customer', key: 'customer' },
  { title: '预计金额', dataIndex: 'amount', key: 'amount' },
  { title: '阶段', dataIndex: 'stage', key: 'stage' },
  { title: '负责人', dataIndex: 'owner', key: 'owner' },
  { title: '预计成交日期', dataIndex: 'date', key: 'date' },
  { title: '操作', key: 'action', width: 150 },
];

const getStageColor = (key: string) => {
  return stageColors[key] || 'default';
};

const getStageName = (key: string) => {
  return stageDictOptions.value.find(s => s.value === key)?.label || key;
};

// Modal Logic
const modalVisible = ref(false);
const { wrapClassName, handleTitleMouseDown } = useDraggableModal(modalVisible);
const modalTitle = ref('新建商机');

interface FormState {
    title: string;
    customer: string;
    amount: number;
    stage: string;
    owner: string;
    date: Dayjs | undefined;
}

const formData = reactive<FormState>({
    title: '',
    customer: '',
    amount: 0,
    stage: 'discovery',
    owner: '',
    date: undefined
});
let currentId = '';

const handleAdd = () => {
    modalTitle.value = '新建商机';
    currentId = '';

    const defaultStage = stageDictOptions.value.find(item => item.isDefault)?.value || 
                         (stageDictOptions.value.length > 0 ? stageDictOptions.value[0]?.value : 'discovery');

    Object.assign(formData, {
        title: '', customer: '', amount: 0, stage: defaultStage, owner: '', date: undefined
    });
    modalVisible.value = true;
};

const isGenerating = ref(false);
const handleAiGenerate = async () => {
    isGenerating.value = true;
    try {
        const data = await generateOpportunityData();
        Object.assign(formData, {
            title: data.title,
            customer: data.customer,
            amount: data.amount,
            stage: data.stage,
            owner: data.owner,
            date: data.date ? dayjs(data.date) : undefined
        });
        message.success('AI 数据生成成功');
    } catch (error) {
        console.error(error);
        message.error('AI 数据生成失败');
    } finally {
        isGenerating.value = false;
    }
};

const handleEdit = (record: OpportunityDto) => {
    modalTitle.value = '编辑商机';
    currentId = record.id;
    Object.assign(formData, {
        title: record.title,
        customer: record.customer,
        amount: record.amount,
        stage: record.stage,
        owner: record.owner,
        date: record.date ? dayjs(record.date) : undefined
    });
    modalVisible.value = true;
};

const handleDelete = (id: string) => {
    Modal.confirm({
        title: '确认删除',
        content: '确定要删除这个商机吗？',
        onOk: async () => {
            try {
                await deleteOpportunity(id);
                message.success('删除成功');
                loadData();
            } catch(e) {
                console.error(e);
                message.error('删除失败');
            }
        }
    });
};

const handleModalOk = async () => {
    if(!formData.title) {
        message.warning('请输入商机名称');
        return;
    }
    const payload: CreateOpportunityDto = {
        title: formData.title,
        customer: formData.customer,
        amount: Number(formData.amount),
        stage: formData.stage as any,
        owner: formData.owner,
        date: formData.date ? formData.date.format('YYYY-MM-DD') : ''
    };
    
    try {
        if(currentId) {
            await updateOpportunity(currentId, payload);
             message.success('更新成功');
        } else {
            await createOpportunity(payload);
             message.success('创建成功');
        }
        modalVisible.value = false;
        loadData();
    } catch(e) {
        console.error(e);
        message.error('保存失败');
    }
};
</script>

<style scoped>
.page-container {
  padding: 24px;
  background: #fff;
  min-height: 100%;
}

.action-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 24px;
}
</style>