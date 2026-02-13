---
name: add-h5-page
description: Add a new mobile page to frontend.h5 using Vant 4 components
disable-model-invocation: false
allowed-tools: Read, Write, Edit, Glob
---

# Add H5 Page Skill

Add a new mobile page to the OMS H5 frontend using Vant 4 components.

## Instructions

When the user requests to add a new mobile page, follow these steps:

### 1. Understand Requirements
- Determine page type (list, detail, form, etc.)
- Identify required features
- Confirm routing and navigation

### 2. Create API Module (if needed)
Location: `frontend.h5/src/api/{module}.ts`

```typescript
import request from '@/utils/request'

export interface {EntityName} {
  id: number
  orgId: number
  name: string
  createdAt: string
}

export const {entityName}Api = {
  getList: () => request.get<{EntityName}[]>('/api/{EntityName}'),
  getById: (id: number) => request.get<{EntityName}>(`/api/{EntityName}/${id}`),
  create: (data: any) => request.post('/api/{EntityName}', data),
  update: (id: number, data: any) => request.put(`/api/{EntityName}/${id}`, data),
  delete: (id: number) => request.delete(`/api/{EntityName}/${id}`)
}
```

### 3. Create Page Component
Location: `frontend.h5/src/views/{module}/{PageName}.vue`

#### List Page Example
```vue
<template>
  <div class="page">
    <van-nav-bar
      :title="title"
      left-arrow
      @click-left="onClickLeft"
    >
      <template #right>
        <van-icon name="plus" @click="handleAdd" />
      </template>
    </van-nav-bar>

    <van-pull-refresh v-model="refreshing" @refresh="onRefresh">
      <van-list
        v-model:loading="loading"
        :finished="finished"
        finished-text="没有更多了"
        @load="onLoad"
      >
        <van-cell
          v-for="item in list"
          :key="item.id"
          :title="item.name"
          is-link
          @click="handleView(item)"
        >
          <template #label>
            <div class="item-info">
              <span>{{ item.description }}</span>
            </div>
          </template>
        </van-cell>
      </van-list>
    </van-pull-refresh>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { showToast } from 'vant'
import { {entityName}Api, type {EntityName} } from '@/api/{module}'

const router = useRouter()
const title = ref('{Page Title}')

const list = ref<{EntityName}[]>([])
const loading = ref(false)
const finished = ref(false)
const refreshing = ref(false)
const page = ref(1)
const pageSize = 20

const onClickLeft = () => {
  router.back()
}

const onLoad = async () => {
  try {
    const res = await {entityName}Api.getList()

    if (refreshing.value) {
      list.value = []
      refreshing.value = false
    }

    list.value.push(...(res.data || []))
    loading.value = false

    if (list.value.length >= (res.total || 0)) {
      finished.value = true
    }
  } catch (error) {
    showToast('加载失败')
    loading.value = false
  }
}

const onRefresh = () => {
  finished.value = false
  loading.value = true
  page.value = 1
  onLoad()
}

const handleAdd = () => {
  router.push('/{module}/{page-name}/add')
}

const handleView = (item: {EntityName}) => {
  router.push(`/{module}/{page-name}/${item.id}`)
}
</script>

<style scoped lang="less">
.page {
  min-height: 100vh;
  background-color: #f7f8fa;
}

.item-info {
  margin-top: 4px;
  font-size: 12px;
  color: #969799;
}
</style>
```

#### Form Page Example
```vue
<template>
  <div class="page">
    <van-nav-bar
      :title="isEdit ? '编辑' : '新增'"
      left-arrow
      @click-left="onClickLeft"
    />

    <van-form @submit="onSubmit">
      <van-cell-group inset>
        <van-field
          v-model="formData.name"
          name="name"
          label="名称"
          placeholder="请输入名称"
          :rules="[{ required: true, message: '请输入名称' }]"
        />

        <van-field
          v-model="formData.description"
          name="description"
          label="描述"
          type="textarea"
          placeholder="请输入描述"
          rows="3"
        />
      </van-cell-group>

      <div class="submit-btn">
        <van-button
          round
          block
          type="primary"
          native-type="submit"
          :loading="submitting"
        >
          提交
        </van-button>
      </div>
    </van-form>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { showToast } from 'vant'
import { {entityName}Api } from '@/api/{module}'

const router = useRouter()
const route = useRoute()

const id = ref(route.params.id as string)
const isEdit = ref(!!id.value)
const submitting = ref(false)

const formData = reactive({
  name: '',
  description: ''
})

const onClickLeft = () => {
  router.back()
}

const loadData = async () => {
  if (!id.value) return

  try {
    const res = await {entityName}Api.getById(Number(id.value))
    Object.assign(formData, res.data)
  } catch (error) {
    showToast('加载失败')
  }
}

const onSubmit = async () => {
  submitting.value = true

  try {
    if (isEdit.value) {
      await {entityName}Api.update(Number(id.value), formData)
      showToast('更新成功')
    } else {
      await {entityName}Api.create(formData)
      showToast('创建成功')
    }
    router.back()
  } catch (error) {
    showToast('操作失败')
  } finally {
    submitting.value = false
  }
}

onMounted(() => {
  loadData()
})
</script>

<style scoped lang="less">
.page {
  min-height: 100vh;
  background-color: #f7f8fa;
}

.submit-btn {
  margin: 16px;
}
</style>
```

