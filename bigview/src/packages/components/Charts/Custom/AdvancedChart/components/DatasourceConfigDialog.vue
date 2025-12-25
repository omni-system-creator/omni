<template>
  <n-modal
    v-model:show="visible"
    preset="dialog"
    title="数据源配置"
    :style="{ width: '700px', maxHeight: '600px' }"
    :mask-closable="false"
    :closable="true"
    :show-icon="false"
  >
    <div class="datasource-dialog-content">
      <div v-if="datasourceList.length > 0" class="datasource-list">
        <div v-for="(item, index) in datasourceList" :key="index" class="datasource-item">
          <div class="datasource-header" @click="toggleCollapse(index)">
            <div class="datasource-title-wrapper">
              <n-icon class="collapse-icon" :class="{ 'collapsed': item.collapsed }">
                <svg viewBox="0 0 16 16" fill="currentColor">
                  <path d="M4.427 9.573l3.396-3.396a.25.25 0 01.354 0l3.396 3.396a.25.25 0 01-.177.427H4.604a.25.25 0 01-.177-.427z"/>
                </svg>
              </n-icon>
              <span class="datasource-title">{{ item.name || `数据源 ${index + 1}` }}</span>
            </div>
            <n-button size="small" type="error" @click.stop="removeDatasource(index)">删除</n-button>
          </div>
          
          <div v-show="!item.collapsed" class="datasource-content">
            <div class="datasource-basic">
              <div class="form-row-inline">
                <div class="form-field">
                  <label class="form-label">名称:</label>
                  <n-input v-model:value="item.name" size="small" placeholder="数据源名称" />
                </div>
                <div class="form-field">
                  <label class="form-label">类型:</label>
                  <n-select 
                    v-model:value="item.type" 
                    size="small" 
                    :options="datasourceTypeOptions"
                    placeholder="数据源类型"
                  />
                </div>
              </div>
            </div>
            
            <!-- 静态数据JSON输入 -->
            <div v-if="item.type === 'static-json'" class="static-data-config">
              <div class="form-row">
                <label class="form-label">静态数据 (JSON格式):</label>
              </div>
              <n-input
                v-model:value="item.staticData"
                type="textarea"
                size="small"
                placeholder="请输入JSON格式的数据，例如：&#10;[&#10;  {&quot;name&quot;: &quot;A&quot;, &quot;value&quot;: 100},&#10;  {&quot;name&quot;: &quot;B&quot;, &quot;value&quot;: 200}&#10;]"
                :autosize="{ minRows: 4, maxRows: 8 }"
                :status="getJsonValidationStatus(item.staticData || '') as any"
                @blur="validateJson(item, index)"
              />
              <div v-if="item.jsonError" class="json-error">
                {{ item.jsonError }}
              </div>
            </div>

            <!-- 静态数据CSV输入 -->
            <div v-if="item.type === 'static-csv'" class="static-data-config">
              <div class="form-row">
                <label class="form-label">静态数据 (CSV格式):</label>
              </div>
              <n-input
                v-model:value="item.csvData"
                type="textarea"
                size="small"
                placeholder="请输入CSV格式的数据，例如：&#10;name,value&#10;A,100&#10;B,200"
                :autosize="{ minRows: 4, maxRows: 8 }"
                :status="getCsvValidationStatus(item.csvData || '') as any"
                @blur="validateCsv(item, index)"
              />
              <div v-if="item.csvError" class="json-error">
                {{ item.csvError }}
              </div>
            </div>



            <!-- 文件数据JSON配置 -->
            <div v-if="item.type === 'file-json'" class="file-data-config">
              <div class="form-row">
                <label class="form-label">上传JSON文件:</label>
                <div class="file-upload-container">
                  <n-input 
                    :value="item.filePath || ''" 
                    size="small" 
                    placeholder="请选择JSON文件" 
                    readonly
                    style="flex: 1;"
                  />
                  <input 
                    type="file" 
                    accept=".json"
                    @change="handleFileUpload($event, item, index, 'json')"
                    style="display: none;"
                    :ref="(el: any) => fileInputRefs[`json-${index}`] = el"
                  />
                  <n-button 
                    size="small" 
                    type="primary" 
                    @click="triggerFileUpload(`json-${index}`)"
                    style="margin-left: 8px;"
                  >
                    选择文件
                  </n-button>
                </div>
              </div>
              <div v-if="item.filePath" class="file-info">
                <div class="info-item">
                  <span class="info-label">文件路径:</span>
                  <span class="info-value">{{ item.filePath }}</span>
                </div>
              </div>
              <div class="form-row" style="margin-top: 12px;" v-if="item.staticData">
                <label class="form-label">JSON数据预览:</label>
                <n-input
                  v-model:value="item.staticData"
                  type="textarea"
                  size="small"
                  placeholder="JSON数据预览"
                  readonly
                  :autosize="{ minRows: 3, maxRows: 6 }"
                />
              </div>
            </div>

            <!-- 文件数据CSV配置 -->
            <div v-if="item.type === 'file-csv'" class="file-data-config">
              <div class="form-row">
                <label class="form-label">上传CSV文件:</label>
                <div class="file-upload-container">
                  <n-input 
                    :value="item.filePath || ''" 
                    size="small" 
                    placeholder="请选择CSV文件" 
                    readonly
                    style="flex: 1;"
                  />
                  <input 
                    type="file" 
                    accept=".csv"
                    @change="handleFileUpload($event, item, index, 'csv')"
                    style="display: none;"
                    :ref="(el: any) => fileInputRefs[`csv-${index}`] = el"
                  />
                  <n-button 
                    size="small" 
                    type="primary" 
                    @click="triggerFileUpload(`csv-${index}`)"
                    style="margin-left: 8px;"
                  >
                    选择文件
                  </n-button>
                </div>
              </div>
              <div v-if="item.filePath" class="file-info">
                <div class="info-item">
                  <span class="info-label">文件路径:</span>
                  <span class="info-value">{{ item.filePath }}</span>
                </div>
              </div>
              <div class="form-row" style="margin-top: 12px;" v-if="item.csvData">
                <label class="form-label">CSV数据预览:</label>
                <n-input
                  v-model:value="item.csvData"
                  type="textarea"
                  size="small"
                  placeholder="CSV数据预览"
                  readonly
                  :autosize="{ minRows: 3, maxRows: 6 }"
                />
              </div>
            </div>

            <!-- 工作流实例数据源JSON配置 -->
            <div v-if="item.type === 'workflow-json'" class="workflow-data-config">
              <div class="form-row">
                <label class="form-label">工作流实例:</label>
                <div class="workflow-instance-selector">
                  <n-input 
                    :value="item.workflowInstance?.name || (item.workflowInstance?.defineName + '(ver: ' + item.workflowInstance?.version + ')')" 
                    size="small" 
                    style="flex: 1;"
                    placeholder="请选择工作流实例" 
                    readonly
                  />
                  <n-button 
                    size="small" 
                    type="primary" 
                    @click="openWorkflowInstanceDialog(index, 'json')"
                    style="margin-left: 8px;"
                  >
                    选择
                  </n-button>
                </div>
              </div>
              <div class="form-row" style="margin-top: 12px;">
                <label class="form-label">JSON数据示例:</label>
                <n-input
                  v-model:value="item.staticData"
                  type="textarea"
                  size="small"
                  placeholder="JSON数据示例"
                  readonly
                  :autosize="{ minRows: 3, maxRows: 6 }"
                />
              </div>
            </div>

            <!-- 工作流实例数据源CSV配置 -->
            <div v-if="item.type === 'workflow-csv'" class="workflow-data-config">
              <div class="form-row">
                <label class="form-label">工作流实例:</label>
                <div class="workflow-instance-selector">
                  <n-input 
                    :value="item.workflowInstance?.name || ''" 
                    size="small" 
                    style="flex: 1;"
                    placeholder="请选择工作流实例" 
                    readonly
                  />
                  <n-button 
                    size="small" 
                    type="primary" 
                    @click="openWorkflowInstanceDialog(index, 'csv')"
                    style="margin-left: 8px;"
                  >
                    选择
                  </n-button>
                </div>
              </div>
              <div v-if="item.workflowInstance" class="workflow-instance-info">
                <div class="info-item">
                  <span class="info-label">任务ID:</span>
                  <span class="info-value">{{ item.workflowInstance.taskId }}</span>
                </div>
                <div class="info-item" v-if="item.workflowInstance.name">
                  <span class="info-label">名称:</span>
                  <span class="info-value">{{ item.workflowInstance.name }}</span>
                </div>
              </div>
              <div class="form-row" style="margin-top: 12px;">
                <label class="form-label">CSV数据示例:</label>
                <n-input
                  v-model:value="item.csvData"
                  type="textarea"
                  size="small"
                  placeholder="CSV数据示例"
                  readonly
                  :autosize="{ minRows: 3, maxRows: 6 }"
                />
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <div v-else class="no-datasource">
        <n-empty description="暂无数据源配置" />
      </div>
      
      <div class="dialog-actions">
        <n-button type="primary" size="small" @click="addDatasource">添加数据源</n-button>
      </div>
    </div>

    <template #action>
      <n-space>
        <n-button @click="handleCancel">取消</n-button>
        <n-button type="primary" @click="handleConfirm">确定</n-button>
      </n-space>
    </template>
  </n-modal>

  <!-- 工作流实例选择对话框 -->
  <WorkflowInstanceSelector
    v-model="workflowInstanceDialogVisible"
    :format="currentDataFormat"
    @confirm="handleWorkflowInstanceConfirm"
    @cancel="handleWorkflowInstanceCancel"
    ref="workflowInstanceSelectorRef"
  />
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { NModal, NButton, NInput, NSelect, NSpace, NEmpty, NIcon, NDataTable, NSpin } from 'naive-ui'
import { parseCSVHeaders } from '@/utils/file'
import WorkflowInstanceSelector, { type WorkflowInstance } from './WorkflowInstanceSelector.vue'

