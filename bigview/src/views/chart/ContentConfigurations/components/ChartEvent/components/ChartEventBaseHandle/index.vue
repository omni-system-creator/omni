<template>
  <n-collapse-item title="基础事件配置" name="2">
    <template #header-extra>
      <n-button type="primary" tertiary size="small" @click.stop="showModal = true">
        <template #icon>
          <n-icon>
            <pencil-icon />
          </n-icon>
        </template>
        编辑
      </n-button>
    </template>
    <n-card class="collapse-show-box">
      <!-- 函数体 -->
      <div v-for="eventName in BaseEvent" :key="eventName">
        <p>
          <span class="func-annotate">// {{ EventTypeName[eventName] }}</span>
          <br />
          <span class="func-keyword">async {{ eventName }}</span> (mouseEvent,components,http) {
        </p>
        <p class="go-ml-4">
          <n-code :code="(targetData.events.baseEvent || {})[eventName] || ''" language="typescript"></n-code>
        </p>
        <p>}<span>,</span></p>
      </div>
    </n-card>
  </n-collapse-item>

  <!-- 弹窗 -->
  <n-modal class="go-chart-data-monaco-editor" v-model:show="showModal" :mask-closable="false" z-index="10">
    <n-card :bordered="false" role="dialog" size="small" aria-modal="true" style="width: 90%; height: 700px">
      <template #header>
        <n-space>
          <n-text>基础事件编辑器</n-text>
        </n-space>
      </template>

      <template #header-extra> </template>
      <n-layout has-sider sider-placement="right">
        <n-layout style="height: 580px; padding-right: 20px">
          <n-tabs v-model:value="editTab" type="card" tab-style="min-width: 100px;">
            <!-- 提示 -->
            <template #suffix>
              <n-text class="tab-tip" type="warning">提示: ECharts 组件会拦截鼠标事件</n-text>
            </template>
            <n-tab-pane
              v-for="(eventName, index) in BaseEvent"
              :key="index"
              :tab="`${EventTypeName[eventName]}-${eventName}`"
              :name="eventName"
            >
              <!-- 函数名称 -->
              <p class="go-pl-3">
                <span class="func-keyword">async function &nbsp;&nbsp;</span>
                <span class="func-keyNameWord">{{ eventName }}(mouseEvent,components,http)&nbsp;&nbsp;{</span>
              </p>
              <!-- 编辑主体 -->
              <monaco-editor
                v-model:modelValue="baseEvent[eventName]"
                height="480px"
                language="javascript"
                ref="monacoEditorRef"
              />
              <!-- 函数结束 -->
              <p class="go-pl-3 func-keyNameWord">}</p>
            </n-tab-pane>
          </n-tabs>
        </n-layout>
        <n-layout-sider
          :collapsed="collapsed"
          :collapsed-width="14"
          :width="440"
          show-trigger="bar"
          collapse-mode="transform"
          content-style="padding: 12px 12px 0px 12px;margin-left: 3px;"
          @collapse="collapsed = true"
          @expand="collapsed = false"
        >
          <n-tabs default-value="1" justify-content="space-evenly" type="segment">
            <!-- 验证结果 -->
            <n-tab-pane tab="验证结果" name="1" size="small">
              <n-scrollbar trigger="none" style="max-height: 505px">
                <n-collapse class="go-px-3" arrow-placement="right" :default-expanded-names="[1, 2, 3]">
                  <template v-for="error in [validEvents()]" :key="error">
                    <n-collapse-item title="错误函数" :name="1">
                      <n-text depth="3">{{ error.errorFn || '暂无' }}</n-text>
                    </n-collapse-item>
                    <n-collapse-item title="错误信息" :name="2">
                      <n-text depth="3">{{ error.name || '暂无' }}</n-text>
                    </n-collapse-item>
                    <n-collapse-item title="堆栈信息" :name="3">
                      <n-text depth="3">{{ error.message || '暂无' }}</n-text>
                    </n-collapse-item>
                  </template>
                </n-collapse>
              </n-scrollbar>
            </n-tab-pane>
            <!-- 辅助说明 -->
            <n-tab-pane tab="自动编程" name="2">
              <n-scrollbar trigger="none" style="max-height: 505px">
                <n-collapse
                  class="go-px-3"
                  arrow-placement="right"
                  :trigger-areas="triggerAreasRef"
                  :default-expanded-names="[1]"
                >
                  <n-collapse-item title="内部变量" :name="1">
                    <template #header-extra>
                      <n-button size="small" type="primary" @click.stop="addVariable">添加变量</n-button>
                      <n-button size="small" type="primary" @click.stop="handle1" style="margin-left: 12px;">
                        插入编辑器
                      </n-button>
                    </template>
                    <n-input v-model:value="newVariable" placeholder="输入变量名" style="margin-bottom: 8px" />
                    <div style="display: flex; flex-wrap: wrap">
                      <div v-for="(variable, index) in optionsVar" :key="index" class="variable-item">
                        <span>{{ variable.label }}</span>
                        <n-button size="small" type="error" @click.stop="removeVariable(index)">删除</n-button>
                      </div>
                    </div>
                  </n-collapse-item>
                  <n-collapse-item title="组件赋值" :name="2">
                    <template #header-extra>
                      <n-button size="small" type="error" dashed style="margin-right: 12px" @click.stop="handleClear2">
                        清空
                      </n-button>
                      <n-button size="small" type="primary" :disabled="!canInsert" @click.stop="handle2">
                        插入编辑器
                      </n-button>
                    </template>
                    <n-select
                      v-model:value="valueComponent"
                      :options="options"
                      :render-label="renderLabel"
                      :render-tag="renderSingleSelectTag"
                      filterable
                    />
                    <n-popselect v-model:value="propOperate" :options="optionsProps" trigger="click">
                      <n-button>{{ propOperate || '选择属性' }}</n-button>
                    </n-popselect>
                    =
                    <n-popselect v-model:value="valueOperate" :options="optionsOperate" trigger="click">
                      <n-button>{{ valueOperate || '弹出选择' }}</n-button>
                    </n-popselect>
                    <n-popselect
                      v-if="valueOperate === 'set'"
                      v-model:value="varOperate"
                      :options="optionsVar"
                      trigger="click"
                    >
                      <n-button>{{ varOperate || '选择变量' }}</n-button>
                    </n-popselect>
                  </n-collapse-item>
                  <n-collapse-item title="变量赋值" :name="3">
                    <template #header-extra>
                      <n-button size="small" type="error" dashed style="margin-right: 12px" @click.stop="handleClear3"
                        >清空</n-button
                      >
                      <n-button size="small" type="primary" :disabled="!canInsert3" @click.stop="handle3"
                        >插入编辑器</n-button
                      >
                    </template>
                    <n-popselect v-model:value="valueVar" :options="optionsVar" trigger="click">
                      <n-button>{{ valueVar || '选择变量' }}</n-button>
                    </n-popselect>
                    =
                    <n-popselect v-model:value="valueVarOperate" :options="varOptionOperate" trigger="click">
                      <n-button>{{ valueVarOperate || '弹出选择' }}</n-button>
                    </n-popselect>
                    <n-select
                      v-if="valueVarOperate === 'component'"
                      v-model:value="valueVarComponent"
                      :options="options"
                      :render-label="renderLabel"
                      :render-tag="renderSingleSelectTag"
                      filterable
                    />
                    <n-popselect
                      v-if="valueVarOperate === 'api'"
                      v-model:value="valueVarAPI"
                      :options="optionsAPI"
                      trigger="click"
                    >
                      <n-button>{{ valueVarAPI || '选择API' }}</n-button>
                    </n-popselect>
                    <n-input
                      v-if="valueVarOperate === 'manual'"
                      v-model:value="valueVarManual"
                      type="text"
                      placeholder="请输入代码"
                    />
                  </n-collapse-item>
                  <n-collapse-item title="数据映射" :name="4">
                    <template #header-extra>
                      <n-button size="small" type="error" dashed style="margin-right: 12px" @click.stop="handleClear4"
                        >清空</n-button
                      >
                      <n-button size="small" type="primary" @click.stop="handle4">插入编辑器</n-button>
                    </template>
                    <n-popselect v-model:value="valueAdvVar" :options="optionsVar" trigger="click">
                      <n-button>{{ valueAdvVar || '选择变量' }}</n-button>
                    </n-popselect>.
                    <n-input v-model:value="varAdvVarChild" type="text" placeholder="选择变量,如 x" />
                    =
                    <n-popselect v-model:value="valueAdvVarFrom" :options="optionsVar" trigger="click">
                      <n-button>{{ valueAdvVarFrom || '选择数据集合' }}</n-button>
                    </n-popselect>.
                    <n-input v-model:value="valueAdvVarRight" type="text" placeholder="选择数据集合,如 y" />
                    <div style="margin:10px 0 ;">
                  </div>

                    <!-- <div style="margin:10px 0 ;">
                    
                  </div>  -->
                    <n-input
                      v-if="varAdvOperate === 'map'"
                      v-model:value="varAdvOperateManualMap"
                      type="textarea"
                      placeholder="直接编写要映射的内容，比如{label:item.label, value:item.key}"
                    />
                    <div style="display: flex;">
                    <n-popselect v-model:value="varAdvOperate" :options="varOptionAdvOperate" trigger="click">
                      <n-button>{{ varAdvOperate || '弹出选择' }}</n-button>
                    </n-popselect>
                    <n-space v-if="varAdvOperate === 'find'" style="margin-left: 20px;">
                      <n-input v-model:value="varAdvOperateManualFind" type="text" placeholder="数据集的项, 比如key" />
                      = mouseEvent
                    </n-space>
                  </div>
                  </n-collapse-item>
                </n-collapse>
              </n-scrollbar>
            </n-tab-pane>
            <n-tab-pane tab="变量说明" name="3">
              <n-scrollbar trigger="none" style="max-height: 505px">
                <n-collapse class="go-px-3" arrow-placement="right" :default-expanded-names="[1, 2]">
                  <n-collapse-item title="mouseEvent" :name="1">
                    <n-text depth="3">鼠标事件对象</n-text>
                  </n-collapse-item>
                </n-collapse>
              </n-scrollbar>
            </n-tab-pane>
          </n-tabs>
        </n-layout-sider>
      </n-layout>

      <template #action>
        <n-space justify="space-between">
          <div class="go-flex-items-center">
            <n-tag :bordered="false" type="primary">
              <template #icon>
                <n-icon :component="DocumentTextIcon" />
              </template>
              说明
            </n-tag>
            <n-text class="go-ml-2" depth="2">编写方式同正常 JavaScript 写法</n-text>
          </div>

          <n-space>
            <n-button size="small" style="margin-left: 20px" type="primary" @click.stop="handleopenFormula"
              >自动生成代码</n-button
            >
            <n-button size="medium" @click="closeEvents">取消</n-button>
            <n-button size="medium" type="primary" @click="saveEvents">保存</n-button>
          </n-space>
        </n-space>
      </template>
    </n-card>
  </n-modal>

  <!-- 弹窗 -->
  <n-modal class="go-chart-data-monaco-editor" v-model:show="showFormula" :mask-closable="false">
    <n-card
      :bordered="false"
      role="dialog"
      size="small"
      aria-modal="true"
      :style="{ width: modalWidth + 'px', height: modalHeight + 'px' }"
      class="go-chart-data-monaco-editor"
    >
      <div class="draggable-header" ref="draggableHeader">
        <!-- 添加一个可拖拽的区域 -->
        <span v-show="modalWidth > 500">可拖拽的区域</span>
      </div>
      <lowflowDesign></lowflowDesign>
      <template #footer>
        <n-space justify="space-between">
          <div class="go-flex-items-center"></div>
          <n-space>
            <n-button size="medium" @click="closeshowFormula">取消</n-button>
            <n-button size="medium" type="primary" @click="saveshowFormula">保存</n-button>
          </n-space>
        </n-space>
      </template>
    </n-card>
  </n-modal>
