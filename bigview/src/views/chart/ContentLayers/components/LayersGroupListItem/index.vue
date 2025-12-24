<template>
  <div class="go-content-layers-group-list-item">
    <div
      class="root-item-content"
      :class="{ hover, select, 'list-mini': selectText }"
      @click="clickHandle($event)"
      @mousedown="groupMousedownHandle($event)"
      @mouseenter="mouseenterHandle(componentGroupData)"
      @mouseleave="mouseleaveHandle(componentGroupData)"
      @contextmenu="handleContextMenu($event, componentGroupData, optionsHandle)"
    >
      <div class="go-flex-items-center item-content">
        <n-icon size="20" class="go-ml-1">
          <template v-if="expend">
            <folder-open-icon></folder-open-icon>
          </template>
          <template v-else>
            <folder-icon></folder-icon>
          </template>
        </n-icon>
        <n-ellipsis style="margin-right: auto">
          <n-text class="go-ml-2 list-text" :depth="2">
            {{ componentGroupData.chartConfig.title }}
          </n-text>
        </n-ellipsis>
        <layers-status :isGroup="false" :hover="hover" :status="status"></layers-status>
      </div>
      <div :class="{ 'select-modal': select }"></div>
    </div>
    <n-collapse-transition :show="expend">
      <!-- https://github.com/SortableJS/vue.draggable.next -->
      <draggable item-key="id" v-model="reverseList"
        :group="{name:'second'}" forceFallback="true"
        ghostClass="ghost" @change="onMoveCallback">
        <template #item="{ element }">
          <div class="go-content-layer-box">
            <LayersListItem
              :componentData="element"
              :layer-mode="layerMode"
              @mousedown="mousedownHandle($event, element)"
              @mouseenter="mouseenterHandle(element)"
              @mouseleave="mouseleaveHandle(element)"
              @contextmenu="handleContextMenu($event, element, optionsHandle)"
            ></LayersListItem>
          </div>
        </template>
      </draggable>
    </n-collapse-transition>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, PropType } from 'vue'
import Draggable from 'vuedraggable'
import cloneDeep from 'lodash/cloneDeep'
import { MouseEventButton, WinKeyboard, MacKeyboard } from '@/enums/editPageEnum'
import { MenuEnum } from '@/enums/editPageEnum'
import { useDesignStore } from '@/store/modules/designStore/designStore'
import { useChartEditStore } from '@/store/modules/chartEditStore/chartEditStore'
import { useContextMenu, divider } from '@/views/chart/hooks/useContextMenu.hook'
import { MenuOptionsItemType } from '@/views/chart/hooks/useContextMenu.hook.d'
import { LayerModeEnum } from '@/store/modules/chartLayoutStore/chartLayoutStore.d'
import { CreateComponentType, CreateComponentGroupType } from '@/packages/index.d'
import { LayersListItem } from '../LayersListItem'
import { LayersStatus } from '../LayersStatus/index'
import { icon } from '@/plugins'

const props = defineProps({
  componentGroupData: {
    type: Object as PropType<CreateComponentGroupType>,
    required: true
  },
  layerMode: {
    type: String as PropType<LayerModeEnum>,
    default: LayerModeEnum.THUMBNAIL
  }
})

// 右键
const pickOptionsList = [MenuEnum.UN_GROUP]

// 全局颜色
const designStore = useDesignStore()
const { FolderIcon, FolderOpenIcon } = icon.ionicons5

const chartEditStore = useChartEditStore()
const { handleContextMenu, onClickOutSide } = useContextMenu()

const expend = ref(false)

// 颜色
const themeColor = computed(() => {
  return designStore.getAppTheme
})

// 是否选中文本
const selectText = computed(() => {
  return props.layerMode === LayerModeEnum.TEXT
})

// 计算当前选中目标
const select = computed(() => {
  const id = props.componentGroupData.id
  return chartEditStore.getTargetChart.selectId.find((e: string) => e === id)
})

// 悬浮
const hover = computed(() => {
  return props.componentGroupData.id === chartEditStore.getTargetChart.hoverId
})

// 组件状态 隐藏/锁定
const status = computed(() => {
  return props.componentGroupData.status
})

// 逆序展示
const reverseList = computed(() => {
  const list: Array<CreateComponentType | CreateComponentGroupType> = cloneDeep(props.componentGroupData.groupList)
  return list.reverse()
})