interface DatasourceItem {
  name: string
  type: string
  url?: string
  staticData?: string
  csvData?: string
  jsonError?: string
  csvError?: string
  config?: any
  collapsed?: boolean
  workflowInstance?: WorkflowInstance
  filePath?: string // 文件相对路径
}

interface Props {
  modelValue: boolean
  datasources: DatasourceItem[]
}

interface Emits {
  (e: 'update:modelValue', value: boolean): void
  (e: 'update:datasources', value: DatasourceItem[]): void
  (e: 'confirm', value: DatasourceItem[]): void
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()

const visible = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const datasourceList = ref<DatasourceItem[]>([])

// 工作流实例相关状态
const workflowInstanceDialogVisible = ref(false)
const currentDatasourceIndex = ref<number>(-1)
const currentDataFormat = ref<string>('json') // 'json' 或 'csv'
const workflowInstanceSelectorRef = ref()

// 文件上传相关状态
const fileInputRefs = ref<Record<string, HTMLInputElement>>({})

// 数据源类型选项
const datasourceTypeOptions = [
  { label: '静态数据(JSON)', value: 'static-json' },
  { label: '静态数据(CSV)', value: 'static-csv' },
  { label: '数据文件(JSON)', value: 'file-json' },
  { label: '数据文件(CSV)', value: 'file-csv' },
  { label: '工作流实例数据(JSON)', value: 'workflow-json' },
  { label: '工作流实例数据(CSV)', value: 'workflow-csv' }
]

// 监听props变化，同步数据
watch(() => props.datasources, (newVal) => {
  datasourceList.value = JSON.parse(JSON.stringify(newVal)).map((item: DatasourceItem) => ({
    ...item,
    collapsed: item.collapsed ?? false
  }))
}, { immediate: true, deep: true })

// 添加数据源
const addDatasource = () => {
  datasourceList.value.push({
    name: ``,
    type: 'static-json',
    url: '',
    staticData: '',
    csvData: '',
    jsonError: '',
    csvError: '',
    config: {},
    collapsed: false,
    workflowInstance: undefined,
    filePath: ''
  })
}

// 切换折叠状态
const toggleCollapse = (index: number) => {
  datasourceList.value[index].collapsed = !datasourceList.value[index].collapsed
}

// 删除数据源
const removeDatasource = (index: number) => {
  datasourceList.value.splice(index, 1)
}

// 打开工作流实例选择对话框
const openWorkflowInstanceDialog = (index: number, format: string = 'json') => {
  currentDatasourceIndex.value = index
  currentDataFormat.value = format
  workflowInstanceDialogVisible.value = true
}

// 处理工作流实例确认选择
const handleWorkflowInstanceConfirm = async (selectedInstance: WorkflowInstance, format: string,  sampleData: any) => {
  if (currentDatasourceIndex.value >= 0) {
    const datasourceIndex = currentDatasourceIndex.value    
    // 保存选中的工作流实例信息
    datasourceList.value[datasourceIndex].workflowInstance = selectedInstance    
    try {      
      if (datasourceList.value[datasourceIndex].type === 'workflow-json') {
        datasourceList.value[datasourceIndex].staticData = JSON.stringify(sampleData, null, 2)
      } else if (datasourceList.value[datasourceIndex].type === 'workflow-csv') {
        datasourceList.value[datasourceIndex].csvData = sampleData
      }      
      window.$message?.success('工作流实例选择成功')
    } catch (error) {
      window.$message?.error('获取工作流实例数据失败')
    }
  }  
  // 重置状态
  currentDatasourceIndex.value = -1
}

// 处理工作流实例取消选择
const handleWorkflowInstanceCancel = () => {
  currentDatasourceIndex.value = -1
}

// JSON验证状态
const getJsonValidationStatus = (jsonStr: string) => {
  if (!jsonStr) return undefined
  try {
    const data = JSON.parse(jsonStr)
    if (!Array.isArray(data)) return 'error'
    if (data.length === 0) return 'error'
    if (!data.every(item => typeof item === 'object' && item !== null)) return 'error'
    return 'success'
  } catch {
    return 'error'
  }
}

// CSV验证状态
const getCsvValidationStatus = (csvStr?: string) => {
  if (!csvStr) return undefined
  try {
    const lines = csvStr.trim().split('\n')
    if (lines.length < 2) return 'error' // 至少需要表头和一行数据
    const headers = parseCSVHeaders(csvStr)
    if (headers.length === 0) return 'error'
    return 'success'
  } catch {
    return 'error'
  }
}

// CSV验证
const validateCsv = (item: DatasourceItem, index: number) => {
  if (!item.csvData) {
    item.csvError = ''
    return
  }

  try {
    const lines = item.csvData.trim().split('\n')
    if (lines.length < 2) {
      item.csvError = 'CSV数据至少需要包含表头和一行数据'
      return
    }
    
    const headers = parseCSVHeaders(item.csvData)
    if (headers.length === 0) {
      item.csvError = 'CSV表头不能为空'
      return
    }
    
    // 验证每行数据的字段数量是否一致
    const headerCount = headers.length
    for (let i = 1; i < lines.length; i++) {
      const fields = lines[i].split(',').map(field => field.trim())
      if (fields.length !== headerCount) {
        item.csvError = `第${i + 1}行数据字段数量(${fields.length})与表头字段数量(${headerCount})不匹配`
        return
      }
    }
    
    item.csvError = ''
  } catch (error) {
    item.csvError = 'CSV格式错误，请检查数据格式'
  }
}

// JSON验证
const validateJson = (item: DatasourceItem, index: number) => {
  if (!item.staticData) {
    item.jsonError = ''
    return
  }

  try {
    const data = JSON.parse(item.staticData)
    if (!Array.isArray(data)) {
      item.jsonError = '数据必须是数组格式'
      return
    }
    if (data.length === 0) {
      item.jsonError = '数据数组不能为空'
      return
    }
    if (!data.every(item => typeof item === 'object' && item !== null)) {
      item.jsonError = '数组中的每个元素都必须是对象'
      return
    }
    item.jsonError = ''
  } catch (error) {
    item.jsonError = 'JSON格式错误，请检查语法'
  }
}

// 触发文件上传
const triggerFileUpload = (refKey: string) => {
  const fileInput = fileInputRefs.value[refKey]
  if (fileInput) {
    fileInput.click()
  }
}

// 处理文件上传
const handleFileUpload = async (event: Event, item: DatasourceItem, index: number, fileType: 'json' | 'csv') => {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0]
  
