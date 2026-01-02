<template>
  <div class="gantt-view">
    <!-- Toolbar -->
    <Teleport to="#tab-toolbar-target" v-if="mounted">
      <div class="gantt-toolbar" v-show="isActive">
        <a-space>
          <a-select v-model:value="zoomLevel" style="width: 120px" :options="zoomOptions" size="small" />
          <a-button @click="scrollToToday" size="small">回到今天</a-button>
        </a-space>
      </div>
    </Teleport>

    <!-- Main Split View -->
    <div class="gantt-content">
      <!-- Left: Task List (Tree Table) -->
      <div class="gantt-sidebar" :style="{ width: sidebarWidth + 'px' }">
        <div class="sidebar-header" ref="sidebarHeaderRef">
          <div class="col-id">ID</div>
          <div class="col-name">名称</div>
          <div class="col-progress">进度</div>
          <div class="col-owner">负责人</div>
          <div class="col-pred">前置任务</div>
          <div class="col-date">开始时间</div>
          <div class="col-date">结束时间</div>
        </div>
        <div class="sidebar-body" ref="leftBodyRef" @scroll="handleLeftScroll">
          <div 
            v-for="row in visibleRows" 
            :key="row.id"
            class="sidebar-row"
            :class="{ 'row-phase': row.type === 'phase', 'row-selected': selectedTaskId === row.id }"
            @click="scrollToTask(row)"
          >
            <!-- Phase Row -->
            <template v-if="row.type === 'phase'">
              <div class="col-id">{{ row.rowNumber }}</div>
              <div class="col-name" style="padding-left: 8px; font-weight: bold;">
                <span 
                  class="expand-icon" 
                  @click.stop="toggleExpand(row.id)"
                >
                  <component :is="row.expanded ? DownOutlined : RightOutlined" />
                </span>
                {{ row.name }}
              </div>
              <div class="col-progress">{{ row.progress }}%</div>
              <div class="col-owner"></div>
              <div class="col-pred"></div>
              <div class="col-date"></div>
              <div class="col-date"></div>
            </template>

            <!-- Task Row -->
            <template v-else>
              <div class="col-id">{{ row.rowNumber }}</div>
              <div class="col-name" :style="{ paddingLeft: (row.depth * 20 + 8) + 'px' }">
                {{ row.name }}
              </div>
              <div class="col-progress" :style="getProgressStyle(row)">
                {{ row.progress }}%
              </div>
              <div class="col-owner">{{ row.owner }}</div>
              <div class="col-pred">{{ row.predecessors }}</div>
              <div class="col-date">{{ formatDate(row.startDate) }}</div>
              <div class="col-date">{{ formatDate(row.endDate) }}</div>
            </template>
          </div>
          <div :style="{ height: bottomSpacerHeight + 'px' }"></div>
        </div>
      </div>

      <!-- Splitter -->
      <div 
        class="gantt-splitter" 
        @mousedown="startResize"
        :class="{ 'resizing': isResizing }"
      ></div>

      <!-- Right: Gantt Chart -->
      <div class="gantt-chart">
        <!-- Timeline Header -->
        <div class="timeline-header" ref="rightHeaderRef" @mousemove="handleHeaderMouseMove" @mouseleave="handleHeaderMouseLeave">
          <div class="timeline-row top-row">
            <div 
              v-for="(block, i) in timelineHeaders.topRow" 
              :key="i"
              class="header-block"
              :style="{ width: block.width + 'px', left: block.left + 'px' }"
            >
              {{ block.label }}
            </div>
          </div>
          <div class="timeline-row bottom-row">
            <div 
              v-for="(block, i) in timelineHeaders.bottomRow" 
              :key="i"
              class="header-block"
              :style="{ width: block.width + 'px', left: block.left + 'px' }"
            >
              {{ block.label }}
            </div>
          </div>
        </div>

        <!-- Canvas Body -->
        <div 
          class="timeline-body" 
          ref="rightScrollRef" 
          @scroll="handleRightScroll"
          @wheel="handleWheel"
        >
          <div 
            class="canvas-container" 
            ref="ganttContainerRef" 
            :style="{ width: totalWidth + 'px', height: totalHeight + 'px' }"
          ></div>
        </div>
        
        <!-- Tooltip -->
        <div 
          v-if="tooltip.visible" 
          class="gantt-tooltip" 
          :style="{ left: tooltip.x + 'px', top: tooltip.y + 'px' }"
        >
          {{ tooltip.text }}
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, watch, nextTick, onActivated, onDeactivated } from 'vue'
import { useProjectFlowStore } from '@/stores/projectFlowStore'
import { App, Rect, Text, Group, Path, Line, PointerEvent as LeaferPointerEvent, DragEvent, Leafer } from 'leafer-ui'
import '@leafer-in/find'
import '@leafer-in/animate'
import { holiday } from '@kang8/chinese-holidays'
import { DownOutlined, RightOutlined } from '@ant-design/icons-vue'

const mounted = ref(false);
onMounted(() => {
  mounted.value = true;
});

const props = defineProps<{
  isActive: boolean;
}>();

const store = useProjectFlowStore()

// --- Helpers ---
const parseLocalDate = (dateStr: string) => {
    if (!dateStr) return new Date();
    const datePart = dateStr.split('T')[0];
    if (datePart) {
        const parts = datePart.split('-');
        if (parts.length === 3) {
            const y = parseInt(parts[0]!, 10);
            const m = parseInt(parts[1]!, 10) - 1;
            const d = parseInt(parts[2]!, 10);
            return new Date(y, m, d);
        }
    }
    return new Date(dateStr);
}

