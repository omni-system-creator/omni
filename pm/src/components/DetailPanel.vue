<script setup lang="ts">
import { useProjectStore } from '../stores/projectStore'
import { computed, ref } from 'vue'
import { NModal, NButton, NUpload, NColorPicker, NSelect, useMessage, type UploadCustomRequestOptions } from 'naive-ui'

const store = useProjectStore()
const message = useMessage()

const ownerOptions = computed(() => {
    return store.users.map(u => ({ label: u.name, value: u.name }))
})

const taskOwners = computed({
    get: () => {
        if (!task.value || !task.value.owner) return []
        return task.value.owner.split(',').filter(Boolean)
    },
    set: (vals: string[]) => {
        if (task.value) {
            task.value.owner = vals.join(',')
            saveTaskChange()
        }
    }
})

// Delete Modal State
const showDeleteModal = ref(false)
const deleteModalContent = ref('')
const deleteModalAction = ref<(() => void) | null>(null)

const confirmDelete = () => {
  if (deleteModalAction.value) {
    deleteModalAction.value()
  }
  showDeleteModal.value = false
}

const openDeleteModal = (content: string, action: () => void) => {
  deleteModalContent.value = content
  deleteModalAction.value = action
  showDeleteModal.value = true
}

const selectedElement = computed(() => store.selectedElement)

const task = computed(() => {
  if (selectedElement.value?.type === 'task') return store.tasks.find(t => t.id === selectedElement.value?.id)
  return null
})

const phase = computed(() => {
  if (selectedElement.value?.type === 'phase') return store.phases.find(p => p.id === selectedElement.value?.id)
  return null
})

const swimlane = computed(() => {
  if (selectedElement.value?.type === 'swimlane') return store.swimlanes.find(s => s.id === selectedElement.value?.id)
  return null
})

const dependency = computed(() => {
    if (selectedElement.value?.type === 'dependency') {
        const [sourceId, targetId] = selectedElement.value.id.split('|')
        const sourceTask = store.tasks.find(t => t.id === sourceId)
        const targetTask = store.tasks.find(t => t.id === targetId)
        
        let type = 'curve' // Default
        let controlPointCount = 2
        if (targetTask) {
             const dep = targetTask.dependencies.find(d => (typeof d === 'string' ? d : d.taskId) === sourceId)
             if (dep && typeof dep !== 'string') {
                 if (dep.type) type = dep.type
                 if (dep.controlPointCount) controlPointCount = dep.controlPointCount
             }
        }
        
        return { sourceId, targetId, sourceTask, targetTask, type, controlPointCount }
    }
    return null
})

const port = computed(() => {
    const sel = selectedElement.value
    if (sel?.type === 'port' && sel.taskId) {
        const t = store.tasks.find(t => t.id === sel.taskId)
        if (t && t.ports) {
            const p = t.ports.find(p => p.id === sel.id)
            if (p) return { ...p, task: t }
        }
    }
    return null
})

// Gradient Presets
const gradientPresets = [
  { name: '默认蓝', start: '#ffffff', end: '#B3E5FC' },
  { name: '清新绿', start: '#E8F5E9', end: '#66BB6A' },
  { name: '活力橙', start: '#FFF3E0', end: '#FFA726' },
  { name: '热情红', start: '#FFEBEE', end: '#EF5350' },
  { name: '高贵紫', start: '#F3E5F5', end: '#AB47BC' },
  { name: '天空蓝', start: '#E3F2FD', end: '#42A5F5' },
  { name: '优雅灰', start: '#F5F5F5', end: '#BDBDBD' },
  { name: '柠檬黄', start: '#FFFDE7', end: '#FFEE58' },
];

