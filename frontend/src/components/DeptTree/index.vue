<template>
  <div class="dept-tree-container">
    <div class="tree-header" v-if="showSearch">
       <a-input-search v-model:value="searchValue" style="margin-bottom: 8px" placeholder="搜索部门" />
    </div>
    <div class="tree-body">
      <a-spin :spinning="loading">
        <a-tree
          v-if="treeData.length > 0"
          :tree-data="treeData"
          :field-names="{ children: 'children', title: 'name', key: 'id' }"
          :default-expand-all="defaultExpandAll"
          v-model:expandedKeys="expandedKeys"
          v-model:selectedKeys="internalSelectedKeys"
          @select="onSelect"
          block-node
        >
          <template #title="{ name, type }">
            <span v-if="type === DeptType.Group">
              <BankOutlined style="color: #faad14; margin-right: 4px" />
            </span>
            <span v-else-if="type === DeptType.Company">
              <ApartmentOutlined style="color: #1890ff; margin-right: 4px" />
            </span>
            <span v-else>
              <ClusterOutlined style="color: #8c8c8c; margin-right: 4px" />
            </span>
            <span v-if="name.indexOf(searchValue) > -1">{{ name.substr(0, name.indexOf(searchValue)) }}<span style="color: #f50">{{ searchValue }}</span>{{ name.substr(name.indexOf(searchValue) + searchValue.length) }}</span>
            <span v-else>{{ name }}</span>
          </template>
        </a-tree>
        <a-empty v-else description="暂无部门数据" />
      </a-spin>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue';
import { 
  BankOutlined,
  ApartmentOutlined,
  ClusterOutlined
} from '@ant-design/icons-vue';
import { getDeptTree, type Dept, DeptType } from '@/api/dept';

const props = defineProps({
  selectedKeys: {
    type: Array as () => number[],
    default: () => []
  },
  showSearch: {
    type: Boolean,
    default: false
  },
  defaultExpandAll: {
    type: Boolean,
    default: true
  },
  rootId: {
    type: Number,
    default: undefined
  }
});

const emit = defineEmits(['update:selectedKeys', 'select', 'loaded']);

const loading = ref(false);
const treeData = ref<Dept[]>([]);
const internalSelectedKeys = ref<number[]>([]);
const expandedKeys = ref<number[]>([]);
const searchValue = ref('');

watch(() => props.selectedKeys, (val) => {
  internalSelectedKeys.value = val;
}, { immediate: true });

watch(internalSelectedKeys, (val) => {
  emit('update:selectedKeys', val);
});

watch(() => props.rootId, () => {
  loadData();
});

const loadData = async () => {
  loading.value = true;
  try {
    const res = await getDeptTree(props.rootId);
    treeData.value = res || [];
    // 默认展开一级
    if (treeData.value.length > 0) {
      expandedKeys.value = treeData.value.map(item => item.id);
    }
    emit('loaded', treeData.value);
  } catch (error) {
    console.error(error);
  } finally {
    loading.value = false;
  }
};

const onSelect = (keys: number[], info: any) => {
  emit('select', keys, info);
};

onMounted(() => {
  loadData();
});

// Expose tree data and helper methods if needed
defineExpose({
  treeData,
  loadData
});
</script>

<style scoped>
.dept-tree-container {
  height: 100%;
  display: flex;
  flex-direction: column;
  background-color: #fff;
}

.tree-body {
  flex: 1;
  overflow-y: auto;
}

:deep(.ant-tree-treenode) {
  padding-bottom: 4px;
}

:deep(.ant-tree-node-content-wrapper) {
  min-height: 32px;
  line-height: 32px;
}

:deep(.ant-tree-switcher) {
  line-height: 32px;
}
</style>
