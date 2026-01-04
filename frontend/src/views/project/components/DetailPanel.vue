<script setup lang="ts">
import { useProjectFlowStore } from '@/stores/projectFlowStore';
import { computed } from 'vue';
import { Modal, message } from 'ant-design-vue';
import type { UploadRequestOption } from 'ant-design-vue/es/vc-upload/interface';
import { UploadOutlined } from '@ant-design/icons-vue';

const store = useProjectFlowStore();

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

const close = () => {
  store.clearSelection()
}

const saveTaskChange = () => {
  if (task.value) {
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
};

const applyGradient = (preset: { start: string, end: string }) => {
  if (task.value) {
    task.value.startColor = preset.start;
    task.value.endColor = preset.end;
    saveTaskChange();
  }
};

const deleteTask = () => {
  if (task.value) {
    Modal.confirm({
      title: '确认删除',
      content: '确定删除该任务吗？',
      okText: '确认',
      cancelText: '取消',
      onOk() {
        if (task.value) {
          store.deleteTask(task.value.id)
          store.clearSelection()
        }
      }
    })
  }
}

const deletePhase = () => {
  if (phase.value) {
    Modal.confirm({
      title: '确认删除',
      content: '确定删除该阶段吗？这将删除该阶段下的所有任务。',
      okText: '确认',
      cancelText: '取消',
      onOk() {
        if (phase.value) {
          store.deletePhase(phase.value.id)
          store.clearSelection()
        }
      }
    })
  }
}

const deleteSwimlane = () => {
  if (swimlane.value) {
    Modal.confirm({
      title: '确认删除',
      content: '确定删除该专业吗？这将删除该专业下的所有任务。',
      okText: '确认',
      cancelText: '取消',
      onOk() {
        if (swimlane.value) {
          store.deleteSwimlane(swimlane.value.id)
          store.clearSelection()
        }
      }
    })
  }
}

const removeAttachment = async (attId: string, attName: string) => {
  if (task.value) {
    // 1. Get Project ID from URL or store
    const projectId = store.projectInfo.code;

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

const customUploadRequest = async ({ file, onSuccess, onError }: UploadRequestOption) => {
    if (!task.value) return;
    
    const formData = new FormData();
    formData.append('file', file as File);

    // Get Project ID
    const projectId = store.projectInfo.code;

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
            type: 'file', 
            uploadDate: new Date().toISOString().split('T')[0] || ''
        });
        
        message.success('上传成功');
        if (onSuccess) onSuccess(result);
    } catch (e) {
        console.error(e);
        message.error('上传失败');
        if (onError) onError(e as Error);
    }
};

const updateDependencyType = (val: 'straight' | 'polyline' | 'curve') => {
    const newType = val
    if (dependency.value && dependency.value.sourceId && dependency.value.targetId) {
        store.updateDependencyType(dependency.value.sourceId!, dependency.value.targetId!, newType)
    }
}

const updateDependencyControlPointCount = (val: number) => {
    const count = val
    if (dependency.value && dependency.value.sourceId && dependency.value.targetId) {
        store.updateDependencyControlPointCount(dependency.value.sourceId!, dependency.value.targetId!, count)
    }
}

const deleteDependency = () => {
    if (dependency.value && dependency.value.sourceId && dependency.value.targetId) {
        Modal.confirm({
            title: '确认删除',
            content: '确定删除该连线吗？',
            okText: '确认',
            cancelText: '取消',
            onOk() {
                if (dependency.value && dependency.value.sourceId && dependency.value.targetId) {
                  store.removeDependency(dependency.value.sourceId, dependency.value.targetId)
                  store.clearSelection()
                }
            }
        })
    }
}

