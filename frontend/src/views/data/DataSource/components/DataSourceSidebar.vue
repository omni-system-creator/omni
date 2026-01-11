<template>
  <div class="left-panel">
    <div class="panel-header">
      <span class="title">数据源连接</span>
      <a-button type="primary" size="small" @click="$emit('addConnection')">
        <template #icon><PlusOutlined /></template>
      </a-button>
    </div>
    <div class="tree-container">
      <a-tree
        class="full-width-tree"
        block-node
        v-model:expandedKeys="expandedKeys"
        v-model:selectedKeys="selectedKeys"
        :tree-data="treeData"
        :load-data="onLoadData"
        @select="onSelect"
        @rightClick="onRightClick"
      >     <template #title="{ title, type }">
          <span v-if="type === 'connection'"><FolderOutlined /> {{ title }}</span>
          <span v-else-if="type === 'database'"><HddOutlined /> {{ title }}</span>
          <span v-else-if="type === 'table'"><TableOutlined /> {{ title }}</span>
          <span v-else>{{ title }}</span>
        </template>
      </a-tree>

      <DataSourceContextMenu
        v-model:visible="contextMenu.visible"
        :x="contextMenu.x"
        :y="contextMenu.y"
        :node="contextMenu.node"
        @menuClick="handleMenuClick"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue';
import { message, Modal } from 'ant-design-vue';
import { 
  PlusOutlined, 
  FolderOutlined, 
  HddOutlined, 
  TableOutlined 
} from '@ant-design/icons-vue';
import * as api from '@/api/dataSource';
import DataSourceContextMenu from './DataSourceContextMenu.vue';

const emit = defineEmits(['select', 'addConnection', 'createDb', 'createTable', 'editConnection', 'nodeRefreshed']);

const treeData = ref<any[]>([]);
const expandedKeys = ref<string[]>([]);
const selectedKeys = ref<string[]>([]);

// Context Menu State
const contextMenu = reactive({
  visible: false,
  x: 0,
  y: 0,
  node: null as any
});

// Load Initial Data Sources
const loadDataSources = async () => {
  try {
    const res = await api.getDataSources();
    if (res) {
      treeData.value = res.map((item: any) => ({
        title: item.name,
        key: `conn-${item.id}`,
        type: 'connection',
        id: item.id,
        isLeaf: false
      }));
    }
  } catch (error) {
    message.error('加载数据源失败');
  }
};

onMounted(() => {
  loadDataSources();
});

// Async Tree Load
const onLoadData = (treeNode: any): Promise<void> => {
  return new Promise(async (resolve) => {
    if (treeNode.children && treeNode.children.length > 0) {
      resolve();
      return;
    }

    try {
      if (treeNode.type === 'connection') {
        const res = await api.getDatabases(treeNode.id);
        if (res) {
          treeNode.dataRef.children = res.map((db: any) => ({
            title: db.name,
            key: `db-${treeNode.id}-${db.name}`,
            type: 'database',
            connectionId: treeNode.id,
            name: db.name,
            isLeaf: false
          }));
        }
      } else if (treeNode.type === 'database') {
        const res = await api.getTables(treeNode.connectionId, treeNode.name);
        if (res) {
          treeNode.dataRef.children = res.map((tb: any) => ({
            title: tb.name,
            key: `tb-${treeNode.connectionId}-${treeNode.name}-${tb.name}`,
            type: 'table',
            connectionId: treeNode.connectionId,
            databaseName: treeNode.name,
            tableName: tb.name,
            isLeaf: true
          }));
        }
      }
      
      treeData.value = [...treeData.value];
    } catch (error) {
      message.error('加载子节点失败');
    }
    resolve();
  });
};

const onSelect = (_keys: any[], info: any) => {
  if (info.selected) {
    emit('select', info.node);
  }
};

const onRightClick = ({ event, node }: any) => {
  contextMenu.visible = true;
  contextMenu.x = event.clientX;
  contextMenu.y = event.clientY;
  contextMenu.node = node;
};

const handleMenuClick = async (action: string) => {
  const node = contextMenu.node;
  if (!node) return;

  switch (action) {
    case 'refresh':
      await refreshNode(node);
      break;
    case 'createDb':
      emit('createDb', node.id); // node.id is connectionId
      break;
    case 'createTable':
      emit('createTable', node); // pass database node
      break;
    case 'edit':
      emit('editConnection', node.id);
      break;
    case 'delete':
      Modal.confirm({
        title: '确认删除',
        content: `确定要删除连接 "${node.title}" 吗？`,
        onOk: async () => {
          try {
            await api.deleteDataSource(node.id);
            message.success('删除成功');
            loadDataSources();
          } catch (error) {
            message.error('删除失败');
          }
        }
      });
      break;
    case 'view':
      emit('select', node); // Treat view as select
      break;
  }
};

const fetchNodeChildren = async (nodeData: any) => {
  if (nodeData.type === 'connection') {
    const res = await api.getDatabases(nodeData.id);
    if (res) {
      return res.map((db: any) => ({
        title: db.name,
        key: `db-${nodeData.id}-${db.name}`,
        type: 'database',
        connectionId: nodeData.id,
        name: db.name,
        isLeaf: false
      }));
    }
  } else if (nodeData.type === 'database') {
    const res = await api.getTables(nodeData.connectionId, nodeData.name);
    if (res) {
      return res.map((tb: any) => ({
        title: tb.name,
        key: `tb-${nodeData.connectionId}-${nodeData.name}-${tb.name}`,
        type: 'table',
        connectionId: nodeData.connectionId,
        databaseName: nodeData.name,
        tableName: tb.name,
        isLeaf: true
      }));
    }
  }
  return [];
};

const refreshNode = async (node: any) => {
  const nodeData = node.dataRef || node;
  
  try {
    const children = await fetchNodeChildren(nodeData);
    
    // Update Tree Data
    nodeData.children = children;
    treeData.value = [...treeData.value];
    
    message.success('刷新成功');
    
    // Notify parent to update tabs if necessary
    emit('nodeRefreshed', nodeData, children);
  } catch (error) {
    message.error('刷新失败');
  }
};

const refreshNodeByKey = (key: string) => {
    const findNode = (nodes: any[], targetKey: string): any => {
        for (const node of nodes) {
            if (node.key === targetKey) return node;
            if (node.children) {
                const found = findNode(node.children, targetKey);
                if (found) return found;
            }
        }
        return null;
    };
    const node = findNode(treeData.value, key);
    if (node) refreshNode(node);
};

defineExpose({
  refreshNode,
  refreshNodeByKey,
  loadDataSources
});
</script>

<style scoped>
.left-panel {
  width: 260px;
  border-right: 1px solid #f0f0f0;
  display: flex;
  flex-direction: column;
  height: 100%;
}

.panel-header {
  height: 50px;
  padding: 12px 16px;
  border-bottom: 1px solid #f0f0f0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #fafafa;
}

.title {
  font-weight: 500;
  color: #333;
}

.tree-container {
  flex: 1;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
}

:deep(.full-width-tree) {
  flex: 1;
  width: 100%;
  padding: 12px;
  border-radius: 0 !important;
  background-color: transparent;
}

:deep(.ant-tree-treenode) {
  width: 100%;
}
</style>
