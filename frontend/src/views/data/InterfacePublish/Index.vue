<template>
  <a-layout style="height: 100%; background: #fff">
    <a-layout-sider width="280" theme="light" style="border-right: 1px solid #f0f0f0">
      <CategoryTree @select="onCategorySelect" />
    </a-layout-sider>
    <a-layout-content class="page-container">
      <div class="header-actions">
        <div class="filters">
          <a-input-search 
            v-model:value="searchKeyword" 
            placeholder="搜索发布接口名称/URL" 
            style="width: 300px" 
            @search="loadData"
          />
          <a-button @click="loadData" style="margin-left: 8px">刷新</a-button>
        </div>
        <a-button type="primary" @click="showDrawer">
          <template #icon><PlusOutlined /></template>
          发布新接口
        </a-button>
      </div>

      <a-table 
        :columns="columns" 
        :data-source="data" 
        :pagination="pagination"
        :loading="loading"
        @change="handleTableChange"
        row-key="id"
      >
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'status'">
            <a-tag :color="record.isPublished ? 'success' : 'default'">
              {{ record.isPublished ? '已发布' : '已下线' }}
            </a-tag>
          </template>
          <template v-else-if="column.key === 'method'">
            <a-tag :color="getMethodColor(record.method)">{{ record.method }}</a-tag>
          </template>
          <template v-else-if="column.key === 'updatedAt'">
            {{ record.updatedAt ? dayjs(record.updatedAt).format('YYYY-MM-DD HH:mm:ss') : '-' }}
          </template>
          <template v-else-if="column.key === 'action'">
            <a-space>
              <a @click.prevent="openEdit(record)">编辑</a>
              <a-popconfirm title="确定要删除该接口吗？" @confirm="handleDelete(record.id)">
                <a style="color: #ff4d4f">删除</a>
              </a-popconfirm>
            </a-space>
          </template>
        </template>
      </a-table>

      <ApiEditorDrawer
        v-model:visible="visible"
        :editingId="editingId"
        :initialData="drawerData"
        :categoryId="currentCategoryId"
        @save="onSave"
        @publish="onPublishChange"
      />
    </a-layout-content>
  </a-layout>
</template>

<script setup lang="ts">
import { ref, onMounted, reactive } from 'vue';
import { PlusOutlined } from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import ApiEditorDrawer from './components/ApiEditorDrawer.vue';
import CategoryTree from './components/CategoryTree.vue';
import { interfaceApi, type InterfaceDefinition } from '@/api/interface';

const visible = ref(false);
const editingId = ref<string | null>(null);
const drawerData = ref<any>(null);
const loading = ref(false);
const data = ref<InterfaceDefinition[]>([]);
const searchKeyword = ref('');
const currentCategoryId = ref<number | undefined>(undefined);

const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0,
  showSizeChanger: true,
  showQuickJumper: true
});

import dayjs from 'dayjs';

const columns = [
  { title: '接口名称', dataIndex: 'name', key: 'name' },
  { title: '所属分类', dataIndex: 'categoryName', key: 'categoryName', width: 150 },
  { title: '请求方法', dataIndex: 'method', key: 'method', width: 100 },
  { title: '完整路径', dataIndex: 'fullPath', key: 'path' },
  { title: '状态', key: 'status', width: 100 },
  { title: '更新时间', dataIndex: 'updatedAt', key: 'updatedAt', width: 180 },
  { title: '操作', key: 'action', width: 200 },
];

const getMethodColor = (method: string) => {
  switch (method.toUpperCase()) {
    case 'GET': return 'blue';
    case 'POST': return 'green';
    case 'PUT': return 'orange';
    case 'DELETE': return 'red';
    default: return 'default';
  }
};

const loadData = async () => {
  loading.value = true;
  try {
    const res = await interfaceApi.getInterfaces({
      categoryId: currentCategoryId.value,
      keyword: searchKeyword.value,
      page: pagination.current,
      pageSize: pagination.pageSize
    });
    // Adjust based on actual API response structure (PagedResult)
    const result = (res as any).data || res;
    data.value = result.items || [];
    pagination.total = result.total || 0;
  } catch (error) {
    console.error(error);
    message.error('加载接口列表失败');
  } finally {
    loading.value = false;
  }
};

const onCategorySelect = (category: any) => {
  currentCategoryId.value = category ? category.id : undefined;
  pagination.current = 1;
  loadData();
};

const handleTableChange = (pag: any) => {
  pagination.current = pag.current;
  pagination.pageSize = pag.pageSize;
  loadData();
};

const showDrawer = () => {
  if (!currentCategoryId.value) {
    message.warning('请先选择一个分类');
    return;
  }
  editingId.value = null;
  drawerData.value = null;
  visible.value = true;
};

const openEdit = (record: any) => {
  editingId.value = String(record.id);
  // Ensure deep copy and parse flowConfig
  const data = JSON.parse(JSON.stringify(record));
  if (data.flowConfig) {
    try {
        data.flow = JSON.parse(data.flowConfig);
    } catch(e) {
        data.flow = null;
    }
  }
  drawerData.value = data;
  visible.value = true;
};

const handleDelete = async (id: number) => {
  try {
    await interfaceApi.deleteInterface(id);
    message.success('删除成功');
    loadData();
  } catch (error) {
    message.error('删除失败');
  }
};

const onPublishChange = async (data: any) => {
  try {
      await interfaceApi.publishInterface(Number(data.id), data.isPublished);
      message.success(data.isPublished ? '已发布' : '已下线');
      loadData();
      
      // Update drawer data if open
      if (editingId.value === String(data.id) && drawerData.value) {
          // Instead of reopening (which causes flicker), we can just update the initialData prop
          // But ApiEditorDrawer only watches visible prop to reset/init form.
          // We need a way to update formState inside drawer when prop changes or expose a method.
          // Since we are passing initialData, we can update it, but reactivity might not trigger form update inside unless we watch initialData deep or visible toggle.
          
          // Let's reload the drawer with new data to reflect status change
          const res = await interfaceApi.getInterfaceById(Number(data.id));
          const updatedRecord = (res as any).data || res;
          
          // Update local data
          drawerData.value = {
              ...updatedRecord,
              flow: updatedRecord.flowConfig ? JSON.parse(updatedRecord.flowConfig) : null
          };
      }
  } catch (e) {
      message.error('操作失败');
  }
};

const onSave = async (savedData: any) => {
  try {
    const apiPayload: any = {
       categoryId: currentCategoryId.value,
       name: savedData.name,
       path: savedData.path,
       method: savedData.method,
       description: savedData.description,
       flowConfig: savedData.flow ? JSON.stringify(savedData.flow) : undefined,
       requiresAuth: savedData.auth?.type !== 'none',
       viewRoles: savedData.viewRoles,
       callRoles: savedData.callRoles,
       manageRoles: savedData.manageRoles
    };

    if (editingId.value) {
      await interfaceApi.updateInterface(Number(editingId.value), apiPayload);
      message.success('更新成功');
    } else {
      if (!currentCategoryId.value) {
        message.error('未选择分类');
        return;
      }
      await interfaceApi.createInterface(apiPayload);
      message.success('创建成功');
      visible.value = false;
    }
    
    loadData();
  } catch (e) {
    console.error(e);
    message.error('保存失败');
  }
};

onMounted(() => {
  loadData();
});
</script>

<style scoped>
.page-container {
  padding: 24px;
  background: #fff;
  min-height: 100%;
  display: flex;
  flex-direction: column;
}

.header-actions {
  display: flex;
  justify-content: space-between;
  margin-bottom: 16px;
}

.filters {
  display: flex;
  align-items: center;
}
</style>