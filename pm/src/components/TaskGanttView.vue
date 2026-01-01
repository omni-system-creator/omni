<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, watch, nextTick } from 'vue'
import { useProjectStore } from '../stores/projectStore'
import { NSplit, NSelect, NButton } from 'naive-ui'
import { App, Rect, Text, Group, Path, Line, DragEvent as LeaferDragEvent, PointerEvent as LeaferPointerEvent } from 'leafer-ui'
import '@leafer-in/find'
import { holiday } from '@kang8/chinese-holidays' // Import library

const store = useProjectStore()

// --- Helpers ---


const parseLocalDate = (dateStr: string) => {
    if (!dateStr) return new Date();
    // Handle "YYYY-MM-DD" explicitly to avoid UTC conversion
    // This ensures 00:00:00 Local Time
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

const getPolylinePoints = (startX: number, startY: number, endX: number, endY: number) => {
    const points: { x: number; y: number }[] = [];
    let exitDist = 20;
    let entryDist = 20;

    // Squeeze leaders if gap is small but positive (avoid large loopback for adjacent days)
    // If gap is > 10px, we prefer a direct S-line with shorter leaders
    if (endX > startX + 10 && (endX - startX) < (exitDist + entryDist)) {
        const mid = (endX - startX) / 2;
        exitDist = mid;
        entryDist = mid;
    }

    // Start point
    points.push({ x: startX, y: startY });

    // Exit leader point
    const pExit = { x: startX + exitDist, y: startY };
    
    // Entry leader point
    const pEntry = { x: endX - entryDist, y: endY };

    if (pExit.x <= pEntry.x + 1) {
        // Normal case: Target is to the right
        // Path: Start -> Exit -> Mid Vertical -> Entry -> End
        const midX = (pExit.x + pEntry.x) / 2;
        
        points.push(pExit);
        points.push({ x: midX, y: startY });
        points.push({ x: midX, y: endY });
        points.push(pEntry);
    } else {
        // Overlap/Loopback case
        // Path: Start -> Exit -> Down -> Back -> Down -> Entry -> End
        // Simple "U" turn shape
        points.push(pExit);
        
        const midY = (startY + endY) / 2;
        
        points.push({ x: pExit.x, y: midY });
        points.push({ x: pEntry.x, y: midY });
        points.push(pEntry);
    }

    // End point
    points.push({ x: endX, y: endY });
    
    // Filter duplicates to prevent NaN in bezier calculations
    return points.filter((p, i) => {
        if (i === 0) return true;
        const prev = points[i - 1];
        if (!prev) return true;
        return Math.abs(p.x - prev.x) > 0.1 || Math.abs(p.y - prev.y) > 0.1;
    });
}
const splitSize = ref(0.4)
const ROW_HEIGHT = 40

// --- Zoom Logic ---
type ZoomLevel = 'week' | 'month' | 'quarter' | 'year'

const zoomLevel = ref<ZoomLevel>('month')

const zoomOptions = [
    { label: '日视图', value: 'month' }, // Default
    { label: '周视图', value: 'week' },
    { label: '月视图', value: 'quarter' },
    { label: '年视图', value: 'year' }
]

const dayWidthMap: Record<ZoomLevel, number> = {
    week: 15, // Compact daily view
    month: 40, // Standard daily view
    quarter: 6, // Compressed
    year: 2 // Very compressed
}

const DAY_WIDTH = computed(() => dayWidthMap[zoomLevel.value])

// --- Data Structure for Custom Tree Table ---
const expandedKeys = ref<Set<string>>(new Set())

// Initialize expandedKeys with all phase IDs
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

// --- Tooltip Logic ---
const tooltip = ref({
    visible: false,
    text: '',
    x: 0,
    y: 0
});

const measureTextWidth = (text: string, fontSize: number = 12) => {
    const canvas = document.createElement('canvas');
    const context = canvas.getContext('2d');
    if (context) {
        context.font = `${fontSize}px sans-serif`;
        return context.measureText(text).width;
    }
    return text.length * fontSize * 0.6; // Fallback
};

const selectedTaskId = ref<string | null>(null);
const animatingLines: any[] = [];
let animationFrameId: number;

const startAnimationLoop = () => {
    const animate = () => {
        if (animatingLines.length > 0) {
            animatingLines.forEach(line => {
                const current = line.dashOffset || 0;
                line.dashOffset = current - 0.5; // Flow speed
            });
        }
        animationFrameId = requestAnimationFrame(animate);
    };
    animate();
};

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
        
        // Calculate vectors
        const v1 = { x: pCurr.x - pPrev.x, y: pCurr.y - pPrev.y };
        const v2 = { x: pNext.x - pCurr.x, y: pNext.y - pCurr.y };
        
        const len1 = Math.sqrt(v1.x * v1.x + v1.y * v1.y);
        const len2 = Math.sqrt(v2.x * v2.x + v2.y * v2.y);
        
        // Clamp radius to half the shortest segment length
        const r = Math.min(radius, len1 / 2, len2 / 2);
        
        // Calculate start of curve (on incoming segment)
        const startX = pCurr.x - (v1.x / len1) * r;
        const startY = pCurr.y - (v1.y / len1) * r;
        
        // Calculate end of curve (on outgoing segment)
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

// Flattened data for rendering
const visibleRows = computed(() => {
    const rows: any[] = []
    let rowNumber = 1 // Global counter for visible rows
    const taskIdToRowMap = new Map<string, number>()

    // First pass: generate rows and build ID map
    store.phases.forEach(phase => {
        // Calculate Phase Progress (Weighted by Duration)
        const phaseTasks = store.tasks.filter(t => t.phaseId === phase.id);
        let totalWeightedProgress = 0;
        let totalDuration = 0;
        
        phaseTasks.forEach(t => {
             const start = parseLocalDate(t.startDate).getTime();
             const end = parseLocalDate(t.endDate).getTime();
             // Duration in days, inclusive
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
        
        // Task Rows (if expanded)
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
                         // Fallback: If not visible, show Task Name or "*"
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

// --- Gantt Time Axis & Headers ---
const timeRange = computed(() => {
    let dates = store.tasks.flatMap(t => [parseLocalDate(t.startDate), parseLocalDate(t.endDate)])
        .filter(d => !isNaN(d.getTime()));
    
    // Sanitize dates (2000-2100) to prevent huge range
    dates = dates.filter(d => d.getFullYear() >= 2000 && d.getFullYear() <= 2100);

    if (dates.length === 0) {
        // Default range if no dates: Current Month
        const now = new Date();
        const start = new Date(now.getFullYear(), now.getMonth(), 1);
        const end = new Date(now.getFullYear(), now.getMonth() + 1, 0); 
        return { start, end };
    }
    
    let minDate = new Date(Math.min(...dates.map(d => d.getTime())));
    let maxDate = new Date(Math.max(...dates.map(d => d.getTime())));
    
    // Add small buffer (e.g., 3 days)
    minDate.setDate(minDate.getDate() - 3);
    maxDate.setDate(maxDate.getDate() + 3);

    // Check if we need to fill viewport
    const vWidth = viewportWidth.value;
    if (vWidth > 0) {
        const dayW = DAY_WIDTH.value;
        const currentMs = maxDate.getTime() - minDate.getTime();
        const currentDays = currentMs / (1000 * 3600 * 24);
        const currentWidth = currentDays * dayW;
        
        if (currentWidth < vWidth) {
            const missingWidth = vWidth - currentWidth;
            // Add extra buffer to ensure we cover the space and maybe a bit more to avoid edge glitches
            const missingDays = Math.ceil(missingWidth / dayW) + 2;
            
            // Add padding to center the content roughly
            const addStart = Math.floor(missingDays / 2);
            const addEnd = missingDays - addStart;
            
            minDate.setDate(minDate.getDate() - addStart);
            maxDate.setDate(maxDate.getDate() + addEnd);
        }
    }
    
    // Normalize to start of day
    minDate = new Date(minDate.getFullYear(), minDate.getMonth(), minDate.getDate());
    maxDate = new Date(maxDate.getFullYear(), maxDate.getMonth(), maxDate.getDate());

    return { start: minDate, end: maxDate };
})

const isTodayInView = computed(() => {
    const { start, end } = timeRange.value;
    const today = parseLocalDate(new Date().toISOString());
    return today.getTime() >= start.getTime() && today.getTime() <= end.getTime();
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
    const { start } = timeRange.value;
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
                    topRow.push({
                        label: `${start.getFullYear() + Math.floor((start.getMonth() + topRow.length)/12)}-${((start.getMonth() + topRow.length)%12)+1}`, // Approximate label logic needs fix
                        width: currentMonthWidth,
                        left: currentMonthStart
                    });
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
            topRow.push({
                label: `${lastD.getFullYear()}-${lastD.getMonth()+1}`,
                width: currentMonthWidth,
                left: currentMonthStart
            });
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

const totalWidth = computed(() => days.value.length * DAY_WIDTH.value)
const totalHeight = computed(() => Math.max(visibleRows.value.length * ROW_HEIGHT, 1))

// --- Sync Scrolling ---
const leftBodyRef = ref<HTMLElement | null>(null)
const rightScrollRef = ref<HTMLElement | null>(null)
const rightHeaderRef = ref<HTMLElement | null>(null)

const scrollLeft = ref(0)
const scrollTop = ref(0)
const viewportWidth = ref(0)
const viewportHeight = ref(0)

// --- Panning State ---
const isPanning = ref(false)
const startPanX = ref(0)
const startPanY = ref(0)
const startScrollLeft = ref(0)
const startScrollTop = ref(0)

const handleRightScroll = (e: Event) => {
    const target = e.target as HTMLElement
    if (!target) return
    
    scrollLeft.value = target.scrollLeft
    scrollTop.value = target.scrollTop

    if (leftBodyRef.value) {
        leftBodyRef.value.scrollTop = target.scrollTop
    }
    if (rightHeaderRef.value) {
        rightHeaderRef.value.scrollLeft = target.scrollLeft
    }
    
    // Update Leafer Group Position
    if (chartGroup) {
        chartGroup.x = -scrollLeft.value
        chartGroup.y = -scrollTop.value
    }
}

const handleLeftWheel = (e: WheelEvent) => {
    // Forward vertical scroll to the right pane
    if (e.deltaY !== 0 && rightScrollRef.value) {
        rightScrollRef.value.scrollTop += e.deltaY
    }
}

// --- Panning & Zooming Handlers ---

const handleGlobalMouseMove = (e: MouseEvent) => {
    if (!isPanning.value || !rightScrollRef.value) return;
    const dx = e.screenX - startPanX.value;
    const dy = e.screenY - startPanY.value;
    rightScrollRef.value.scrollLeft = startScrollLeft.value - dx;
    rightScrollRef.value.scrollTop = startScrollTop.value - dy;
}

const handleGlobalMouseUp = () => {
    if (isPanning.value) {
        isPanning.value = false;
        document.body.style.cursor = '';
    }
}

// Order: Zoom Out (Year) -> Zoom In (Month)
// 'year' (2px), 'quarter' (6px), 'week' (15px), 'month' (40px)
const zoomLevels: ZoomLevel[] = ['year', 'quarter', 'week', 'month'];

const handleWheel = async (e: WheelEvent) => {
    if (e.ctrlKey) {
        // e.preventDefault() is handled by template modifier or here if passive: false
        // Since we will attach @wheel="handleWheel" without .passive, we can preventDefault here.
        e.preventDefault();
        
        // Direction: 
        // deltaY > 0 (Scroll Down) -> Zoom Out -> Decrease Index (Move Left)
        // deltaY < 0 (Scroll Up) -> Zoom In -> Increase Index (Move Right)
        const direction = e.deltaY > 0 ? -1 : 1;
        
        const currentIndex = zoomLevels.indexOf(zoomLevel.value);
        let newIndex = currentIndex + direction;
        
        if (newIndex < 0) newIndex = 0;
        if (newIndex >= zoomLevels.length) newIndex = zoomLevels.length - 1;
        
        if (newIndex !== currentIndex && rightScrollRef.value) {
            const rect = rightScrollRef.value.getBoundingClientRect();
            // Mouse X relative to Viewport
            const mouseX = e.clientX - rect.left;
            // Absolute X in Content
            const absoluteX = mouseX + rightScrollRef.value.scrollLeft;
            
            // Calculate Date at Mouse X based on CURRENT settings
            const { start } = timeRange.value;
            const currentDayW = DAY_WIDTH.value;
            const daysFromStart = absoluteX / currentDayW;
            const timeAtMouse = start.getTime() + daysFromStart * 24 * 3600 * 1000;
            
            // Apply new zoom
            const nextZoom = zoomLevels[newIndex];
            if (nextZoom) {
                zoomLevel.value = nextZoom;
            }
            
            // Wait for DOM/Leafer update (re-render triggers DAY_WIDTH change)
            await nextTick();
            
            // Recalculate Position
            const newDayW = DAY_WIDTH.value;
            const { start: newStart } = timeRange.value; // timeRange start might shift
            
            const newDaysFromStart = (timeAtMouse - newStart.getTime()) / (24 * 3600 * 1000);
            const newAbsoluteX = newDaysFromStart * newDayW;
            
            // Adjust scroll so that newAbsoluteX is at mouseX
            const newScrollLeft = newAbsoluteX - mouseX;
            
            rightScrollRef.value.scrollLeft = newScrollLeft;
        }
    }
}

const handleHeaderMouseMove = (e: MouseEvent) => {
    if (!rightHeaderRef.value) return;
    
    const rect = rightHeaderRef.value.getBoundingClientRect();
    const x = e.clientX - rect.left + rightHeaderRef.value.scrollLeft;
    const dayIndex = Math.floor(x / DAY_WIDTH.value);
    
    if (dayIndex >= 0 && dayIndex < days.value.length) {
        const d = days.value[dayIndex];
        if (!d) return;

        const weekMap = ['日', '一', '二', '三', '四', '五', '六'];
        const weekStr = `星期${weekMap[d.getDay()]}`;
        const y = d.getFullYear();
        const m = String(d.getMonth() + 1).padStart(2, '0');
        const day = String(d.getDate()).padStart(2, '0');
        const dateStr = `${y}-${m}-${day}`;
        
        let statusStr = '';
        try {
            const name = holiday.publicHolidayName(d);
            if (name) {
                statusStr = ` [${name}]`;
            } else if (holiday.isPublicWorkday(d)) {
                statusStr = ' [班]'; // Adjusted workday
            } else if (holiday.isHoliday(d)) {
                statusStr = ' [周末]';
            }
        } catch (err) {
            // Ignore error
        }
        
        tooltip.value = {
            visible: true,
            text: `${dateStr} ${weekStr}${statusStr}`,
            x: e.clientX + 10,
            y: e.clientY + 20
        };
    } else {
        tooltip.value.visible = false;
    }
}

const handleHeaderMouseLeave = () => {
    tooltip.value.visible = false;
}

const scrollToToday = () => {
    if (!rightScrollRef.value) return;
    const { start } = timeRange.value;
    // Use parseLocalDate to ensure we are using start of day local time
    // But actually new Date() is fine if we just want "today"
    const today = parseLocalDate(new Date().toISOString()); 
    const diffTime = today.getTime() - start.getTime();
    const diffDays = diffTime / (1000 * 3600 * 24);
    
    // Position at start of today + half day width to center in the day column
    const todayX = diffDays * DAY_WIDTH.value + DAY_WIDTH.value / 2;
    const viewportW = rightScrollRef.value.clientWidth;
    
    // Center the exact current time line
    const targetScrollX = todayX - viewportW / 2;
    
    rightScrollRef.value.scrollTo({
        left: Math.max(0, targetScrollX),
        behavior: 'auto' // Use auto to ensure immediate and accurate positioning
    });
}

const scrollToTask = (row: any) => {
    if (!rightScrollRef.value || !row.startDate || !row.endDate) return;
    
    // Sync selection
    store.selectElement('task', row.id);
    
    const { start } = timeRange.value;
    const taskStart = parseLocalDate(row.startDate);
    const taskEnd = parseLocalDate(row.endDate);
    
    if (isNaN(taskStart.getTime()) || isNaN(taskEnd.getTime())) return;
    
    const diffTimeStart = taskStart.getTime() - start.getTime();
    const diffDaysStart = diffTimeStart / (1000 * 3600 * 24);
    
    const diffTimeEnd = taskEnd.getTime() - start.getTime();
    const diffDaysEnd = diffTimeEnd / (1000 * 3600 * 24);
    
    const startX = diffDaysStart * DAY_WIDTH.value;
    const endX = (diffDaysEnd + 1) * DAY_WIDTH.value;
    const taskWidth = endX - startX;
    
    const viewportW = rightScrollRef.value.clientWidth;
    
    let targetScrollX = 0;
    
    if (taskWidth < viewportW) {
        // Task fits in viewport, center it
        const centerX = startX + taskWidth / 2;
        targetScrollX = centerX - viewportW / 2;
    } else {
        // Task is wider than viewport, scroll to start with slight buffer
        targetScrollX = startX - 50; // 50px buffer
    }
    
    const clampedScrollLeft = Math.max(0, targetScrollX);
    
    // Animate scroll? Native smooth scroll might be enough, but we manually sync chartGroup.
    // Let's stick to direct assignment for responsiveness, or use behavior: 'smooth' but we need to listen to scroll events.
    // Since we handle scroll events to update chartGroup, smooth scroll should work.
    
    rightScrollRef.value.scrollTo({
        left: clampedScrollLeft,
        behavior: 'smooth'
    });
    
    // Note: chartGroup update will happen in scroll event handler
}

const statusColors: Record<string, string> = {
    completed: "#4CAF50",
    in_progress: "#2196F3",
    delayed: "#F44336",
    pending: "#9E9E9E",
};



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
        textAlign: 'center' as const,
        color: '#333' 
    }
}

// --- Leafer UI Integration ---
const ganttContainerRef = ref<HTMLElement | null>(null)
let leaferApp: App | null = null
let chartGroup: Group | null = null

const initLeafer = () => {
    if (!ganttContainerRef.value) return
    
    // Destroy existing instance if any
    if (leaferApp) {
        leaferApp.destroy()
    }

    leaferApp = new App({
        view: ganttContainerRef.value,
        fill: '#ffffff', // Background color
        tree: {}, // Start with default tree config
        type: 'user' as any // Important: ensures events work with manual transform
    })

    chartGroup = new Group()
    leaferApp.tree.add(chartGroup)
    
    // Initial sync
    if (rightScrollRef.value) {
         chartGroup.x = -rightScrollRef.value.scrollLeft
         chartGroup.y = -rightScrollRef.value.scrollTop
    }
    
    drawGantt()
}

const drawGantt = () => {
    if (!chartGroup || !leaferApp) return
    const group = chartGroup
    
    group.clear()
    
    const { start: minDate } = timeRange.value

    if (!minDate) return

    // Groups for layering
    const gridGroup = new Group()
    const lineGroup = new Group()
    const taskGroup = new Group()
    
    group.add(gridGroup)
    
    // NEW: Background for Panning (Above grid, below lines/tasks)
    const bgRect = new Rect({
        x: 0, y: 0,
        width: Math.max(totalWidth.value, viewportWidth.value),
        height: Math.max(totalHeight.value, viewportHeight.value),
        fill: 'transparent' // Clickable but invisible
    })
    bgRect.on(LeaferPointerEvent.DOWN, (e) => {
        // Use native event to get screen coordinates
        const native = e.origin as MouseEvent;
        // Check if screenX exists (MouseEvent)
        if (native && typeof native.screenX === 'number') {
            isPanning.value = true;
            startPanX.value = native.screenX;
            startPanY.value = native.screenY;
            if (rightScrollRef.value) {
                startScrollLeft.value = rightScrollRef.value.scrollLeft;
                startScrollTop.value = rightScrollRef.value.scrollTop;
            }
            document.body.style.cursor = 'grabbing';
        }
    })
    group.add(bgRect)

    group.add(lineGroup)
    group.add(taskGroup)
    
    // 0. Draw Weekend/Holiday Backgrounds
    if (zoomLevel.value !== 'year') {
        const holidayColor = '#f5f5f5'; // Light grey for weekends
        const legalHolidayColor = '#e8e8e8'; // Slightly darker for legal holidays
        
        // Use library to check holidays
        // @kang8/chinese-holidays:
        // isWorkday(date): True if working day.
        // isPublicHoliday(date): True if it's a legal holiday (e.g. National Day), excluding normal weekends.
        
        days.value.forEach((d, i) => {
             // Check if it is a working day
             // Note: isWorkday returns true for adjusted working days (even if Saturday/Sunday)
             // and false for holidays/weekends.
             let isWork = true;
             let isPublic = false;
             
             try {
                 isWork = holiday.isWorkday(d);
                 isPublic = holiday.isPublicHoliday(d);
             } catch (e) {
                 // Fallback if library fails for some date range or error
                 const dayOfWeek = d.getDay();
                 isWork = dayOfWeek !== 0 && dayOfWeek !== 6;
             }
             
             if (!isWork) {
                 // It is a rest day (Weekend or Holiday)
                 // Determine color: slightly darker if it's a public holiday
                 
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

    // 1. Draw Grid Lines (Vertical)
    // Actually simpler: draw grid based on bottom row ticks of header
    timelineHeaders.value.bottomRow.forEach(tick => {
         gridGroup.add(new Rect({
             x: tick.left,
             y: 0,
             width: 1,
             height: totalHeight.value,
             fill: '#f0f0f0'
         }))
         // Also add line at end of tick
         gridGroup.add(new Rect({
             x: tick.left + tick.width,
             y: 0,
             width: 1,
             height: totalHeight.value,
             fill: '#f0f0f0'
         }))
    })

    // Draw Today Line
    // Use parseLocalDate to get 00:00:00 of today for consistent diffing
    const today = parseLocalDate(new Date().toISOString());
    const diffTimeToday = today.getTime() - minDate.getTime();
    if (diffTimeToday >= 0) {
        const diffDaysToday = diffTimeToday / (1000 * 3600 * 24);
        // Center the line in the day column
        const todayX = diffDaysToday * DAY_WIDTH.value + DAY_WIDTH.value / 2;
        
        gridGroup.add(new Line({
            points: [todayX, 0, todayX, totalHeight.value],
            stroke: 'rgba(255, 0, 0, 0.5)',
            strokeWidth: 1,
            dashPattern: [5, 5],
            zIndex: 5
        }));
    }
    
    // Map to store task positions for dependency lines
    const taskPositions = new Map<string, { x: number, y: number, width: number, height: number }>();

    // 3. Draw Dependency Lines (Initial)
    const drawDependencyLines = () => {
        // Clear existing lines
        lineGroup.clear();
        animatingLines.length = 0;

        visibleRows.value.forEach(row => {
            if (row.type === 'task' && row.data && row.data.dependencies) {
                 row.data.dependencies.forEach((depOrObj: string | any) => {
                     const depId = typeof depOrObj === 'string' ? depOrObj : depOrObj.taskId;
                     const source = taskPositions.get(depId);
                     const target = taskPositions.get(row.id);
                     
                     if (source && target) {
                         const startX = source.x + source.width;
                         const startY = source.y + source.height / 2;
                         const endX = target.x;
                         const endY = target.y + target.height / 2;
                         
                         // Safety check: ensure coordinates are valid numbers and not (0,0) which indicates an error
                         if (
                             isNaN(startX) || isNaN(startY) || isNaN(endX) || isNaN(endY) ||
                             (Math.abs(startX) < 1 && Math.abs(startY) < 1) || 
                             (Math.abs(endX) < 1 && Math.abs(endY) < 1)
                         ) {
                             return;
                         }

                         const points = getPolylinePoints(startX, startY, endX, endY);
                         // Use rounded corners
                         const pathData = pointsToRoundedPath(points, 5);
                         
                         // Determine if line should be highlighted
                         const isSelected = selectedTaskId.value && (selectedTaskId.value === row.id || selectedTaskId.value === depId);
                         
                         const line = new Path({
                             path: pathData,
                             stroke: isSelected ? '#2196f3' : '#999',
                             strokeWidth: isSelected ? 2 : 1,
                             dashPattern: isSelected ? [5, 5] : undefined
                         });
                         
                         if (isSelected) {
                             animatingLines.push(line);
                         }
                         
                         lineGroup.add(line);

                         // Draw Arrow manually
                         if (points.length >= 2) {
                             const pLast = points[points.length - 1];
                             const pPrev = points[points.length - 2];
                             
                             if (pLast && pPrev) {
                                 const angle = Math.atan2(pLast.y - pPrev.y, pLast.x - pPrev.x) * 180 / Math.PI;
                                 
                                 const headLen = 10;
                                 const headAngle = Math.PI / 6; // 30 degrees
                                 const rad = (angle * Math.PI) / 180;
                                 
                                 const tipX = pLast.x;
                                 const tipY = pLast.y;
                                 
                                 const leftX = tipX - headLen * Math.cos(rad - headAngle);
                                 const leftY = tipY - headLen * Math.sin(rad - headAngle);
                                 
                                 const rightX = tipX - headLen * Math.cos(rad + headAngle);
                                 const rightY = tipY - headLen * Math.sin(rad + headAngle);
                                 
                                 const arrow = new Path({
                                     path: `M ${tipX} ${tipY} L ${leftX} ${leftY} L ${rightX} ${rightY} Z`,
                                     fill: isSelected ? '#2196f3' : '#999'
                                 });
                                 
                                 lineGroup.add(arrow);
                             }
                         }
                     }
                 });
            }
        });
    }

    // 2. Draw Rows & Calculate Task Positions
    visibleRows.value.forEach((row, index) => {
        const y = index * ROW_HEIGHT
        
        // Horizontal Line
        gridGroup.add(new Rect({
            x: 0,
            y: y + ROW_HEIGHT - 1,
            width: totalWidth.value,
            height: 1,
            fill: '#eee'
        }))
        
        // Draw Task Bar
        if (row.type === 'task' && row.startDate && row.endDate) {
            const start = parseLocalDate(row.startDate)
            const end = parseLocalDate(row.endDate)
            
            if (!isNaN(start.getTime()) && !isNaN(end.getTime())) {
                const offsetMs = start.getTime() - minDate.getTime()
                const durationMs = end.getTime() - start.getTime()
                
                const msPerDay = 1000 * 3600 * 24
                const offsetDays = offsetMs / msPerDay
                const durationDays = durationMs / msPerDay + 1 // Inclusive
                
                const barX = offsetDays * DAY_WIDTH.value
                const barW = durationDays * DAY_WIDTH.value
                const barHeight = ROW_HEIGHT - 16;
                const barY = y + 8;
                
                // Color Logic
                const color = statusColors[row.data.status] || "#9E9E9E";
                const progressPct = (row.data.progress || 0) / 100;
                const startColor = row.data.startColor || 'white';
                const endColor = row.data.endColor || '#B3E5FC';

                const fill = {
                    type: 'linear',
                    from: { x: 0, y: 0 },
                    to: { x: barW, y: 0 },
                    stops: [
                        { offset: 0, color: startColor },
                        { offset: progressPct, color: endColor },
                        { offset: progressPct, color: 'white' },
                        { offset: 1, color: 'white' }
                    ]
                };

                // Task Group (for Bar and Label)
                const itemGroup = new Group({
                    x: barX,
                    y: barY,
                    cursor: 'grab',
                    draggable: true,
                    zIndex: 10
                });

                // Selection Handler
                itemGroup.on(LeaferPointerEvent.TAP, () => {
                    store.selectElement('task', row.id);
                });

                // Task Bar
                const isSelected = selectedTaskId.value === row.id;
                const bar = new Rect({
                    x: 0,
                    y: 0,
                    width: Math.max(barW, 2),
                    height: barHeight,
                    fill: fill,
                    stroke: isSelected ? '#000' : color, 
                    strokeWidth: isSelected ? 2 : 1,
                    cornerRadius: 4
                })

                // Resize Handle (Right)
                const resizeHandle = new Rect({
                    x: Math.max(barW - 8, 0),
                    y: 0,
                    width: 8,
                    height: barHeight,
                    fill: 'transparent',
                    cursor: 'ew-resize',
                    zIndex: 11
                });
                
                // Visual grip lines for resize handle
                const gripLine = new Rect({
                    x: Math.max(barW - 5, 0),
                    y: barHeight / 2 - 4,
                    width: 2,
                    height: 8,
                    fill: 'rgba(255,255,255,0.5)',
                    cornerRadius: 1,
                    listening: false
                });

                // Drag Events for Task Move
                let startDragX = 0;
                let isResizing = false;

                // --- Update Dependencies Function ---
                const updateDependencies = () => {
                     // Update position in map
                     taskPositions.set(row.id, {
                         x: itemGroup.x || 0, // Should be barX initially
                         y: barY,
                         width: bar.width || 0,
                         height: barHeight
                     });
                     
                     // Redraw ALL dependency lines (simplest approach for now)
                     drawDependencyLines();
                };
                
                itemGroup.on(LeaferDragEvent.START, (e: LeaferDragEvent) => {
                    if (isResizing) {
                        e.stop(); // Stop drag if resizing
                        return;
                    }
                    startDragX = itemGroup.x || 0;
                });

                itemGroup.on(LeaferDragEvent.DRAG, (_e: LeaferDragEvent) => {
                    if (isResizing) {
                         // Reset position if accidentally moved
                         itemGroup.x = startDragX; 
                         itemGroup.y = barY;
                         return;
                    }
                    
                    // Allow X-axis drag only
                    itemGroup.y = barY;

                    // Real-time dependency update
                    updateDependencies();
                });

                itemGroup.on(LeaferDragEvent.END, (_e: LeaferDragEvent) => {
                    if (isResizing) return;

                    const currentX = itemGroup.x || 0;
                    const diffX = currentX - startDragX;
                    
                    // Calculate day difference
                    const dayWidth = DAY_WIDTH.value;
                    const dayDiff = Math.round(diffX / dayWidth);
                    
                    if (dayDiff !== 0) {
                        // Calculate new dates
                        const newStart = new Date(start);
                        newStart.setDate(newStart.getDate() + dayDiff);
                        
                        const newEnd = new Date(end);
                        newEnd.setDate(newEnd.getDate() + dayDiff);
                        
                        // Format as YYYY-MM-DD
                        const formatDate = (d: Date) => {
                            const y = d.getFullYear();
                            const m = String(d.getMonth() + 1).padStart(2, '0');
                            const day = String(d.getDate()).padStart(2, '0');
                            return `${y}-${m}-${day}`;
                        };
                        
                        store.updateTask(row.id, {
                            startDate: formatDate(newStart),
                            endDate: formatDate(newEnd)
                        });
                    } else {
                        // Snap back if movement was less than half a day
                        drawGantt();
                    }
                });

                // Resize Logic
                let startResizeW = 0;
                let startResizeMouseX = 0;

                resizeHandle.on(LeaferDragEvent.START, (e: LeaferDragEvent) => {
                    e.stop(); // Prevent parent drag
                    // Set resizing flag immediately and disable parent dragging
                    isResizing = true;
                    itemGroup.draggable = false;
                    
                    startResizeW = bar.width || 0;
                    startResizeMouseX = e.x;
                });



                resizeHandle.on(LeaferDragEvent.DRAG, (e: LeaferDragEvent) => {
                    e.stop();
                    const diff = e.x - startResizeMouseX;
                    const newW = Math.max(DAY_WIDTH.value, startResizeW + diff);
                    
                    bar.width = newW;
                    resizeHandle.x = Math.max(newW - 8, 0);
                    gripLine.x = Math.max(newW - 5, 0);
                    
                    // Real-time dependency update
                    updateDependencies();
                });

                resizeHandle.on(LeaferDragEvent.END, (e: LeaferDragEvent) => {
                    e.stop();
                    isResizing = false;
                    // Re-enable parent dragging
                    itemGroup.draggable = true;
                    
                    const finalW = bar.width || 0;
                    const durationDays = Math.round(finalW / DAY_WIDTH.value);
                    
                    // Calculate new end date based on duration
                    // Note: durationDays = (end - start) / day + 1
                    // So end = start + (durationDays - 1) * day
                    const newEnd = new Date(start);
                    newEnd.setDate(newEnd.getDate() + Math.max(0, durationDays - 1));
                    
                    const formatDate = (d: Date) => {
                        const y = d.getFullYear();
                        const m = String(d.getMonth() + 1).padStart(2, '0');
                        const day = String(d.getDate()).padStart(2, '0');
                        return `${y}-${m}-${day}`;
                    };

                    store.updateTask(row.id, {
                        endDate: formatDate(newEnd)
                    });
                    // Also save width if needed (optional)
                    // store.updateTask(row.id, { width: finalW }); 
                    
                    drawGantt();
                });

                // Tooltip Logic
                itemGroup.on(LeaferPointerEvent.ENTER, (e: LeaferPointerEvent) => {
                    const currentBarW = bar.width || 0;
                    const allowedWidth = Math.max(currentBarW - 10, 0);
                    const textWidth = measureTextWidth(row.name, 12);
                    
                    if (textWidth > allowedWidth) {
                         const evt = (e as any).event || (e as any).origin;
                         if (evt) {
                             tooltip.value = {
                                 visible: true,
                                 text: row.name,
                                 x: evt.clientX + 10,
                                 y: evt.clientY + 10
                             };
                         }
                    }
                });

                itemGroup.on(LeaferPointerEvent.LEAVE, () => {
                    tooltip.value.visible = false;
                });
                
                itemGroup.on(LeaferPointerEvent.MOVE, (e: LeaferPointerEvent) => {
                    if (tooltip.value.visible) {
                         const evt = (e as any).event || (e as any).origin;
                         if (evt) {
                             tooltip.value.x = evt.clientX + 10;
                             tooltip.value.y = evt.clientY + 10;
                         }
                    }
                });

                const label = new Text({
                    x: 6,
                    y: 4,
                    text: row.name,
                    fill: '#333',
                    fontSize: 12,
                    textOverflow: 'ellipsis',
                    width: Math.max(barW - 10, 0)
                });
                
                itemGroup.add(bar)
                itemGroup.add(resizeHandle)
                itemGroup.add(gripLine)
                itemGroup.add(label)
                taskGroup.add(itemGroup)
                
                // Store position
                taskPositions.set(row.id, {
                    x: barX,
                    y: barY,
                    width: Math.max(barW, 2),
                    height: barHeight
                });
            }
        } else if (row.type === 'phase') {
             // Optional: Draw phase background spanning full width
             gridGroup.add(new Rect({
                 x: 0,
                 y: y,
                 width: totalWidth.value,
                 height: ROW_HEIGHT,
                 fill: 'rgba(0,0,0,0.02)',
                 zIndex: -1
             }))
        }
    })

    drawDependencyLines();
    

    
    // Force resize check (No longer needed to set to totalWidth, as we use viewport size)
    // But we might need to redraw if needed.
}

watch([visibleRows, days], () => {
    nextTick(() => {
        drawGantt()
    })
}, { deep: true })

// Sync selection from store
watch(() => store.selectedElement, (newVal) => {
    if (newVal && newVal.type === 'task') {
        selectedTaskId.value = newVal.id;
    } else {
        selectedTaskId.value = null;
    }
    drawGantt();
}, { deep: true });

watch(zoomLevel, (newVal, oldVal) => {
    const oldDayWidth = dayWidthMap[oldVal]
    // Capture current scroll center relative to time
    let centerDays = 0
    if (rightScrollRef.value) {
        const centerPixel = rightScrollRef.value.scrollLeft + rightScrollRef.value.clientWidth / 2
        centerDays = centerPixel / oldDayWidth
    }

    nextTick(() => {
        drawGantt()
        
        // Restore scroll position based on time
        if (rightScrollRef.value) {
            const newDayWidth = dayWidthMap[newVal]
            const newScrollLeft = centerDays * newDayWidth - rightScrollRef.value.clientWidth / 2
            const clampedScrollLeft = Math.max(0, newScrollLeft)
            
            rightScrollRef.value.scrollLeft = clampedScrollLeft
            
            // Manually sync state to prevent lag/blank (waiting for scroll event)
            scrollLeft.value = rightScrollRef.value.scrollLeft
            if (chartGroup) {
                chartGroup.x = -scrollLeft.value
            }
        }
    })
})

// Resize Observer
let resizeObserver: ResizeObserver | null = null

onMounted(() => {
    // Add global mouse listeners for panning
    window.addEventListener('mousemove', handleGlobalMouseMove);
    window.addEventListener('mouseup', handleGlobalMouseUp);

    if (rightScrollRef.value) {
        resizeObserver = new ResizeObserver(entries => {
            for (const entry of entries) {
                viewportWidth.value = entry.contentRect.width
                viewportHeight.value = entry.contentRect.height
                // Force Leafer resize
                if (leaferApp) {
                    leaferApp.resize({ width: viewportWidth.value, height: viewportHeight.value })
                    // Redraw to update background rect size
                    drawGantt()
                }
            }
        })
        resizeObserver.observe(rightScrollRef.value)
        
        // Initial values
        viewportWidth.value = rightScrollRef.value.clientWidth
        viewportHeight.value = rightScrollRef.value.clientHeight
    }

    initLeafer()
    // Sync initial scroll
    if (rightScrollRef.value) {
        rightScrollRef.value.scrollTop = 0
        scrollToToday()
    }
    
    startAnimationLoop();
})

onUnmounted(() => {
    window.removeEventListener('mousemove', handleGlobalMouseMove);
    window.removeEventListener('mouseup', handleGlobalMouseUp);

    if (animationFrameId) {
        cancelAnimationFrame(animationFrameId);
    }
    if (resizeObserver) {
        resizeObserver.disconnect()
    }
    if (leaferApp) {
        leaferApp.destroy()
        leaferApp = null
    }
})
</script>

<template>
    <div class="gantt-view">
        <n-split direction="horizontal" :default-size="splitSize" :min="0.2" :max="0.8" style="height: 100%; width: 100%;">
            <template #1>
                <div class="left-pane">
                    <div class="pane-toolbar left-toolbar">
                        <span style="font-weight: bold; padding-left: 10px;">任务列表</span>
                    </div>
                    <div class="pane-header left-header-row">
                        <div class="left-header-cell col-id">ID</div>
                        <div class="left-header-cell col-name">名称</div>
                        <div class="left-header-cell col-status">进度</div>
                        <div class="left-header-cell col-owner">负责人</div>
                        <div class="left-header-cell col-pred">前置任务</div>
                        <div class="left-header-cell col-date">开始时间</div>
                        <div class="left-header-cell col-date">结束时间</div>
                    </div>
                    <div class="left-body" ref="leftBodyRef" @wheel="handleLeftWheel">
                        <div class="table-row" 
                             v-for="row in visibleRows" 
                             :key="row.id"
                             :class="`row-${row.type}`"
                             @click="scrollToTask(row)"
                        >
                            <div class="cell-id col-id">{{ row.rowNumber }}</div>
                            <div class="cell-name col-name" :style="{ paddingLeft: (row.depth * 20 + 10) + 'px' }">
                                <span v-if="row.type === 'phase'" class="toggle-icon" @click.stop="toggleExpand(row.id)">
                                    {{ row.expanded ? '▼' : '▶' }}
                                </span>
                                {{ row.name }}
                            </div>
                            <div class="cell-status col-status" :style="getProgressStyle(row)">
                                {{ row.progress }}%
                            </div>
                            <div class="cell-owner col-owner">{{ row.owner }}</div>
                            <div class="cell-pred col-pred">{{ row.predecessors }}</div>
                            <div class="cell-date col-date">{{ row.startDate ? parseLocalDate(row.startDate).toLocaleDateString() : '' }}</div>
                            <div class="cell-date col-date">{{ row.endDate ? parseLocalDate(row.endDate).toLocaleDateString() : '' }}</div>
                        </div>
                        <div class="scroll-spacer"></div>
                    </div>
                </div>
            </template>
            <template #2>
                <div class="right-pane">
                    <div class="pane-toolbar right-toolbar">
                        <n-button v-if="isTodayInView" size="small" @click="scrollToToday" style="margin-right: 10px;">今天</n-button>
                        <n-select v-model:value="zoomLevel" :options="zoomOptions" size="small" style="width: 150px" />
                    </div>
                    <div class="pane-header right-header-row" ref="rightHeaderRef" 
                         @mousemove="handleHeaderMouseMove" 
                         @mouseleave="handleHeaderMouseLeave">
                         <div class="timeline-header" :style="{ width: (totalWidth + 17) + 'px' }">
                             <!-- Top Row -->
                             <div class="header-row top">
                                 <div v-for="(item, i) in timelineHeaders.topRow" :key="i"
                                      class="header-cell"
                                      :style="{ width: item.width + 'px', left: item.left + 'px' }">
                                     {{ item.label }}
                                 </div>
                             </div>
                             <!-- Bottom Row -->
                             <div class="header-row bottom">
                                 <div v-for="(item, i) in timelineHeaders.bottomRow" :key="i"
                                      class="header-cell"
                                      :style="{ width: item.width + 'px', left: item.left + 'px' }">
                                     {{ item.label }}
                                 </div>
                             </div>
                         </div>
                    </div>
                    <div class="right-scroll-container" @scroll="handleRightScroll" @wheel="handleWheel" ref="rightScrollRef">
                        <div class="spacer" :style="{ width: totalWidth + 'px', height: totalHeight + 'px' }"></div>
                        <div ref="ganttContainerRef" 
                             :style="{ 
                                 position: 'absolute', 
                                 left: 0, 
                                 top: 0, 
                                 width: viewportWidth + 'px', 
                             height: viewportHeight + 'px',
                             transform: `translate(${scrollLeft}px, ${scrollTop}px)`
                         }"
                    ></div>
                    </div>
                </div>
            </template>
        </n-split>
        <div v-if="tooltip.visible" :style="{ 
            position: 'fixed', 
            left: tooltip.x + 'px', 
            top: tooltip.y + 'px', 
            background: 'rgba(0, 0, 0, 0.8)', 
            color: '#fff', 
            padding: '5px 10px', 
            borderRadius: '4px', 
            fontSize: '12px', 
            pointerEvents: 'none', 
            zIndex: 9999,
            whiteSpace: 'nowrap'
        }">
            {{ tooltip.text }}
        </div>
    </div>
</template>

<style scoped>
.gantt-view {
    height: 100%;
    width: 100%;
    display: flex;
    flex-direction: column;
}
.left-pane, .right-pane {
    height: 100%;
    width: 100%;
    display: flex;
    flex-direction: column;
}
.pane-toolbar {
    height: 42px;
    border-bottom: 1px solid #eee;
    display: flex;
    align-items: center;
    background: #fff;
    flex-shrink: 0;
}
.left-toolbar {
    /* Optional specifics for left toolbar */
}
.right-toolbar {
    justify-content: flex-end;
    padding: 0 5px;
}

.pane-header {
    height: 50px; /* 2 rows of 25px */
    background: #f5f5f5;
    border-bottom: 1px solid #e0e0e0;
    flex-shrink: 0;
    position: relative;
}

.left-header-row {
    display: flex;
    align-items: center;
    padding-left: 0; /* Remove padding as cells handle it or not needed */
    font-weight: bold;
}

.left-header-cell {
    display: flex;
    align-items: center;
    justify-content: center;
    border-right: 1px solid #e0e0e0;
    font-size: 12px;
    color: #666;
    box-sizing: border-box;
    white-space: nowrap;
    overflow: hidden;
    height: 100%;
    background: #f5f5f5;
    flex-shrink: 0;
}

.col-name { width: 200px; }
.col-status { width: 80px; }
.col-owner { width: 80px; }
.col-date { width: 100px; }
.col-id { width: 40px; text-align: center; justify-content: center; }
.col-pred { width: 80px; text-align: center; justify-content: center; }

.right-header-row {
    overflow: hidden; /* Controlled by JS */
}

.left-body {
    flex: 1;
    overflow-y: hidden; /* Scroll controlled by JS via right pane */
    overflow-x: auto;
}
.table-row {
    height: 40px;
    border-bottom: 1px solid #eee;
    display: flex;
    align-items: center;
    white-space: nowrap;
    font-size: 13px;
    cursor: pointer;
    transition: background-color 0.2s;
}
.table-row:hover {
    background-color: #f0f8ff;
}
.row-phase {
    background: #fafafa;
    font-weight: bold;
}

.cell-name, .cell-status, .cell-owner, .cell-date, .cell-id, .cell-pred {
    display: flex;
    align-items: center;
    border-right: 1px solid #eee;
    box-sizing: border-box;
    height: 100%;
    overflow: hidden;
    text-overflow: ellipsis;
    padding: 0 5px;
    flex-shrink: 0;
}

.cell-status, .cell-owner, .cell-date, .cell-id, .cell-pred {
    justify-content: center;
}

.toggle-icon {
    cursor: pointer;
    margin-right: 5px;
    width: 16px;
    display: inline-block;
    text-align: center;
}
.timeline-header {
    height: 100%;
    position: relative;
}

.header-row {
    height: 25px;
    position: relative;
    width: 100%;
}
.header-row.top {
    background: #f9f9f9;
    border-bottom: 1px solid #eee;
}
.header-row.bottom {
    background: #fff;
}

.header-cell {
    position: absolute;
    top: 0;
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
    border-right: 1px solid #e0e0e0;
    font-size: 12px;
    color: #666;
    box-sizing: border-box;
    white-space: nowrap;
    overflow: hidden;
}

.right-scroll-container {
    flex: 1;
    overflow: auto; /* Master scroll */
    position: relative;
}

.leafer-wrapper {
    /* Dimensions set by style binding */
}
.scroll-spacer {
    height: 17px; /* Standard scrollbar height */
    flex-shrink: 0;
}
</style>