const quickColors = [
  '#ffffff', '#f0f0f0', '#cccccc', '#999999', '#333333', '#000000', // Grayscale
  '#B3E5FC', '#2196F3', '#0D47A1', // Blues
  '#C8E6C9', '#4CAF50', '#1B5E20', // Greens
  '#FFE0B2', '#FF9800', '#E65100', // Oranges
  '#FFCDD2', '#F44336', '#B71C1C', // Reds
  '#E1BEE7', '#9C27B0', '#4A148C', // Purples
  '#FFF9C4', '#FFEB3B', '#FBC02D', // Yellows
];

const applyGradient = (preset: { start: string, end: string }) => {
  if (task.value) {
    task.value.startColor = preset.start;
    task.value.endColor = preset.end;
    saveTaskChange();
  }
};

const saveTaskChange = () => {
    if (task.value) {
        // Trigger save and socket emit via store action
        // Since v-model already mutated the store object, we can pass a dummy update or the full object
        // But store.updateTask expects Partial<Task> and merges it. 
        // We need to call it to trigger side effects (auto-save + socket).
        // Passing the changed fields would be cleaner, but we don't track diffs here easily.
        // Passing the whole task properties that might have changed is safe.
        store.updateTask(task.value.id, {
            name: task.value.name,
            owner: task.value.owner,
            status: task.value.status,
            progress: task.value.progress,
            startDate: task.value.startDate,
            endDate: task.value.endDate,
            description: task.value.description,
            startColor: task.value.startColor,
            endColor: task.value.endColor
        });
    }
}

const close = () => {
  store.clearSelection()
}

const deleteTask = () => {
  if (task.value) {
    openDeleteModal('确定删除该任务吗？', () => {
      if (task.value) {
        store.deleteTask(task.value.id)
        store.clearSelection()
      }
    })
  }
}

const deletePhase = () => {
  if (phase.value) {
    openDeleteModal('确定删除该阶段吗？这将删除该阶段下的所有任务。', () => {
      if (phase.value) {
        store.deletePhase(phase.value.id)
        store.clearSelection()
      }
    })
  }
}

const deleteSwimlane = () => {
  if (swimlane.value) {
    openDeleteModal('确定删除该专业吗？这将删除该专业下的所有任务。', () => {
      if (swimlane.value) {
        store.deleteSwimlane(swimlane.value.id)
        store.clearSelection()
      }
    })
  }
}

const removeAttachment = async (attId: string, attName: string) => {
  if (task.value) {
    // 1. Get Project ID from URL
    const path = window.location.pathname
    const match = path.match(/\/project\/([^/]+)/)
    const projectId = match && match[1] ? match[1] : store.projectInfo.code;

    try {
        // 2. Call Delete API
        const response = await fetch(`/api/project/${projectId}/task/${task.value.id}/attachment/${encodeURIComponent(attName)}`, {
            method: 'DELETE'
        });

        if (response.ok) {
             // 3. Remove from store
             store.removeAttachment(task.value.id, attId)
             message.success('附件删除成功')
        } else {
             message.error('附件删除失败')
        }
    } catch (e) {
        console.error(e);
        message.error('附件删除出错')
    }
  }
}

const customUploadRequest = async ({ file, data, onFinish, onError }: UploadCustomRequestOptions) => {
    if (!task.value) return;
    
    const formData = new FormData();
    if (data) {
        Object.keys(data).forEach((key) => {
            formData.append(key, (data as any)[key]);
        });
    }
    formData.append('file', file.file as File);

    // Get Project ID
    const path = window.location.pathname
    const match = path.match(/\/project\/([^/]+)/)
    const projectId = match && match[1] ? match[1] : store.projectInfo.code;

    try {
        const response = await fetch(`/api/project/${projectId}/task/${task.value.id}/attachment`, {
            method: 'POST',
            body: formData,
        });

        if (!response.ok) {
            throw new Error('Upload failed');
        }

        const result = await response.json();
        
        // Add to store
        store.addAttachment(task.value.id, {
            id: 'a' + Date.now(),
            name: result.file.name,
            url: result.file.url,
            type: 'file', // You might want to map extension to type
            uploadDate: new Date().toISOString().split('T')[0] || ''
        });
        
        message.success('上传成功');
        onFinish();
    } catch (e) {
        console.error(e);
        message.error('上传失败');
        onError();
    }
};

