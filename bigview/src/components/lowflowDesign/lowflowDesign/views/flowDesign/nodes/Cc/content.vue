<script setup lang="ts">
import {CcNode} from './index'
import {ref, watchEffect} from "vue";
// import {getList, User} from "../../../../api/modules/user";

export interface CcContentProps {
  node: CcNode
}
const userList = [
    {
        id: 1,
        name: "张三",
        username: "admin",
        avatar: "https://avatars.githubusercontent.com/u/44080404?v=4",
    },
    {
        id: 2,
        name: "李四",
        username: "lisi",
        avatar: "https://avatars.githubusercontent.com/u/44080404?v=4",
    },
    {
        id: 3,
        name: "王五",
        username: "wangwu",
        avatar: "https://avatars.githubusercontent.com/u/44080404?v=4",
    },
    {
        id: 4,
        name: "赵六",
        username: "zhaoliu",
        avatar: "https://avatars.githubusercontent.com/u/44080404?v=4",
    },
    {
        id: 5,
        name: "孙七",
        username: "sunqi",
        avatar: "https://avatars.githubusercontent.com/u/44080404?v=4",
    },
    {
        id: 6,
        name: "周八",
        username: "zhouba",
        avatar: "https://avatars.githubusercontent.com/u/44080404?v=4",
    },
    {
        id: 7,
        name: "吴九",
        username: "wujui",
        avatar: "https://avatars.githubusercontent.com/u/44080404?v=4",
    },
    {
        id: 8,
        name: "郑十",
        username: "zhengshi",
        avatar: "https://avatars.githubusercontent.com/u/44080404?v=4",
    }
]
const $props = withDefaults(defineProps<CcContentProps>(), {})
const content = ref<string>('')
watchEffect(() => {
  const props = $props.node
  if (props.users.length > 0) {
    content.value = userList.map((item) => item.name).join('、')
  } else {
    content.value = '未指定变量'
  }
})

</script>

<template>
  <el-text>
    {{ content || node.name }}
  </el-text>
</template>

<style scoped lang="scss">

</style>
