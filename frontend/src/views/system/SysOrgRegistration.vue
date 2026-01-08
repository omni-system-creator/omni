<template>
  <div class="sys-org-registration-container">
    <a-card :bordered="false">
      <template #title>
        <a-space>
          <a-input-search
            v-model:value="searchText"
            placeholder="搜索组织名称/联系人/电话"
            style="width: 300px"
            @search="handleSearch"
            allow-clear
          />
          <a-select
            v-model:value="statusFilter"
            style="width: 120px"
            placeholder="状态筛选"
            @change="handleSearch"
          >
            <a-select-option value="">全部</a-select-option>
            <a-select-option value="pending">待审核</a-select-option>
            <a-select-option value="approved">已通过</a-select-option>
            <a-select-option value="rejected">已拒绝</a-select-option>
          </a-select>
        </a-space>
      </template>
      <template #extra>
        <a-button type="primary" @click="handleSearch">
          <template #icon><ReloadOutlined /></template>
          刷新
        </a-button>
      </template>

      <a-table
        :columns="columns"
        :data-source="data"
        :loading="loading"
        row-key="id"
        :pagination="pagination"
        @change="handleTableChange"
      >
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'status'">
            <a-tag :color="getStatusColor(record.status)">
              {{ getStatusText(record.status) }}
            </a-tag>
          </template>
          
          <template v-else-if="column.key === 'createdAt'">
            {{ formatDate(record.createdAt) }}
          </template>

          <template v-else-if="column.key === 'action'">
            <a-space>
              <a @click="handleView(record)">查看</a>
              <a-divider type="vertical" />
              <a-dropdown>
                <a class="ant-dropdown-link" @click.prevent>
                  <MoreOutlined />
                </a>
                <template #overlay>
                  <a-menu>
                    <template v-if="record.status === 'pending'">
                      <a-menu-item key="approve">
                        <a href="javascript:;" @click="handleApprove(record)" style="color: #52c41a">通过</a>
                      </a-menu-item>
                      <a-menu-item key="reject">
                        <a href="javascript:;" @click="handleReject(record)" style="color: #ff4d4f">拒绝</a>
                      </a-menu-item>
                    </template>
                    <a-menu-item key="delete">
                      <a href="javascript:;" @click="handleDelete(record)" style="color: #ff4d4f">删除</a>
                    </a-menu-item>
                  </a-menu>
                </template>
              </a-dropdown>
            </a-space>
          </template>
        </template>
      </a-table>
    </a-card>

    <!-- 详情弹窗 -->
    <a-drawer
      v-model:open="detailVisible"
      title="注册申请详情"
      width="600"
      placement="right"
    >
      <a-descriptions :column="1" bordered v-if="currentRecord">
        <a-descriptions-item label="组织名称">{{ currentRecord.orgName }}</a-descriptions-item>
        <a-descriptions-item label="组织简称">{{ currentRecord.orgShortName || '-' }}</a-descriptions-item>
        <a-descriptions-item label="字母缩写">{{ currentRecord.orgAbbr || '-' }}</a-descriptions-item>
        <a-descriptions-item label="证照编码">{{ currentRecord.licenseCode || '-' }}</a-descriptions-item>
        <a-descriptions-item label="联系人">{{ currentRecord.contactName }}</a-descriptions-item>
        <a-descriptions-item label="联系电话">{{ currentRecord.contactPhone }}</a-descriptions-item>
        <a-descriptions-item label="联系邮箱">{{ currentRecord.contactEmail || '-' }}</a-descriptions-item>
        <a-descriptions-item label="管理员账号">{{ currentRecord.adminUsername }}</a-descriptions-item>
        <a-descriptions-item label="申请时间">{{ formatDate(currentRecord.createdAt) }}</a-descriptions-item>
        <a-descriptions-item label="状态">
          <a-tag :color="getStatusColor(currentRecord.status)">
            {{ getStatusText(currentRecord.status) }}
          </a-tag>
        </a-descriptions-item>
        <a-descriptions-item label="拒绝原因" v-if="currentRecord.status === 'rejected'">
          {{ currentRecord.rejectReason }}
        </a-descriptions-item>
      </a-descriptions>

      <div class="mt-4" v-if="currentRecord">
        <div v-if="currentRecord.licenseFileUrl">
          <h3>营业执照</h3>
          <a-image
            :width="200"
            :src="currentRecord.licenseFileUrl"
          />
        </div>
        <div v-if="currentRecord.authLetterFileUrl" class="mt-4">
          <h3>授权书</h3>
          <a-image
            :width="200"
            :src="currentRecord.authLetterFileUrl"
          />
        </div>
      </div>
      
      <template #footer>
        <a-space>
          <template v-if="currentRecord && currentRecord.status === 'pending'">
            <a-button type="primary" @click="handleApprove(currentRecord)">通过</a-button>
            <a-button danger @click="handleReject(currentRecord)">拒绝</a-button>
          </template>
          <a-popconfirm
            v-if="currentRecord"
            title="确定要删除该申请记录吗？"
            ok-text="删除"
            cancel-text="取消"
            ok-type="danger"
            @confirm="handleDelete(currentRecord)"
          >
            <a-button danger>删除</a-button>
          </a-popconfirm>
        </a-space>
      </template>
    </a-drawer>

    <!-- 拒绝原因弹窗 -->
    <a-modal
      v-model:open="rejectModalVisible"
      title="拒绝申请"
      @ok="submitReject"
      :confirmLoading="rejectLoading"
    >
      <a-form :layout="'vertical'">
        <a-form-item label="拒绝原因" required>
          <a-textarea v-model:value="rejectReason" :rows="4" placeholder="请输入拒绝原因" />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, reactive, createVNode } from 'vue';