const formatDate = (dateStr: string) => {
    if (!dateStr) return '';
    const date = parseLocalDate(dateStr);
    const y = date.getFullYear();
    const m = String(date.getMonth() + 1).padStart(2, '0');
    const d = String(date.getDate()).padStart(2, '0');
    const datePart = `${y}-${m}-${d}`;
    
    // Check if time is 00:00:00 (which it is for parseLocalDate result if string was YYYY-MM-DD)
    // But if the original string had time, parseLocalDate strips it?
    // Wait, parseLocalDate implementation:
    // if dateStr has 'T', it splits and takes [0]. So it ALWAYS returns 00:00:00.
    // So parseLocalDate effectively strips time.
    
    // If the user wants to show time if it exists, I should NOT use parseLocalDate for the formatting check
    // if the input string has time.
    
    // However, if the requirement is "if 0 point just show year month day", and parseLocalDate strips time,
    // then using parseLocalDate will ALWAYS show 00:00:00, so I will ALWAYS show just date.
    
    // Let's check the user's requirement again: "Start time and end time if 0 point just show year month day".
    // This implies if it's NOT 0 point, show time.
    // So I should parse the original string properly to check for time.
    
    const originalDate = new Date(dateStr);
    if (isNaN(originalDate.getTime())) return '';
    
    const h = originalDate.getHours();
    const min = originalDate.getMinutes();
    const s = originalDate.getSeconds();
    
    if (h === 0 && min === 0 && s === 0) {
        return datePart;
    }
    
    const hh = String(h).padStart(2, '0');
    const mm = String(min).padStart(2, '0');
    return `${datePart} ${hh}:${mm}`;
}

const getProgressStyle = (row: any) => {
    if (!row.data) return {};
    // Use calculated progress from row, fallback to data
    const progress = row.progress !== undefined ? row.progress : (row.data.progress || 0);
    
    const startColor = row.data.startColor || 'white';
    // Use row.color (phase color or swimlane color) as the end color
    const endColor = row.color || row.data.endColor || '#B3E5FC';
    
    // Status border only for tasks
    const borderColor = row.type === 'task' ? (statusColors[row.data.status] || '#ccc') : '#e0e0e0';
    
    // CSS Linear Gradient
    return {
        background: `linear-gradient(to right, ${startColor} 0%, ${endColor} ${progress}%, white ${progress}%, white 100%)`,
        borderBottom: `2px solid ${borderColor}`, 
        textAlign: 'center' as any,
        color: '#333' 
    }
}

const getPolylinePoints = (startX: number, startY: number, endX: number, endY: number) => {
    const points: { x: number; y: number }[] = [];
    let exitDist = 20;
    let entryDist = 20;

    if (endX > startX + 10 && (endX - startX) < (exitDist + entryDist)) {
        const mid = (endX - startX) / 2;
        exitDist = mid;
        entryDist = mid;
    }

    points.push({ x: startX, y: startY });
    const pExit = { x: startX + exitDist, y: startY };
    const pEntry = { x: endX - entryDist, y: endY };

    if (pExit.x <= pEntry.x + 1) {
        const midX = (pExit.x + pEntry.x) / 2;
        points.push(pExit);
        points.push({ x: midX, y: startY });
        points.push({ x: midX, y: endY });
        points.push(pEntry);
    } else {
        points.push(pExit);
        const midY = (startY + endY) / 2;
        points.push({ x: pExit.x, y: midY });
        points.push({ x: pEntry.x, y: midY });
        points.push(pEntry);
    }
    points.push({ x: endX, y: endY });
    
    return points.filter((p, i) => {
        if (i === 0) return true;
        const prev = points[i - 1];
        if (!prev) return true;
        return Math.abs(p.x - prev.x) > 0.1 || Math.abs(p.y - prev.y) > 0.1;
    });
}

const pointsToRoundedPath = (points: { x: number; y: number }[], radius: number = 5): string => {
    if (points.length < 2) return '';
    const p0 = points[0];
    if (!p0) return '';
    let path = `M ${p0.x} ${p0.y}`;
    
    for (let i = 1; i < points.length - 1; i++) {
        const pPrev = points[i - 1];
        const pCurr = points[i];
        const pNext = points[i + 1];

        if (!pPrev || !pCurr || !pNext) continue;
        
        const v1 = { x: pCurr.x - pPrev.x, y: pCurr.y - pPrev.y };
        const v2 = { x: pNext.x - pCurr.x, y: pNext.y - pCurr.y };
        
        const len1 = Math.sqrt(v1.x * v1.x + v1.y * v1.y);
        const len2 = Math.sqrt(v2.x * v2.x + v2.y * v2.y);
        
        const r = Math.min(radius, len1 / 2, len2 / 2);
        
        const startX = pCurr.x - (v1.x / len1) * r;
        const startY = pCurr.y - (v1.y / len1) * r;
        const endX = pCurr.x + (v2.x / len2) * r;
        const endY = pCurr.y + (v2.y / len2) * r;
        
        path += ` L ${startX} ${startY}`;
        path += ` Q ${pCurr.x} ${pCurr.y} ${endX} ${endY}`;
    }
    
    const pLast = points[points.length - 1];
    if (pLast) {
        path += ` L ${pLast.x} ${pLast.y}`;
    }
    return path;
}

// const statusMap: Record<string, string> = {
//   pending: '未开始',
//   in_progress: '进行中',
//   completed: '已完成',
//   delayed: '已延期'
// }

const statusColors: Record<string, string> = {
    completed: "#4CAF50",
    in_progress: "#2196F3",
    delayed: "#F44336",
    pending: "#9E9E9E",
};

// --- Zoom Logic ---
type ZoomLevel = 'week' | 'month' | 'quarter' | 'year'
const zoomLevel = ref<ZoomLevel>('month')
const zoomOptions = [
    { label: '日视图', value: 'month' },
    { label: '周视图', value: 'week' },
    { label: '月视图', value: 'quarter' },
    { label: '年视图', value: 'year' }
]
const dayWidthMap: Record<ZoomLevel, number> = {
    week: 15,
    month: 40,
    quarter: 6,
    year: 2
}
const DAY_WIDTH = computed(() => dayWidthMap[zoomLevel.value])
const ROW_HEIGHT = 40

// --- Tree Table Logic ---
const expandedKeys = ref<Set<string>>(new Set())

