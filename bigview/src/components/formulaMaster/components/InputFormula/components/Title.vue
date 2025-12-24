<script setup lang="ts">
import {defineProps,defineEmits, ref} from 'vue'
import {InputSearch, Row} from 'ant-design-vue'

const emits = defineEmits(['handleSearch'])
const props = defineProps({
  title: {
    type: String,
    default: '标题'
  },
  isSearch: {
    type: Boolean,
    default: true
  },
  searchPlaceholder: {
    type: String,
    default: '请输入'
  }
})
const searchText = ref('')
const onSearch = () => {
  emits('handleSearch', searchText.value)
}
</script>

<template>
  <Row
      class="title"
      :style="{height:props.isSearch?'60px':'30px'}"
  >
    <h1>
      {{ props.title }}
    </h1>
    <InputSearch
        v-if="props.isSearch"
        v-model:value="searchText"
        :placeholder="props.searchPlaceholder"
        style="zoom:.9"
        @search="onSearch"
    />
  </Row>
</template>

<style lang="scss" scoped>
.title {
  width: 100%;
  display: flex;
  // background-color: #1F1F20;
  h1 {
    width: 100%;
    font-size: 14px;
    height: 30px;
    line-height: 16px;
    margin: -8px 0 0 0;
    padding: 0;
    display: flex;
    align-items: center;
  }
}

</style>
