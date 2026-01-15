<template>
  <div>
    <div style="margin-bottom: 12px; display: flex; justify-content: space-between; align-items: center">
      <a-upload
        :file-list="fileList"
        :before-upload="handleBeforeUpload"
        :show-upload-list="false"
      >
        <a-button type="primary" size="small">上传附件</a-button>
      </a-upload>
    </div>
    <a-table
      v-if="displayList.length"
      :columns="columns"
      :data-source="displayList"
      row-key="id"
      size="small"
      :pagination="false"
    >
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'fileName'">
          <a-space>
            <file-text-outlined />
            <span>{{ record.fileName }}</span>
          </a-space>
        </template>
        <template v-else-if="column.key === 'uploadDate'">
          <span>{{ formatDate(record.uploadDate) }}</span>
        </template>
        <template v-else-if="column.key === 'actions'">
          <a-space>
            <a-tooltip title="下载" v-if="record.filePath">
              <a-button
                type="text"
                size="small"
                :href="record.filePath"
                target="_blank"
              >
                <template #icon><DownloadOutlined /></template>
              </a-button>
            </a-tooltip>
            <a-tooltip title="删除">
              <a-popconfirm title="确认删除该附件？" @confirm="() => handleDelete(record as any)">
                <a-button type="text" size="small" danger>
                  <template #icon><DeleteOutlined /></template>
                </a-button>
              </a-popconfirm>
            </a-tooltip>
          </a-space>
        </template>
      </template>
    </a-table>
    <a-empty v-else description="暂无附件" />
  </div>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { FileTextOutlined, DownloadOutlined, DeleteOutlined } from '@ant-design/icons-vue'
import { message } from 'ant-design-vue'
import type { ColumnType } from 'ant-design-vue/es/table/interface'
import type { ContractAttachmentDto } from '@/api/contract'
import { uploadContractAttachment, deleteContractAttachment } from '@/api/contract'

const props = defineProps<{
  contractId: number
  attachments: ContractAttachmentDto[]
}>()

const emit = defineEmits<{
  (e: 'changed'): void
}>()

const fileList = ref<any[]>([])

const displayList = computed(() => props.attachments || [])

const columns: ColumnType[] = [
  {
    title: '文件名',
    dataIndex: 'fileName',
    key: 'fileName'
  },
  {
    title: '大小',
    dataIndex: 'size',
    key: 'size',
    width: 120,
    align: 'right'
  },
  {
    title: '上传时间',
    dataIndex: 'uploadDate',
    key: 'uploadDate',
    width: 190,
    align: 'center'
  },
  {
    title: '操作',
    key: 'actions',
    width: 150,
    align: 'center'
  }
]

const formatDate = (val?: string) => {
  if (!val) return ''
  const d = new Date(val)
  if (Number.isNaN(d.getTime())) return val
  const pad = (n: number) => (n < 10 ? `0${n}` : `${n}`)
  const y = d.getFullYear()
  const m = pad(d.getMonth() + 1)
  const day = pad(d.getDate())
  const h = pad(d.getHours())
  const mi = pad(d.getMinutes())
  const s = pad(d.getSeconds())
  return `${y}-${m}-${day} ${h}:${mi}:${s}`
}

const handleBeforeUpload = async (file: any) => {
  fileList.value = [file]
  try {
    await uploadContractAttachment(props.contractId, file as File)
    message.success('上传成功')
    emit('changed')
  } catch (e) {
    message.error('上传失败')
  } finally {
    fileList.value = []
  }
  return false
}

const handleDelete = async (item: ContractAttachmentDto) => {
  try {
    await deleteContractAttachment(item.id)
    message.success('删除成功')
    emit('changed')
  } catch (e) {
    message.error('删除失败')
  }
}
</script>

<style scoped>
</style>
