<template>
  <a-alert message="数据操作" type="info" show-icon style="margin-bottom: 16px">
    <template #description>
      <div style="font-size: 12px;">
        <p>执行SQL语句，系统会自动将<strong>上下文变量</strong>注入为SQL参数。</p>
        <p><strong>使用方式:</strong> 直接使用 <code>@参数名</code> (例如请求参数为 id，则写 @id)</p>
        <p><strong>Example:</strong> SELECT * FROM production_plans WHERE plan_no = @id</p>
        <p><strong>Output:</strong> 结果数组将存入 <code>dbResult</code> 变量供后续使用</p>
      </div>
    </template>
  </a-alert>
  <a-form-item label="数据源">
    <a-tree-select
      v-model:value="treeValue"
      style="width: 100%"
      :dropdown-style="{ maxHeight: '400px', overflow: 'auto' }"
      :tree-data="treeData"
      placeholder="请选择数据源"
      tree-default-expand-all
      :load-data="onLoadData"
      @change="onTreeSelectChange"
    />
  </a-form-item>
  <a-form-item label="操作类型">
    <a-select v-model:value="node.data.opType" @change="onChange">
      <a-select-option value="select">查询 (Select)</a-select-option>
      <a-select-option value="insert">插入 (Insert)</a-select-option>
      <a-select-option value="update">更新 (Update)</a-select-option>
      <a-select-option value="delete">删除 (Delete)</a-select-option>
    </a-select>
  </a-form-item>
  <a-form-item label="SQL语句">
    <a-textarea v-model:value="node.data.sql" :rows="5" placeholder="SELECT * FROM production_plans WHERE plan_no = @id" @input="onChange" />
  </a-form-item>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue';
import { message } from 'ant-design-vue';
import { getDataSources, getDatabases, type DataSourceConnection } from '@/api/dataSource';

const props = defineProps<{
  node: any;
  readOnly?: boolean;
}>();

const emit = defineEmits(['change']);

const treeData = ref<any[]>([]);
const treeValue = ref<string>();
const loading = ref(false);

const loadDataSources = async () => {
  loading.value = true;
  try {
    const res = await getDataSources();
    if (res) {
      // Group by type
      const groups: Record<string, DataSourceConnection[]> = {};
      res.forEach(ds => {
        const type = ds.type || 'Other';
        if (!groups[type]) groups[type] = [];
        groups[type].push(ds);
      });

      treeData.value = Object.keys(groups).map(type => ({
        title: type.toUpperCase(),
        value: `type-${type}`,
        key: `type-${type}`,
        selectable: false,
        children: groups[type]!.map(ds => ({
          title: `${ds.name} (${ds.host}:${ds.port})`,
          value: `conn-${ds.id}`,
          key: `conn-${ds.id}`,
          selectable: false,
          isLeaf: false,
          dataRef: ds
        }))
      }));

      // If there is an initial selection with databaseName, preload that connection's databases
      if (props.node.data.sourceId && props.node.data.databaseName) {
        // Find connection node in the grouped tree
        for (const typeNode of treeData.value) {
          const connNode = typeNode.children?.find((n: any) => n.key === `conn-${props.node.data.sourceId}`);
          if (connNode) {
            await loadDatabasesForNode(connNode);
            break;
          }
        }
      }
      // Force update to ensure TreeSelect picks up the children
      treeData.value = [...treeData.value];
    }
  } catch (error) {
    message.error('加载数据源失败');
  } finally {
    loading.value = false;
  }
};

const loadDatabasesForNode = async (treeNode: any) => {
  try {
    const ds = treeNode.dataRef;
    const dbs = await getDatabases(ds.id);
    if (dbs) {
      treeNode.children = dbs.map((db: any) => ({
        title: db.name,
        value: `db-${ds.id}-${db.name}`,
        key: `db-${ds.id}-${db.name}`,
        isLeaf: true
      }));
    } else {
      treeNode.isLeaf = true;
    }
  } catch (e) {
    message.error('加载数据库失败');
    treeNode.isLeaf = true;
  }
};

const onLoadData = (treeNode: any) => {
  return new Promise<void>(async (resolve) => {
    const { key } = treeNode;
    // Find the node in treeData
    const findNode = (nodes: any[], targetKey: string): any => {
      for (const node of nodes) {
        if (node.key === targetKey) return node;
        if (node.children) {
          const res = findNode(node.children, targetKey);
          if (res) return res;
        }
      }
      return null;
    };

    const targetNode = findNode(treeData.value, key);
    if (!targetNode || (targetNode.children && targetNode.children.length > 0)) {
      resolve();
      return;
    }
    
    await loadDatabasesForNode(targetNode);
    treeData.value = [...treeData.value];
    resolve();
  });
};

// Sync node.data to treeValue
watch(() => [props.node.data.sourceId, props.node.data.databaseName], ([sourceId, dbName]) => {
  if (!sourceId) {
    treeValue.value = undefined;
    return;
  }
  if (dbName) {
    treeValue.value = `db-${sourceId}-${dbName}`;
  } else {
    treeValue.value = `conn-${sourceId}`;
  }
}, { immediate: true });

onMounted(() => {
  loadDataSources();
});

const onTreeSelectChange = (value: string) => {
  if (!value) {
    props.node.data.sourceId = undefined;
    props.node.data.databaseName = undefined;
  } else if (value.startsWith('conn-')) {
    const id = value.split('-')[1];
    props.node.data.sourceId = id;
    props.node.data.databaseName = undefined;
  } else if (value.startsWith('db-')) {
    const parts = value.split('-');
    // db-{id}-{name}
    const id = parts[1];
    const name = parts.slice(2).join('-');
    props.node.data.sourceId = id;
    props.node.data.databaseName = name;
  }
  emit('change');
};

const onChange = () => {
  emit('change');
};
</script>
