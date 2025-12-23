<template>
  <div 
    v-if="visible" 
    class="context-menu" 
    :style="{ top: `${y}px`, left: `${x}px` }"
  >
    <a-menu>
      <a-menu-item v-if="node.type === 'connection'" key="refresh" @click="handleClick('refresh')">
        <template #icon><ReloadOutlined /></template> 刷新连接
      </a-menu-item>
      <a-menu-item v-if="node.type === 'connection'" key="createDb" @click="handleClick('createDb')">
        <template #icon><PlusCircleOutlined /></template> 新建数据库
      </a-menu-item>
      <a-menu-item v-if="node.type === 'connection'" key="edit" @click="handleClick('edit')">
        <template #icon><EditOutlined /></template> 编辑连接
      </a-menu-item>
      <a-menu-item v-if="node.type === 'connection'" key="delete" danger @click="handleClick('delete')">
        <template #icon><DeleteOutlined /></template> 删除连接
      </a-menu-item>
      
      <a-menu-item v-if="node.type === 'database'" key="refresh" @click="handleClick('refresh')">
        <template #icon><ReloadOutlined /></template> 刷新数据库
      </a-menu-item>
      <a-menu-item v-if="node.type === 'database'" key="createTable" @click="handleClick('createTable')">
         <template #icon><PlusCircleOutlined /></template> 新建表
      </a-menu-item>
      
      <a-menu-item v-if="node.type === 'table'" key="view" @click="handleClick('view')">
        <template #icon><TableOutlined /></template> 查看数据
      </a-menu-item>
      <a-menu-item v-if="node.type === 'table'" key="refresh" @click="handleClick('refresh')">
        <template #icon><ReloadOutlined /></template> 刷新表
      </a-menu-item>
    </a-menu>
  </div>
</template>

<script setup lang="ts">
import { 
  ReloadOutlined, 
  PlusCircleOutlined, 
  EditOutlined, 
  DeleteOutlined,
  TableOutlined
} from '@ant-design/icons-vue';

const props = defineProps<{
  visible: boolean;
  x: number;
  y: number;
  node: any;
}>();

const emit = defineEmits(['update:visible', 'menuClick']);

const handleClick = (action: string) => {
  emit('menuClick', action);
  emit('update:visible', false);
};
</script>

<style scoped>
.context-menu {
  position: fixed;
  z-index: 1000;
  background: #fff;
  border: 1px solid #f0f0f0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
  border-radius: 4px;
  min-width: 120px;
}
</style>