</template>

<script setup lang="ts">
import { useChartEditStore } from '@/store/modules/chartEditStore/chartEditStore'
import { ref, watch, onMounted, computed, h, nextTick } from 'vue'
import type { SelectRenderLabel, SelectRenderTag } from 'naive-ui'
import { NAvatar, NTag, NText } from 'naive-ui'
import { MonacoEditor } from '@/components/Pages/MonacoEditor'
import { useTargetData } from '../../../hooks/useTargetData.hook'
import { CreateComponentType, CreateComponentGroupType } from '@/packages/index.d'
import { BaseEvent } from '@/enums/eventEnum'
import { icon } from '@/plugins'
import cloneDeep from 'lodash/cloneDeep'
import { fetchImages } from '@/packages'
import lowflowDesign from '@/components/lowflowDesign/lowflowDesign/index.vue'
import interact from 'interactjs'
import { useMonacoEditor } from '@/components/Pages/MonacoEditor/index.hook'

const { el, updateVal, getEditor, createEditor } = useMonacoEditor()
const modalWidth = ref(1200)
const modalHeight = ref(700)
const draggableHeader = ref(null)
const monacoEditorRef: any = ref(null)
//变量列表
const optionsVar = ref<{ value: string; label: string }[]>([
  { value: 'x', label: 'x' },
  { value: 'y', label: 'y' },
  { value: 'z', label: 'z' }
])
const variables = ref<string[]>(['x', 'y', 'z'])
const newVariable = ref('')
//添加删除变量逻辑
const addVariable = () => {
  const variableName = newVariable.value.trim()

  // 定义变量命名规则的正则表达式
  const variableNameRegex = /^[a-zA-Z_$][a-zA-Z0-9_$]*$/

  if (variableName !== '' && variableNameRegex.test(variableName)) {
    optionsVar.value.push({ value: variableName, label: variableName })
    newVariable.value = '' // 清空输入框
  } else if (variableName === '') {
    window['$message'].warning('变量名不能为空')
  } else {
    window['$message'].error('变量名不符合命名规则，请重新输入')
  }
}