// 移动结束处理
const onMoveCallback = (val: any) => {
  const { oldIndex, newIndex } = val.moved
  if (newIndex - oldIndex > 0) {
    // 从上往下
    const moveTarget = props.componentGroupData.groupList.splice(-(oldIndex + 1), 1)[0]
    props.componentGroupData.groupList.splice(-newIndex, 0, moveTarget)
  } else {
    // 从下往上
    const moveTarget = props.componentGroupData.groupList.splice(-(oldIndex + 1), 1)[0]
    if (newIndex === 0) {
      props.componentGroupData.groupList.push(moveTarget)
    } else {
      props.componentGroupData.groupList.splice(-newIndex, 0, moveTarget)
    }
  }
}
// 右键
const optionsHandle = (
  targetList: MenuOptionsItemType[],
  allList: MenuOptionsItemType[],
  targetInstance: CreateComponentType
) => {

  const filter = (menulist: MenuEnum[]) => {
    return allList.filter(i => menulist.includes(i.key as MenuEnum))
  }

  // 多选处理
  if (chartEditStore.getTargetChart.selectId.length > 1) {
    return filter([MenuEnum.GROUP])
  } else {
    const statusMenuEnums: MenuEnum[] = []
    if (targetInstance.status.lock) {
      statusMenuEnums.push(MenuEnum.LOCK)
    } else {
      statusMenuEnums.push(MenuEnum.UNLOCK)
    }
    if (targetInstance.status.hide) {
      statusMenuEnums.push(MenuEnum.HIDE)
    } else {
      statusMenuEnums.push(MenuEnum.SHOW)
    }
    if(targetInstance.isGroup) {
      return [
        ...filter([MenuEnum.UN_GROUP]),
        divider(),
        ...targetList.filter(i => !statusMenuEnums.includes(i.key as MenuEnum))
      ]
    }
    else {
      return [
        ...targetList.filter(i => !statusMenuEnums.includes(i.key as MenuEnum))
      ]
    }
  }
}

// 点击
const clickHandle = (e: MouseEvent) => {
  // 按下左键 + CTRL
  if (window.$KeyboardActive?.ctrl) return
  // 判断左右键
  expend.value = !expend.value
  mousedownHandle(e, props.componentGroupData)
}

// 组点击事件
const groupMousedownHandle = (e: MouseEvent) => {
  onClickOutSide()
  // 若此时按下了 CTRL, 表示多选
  const id = props.componentGroupData.id
  if (e.buttons === MouseEventButton.LEFT && window.$KeyboardActive?.ctrl) {
    // 若已选中，则去除
    if (chartEditStore.targetChart.selectId.includes(id)) {
      const exList = chartEditStore.targetChart.selectId.filter(e => e !== id)
      chartEditStore.setTargetSelectChart(exList)
    } else {
      chartEditStore.setTargetSelectChart(id, true)
    }
    return
  }
  chartEditStore.setTargetSelectChart(id)
}

// 公共点击事件
const mousedownHandle = (
  e: MouseEvent,
  item: CreateComponentType | CreateComponentGroupType
) => {
  e.preventDefault()
  e.stopPropagation()

  onClickOutSide()
  // 若此时按下了 CTRL, 表示多选
  const id = item.id
  if (e.buttons === MouseEventButton.LEFT && window.$KeyboardActive?.ctrl) {
    // 若已选中，则去除
    if (chartEditStore.targetChart.selectId.includes(id)) {
      const exList = chartEditStore.targetChart.selectId.filter(e => e !== id)
      chartEditStore.setTargetSelectChart(exList)
    } else {
      chartEditStore.setTargetSelectChart(id, true)
    }
    return
  }
  chartEditStore.setTargetSelectChart(id)
}

// 公共进入事件
const mouseenterHandle = (componentInstance: CreateComponentType | CreateComponentGroupType) => {
  chartEditStore.setTargetHoverChart(componentInstance.id)
}

// 公共移出事件
const mouseleaveHandle = (componentInstance: CreateComponentType | CreateComponentGroupType) => {
  chartEditStore.setTargetHoverChart(undefined)
}
</script>

<style lang="scss" scoped>
$centerHeight: 52px;
$centerMiniHeight: 28px;
$textSize: 10px;

@include go(content-layers-group-list-item) {
  position: relative;
  width: 90%;
  margin: 10px 5%;
  margin-bottom: 5px;
  @extend .go-transition-quick;
  @include deep() {
    .go-content-layers-list-item {
      margin-right: 0 !important;
      width: 95% !important;
    }
  }

  &:hover > .root-item-content {
    @include deep() {
      .icon-item {
        opacity: 1;
      }
    }
  }

  .ghost {
    opacity: 0;
  }

  .root-item-content {
    height: $centerHeight;
    cursor: pointer;
    border-radius: 5px;
    border: 1px solid rgba(0, 0, 0, 0);
    &.hover,
    &:hover {
      @include fetch-bg-color('background-color4');
    }
    /* 选中 */
    &.select {
      border: 1px solid v-bind('themeColor');
      /* 需要设置最高级，覆盖 hover 的颜色 */
      background-color: rgba(0, 0, 0, 0);
      .list-img {
        border: 1px solid v-bind('themeColor') !important;
      }
    }

    // mini样式
    &.list-mini {
      height: $centerMiniHeight;
      .item-content {
        height: calc(#{$centerMiniHeight} - 10px) !important;
      }
      .select-modal {
        height: calc(#{$centerMiniHeight} + 2px) !important;
      }
    }
  }
  .select-modal,
  .item-content {
    position: absolute;
    top: 0;
    left: 0;
  }
  .item-content {
    z-index: 1;
    padding: 6px 5px;
    justify-content: start !important;
    width: calc(100% - 10px);
    height: calc(#{$centerHeight} - 10px);
  }
  .select-modal {
    width: 100%;
    height: calc(#{$centerHeight} + 2px);
    opacity: 0.3;
    background-color: v-bind('themeColor');
  }
  .list-text {
    padding-left: 6px;
    font-size: $textSize;
  }

  .list-status-icon {
    margin-left: 3px;
  }
}
</style>