const updateDependencyType = (e: Event) => {
    const newType = (e.target as HTMLSelectElement).value as 'straight' | 'polyline' | 'curve'
    if (dependency.value && dependency.value.sourceId && dependency.value.targetId) {
        const depVal = dependency.value
        store.updateDependencyType(depVal.sourceId!, depVal.targetId!, newType)
    }
}

const updateDependencyControlPointCount = (e: Event) => {
    const count = parseInt((e.target as HTMLSelectElement).value)
    if (dependency.value && dependency.value.sourceId && dependency.value.targetId) {
        store.updateDependencyControlPointCount(dependency.value.sourceId!, dependency.value.targetId!, count)
    }
}

const deleteDependency = () => {
    if (dependency.value && dependency.value.sourceId && dependency.value.targetId) {
        openDeleteModal('确定删除该连线吗？', () => {
            if (dependency.value && dependency.value.sourceId && dependency.value.targetId) {
              store.removeDependency(dependency.value.sourceId, dependency.value.targetId)
              store.clearSelection()
            }
        })
    }
}

const deletePort = () => {
    if (port.value) {
        openDeleteModal('确定删除该连接点吗？', () => {
            if (port.value) {
              store.removeTaskPort(port.value.task.id, port.value.id)
              store.selectElement('task', port.value.task.id)
            }
        })
    }
}

const updatePortPercentage = (e: Event) => {
    const val = parseFloat((e.target as HTMLInputElement).value)
    if (port.value) {
        store.updateTaskPort(port.value.task.id, port.value.id, val)
    }
}

</script>