const removeVariable = (index: number) => {
  optionsVar.value.splice(index, 1)
}
onMounted(() => {
  interact('.go-chart-data-monaco-editor')
    .draggable({
      allowFrom: '.draggable-header',
      listeners: {
        move: event => {
          const target = event.target
          const x = (parseFloat(target.getAttribute('data-x')) || 0) + event.dx
          const y = (parseFloat(target.getAttribute('data-y')) || 0) + event.dy

          target.style.transform = `translate(${x}px, ${y}px)`
          target.setAttribute('data-x', x)
          target.setAttribute('data-y', y)
        }
      }
    })
    .resizable({
      edges: { bottom: true, right: true, left: true },
      listeners: {
        move: event => {
          const target = event.target
          // 更新宽度和高度
          const newWidth = modalWidth.value + event.deltaRect.width
          const newHeight = modalHeight.value + event.deltaRect.height
          if (newWidth <= 500 || newHeight <= 500) {
            return
          }

          modalWidth.value = newWidth
          modalHeight.value = newHeight

          target.style.width = `${newWidth}px`
          target.style.height = `${newHeight}px`
          // 不要在这里更新 transform 和 data-x, data-y
        }
      }
    })
})
const flattenOrganizationTree = (tree: any, parentPath = '', namespace: any[] = []): any[] => {
  let flattenedArray: any = []
  for (const node of tree) {
    let isShow = true
    if (namespace && namespace.length > 0) {
      if (namespace.indexOf(node.namespace) > -1) {
        isShow = false
      }
    }
    const fullPath = parentPath && !isShow ? `${parentPath}.${node.label}` : node.label
    flattenedArray.push({ ...node, label: parentPath == '' ? node.label : fullPath })
    if (node.children && node.children.length > 0) {
      flattenedArray = flattenedArray.concat(flattenOrganizationTree(node.children, fullPath, namespace))
    }
  }
  return flattenedArray
}