// --- Splitter Logic ---
const sidebarWidth = ref(400)
const isResizing = ref(false)
const bottomSpacerHeight = ref(0)

const startResize = () => {
  isResizing.value = true
  document.addEventListener('mousemove', handleResize)
  document.addEventListener('mouseup', stopResize)
  document.body.style.cursor = 'col-resize'
  document.body.style.userSelect = 'none'
}

const handleResize = (e: MouseEvent) => {
  if (!isResizing.value) return
  sidebarWidth.value = Math.max(200, Math.min(800, sidebarWidth.value + e.movementX))
}

const stopResize = () => {
  isResizing.value = false
  document.removeEventListener('mousemove', handleResize)
  document.removeEventListener('mouseup', stopResize)
  document.body.style.cursor = ''
  document.body.style.userSelect = ''
  // Trigger resize for canvas
  nextTick(() => {
    initLeafer()
  })
}

watch(() => store.phases, (phases) => {
    phases.forEach(p => expandedKeys.value.add(p.id))
}, { immediate: true })

const toggleExpand = (key: string) => {
    if (expandedKeys.value.has(key)) {
        expandedKeys.value.delete(key)
    } else {
        expandedKeys.value.add(key)
    }
}

// --- Flattened Data ---
const visibleRows = computed(() => {
    const rows: any[] = []
    let rowNumber = 1
    const taskIdToRowMap = new Map<string, number>()

    store.phases.forEach(phase => {
        const phaseTasks = store.tasks.filter(t => t.phaseId === phase.id);
        
        // Calculate Phase Progress
        let totalWeightedProgress = 0;
        let totalDuration = 0;
        
        phaseTasks.forEach(t => {
             const start = parseLocalDate(t.startDate).getTime();
             const end = parseLocalDate(t.endDate).getTime();
             let duration = (end - start) / (1000 * 3600 * 24) + 1;
             if (isNaN(duration) || duration < 1) duration = 1;
             
             totalDuration += duration;
             totalWeightedProgress += (t.progress || 0) * duration;
        });
        
        const phaseProgress = totalDuration > 0 ? Math.round(totalWeightedProgress / totalDuration) : 0;

        // Phase Row
        const phaseRow = {
            id: phase.id,
            name: phase.name,
            type: 'phase',
            depth: 0,
            expanded: expandedKeys.value.has(phase.id),
            data: phase,
            rowNumber: rowNumber++,
            progress: phaseProgress,
            color: phase.color || '#E3F2FD'
        }
        rows.push(phaseRow)
        
        if (expandedKeys.value.has(phase.id)) {
            phaseTasks.forEach(task => {
                const taskRow = {
                    id: task.id,
                    name: task.name,
                    type: 'task',
                    depth: 1,
                    data: task,
                    status: task.status,
                    owner: task.owner,
                    startDate: task.startDate,
                    endDate: task.endDate,
                    rowNumber: rowNumber++,
                    progress: task.progress || 0,
                    color: undefined
                }
                rows.push(taskRow)
                taskIdToRowMap.set(task.id, taskRow.rowNumber)
            })
        }
    })

    // Second pass: resolve dependencies to row numbers
    rows.forEach(row => {
        if (row.type === 'task' && row.data.dependencies) {
            row.predecessors = row.data.dependencies
                .map((depOrId: string | any) => {
                     const depId = typeof depOrId === 'string' ? depOrId : depOrId.taskId;
                     const visibleRow = taskIdToRowMap.get(depId);
                     if (visibleRow !== undefined) {
                         return visibleRow;
                     } else {
                         const task = store.tasks.find(t => t.id === depId);
                         return task ? `[${task.name}]` : depId;
                     }
                })
                .join(', ')
        } else {
            row.predecessors = ''
        }
    })

    return rows
})

const totalWidth = computed(() => days.value.length * DAY_WIDTH.value)
const totalHeight = computed(() => Math.max(visibleRows.value.length * ROW_HEIGHT, 1))

// --- Time Axis ---
const viewportWidth = ref(0)
const viewportHeight = ref(0)

const timeRange = computed(() => {
    let dates = store.tasks.flatMap(t => [parseLocalDate(t.startDate), parseLocalDate(t.endDate)])
        .filter(d => !isNaN(d.getTime()));
    
    dates = dates.filter(d => d.getFullYear() >= 2000 && d.getFullYear() <= 2100);

    if (dates.length === 0) {
        const now = new Date();
        const start = new Date(now.getFullYear(), now.getMonth(), 1);
        const end = new Date(now.getFullYear(), now.getMonth() + 1, 0); 
        return { start, end };
    }
    
    let minDate = new Date(Math.min(...dates.map(d => d.getTime())));
    let maxDate = new Date(Math.max(...dates.map(d => d.getTime())));
    
    minDate.setDate(minDate.getDate() - 3);
    maxDate.setDate(maxDate.getDate() + 3);

    // Ensure minDate/maxDate are at start of day
    minDate = new Date(minDate.getFullYear(), minDate.getMonth(), minDate.getDate());
    maxDate = new Date(maxDate.getFullYear(), maxDate.getMonth(), maxDate.getDate());

    return { start: minDate, end: maxDate };
})

const days = computed(() => {
    const { start, end } = timeRange.value;
    const dayList = [];
    for (let d = new Date(start); d <= end; d.setDate(d.getDate() + 1)) {
        dayList.push(new Date(d));
    }
    return dayList;
})

