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

const props = defineProps<{
  open: boolean;
  contractData: any;
}>();

const emit = defineEmits(['update:open']);

const visible = computed({
  get: () => props.open,
  set: (val) => emit('update:open', val),
});

const onClose = () => {
  visible.value = false;
};

const contract = computed(() => props.contractData || {});
const activeTab = ref('financial');

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

// Mock Data Definitions
const planColumns = [
  { title: '期数', dataIndex: 'phase', key: 'phase', width: 80 },
  { title: '计划付款日期', dataIndex: 'dueDate', key: 'dueDate' },
  { title: '计划金额', dataIndex: 'amount', key: 'amount', align: 'right' },
  { title: '付款条件', dataIndex: 'condition', key: 'condition' },
  { title: '状态', dataIndex: 'status', key: 'status' },
];

const planData = [
  { key: '1', phase: '第一期', dueDate: '2025-12-10', amount: '20,000.00', condition: '合同签订后5个工作日', status: '已支付' },
  { key: '2', phase: '第二期', dueDate: '2026-03-10', amount: '15,000.00', condition: '项目中期验收', status: '未支付' },
  { key: '3', phase: '第三期', dueDate: '2026-06-10', amount: '15,000.00', condition: '项目终验', status: '未支付' },
];

const recordColumns = [
  { title: '日期', dataIndex: 'date', key: 'date' },
  { title: '金额', dataIndex: 'amount', key: 'amount', align: 'right' },
  { title: '方式', dataIndex: 'method', key: 'method' },
  { title: '经办人', dataIndex: 'operator', key: 'operator' },
  { title: '备注', dataIndex: 'remark', key: 'remark' },
];

const recordData = [
  { key: '1', date: '2025-12-10', amount: '20,000.00', method: '银行转账', operator: '张三', remark: '首付款' },
];

const invoiceColumns = [
  { title: '发票号码', dataIndex: 'invoiceNo', key: 'invoiceNo' },
  { title: '开票日期', dataIndex: 'date', key: 'date' },
  { title: '金额', dataIndex: 'amount', key: 'amount', align: 'right' },
  { title: '类型', dataIndex: 'type', key: 'type' },
  { title: '状态', dataIndex: 'status', key: 'status' },
];

const invoiceData = [
  { key: '1', invoiceNo: 'FP20251210001', date: '2025-12-10', amount: '20,000.00', type: '增值税专用发票', status: '已开具' },
];

const contactColumns = [
  { title: '姓名', dataIndex: 'name', key: 'name' },
  { title: '角色', dataIndex: 'role', key: 'role' },
  { title: '电话', dataIndex: 'phone', key: 'phone' },
  { title: '邮箱', dataIndex: 'email', key: 'email' },
];

const contactData = [
  { key: '1', name: '李四', role: '客户项目经理', phone: '13800138000', email: 'lisi@yytech.com' },
  { key: '2', name: '王五', role: '财务对接人', phone: '13900139000', email: 'wangwu@yytech.com' },
];

const attachmentData = [
  { name: '合同扫描件.pdf', size: '2.5 MB', date: '2025-12-05' },
  { name: '技术协议.docx', size: '1.2 MB', date: '2025-12-05' },
  { name: '补充协议一.pdf', size: '0.8 MB', date: '2025-12-15' },
];

</script>

<style scoped>
.tab-content {
  padding: 8px 0;
}
</style>
