<template>
  <a-drawer
    v-model:open="visible"
    title="合同详情"
    placement="right"
    width="85%"
    :body-style="{ paddingBottom: '80px' }"
    @close="onClose"
  >
    <!-- 顶部基本信息 -->
    <a-descriptions title="基本信息" bordered :column="3" size="small">
      <a-descriptions-item label="合同编号">{{ contract.contractNo }}</a-descriptions-item>
      <a-descriptions-item label="合同名称">{{ contract.contractName }}</a-descriptions-item>
      <a-descriptions-item label="状态">
        <a-tag :color="getStatusColor(contract.status)">{{ getStatusText(contract.status) }}</a-tag>
      </a-descriptions-item>
      <a-descriptions-item label="客户名称">{{ contract.customerName }}</a-descriptions-item>
      <a-descriptions-item label="签订时间">{{ contract.signDate }}</a-descriptions-item>
      <a-descriptions-item label="总金额">{{ contract.totalAmount }}</a-descriptions-item>
      <a-descriptions-item label="已收款">{{ contract.receivedAmount }}</a-descriptions-item>
      <a-descriptions-item label="最新收款时间">{{ contract.latestCollectionDate || '-' }}</a-descriptions-item>
      <a-descriptions-item label="备注" :span="3">{{ contract.remark }}</a-descriptions-item>
    </a-descriptions>

    <a-divider style="margin: 16px 0" />

    <!-- 详情标签页 -->
    <a-tabs v-model:activeKey="activeTab">
      <!-- 财务信息 -->
      <a-tab-pane key="financial" tab="财务信息">
        <div class="tab-content">
          <a-card title="收付款计划" size="small" style="margin-bottom: 16px">
            <a-table :columns="planColumns" :data-source="planData" size="small" :pagination="false" />
          </a-card>
          
          <a-card title="收付款记录" size="small" style="margin-bottom: 16px">
            <a-table :columns="recordColumns" :data-source="recordData" size="small" :pagination="false" />
          </a-card>

          <a-card title="发票记录" size="small">
            <a-table :columns="invoiceColumns" :data-source="invoiceData" size="small" :pagination="false" />
          </a-card>
        </div>
      </a-tab-pane>

      <!-- 执行记录 -->
      <a-tab-pane key="execution" tab="执行记录">
        <a-timeline mode="left" style="margin-top: 20px">
          <a-timeline-item color="green" label="2025-12-05">合同签订完成，状态变更为【执行中】</a-timeline-item>
          <a-timeline-item color="blue" label="2025-12-10">收到第一笔款项 20,000.00 元</a-timeline-item>
          <a-timeline-item color="blue" label="2025-12-12">项目启动会议召开</a-timeline-item>
          <a-timeline-item color="gray" label="2025-12-01">合同草稿创建</a-timeline-item>
        </a-timeline>
      </a-tab-pane>

      <!-- 联系人 -->
      <a-tab-pane key="contacts" tab="联系人">
        <a-table :columns="contactColumns" :data-source="contactData" size="small" :pagination="false" />
      </a-tab-pane>

      <!-- 附件 -->
      <a-tab-pane key="attachments" tab="附件">
        <a-list :grid="{ gutter: 16, column: 4 }" :data-source="attachmentData">
          <template #renderItem="{ item }">
            <a-list-item>
              <a-card :title="item.name" size="small">
                <template #extra><a href="#">下载</a></template>
                <div style="text-align: center; color: #999">
                  <file-text-outlined style="font-size: 32px; margin-bottom: 8px" />
                  <div>{{ item.size }}</div>
                  <div>{{ item.date }}</div>
                </div>
              </a-card>
            </a-list-item>
          </template>
        </a-list>
      </a-tab-pane>
    </a-tabs>

    <template #footer>
      <a-space style="float: right">
        <a-button @click="onClose">关闭</a-button>
        <a-button type="primary">编辑合同</a-button>
      </a-space>
    </template>
  </a-drawer>
</template>

<script lang="ts" setup>
import { ref, computed } from 'vue';
import { FileTextOutlined } from '@ant-design/icons-vue';
import type { ContractDetailDto } from '@/api/contract';

const props = defineProps<{
  open: boolean;
  contractData: ContractDetailDto | null;
}>();

const emit = defineEmits(['update:open']);

const visible = computed({
  get: () => props.open,
  set: (val) => emit('update:open', val)
});

