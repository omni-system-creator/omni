<template>
  <!-- 工作流实例选择对话框 -->
  <n-modal
    v-model:show="visible"
    preset="dialog"
    title="选择工作流实例"
    :style="{ width: '1200px', maxHeight: '700px' }"
    :mask-closable="false"
    :closable="true"
    :show-icon="false"
  >
    <div class="workflow-instance-dialog-content">
      <!-- 筛选区域 -->
      <div class="filter-section">
        <div style="display: flex; align-items: center; gap: 16px;">
          <div style="display: flex; align-items: center; gap: 8px; flex: 1;">
            <label style="font-size: 14px; color: #999; font-weight: 500; white-space: nowrap;">实例名称:</label>
            <n-input
              v-model:value="filterForm.name"
              placeholder="按实例名称搜索"
              clearable
              @keyup.enter="handleSearch"
              style="flex: 1;"
            />
          </div>
          <div style="display: flex; align-items: center; gap: 8px; flex: 1;">
            <label style="font-size: 14px; color: #999; font-weight: 500; white-space: nowrap;">流程定义:</label>
            <n-input
              v-model:value="filterForm.defineName"
              placeholder="按流程定义名称搜索"
              clearable
              @keyup.enter="handleSearch"
              style="flex: 1;"
            />
          </div>
          <div style="display: flex; align-items: center; gap: 8px; flex: 1;">
            <label style="font-size: 14px; color: #999; font-weight: 500; white-space: nowrap;">创建时间:</label>
            <n-date-picker
              v-model:value="filterForm.createTimeRange"
              type="datetimerange"
              clearable
              format="yyyy-MM-dd HH:mm:ss"
              value-format="yyyy-MM-dd HH:mm:ss"
              placeholder="选择时间区间"
              style="flex: 1;"
            />
          </div>
          <div style="display: flex; gap: 8px; flex-shrink: 0;">
            <n-button @click="handleReset">重置</n-button>
            <n-button type="primary" @click="handleSearch">搜索</n-button>
          </div>
        </div>
      </div>

      <!-- 表格容器，设置相对定位 -->
      <div class="table-container">
        <div v-if="loading" class="loading-container">
          <n-spin size="medium" />
          <span style="margin-left: 12px;">正在加载工作流实例列表...</span>
        </div>
        
        <div v-else-if="workflowInstanceList.length > 0" class="workflow-instance-list">
          <n-data-table
            :columns="workflowInstanceColumns"
            :data="workflowInstanceList"
            :pagination="false"
            :max-height="400"
            :row-key="(row: WorkflowInstance) => row.taskId"
            :checked-row-keys="selectedKeys"
            @update:checked-row-keys="handleSelect"
            @row-click="handleRowClick"
            :row-props="rowProps"
            single-line
            size="small"
          />
        </div>
        
        <div v-else class="no-workflow-instance">
          <n-empty description="暂无工作流实例" />
        </div>

        <!-- 数据预览浮层 -->
        <div v-if="sampleDataPreview" class="data-preview-overlay">
          <div class="data-preview-modal">
            <div class="preview-header">
              <h4 style="margin: 0; color: #333;">数据预览</h4>
              <n-button 
                size="small" 
                quaternary 
                @click="closeSampleDataPreview"
                style="color: #999;"
              >
                <template #icon>
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/>
                  </svg>
                </template>
                关闭预览
              </n-button>
            </div>
            
            <!-- 数据加载状态 -->
            <div v-if="dataLoading" class="data-loading-container">
              <n-spin size="small" />
              <span style="margin-left: 8px; color: #666;">正在加载数据预览...</span>
            </div>
            
            <!-- 数据内容 -->
            <div v-else class="preview-content">
              <div v-if="props.format === 'json'" class="json-preview">
                <pre class="json-content">{{ JSON.stringify(sampleData, null, 2) }}</pre>
              </div>
              <div v-else-if="props.format === 'csv'" class="csv-preview">
                <pre class="csv-content">{{ sampleData }}</pre>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <template #action>
      <div style="display: flex; justify-content: space-between; align-items: center; width: 100%;">
        <!-- 分页组件 -->
        <div class="pagination-container">
          <n-pagination
            v-model:page="pagination.page"
            v-model:page-size="pagination.pageSize"
            :item-count="totalCount"
            :page-sizes="[10, 20, 50, 100]"
            show-size-picker
            show-quick-jumper
            :show-total="true"
            @update:page="handlePageChange"
            @update:page-size="handlePageSizeChange"
          >
            <template #prefix="{ itemCount }">
              共 {{ itemCount }} 条
            </template>
          </n-pagination>
        </div>
        
        <!-- 操作按钮 -->
        <n-space>
          <n-button @click="handleCancel">取消</n-button>
          <n-button 
            type="primary" 
            @click="handleConfirm"
            :disabled="selectedKeys.length === 0"
          >
            确定
          </n-button>
        </n-space>
      </div>
    </template>
  </n-modal>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { 
  NModal, 
  NButton, 
  NSpace, 
  NEmpty, 
  NDataTable, 
  NSpin, 
  NInput, 
  NDatePicker, 
  NDivider, 
  NPagination 
} from 'naive-ui'
import { getWorkflowInstanceList, getWorkflowInstanceData } from '@/api/path/system.api'