const { targetData, chartEditStore } = useTargetData()
const { DocumentTextIcon, ChevronDownIcon, PencilIcon } = icon.ionicons5

const EventTypeName = {
  [BaseEvent.ON_CLICK]: '单击',
  [BaseEvent.ON_DBL_CLICK]: '双击',
  [BaseEvent.ON_CHANGE]: '改变',
  [BaseEvent.ON_MOUSE_ENTER]: '鼠标进入',
  [BaseEvent.ON_MOUSE_LEAVE]: '鼠标移出'
}
const valueComponent = ref(null)
const valueVarComponent = ref(null)
const valueOperate = ref('')
const propOperate = ref('')
const propVarOperate = ref('')
const varOperate = ref('')
const valueVar = ref('')
const valueAdvVar = ref('')
const valueAdvVarRight = ref('')
const varAdvVarChild = ref('')
const valueAdvVarFrom = ref('')
const valueVarOperate = ref('')
const varAdvOperate = ref('')
const varAdvOperateManualMap = ref('')
const varAdvOperateManualFind = ref('')
const valueVarAPI = ref('')
const valueVarManual = ref('')
const triggerAreasRef = ref(['main', 'arrow'])
const options = computed(() => {
  const list: Array<CreateComponentType | CreateComponentGroupType> = cloneDeep(chartEditStore.getComponentList)
  return list.reverse().map(item => {
    return { ...item, value: item.id, label: item.chartConfig.title }
  })
})