import { message, Modal } from 'ant-design-vue';
import { ReloadOutlined, MoreOutlined, ExclamationCircleOutlined } from '@ant-design/icons-vue';
import { getOrgRegistrationList, approveOrgRegistration, rejectOrgRegistration, deleteOrgRegistration, type SysOrgRegistration } from '@/api/system/orgRegistration';
import dayjs from 'dayjs';

const searchText = ref('');
const statusFilter = ref('');
const loading = ref(false);
const data = ref<SysOrgRegistration[]>([]);
const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0,
  showSizeChanger: true,
  showTotal: (total: number) => `共 ${total} 条`,
});

const columns = [
  { title: '组织名称', dataIndex: 'orgName', key: 'orgName' },
  { title: '联系人', dataIndex: 'contactName', key: 'contactName' },
  { title: '联系电话', dataIndex: 'contactPhone', key: 'contactPhone' },
  { title: '申请时间', dataIndex: 'createdAt', key: 'createdAt' },
  { title: '状态', dataIndex: 'status', key: 'status' },
  { title: '操作', key: 'action', align: 'center' },
];

const detailVisible = ref(false);
const currentRecord = ref<any>(null);

const rejectModalVisible = ref(false);
const rejectReason = ref('');
const rejectLoading = ref(false);
const rejectId = ref<number | null>(null);

const loadData = async () => {
  loading.value = true;
  try {
    const res = await getOrgRegistrationList({
      page: pagination.current,
      pageSize: pagination.pageSize,
      keyword: searchText.value,
      status: statusFilter.value,
    });
    data.value = res.items;
    pagination.total = res.total;
  } catch (error) {
    console.error(error);
  } finally {
    loading.value = false;
  }
};

const handleSearch = () => {
  pagination.current = 1;
  loadData();
};

const handleTableChange = (pag: any) => {
  pagination.current = pag.current;
  pagination.pageSize = pag.pageSize;
  loadData();
};

const getStatusColor = (status: string) => {
  switch (status) {
    case 'pending': return 'orange';
    case 'approved': return 'green';
    case 'rejected': return 'red';
    default: return 'default';
  }
};

const getStatusText = (status: string) => {
  switch (status) {
    case 'pending': return '待审核';
    case 'approved': return '已通过';
    case 'rejected': return '已拒绝';
    default: return status;
  }
};

const formatDate = (date: string) => {
  return dayjs(date).format('YYYY-MM-DD HH:mm:ss');
};

const handleView = (record: any) => {
  currentRecord.value = record;
  detailVisible.value = true;
};

const handleApprove = (record: any) => {
  Modal.confirm({
    title: '确认通过',
    icon: createVNode(ExclamationCircleOutlined),
    content: '确定通过该申请吗？',
    onOk: async () => {
      try {
        await approveOrgRegistration(record.id);
        message.success('审核通过');
        detailVisible.value = false;
        loadData();
      } catch (error) {
        console.error(error);
      }
    },
  });
};

const handleReject = (record: any) => {
  rejectId.value = record.id;
  rejectReason.value = '';
  rejectModalVisible.value = true;
};

const submitReject = async () => {
  if (!rejectReason.value) {
    message.warning('请输入拒绝原因');
    return;
  }
  
  rejectLoading.value = true;
  try {
    await rejectOrgRegistration(rejectId.value!, rejectReason.value);
    message.success('已拒绝申请');
    rejectModalVisible.value = false;
    detailVisible.value = false;
    loadData();
  } catch (error) {
    console.error(error);
  } finally {
    rejectLoading.value = false;
  }
};

const handleDelete = (record: any) => {
  Modal.confirm({
    title: '确认删除',
    icon: createVNode(ExclamationCircleOutlined),
    content: '确定要删除该申请记录吗？此操作不可恢复。',
    okType: 'danger',
    onOk: async () => {
      try {
        await deleteOrgRegistration(record.id);
        message.success('删除成功');
        if (detailVisible.value && currentRecord.value?.id === record.id) {
          detailVisible.value = false;
        }
        loadData();
      } catch (error) {
        console.error(error);
      }
    },
  });
};

onMounted(() => {
  loadData();
});
</script>

<style scoped>
.sys-org-registration-container {
  padding: 10px;
  height: 100%;
}
.mt-4 {
  margin-top: 16px;
}
</style>
