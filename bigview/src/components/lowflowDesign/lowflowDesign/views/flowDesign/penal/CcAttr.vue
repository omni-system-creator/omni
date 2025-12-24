<script setup lang="ts">
import { NSpace, NSelect } from 'naive-ui';
import { useVModels } from '@vueuse/core';
import { CcNode } from '../nodes/Cc/index';
import { computed, inject, Ref, ref, onMounted } from 'vue';
import { Field } from '../../../components/Render/interface';
import { useChartEditStore } from '@/store/modules/chartEditStore/chartEditStore'


const chartEditStore = useChartEditStore()
const activeName = ref('properties');

export interface ApprovalAttr {
  node: CcNode;
}
//组件值
const componentValue = ref('');
//数据源
const dataSource = ref('');
const componentSource = ref('');
const componentOptions = chartEditStore.getComponentList.map(e =>{
  return {
    value: e.id,
    label: e.chartConfig.title
  }
})
const dataSourceOptions = [
  {
    value: 'component',
    label: '其他组件'
  },
  {
    value: 'api',
    label: 'API'
  },
  {
    value: 'static',
    label: '静态数据'
  }
]

const $props = defineProps<ApprovalAttr>();
const $emits = defineEmits<{
  (e: 'update:node', modelValue: CcNode): void;
}>();

const { node } = useVModels($props, $emits);
const { fields } = inject<{
  fields: Ref<Field[]>;
}>('nodeHooks')!;

const allReadable = computed({
  get() {
    return node.value.formProperties.every(e => e.readable);
  },
  set(val) {
    node.value.formProperties.forEach(e => (e.readable = val));
    allHidden.value = !val;
  },
});

const allHidden = computed({
  get() {
    return node.value.formProperties.every(e => e.hidden);
  },
  set(val) {
    node.value.formProperties.forEach(e => (e.hidden = val));
    allReadable.value = !val;
  },
});

onMounted(() => {
  const formProperties = node.value.formProperties;
  node.value.formProperties = fields.value
    .filter(e => e.value !== undefined)
    .map(e => ({
      id: e.id,
      name: e.title,
      readable: true,
      writeable: false,
      required: false,
      hidden: e.props.hidden || false,
    }));

  node.value.formProperties.forEach(item => {
    const properties = formProperties.find(f => f.id === item.id);
    if (properties) {
      item.readable = properties.readable;
      item.writeable = properties.writeable;
      item.hidden = properties.hidden;
      item.required = properties.required;
    }
  });
});
const handleConfirm = () => {
  // 处理确认逻辑
  console.log('确认');
};

const handleCancel = () => {
  // 处理取消逻辑
  console.log('取消');
};
</script>

<template>
  <div class="container">
  <div class="box-card">
  <n-text>选择组件:</n-text>
  <div>
    <el-select
      v-model="componentValue"
      placeholder="Select"
      effect="dark"
      size="default"  
      style="width: 240px"
    >
      <el-option
        v-for="item in componentOptions"
        :key="item.value"
        :label="item.label"
        :value="item.value"
      />
    </el-select></div>

  </div>
    <div class="box-card">
    <n-text>选择数据来源:</n-text>
    <div>
      <el-select
      v-model="dataSource"
      placeholder="Select"
      effect="dark"
      size="default"  
      style="width: 240px"
    >
      <el-option
        v-for="item in dataSourceOptions"
        :key="item.value"
        :label="item.label"
        :value="item.value"
      />
    </el-select>
    </div>
    
  </div>
  <div class="box-card" v-if="dataSource === 'component'">
    <n-text>选择数据来源组件:</n-text>
    <div>
      <n-list hoverable clickable>
    <n-list-item v-for="item in componentOptions" :key="item.value">
      <n-list-item-meta>
        <n-text>{{ item.label }}</n-text>
      </n-list-item-meta>
    </n-list-item>
  </n-list>
    </div>
  </div>
  <div class="box-card" v-if="dataSource === 'api'">
    <n-text>选择API:</n-text>
    <div>
      <n-list hoverable clickable>
    <n-list-item v-for="item in 5" :key="item" >
      <n-list-item-meta>
        <n-text>{{ item }}</n-text>
      </n-list-item-meta>
    </n-list-item>
  </n-list>
    </div>
    
  </div>
  <div class="box-card" v-if="dataSource === 'static'">
    <n-upload
    action="https://www.mocky.io/v2/5e4bafc63100007100d8b70f"
    :headers="{
      'naive-info': 'hello!',
    }"
    :data="{
      'naive-data': 'cool! naive!',
    }"
  >
    <n-button>上传JSON文件</n-button>
  </n-upload>
  </div>
  <!-- <div class="button-container">
    <n-button @click="handleCancel">取消</n-button>
    <n-button type="primary" @click="handleConfirm">确定</n-button>
  </div> -->
  </div>
</template>

<style scoped lang="scss">
/* 你的样式 */
 .box-card {
  margin-bottom:20px
 }
 .container {
  position: relative;
  height: 100%; /* 确保容器有高度 */
}

.button-container {
  position: absolute;
  bottom: 0;
  right: 0;
  left: 0;
  display: flex;
  justify-content: flex-end;
  margin: 20px;
  gap: 10px;
  // background-color: white;
  box-shadow: 0 -2px 4px rgba(0, 0, 0, 0.1); /* 可选：添加阴影效果 */
}
</style>