export interface WorkflowInstance {
  taskId: string
  name: string
  endTime?: string
  createBy?: string
  defineName?: string
  version?: string
}

interface Props {
  modelValue: boolean
  format?: string // 'json' 或 'csv'
}

interface Emits {
  (e: 'update:modelValue', value: boolean): void
  (e: 'confirm', instance: WorkflowInstance, format: string, sampleData: any): void
  (e: 'cancel'): void
}

// 筛选表单接口
interface FilterForm {
  name: string
  defineName: string
  createTimeRange: [string, string] | null
}

// 分页接口
interface Pagination {
  page: number
  pageSize: number
}

const props = withDefaults(defineProps<Props>(), {
  format: 'json'
})

const emit = defineEmits<Emits>()

const visible = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

// 状态管理
const loading = ref(false)
const dataLoading = ref(false) // 数据预览加载状态
const workflowInstanceList = ref<WorkflowInstance[]>([])
const selectedKeys = ref<string[]>([])
const sampleData = ref<any>()
const sampleDataPreview = ref(false)
const totalCount = ref(0) // 总记录数

// 筛选表单
const filterForm = ref<FilterForm>({
  name: '',
  defineName: '',
  createTimeRange: null
})

// 分页状态
const pagination = ref<Pagination>({
  page: 1,
  pageSize: 10
})

