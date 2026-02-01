<template>
  <div class="ar-list">
    <SmartTable
      tableKey="finance_ar_list"
      :columns="columns"
      :data-source="data"
      rowKey="id"
      :loading="loading"
      :pagination="pagination"
      @change="handleTableChange"
      :scroll="{ x: 'max-content' }"
      style="height: 100%"
    >
      <template #toolbar>
        <div class="toolbar-wrapper">
          <div class="toolbar-left">
            <a-button type="primary" @click="openCreateModal">
              <template #icon><PlusOutlined /></template>
              新增应收单
            </a-button>
          </div>
          <div class="toolbar-right">
            <a-form layout="inline" class="flex-nowrap">
              <a-form-item label="客户">
                <a-input v-model:value="queryParam.customer" placeholder="请输入" />
              </a-form-item>
              <a-form-item label="状态">
                <a-select v-model:value="queryParam.status" placeholder="请选择" style="width: 120px">
                  <a-select-option value="">全部</a-select-option>
                  <a-select-option v-for="item in billStatusOptions" :key="item.value" :value="item.value">
                    {{ item.label }}
                  </a-select-option>
                </a-select>
              </a-form-item>
              <a-form-item>
                <a-space>
                  <a-button type="primary" @click="fetchData">查询</a-button>
                  <a-button @click="resetQuery">重置</a-button>
                </a-space>
              </a-form-item>
            </a-form>
          </div>
        </div>
      </template>

      <template #bodyCell="{ column, record, index }">
        <template v-if="column.key === 'sequence'">
          {{ ((pagination.current || 1) - 1) * (pagination.pageSize || 10) + index + 1 }}
        </template>
        <template v-if="column.key === 'amount'">
      <span>¥{{ record.amount.toLocaleString() }}</span>
    </template>
    <template v-if="column.key === 'description'">
      <a-tooltip v-if="record.description" :title="record.description">
        <span>{{ record.description }}</span>
      </a-tooltip>
    </template>
    <template v-if="column.key === 'status'">
          <a-tag :color="getStatusColor(record.status)">{{ getStatusText(record.status) }}</a-tag>
        </template>
        <template v-if="column.key === 'attachments'">
            <a-button v-if="record.attachments?.length" type="link" size="small" @click="showAttachments(record as FinanceApAr)">
              <template #icon><PaperClipOutlined /></template>
            </a-button>
        </template>
        <template v-if="column.key === 'action'">
          <a @click="handleDetail(record)">详情</a>
          <template v-if="record.status !== 2">
            <a-divider type="vertical" />
            <a-dropdown>
              <a class="ant-dropdown-link" @click.prevent>
                <MoreOutlined />
              </a>
              <template #overlay>
                <a-menu>
                  <a-menu-item>
                    <a @click="handleEdit(record)">编辑</a>
                  </a-menu-item>
                  <a-menu-item>
                    <a class="text-danger" @click="handleDelete(record)">删除</a>
                  </a-menu-item>
                  <a-menu-item>
                    <a>核销</a>
                  </a-menu-item>
                  <a-menu-item>
                    <a>催收</a>
                  </a-menu-item>
                </a-menu>
              </template>
            </a-dropdown>
          </template>
        </template>
      </template>
    </SmartTable>

    <!-- Create Modal -->
    <ArCreateModal v-model:visible="createVisible" :edit-data="editData" :disabled="isReadOnly" @success="fetchData" />

    <!-- Attachment Modal -->
    <a-modal
      v-model:visible="attachmentModalVisible"
      title="附件管理"
      :footer="null"
      width="600px"
    >
      <div class="mb-4">
        <a-upload
          :before-upload="handleUpload"
          :show-upload-list="false"
        >
          <a-button>
            <upload-outlined />
            上传附件
          </a-button>
        </a-upload>
      </div>
      <a-list item-layout="horizontal" :data-source="currentAttachments">
        <template #renderItem="{ item }">
          <a-list-item>
            <template #actions>
              <a :href="getKkViewUrl(item.filePath, item.fileName)" target="_blank">预览</a>
              <a :href="getDownloadUrl(item.id)" target="_blank">下载</a>
              <a @click="handleDeleteAttachment(item.id)" class="text-danger">删除</a>
            </template>
            <a-list-item-meta
              :description="`${item.size} - ${item.uploader} - ${dayjs(item.uploadDate).format('YYYY-MM-DD HH:mm:ss')}`"
            >
              <template #title>
                <a :href="getKkViewUrl(item.filePath, item.fileName)" target="_blank">{{ item.fileName }}</a>
              </template>
            </a-list-item-meta>
          </a-list-item>
        </template>
      </a-list>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, h } from 'vue';
import SmartTable from '@/components/SmartTable/index.vue';
import { PlusOutlined, PaperClipOutlined, UploadOutlined, MoreOutlined } from '@ant-design/icons-vue';
import { message, Modal } from 'ant-design-vue';
import type { ColumnType } from 'ant-design-vue/es/table';
import { getApArList, uploadAttachment, deleteAttachment, deleteApAr, type FinanceApAr, type FinanceAttachment } from '@/api/finance';
import { getDictDataByCode, type DictDataDto } from '@/api/dict';
import ArCreateModal from './ArCreateModal.vue';
import { getKkViewUrl } from '@/utils/kkview';
import dayjs from 'dayjs';

