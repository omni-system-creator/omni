<script setup lang="ts">
import { ref, computed } from 'vue'
import { useProjectStore } from '../stores/projectStore'
import { NSelect, NTag, NScrollbar } from 'naive-ui'

const store = useProjectStore()

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
    // 任务背景色逻辑：如果设置了渐变色，使用渐变色
    // 默认样式：白蓝渐变
    const progress = task.progress || 0;
    const startColor = task.startColor || 'white';
    const endColor = task.endColor || '#B3E5FC';
    
    // 为了保证文字可读性，这里我们只在底部显示一个细进度条，或者整个背景淡一点？
    // 用户的需求是“卡片在分组内竖向滚动”，并没有特别指定卡片样式。
    // 为了美观，我们使用纯色背景，然后在底部显示进度条，或者使用轻微的渐变。
    // 既然之前的任务列表和泳道图都用了那个渐变，这里保持一致可能比较好，
    // 但是在小卡片上，强烈的渐变可能影响阅读。
    // 让我们稍微调整一下，使用白色背景，底部加一个进度条指示器。
    
    // 但是根据用户之前对于“颜色一致性”的要求，也许他希望看到同样的视觉效果。
    // 我们先试着用同样的渐变背景。
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
        <n-select v-model:value="groupingKey" :options="groupingOptions" class="group-select" size="small" />
    </div>
    
    <div class="board-container">
        <n-scrollbar x-scrollable style="height: 100%" :content-style="{ height: '100%' }">
            <div class="board">
                <div 
                    v-for="col in columns" 
                    :key="col.id" 
                    class="column"
                >
            <div class="column-header" :style="{ borderTopColor: col.borderColor || '#ccc' }">
                <div class="column-title">
                    {{ col.name }} 
                    <n-tag round size="small" :bordered="false" class="count-tag">
                        {{ col.tasks.length }}
                    </n-tag>
                </div>
            </div>
            
            <div class="column-content">
                <n-scrollbar>
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
                                    <n-tag size="tiny" :type="task.status === 'completed' ? 'success' : task.status === 'delayed' ? 'error' : task.status === 'in_progress' ? 'info' : 'default'" :bordered="false">
                                        {{ statusMap[task.status] }}
                                    </n-tag>
                                    <span class="owner">{{ task.owner }}</span>
                                </div>
                                <div class="task-dates" v-if="task.startDate && task.endDate">
                                    {{ task.startDate.slice(5) }} ~ {{ task.endDate.slice(5) }}
                                </div>
                            </div>
                        </div>
                    </div>
                </n-scrollbar>
                </div>
            </div>
            </div>
        </n-scrollbar>
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
    overflow: hidden;
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
    width: max-content; /* 强制宽度适应内容 */
}

.column {
    min-width: 320px;
    width: 320px;
    display: flex;
    flex-direction: column;
    background: #f7f7f7;
    border-radius: 8px;
    height: 100%; /* Adapt to container height */
    border: 1px solid #e0e0e0;
    box-shadow: 0 1px 3px rgba(0,0,0,0.05);
}

.column-header {
    padding: 12px 16px;
    font-weight: bold;
    font-size: 15px;
    background: white;
    border-bottom: 1px solid #eee;
    border-top: 4px solid transparent; 
    border-radius: 8px 8px 0 0;
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-shrink: 0;
}

.count-tag {
    margin-left: 8px;
    background-color: #f0f0f0;
    color: #666;
}

.column-content {
    flex: 1;
    overflow: hidden; /* For scrollbar */
    padding: 0;
    position: relative;
}

.task-list {
    padding: 12px;
    display: flex;
    flex-direction: column;
    gap: 10px;
    min-height: 100%; /* Ensure drop targets work if we add DnD later */
}

.task-card {
    background: white;
    border: 1px solid #e0e0e0;
    border-radius: 6px;
    cursor: pointer;
    transition: all 0.2s;
    box-shadow: 0 1px 2px rgba(0,0,0,0.05);
    position: relative;
    overflow: hidden;
}

.task-bg {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    opacity: 0.3; /* Make the gradient background subtle so text is readable */
    z-index: 0;
}

.task-content-wrapper {
    position: relative;
    z-index: 1;
    padding: 12px;
}

.task-card:hover {
    box-shadow: 0 4px 12px rgba(0,0,0,0.1);
    transform: translateY(-2px);
    border-color: #ccc;
}

.task-card.selected {
    border-color: #2196F3;
    box-shadow: 0 0 0 2px rgba(33, 150, 243, 0.2);
}

.task-name {
    font-weight: 600;
    color: #333;
    margin-bottom: 8px;
    display: block;
    line-height: 1.4;
}

.task-meta {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: 8px;
}

.owner {
    font-size: 12px;
    color: #666;
}

.task-dates {
    font-size: 11px;
    color: #999;
    margin-top: 6px;
}
</style>