const timelineHeaders = computed(() => {
    const level = zoomLevel.value;
    const topRow: { label: string, width: number, left: number }[] = [];
    const bottomRow: { label: string, width: number, left: number }[] = [];
    const dayW = DAY_WIDTH.value;
    
    if (level === 'month') {
        // Top: YYYY-MM
        // Bottom: DD
        let currentMonth = -1;
        let currentMonthStart = 0;
        let currentMonthWidth = 0;
        
        days.value.forEach((d, i) => {
            const m = d.getMonth();
            if (m !== currentMonth) {
                if (currentMonth !== -1) {
                    const blockStartDay = days.value[Math.floor(currentMonthStart / dayW)];
                    if (blockStartDay) {
                        topRow.push({
                            label: `${blockStartDay.getFullYear()}-${blockStartDay.getMonth() + 1}`,
                            width: currentMonthWidth,
                            left: currentMonthStart
                        });
                    }
                }
                currentMonth = m;
                currentMonthStart = i * dayW;
                currentMonthWidth = 0;
            }
            currentMonthWidth += dayW;
            
            bottomRow.push({
                label: String(d.getDate()),
                width: dayW,
                left: i * dayW
            });
        });
        // Push last month
        const lastD = days.value[days.value.length - 1];
        if (lastD) {
            const blockStartDay = days.value[Math.floor(currentMonthStart / dayW)];
            if (blockStartDay) {
                topRow.push({
                    label: `${blockStartDay.getFullYear()}-${blockStartDay.getMonth() + 1}`,
                    width: currentMonthWidth,
                    left: currentMonthStart
                });
            }
        }
    } else if (level === 'week') {
        // Top: YYYY-MM
        // Bottom: Week start date (MM-DD)
        let currentMonth = -1;
        let currentMonthStart = 0;
        let currentMonthWidth = 0;
        
        let currentWeekStart = 0;
        let currentWeekWidth = 0;
        let currentWeekLabel = '';
        
        days.value.forEach((d, i) => {
             // Month Logic (Same as above)
            const m = d.getMonth();
            if (m !== currentMonth) {
                if (currentMonth !== -1) {
                    const blockStartDay = days.value[Math.floor(currentMonthStart / dayW)];
                    if (blockStartDay) {
                         topRow.push({
                            label: `${blockStartDay.getFullYear()}-${blockStartDay.getMonth() + 1}`,
                            width: currentMonthWidth,
                            left: currentMonthStart
                        });
                    }
                }
                currentMonth = m;
                currentMonthStart = i * dayW;
                currentMonthWidth = 0;
            }
            currentMonthWidth += dayW;
            
            // Week Logic
            const dayOfWeek = d.getDay(); 
            const isoDay = dayOfWeek === 0 ? 7 : dayOfWeek;
            
            if (isoDay === 1 || i === 0) {
                if (currentWeekWidth > 0) {
                    bottomRow.push({
                        label: currentWeekLabel,
                        width: currentWeekWidth,
                        left: currentWeekStart
                    });
                }
                currentWeekStart = i * dayW;
                currentWeekWidth = 0;
                // Label for the week: MM-DD
                currentWeekLabel = `${d.getMonth() + 1}/${d.getDate()}`;
            }
            currentWeekWidth += dayW;
        });
        
        // Push last blocks
        const lastD = days.value[days.value.length - 1];
        if (lastD) {
             const blockStartDay = days.value[Math.floor(currentMonthStart / dayW)];
             if (blockStartDay) {
                 topRow.push({
                    label: `${blockStartDay.getFullYear()}-${blockStartDay.getMonth() + 1}`,
                    width: currentMonthWidth,
                    left: currentMonthStart
                });
             }
        }
        if (currentWeekWidth > 0) {
            bottomRow.push({
                label: currentWeekLabel,
                width: currentWeekWidth,
                left: currentWeekStart
            });
        }
        
    } else if (level === 'quarter') {
        // Top: YYYY QX
        // Bottom: Month
        // We iterate days but group by month and quarter
        let currentQuarter = -1;
        let currentQuarterYear = -1;
        let currentQuarterStart = 0;
        let currentQuarterWidth = 0;
        
        let currentMonth = -1;
        let currentMonthStart = 0;
        let currentMonthWidth = 0;
        
        days.value.forEach((d, i) => {
            const y = d.getFullYear();
            const m = d.getMonth();
            const q = Math.floor(m / 3) + 1;
            
            // Quarter Logic
            if ((q !== currentQuarter || y !== currentQuarterYear) && currentQuarter !== -1) {
                 if (i > 0) {
                     topRow.push({
                         label: `${currentQuarterYear}-Q${currentQuarter}`,
                         width: currentQuarterWidth,
                         left: currentQuarterStart
                     });
                 }
                 currentQuarter = q;
                 currentQuarterYear = y;
                 currentQuarterStart = i * dayW;
                 currentQuarterWidth = 0;
            } else if (currentQuarter === -1) {
                currentQuarter = q;
                currentQuarterYear = y;
            }
            currentQuarterWidth += dayW;

            // Month Logic
             if (m !== currentMonth) {
                 if (currentMonth !== -1) {
                      bottomRow.push({
                          label: `${currentMonth + 1}月`,
                          width: currentMonthWidth,
                          left: currentMonthStart
                      });
                 }
                 currentMonth = m;
                 currentMonthStart = i * dayW;
                 currentMonthWidth = 0;
             }
             currentMonthWidth += dayW;
        });
        // Push last
        topRow.push({ label: `${currentQuarterYear}-Q${currentQuarter}`, width: currentQuarterWidth, left: currentQuarterStart });
        bottomRow.push({ label: `${currentMonth + 1}月`, width: currentMonthWidth, left: currentMonthStart });
        
    } else if (level === 'year') {
         // Top: YYYY
         // Bottom: Month
         let currentYear = -1;
         let currentYearStart = 0;
         let currentYearWidth = 0;
         
         let currentMonth = -1;
         let currentMonthStart = 0;
         let currentMonthWidth = 0;
         
         days.value.forEach((d, i) => {
             const y = d.getFullYear();
             const m = d.getMonth();
             
             if (y !== currentYear) {
                 if (currentYear !== -1) {
                     topRow.push({ label: String(currentYear), width: currentYearWidth, left: currentYearStart });
                 }
                 currentYear = y;
                 currentYearStart = i * dayW;
                 currentYearWidth = 0;
             }
             currentYearWidth += dayW;
             
             if (m !== currentMonth) {
                  if (currentMonth !== -1) {
                       bottomRow.push({ label: `${currentMonth + 1}月`, width: currentMonthWidth, left: currentMonthStart });
                  }
                  currentMonth = m;
                  currentMonthStart = i * dayW;
                  currentMonthWidth = 0;
              }
              currentMonthWidth += dayW;
         });
         topRow.push({ label: String(currentYear), width: currentYearWidth, left: currentYearStart });
         bottomRow.push({ label: `${currentMonth + 1}月`, width: currentMonthWidth, left: currentMonthStart });
    }
    
    return { topRow, bottomRow };
})

