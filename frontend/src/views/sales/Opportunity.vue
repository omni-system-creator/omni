<template>
  <div class="page-container">
    <div class="action-header">
      <div class="left-actions">
        <a-radio-group v-model:value="viewMode" button-style="solid">
          <a-radio-button value="kanban"><AppstoreOutlined /> 看板</a-radio-button>
          <a-radio-button value="list"><BarsOutlined /> 列表</a-radio-button>
        </a-radio-group>
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
    <div v-else-if="viewMode === 'kanban'" class="kanban-board">
      <div class="kanban-column" v-for="stage in stages" :key="stage.key">
        <div class="column-header">
          <span class="stage-name">{{ stage.name }}</span>
          <span class="stage-count">{{ getOpportunitiesByStage(stage.key).length }}</span>
        </div>
        <div class="column-content">
          <div class="opportunity-card" v-for="opp in getOpportunitiesByStage(stage.key)" :key="opp.id" @click="handleEdit(opp)">
            <div class="card-title">{{ opp.title }}</div>
            <div class="card-customer">{{ opp.customer }}</div>
            <div class="card-amount">¥ {{ opp.amount.toLocaleString() }}</div>
            <div class="card-footer">
              <a-avatar size="small" style="background-color: #87d068">{{ opp.owner[0] }}</a-avatar>
              <span class="date">{{ opp.date }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-else class="list-view">
      <a-table :columns="columns" :data-source="opportunities" row-key="id">
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'stage'">
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

    <a-modal v-model:open="modalVisible" :title="modalTitle" @ok="handleModalOk">
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
                  <a-select-option v-for="s in stages" :key="s.key" :value="s.key">{{s.name}}</a-select-option>
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
import { AppstoreOutlined, BarsOutlined, PlusOutlined } from '@ant-design/icons-vue';
import { message, Modal } from 'ant-design-vue';
import dayjs, { type Dayjs } from 'dayjs';
import { getOpportunities, createOpportunity, updateOpportunity, deleteOpportunity, type OpportunityDto, type CreateOpportunityDto } from '@/api/sales';

const viewMode = ref('kanban');
const opportunities = ref<OpportunityDto[]>([]);
const loading = ref(false);

const stages = [
  { key: 'new', name: '初步接洽', color: 'blue' },
  { key: 'proposition', name: '方案报价', color: 'cyan' },
  { key: 'negotiation', name: '商务谈判', color: 'orange' },
  { key: 'won', name: '赢单', color: 'green' },
  { key: 'lost', name: '输单', color: 'red' },
];

const loadData = async () => {
    loading.value = true;
    try {
        const res = await getOpportunities();
        opportunities.value = res.map(o => ({
            ...o,
            date: o.date ? dayjs(o.date).format('YYYY-MM-DD') : ''
        }));
    } catch (e) {
        console.error(e);
        message.error('获取商机列表失败');
    } finally {
        loading.value = false;
    }
};

onMounted(() => {
    loadData();
});


const columns: ColumnType[] = [
  { title: '商机名称', dataIndex: 'title', key: 'title' },
  { title: '客户', dataIndex: 'customer', key: 'customer' },
  { title: '预计金额', dataIndex: 'amount', key: 'amount' },
  { title: '阶段', dataIndex: 'stage', key: 'stage' },
  { title: '负责人', dataIndex: 'owner', key: 'owner' },
  { title: '预计成交日期', dataIndex: 'date', key: 'date' },
  { title: '操作', key: 'action', width: 150 },
];

const getOpportunitiesByStage = (stageKey: string) => {
  return opportunities.value.filter(o => o.stage === stageKey);
};

const getStageColor = (key: string) => {
  return stages.find(s => s.key === key)?.color || 'default';
};

const getStageName = (key: string) => {
  return stages.find(s => s.key === key)?.name || key;
};

// Modal Logic
const modalVisible = ref(false);
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
    stage: 'new',
    owner: '',
    date: undefined
});
let currentId = '';

const handleAdd = () => {
    modalTitle.value = '新建商机';
    currentId = '';
    Object.assign(formData, {
        title: '', customer: '', amount: 0, stage: 'new', owner: '', date: undefined
    });
    modalVisible.value = true;
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
  height: 100%;
  display: flex;
  flex-direction: column;
}

.action-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 24px;
}

.kanban-board {
  flex: 1;
  display: flex;
  gap: 16px;
  overflow-x: auto;
  padding-bottom: 16px;
}

.kanban-column {
  width: 280px;
  flex-shrink: 0;
  background: #f5f5f5;
  border-radius: 4px;
  display: flex;
  flex-direction: column;
  padding: 12px;
}

.column-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 12px;
  font-weight: bold;
  color: #333;
}

.column-content {
  flex: 1;
  overflow-y: auto;
}

.opportunity-card {
  background: #fff;
  padding: 12px;
  border-radius: 4px;
  margin-bottom: 12px;
  box-shadow: 0 1px 2px rgba(0,0,0,0.05);
  cursor: pointer;
  transition: all 0.3s;
}

.opportunity-card:hover {
  box-shadow: 0 4px 8px rgba(0,0,0,0.1);
}

.card-title {
  font-weight: 500;
  margin-bottom: 8px;
}

.card-customer {
  font-size: 12px;
  color: #666;
  margin-bottom: 4px;
}

.card-amount {
  font-weight: bold;
  color: #faad14;
  margin-bottom: 8px;
}

.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 12px;
  color: #999;
}
</style>