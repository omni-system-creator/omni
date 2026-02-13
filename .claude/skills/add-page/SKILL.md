---
name: add-page
description: Add a new frontend page with proper layout, table, and API integration following OMS UI standards
disable-model-invocation: false
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Add Page Skill

Add a new frontend page to the OMS PC frontend following UI standards and best practices.

## Instructions

When the user requests to add a new page, follow these steps:

### 1. Understand Requirements
- Determine page type (list, detail, form, dashboard, etc.)
- Identify required features (CRUD, search, filters, etc.)
- Confirm routing and menu placement

### 2. Create API Module
Location: `frontend/src/api/{module}.ts`

```typescript
import request from '@/utils/request'

export interface {EntityName} {
  id: number
  orgId: number
  propertyName: string
  createdAt: string
  updatedAt: string
}

export interface Create{EntityName}Dto {
  propertyName: string
}

export interface Update{EntityName}Dto {
  propertyName: string
}

export const {entityName}Api = {
  getList: () => request.get<{EntityName}[]>('/api/{EntityName}'),

  getById: (id: number) => request.get<{EntityName}>(`/api/{EntityName}/${id}`),

  create: (data: Create{EntityName}Dto) => request.post<{EntityName}>('/api/{EntityName}', data),

  update: (id: number, data: Update{EntityName}Dto) =>
    request.put<{EntityName}>(`/api/{EntityName}/${id}`, data),

  delete: (id: number) => request.delete(`/api/{EntityName}/${id}`)
}
```

### 3. Create Page Component
Location: `frontend/src/views/{module}/{PageName}.vue`

**CRITICAL UI Standards**:
- Use `SplitLayout` for resizable panels (NOT manual Flex/Grid)
- Tables MUST have row number column (with pagination offset)
- Action column MUST be centered with icons (not text)
- More than 3 actions MUST use `MoreOutlined` dropdown
- Complex modals MUST support drag and maximize
- Containers MUST adapt to parent size (avoid double scrollbars)

Example List Page:
```vue
<template>
  <div class="page-container">
    <a-card title="{Entity} Management" :bordered="false">
      <template #extra>
        <a-space>
          <a-button type="primary" @click="handleAdd">
            <template #icon><PlusOutlined /></template>
            Add {Entity}
          </a-button>
        </a-space>
      </template>

      <a-table
        :columns="columns"
        :data-source="dataSource"
        :loading="loading"
        :pagination="pagination"
        @change="handleTableChange"
        :scroll="{ y: 'calc(100vh - 300px)' }"
      >
        <!-- Row number column -->
        <template #bodyCell="{ column, index }">
          <template v-if="column.key === 'rowNumber'">
            {{ (pagination.current - 1) * pagination.pageSize + index + 1 }}
          </template>
          <template v-else-if="column.key === 'action'">
            <a-space>
              <a-tooltip title="Edit">
                <a-button type="link" size="small" @click="handleEdit(record)">
                  <template #icon><EditOutlined /></template>
                </a-button>
              </a-tooltip>
              <a-tooltip title="Delete">
                <a-button type="link" danger size="small" @click="handleDelete(record)">
                  <template #icon><DeleteOutlined /></template>
                </a-button>
              </a-tooltip>
            </a-space>
          </template>
        </template>
      </a-table>
    </a-card>

    <!-- Edit Modal -->
    <a-modal
      v-model:open="modalVisible"
      :title="modalTitle"
      :confirm-loading="modalLoading"
      @ok="handleModalOk"
      width="600px"
    >
      <a-form
        ref="formRef"
        :model="formData"
        :label-col="{ span: 6 }"
        :wrapper-col="{ span: 16 }"
      >
        <a-form-item label="Property Name" name="propertyName" :rules="[{ required: true }]">
          <a-input v-model:value="formData.propertyName" />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { {entityName}Api, type {EntityName}, type Create{EntityName}Dto } from '@/api/{module}'

const loading = ref(false)
const dataSource = ref<{EntityName}[]>([])
const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0
})

const columns = [
  {
    title: 'No.',
    key: 'rowNumber',
    width: 60,
    align: 'center'
  },
  {
    title: 'Property Name',
    dataIndex: 'propertyName',
    key: 'propertyName'
  },
  {
    title: 'Created At',
    dataIndex: 'createdAt',
    key: 'createdAt',
    width: 180
  },
  {
    title: 'Action',
    key: 'action',
    width: 120,
    align: 'center'
  }
]

const modalVisible = ref(false)
const modalLoading = ref(false)
const modalTitle = ref('')
const editingId = ref<number | null>(null)
const formRef = ref()
const formData = reactive<Create{EntityName}Dto>({
  propertyName: ''
})

const fetchData = async () => {
  loading.value = true
  try {
    const res = await {entityName}Api.getList()
    dataSource.value = res.data || []
    pagination.total = res.data?.length || 0
  } catch (error) {
    message.error('Failed to load data')
  } finally {
    loading.value = false
  }
}

const handleAdd = () => {
  modalTitle.value = 'Add {Entity}'
  editingId.value = null
  Object.assign(formData, { propertyName: '' })
  modalVisible.value = true
}

const handleEdit = (record: {EntityName}) => {
  modalTitle.value = 'Edit {Entity}'
  editingId.value = record.id
  Object.assign(formData, {
    propertyName: record.propertyName
  })
  modalVisible.value = true
}

const handleModalOk = async () => {
  try {
    await formRef.value.validate()
    modalLoading.value = true

    if (editingId.value) {
      await {entityName}Api.update(editingId.value, formData)
      message.success('Updated successfully')
    } else {
      await {entityName}Api.create(formData)
      message.success('Created successfully')
    }

    modalVisible.value = false
    fetchData()
  } catch (error) {
    message.error('Operation failed')
  } finally {
    modalLoading.value = false
  }
}

const handleDelete = (record: {EntityName}) => {
  Modal.confirm({
    title: 'Confirm Delete',
    content: 'Are you sure you want to delete this item?',
    onOk: async () => {
      try {
        await {entityName}Api.delete(record.id)
        message.success('Deleted successfully')
        fetchData()
      } catch (error) {
        message.error('Delete failed')
      }
    }
  })
}

const handleTableChange = (pag: any) => {
  pagination.current = pag.current
  pagination.pageSize = pag.pageSize
  fetchData()
}

onMounted(() => {
  fetchData()
})
</script>

<style scoped lang="less">
.page-container {
  height: 100%;
  padding: 16px;

  .ant-card {
    height: 100%;
  }
}
</style>
```