// --- Sync Scrolling ---
const leftBodyRef = ref<HTMLElement | null>(null)
const sidebarHeaderRef = ref<HTMLElement | null>(null)
const rightScrollRef = ref<HTMLElement | null>(null)
const rightHeaderRef = ref<HTMLElement | null>(null)
const ganttContainerRef = ref<HTMLElement | null>(null)

const scrollLeft = ref(0)
const scrollTop = ref(0)
let ignoreNextScrollLeft = false;
let ignoreNextScrollRight = false;

const handleRightScroll = (e: Event) => {
    const target = e.target as HTMLElement
    if (!target) return
    
    scrollLeft.value = target.scrollLeft
    scrollTop.value = target.scrollTop

    if (ignoreNextScrollRight) {
         ignoreNextScrollRight = false;
    } else {
        if (leftBodyRef.value) {
            ignoreNextScrollLeft = true;
            leftBodyRef.value.scrollTop = target.scrollTop
        }
    }
    
    if (rightHeaderRef.value) {
        rightHeaderRef.value.scrollLeft = target.scrollLeft
    }
}

const handleLeftScroll = (e: Event) => {
    const target = e.target as HTMLElement
    if (!target) return
    
    if (sidebarHeaderRef.value) {
        sidebarHeaderRef.value.scrollLeft = target.scrollLeft
    }
    
    if (ignoreNextScrollLeft) {
        ignoreNextScrollLeft = false;
    } else {
        if (rightScrollRef.value) {
            ignoreNextScrollRight = true;
            rightScrollRef.value.scrollTop = target.scrollTop
        }
    }
}

// --- Leafer UI ---
let leaferApp: App | null = null
let staticLayer: Leafer | null = null
let animateLayer: Leafer | null = null
const selectedTaskId = ref<string | null>(null)

const initLeafer = () => {
    if (!ganttContainerRef.value) return
    
    updateSpacer()

    if (leaferApp) leaferApp.destroy()

    leaferApp = new App({
        view: ganttContainerRef.value,
        fill: '#ffffff',
        tree: {},
        type: 'user' as any
    })
    
    // Layer 1: Static Content (Grid, Tasks, Normal Lines)
    staticLayer = new Leafer({ type: 'user' as any })
    leaferApp.add(staticLayer)
    
    // Layer 2: Animation Content (Selected Lines, Interactions)
    animateLayer = new Leafer({ type: 'user' as any })
    leaferApp.add(animateLayer)
    
    drawGantt()
}

