<script setup lang="ts">
import { Row, List, ListItem } from 'ant-design-vue'
import { defineProps } from 'vue'

const props = defineProps({
  list: {
    type: Array,
    default: () => [
      '请从左侧面板中选择字段或选项',
      '支持<span style="color:red;font-weight: bold;">英文</span>模式下运算符号（+、-、*、/、>、<、==、!=、<=、>=）及函数',
      '参考场景：\n 根据输入的数量和单价，自动计算出金额，则可将计算公式设置为：数量*单价'
    ],
    required: false
  }
})
</script>

<template>
  <Row id="explain">
    <List size="small" :data-source="props.list">
      <template #renderItem="{ item }">
        <ListItem><span v-html="item"></span></ListItem>
      </template>
    </List>
  </Row>
</template>

<style lang="scss" scoped>
#explain {
  padding: 10px;
  width: 100%;

  :deep(.ant-list) {
    width: 100%;

    .ant-list-item {
      white-space: pre-line;
      font-size: 12px;
      color: #7F7F7F;
    }
  }
}
</style>