const deletePort = () => {
    if (port.value) {
        Modal.confirm({
            title: '确认删除',
            content: '确定删除该连接点吗？',
            okText: '确认',
            cancelText: '取消',
            onOk() {
                if (port.value) {
                  store.removeTaskPort(port.value.task.id, port.value.id)
                  store.selectElement('task', port.value.task.id)
                }
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
          <a-input v-model:value="task.name" @change="saveTaskChange" />
        </div>

        <div class="field">
          <label>负责人:</label>
          <a-input v-model:value="task.owner" @change="saveTaskChange" />
        </div>
        <div class="field">
          <label>状态:</label>
          <a-select v-model:value="task.status" @change="saveTaskChange" style="width: 100%">
            <a-select-option value="pending">未开始</a-select-option>
            <a-select-option value="in_progress">进行中</a-select-option>
            <a-select-option value="completed">已完成</a-select-option>
            <a-select-option value="delayed">延期</a-select-option>
          </a-select>
        </div>
        <div class="field">
          <label>进度:</label>
          <div style="display: flex; align-items: center; gap: 10px;">
              <input type="range" v-model.number="task.progress" min="0" max="100" @change="saveTaskChange" style="flex:1" />
              <span>{{ task.progress }}%</span>
          </div>
        </div>
        <div class="field">
          <label>开始时间:</label>
          <a-input v-model:value="task.startDate" type="date" @change="saveTaskChange" />
        </div>
        <div class="field">
          <label>结束时间:</label>
          <a-input v-model:value="task.endDate" type="date" @change="saveTaskChange" />
        </div>
        
        <div class="field">
          <label>进度条样式:</label>
          <div class="color-picker-group">
            <div class="color-input">
               <span>起始色:</span>
               <div class="color-control">
                  <input type="color" v-model="task.startColor" @change="saveTaskChange" />
               </div>
            </div>
            <div class="color-input">
               <span>结束色:</span>
               <div class="color-control">
                  <input type="color" v-model="task.endColor" @change="saveTaskChange" />
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
          
          <a-upload
            :custom-request="customUploadRequest"
            :show-upload-list="false"
          >
            <a-button>
                <upload-outlined />
                上传附件
            </a-button>
          </a-upload>
        </div>

        <div class="field">
          <label>备注:</label>
          <textarea v-model="task.description" @change="saveTaskChange" placeholder="请输入备注信息"></textarea>
        </div>

        <div class="actions">
            <a-button danger @click="deleteTask">删除任务</a-button>
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
          <a-input v-model:value="phase.name" />
        </div>
        <div class="field">
          <label>颜色:</label>
          <input type="color" v-model="phase.color" style="width: 100%; height: 32px; padding: 2px;" />
          <div class="preset-colors">
             <div 
               v-for="(color, index) in quickColors" 
               :key="index" 
               class="preset-swatch"
               :style="{ background: color }"
               @click="phase.color = color"
             ></div>
          </div>
        </div>
        <div class="actions">
            <a-button danger @click="deletePhase">删除阶段</a-button>
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
          <a-input v-model:value="swimlane.name" />
        </div>
        <div class="field">
          <label>颜色:</label>
          <input type="color" v-model="swimlane.color" style="width: 100%; height: 32px; padding: 2px;" />
          <div class="preset-colors">
             <div 
               v-for="(color, index) in quickColors" 
               :key="index" 
               class="preset-swatch"
               :style="{ background: color }"
               @click="swimlane.color = color"
             ></div>
          </div>
        </div>
        <div class="actions">
            <a-button danger @click="deleteSwimlane">删除专业</a-button>
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
            <a-select :value="dependency.type" @change="updateDependencyType" style="width: 100%">
                <a-select-option value="polyline">折线</a-select-option>
                <a-select-option value="straight">直线</a-select-option>
                <a-select-option value="curve">曲线</a-select-option>
            </a-select>
        </div>
        <div class="field" v-if="dependency.type === 'curve'">
            <label>曲线控制点:</label>
            <a-select :value="dependency.controlPointCount || 2" @change="updateDependencyControlPointCount" style="width: 100%">
                <a-select-option :value="2">2个 (简单)</a-select-option>
                <a-select-option :value="3">3个 (中等)</a-select-option>
                <a-select-option :value="4">4个 (复杂)</a-select-option>
            </a-select>
        </div>
        <div class="actions">
            <a-button danger @click="deleteDependency">删除连线</a-button>
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
            <a-button danger @click="deletePort">删除连接点</a-button>
        </div>
      </div>
    </div>
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

.actions {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
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

textarea {
  width: 100%;
  height: 80px;
  padding: 8px;
  border: 1px solid #d9d9d9;
  border-radius: 4px;
  resize: vertical;
}
</style>