const drawGantt = () => {
    if (!leaferApp || !staticLayer || !animateLayer) return
    
    // Reset tooltip when redrawing to prevent stuck tooltips
    tooltip.value.visible = false;
    
    staticLayer.clear()
    animateLayer.clear()
    
    const { start: minDate } = timeRange.value
    if (!minDate) return

    const gridGroup = new Group()
    const lineGroup = new Group()
    const taskGroup = new Group()
    
    // Static Layer Structure: Grid -> Lines (Unselected) -> Tasks
    staticLayer.add(gridGroup)
    
    // Background for panning
    const bgRect = new Rect({
        x: 0, y: 0,
        width: Math.max(totalWidth.value, viewportWidth.value),
        height: Math.max(totalHeight.value, viewportHeight.value),
        fill: 'transparent'
    })
    staticLayer.add(bgRect)
    
    staticLayer.add(lineGroup)
    staticLayer.add(taskGroup)
    
    // Animation Layer Structure: Selected Lines
    const activeLineGroup = new Group()
    animateLayer.add(activeLineGroup)
    
    // Draw Holidays
    if (zoomLevel.value !== 'year') {
        const holidayColor = '#f5f5f5';
        const legalHolidayColor = '#e8e8e8';
        
        days.value.forEach((d, i) => {
             let isWork = true;
             let isPublic = false;
             try {
                 isWork = holiday.isWorkday(d);
                 isPublic = holiday.isPublicHoliday(d);
             } catch (e) {
                 const dayOfWeek = d.getDay();
                 isWork = dayOfWeek !== 0 && dayOfWeek !== 6;
             }
             
             if (!isWork) {
                 gridGroup.add(new Rect({
                     x: i * DAY_WIDTH.value,
                     y: 0,
                     width: DAY_WIDTH.value,
                     height: totalHeight.value,
                     fill: isPublic ? legalHolidayColor : holidayColor,
                 }));
             }
        });
    }

    // Grid Lines
    timelineHeaders.value.bottomRow.forEach(tick => {
         gridGroup.add(new Rect({
             x: tick.left + tick.width,
             y: 0,
             width: 1,
             height: totalHeight.value,
             fill: '#f0f0f0'
         }))
    })

    // Today Line
    const today = new Date();
    const offsetTime = today.getTime() - minDate.getTime();
    // Only draw if today is after start date. 
    // We don't strictly check end date because the canvas might extend or it doesn't hurt to draw outside.
    if (offsetTime >= 0) {
        const daysFromStart = offsetTime / (1000 * 3600 * 24);
        const x = daysFromStart * DAY_WIDTH.value;
        
        gridGroup.add(new Line({
            points: [x, 0, x, totalHeight.value],
            stroke: 'red',
            strokeWidth: 1,
            dashPattern: [5, 5],
            opacity: 0.6
        }));
    }
    
    // Rows
    const taskPositions = new Map<string, { x: number, y: number, width: number, height: number }>();
    
    visibleRows.value.forEach((row, index) => {
        const y = index * ROW_HEIGHT
        gridGroup.add(new Rect({
            x: 0, y: y + ROW_HEIGHT - 1, width: totalWidth.value, height: 1, fill: '#eee'
        }))
        
        if (row.type === 'task' && row.startDate && row.endDate) {
            const start = parseLocalDate(row.startDate)
            const end = parseLocalDate(row.endDate)
            
            if (!isNaN(start.getTime()) && !isNaN(end.getTime())) {
                const offsetMs = start.getTime() - minDate.getTime()
                const durationMs = end.getTime() - start.getTime()
                const msPerDay = 1000 * 3600 * 24
                const offsetDays = offsetMs / msPerDay
                const durationDays = durationMs / msPerDay + 1
                
                const barX = offsetDays * DAY_WIDTH.value
                const barW = durationDays * DAY_WIDTH.value
                const barHeight = ROW_HEIGHT - 16;
                const barY = y + 8;
                
                const color = statusColors[row.data.status] || "#9E9E9E";
                const progressPct = (row.data.progress || 0) / 100;
                
                const fill = {
                    type: 'linear',
                    from: { x: 0, y: 0 },
                    to: { x: barW, y: 0 },
                    stops: [
                        { offset: 0, color: row.data.startColor || 'white' },
                        { offset: progressPct, color: row.data.endColor || '#B3E5FC' },
                        { offset: progressPct, color: 'white' },
                        { offset: 1, color: 'white' }
                    ]
                }
                
                const bar = new Rect({
                    x: barX, y: barY, width: barW, height: barHeight,
                    fill: fill as any, // Cast to any to avoid strict type checking on gradient
                    stroke: color,
                    strokeWidth: 1,
                    cornerRadius: 4,
                    cursor: 'pointer'
                })
                
                bar.on(LeaferPointerEvent.CLICK, () => {
                    scrollToTask(row)
                })

                taskGroup.add(bar)
                
                // Text
                const text = new Text({
                    x: barX + 5, y: barY + 4,
                    text: row.name,
                    fontSize: 12,
                    fill: '#333',
                    width: Math.max(0, barW - 10),
                    textOverflow: '...',
                    overflow: 'hide'
                })
                
                const showTooltip = (e: LeaferPointerEvent) => {
                    tooltip.value.text = row.name
                    tooltip.value.visible = true
                    const native = e.origin
                    if (native) {
                        tooltip.value.x = native.clientX + 10
                        tooltip.value.y = native.clientY + 10
                    }
                }
                
                const moveTooltip = (e: LeaferPointerEvent) => {
                    if (!tooltip.value.visible) return
                    const native = e.origin
                    if (native) {
                        tooltip.value.x = native.clientX + 10
                        tooltip.value.y = native.clientY + 10
                    }
                }
                
                const hideTooltip = () => {
                    tooltip.value.visible = false
                }
                
                text.on(LeaferPointerEvent.ENTER, showTooltip)
                text.on(LeaferPointerEvent.MOVE, moveTooltip)
                text.on(LeaferPointerEvent.LEAVE, hideTooltip)
                
                // Also add tooltip to bar for better UX? 
                // User said "task text exceeding box... mouse enter show tooltip".
                // Often it's better if the whole bar shows tooltip, but let's stick to text or both.
                // If I add to bar, it might be redundant or conflict.
                // Let's add to bar as well because sometimes text is short but user still hovers bar.
                // Wait, if text is short, user might not need tooltip, but consistency is good.
                // However, the request specifically mentioned "text exceeding box".
                // I'll add to both to be safe and provide better UX.
                bar.on(LeaferPointerEvent.ENTER, showTooltip)
                bar.on(LeaferPointerEvent.MOVE, moveTooltip)
                bar.on(LeaferPointerEvent.LEAVE, hideTooltip)

                taskGroup.add(text)

                // Resize Handles
                const handleWidth = 8;
                
                // Left Handle
                const leftHandle = new Rect({
                    x: barX - handleWidth/2,
                    y: barY,
                    width: handleWidth,
                    height: barHeight,
                    fill: 'transparent',
                    cursor: 'w-resize',
                    zIndex: 10
                });

                // Right Handle
                const rightHandle = new Rect({
                    x: barX + barW - handleWidth/2,
                    y: barY,
                    width: handleWidth,
                    height: barHeight,
                    fill: 'transparent',
                    cursor: 'e-resize',
                    zIndex: 10
                });

                // Right Resize Logic
                rightHandle.on(DragEvent.START, () => {
                     // No op
                });

                rightHandle.on(DragEvent.DRAG, (e: DragEvent) => {
                     const currentW = bar.width ?? 0;
                     const newW = Math.max(DAY_WIDTH.value, currentW + e.moveX);
                     bar.width = newW;
                     
                     rightHandle.x = (bar.x ?? 0) + (bar.width ?? 0) - handleWidth/2;
                     
                     // Update Text
                     text.width = Math.max(0, (bar.width ?? 0) - 10);
                     
                     // Tooltip
                     const days = (bar.width ?? 0) / DAY_WIDTH.value;
                     const startOffsetMs = ((bar.x ?? 0) / DAY_WIDTH.value) * (24*3600*1000);
                     const startDate = new Date(minDate.getTime() + startOffsetMs);
                     const endDate = new Date(startDate.getTime() + (days - 1) * (24*3600*1000));
                     
                     const sY = startDate.getFullYear();
                     const sM = String(startDate.getMonth() + 1).padStart(2, '0');
                     const sD = String(startDate.getDate()).padStart(2, '0');
                     const sStr = `${sY}-${sM}-${sD}`;
                     
                     const eY = endDate.getFullYear();
                     const eM = String(endDate.getMonth() + 1).padStart(2, '0');
                     const eD = String(endDate.getDate()).padStart(2, '0');
                     const eStr = `${eY}-${eM}-${eD}`;
                     
                     tooltip.value.visible = true;
                     tooltip.value.text = `${row.name}: ${sStr} - ${eStr}`;
                     
                     if (e.origin) {
                        tooltip.value.x = e.origin.clientX + 10;
                        tooltip.value.y = e.origin.clientY + 10;
                     }
                });

                rightHandle.on(DragEvent.END, () => {
                     tooltip.value.visible = false;
                     
                     const days = (bar.width ?? 0) / DAY_WIDTH.value;
                     const startOffsetMs = ((bar.x ?? 0) / DAY_WIDTH.value) * (24*3600*1000);
                     const startDate = new Date(minDate.getTime() + startOffsetMs);
                     const newEndDate = new Date(startDate.getTime() + (days - 1) * (24*3600*1000));
                     // Adjust for timezone issues if any, but toISOString().split('T')[0] is UTC.
                     // We should use local date string.
                     const y = newEndDate.getFullYear();
                     const m = String(newEndDate.getMonth() + 1).padStart(2, '0');
                     const d = String(newEndDate.getDate()).padStart(2, '0');
                     const dateStr = `${y}-${m}-${d}`;
                     
                     if (row.endDate !== dateStr) {
                         store.updateTask(row.id, { endDate: dateStr });
                     }
                     // drawGantt(); // Watcher will trigger
                });

                // Left Resize Logic
                leftHandle.on(DragEvent.DRAG, (e: DragEvent) => {
                     const currentRight = (bar.x ?? 0) + (bar.width ?? 0);
                     
                     let newX = (bar.x ?? 0) + e.moveX;
                     let newW = (bar.width ?? 0) - e.moveX;
                     
                     if (newW < DAY_WIDTH.value) {
                         newW = DAY_WIDTH.value;
                         newX = currentRight - newW;
                     }
                     
                     bar.x = newX;
                     bar.width = newW;
                     
                     leftHandle.x = (bar.x ?? 0) - handleWidth/2;
                     text.x = (bar.x ?? 0) + 5;
                     text.width = Math.max(0, (bar.width ?? 0) - 10);
                     
                     // Tooltip
                     const startOffsetMs = ((bar.x ?? 0) / DAY_WIDTH.value) * (24*3600*1000);
                     const startDate = new Date(minDate.getTime() + startOffsetMs);
                     
                     const sY = startDate.getFullYear();
                     const sM = String(startDate.getMonth() + 1).padStart(2, '0');
                     const sD = String(startDate.getDate()).padStart(2, '0');
                     const sStr = `${sY}-${sM}-${sD}`;
                     
                     tooltip.value.visible = true;
                     tooltip.value.text = `${row.name}: ${sStr} - ${formatDate(row.endDate)}`;
                     if (e.origin) {
                        tooltip.value.x = e.origin.clientX + 10;
                        tooltip.value.y = e.origin.clientY + 10;
                     }
                });
                
                leftHandle.on(DragEvent.END, () => {
                     tooltip.value.visible = false;
                     
                     const startOffsetMs = ((bar.x ?? 0) / DAY_WIDTH.value) * (24*3600*1000);
                     const newStartDate = new Date(minDate.getTime() + startOffsetMs);
                     
                     const y = newStartDate.getFullYear();
                     const m = String(newStartDate.getMonth() + 1).padStart(2, '0');
                     const d = String(newStartDate.getDate()).padStart(2, '0');
                     const dateStr = `${y}-${m}-${d}`;
                     
                     if (row.startDate !== dateStr) {
                         store.updateTask(row.id, { startDate: dateStr });
                     }
                     // drawGantt(); // Watcher will trigger
                });

                taskGroup.add(leftHandle);
                taskGroup.add(rightHandle);
                
                taskPositions.set(row.id, { x: barX, y: barY, width: barW, height: barHeight })
            }
        }
    })
    
    // Dependency Lines
    visibleRows.value.forEach(row => {
        if (row.type === 'task' && row.data && row.data.dependencies) {
            row.data.dependencies.forEach((depOrObj: any) => {
                const depId = typeof depOrObj === 'string' ? depOrObj : depOrObj.taskId;
                const source = taskPositions.get(depId);
                const target = taskPositions.get(row.id);
                
                if (source && target) {
                     const startX = source.x + source.width;
                     const startY = source.y + source.height / 2;
                     const endX = target.x;
                     const endY = target.y + target.height / 2;
                     
                     const points = getPolylinePoints(startX, startY, endX, endY);
                     const pathData = pointsToRoundedPath(points, 5);
                     
                     const isSelected = selectedTaskId.value && (selectedTaskId.value === row.id || selectedTaskId.value === depId);
                     
                     const line = new Path({
                         path: pathData,
                         stroke: isSelected ? '#2196f3' : '#999',
                         strokeWidth: isSelected ? 2 : 1,
                         dashPattern: isSelected ? [5, 5] : undefined
                     });
                     
                     if (isSelected) {
                         activeLineGroup.add(line);
                         (line as any).animate({ dashOffset: -10 }, { duration: 1000, loop: true })
                     } else {
                         lineGroup.add(line);
                     }
                }
            })
        }
    })
}