const optionsProps = [
  {
    label: '数据集',
    value: 'dataset'
  },
  {
    label: '内容',
    value: 'selectValue'
  }
]
const optionsOperate = [
  {
    label: '清空',
    value: 'clear'
  },
  {
    label: '隐藏',
    value: 'hide'
  },
  {
    label: '显示',
    value: 'show'
  },
  {
    label: '赋值',
    value: 'set'
  }
]
const optionsAPI = [
  {
    label: '我是API',
    value: 'api'
  }
]
const varOptionOperate = [
  {
    label: '来自控件',
    value: 'component'
  },
  {
    label: '来自API',
    value: 'api'
  },
  {
    label: '来自mouseEvent',
    value: 'mouseEvent'
  },
  {
    label: '手动输入',
    value: 'manual'
  }
]
const varOptionAdvOperate = [
  {
    label: '查找',
    value: 'find'
  },
  {
    label: '映射',
    value: 'map'
  }
]
// 受控弹窗
const showModal = ref(false)
const showFormula = ref(false)
// 编辑区域控制
const editTab = ref(BaseEvent.ON_CLICK)
// events 函数模板
let baseEvent = ref({ ...targetData.value.events.baseEvent })
// 事件错误标识
const errorFlag = ref(false)

const collapsed = ref(false)
const leftCollapsed = ref(false)

// 验证语法
const validEvents = () => {
  let errorFn = ''
  let message = ''
  let name = ''

  errorFlag.value = Object.entries(baseEvent.value).every(([eventName, str]) => {
    try {
      // 支持await，验证语法
      const AsyncFunction = Object.getPrototypeOf(async function () {}).constructor
      new AsyncFunction(str)
      return true
    } catch (error: any) {
      message = error.message
      name = error.name
      errorFn = eventName
      return false
    }
  })
  return {
    errorFn,
    message,
    name
  }
}

