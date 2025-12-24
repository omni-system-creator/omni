<template>
  <div class="dv-scroll-board"  @mouseenter="handleMouseEnter" @mouseleave="handleMouseLeave">
    <table v-if="status.header.length && status.mergedConfig" :style="`background-color: ${status.mergedConfig.headerBGC};`">
      <thead>
        <tr>
          <th
            v-for="(headerItem, i) in status.header"
            :key="`${headerItem}${i}`"
            :style="`
              height: ${status.mergedConfig.headerHeight}px;
              line-height: ${status.mergedConfig.headerHeight}px;
              width: ${status.widths[i]}px;
              text-align: ${status.aligns[i]};
            `"
            v-html="headerItem"
          />
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="(row, ri) in status.rows"
          :key="`${row.toString()}${row.scroll}`"
          :style="`
            height: ${status.heights[ri]}px;
            line-height: ${status.heights[ri]}px;
            background-color: ${status.mergedConfig[row.rowIndex % 2 === 0 ? 'evenRowBGC' : 'oddRowBGC']};
          `"
        >
          <td
            v-for="(ceil, ci) in row.ceils"
            :key="`${ceil}${ri}${ci}`"
            :style="`width: ${status.widths[ci]}px; text-align: ${status.aligns[ci]};`"
            v-html="ceil"
          />
        </tr>
      </tbody>
    </table>
  </div>
</template>
<script setup lang="ts">
import { PropType, onUnmounted, reactive, toRefs, watch, onMounted } from 'vue'
import { CreateComponentType } from '@/packages/index.d'
import { useChartDataFetch } from '@/hooks'
import { useChartEditStore } from '@/store/modules/chartEditStore/chartEditStore'
import merge from 'lodash/merge'
import cloneDeep from 'lodash/cloneDeep'

const props = defineProps({
  chartConfig: {
    type: Object as PropType<CreateComponentType>,
    required: true
  }
})

const { w, h } = toRefs(props.chartConfig.attr)

const status = reactive({
  defaultConfig: {
    header: [],
    dataset: [],
    rowNum: 5,
    headerBGC: '#00BAFF',
    oddRowBGC: '#003B51',
    evenRowBGC: '#0A2732',
    waitTime: 2, // 轮播间隔时间（秒）
    headerHeight: 35,
    columnWidth: [],
    align: [],
    index: false,
    indexHeader: '序号',
    carousel: 'single', // 轮播模式：'single' 或 'page'
    hoverPause: true // 是否在鼠标悬停时暂停轮播
  },
  mergedConfig: props.chartConfig.option,
  header: [],
  rowsData: [],
  rows: [
    {
      ceils: [],
      rowIndex: 0,
      scroll: 0
    }
  ],
  widths: [],
  heights: [0],
  avgHeight: 0,
  aligns: [],
  animationIndex: 0,
  animationHandler: 0,
  updater: 0,
  needCalc: false
})

const calcData = () => {
  mergeConfig()
  calcHeaderData()
  calcRowsData()
  calcWidths()
  calcHeights()
  calcAligns()
  animation(true)
}

onMounted(() => {
  calcData()
})

const mergeConfig = () => {
  status.mergedConfig = merge(cloneDeep(status.defaultConfig), props.chartConfig.option)
}

const calcHeaderData = () => {
  let { header, index, indexHeader } = status.mergedConfig
  if (!header.length) {
    status.header = []
    return
  }
  header = [...header]
  if (index) header.unshift(indexHeader)
  status.header = header
}

const calcRowsData = () => {
  let { dataset, index, headerBGC, rowNum } = status.mergedConfig
  if (index) {
    dataset = dataset.map((row: any, i: number) => {
      row = [...row]
      const indexTag = `<span class="index" style="background-color: ${headerBGC};border-radius: 3px;padding: 0px 3px;">${
        i + 1
      }</span>`
      row.unshift(indexTag)
      return row
    })
  }
  dataset = dataset.map((ceils: any, i: number) => ({ ceils, rowIndex: i }))
  const rowLength = dataset.length
  if (rowLength > rowNum && rowLength < 2 * rowNum) {
    dataset = [...dataset, ...dataset]
  }
  dataset = dataset.map((d: any, i: number) => ({ ...d, scroll: i }))

  status.rowsData = dataset
  status.rows = dataset
}

const calcWidths = () => {
  const { mergedConfig, rowsData } = status
  const { columnWidth, header } = mergedConfig
  const usedWidth = columnWidth.reduce((all: any, ws: number) => all + ws, 0)
  let columnNum = 0
  if (rowsData[0]) {
    columnNum = (rowsData[0] as any).ceils.length
  } else if (header.length) {
    columnNum = header.length
  }
  const minColumnWidth = 100 // 设置一个最小列宽
  const totalMinWidth = columnNum * minColumnWidth
  const avgWidth = (w.value - usedWidth - (totalMinWidth - usedWidth)) / (columnNum - columnWidth.length)
  const widths = new Array(columnNum).fill(minColumnWidth)
  for (let i = 0; i < columnWidth.length; i++) {
    widths[i] = columnWidth[i]
  }
  status.widths = merge(widths, columnWidth)
}

const calcHeights = (onresize = false) => {
  const { mergedConfig, header } = status
  const { headerHeight, rowNum, dataset } = mergedConfig
  let allHeight = h.value
  if (header.length) allHeight -= headerHeight
  const avgHeight = allHeight / rowNum
  status.avgHeight = avgHeight
  if (!onresize) status.heights = new Array(dataset.length).fill(avgHeight)
}

const calcAligns = () => {
  const { header, mergedConfig } = status

  const columnNum = header.length

  let aligns = new Array(columnNum).fill('left')

  const { align } = mergedConfig

  status.aligns = merge(aligns, align)
}

const animation = async (start = false) => {
  const { needCalc } = status

  if (needCalc) {
    calcRowsData()
    calcWidths()
    status.needCalc = false
  }
  let { avgHeight, animationIndex, mergedConfig, rowsData, updater } = status
  const { waitTime, carousel, rowNum } = mergedConfig

  const rowLength = rowsData.length
  if (rowNum >= rowLength) return
  if (start) {
    await new Promise(resolve => setTimeout(resolve, waitTime * 1000))
    if (updater !== status.updater) return
  }
  const animationNum = carousel === 'single' ? 1 : rowNum
  let rows = rowsData.slice(animationIndex)
  rows.push(...rowsData.slice(0, animationIndex))
  status.rows = rows.slice(0, carousel === 'page' ? rowNum * 2 : rowNum + 1)
  await new Promise(resolve => setTimeout(resolve, 300))
  if (updater !== status.updater) return
  animationIndex += animationNum
  const back = animationIndex - rowLength
  if (back >= 0) animationIndex = back
  status.animationIndex = animationIndex
  status.animationHandler = setTimeout(animation, waitTime * 1000 - 300) as any
}

const stopAnimation = () => {
  status.updater = (status.updater + 1) % 999999
  if (!status.animationHandler) return
  clearTimeout(status.animationHandler)
}

const onRestart = async () => {
  try {
    if (!status.mergedConfig) return
    stopAnimation()
    calcData()
  } catch (error) {
    console.log(error)
  }
}
const handleMouseEnter = () => {
  if (status.mergedConfig.hoverPause) {
    stopAnimation()
  }
}

const handleMouseLeave = () => {
  if (status.mergedConfig.hoverPause) {
    animation(true)
  }
}
watch(
  () => w.value,
  () => {
    onRestart()
  }
)

watch(
  () => h.value,
  () => {
    onRestart()
  }
)

watch(
  () => props.chartConfig.option,
  () => {
    onRestart()
  },
  { deep: true }
)

useChartDataFetch(props.chartConfig, useChartEditStore, (resData: any[]) => {
  props.chartConfig.option.dataset = resData
  onRestart()
})

onUnmounted(() => {
  stopAnimation()
})
</script>
<style lang="scss" scoped>
.dv-scroll-board {
  position: relative;
  width: 100%;
  height: 100%;
  color: #fff;
  overflow-x: auto;
  overflow-y: auto; /* 隐藏 Y 轴滚动条 */
  &::-webkit-scrollbar {
    height: 4px; /* 滚动条的高度 */
    width: 1px; /* 滚动条的宽度 */
   
  }

  &::-webkit-scrollbar-track {
    background: #f1f1f1; /* 滚动条轨道的背景颜色 */
  }

  &::-webkit-scrollbar-thumb {
    background: #455b5e; /* 滚动条滑块的颜色 */
    border-radius: 4px; /* 滑块的圆角 */
  }

  &::-webkit-scrollbar-thumb:hover {
    background: #cf4444; /* 滑块悬停时的颜色 */
  }
  table {
    width: 100%;
    border-collapse: collapse;
    overflow-x: auto;
    white-space: nowrap;

    thead {
      tr {
        th {
          transition: all 0.3s;
          border: 1px solid #ddd;
          padding: 8px;
        }
      }
    }

    tbody {
      tr {
        td {
          transition: all 0.3s;
          border: 1px solid #ddd;
          padding: 8px;
        }
      }
    }
  }
}
</style>