// --- Interactions ---
const scrollToToday = () => {
    if (!rightScrollRef.value) return;
    const { start } = timeRange.value;
    const today = parseLocalDate(new Date().toISOString()); 
    const diffTime = today.getTime() - start.getTime();
    const diffDays = diffTime / (1000 * 3600 * 24);
    const todayX = diffDays * DAY_WIDTH.value + DAY_WIDTH.value / 2;
    const viewportW = rightScrollRef.value.clientWidth;
    const targetScrollX = todayX - viewportW / 2;
    rightScrollRef.value.scrollTo({ left: Math.max(0, targetScrollX), behavior: 'auto' });
}

const scrollToTask = (row: any) => {
    selectedTaskId.value = row.id
    drawGantt() // Redraw to update selection
    
    if (!rightScrollRef.value || !row.startDate || !row.endDate) return;
    const { start } = timeRange.value;
    const taskStart = parseLocalDate(row.startDate);
    const diffTimeStart = taskStart.getTime() - start.getTime();
    const diffDaysStart = diffTimeStart / (1000 * 3600 * 24);
    const startX = diffDaysStart * DAY_WIDTH.value;
    const targetScrollX = startX - 50;
    
    rightScrollRef.value.scrollTo({ left: Math.max(0, targetScrollX), behavior: 'smooth' });
}