<template>
  <div v-if="selectedElement" class="detail-panel">
    
    <!-- Task Detail -->
    <div v-if="task">
      <div class="panel-header">
        <h3>任务详情</h3>
        <button class="close-btn" @click="close">×</button>
      </div>
      <div class="panel-content">
        <div class="field">
          <label>编号:</label>
          <span>{{ task.id }}</span>
        </div>
        <div class="field">
          <label>名称:</label>
          <input v-model="task.name" @change="saveTaskChange" />
        </div>
        <div class="field">
          <label>负责人:</label>
          <n-select 
            v-model:value="taskOwners" 
            multiple 
            :options="ownerOptions" 
            placeholder="选择负责人"
          />
        </div>
        <div class="field">
          <label>状态:</label>
          <select v-model="task.status" @change="saveTaskChange">
            <option value="pending">未开始</option>
            <option value="in_progress">进行中</option>
            <option value="completed">已完成</option>
            <option value="delayed">延期</option>
          </select>
        </div>
        <div class="field">
          <label>进度:</label>
          <input type="range" v-model.number="task.progress" min="0" max="100" @change="saveTaskChange" />
          <span>{{ task.progress }}%</span>
        </div>
        <div class="field">
          <label>开始时间:</label>
          <input type="date" v-model="task.startDate" @change="saveTaskChange" />
        </div>
        <div class="field">
          <label>结束时间:</label>
          <input type="date" v-model="task.endDate" @change="saveTaskChange" />
        </div>
        
        <div class="field">
          <label>进度条样式:</label>
          <div class="color-picker-group">
            <div class="color-input">
               <span>起始色:</span>
               <div class="color-control">
                  <n-color-picker 
                    v-model:value="task.startColor" 
                    :swatches="quickColors" 
                    @update:value="saveTaskChange"
                    class="custom-color-picker"
                  />
               </div>
            </div>
            <div class="color-input">
               <span>结束色:</span>
               <div class="color-control">
                  <n-color-picker 
                    v-model:value="task.endColor" 
                    :swatches="quickColors" 
                    @update:value="saveTaskChange"
                    class="custom-color-picker"
                  />
               </div>
            </div>
          </div>
          <div class="preset-colors">
             <div 
               v-for="(preset, index) in gradientPresets" 
               :key="index" 
               class="preset-swatch"
               :style="{ background: `linear-gradient(to right, ${preset.start}, ${preset.end})` }"
               @click="applyGradient(preset)"
               :title="preset.name"
             ></div>
          </div>
        </div>

        <div class="field">
          <label>附件:</label>
          <ul class="attachment-list">
            <li v-for="att in task.attachments" :key="att.id">
              <a :href="att.url" target="_blank">{{ att.name }}</a>
              <span class="remove-att" @click="removeAttachment(att.id, att.name)" title="删除附件">×</span>
            </li>
          </ul>
          
          <n-upload
            :custom-request="customUploadRequest"
            :show-file-list="false"
          >
            <n-button class="btn-sm">上传附件</n-button>
          </n-upload>
        </div>

        <div class="field">
          <label>备注:</label>
          <textarea v-model="task.description" @change="saveTaskChange" />
        </div>

        <div class="actions">
            <button class="btn-danger" @click="deleteTask">删除任务</button>
        </div>
      </div>
    </div>

    <!-- Phase Detail -->
    <div v-if="phase">
      <div class="panel-header">
        <h3>阶段详情</h3>
        <button class="close-btn" @click="close">×</button>
      </div>
      <div class="panel-content">
        <div class="field">
          <label>名称:</label>
          <input v-model="phase.name" />
        </div>
        <div class="field">
          <label>颜色:</label>
          <n-color-picker 
            v-model:value="phase.color" 
            :swatches="quickColors" 
            class="custom-color-picker"
          />
        </div>
        <div class="actions">
            <button class="btn-danger" @click="deletePhase">删除阶段</button>
        </div>
      </div>
    </div>

    <!-- Swimlane Detail -->
    <div v-if="swimlane">
      <div class="panel-header">
        <h3>专业详情</h3>
        <button class="close-btn" @click="close">×</button>
      </div>
      <div class="panel-content">
        <div class="field">
          <label>名称:</label>
          <input v-model="swimlane.name" />
        </div>
        <div class="field">
          <label>颜色:</label>
          <n-color-picker 
            v-model:value="swimlane.color" 
            :swatches="quickColors" 
            class="custom-color-picker"
          />
        </div>
        <div class="actions">
            <button class="btn-danger" @click="deleteSwimlane">删除专业</button>
        </div>
      </div>
    </div>

    <!-- Dependency Detail -->
    <div v-if="dependency">
      <div class="panel-header">
        <h3>连线详情</h3>
        <button class="close-btn" @click="close">×</button>
      </div>
      <div class="panel-content">
        <div class="field">
          <label>起点任务:</label>
          <span>{{ dependency.sourceTask?.name || dependency.sourceId }}</span>
        </div>
        <div class="field">
          <label>终点任务:</label>
          <span>{{ dependency.targetTask?.name || dependency.targetId }}</span>
        </div>
        <div class="field">
            <label>连线类型:</label>
            <select :value="dependency.type" @change="updateDependencyType">
                <option value="polyline">折线</option>
                <option value="straight">直线</option>
                <option value="curve">曲线</option>
            </select>
        </div>
        <div class="field" v-if="dependency.type === 'curve'">
            <label>曲线控制点:</label>
            <select :value="dependency.controlPointCount || 2" @change="updateDependencyControlPointCount">
                <option :value="2">2个 (简单)</option>
                <option :value="3">3个 (中等)</option>
                <option :value="4">4个 (复杂)</option>
            </select>
        </div>
        <div class="actions">
            <button class="btn-danger" @click="deleteDependency">删除连线</button>
        </div>
      </div>
    </div>

    <!-- Port Detail -->
    <div v-if="port">
      <div class="panel-header">
        <h3>连接点详情</h3>
        <button class="close-btn" @click="close">×</button>
      </div>
      <div class="panel-content">
        <div class="field">
          <label>所属任务:</label>
          <span>{{ port.task.name }}</span>
        </div>
        <div class="field">
          <label>方向:</label>
          <span>{{ port.side === 'top' ? '上' : port.side === 'bottom' ? '下' : port.side === 'left' ? '左' : '右' }}</span>
        </div>
        <div class="field">
          <label>位置比例:</label>
          <div style="display: flex; align-items: center; gap: 10px;">
            <input 
                type="range" 
                :value="port.percentage" 
                min="0.1" 
                max="0.9" 
                step="0.01"
                @input="updatePortPercentage"
                style="flex: 1;"
            />
            <span style="min-width: 40px; text-align: right;">{{ (port.percentage * 100).toFixed(0) }}%</span>
          </div>
        </div>
        <div class="actions">
            <button class="btn-danger" @click="deletePort">删除连接点</button>
        </div>
      </div>
    </div>
    <n-modal
      v-model:show="showDeleteModal"
      preset="dialog"
      title="确认删除"
      :content="deleteModalContent"
      positive-text="确认"
      negative-text="取消"
      @positive-click="confirmDelete"
      @negative-click="showDeleteModal = false"
    />
  </div>
