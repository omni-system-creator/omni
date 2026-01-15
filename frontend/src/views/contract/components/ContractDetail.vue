<template>
  <a-drawer
    v-model:open="visible"
    title="合同详情"
    placement="right"
    width="900"
    :body-style="{ paddingBottom: '80px' }"
    @close="onClose"
  >
    <!-- 顶部基本信息 -->
    <a-descriptions title="基本信息" bordered :column="3" size="small">
      <a-descriptions-item label="合同名称">{{ contract.contractName }}</a-descriptions-item>
      <a-descriptions-item label="合同编号">{{ contract.contractNo }}</a-descriptions-item>
      <a-descriptions-item label="状态">
        <a-tag :color="getStatusColor(contract.status)">{{ getStatusText(contract.status) }}</a-tag>
      </a-descriptions-item>
      <a-descriptions-item label="客户名称">
        {{ contract.partnerName || contract.customerName }}
      </a-descriptions-item>
      <a-descriptions-item label="签订时间">
        {{ contract.signDate ? contract.signDate.split('T')[0] : '-' }}
      </a-descriptions-item>
      <a-descriptions-item label="总金额">{{ contract.totalAmount }}</a-descriptions-item>
      <a-descriptions-item label="已收款">{{ formatAmount(receivedAmount) }}</a-descriptions-item>
      <a-descriptions-item label="最新收款时间">{{ latestCollectionDate || '-' }}</a-descriptions-item>
      <a-descriptions-item label="负责人" :span="3">{{ contract.manager || '-' }}</a-descriptions-item>
    </a-descriptions>

    <a-divider style="margin: 16px 0" />

    <a-tabs v-model:activeKey="activeTab">
      <!-- 合同信息 (Replaced basic info if needed, or keep it as summary and show full here) -->
      <a-tab-pane key="info" tab="合同信息">
        <a-descriptions bordered :column="2">
          <a-descriptions-item label="合同名称">{{ contract.contractName }}</a-descriptions-item>
          <a-descriptions-item label="合同编号">{{ contract.contractNo }}</a-descriptions-item>
          <a-descriptions-item label="合同类型">
            <a-tag :color="getContractTypeColor(contract.type)">
              {{ getContractTypeLabel(contract.type) }}
            </a-tag>
          </a-descriptions-item>
          <a-descriptions-item label="总价类型">
            <a-tag :color="getPricingTypeColor(contract.pricingType)">
              {{ getPricingTypeLabel(contract.pricingType) }}
            </a-tag>
          </a-descriptions-item>
          <a-descriptions-item label="客户名称">{{ contract.partnerName || contract.customerName }}</a-descriptions-item>
          <a-descriptions-item label="负责人">{{ contract.manager || '-' }}</a-descriptions-item>
          <a-descriptions-item label="签订日期">{{ contract.signDate ? contract.signDate.split('T')[0] : '-' }}</a-descriptions-item>
          <a-descriptions-item label="有效期限">
            {{ contract.startDate ? contract.startDate.split('T')[0] : '' }} ~ 
            {{ contract.endDate ? contract.endDate.split('T')[0] : '' }}
          </a-descriptions-item>
          <a-descriptions-item label="合同金额">{{ formatAmount(contract.totalAmount) }} {{ contract.currency }}</a-descriptions-item>
          <a-descriptions-item label="付款方式">
            <a-tag>{{ getPaymentMethodLabel(contract.paymentMethod) }}</a-tag>
          </a-descriptions-item>
          <a-descriptions-item label="合同状态">
            <a-tag :color="getStatusColor(contract.status)">
              {{ getStatusText(contract.status) }}
            </a-tag>
          </a-descriptions-item>
          <a-descriptions-item label="备注" :span="2">{{ contract.description || contract.remark }}</a-descriptions-item>
        </a-descriptions>
      </a-tab-pane>

      <!-- 账款管理 -->
      <a-tab-pane key="financial" tab="账款管理">
        <div class="tab-content">
          <PaymentPlanList
            :contract-id="contract.id"
            :plans="contract.paymentPlans"
            @changed="handlePaymentsChanged"
          />
          <PaymentRecordList
            :contract-id="contract.id"
            :records="contract.paymentRecords"
            @changed="handlePaymentsChanged"
          />
        </div>
      </a-tab-pane>

      <!-- 发票管理 -->
      <a-tab-pane key="invoices" tab="发票管理">
        <div class="tab-content">
          <InvoiceList
            :contract-id="contract.id"
            :invoices="contract.invoices"
            @changed="handleInvoicesChanged"
          />
        </div>
      </a-tab-pane>

      <!-- 关联合同 -->
      <a-tab-pane key="related" tab="关联合同">
        <RelatedContractList
          :contract-id="contract.id"
          :related-contracts="contract.relatedContracts || []"
          @changed="handleRelatedChanged"
          @open-contract="handleOpenRelatedContract"
        />
      </a-tab-pane>

      <!-- 附件 -->
      <a-tab-pane key="attachments" tab="附件">
        <ContractAttachmentList
          :contract-id="contract.id"
          :attachments="contract.attachments || []"
          @changed="handleAttachmentsChanged"
        />
      </a-tab-pane>
    </a-tabs>

    <template #footer>
      <a-space style="float: right">
        <a-button @click="onClose">关闭</a-button>
      </a-space>
    </template>
  </a-drawer>