const onClose = () => {
  visible.value = false;
};

const activeTab = ref('financial');
// Mock empty data structure for safe access if contractData is null
const emptyContract: ContractDetailDto = {
  id: 0,
  contractNo: '',
  contractName: '',
  status: '',
  customerName: '',
  signDate: '',
  totalAmount: 0,
  receivedAmount: 0,
  paymentPlans: [],
  paymentRecords: [],
  invoices: [],
  contacts: [],
  attachments: []
};

const contract = computed(() => props.contractData || emptyContract);
const detailData = computed(() => props.contractData);

// Helpers
const getStatusColor = (status: string) => {
  switch (status) {
    case 'executing': return 'processing';
    case 'completed': return 'success';
    case 'abnormal': return 'error';
    default: return 'default';
  }
};

const getStatusText = (status: string) => {
  switch (status) {
    case 'executing': return '执行中';
    case 'completed': return '已完成';
    case 'abnormal': return '异常';
    default: return '未知';
  }
};

// Data Definitions
const planColumns = [
  { title: '期数', dataIndex: 'phase', key: 'phase', width: 80 },
  { title: '计划付款日期', dataIndex: 'dueDate', key: 'dueDate' },
  { title: '计划金额', dataIndex: 'amount', key: 'amount', align: 'right' },
  { title: '付款条件', dataIndex: 'condition', key: 'condition' },
  { title: '状态', dataIndex: 'status', key: 'status' },
];

const planData = computed(() => {
  if (!detailData.value?.paymentPlans) return [];
  return detailData.value.paymentPlans.map((p: any) => ({
    key: p.id.toString(),
    phase: p.phase,
    dueDate: p.dueDate ? new Date(p.dueDate).toISOString().split('T')[0] : '',
    amount: p.amount.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
    condition: p.condition,
    status: p.status === 'paid' ? '已支付' : '未支付' // Simple mapping
  }));
});

const recordColumns = [
  { title: '日期', dataIndex: 'date', key: 'date' },
  { title: '金额', dataIndex: 'amount', key: 'amount', align: 'right' },
  { title: '方式', dataIndex: 'method', key: 'method' },
  { title: '经办人', dataIndex: 'operator', key: 'operator' },
  { title: '备注', dataIndex: 'remark', key: 'remark' },
];

const recordData = computed(() => {
  if (!detailData.value?.paymentRecords) return [];
  return detailData.value.paymentRecords.map((r: any) => ({
    key: r.id.toString(),
    date: new Date(r.paymentDate).toISOString().split('T')[0],
    amount: r.amount.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
    method: r.method,
    operator: r.operator,
    remark: r.remark
  }));
});

const invoiceColumns = [
  { title: '发票号码', dataIndex: 'invoiceNo', key: 'invoiceNo' },
  { title: '开票日期', dataIndex: 'date', key: 'date' },
  { title: '金额', dataIndex: 'amount', key: 'amount', align: 'right' },
  { title: '类型', dataIndex: 'type', key: 'type' },
  { title: '状态', dataIndex: 'status', key: 'status' },
];

const invoiceData = computed(() => {
  if (!detailData.value?.invoices) return [];
  return detailData.value.invoices.map((i: any) => ({
    key: i.id.toString(),
    invoiceNo: i.invoiceNo,
    date: new Date(i.invoiceDate).toISOString().split('T')[0],
    amount: i.amount.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
    type: i.type,
    status: i.status // Map status text if needed
  }));
});

const contactColumns = [
  { title: '姓名', dataIndex: 'name', key: 'name' },
  { title: '角色', dataIndex: 'role', key: 'role' },
  { title: '电话', dataIndex: 'phone', key: 'phone' },
  { title: '邮箱', dataIndex: 'email', key: 'email' },
];

const contactData = computed(() => {
  if (!detailData.value?.contacts) return [];
  return detailData.value.contacts.map((c: any) => ({
    key: c.id.toString(),
    name: c.name,
    role: c.role,
    phone: c.phone,
    email: c.email
  }));
});

const attachmentData = computed(() => {
  if (!detailData.value?.attachments) return [];
  return detailData.value.attachments.map((a: any) => ({
    name: a.fileName,
    size: a.size || '-',
    date: new Date(a.uploadDate).toISOString().split('T')[0]
  }));
});
</script>

<style scoped>
.tab-content {
  padding: 8px 0;
}
</style>
