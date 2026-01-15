<template>
  <a-card title="收付款记录" size="small" class="card-no-padding" style="margin-bottom: 16px">
    <template #extra>
      <a-button type="text" size="small" @click="openCreate">
        <template #icon><PlusOutlined /></template>
      </a-button>
    </template>
    <a-table
      :columns="columns"
      :data-source="tableData"
      size="small"
      :pagination="false"
    >
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'action'">
          <a-space>
            <a-button type="text" size="small" @click="openEdit(record)">
              <template #icon><EditOutlined /></template>
            </a-button>
            <a-popconfirm title="确定删除该记录吗？" @confirm="handleDelete(record)">
              <a-button type="text" danger size="small">
                <template #icon><DeleteOutlined /></template>
              </a-button>
            </a-popconfirm>
          </a-space>
        </template>
        <template v-else-if="column.key === 'voucher'">
          <a v-if="record.voucherUrl" :href="record.voucherUrl" target="_blank">查看</a>
          <span v-else>-</span>
        </template>
      </template>
    </a-table>

    <a-modal
      v-model:open="modalVisible"
      :title="currentRecord ? '编辑收付款记录' : '新增收付款记录'"
      @ok="handleOk"
      @cancel="handleCancel"
      :confirm-loading="saving"
      destroy-on-close
    >
      <a-form :model="formState" layout="vertical">
        <a-form-item label="日期">
          <a-date-picker v-model:value="formState.paymentDate" style="width: 100%" />
        </a-form-item>
        <a-form-item label="金额">
          <a-input-number v-model:value="formState.amount" :min="0" style="width: 100%" />
        </a-form-item>
        <a-form-item label="类型">
          <a-select v-model:value="formState.type">
            <a-select-option value="collection">收款</a-select-option>
            <a-select-option value="payment">付款</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="方式">
          <a-select v-model:value="formState.method" :options="paymentMethodOptions.map(d => ({ label: d.label, value: d.value }))" />
        </a-form-item>
        <a-form-item label="经办人">
          <a-input v-model:value="formState.operator" />
        </a-form-item>
        <a-form-item label="备注">
          <a-input v-model:value="formState.remark" />
        </a-form-item>
        <a-form-item label="凭证附件">
          <a-upload
            :file-list="voucherFileList"
            :before-upload="handleVoucherBeforeUpload"
            @remove="handleVoucherRemove"
            :max-count="1"
          >
            <a-button>
              选择文件
            </a-button>
          </a-upload>
        </a-form-item>
      </a-form>
    </a-modal>
  </a-card>
</template>

<script setup lang="ts">
import { computed, ref, watch, onMounted } from 'vue'
import { message } from 'ant-design-vue'
import { PlusOutlined, EditOutlined, DeleteOutlined } from '@ant-design/icons-vue'
import type { ColumnType } from 'ant-design-vue/es/table/interface'
import dayjs from 'dayjs'
import type { ContractDetailDto, ContractPaymentRecordDto } from '@/api/contract'
import { getDictDataByCode, type DictDataDto } from '@/api/dict'
import {
  createPaymentRecord,
  updatePaymentRecord,
  deletePaymentRecord,
  type CreateContractPaymentRecordDto,
  uploadPaymentRecordVoucher
} from '@/api/contract'

const props = defineProps<{
  contractId: number
  records: ContractDetailDto['paymentRecords']
}>()

const emit = defineEmits<{
  (e: 'changed'): void
}>()

const paymentMethodOptions = ref<DictDataDto[]>([])
const voucherFileList = ref<any[]>([])

onMounted(async () => {
  paymentMethodOptions.value = await getDictDataByCode('contract_payment_method') || []
})

const getMethodLabel = (val?: string) => {
  if (!val) return '-'
  const found = paymentMethodOptions.value.find(o => o.value === val)
  return found ? found.label : val
}

const getTypeLabel = (val?: string) => {
  if (val === 'collection') return '收款'
  if (val === 'payment') return '付款'
  return val || '-'
}

