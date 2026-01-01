<script setup lang="ts">
import { ref, computed } from 'vue'
import { useProjectFlowStore } from '@/stores/projectFlowStore'
import { Select, Tag } from 'ant-design-vue'

const store = useProjectFlowStore()

const groupingKey = ref<'phase' | 'swimlane' | 'status'>('phase')

const groupingOptions = [
  { label: '按阶段分组', value: 'phase' },
  { label: '按专业分组', value: 'swimlane' },
  { label: '按状态分组', value: 'status' }
]

const statusMap: Record<string, string> = {
    pending: '未开始',
    in_progress: '进行中',
    completed: '已完成',
    delayed: '延期'
}

const statusColors: Record<string, string> = {
    pending: '#9E9E9E',
    in_progress: '#2196F3',
    completed: '#4CAF50',
    delayed: '#F44336'
}

const columns = computed(() => {
    if (groupingKey.value === 'phase') {
        return store.phases.map(p => ({
            id: p.id,
            name: p.name,
            color: p.color,
            borderColor: p.color,
            tasks: store.tasks.filter(t => t.phaseId === p.id)
        }))
    } else if (groupingKey.value === 'swimlane') {
        return store.swimlanes.map(s => ({
            id: s.id,
            name: s.name,
            color: s.color,
            borderColor: s.color,
            tasks: store.tasks.filter(t => t.swimlaneId === s.id)
        }))
    } else {
        // Status
        const statuses = ['pending', 'in_progress', 'completed', 'delayed']
        return statuses.map(s => ({
            id: s,
            name: statusMap[s],
            color: '#f9f9f9',
            borderColor: statusColors[s],
            tasks: store.tasks.filter(t => t.status === s)
        }))
    }
})

const getTaskColor = (task: any) => {
    const progress = task.progress || 0;
    const startColor = task.startColor || 'white';
    const endColor = task.endColor || '#B3E5FC';
    return `linear-gradient(to right, ${startColor} 0%, ${endColor} ${progress}%, white ${progress}%, white 100%)`
}

const openTaskDetail = (task: any) => {
    store.selectElement('task', task.id)
}

</script>

<template>
  <div class="kanban-container">
    <div class="toolbar">
        <span class="label">分组方式:</span>
        <Select v-model:value="groupingKey" :options="groupingOptions" class="group-select" size="small" />
    </div>
    
    <div class="board-container">
        <div class="board">
            <div 
                v-for="col in columns" 
                :key="col.id" 
                class="column"
            >
                <div class="column-header" :style="{ borderTopColor: col.borderColor || '#ccc' }">
                    <div class="column-title">
                        {{ col.name }} 
                        <Tag :bordered="false" class="count-tag">
                            {{ col.tasks.length }}
                        </Tag>
                    </div>
                </div>
                
                <div class="column-content">
                    <div class="task-list">
                        <div 
                            v-for="task in col.tasks" 
                            :key="task.id" 
                            class="task-card"
                            :class="{ selected: store.selectedElement?.id === task.id }"
                            @click="openTaskDetail(task)"
                        >
                            <div class="task-bg" :style="{ background: getTaskColor(task) }"></div>
                            <div class="task-content-wrapper">
                                <div class="task-header">
                                    <span class="task-name">{{ task.name }}</span>
                                </div>
                                <div class="task-meta">
                                    <Tag :color="task.status === 'completed' ? 'success' : task.status === 'delayed' ? 'error' : task.status === 'in_progress' ? 'processing' : 'default'" :bordered="false">
                                        {{ statusMap[task.status] }}
                                    </Tag>
                                    <span class="owner">{{ task.owner }}</span>
                                </div>
                                <div class="task-dates" v-if="task.startDate && task.endDate">
                                    {{ task.startDate.slice(5) }} ~ {{ task.endDate.slice(5) }}
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
  </div>
</template>

<style scoped>
.kanban-container {
    display: flex;
    flex-direction: column;
    height: 100%;
    width: 100%;
    background-color: #f0f2f5;
}

.toolbar {
    padding: 10px 20px;
    background: white;
    border-bottom: 1px solid #eee;
    display: flex;
    align-items: center;
    gap: 10px;
    flex-shrink: 0;
}

.group-select {
    width: 200px;
}

.board-container {
    flex: 1;
    overflow-x: auto;
    overflow-y: hidden;
    position: relative;
}

.board {
    display: flex;
    flex-direction: row;
    padding: 20px;
    gap: 20px;
    height: 100%;
    box-sizing: border-box;
    min-width: 100%;
    width: max-content;
}

.column {
    min-width: 320px;
    width: 320px;
    display: flex;
    flex-direction: column;
    background: #f7f7f7;
    border-radius: 8px;
    height: 100%;
    border: 1px solid #e0e0e0;
    box-shadow: 0 1px 3px rgba(0,0,0,0.05);
}

.column-header {
    padding: 12px 16px;
    font-weight: bold;
    font-size: 15px;
    background: white;
    border-top: 3px solid #ccc;
    border-radius: 8px 8px 0 0;
    border-bottom: 1px solid #eee;
}

.column-title {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.count-tag {
    background: #eee;
    color: #666;
    border-radius: 10px;
    font-size: 12px;
}

.column-content {
    flex: 1;
    overflow-y: auto;
    padding: 10px;
}

.task-list {
    display: flex;
    flex-direction: column;
    gap: 10px;
}

.task-card {
    background: white;
    border-radius: 6px;
    box-shadow: 0 1px 2px rgba(0,0,0,0.1);
    cursor: pointer;
    position: relative;
    overflow: hidden;
    transition: all 0.2s;
    border: 1px solid transparent;
}

.task-card:hover {
    box-shadow: 0 4px 8px rgba(0,0,0,0.1);
    transform: translateY(-2px);
}

.task-card.selected {
    border-color: #2196F3;
    box-shadow: 0 0 0 2px rgba(33, 150, 243, 0.2);
}

.task-bg {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    opacity: 0.3;
    pointer-events: none;
    z-index: 0;
}

.task-content-wrapper {
    position: relative;
    z-index: 1;
    padding: 12px;
}

.task-header {
    margin-bottom: 8px;
    font-weight: 500;
    font-size: 14px;
    line-height: 1.4;
    color: #333;
}

.task-meta {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 6px;
}

.owner {
    font-size: 12px;
    color: #666;
}

.task-dates {
    font-size: 12px;
    color: #999;
    text-align: right;
}
</style>