// 关闭事件
const closeEvents = () => {
  showModal.value = false
}
const handleopenFormula = () => {
  showFormula.value = true

  // nextTick(() => {
  //       codeEditorRef.value.setEditorValue((InputFormulaOptions.editorOptions as any)['docs']);
  //       console.log(codeEditorRef);
  //     });
}
const closeshowFormula = () => {
  showFormula.value = false
}
const saveshowFormula = () => {
  showFormula.value = false
}
// 新增事件
const saveEvents = () => {
  if (validEvents().errorFn) {
    window['$message'].error('事件函数错误，无法进行保存')
    return
  }
  if (Object.values(baseEvent.value).join('').trim() === '') {
    // 清空事件
    targetData.value.events.baseEvent = {
      [BaseEvent.ON_CLICK]: undefined,
      [BaseEvent.ON_DBL_CLICK]: undefined,
      [BaseEvent.ON_CHANGE]: undefined,
      [BaseEvent.ON_MOUSE_ENTER]: undefined,
      [BaseEvent.ON_MOUSE_LEAVE]: undefined
    }
  } else {
    targetData.value.events.baseEvent = { ...baseEvent.value }
  }
  closeEvents()
}
// const getImgSrc = (name:String) => {
//   return require(`@/assets/images/chart/charts/${name}`)
// }

// 获取图片
const imageInfo = ref('')
const fetchImageUrl = async (chartConfig: any) => {
  imageInfo.value = await fetchImages(chartConfig)
  return imageInfo.value
}
// fetchImageUrl()
const getImgSrc = (chartConfig: any) => {
  return `/src/assets/images/chart/${chartConfig.package.toLowerCase()}/${chartConfig.image}`
}
const renderSingleSelectTag: SelectRenderTag = ({ option }) => {
  fetchImageUrl(option.chartConfig)
  return h(
    'div',
    {
      style: {
        display: 'flex',
        alignItems: 'center'
      }
    },
    [
      h(NAvatar, {
        src: imageInfo.value,
        round: false,
        size: 32,
        style: {
          marginRight: '12px'
        }
      }),
      (option as any).chartConfig.title as string
    ]
  )
}
const renderLabel: SelectRenderLabel = option => {
  return h(
    'div',
    {
      style: {
        display: 'flex',
        alignItems: 'center'
      }
    },
    [
      h(NAvatar, {
        src: getImgSrc((option as any).chartConfig),
        round: false,
        size: 'small'
      }),
      h(
        'div',
        {
          style: {
            marginLeft: '12px',
            padding: '4px 0'
          }
        },
        [
          h('div', null, [(option as any).chartConfig.title as string]),
          h(
            NText,
            { depth: 3, tag: 'div' },
            {
              default: () => `id: ${option.id}${(option as any).status.hide ? '  【隐藏】' : ''}`
            }
          )
        ]
      )
    ]
  )
}

const insertNewLine = async (content: String) => {
  const userList = chartEditStore.getComponentList
  updateVal('const userList = chartEditStore.getComponentList')
  console.log(userList)
  if (monacoEditorRef.value) {
    const code = monacoEditorRef.value[0]
    await nextTick() // 确保 DOM 更新完成
    code.insertCode(content)
  }
}