</template>

<style scoped>
.detail-panel {
  width: 300px;
  background: white;
  border-left: 1px solid #ccc;
  padding: 20px;
  box-shadow: -2px 0 5px rgba(0,0,0,0.1);
  display: flex;
  flex-direction: column;
  height: 100%;
  overflow-y: auto;
}

.color-picker-group {
  display: flex;
  gap: 10px;
  margin-bottom: 10px;
}

.color-input {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 5px;
}

.color-input span {
  font-size: 12px;
  color: #666;
}

.color-control {
  display: flex;
  align-items: center;
  gap: 10px;
  flex: 1;
}

.custom-color-picker {
  height: 40px;
  width: 120px;
}
:deep(.n-color-picker-trigger) {
  height: 100% !important;
}

.preset-colors {
  display: flex;
  flex-wrap: wrap;
  gap: 5px;
  margin-top: 5px;
}

.preset-swatch {
  width: 24px;
  height: 24px;
  border-radius: 4px;
  cursor: pointer;
  border: 1px solid #ddd;
  transition: transform 0.2s;
}

.preset-swatch:hover {
  transform: scale(1.1);
  box-shadow: 0 2px 4px rgba(0,0,0,0.2);
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  border-bottom: 1px solid #eee;
  padding-bottom: 10px;
}

.close-btn {
  background: none;
  border: none;
  font-size: 20px;
  cursor: pointer;
}

.field {
  margin-bottom: 15px;
  display: flex;
  flex-direction: column;
}

label {
  font-weight: bold;
  margin-bottom: 5px;
  font-size: 0.9em;
}

input, select {
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
}

.actions {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

.btn-danger {
  background: #ff4444;
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 4px;
  cursor: pointer;
}

.btn-danger:hover {
  background: #cc0000;
}

.attachment-list {
  list-style: none;
  padding: 0;
  margin: 5px 0 10px 0;
}
.attachment-list li {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 5px;
  background: #f9f9f9;
  border-radius: 4px;
  margin-bottom: 5px;
  font-size: 0.9em;
}
.attachment-list a {
  text-decoration: none;
  color: #2196F3;
  max-width: 200px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.remove-att {
  cursor: pointer;
  color: #999;
  font-weight: bold;
  padding: 0 5px;
}
.remove-att:hover {
  color: red;
}
.btn-sm {
  background: #eee;
  border: 1px solid #ddd;
  padding: 5px 10px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.85em;
  align-self: flex-start;
}
.btn-sm:hover {
  background: #e0e0e0;
}

textarea {
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
  min-height: 80px;
  resize: vertical;
}
</style>