  if (!file) return
  
  try {
    // 显示上传中状态
    window.$message?.loading('文件上传中...', { duration: 0, key: 'upload' })
    
    // 调用上传API
    const { uploadDatasourceFileApi } = await import('@/api/path/system.api')
    const response = await uploadDatasourceFileApi(file, fileType)
    
    if (response && response.data) {
      // 上传成功，保存文件信息
      item.filePath = response.data.filePath
      
      // 读取文件内容用于预览
      const reader = new FileReader()
      reader.onload = (e) => {
        const content = e.target?.result as string
        
        try {
          if (fileType === 'json') {
            // 处理JSON文件
            const jsonData = JSON.parse(content)
            if (Array.isArray(jsonData)) {
              // 取前几条数据作为示例
              const sampleData = jsonData.slice(0, 3)
              item.staticData = JSON.stringify(sampleData, null, 2)
              item.jsonError = ''
            } else {
              item.jsonError = 'JSON文件必须包含数组格式的数据'
            }
          } else if (fileType === 'csv') {
            // 处理CSV文件
            const lines = content.split('\n').filter(line => line.trim())
            if (lines.length > 0) {
              // 取前几行作为示例
              const sampleLines = lines.slice(0, 4) // 表头 + 3行数据
              item.csvData = sampleLines.join('\n')
              item.csvError = ''
            } else {
              item.csvError = 'CSV文件不能为空'
            }
          }
        } catch (error) {
          if (fileType === 'json') {
            item.jsonError = 'JSON文件格式错误'
          } else {
            item.csvError = 'CSV文件读取失败'
          }
        }
      }
      
      reader.onerror = () => {
        console.error('文件读取失败')
      }
      
      reader.readAsText(file, 'utf-8')
      
      // 关闭加载提示，显示成功消息
      window.$message?.destroyAll()
      window.$message?.success(`${fileType.toUpperCase()}文件上传成功`)
    } else {
      throw new Error('上传响应数据格式错误')
    }
  } catch (error) {
    console.error('文件上传失败:', error)
    // 关闭加载提示，显示错误消息
    window.$message?.destroyAll()
    window.$message?.error('文件上传失败，请重试')
    
    // 清空文件路径
    item.filePath = ''
  }
  