const loading = ref(false);
const data = ref<FinanceApAr[]>([]);
const billStatusOptions = ref<DictDataDto[]>([]);

const queryParam = reactive({
  customer: '',
  status: ''
});

const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0,
  showSizeChanger: true,
  showTotal: (total: number) => `共 ${total} 条`
});

const createVisible = ref(false);
  const editData = ref<FinanceApAr | undefined>(undefined);
  const isReadOnly = ref(false);
  
  const columns: ColumnType[] = [
  { title: '序号', key: 'sequence', width: 60, align: 'center' },
  { title: '单号', dataIndex: 'billNo', key: 'billNo' },
  { title: '科目', dataIndex: 'subjectName', key: 'subjectName' },
  { title: '客户', dataIndex: 'partnerName', key: 'partnerName' },
  { title: '金额', dataIndex: 'amount', key: 'amount', align: 'right' as const },
  { title: '到期日', dataIndex: 'dueDate', key: 'dueDate', customRender: ({ text }) => text ? text.substring(0, 10) : '' },
  { title: '逾期(天)', dataIndex: 'overdueDays', key: 'overdueDays', customRender: ({ text }) => text > 0 ? h('span', { class: 'text-danger' }, text) : text },
  { title: '备注', dataIndex: 'description', key: 'description', width: 200, ellipsis: true },
  { title: '状态', dataIndex: 'status', key: 'status' },
  { title: '附件', key: 'attachments', width: 80, align: 'center' },
  { title: '操作', key: 'action', width: 150 }
];

onMounted(async () => {
  const dicts = await getDictDataByCode('finance_bill_status');
  billStatusOptions.value = dicts || [];
  fetchData();
});

const getStatusText = (status: number) => {
  const item = billStatusOptions.value.find(x => x.value === status.toString());
  return item ? item.label : status.toString();
};

const getStatusColor = (status: number) => {
  const item = billStatusOptions.value.find(x => x.value === status.toString());
  return item ? item.listClass : 'default';
};

const fetchData = async () => {
  loading.value = true;
  try {
    const res = await getApArList({ type: 'AR', partner: queryParam.customer, status: queryParam.status || undefined });
    data.value = res || [];
    pagination.total = data.value.length;
    pagination.current = 1;
  } finally {
    loading.value = false;
  }
};

const handleTableChange = (pag: any) => {
  if (pag.current) pagination.current = pag.current;
  if (pag.pageSize) pagination.pageSize = pag.pageSize;
};

const resetQuery = () => {
  queryParam.customer = '';
  queryParam.status = '';
  fetchData();
};

const openCreateModal = () => {
  editData.value = undefined;
  isReadOnly.value = false;
  createVisible.value = true;
};

const handleDetail = (record: FinanceApAr) => {
  editData.value = record;
  isReadOnly.value = true;
  createVisible.value = true;
};

const handleEdit = (record: FinanceApAr) => {
  editData.value = record;
  isReadOnly.value = false;
  createVisible.value = true;
};

const handleDelete = (record: FinanceApAr) => {
  Modal.confirm({
    title: '确认删除?',
    content: `确定要删除应收单 ${record.billNo} 吗？`,
    onOk: async () => {
      try {
        await deleteApAr(record.id);
        message.success('删除成功');
        fetchData();
      } catch (error) {
        // error handled by request interceptor usually
      }
    }
  });
};

// Attachment Logic
const attachmentModalVisible = ref(false);
const currentAttachments = ref<FinanceAttachment[]>([]);
const currentTargetId = ref<number>(0);

const showAttachments = (record: FinanceApAr) => {
  currentAttachments.value = record.attachments || [];
  currentTargetId.value = record.id;
  attachmentModalVisible.value = true;
};

const handleUpload = async (file: File) => {
  try {
    const formData = new FormData();
    formData.append('file', file);
    formData.append('targetType', 'ApAr');
    formData.append('targetId', currentTargetId.value.toString());
    
    const res = await uploadAttachment(formData);
    if (res) {
      message.success('上传成功');
      currentAttachments.value.push(res);
      const item = data.value.find(x => x.id === currentTargetId.value);
      if (item) {
        if (!item.attachments) item.attachments = [];
        item.attachments.push(res);
      }
    }
    return false;
  } catch (error) {
    return false;
  }
};

const getDownloadUrl = (id: number) => {
  return `/api/finance/attachment/${id}/download`;
};

const handleDeleteAttachment = async (id: number) => {
  Modal.confirm({
    title: '确认删除附件?',
    onOk: async () => {
      await deleteAttachment(id);
      message.success('删除成功');
      currentAttachments.value = currentAttachments.value.filter(x => x.id !== id);
      const item = data.value.find(x => x.id === currentTargetId.value);
      if (item && item.attachments) {
        item.attachments = item.attachments.filter(x => x.id !== id);
      }
    }
  });
};
</script>

<style scoped>
.ar-list {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.toolbar-wrapper {
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
}
</style>
