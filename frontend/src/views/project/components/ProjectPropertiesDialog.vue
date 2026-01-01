<script setup lang="ts">
import { ref, watch } from 'vue';
import { useProjectFlowStore } from '@/stores/projectFlowStore';
import type { ProjectInfo } from '@/types/project';

const props = defineProps<{
  open: boolean
}>();

const emit = defineEmits<{
  (e: 'update:open', value: boolean): void
}>();

const store = useProjectFlowStore();
const formValue = ref<ProjectInfo>({ ...store.projectInfo });

watch(() => props.open, (val) => {
  if (val) {
    formValue.value = { ...store.projectInfo };
  }
});

const handleSave = () => {
  store.updateProjectInfo(formValue.value);
  emit('update:open', false);
};

const handleCancel = () => {
  emit('update:open', false);
};
</script>

<template>
  <a-modal
    :open="open"
    title="项目属性"
    width="600px"
    @update:open="(val: boolean) => emit('update:open', val)"
    @ok="handleSave"
    @cancel="handleCancel"
  >
    <a-form :model="formValue" :label-col="{ span: 4 }" :wrapper-col="{ span: 20 }">
      <a-form-item label="项目编号" name="code">
        <a-input v-model:value="formValue.code" placeholder="请输入项目编号" autofocus />
      </a-form-item>
      <a-form-item label="项目名称" name="name">
        <a-input v-model:value="formValue.name" placeholder="请输入项目名称" />
      </a-form-item>
      <a-form-item label="项目类型" name="type">
        <a-input v-model:value="formValue.type" placeholder="请输入项目类型" />
      </a-form-item>
      <a-form-item label="项目描述" name="description">
        <a-textarea v-model:value="formValue.description" placeholder="请输入项目描述" :rows="4" />
      </a-form-item>
      <a-form-item label="负责人" name="manager">
        <a-input v-model:value="formValue.manager" placeholder="请输入负责人" />
      </a-form-item>
      <a-form-item label="计划开始" name="plannedStartDate">
        <a-date-picker v-model:value="formValue.plannedStartDate" value-format="YYYY-MM-DD" style="width: 100%" />
      </a-form-item>
      <a-form-item label="计划完成" name="plannedEndDate">
        <a-date-picker v-model:value="formValue.plannedEndDate" value-format="YYYY-MM-DD" style="width: 100%" />
      </a-form-item>
    </a-form>
  </a-modal>
</template>
