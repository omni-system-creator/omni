<template>
  <div>
    <div style="margin-bottom: 12px; display: flex; justify-content: space-between; align-items: center">
      <div>
        <a-button type="primary" size="small" @click="openSelector">设置关联合同</a-button>
      </div>
    </div>

    <div v-if="displayList.length">
      <a-row :gutter="16">
        <a-col v-for="item in displayList" :key="item.id" :span="12" style="margin-bottom: 12px">
          <a-card :title="null" size="small">
            <div style="font-weight: 500; margin-bottom: 4px">
              <a @click="handleOpen(item)">{{ item.contractName }}</a>
            </div>
            <div style="font-size: 12px; color: #999; margin-bottom: 8px">
              合同编号：{{ item.contractNo }}
            </div>
            <div style="display: flex; flex-wrap: wrap; gap: 8px; font-size: 12px">
              <div>
                <span>类型：</span>
                <a-tag :color="getContractTypeColor(item.type)" style="margin-right: 0">
                  {{ getContractTypeLabel(item.type) }}
                </a-tag>
              </div>
              <div>
                <span>负责人：</span>
                <span>{{ item.manager || '-' }}</span>
              </div>
              <div>
                <span>金额：</span>
                <span>{{ formatAmount(item.totalAmount) }} {{ item.currency }}</span>
              </div>
              <div>
                <span>状态：</span>
                <a-tag :color="getStatusColor(item.status)" style="margin-right: 0">
                  {{ getStatusText(item.status) }}
                </a-tag>
              </div>
              <div>
                <span>签订日期：</span>
                <span>{{ item.signDate ? item.signDate.split('T')[0] : '-' }}</span>
              </div>
            </div>
          </a-card>
        </a-col>
      </a-row>
    </div>
    <a-empty v-else description="暂无关联合同" />

    <a-modal
      v-model:open="selectorVisible"
      title="选择关联合同"
      width="1200px"
      @ok="handleSelectorOk"
    >
      <div style="margin-bottom: 12px; display: flex; justify-content: space-between; align-items: center">
        <a-input-search
          v-model:value="keyword"
          placeholder="搜索合同名称或编号"
          style="width: 260px"
          @search="fetchSelectableContracts"
          allow-clear
        />
      </div>
      <a-table
        :columns="selectColumns"
        :data-source="selectableContracts"
        :loading="selectLoading"
        row-key="id"
        size="small"
        :pagination="{ pageSize: 10 }"
        :row-selection="rowSelection"
      >
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'type'">
            <a-tag :color="getContractTypeColor(record.type)">
              {{ getContractTypeLabel(record.type) }}
            </a-tag>
          </template>
          <template v-else-if="column.key === 'totalAmount'">
            {{ formatAmount(record.totalAmount) }} {{ record.currency }}
          </template>
          <template v-else-if="column.key === 'status'">
            <a-tag :color="getStatusColor(record.status)">
              {{ getStatusText(record.status) }}
            </a-tag>
          </template>
          <template v-else-if="column.key === 'signDate'">
            <span>{{ record.signDate ? record.signDate.split('T')[0] : '-' }}</span>
          </template>
        </template>
      </a-table>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { message } from 'ant-design-vue'
import type { ColumnType } from 'ant-design-vue/es/table/interface'
import { getDictDataByCode, type DictDataDto } from '@/api/dict'
import {
  getContracts,
  getRelatedContracts,
  setRelatedContracts,
  type ContractDto,
  type RelatedContractDto
} from '@/api/contract'

const props = defineProps<{
  contractId: number
  relatedContracts: RelatedContractDto[]
}>()

const emit = defineEmits<{
  (e: 'changed'): void
  (e: 'open-contract', id: number): void
}>()

const loading = ref(false)
const selectorVisible = ref(false)
const selectLoading = ref(false)
const keyword = ref('')

const contractTypeOptions = ref<DictDataDto[]>([])

const displayList = computed(() => props.relatedContracts || [])

const selectableContracts = ref<ContractDto[]>([])
const selectedIds = ref<number[]>([])

const selectColumns: ColumnType[] = [
  { title: '合同编号', dataIndex: 'contractNo', key: 'contractNo', width: 160 },
  { title: '合同名称', dataIndex: 'contractName', key: 'contractName' },
  { title: '类型', dataIndex: 'type', key: 'type', width: 120 },
  { title: '负责人', dataIndex: 'manager', key: 'manager', width: 120 },
  { title: '金额', dataIndex: 'totalAmount', key: 'totalAmount', width: 160, align: 'right' as const },
  { title: '状态', dataIndex: 'status', key: 'status', width: 120 },
  { title: '签订日期', dataIndex: 'signDate', key: 'signDate', width: 140 }
]

const rowSelection = computed(() => ({
  selectedRowKeys: selectedIds.value,
  onChange: (keys: any[]) => {
    selectedIds.value = keys as number[]
  }
}))

const formatAmount = (value?: number) => {
  if (value == null) return '-'
  return value.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

const getDictLabel = (options: DictDataDto[], value?: string) => {
  if (!value) return '-'
  const item = options.find(i => i.value === value)
  return item ? item.label : value
}

const getContractTypeLabel = (value?: string) => getDictLabel(contractTypeOptions.value, value)

const getContractTypeColor = (value?: string) => {
  if (value === 'sales') return 'blue'
  if (value === 'purchase') return 'orange'
  return 'default'
}

const getStatusColor = (status: string) => {
  switch (status) {
    case 'executing':
      return 'processing'
    case 'completed':
      return 'success'
    case 'abnormal':
      return 'error'
    default:
      return 'default'
  }
}

const getStatusText = (status: string) => {
  switch (status) {
    case 'executing':
      return '执行中'
    case 'completed':
      return '已完成'
    case 'abnormal':
      return '异常'
    default:
      return status || '未知'
  }
}

const handleOpen = (item: RelatedContractDto) => {
  emit('open-contract', item.id)
}

const syncSelectedFromProps = () => {
  selectedIds.value = (props.relatedContracts || []).map(r => r.id)
}

const openSelector = async () => {
  selectorVisible.value = true
  syncSelectedFromProps()
  await fetchSelectableContracts()
}

const fetchSelectableContracts = async () => {
  selectLoading.value = true
  try {
    const res = await getContracts(undefined, keyword.value || undefined, undefined)
    const list = res || []
    selectableContracts.value = list.filter(c => c.id !== props.contractId)
  } catch (e) {
    message.error('获取合同列表失败')
  } finally {
    selectLoading.value = false
  }
}

const refreshCurrentRelated = async () => {
  loading.value = true
  try {
    const res = await getRelatedContracts(props.contractId)
    const ids = (res || []).map(r => r.id)
    selectedIds.value = ids
    emit('changed')
  } catch (e) {
    message.error('刷新关联合同失败')
  } finally {
    loading.value = false
  }
}

const handleSelectorOk = async () => {
  try {
    await setRelatedContracts(props.contractId, {
      relatedContractIds: selectedIds.value
    })
    message.success('关联合同已更新')
    selectorVisible.value = false
    await refreshCurrentRelated()
  } catch (e) {
    message.error('更新关联合同失败')
  }
}

onMounted(async () => {
  contractTypeOptions.value = (await getDictDataByCode('contract_type')) || []
  syncSelectedFromProps()
})

watch(
  () => props.relatedContracts,
  () => {
    syncSelectedFromProps()
  },
  { deep: true }
)
</script>

<style scoped>
</style>