  // 清空input值，允许重复选择同一文件
  target.value = ''
}

// 取消
const handleCancel = () => {
  visible.value = false
}

// 确定
const handleConfirm = () => {
  // 验证所有数据
  let hasError = false
  datasourceList.value.forEach((item, index) => {
    if (item.type === 'static-json' && item.staticData) {
      validateJson(item, index)
      if (item.jsonError) {
        hasError = true
      }
    } else if (item.type === 'static-csv' && item.csvData) {
      validateCsv(item, index)
      if (item.csvError) {
        hasError = true
      }
    }
  })

  if (hasError) {
    return
  }

  emit('update:datasources', datasourceList.value)
  emit('confirm', datasourceList.value)
  visible.value = false
}
</script>

<style scoped>
.datasource-dialog-content {
  max-height: 450px;
  overflow-y: auto;
}

.datasource-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.datasource-item {
  padding: 16px;
  border: 1px solid #404040;
  border-radius: 6px;
  background-color: #2a2a2a;
  color: #e0e0e0;
}

.datasource-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
  cursor: pointer;
  padding: 8px;
  border-radius: 4px;
  transition: background-color 0.2s;
}

.datasource-header:hover {
  background-color: #3a3a3a;
}

.datasource-title-wrapper {
  display: flex;
  align-items: center;
  gap: 8px;
}