const columns: ColumnType[] = [
  { title: '日期', dataIndex: 'date', key: 'date' },
  { title: '类型', dataIndex: 'type', key: 'type' },
  { title: '金额', dataIndex: 'amount', key: 'amount', align: 'right' as const },
  { title: '方式', dataIndex: 'method', key: 'method' },
  { title: '凭证', dataIndex: 'voucher', key: 'voucher' },
  { title: '经办人', dataIndex: 'operator', key: 'operator' },
  { title: '备注', dataIndex: 'remark', key: 'remark' },
  { title: '操作', key: 'action', width: 80, align: 'center' as const }
]

const tableData = computed(() => {
  if (!props.records) return []
  return props.records.map(r => ({
    key: r.id.toString(),
    id: r.id,
    date: new Date(r.paymentDate).toISOString().split('T')[0],
    amount: r.amount.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
    type: getTypeLabel(r.type),
    method: getMethodLabel(r.method),
    voucherUrl: r.voucherFilePath,
    operator: r.operator,
    remark: r.remark
  }))
})

const modalVisible = ref(false)
const saving = ref(false)
const currentRecord = ref<ContractPaymentRecordDto | null>(null)

const formState = ref<{
  paymentDate: any
  amount: number
  type?: string
  method?: string
  operator?: string
  remark?: string
}>({
  paymentDate: null,
  amount: 0,
  type: 'collection',
  method: undefined,
  operator: '',
  remark: ''
})

watch(
  () => modalVisible.value,
  val => {
    if (!val) {
      currentRecord.value = null
    }
  }
)

const resetForm = () => {
  formState.value = {
    paymentDate: null,
    amount: 0,
    type: 'collection',
    method: '',
    operator: '',
    remark: ''
  }
  voucherFileList.value = []
}

const openCreate = () => {
  resetForm()
  currentRecord.value = null
  modalVisible.value = true
}

const openEdit = (record: any) => {
  const target = props.records.find(r => r.id === record.id)
  if (!target) return
  currentRecord.value = target
  formState.value = {
    paymentDate: target.paymentDate ? dayjs(target.paymentDate) : null,
    amount: target.amount,
    type: target.type,
    method: target.method,
    operator: target.operator,
    remark: target.remark
  }
  voucherFileList.value = target.voucherFilePath
    ? [
        {
          uid: String(target.id),
          name: target.voucherFileName || '凭证附件',
          status: 'done',
          url: target.voucherFilePath
        }
      ]
    : []
  modalVisible.value = true
}

const handleCancel = () => {
  modalVisible.value = false
}

const handleVoucherBeforeUpload = (file: any) => {
  voucherFileList.value = [file]
  return false
}

const handleVoucherRemove = () => {
  voucherFileList.value = []
}

const handleOk = async () => {
  if (!formState.value.paymentDate || formState.value.amount == null) {
    message.error('请填写日期和金额')
    return
  }

  const payload: CreateContractPaymentRecordDto = {
    paymentDate: dayjs(formState.value.paymentDate).format('YYYY-MM-DD'),
    amount: formState.value.amount,
    type: formState.value.type,
    method: formState.value.method,
    operator: formState.value.operator,
    remark: formState.value.remark
  }

  saving.value = true
  try {
    let recordId: number | null = null
    if (currentRecord.value) {
      const res = await updatePaymentRecord(currentRecord.value.id, payload)
      recordId = res.id
      message.success('更新成功')
    } else {
      const res = await createPaymentRecord(props.contractId, payload)
      recordId = res.id
      message.success('新增成功')
    }

    const fileItem = voucherFileList.value[0]
    if (recordId != null && fileItem) {
      const rawFile = (fileItem as any).originFileObj || (fileItem as any)
      if (rawFile instanceof File) {
        await uploadPaymentRecordVoucher(recordId, rawFile)
      }
    }

    modalVisible.value = false
    emit('changed')
  } catch (e) {
    message.error('保存失败')
  } finally {
    saving.value = false
  }
}

const handleDelete = async (record: any) => {
  saving.value = true
  try {
    await deletePaymentRecord(record.id)
    message.success('删除成功')
    emit('changed')
  } catch (e) {
    message.error('删除失败')
  } finally {
    saving.value = false
  }
}
</script>

<style scoped>
.card-no-padding :deep(.ant-card-body) {
  padding: 0;
}
</style>
