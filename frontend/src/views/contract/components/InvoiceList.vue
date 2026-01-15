<template>
  <a-card title="发票记录" size="small" class="card-no-padding" style="margin-bottom: 16px">
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
            <a-popconfirm title="确定删除该发票记录吗？" @confirm="handleDelete(record)">
              <a-button type="text" danger size="small">
                <template #icon><DeleteOutlined /></template>
              </a-button>
            </a-popconfirm>
          </a-space>
        </template>
        <template v-else-if="column.key === 'direction'">
          <a-tag v-if="record.direction">{{ record.direction }}</a-tag>
          <span v-else>-</span>
        </template>
        <template v-else-if="column.key === 'type'">
          <a-tag v-if="record.type">{{ record.type }}</a-tag>
          <span v-else>-</span>
        </template>
        <template v-else-if="column.key === 'status'">
          <a-tag v-if="record.status">{{ record.status }}</a-tag>
          <span v-else>-</span>
        </template>
        <template v-else-if="column.key === 'attachment'">
          <a v-if="record.attachmentUrl" :href="record.attachmentUrl" target="_blank">查看</a>
          <span v-else>-</span>
        </template>
      </template>
    </a-table>

    <a-modal
      v-model:open="modalVisible"
      :title="currentInvoice ? '编辑发票记录' : '新增发票记录'"
      @ok="handleOk"
      @cancel="handleCancel"
      :confirm-loading="saving"
      destroy-on-close
    >
      <a-form :model="formState" layout="vertical">
        <a-form-item label="收/开" required>
          <a-select v-model:value="formState.direction">
            <a-select-option value="input">收票</a-select-option>
            <a-select-option value="output">开票</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="发票号码" required>
          <a-input v-model:value="formState.invoiceNo" />
        </a-form-item>
        <a-form-item label="日期" required>
          <a-date-picker v-model:value="formState.invoiceDate" style="width: 100%" />
        </a-form-item>
        <a-form-item label="金额" required>
          <a-input-number v-model:value="formState.amount" :min="0" style="width: 100%" />
        </a-form-item>
        <a-form-item label="发票类型">
          <a-select v-model:value="formState.type" allow-clear>
            <a-select-option
              v-for="item in invoiceTypeOptions"
              :key="item.value"
              :value="item.value"
            >
              {{ item.label }}
            </a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="附件">
          <a-upload
            :file-list="attachmentFileList"
            :before-upload="handleAttachmentBeforeUpload"
            @remove="handleAttachmentRemove"
            :max-count="1"
          >
            <a-button>选择文件</a-button>
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
import { getDictDataByCode, type DictDataDto } from '@/api/dict'
import type { ContractDetailDto, ContractInvoiceDto } from '@/api/contract'
import {
  createInvoice,
  updateInvoice,
  deleteInvoice,
  uploadInvoiceAttachment,
  type CreateContractInvoiceDto
} from '@/api/contract'

const props = defineProps<{
  contractId: number
  invoices: ContractDetailDto['invoices']
}>()

const emit = defineEmits<{
  (e: 'changed'): void
}>()

const getDirectionLabel = (val?: string) => {
  if (val === 'input') return '收票'
  if (val === 'output') return '开票'
  return val || '-'
}

const columns: ColumnType[] = [
  { title: '发票号码', dataIndex: 'invoiceNo', key: 'invoiceNo' },
  { title: '日期', dataIndex: 'date', key: 'date' },
  { title: '收/开', dataIndex: 'direction', key: 'direction' },
  { title: '类型', dataIndex: 'type', key: 'type' },
  { title: '金额', dataIndex: 'amount', key: 'amount', align: 'center' as const },
  { title: '附件', dataIndex: 'attachment', key: 'attachment' },
  { title: '状态', dataIndex: 'status', key: 'status', align: 'center' as const },
  { title: '操作', key: 'action', width: 80, align: 'center' as const }
]

const invoiceTypeOptions = ref<DictDataDto[]>([])
const invoiceStatusOptions = ref<DictDataDto[]>([])

const getTypeLabel = (val?: string) => {
  if (!val) return '-'
  const found = invoiceTypeOptions.value.find(o => o.value === val)
  return found ? found.label : val
}