### 4. Add Route
Location: `frontend/src/router/index.ts` or dynamic routes

```typescript
{
  path: '/{module}/{page-name}',
  name: '{PageName}',
  component: () => import('@/views/{module}/{PageName}.vue'),
  meta: {
    title: '{Page Title}',
    requiresAuth: true
  }
}
```

### 5. Add Menu Item (if needed)
Update menu configuration to include the new page.

### 6. UI Standards Checklist

- [ ] Use `SplitLayout` for resizable panels (not manual Flex/Grid)
- [ ] Table has row number column on the left
- [ ] Row numbers continue across pages (use pagination offset)
- [ ] Action column is centered
- [ ] Actions use icons with `title` tooltips (not text)
- [ ] More than 3 actions use `MoreOutlined` dropdown
- [ ] Complex modals support drag (use `useDraggableModal`)
- [ ] Submit buttons bind to `loading` state
- [ ] Containers adapt to parent size (no double scrollbars)
- [ ] Error handling with `message.error()`
- [ ] Success feedback with `message.success()`
- [ ] Confirm dialogs for destructive actions
- [ ] Form validation with rules
- [ ] TypeScript types for all data

## Component Examples

### Using SplitLayout
```vue
<SplitLayout
  :default-size="300"
  :min-size="200"
  :max-size="500"
  storage-key="page-split"
>
  <template #left>
    <!-- Left panel content -->
  </template>
  <template #right>
    <!-- Right panel content -->
  </template>
</SplitLayout>
```

### Using Draggable Modal
```vue
<script setup>
import { useDraggableModal } from '@/composables/useDraggableModal'

const { modalRef, handleMouseDown } = useDraggableModal()
</script>

<template>
  <a-modal
    ref="modalRef"
    v-model:open="visible"
    :title="title"
    @mousedown="handleMouseDown"
  >
    <!-- Modal content -->
  </a-modal>
</template>
```

### Action Column with Dropdown
```vue
<template #bodyCell="{ column, record }">
  <template v-if="column.key === 'action'">
    <a-space>
      <a-tooltip title="Edit">
        <a-button type="link" size="small" @click="handleEdit(record)">
          <template #icon><EditOutlined /></template>
        </a-button>
      </a-tooltip>
      <a-dropdown>
        <a-button type="link" size="small">
          <template #icon><MoreOutlined /></template>
        </a-button>
        <template #overlay>
          <a-menu>
            <a-menu-item @click="handleView(record)">
              <EyeOutlined /> View
            </a-menu-item>
            <a-menu-item @click="handleCopy(record)">
              <CopyOutlined /> Copy
            </a-menu-item>
            <a-menu-item danger @click="handleDelete(record)">
              <DeleteOutlined /> Delete
            </a-menu-item>
          </a-menu>
        </template>
      </a-dropdown>
    </a-space>
  </template>
</template>
```
