<script setup lang="ts">
import { computed, h } from 'vue'
import { useProjectStore } from '../stores/projectStore'
import { NDataTable, NTag, NButton, useMessage } from 'naive-ui'
import type { DataTableColumns } from 'naive-ui'

const store = useProjectStore()
const message = useMessage()

// Helper to get file icon/type
const getFileType = (fileName: string) => {
    const ext = fileName.split('.').pop()?.toLowerCase() || ''
    return ext
}

const fileTypeMap: Record<string, string> = {
    pdf: '📄',
    doc: '📝',
    docx: '📝',
    ppt: '📊',
    pptx: '📊',
    xls: '📉',
    xlsx: '📉',
    jpg: '🖼️',
    png: '🖼️',
    zip: '📦',
    rar: '📦'
}

const getFileIcon = (fileName: string) => {
    const ext = getFileType(fileName)
    return fileTypeMap[ext] || '📁'
}

const documents = computed(() => {
    const docs: any[] = []
    store.tasks.forEach(task => {
        if (task.attachments && task.attachments.length > 0) {
            task.attachments.forEach(att => {
                const phase = store.phases.find(p => p.id === task.phaseId)
                const swimlane = store.swimlanes.find(s => s.id === task.swimlaneId)
                docs.push({
                    key: att.id,
                    name: att.name,
                    icon: getFileIcon(att.name),
                    phase: phase?.name || '未知阶段',
                    swimlane: swimlane?.name || '未知专业',
                    task: task.name,
                    uploader: att.uploader || '未知用户',
                    uploadTime: att.uploadDate,
                    size: att.size || '未知大小',
                    url: att.url
                })
            })
        }
    })
    return docs.sort((a, b) => new Date(b.uploadTime).getTime() - new Date(a.uploadTime).getTime())
})

const parseSize = (sizeStr: string) => {
    if (!sizeStr) return 0
    const units = { 'B': 1, 'KB': 1024, 'MB': 1024*1024, 'GB': 1024*1024*1024 }
    const match = sizeStr.match(/([\d.]+)\s*([a-zA-Z]+)/)
    if (match && match[1] && match[2]) {
        const val = parseFloat(match[1])
        const unit = match[2].toUpperCase()
        return val * (units[unit as keyof typeof units] || 1)
    }
    return 0
}

const handleDownload = (row: any) => {
    // In a real app, this would use the actual URL.
    // For this demo, we simulate a download or use the URL if it's not a placeholder.
    if (row.url && row.url !== '#') {
        const link = document.createElement('a')
        link.href = row.url
        link.download = row.name
        document.body.appendChild(link)
        link.click()
        document.body.removeChild(link)
        message.success(`开始下载: ${row.name}`)
    } else {
        // Simulation for demo
        message.success(`模拟下载: ${row.name}`)
    }
}

const columns: DataTableColumns<any> = [
    {
        title: '序号',
        key: 'index',
        width: 60,
        align: 'center',
        render: (_, index) => {
            return `${index + 1}`
        }
    },
    {
        title: '文件名称',
        key: 'name',
        sorter: (row1, row2) => row1.name.localeCompare(row2.name),
        render(row) {
            return h('div', { style: { display: 'flex', alignItems: 'center', gap: '8px' } }, [
                h('span', { style: { fontSize: '1.2em' } }, row.icon),
                h('span', null, row.name)
            ])
        }
    },
    {
        title: '所属阶段',
        key: 'phase',
        sorter: (row1, row2) => row1.phase.localeCompare(row2.phase),
        render(row) {
            return h(NTag, { type: 'default', size: 'small', bordered: false }, { default: () => row.phase })
        }
    },
    {
        title: '所属专业',
        key: 'swimlane',
        sorter: (row1, row2) => row1.swimlane.localeCompare(row2.swimlane),
        render(row) {
            return h(NTag, { type: 'info', size: 'small', bordered: false }, { default: () => row.swimlane })
        }
    },
    {
        title: '所属任务',
        key: 'task',
        sorter: (row1, row2) => row1.task.localeCompare(row2.task)
    },
    {
        title: '上传者',
        key: 'uploader',
        sorter: (row1, row2) => row1.uploader.localeCompare(row2.uploader)
    },
    {
        title: '上传时间',
        key: 'uploadTime',
        sorter: (row1, row2) => new Date(row1.uploadTime).getTime() - new Date(row2.uploadTime).getTime()
    },
    {
        title: '文件大小',
        key: 'size',
        sorter: (row1, row2) => parseSize(row1.size) - parseSize(row2.size)
    },
    {
        title: '操作',
        key: 'actions',
        render(row) {
            return h(
                NButton,
                {
                    size: 'small',
                    type: 'primary',
                    ghost: true,
                    onClick: () => handleDownload(row)
                },
                { default: () => '下载' }
            )
        }
    }
]

</script>

<template>
    <div class="document-view-container">
        <n-data-table
            :columns="columns"
            :data="documents"
            :pagination="{ pageSize: 15 }"
            :bordered="false"
            striped
            class="doc-table"
        />
    </div>
</template>

<style scoped>
.document-view-container {
    width: 100%;
    height: 100%;
    padding: 0;
    box-sizing: border-box;
    overflow: hidden;
    background: #f0f2f5;
    display: flex;
    flex-direction: column;
}

.doc-table {
    flex: 1;
}

:deep(.n-data-table-wrapper) {
    background: white;
    border-radius: 0;
    box-shadow: none;
}
</style>