const getStatusLabel = (val?: string) => {
  if (!val) return '-'
  const found = invoiceStatusOptions.value.find(o => o.value === val)
  return found ? found.label : val
}

const tableData = computed(() => {
  if (!props.invoices) return []
  return props.invoices.map(i => ({
    key: i.id.toString(),
    id: i.id,
    invoiceNo: i.invoiceNo,
    date: new Date(i.invoiceDate).toISOString().split('T')[0],
    direction: getDirectionLabel(i.direction),
    type: getTypeLabel(i.type),
    amount: i.amount.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
    attachmentUrl: i.attachmentFilePath,
    status: getStatusLabel(i.status)
  }))
})

const modalVisible = ref(false)
const saving = ref(false)
const currentInvoice = ref<ContractInvoiceDto | null>(null)
const attachmentFileList = ref<any[]>([])

const formState = ref<{
  direction: string
  invoiceNo: string
  invoiceDate: any
  amount: number
  type?: string
}>({
  direction: 'output',
  invoiceNo: '',
  invoiceDate: null,
  amount: 0,
  type: undefined
})

onMounted(async () => {
  invoiceTypeOptions.value = (await getDictDataByCode('contract_invoice_type')) || []
  invoiceStatusOptions.value = (await getDictDataByCode('contract_invoice_state')) || []
})

watch(
  () => modalVisible.value,
  val => {
    if (!val) {
      currentInvoice.value = null
    }
  }
)

const resetForm = () => {
  formState.value = {
    direction: 'output',
    invoiceNo: '',
    invoiceDate: null,
    amount: 0,
    type: invoiceTypeOptions.value.find(i => i.isDefault)?.value || undefined
  }
  attachmentFileList.value = []
}

const openCreate = () => {
  resetForm()
  currentInvoice.value = null
  modalVisible.value = true
}

const openEdit = (record: any) => {
  const target = props.invoices.find(i => i.id === record.id)
  if (!target) return
  currentInvoice.value = target
  formState.value = {
    direction: target.direction || 'output',
    invoiceNo: target.invoiceNo,
    invoiceDate: target.invoiceDate ? dayjs(target.invoiceDate) : null,
    amount: target.amount,
    type: target.type
  }
  attachmentFileList.value = target.attachmentFilePath
    ? [
        {
          uid: String(target.id),
          name: target.attachmentFileName || '发票附件',
          status: 'done',
          url: target.attachmentFilePath
        }
      ]
    : []
  modalVisible.value = true
}

const handleCancel = () => {
  modalVisible.value = false
}

const handleAttachmentBeforeUpload = (file: any) => {
  attachmentFileList.value = [file]
  return false
}

const handleAttachmentRemove = () => {
  attachmentFileList.value = []
}

const handleOk = async () => {
  if (!formState.value.invoiceNo || !formState.value.invoiceDate || formState.value.amount == null) {
    message.error('请填写必填字段')
    return
  }

  const payload: CreateContractInvoiceDto = {
    invoiceNo: formState.value.invoiceNo,
    invoiceDate: dayjs(formState.value.invoiceDate).format('YYYY-MM-DD'),
    amount: formState.value.amount,
    direction: formState.value.direction,
    type: formState.value.type,
    status:
      currentInvoice.value?.status ||
      invoiceStatusOptions.value.find(i => i.isDefault)?.value ||
      undefined
  }

  saving.value = true
  try {
    let invoiceId: number | null = null
    if (currentInvoice.value) {
      const res = await updateInvoice(currentInvoice.value.id, payload)
      invoiceId = res.id
      message.success('更新成功')
    } else {
      const res = await createInvoice(props.contractId, payload)
      invoiceId = res.id
      message.success('新增成功')
    }

    const fileItem = attachmentFileList.value[0]
    if (invoiceId != null && fileItem) {
      const rawFile = (fileItem as any).originFileObj || (fileItem as any)
      if (rawFile instanceof File) {
        await uploadInvoiceAttachment(invoiceId, rawFile)
      }
    }

    modalVisible.value = false
    emit('changed')
  } catch {
    message.error('保存失败')
  } finally {
    saving.value = false
  }
}

const handleDelete = async (record: any) => {
  saving.value = true
  try {
    await deleteInvoice(record.id)
    message.success('删除成功')
    emit('changed')
  } catch {
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
