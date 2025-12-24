<script setup lang="ts">
import {ref, defineEmits} from 'vue';
import {Tree, Tag, Tooltip} from "ant-design-vue"
import Title from "./Title.vue";
import {DownOutlined} from '@ant-design/icons-vue';
import {defineProps} from 'vue';

const props = defineProps({
  title: {
    type: String,
    default: '标题'
  },
  isSearch: {
    type: Boolean,
    default: true
  },
  treeData: {
    type: Array,
    required: true,
    default: () => []
  },
  fieldNames: {
    type: Object,
    default: () => ({
      title: 'label',
      key: 'value',
      children: 'children'
    })
  }
})
const emits = defineEmits(['handleExplain', 'handleSelectNode'])
const searchValue = ref<string>('');
const defaultTree = JSON.parse(JSON.stringify(props.treeData));
const showTree = ref(props.treeData);
const expandedKeys = ref<any[]>(defaultTree.length > 0 ? [defaultTree[0].value] : []);
const selectedKeys = ref<string[]>([]);
const autoExpandParent = ref<boolean>(false);

function searchAndFilter(data: any, keyword: any) {
  return data.filter((item: any) => {
    const labelMatches = item.label.toUpperCase().includes(keyword.toUpperCase());
    if (item.children && item.children.length > 0) {
      item.children = searchAndFilter(item.children, keyword);
    }
    return labelMatches || (item.children && item.children.length > 0);
  });
}

const filterNodesWithChildren = (data: any): any[] => {
  const result: any[] = [];
  data.forEach((node: any) => {
    if (node.children && node.children.length > 0) {
      result.push(node.value);
      result.push(...filterNodesWithChildren(node.children));
    }
  });
  return result;
}

const handleSelect = (_: any, e: any) => {
  if (e.node.children && e.node.children.length > 0) {
    selectedKeys.value = []
  }
  if (e.node.explain && e.node.explain.length > 0) {
    emits("handleExplain", e.node.explain)
  }
}
const handleDbSelect = (node: any) => {
  if (!node.children || node.children.length <= 0) emits("handleSelectNode", node);

}
const handleSearch = (text: string) => {
  searchValue.value = text
  if (text == '') {
    showTree.value = defaultTree
    expandedKeys.value = [defaultTree[0].value]
    autoExpandParent.value = false
  } else {
    let filterData = searchAndFilter(JSON.parse(JSON.stringify(defaultTree)), text)
    expandedKeys.value = filterNodesWithChildren(filterData)
    showTree.value = filterData;
    autoExpandParent.value = true
  }
}
const onExpand = (expandedKeys: any): void => {
  expandedKeys.value = expandedKeys;
  autoExpandParent.value = false;
};
const showToolTip = (e: any) => {
  if (e.target.clientWidth >= e.target.scrollWidth) {
    e.target.style.pointerEvents = "none";
  }
}
</script>

<template>
  <div class="tree-content">
    <Title v-bind="{title:props.title,isSearch:props.isSearch}" @handleSearch="handleSearch"/>
    <Tree
        v-model:expandedKeys="expandedKeys"
        v-model:selectedKeys="selectedKeys"
        :autoExpandParent="autoExpandParent"
        show-line
        v-if="showTree.length > 0"
        :tree-data="showTree"
        :fieldNames="props.fieldNames"
        :style="{
        height:props.isSearch?'calc(100% - 60px) !important':'calc(100% - 20px)!important',
        overflow:'hidden'
      }"
        @select="handleSelect"
        @expand="onExpand"
    >
      <template #switcherIcon="{ switcherCls }">
        <down-outlined :class="switcherCls"/>
      </template>
      <template #title="treeNode">
        <span class="tree-text" @dblclick="handleDbSelect(treeNode)">
          <Tooltip placement="top" @mouseenter="showToolTip">
              <template #title>
                <span>{{ treeNode[props.fieldNames.title] }}</span>
              </template>
              <span class="text">
                  {{ treeNode[props.fieldNames.title] }}
              </span>
          </Tooltip>
          <Tag
              :bordered="false"
              v-if="!treeNode.children && treeNode.tag && treeNode.tag != 'none'"
          >{{ treeNode.tagName }}</Tag>
          </span>
      </template>
    </Tree>
  </div>
</template>
<style>
</style>
<style lang="scss" scoped>
.tree-content {
  height: 100%;
  :deep(.ant-tree){
    // height: 9cap;
    background-color: #1F1F20;
  }
  :deep(.ant-tree-treenode) {
    width: 100%;
    color: rgb(255, 255, 255);
    .ant-tree-node-content-wrapper {
      flex-grow: 1;
      width: calc(100% - 25px);

      .tree-text {
        width: 100%;
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 0;

        .text {
          width: 100%;
          flex-grow: 1;
          overflow: hidden;
          text-overflow: ellipsis;
          word-break: break-all;
          white-space: nowrap;
        }

        .ant-tag {
          margin: 0;
          flex-shrink: 0;
        }
      }
    }
  }

  :deep(.ant-tree-node-content-wrapper-normal) {
    width: 100%;
    padding: 0;
    margin: 0;
  }

  :deep(.ant-tree-switcher) {
    width: 10px;
    margin-right: 5px;
  }

  :deep(.ant-tree-switcher-noop) {
    display: none !important;
  }
}
</style>