.collapse-icon {
  width: 16px;
  height: 16px;
  transition: transform 0.2s;
  color: #cccccc;
}

.collapse-icon.collapsed {
  transform: rotate(-90deg);
}

.datasource-title {
  font-weight: 600;
  font-size: 14px;
  color: #ffffff;
}

.datasource-content {
  padding-left: 24px;
}

.datasource-basic {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.form-row-inline {
  display: flex;
  gap: 16px;
  align-items: flex-start;
}

.form-field {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.form-row {
  display: flex;
  align-items: center;
  gap: 8px;
}

.form-label {
  min-width: 80px;
  font-weight: 500;
  color: #cccccc;
  white-space: nowrap;
  font-size: 12px;
}

.static-data-config {
  margin-top: 12px;
}

.workflow-data-config {
  margin-top: 12px;
}

.workflow-instance-config {
  margin-top: 12px;
}

.workflow-instance-selector {
  flex: 1;
  display: flex;
  align-items: center;
}

.workflow-instance-info {
  margin-top: 12px;
  padding: 12px;
  background-color: #1a1a1a;
  border-radius: 4px;
  border: 1px solid #404040;
}

.info-item {
  display: flex;
  align-items: center;
  margin-bottom: 8px;
}

.info-item:last-child {
  margin-bottom: 0;
}

.info-label {
  min-width: 80px;
  font-weight: 500;
  color: #cccccc;
  font-size: 12px;
}

.info-value {
  color: #ffffff;
  font-size: 12px;
}

.json-error {
  color: #d03050;
  font-size: 12px;
  margin-top: 4px;
}

.no-datasource {
  text-align: center;
  padding: 40px 0;
}

.dialog-actions {
  margin-top: 16px;
  text-align: center;
}

.file-data-config {
  margin-top: 12px;
}

.file-upload-container {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 8px;
}

.file-info {
  margin-top: 12px;
  padding: 12px;
  background-color: #1a1a1a;
  border-radius: 4px;
  border: 1px solid #404040;
}
</style>