// 日期时间格式化函数
const formatDateTime = (dateTime: string | Date): string => {
  if (!dateTime) return '-'
  
  try {
    // 处理各种日期格式
    let date: Date
    if (typeof dateTime === 'string') {
      // 如果是ISO格式的字符串，直接解析
      date = new Date(dateTime)
    } else {
      date = dateTime
    }
    
    if (isNaN(date.getTime())) {
      console.warn('Invalid date:', dateTime)
      return String(dateTime) // 返回原始字符串而不是 '-'
    }
    
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    const hours = String(date.getHours()).padStart(2, '0')
    const minutes = String(date.getMinutes()).padStart(2, '0')
    const seconds = String(date.getSeconds()).padStart(2, '0')
    
    return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`
  } catch (error) {
    console.error('Date formatting error:', error, dateTime)
    return String(dateTime) // 返回原始字符串
  }
}

// 工作流实例表格列配置
const workflowInstanceColumns = [
  {
    type: 'selection',
    multiple: false
  },
  {
    title: '实例名称',
    key: 'name',
    ellipsis: {
      tooltip: true
    },
    render: (row: WorkflowInstance) => {
      return row.name || '--'
    }
  },
  {
    title: '流程定义',
    key: 'defineName',
    ellipsis: {
      tooltip: true
    }
  },
  {
    title: '版本号',
    key: 'version',
    align: 'center',
    width: 80
  },
  {
    title: '创建时间',
    key: 'endTime',
    width: 180,
    render: (row: WorkflowInstance) => {
      if (!row.endTime) return '--'
      const formatted = formatDateTime(row.endTime)
      return formatted
    }
  },
  {
    title: '操作员',
    key: 'createBy',
    align: 'center',
    width: 120,
    render: (row: WorkflowInstance) => {
      return row.createBy || '--'
    }
  }
]

// 监听对话框显示状态，自动加载数据
watch(visible, (newVal) => {
  if (newVal) {
    loadWorkflowInstanceList()
  } else {
    // 关闭时重置状态
    selectedKeys.value = []
    resetFilter()
  }
})

// 加载工作流实例列表
const loadWorkflowInstanceList = async () => {
  selectedKeys.value = []
  loading.value = true
  try {
    // 构建查询参数
    const params: any = {
      pageNum: pagination.value.page,
      pageSize: pagination.value.pageSize,
      orderByColumn: 'endTime',
      isAsc: 'desc'
    }
    
    // 添加筛选条件
    if (filterForm.value.name) {
      params.name = filterForm.value.name
    }
    
    if (filterForm.value.defineName) {
      params.defineName = filterForm.value.defineName
    }
    
    if (filterForm.value.createTimeRange && filterForm.value.createTimeRange.length === 2) {
      // 将时间戳转换为 yyyy-MM-dd HH:mm:ss 格式的字符串
      params.startTime = formatDateTime(new Date(filterForm.value.createTimeRange[0]))
      params.endTime = formatDateTime(new Date(filterForm.value.createTimeRange[1]))
    }
    
    const res = await getWorkflowInstanceList(params)
    workflowInstanceList.value = res.rows || []
    totalCount.value = res.total || 0
  } catch (error) {
    console.error('加载工作流实例列表失败:', error)
    workflowInstanceList.value = []
    totalCount.value = 0
  } finally {
    loading.value = false
  }
}

// 处理工作流实例选择
const handleSelect = (keys: string[]) => {
  selectedKeys.value = keys
}

// 处理行点击选中
const handleRowClick = async (row: WorkflowInstance) => {
  const taskId = row.taskId
  const currentIndex = selectedKeys.value.indexOf(taskId)
  
  if (currentIndex > -1) {
    selectedKeys.value = []
    sampleData.value = null // 清空预览数据
  } else {
    try {
      sampleDataPreview.value = true
      dataLoading.value = true
      const res = await getWorkflowInstanceData({ taskId, format: props.format, size: 5})
      console.log('+++', res)
      if(res && (props.format === 'csv' && res.data) || (props.format === 'json' && res.data.length > 0)) {
        sampleData.value = res.data;
        selectedKeys.value = [taskId]
      } else {
        // 没有数据时显示提示信息
        sampleData.value = 'NO_DATA';
        sampleDataPreview.value = false
        selectedKeys.value = []
        window.$message?.warning('该流程实例没有可用数据')
      }
    } catch (error) {
      sampleDataPreview.value = false
      console.error('获取数据预览失败:', error)
      window.$message?.error('获取数据预览失败')
    } finally {
      dataLoading.value = false // 结束加载状态
    }
  }
}

// 关闭数据预览
const closeSampleDataPreview = () => {
  sampleDataPreview.value = false
}

// 行属性配置，添加点击样式
const rowProps = (row: WorkflowInstance) => {
  return {
    style: 'cursor: pointer;',
    onClick: () => handleRowClick(row)
  }
}

// 处理搜索
const handleSearch = () => {
  sampleDataPreview.value = false
  pagination.value.page = 1 // 重置到第一页
  loadWorkflowInstanceList() // 重新加载数据
}

// 处理重置
const handleReset = () => {
  resetFilter()
  sampleDataPreview.value = false
  pagination.value.page = 1
  loadWorkflowInstanceList() // 重新加载数据
}

// 重置筛选条件
const resetFilter = () => {
  filterForm.value = {
    name: '',
    defineName: '',
    createTimeRange: null
  }
}

// 处理分页变化
const handlePageChange = (page: number) => {
  pagination.value.page = page
  loadWorkflowInstanceList() // 重新加载数据
}

// 处理每页条数变化
const handlePageSizeChange = (pageSize: number) => {
  pagination.value.pageSize = pageSize
  pagination.value.page = 1 // 重置到第一页
  loadWorkflowInstanceList() // 重新加载数据
}

// 处理取消
const handleCancel = () => {
  selectedKeys.value = []
  sampleData.value = null // 清空预览数据
  sampleDataPreview.value = false
  visible.value = false
  emit('cancel')
}

// 处理确认
const handleConfirm = () => {
  if (selectedKeys.value.length === 0) {
    window.$message?.warning('请选择一个工作流实例')
    return
  }
  
  sampleDataPreview.value = false
  const selectedInstance = workflowInstanceList.value.find(
    item => item.taskId === selectedKeys.value[0]
  )
  
  if (selectedInstance) {
    emit('confirm', selectedInstance, props.format, sampleData.value)
    visible.value = false
  }
}
</script>

<style scoped>
.workflow-instance-dialog-content {
  max-height: 550px;
  overflow-y: auto;
}

.filter-section {
  padding: 16px 0 0 0;
  border-radius: 6px;
  margin-bottom: 16px;
}

.loading-container {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40px 0;
  color: #cccccc;
}

.workflow-instance-list {
  margin-top: 16px;
}

.pagination-container {
  display: flex;
  justify-content: flex-start;
}

.no-workflow-instance {
  text-align: center;
  padding: 40px 0;
}

/* 表格容器 */
.table-container {
  position: relative;
  min-height: 400px;
}

/* 数据预览浮层 */
.data-preview-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  backdrop-filter: blur(2px);
}

.data-preview-modal {
  background-color: #fff;
  border-radius: 8px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.15);
  max-width: 80%;
  max-height: 80%;
  min-width: 600px;
  min-height: 300px;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.preview-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  border-bottom: 1px solid #e0e0e6;
  background-color: #f8f9fa;
  flex-shrink: 0;
}

.data-loading-container {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40px;
  color: #666;
  flex: 1;
}

.preview-content {
  flex: 1;
  overflow-y: auto;
  min-height: 200px;
}

.no-data-tip {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 200px;
  color: #999;
}

.json-content, .csv-content {
  margin: 0;
  padding: 16px;
  border-radius: 6px;
  font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
  font-size: 13px;
  line-height: 1.5;
  color: #333;
  white-space: pre-wrap;
  word-break: break-all;
}
</style>