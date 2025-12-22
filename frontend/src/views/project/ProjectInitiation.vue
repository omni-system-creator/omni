<template>
  <div class="project-initiation-container">
    <a-card :bordered="false">
      <template #title>
        <a-space>
          <a-input-search
            v-model:value="searchText"
            placeholder="搜索立项名称"
            style="width: 250px"
            @search="handleSearch"
          />
        </a-space>
      </template>
      <template #extra>
        <a-button type="primary" @click="handleAdd">
          <template #icon><PlusOutlined /></template>
          项目立项申请
        </a-button>
      </template>

      <a-table :columns="columns" :data-source="data" :pagination="pagination">
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'status'">
            <a-badge :status="getStatusBadge(record.status)" :text="record.status" />
          </template>
          <template v-if="column.key === 'action'">
            <a @click="viewDetail(record)">查看详情</a>
            <a-divider type="vertical" v-if="record.status === '待审批'" />
            <a-popconfirm title="确定撤回申请吗？" v-if="record.status === '待审批'" @confirm="handleWithdraw(record)">
              <a class="danger-text">撤回</a>
            </a-popconfirm>
          </template>
        </template>
      </a-table>
    </a-card>

    <a-modal
      v-model:open="visible"
      title="项目立项申请"
      width="700px"
      @ok="handleOk"
    >
      <a-form :model="formState" layout="vertical" ref="formRef" :rules="rules">
        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="项目名称" name="name">
              <a-input v-model:value="formState.name" placeholder="请输入项目名称" />
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="项目类型" name="type">
              <a-select v-model:value="formState.type" placeholder="请选择项目类型">
                <a-select-option value="dev">研发项目</a-select-option>
                <a-select-option value="impl">实施项目</a-select-option>
                <a-select-option value="internal">内部事务</a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
        </a-row>
        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="项目负责人" name="leader">
              <a-input v-model:value="formState.leader" placeholder="请输入负责人" />
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="预计周期" name="cycle">
               <a-range-picker v-model:value="formState.cycle" style="width: 100%" />
            </a-form-item>
          </a-col>
        </a-row>
        <a-form-item label="项目目标" name="target">
          <a-textarea v-model:value="formState.target" :rows="3" placeholder="简述项目目标" />
        </a-form-item>
        <a-form-item label="项目范围" name="scope">
          <a-textarea v-model:value="formState.scope" :rows="3" placeholder="界定项目范围" />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue';
import { PlusOutlined } from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';

const searchText = ref('');
const visible = ref(false);
const formRef = ref();

const columns = [
  { title: '立项名称', dataIndex: 'name', key: 'name' },
  { title: '类型', dataIndex: 'type', key: 'type', width: 100 },
  { title: '申请人', dataIndex: 'applicant', key: 'applicant', width: 100 },
  { title: '负责人', dataIndex: 'leader', key: 'leader', width: 100 },
  { title: '申请时间', dataIndex: 'applyTime', key: 'applyTime', width: 180 },
  { title: '审批状态', dataIndex: 'status', key: 'status', width: 120 },
  { title: '操作', key: 'action', width: 150 }
];

const data = ref([
  { id: 1, name: '供应链系统二期', type: '研发', applicant: '张三', leader: '张三', applyTime: '2024-12-20 10:00', status: '待审批' },
  { id: 2, name: '华东区销售培训', type: '内部', applicant: '李四', leader: '李四', applyTime: '2024-12-18 14:30', status: '已通过' },
  { id: 3, name: 'CRM系统采购', type: '实施', applicant: '王五', leader: '王五', applyTime: '2024-12-15 09:00', status: '已驳回' },
]);

const pagination = {
  total: 50,
  current: 1,
  pageSize: 10
};

const formState = reactive({
  name: '',
  type: undefined,
  leader: '',
  cycle: [],
  target: '',
  scope: ''
});

const rules = {
  name: [{ required: true, message: '请输入项目名称', trigger: 'blur' }],
  type: [{ required: true, message: '请选择项目类型', trigger: 'change' }],
  leader: [{ required: true, message: '请输入负责人', trigger: 'blur' }]
};

const getStatusBadge = (status: string) => {
  switch (status) {
    case '待审批': return 'processing';
    case '已通过': return 'success';
    case '已驳回': return 'error';
    default: return 'default';
  }
};

const handleSearch = () => {
  message.loading('查询中...');
};

const handleAdd = () => {
  visible.value = true;
};

const handleOk = () => {
  formRef.value.validate().then(() => {
    message.success('提交立项申请成功');
    visible.value = false;
  }).catch(() => {});
};

const handleWithdraw = (record: any) => {
  message.success(`已撤回立项申请：${record.name}`);
};

const viewDetail = (record: any) => {
  message.info(`查看详情：${record.name}`);
};
</script>

<style scoped>
.project-initiation-container {
  padding: 16px;
  flex: 1;
}
.danger-text {
  color: #ff4d4f;
}
</style>