</template>

<script lang="ts" setup>
import { ref, computed, onMounted } from 'vue'
import type { ContractDetailDto } from '@/api/contract'
import { getDictDataByCode, type DictDataDto } from '@/api/dict'
import PaymentPlanList from './PaymentPlanList.vue'
import PaymentRecordList from './PaymentRecordList.vue'
import InvoiceList from './InvoiceList.vue'
import RelatedContractList from './RelatedContractList.vue'
import ContractAttachmentList from './ContractAttachmentList.vue'

const props = defineProps<{
  open: boolean
  contractData: ContractDetailDto | null
}>()

const emit = defineEmits(['update:open', 'refresh', 'open-contract'])

const visible = computed({
  get: () => props.open,
  set: val => emit('update:open', val)
})

const onClose = () => {
  visible.value = false
}

const activeTab = ref('info')
// Mock empty data structure for safe access if contractData is null
const emptyContract: any = {
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
  relatedContracts: [],
  contacts: [],
  attachments: []
}

const contract = computed(() => props.contractData || emptyContract)

const receivedAmount = computed(() => {
  const records = contract.value.paymentRecords || []
  return records
    .filter((r: any) => r.type === 'collection')
    .reduce((sum: number, r: any) => sum + (r.amount || 0), 0)
})

const latestCollectionDate = computed(() => {
  const records = contract.value.paymentRecords || []
  const collectionRecords = records.filter((r: any) => r.type === 'collection' && r.paymentDate)
  if (!collectionRecords.length) return ''
  const latest = collectionRecords
    .map((r: any) => new Date(r.paymentDate as string).getTime())
    .reduce((max: number, t: number) => (t > max ? t : max), 0)
  return new Date(latest).toISOString().split('T')[0]
})

const contractTypeOptions = ref<DictDataDto[]>([])
const pricingTypeOptions = ref<DictDataDto[]>([])
const paymentMethodOptions = ref<DictDataDto[]>([])

const formatAmount = (value?: number) => {
  if (value == null) return '-'
  return value.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

onMounted(async () => {
  const [typeRes, pricingRes, paymentRes] = await Promise.all([
    getDictDataByCode('contract_type'),
    getDictDataByCode('contract_pricing_type'),
    getDictDataByCode('contract_payment_method')
  ])
  contractTypeOptions.value = typeRes || []
  pricingTypeOptions.value = pricingRes || []
  paymentMethodOptions.value = paymentRes || []
})

const getDictLabel = (options: DictDataDto[], value?: string) => {
  if (!value) return '-';
  const item = options.find(item => item.value === value);
  return item ? item.label : value;
};

const getContractTypeLabel = (value?: string) => getDictLabel(contractTypeOptions.value, value);
const getPricingTypeLabel = (value?: string) => getDictLabel(pricingTypeOptions.value, value);
const getPaymentMethodLabel = (value?: string) => getDictLabel(paymentMethodOptions.value, value);

const getContractTypeColor = (value?: string) => {
  if (value === 'sales') return 'blue';
  if (value === 'purchase') return 'orange';
  return 'default';
};

const getPricingTypeColor = (value?: string) => {
  if (value === 'fixed') return 'cyan';
  if (value === 'non_fixed') return 'purple';
  return 'cyan';
};

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

const handlePaymentsChanged = () => {
  emit('refresh');
};

const handleInvoicesChanged = () => {
  emit('refresh');
};

const handleRelatedChanged = () => {
  emit('refresh');
};

const handleOpenRelatedContract = (id: number) => {
  emit('open-contract', id);
};
const handleAttachmentsChanged = () => {
  emit('refresh');
};
</script>

<style scoped>
.tab-content {
  padding: 8px 0;
}
</style>