const handleWheel = (e: WheelEvent) => {
    if (e.ctrlKey) {
        e.preventDefault();
        // Zoom logic can be implemented here if needed
    }
}

// Tooltip logic
const tooltip = ref({ visible: false, text: '', x: 0, y: 0 });
const handleHeaderMouseMove = () => {
    // Simplified tooltip
    tooltip.value.visible = false;
}
const handleHeaderMouseLeave = () => {
    tooltip.value.visible = false;
}

const handleWindowResize = () => {
    initLeafer();
    updateSpacer();
}

const togglePageScroll = (disable: boolean) => {
    const content = document.querySelector('.site-layout-content') as HTMLElement
    if (content) {
        content.style.overflow = disable ? 'hidden' : ''
    }
}

onActivated(() => {
    togglePageScroll(true)
})

onDeactivated(() => {
    togglePageScroll(false)
})

onMounted(() => {
    if (rightScrollRef.value) {
        viewportWidth.value = rightScrollRef.value.clientWidth
        viewportHeight.value = rightScrollRef.value.clientHeight
    }
    initLeafer()
    window.addEventListener('resize', handleWindowResize)
    togglePageScroll(true)
})

onUnmounted(() => {
    if (leaferApp) leaferApp.destroy()
    window.removeEventListener('resize', handleWindowResize)
    togglePageScroll(false)
})

const updateSpacer = () => {
    if (leftBodyRef.value && rightScrollRef.value) {
        // We want to ensure that the left side can scroll as much as the right side.
        // Right scrollable height = ContentHeight
        // Right viewport height = ClientHeight (smaller if scrollbar exists)
        // Max Scroll Top = ContentHeight - ClientHeight
        
        // Left Content Height (without spacer) = ContentHeight (same as Right)
        // Left viewport height = ClientHeight (usually larger as no horizontal scrollbar)
        
        // We want MaxScrollTop_Left >= MaxScrollTop_Right
        // (ContentHeight + Spacer) - LeftClientHeight >= ContentHeight - RightClientHeight
        // Spacer >= LeftClientHeight - RightClientHeight
        
        const leftH = leftBodyRef.value.clientHeight
        const rightH = rightScrollRef.value.clientHeight
        bottomSpacerHeight.value = Math.max(0, leftH - rightH)
    }
}

watch([() => store.tasks, () => store.phases, zoomLevel], () => {
    drawGantt()
    nextTick(updateSpacer)
}, { deep: true })
</script>

<style scoped>
.gantt-view {
  display: flex;
  flex-direction: column;
  height: 100%;
  overflow: hidden;
}

.gantt-toolbar {
  padding: 0 8px;
  display: flex;
  align-items: center;
}

.gantt-content {
  flex: 1;
  display: flex;
  overflow: hidden;
}

.gantt-sidebar {
  /* width controlled by style binding */
  border-right: 1px solid #f0f0f0;
  display: flex;
  flex-direction: column;
  background: #fff;
  flex-shrink: 0;
}

.gantt-splitter {
  width: 6px;
  background: #f0f0f0;
  cursor: col-resize;
  flex-shrink: 0;
  transition: background 0.2s;
  z-index: 10;
}

.gantt-splitter:hover, .gantt-splitter.resizing {
  background: #1890ff;
}

.sidebar-header {
  height: 40px;
  display: flex;
  align-items: center;
  border-bottom: 1px solid #f0f0f0;
  background: #fafafa;
  font-weight: bold;
  overflow: hidden; /* Hide scrollbar but allow programmatic scroll */
}

.sidebar-body {
  flex: 1;
  overflow-y: auto; /* Allow native scroll */
  overflow-x: auto;
}
.sidebar-body::-webkit-scrollbar {
    width: 0;
}

.sidebar-row {
  height: 40px;
  display: flex;
  align-items: center;
  border-bottom: 1px solid #eee;
  cursor: pointer;
}
.sidebar-row:hover {
  background-color: #f5f5f5;
}
.row-selected {
  background-color: #e6f7ff;
}
.row-phase {
  background-color: #fafafa;
}

.col-id { width: 40px; text-align: center; justify-content: center; border-right: 1px solid #f0f0f0; flex-shrink: 0; }
.col-name { width: 200px; padding: 0 8px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; border-right: 1px solid #f0f0f0; flex-shrink: 0; }
.col-progress { width: 80px; text-align: center; border-right: 1px solid #f0f0f0; flex-shrink: 0; }
.col-owner { width: 80px; text-align: center; border-right: 1px solid #f0f0f0; flex-shrink: 0; }
.col-pred { width: 80px; text-align: center; border-right: 1px solid #f0f0f0; flex-shrink: 0; }
.col-date { width: 100px; text-align: center; border-right: 1px solid #f0f0f0; flex-shrink: 0; }

.gantt-chart {
  flex: 1;
  display: flex;
  flex-direction: column;
  position: relative;
  overflow: hidden;
}

.timeline-header {
  height: 40px;
  position: relative;
  overflow: hidden;
  border-bottom: 1px solid #f0f0f0;
  background: #fafafa;
}

.timeline-row {
  height: 20px;
  position: relative;
}

.header-block {
  position: absolute;
  top: 0;
  height: 100%;
  border-right: 1px solid #eee;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  color: #666;
  white-space: nowrap;
  overflow: hidden;
}

.timeline-body {
  flex: 1;
  overflow: auto;
  position: relative;
}

.canvas-container {
  position: relative;
}

.gantt-tooltip {
  position: fixed;
  background: rgba(0, 0, 0, 0.75);
  color: white;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  pointer-events: none;
  z-index: 1000;
}

.expand-icon {
  display: inline-block;
  width: 16px;
  text-align: center;
  cursor: pointer;
  margin-right: 4px;
}
</style>
