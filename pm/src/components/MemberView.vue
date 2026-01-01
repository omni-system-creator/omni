<script setup lang="ts">
import { computed, h, ref, onMounted, onUnmounted, watch } from 'vue'
import { useProjectStore } from '../stores/projectStore'
import { NDataTable, NProgress } from 'naive-ui'
import type { DataTableColumns } from 'naive-ui'
import * as echarts from 'echarts'

const store = useProjectStore()

interface MemberStat {
    name: string
    total: number
    completed: number
    inProgress: number
    delayed: number
    pending: number
    avgProgress: number
}

const memberStats = computed(() => {
    const stats: Record<string, MemberStat> = {}
    
    store.tasks.forEach(task => {
        const owners = task.owner ? task.owner.split(',').filter(Boolean) : ['未分配']
        
        owners.forEach(owner => {
            if (!stats[owner]) {
                stats[owner] = {
                    name: owner,
                    total: 0,
                    completed: 0,
                    inProgress: 0,
                    delayed: 0,
                    pending: 0,
                    avgProgress: 0
                }
            }
            
            stats[owner].total++
            if (task.status === 'completed') stats[owner].completed++
            else if (task.status === 'in_progress') stats[owner].inProgress++
            else if (task.status === 'delayed') stats[owner].delayed++
            else stats[owner].pending++
            
            // Accumulate progress for average calculation
            // task.progress is 0-100
            stats[owner].avgProgress += (task.progress || 0)
        })
    })
    
    return Object.values(stats).map(s => ({
        ...s,
        avgProgress: s.total > 0 ? Math.round(s.avgProgress / s.total) : 0
    })).sort((a, b) => b.total - a.total)
})

const chartRef = ref<HTMLElement | null>(null)
let chartInstance: echarts.ECharts | null = null

const initChart = () => {
    if (!chartRef.value) return
    chartInstance = echarts.init(chartRef.value)
    updateChart()
}

const updateChart = () => {
    if (!chartInstance) return
    
    const names = memberStats.value.map(s => s.name)
    const completed = memberStats.value.map(s => s.completed)
    const inProgress = memberStats.value.map(s => s.inProgress)
    const delayed = memberStats.value.map(s => s.delayed)
    const pending = memberStats.value.map(s => s.pending)

    const option = {
        title: {
            text: '人员任务统计',
            left: 'center'
        },
        tooltip: {
            trigger: 'axis',
            axisPointer: { type: 'shadow' }
        },
        legend: {
            data: ['已完成', '进行中', '延期', '未开始'],
            bottom: 0
        },
        grid: {
            left: '3%',
            right: '4%',
            bottom: '10%',
            containLabel: true
        },
        xAxis: {
            type: 'category',
            data: names
        },
        yAxis: {
            type: 'value'
        },
        series: [
            {
                name: '已完成',
                type: 'bar',
                stack: 'total',
                emphasis: { focus: 'series' },
                data: completed,
                color: '#18a058'
            },
            {
                name: '进行中',
                type: 'bar',
                stack: 'total',
                emphasis: { focus: 'series' },
                data: inProgress,
                color: '#2080f0'
            },
            {
                name: '延期',
                type: 'bar',
                stack: 'total',
                emphasis: { focus: 'series' },
                data: delayed,
                color: '#d03050'
            },
            {
                name: '未开始',
                type: 'bar',
                stack: 'total',
                emphasis: { focus: 'series' },
                data: pending,
                color: '#909399'
            }
        ]
    }
    chartInstance.setOption(option)
}

const handleResize = () => {
    chartInstance?.resize()
}

onMounted(() => {
    initChart()
    window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
    window.removeEventListener('resize', handleResize)
    chartInstance?.dispose()
})

watch(memberStats, () => {
    updateChart()
})

const columns: DataTableColumns<MemberStat> = [
    { 
        title: '序号',
        key: 'index',
        width: 60,
        align: 'center',
        render: (_, index) => `${index + 1}`
    },
    { 
        title: '人员姓名', 
        key: 'name',
        sorter: (a, b) => a.name.localeCompare(b.name)
    },
    { 
        title: '任务总数', 
        key: 'total', 
        sorter: (a, b) => a.total - b.total 
    },
    { 
        title: '已完成', 
        key: 'completed', 
        sorter: (a, b) => a.completed - b.completed 
    },
    { 
        title: '进行中', 
        key: 'inProgress', 
        sorter: (a, b) => a.inProgress - b.inProgress 
    },
    { 
        title: '延期', 
        key: 'delayed', 
        sorter: (a, b) => a.delayed - b.delayed,
        render(row) {
            return h('span', { style: { color: row.delayed > 0 ? 'red' : 'inherit', fontWeight: row.delayed > 0 ? 'bold' : 'normal' } }, row.delayed)
        }
    },
    { 
        title: '未开始', 
        key: 'pending', 
        sorter: (a, b) => a.pending - b.pending 
    },
    { 
        title: '平均进度', 
        key: 'avgProgress',
        sorter: (a, b) => a.avgProgress - b.avgProgress,
        render(row) {
            return h(NProgress, {
                type: 'line',
                percentage: row.avgProgress,
                indicatorPlacement: 'inside',
                processing: row.avgProgress < 100 && row.avgProgress > 0,
                color: row.avgProgress === 100 ? '#18a058' : '#2080f0' // Green if 100%, Blue otherwise
            })
        }
    }
]
</script>

<template>
    <div class="member-view-container">
        <div class="chart-wrapper">
            <div ref="chartRef" class="chart-container"></div>
        </div>
        <n-data-table
            :columns="columns"
            :data="memberStats"
            :pagination="{ pageSize: 15 }"
            :bordered="false"
            striped
            class="member-table"
        />
    </div>
</template>

<style scoped>
.member-view-container {
    width: 100%;
    height: 100%;
    background: #f0f2f5;
    display: flex;
    flex-direction: column;
    overflow: auto;
}
.chart-wrapper {
    background: white;
    padding: 20px;
    margin-bottom: 20px;
    flex-shrink: 0;
}
.chart-container {
    width: 100%;
    height: 350px;
}
.member-table {
    flex: 1;
}
:deep(.n-data-table-wrapper) {
    background: white;
    border-radius: 0;
    box-shadow: none;
}
</style>
