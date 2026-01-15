<template>
  <a-card title="收付款计划" size="small" class="card-no-padding" style="margin-bottom: 16px">
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
            <a-popconfirm title="确定删除该计划吗？" @confirm="handleDelete(record)">
              <a-button type="text" danger size="small">
                <template #icon><DeleteOutlined /></template>
              </a-button>
            </a-popconfirm>
          </a-space>
        </template>
      </template>
    </a-table>

    <a-modal
      v-model:open="modalVisible"
      :title="currentRecord ? '编辑收付款计划' : '新增收付款计划'"
      @ok="handleOk"
      @cancel="handleCancel"
      :confirm-loading="saving"
      destroy-on-close
    >
      <a-form :model="formState" layout="vertical">
        <a-form-item label="期数">
          <a-input v-model:value="formState.phase" />
        </a-form-item>
        <a-form-item label="计划付款日期">
          <a-date-picker v-model:value="formState.dueDate" style="width: 100%" />
        </a-form-item>
        <a-form-item label="计划金额">
          <a-input-number v-model:value="formState.amount" :min="0" style="width: 100%" />
        </a-form-item>
        <a-form-item label="付款条件">
          <a-input v-model:value="formState.condition" />
        </a-form-item>
        <a-form-item label="状态">
          <a-select v-model:value="formState.status">
            <a-select-option value="pending">未支付</a-select-option>
            <a-select-option value="paid">已支付</a-select-option>
          </a-select>
        </a-form-item>
      </a-form>
    </a-modal>
  </a-card>
</template>

<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { message } from 'ant-design-vue'
import { PlusOutlined, EditOutlined, DeleteOutlined } from '@ant-design/icons-vue'
import type { ColumnType } from 'ant-design-vue/es/table/interface'
import dayjs from 'dayjs'
import type { ContractDetailDto, ContractPaymentPlanDto } from '@/api/contract'
import { createPaymentPlan, updatePaymentPlan, deletePaymentPlan, type CreateContractPaymentPlanDto } from '@/api/contract'

const props = defineProps<{
  contractId: number
  plans: ContractDetailDto['paymentPlans']
}>()

const emit = defineEmits<{
  (e: 'changed'): void
}>()

const columns: ColumnType[] = [
  { title: '期数', dataIndex: 'phase', key: 'phase', width: 80 },
  { title: '计划付款日期', dataIndex: 'dueDate', key: 'dueDate' },
  { title: '计划金额', dataIndex: 'amount', key: 'amount', align: 'right' as const },
  { title: '付款条件', dataIndex: 'condition', key: 'condition' },
  { title: '状态', dataIndex: 'status', key: 'status' },
  { title: '操作', key: 'action', width: 80, align: 'center' as const }
]

const tableData = computed(() => {
  if (!props.plans) return []
  return props.plans.map(p => ({
    key: p.id.toString(),
    id: p.id,
    phase: p.phase,
    dueDate: p.dueDate ? new Date(p.dueDate).toISOString().split('T')[0] : '',
    amount: p.amount.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
    condition: p.condition,
    status: p.status === 'paid' ? '已支付' : '未支付',
    rawStatus: p.status
  }))
})

const modalVisible = ref(false)
const saving = ref(false)
const currentRecord = ref<ContractPaymentPlanDto | null>(null)

const formState = ref<{
  phase: string
  dueDate: any
  amount: number
  condition?: string
  status: string
}>({
  phase: '',
  dueDate: null,
  amount: 0,
  condition: '',
  status: 'pending'
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
    phase: '',
    dueDate: null,
    amount: 0,
    condition: '',
    status: 'pending'
  }
}

const openCreate = () => {
  resetForm()
  currentRecord.value = null
  modalVisible.value = true
}

const openEdit = (record: any) => {
  const target = props.plans.find(p => p.id === record.id)
  if (!target) return
  currentRecord.value = target
  formState.value = {
    phase: target.phase,
    dueDate: target.dueDate ? dayjs(target.dueDate) : null,
    amount: target.amount,
    condition: target.condition,
    status: target.status
  }
  modalVisible.value = true
}

const handleCancel = () => {
  modalVisible.value = false
}

const handleOk = async () => {
  if (!formState.value.phase || formState.value.amount == null) {
    message.error('请填写期数和金额')
    return
  }

  const payload: CreateContractPaymentPlanDto = {
    phase: formState.value.phase,
    dueDate: formState.value.dueDate ? dayjs(formState.value.dueDate).format('YYYY-MM-DD') : undefined,
    amount: formState.value.amount,
    condition: formState.value.condition,
    status: formState.value.status
  }

  saving.value = true
  try {
    if (currentRecord.value) {
      await updatePaymentPlan(currentRecord.value.id, payload)
      message.success('更新成功')
    } else {
      await createPaymentPlan(props.contractId, payload)
      message.success('新增成功')
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
    await deletePaymentPlan(record.id)
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
