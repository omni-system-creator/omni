<script setup lang="ts">
import Segmented from '../../../components/Segmented'
import { useVModels } from '@vueuse/core'
import { ApprovalNode } from '../nodes/Approval/index'
import { computed, inject, Ref, ref, onMounted } from 'vue'
import { CircleCheck, CircleClose, Switch, Plus, Minus } from '@element-plus/icons-vue'
import { Field } from '../../../components/Render/interface'
import { FormProperty } from '../../flowDesign/index'
import UserSelection from '../../../components/UserSelection'
import { useChartEditStore } from '@/store/modules/chartEditStore/chartEditStore'

const activeName = ref('properties')
const chartEditStore = useChartEditStore()
export interface ApprovalAttr {
  node: ApprovalNode
}

const $props = defineProps<ApprovalAttr>()
const $emits = defineEmits<{
  (e: 'update:node', modelValue: ApprovalNode): void
}>()
const { node } = useVModels($props, $emits)
const { fields } = inject<{
  fields: Ref<Field[]>
}>('nodeHooks')!
// 全部可写
const allWriteable = computed({
  get() {
    return node.value.formProperties.every(e => e.writeable)
  },
  set(val) {
    node.value.formProperties.forEach(e => (e.writeable = val))
    if (val) {
      allReadable.value = false
      allHidden.value = false
    } else {
      allRequired.value = false
    }
  }
})
// 全部必填
const allRequired = computed({
  get() {
    return node.value.formProperties.every(e => e.required)
  },
  set(val) {
    node.value.formProperties.forEach(e => (e.required = val))
    if (val) {
      allWriteable.value = true
      allReadable.value = false
      allHidden.value = false
    }
  }
})
// 全部可读
const allReadable = computed({
  get() {
    return node.value.formProperties.every(e => e.readable)
  },
  set(val) {
    node.value.formProperties.forEach(e => (e.readable = val))
    if (val) {
      allWriteable.value = false
      allHidden.value = false
      allRequired.value = false
    }
  }
})
// 全部隐藏
const allHidden = computed({
  get() {
    return node.value.formProperties.every(e => e.hidden)
  },
  set(val) {
    node.value.formProperties.forEach(e => (e.hidden = val))
    if (val) {
      allWriteable.value = false
      allRequired.value = false
      allReadable.value = false
    }
  }
})
/**
 * 更改可读
 * @param row
 */
const changeReadable = (row: FormProperty) => {
  if (row.readable) {
    row.writeable = false
    row.required = false
    row.hidden = false
  }
}
/**
 * 更改必填
 * @param row
 */
const changeRequired = (row: FormProperty) => {
  if (row.required) {
    row.writeable = true
    row.readable = false
    row.hidden = false
  }
}
/**
 * 更改可写
 * @param row
 */
const changeWriteable = (row: FormProperty) => {
  if (row.writeable) {
    row.readable = false
    row.hidden = false
  } else {
    row.required = false
  }
}
/**
 * 更改隐藏
 * @param row
 */
const changeHidden = (row: FormProperty) => {
  if (row.hidden) {
    row.readable = false
    row.writeable = false
    row.required = false
  }
}
onMounted(() => {
  const formProperties = node.value.formProperties
  node.value.formProperties = fields.value
    .filter(e => e.value !== undefined)
    .map(e => ({
      id: e.id,
      name: e.title,
      readable: e.props.disabled || false,
      writeable: !e.props.disabled || false,
      hidden: e.props.hidden || false,
      required: (e.props.required && !e.props.disabled) || false
    }))
  node.value.formProperties.forEach(item => {
    const properties = formProperties.find(f => f.id === item.id)
    if (properties) {
      item.readable = properties.readable
      item.writeable = properties.writeable
      item.hidden = properties.hidden
      item.required = properties.required
    }
  })
})
</script>

<template>
  <n-tabs v-model:value="activeName" type="line" animated>
    <n-tab-pane name="user" tab="指定组件" v-if="node.assigneeType === 'user'">
      <n-form-item path="users">
        <user-selection multiple placeholder="请选择组件" v-model="node.users" />
      </n-form-item>
    </n-tab-pane>
  </n-tabs>
  <!-- {{chartEditStore.getComponentList}} -->
</template>

<style scoped lang="scss">
.flex-column {
  display: flex !important;
  align-items: flex-start !important;
  flex-direction: column !important;
}

.flow-opt-item {
  display: flex;
  align-items: center;

  .flow-opt-item__icon {
    background: var(--el-color-primary);
    color: #fff;
    border-radius: 7px;
    padding: 3px;
  }

  .flow-opt-item__content {
    box-sizing: border-box;
    flex: 1;
    margin-left: 20px;
    font-size: 14px;

    .flow-opt-item__second {
      margin-top: 3px;
      font-size: 12px;
      color: var(--el-text-color-placeholder);
    }
  }
}
</style>