// const chartEditStore = useChartEditStore()
const handle1 = async () => {
  await insertNewLine(`var ${optionsVar.value.map(item=>{return item.value}).join(",")};`)
}
const handleClear2 = () => {
  valueComponent.value = null
  propOperate.value = ''
  valueOperate.value = ''
}
//
const canInsert = computed(() => {
  if (valueOperate.value === 'set') {
    return (
      valueComponent.value !== null && propOperate.value !== '' && varOperate.value !== ''
    )
  } else {
    return valueComponent.value !== null && propOperate.value !== '' && valueOperate.value !== ''
  }
})
const handle2 = async () => {
  let left = ''
  let right = ''
  if (valueOperate.value === 'show' || valueOperate.value === 'hide') {
    left = `components.${valueComponent.value}.props.chartConfig.status.hide`
    right = valueOperate.value === 'show' ? 'false' : 'true'
  } else if (valueOperate.value === 'clear') {
    left = `components.${valueComponent.value}.props.chartConfig.option.${propOperate.value}`
    right = propOperate.value === 'dataset' ? '[]' : 'null'
  } else if (valueOperate.value === 'set') {
    left = `components.${valueComponent.value}.props.chartConfig.option.${propOperate.value}`
    right = varOperate.value
  }
  await insertNewLine(`${left} = ${right}`)
  handleClear2()
}
const handleClear3 = () => {
  valueVar.value = ''
  valueVarOperate.value = ''
}
const handle3 = async () => {
  let right = ''
  // TODO: 还差API
  if (valueVarOperate.value === 'component') {
    right = `components.${valueVarComponent.value}.props.chartConfig.option.dataset`
  } else if (valueVarOperate.value === 'manual') {
    right = valueVarManual.value ?? ''
  } else if (valueVarOperate.value === 'mouseEvent'){
    right = 'mouseEvent'
  }
  await insertNewLine(`${valueVar.value} = ${right}`)
  handleClear3()
}
const canInsert3 = computed(() => {
  if (valueVar.value === '') {
    return false
  }
  if (valueVarOperate.value === '') {
    return false
  }
  if (valueVarOperate.value === 'component' && valueVarComponent.value === null) {
    return false
  }
  if (valueVarOperate.value === 'api' && valueVarAPI.value === '') {
    return false
  }
  if (valueVarOperate.value === 'manual' && valueVarManual.value === '') {
    return false
  }
  return true
})
const handleClear4 = () => {
  valueAdvVar.value = ''
  varAdvVarChild.value = ''
  valueAdvVarFrom.value = ''
  valueAdvVarRight.value = ''
  varAdvOperate.value = ''
  varAdvOperateManualMap.value = ''
  varAdvOperateManualFind.value = ''
}

const handle4 = async () => {
  let left = valueAdvVar.value
  if (varAdvVarChild.value) {
    left = left + (varAdvVarChild.value.startsWith('.') ? varAdvVarChild.value : '.' + varAdvVarChild.value)
  }
  let right = valueAdvVarFrom.value
  if (valueAdvVarRight.value) {
    right = right + (valueAdvVarRight.value.startsWith('.') ? valueAdvVarRight.value : '.' + valueAdvVarRight.value)
  }
  if (varAdvOperate.value === 'find') {
    right = right + `.find((item) => item.${varAdvOperateManualFind.value} === mouseEvent);`
  } else if (varAdvOperate.value === 'map') {
    right = right + `.map((item) => { return ${varAdvOperateManualMap.value} });`
  }
  await insertNewLine(`${left} = ${right}`)
  handleClear4()
}
watch(
  () => showModal.value,
  (newData: boolean) => {
    if (newData) {
      baseEvent.value = { ...targetData.value.events.baseEvent }
    }
  }
)
</script>

<style lang="scss" scoped>
@use '../index.scss';

:deep(.n-layout-sider-scroll-container) {
  overflow: none;
}

.draggable-header {
  cursor: move;
  padding: 10px;
  height: 3rem;
  border-bottom: 1px solid #ccc;
  backdrop-filter: rgb(35, 35, 35);
  display: flex; /* 使用 Flexbox 布局 */
  // justify-content: center; /* 水平居中 */
  align-items: center; /* 垂直居中 */
  span {
    font-size: 1rem;
  }
}
.go-chart-data-monaco-editor {
  overflow-y: auto; /* 超出内容时显示垂直滚动条 */
}
.variable-item {
  display: flex;
  align-items: center;
  margin-bottom: 8px;
  width: 80px;
  margin: 10px 20px;
}
.variable-item span {
  margin-right: 8px;
  width: 50px;
}
</style>