#### Detail Page Example
```vue
<template>
  <div class="page">
    <van-nav-bar
      title="详情"
      left-arrow
      @click-left="onClickLeft"
    >
      <template #right>
        <van-icon name="edit" @click="handleEdit" />
      </template>
    </van-nav-bar>

    <van-loading v-if="loading" class="loading" />

    <div v-else class="content">
      <van-cell-group inset>
        <van-cell title="名称" :value="detail.name" />
        <van-cell title="描述" :value="detail.description" />
        <van-cell title="创建时间" :value="detail.createdAt" />
      </van-cell-group>

      <div class="actions">
        <van-button
          round
          block
          type="danger"
          @click="handleDelete"
        >
          删除
        </van-button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { showToast, showConfirmDialog } from 'vant'
import { {entityName}Api, type {EntityName} } from '@/api/{module}'

const router = useRouter()
const route = useRoute()

const id = ref(route.params.id as string)
const loading = ref(true)
const detail = ref<{EntityName}>({} as {EntityName})

const onClickLeft = () => {
  router.back()
}

const loadData = async () => {
  loading.value = true
  try {
    const res = await {entityName}Api.getById(Number(id.value))
    detail.value = res.data
  } catch (error) {
    showToast('加载失败')
  } finally {
    loading.value = false
  }
}

const handleEdit = () => {
  router.push(`/{module}/{page-name}/${id.value}/edit`)
}

const handleDelete = async () => {
  try {
    await showConfirmDialog({
      title: '确认删除',
      message: '确定要删除这条记录吗？'
    })

    await {entityName}Api.delete(Number(id.value))
    showToast('删除成功')
    router.back()
  } catch (error) {
    if (error !== 'cancel') {
      showToast('删除失败')
    }
  }
}

onMounted(() => {
  loadData()
})
</script>

<style scoped lang="less">
.page {
  min-height: 100vh;
  background-color: #f7f8fa;
}

.loading {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 200px;
}

.content {
  padding-bottom: 20px;
}

.actions {
  margin: 16px;
}
</style>
```

### 4. Add Routes
Location: `frontend.h5/src/router/index.ts`

```typescript
{
  path: '/{module}/{page-name}',
  name: '{PageName}',
  component: () => import('@/views/{module}/{PageName}.vue'),
  meta: {
    title: '{Page Title}',
    requiresAuth: true
  }
},
{
  path: '/{module}/{page-name}/add',
  name: '{PageName}Add',
  component: () => import('@/views/{module}/{PageName}Form.vue'),
  meta: {
    title: '新增{Entity}',
    requiresAuth: true
  }
},
{
  path: '/{module}/{page-name}/:id',
  name: '{PageName}Detail',
  component: () => import('@/views/{module}/{PageName}Detail.vue'),
  meta: {
    title: '{Entity}详情',
    requiresAuth: true
  }
},
{
  path: '/{module}/{page-name}/:id/edit',
  name: '{PageName}Edit',
  component: () => import('@/views/{module}/{PageName}Form.vue'),
  meta: {
    title: '编辑{Entity}',
    requiresAuth: true
  }
}
```

### 5. Common Vant Components

#### Navigation
- `van-nav-bar` - Navigation bar with title and actions
- `van-tabbar` - Bottom tab bar
- `van-sidebar` - Side navigation

#### Data Display
- `van-list` - Infinite scroll list
- `van-cell` - Cell item for lists
- `van-card` - Product card
- `van-tag` - Tag label

#### Form Components
- `van-form` - Form container
- `van-field` - Input field
- `van-picker` - Picker selector
- `van-datetime-picker` - Date/time picker
- `van-uploader` - File uploader
- `van-switch` - Toggle switch
- `van-checkbox` - Checkbox
- `van-radio` - Radio button

#### Feedback
- `van-loading` - Loading indicator
- `van-toast` - Toast message (use `showToast()`)
- `van-dialog` - Dialog (use `showDialog()`, `showConfirmDialog()`)
- `van-action-sheet` - Action sheet
- `van-pull-refresh` - Pull to refresh

#### Other
- `van-button` - Button
- `van-icon` - Icon
- `van-image` - Image with lazy load
- `van-popup` - Popup layer
- `van-search` - Search bar

### 6. Mobile Best Practices

1. **Touch-Friendly**: Ensure buttons and clickable areas are at least 44x44px
2. **Loading States**: Show loading indicators for async operations
3. **Error Handling**: Use `showToast()` for error messages
4. **Pull to Refresh**: Implement pull-to-refresh for list pages
5. **Infinite Scroll**: Use `van-list` for long lists
6. **Confirmation**: Use `showConfirmDialog()` for destructive actions
7. **Navigation**: Always provide back button in nav bar
8. **Responsive**: Test on different screen sizes
9. **Performance**: Lazy load images and components
10. **Offline**: Handle network errors gracefully

### 7. Styling Guidelines

- Use Vant's design tokens for consistency
- Background color: `#f7f8fa` for pages
- Use `inset` prop for cell groups to add margins
- Add proper spacing between sections (16px)
- Use `round` prop for buttons
- Keep text readable (min 14px font size)
