<template>
  <Modal
      :open="props.open"
      centered
      :width="`${props.width}px`"
      :ok-text="props.okText"
      :cancel-text="props.cancelText"
      @cancel="handleCancel"
      @ok="handleOk">
    <template #title>
      <h4>{{ props.title }} <a-typography-text type="secondary" v-if="props.childTitle">{{props.childTitle}}</a-typography-text></h4>
    </template>
    <slot></slot>
  </Modal>
</template>

<script lang="ts" setup>
import {defineProps, defineEmits} from "vue";
import {Modal} from "ant-design-vue";

const emit = defineEmits(['handleOk', 'handleCancel'])
const props = defineProps({
  open: {
    type: Boolean,
    default: false,
  },
  width: {
    type: String,
    default: "1200",
  },
  title: {
    type: String,
    default: "",
  },
  childTitle:{
    type: String,
    default:""
  },
  okText: {
    type: String,
    default: "确定",
  },
  cancelText: {
    type: String,
    default: "取消",
  },
});
const handleOk = (e: MouseEvent) => {
  emit('handleOk', e);
};
const handleCancel = (e: MouseEvent) => {
  emit('handleCancel', e);
};
</script>
