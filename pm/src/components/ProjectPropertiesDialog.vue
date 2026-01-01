<script setup lang="ts">
import { ref, watch } from 'vue'
import { NModal, NCard, NForm, NFormItem, NInput, NDatePicker, NButton, NSpace } from 'naive-ui'
import { useProjectStore } from '../stores/projectStore'
import type { ProjectInfo } from '../types'

const props = defineProps<{
  show: boolean
}>()

const emit = defineEmits<{
  (e: 'update:show', value: boolean): void
}>()

const store = useProjectStore()
const formValue = ref<ProjectInfo>({ ...store.projectInfo })

watch(() => props.show, (val) => {
  if (val) {
    formValue.value = { ...store.projectInfo }
  }
})

const handleSave = () => {
  store.updateProjectInfo(formValue.value)
  emit('update:show', false)
}

const handleCancel = () => {
  emit('update:show', false)
}
</script>

<template>
  <NModal :show="show" @update:show="(val) => emit('update:show', val)">
    <NCard
      style="width: 600px"
      title="项目属性"
      :bordered="false"
      size="huge"
      role="dialog"
      aria-modal="true"
    >
      <NForm :model="formValue" label-placement="left" label-width="100" @keydown.enter.prevent="handleSave">
        <NFormItem label="项目编号" path="code">
          <NInput v-model:value="formValue.code" placeholder="请输入项目编号" autofocus />
        </NFormItem>
        <NFormItem label="项目名称" path="name">
          <NInput v-model:value="formValue.name" placeholder="请输入项目名称" />
        </NFormItem>
        <NFormItem label="项目类型" path="type">
          <NInput v-model:value="formValue.type" placeholder="请输入项目类型" />
        </NFormItem>
        <NFormItem label="项目描述" path="description">
          <NInput v-model:value="formValue.description" type="textarea" placeholder="请输入项目描述" @keydown.enter.stop />
        </NFormItem>
        <NFormItem label="负责人" path="manager">
          <NInput v-model:value="formValue.manager" placeholder="请输入负责人" />
        </NFormItem>
        <NFormItem label="计划开始时间" path="plannedStartDate">
          <NDatePicker v-model:formatted-value="formValue.plannedStartDate" value-format="yyyy-MM-dd" type="date" placeholder="选择开始时间" style="width: 100%" />
        </NFormItem>
        <NFormItem label="计划完成时间" path="plannedEndDate">
           <NDatePicker v-model:formatted-value="formValue.plannedEndDate" value-format="yyyy-MM-dd" type="date" placeholder="选择完成时间" style="width: 100%" />
        </NFormItem>
      </NForm>
      <template #footer>
        <NSpace justify="end">
          <NButton @click="handleCancel">取消</NButton>
          <NButton type="primary" @click="handleSave">保存</NButton>
        </NSpace>
      </template>
    </NCard>
  </NModal>
</template>
