<template>
  <div class="form-list-container">
    <div class="list-header">
      <div class="header-left">
        <span class="category-title">{{ categoryName || '全部表单' }}</span>
      </div>
      <div class="header-right">
        <a-space>
          <a-input-search
            v-model:value="queryParams.keyword"
            placeholder="搜索表单"
            style="width: 200px"
            @search="handleSearch"
          />
          <a-button type="primary" @click="handleCreate" v-if="permissionStore.hasPermission('form:create')">
            <template #icon><PlusOutlined /></template>
            新建表单
          </a-button>
        </a-space>
      </div>
    </div>

    <div class="list-content">
      <a-table
        :columns="columns"
        :data-source="tableData"
        :loading="loading"
        :pagination="pagination"
        @change="handleTableChange"
        row-key="id"
      >
        <template #bodyCell="{ column, record, index }">
          <template v-if="column.key === 'index'">
            {{ (pagination.current - 1) * pagination.pageSize + index + 1 }}
          </template>
          <template v-else-if="column.key === 'status'">
            <a-tag :color="record.isPublished ? 'green' : 'orange'">
              {{ record.isPublished ? '已发布' : '草稿' }}
            </a-tag>
          </template>
          <template v-else-if="column.key === 'updatedAt'">
            {{ record.updatedAt ? dayjs(record.updatedAt).format('YYYY-MM-DD HH:mm:ss') : '-' }}
          </template>
          <template v-else-if="column.key === 'action'">
            <a-space>
              <a-tooltip title="编辑" v-if="canManage(record)">
                <a-button type="link" size="small" @click="handleEdit(record as any)">
                  <template #icon><EditOutlined /></template>
                </a-button>
              </a-tooltip>
              <a-tooltip title="设计" v-if="canManage(record)">
                <a-button type="link" size="small" @click="handleDesign(record as any)">
                  <template #icon><FormOutlined /></template>
                </a-button>
              </a-tooltip>
              <a-tooltip title="发布" v-if="!record.isPublished && canManage(record)">
                <a-button 
                  type="link" 
                  size="small" 
                  @click="handlePublish(record as any)"
                >
                  <template #icon><SendOutlined /></template>
                </a-button>
              </a-tooltip>
              <a-tooltip title="取消发布" v-if="record.isPublished && canManage(record)">
                <a-button 
                  type="link" 
                  size="small" 
                  @click="handleUnpublish(record as any)"
                >
                  <template #icon><StopOutlined /></template>
                </a-button>
              </a-tooltip>
              <a-tooltip title="分享" v-if="record.isPublished && canManage(record)">
                <a-button 
                  type="link" 
                  size="small" 
                  @click="handleViewLink(record as any)"
                >
                  <template #icon><ShareAltOutlined /></template>
                </a-button>
              </a-tooltip>
              <a-tooltip title="数据" v-if="record.isPublished && canManage(record)">
                <a-button 
                  type="link" 
                  size="small" 
                  @click="handleViewData(record as any)"
                >
                  <template #icon><TableOutlined /></template>
                </a-button>
              </a-tooltip>
              <a-popconfirm title="确定删除吗？" @confirm="handleDelete(record.id)" v-if="canManage(record)">
                <a-tooltip title="删除">
                  <a-button type="link" danger size="small">
                    <template #icon><DeleteOutlined /></template>
                  </a-button>
                </a-tooltip>
              </a-popconfirm>
            </a-space>
          </template>
        </template>
      </a-table>
    </div>

    <!-- Create/Edit Dialog -->
    <a-modal
      v-model:open="dialogVisible"
      :title="dialogTitle"
      @ok="handleDialogOk"
      :confirmLoading="confirmLoading"
    >
      <a-form :model="formState" layout="vertical">
        <a-form-item label="表单名称" required>
          <a-input v-model:value="formState.name" placeholder="请输入表单名称" />
        </a-form-item>
        <a-form-item label="所属分类" required>
           <a-tree-select
            v-model:value="formState.categoryId"
            style="width: 100%"
            :dropdown-style="{ maxHeight: '400px', overflow: 'auto' }"
            :tree-data="categoryTreeData"
            placeholder="请选择分类"
            :field-names="{ children: 'children', label: 'name', value: 'id' }"
            tree-default-expand-all
          />
        </a-form-item>
        <a-form-item label="描述">
          <a-textarea v-model:value="formState.description" :rows="4" />
        </a-form-item>
        <a-form-item label="设置" name="requiresLogin">
          <a-space direction="vertical">
            <a-checkbox v-model:checked="formState.requiresLogin">需要登录才能填报</a-checkbox>
            <a-checkbox v-model:checked="formState.limitOnePerUser">每人只能填一份 (需登录)</a-checkbox>
          </a-space>
        </a-form-item>

        <a-divider orientation="left">权限设置</a-divider>

        <a-form-item label="查看权限" help="指定哪些角色可以看到此表单（为空则所有人可见）">
          <a-select
            v-model:value="formState.viewRoleIdsList"
            mode="multiple"
            placeholder="请选择角色"
            :options="roleOptions"
            :filter-option="filterRoleOption"
            allow-clear
            style="width: 100%"
          />
        </a-form-item>

        <a-form-item label="填报权限" help="指定哪些角色可以填报此表单（为空则所有人可填）">
          <a-select
            v-model:value="formState.fillRoleIdsList"
            mode="multiple"
            placeholder="请选择角色"
            :options="roleOptions"
            :filter-option="filterRoleOption"
            allow-clear
            style="width: 100%"
          />
        </a-form-item>

        <a-form-item label="管理权限" help="指定哪些角色可以管理此表单（编辑/删除/查看数据）">
          <a-select
            v-model:value="formState.manageRoleIdsList"
            mode="multiple"
            placeholder="请选择角色"
            :options="roleOptions"
            :filter-option="filterRoleOption"
            allow-clear
            style="width: 100%"
          />
        </a-form-item>
      </a-form>
    </a-modal>

    <!-- Publish Link Modal -->
    <a-modal
      v-model:open="linkModalVisible"
      title="表单链接"
      :footer="null"
    >
      <div class="link-content">
        <a-input v-model:value="publishUrl" readonly>
          <template #addonAfter>
            <CopyOutlined style="cursor: pointer" @click="copyLink" />
          </template>
        </a-input>
        <div style="margin-top: 16px; text-align: center;">
          <a-qrcode :value="publishUrl" />
        </div>
      </div>
    </a-modal>

    <!-- Data Viewer Modal -->
    <DraggableModal
      v-model:visible="dataModalVisible"
      :title="`${currentFormName} - 数据汇总`"
      width="80%"
      height="80%"
      bodyPadding="0"
    >
      <div class="data-view-container">
        <div class="toolbar">
          <a-button type="primary" size="small" @click="exportExcel">
            <template #icon><DownloadOutlined /></template>
            导出Excel
          </a-button>
        </div>
        
        <div class="table-wrapper" ref="tableWrapperRef">
          <a-table
            :columns="dataColumns"
            :data-source="dataTableData"
            :loading="dataLoading"
            :pagination="false"
            row-key="id"
            size="small"
            :scroll="{ x: 'max-content', y: tableHeight }"
          >
            <template #bodyCell="{ column, record }">
              <template v-if="column.key === 'submittedAt'">
                {{ dayjs(record.submittedAt).format('YYYY-MM-DD HH:mm:ss') }}
              </template>
              <template v-else-if="(column as any).isSubTable">
                 <a-button type="link" size="small" @click="viewSubTable(record[(column as any).key], column)">
                   查看 ({{ Array.isArray(record[(column as any).key]) ? record[(column as any).key].length : 0 }})
                 </a-button>
              </template>
            </template>
          </a-table>
        </div>
        <div class="pagination-wrapper">
          <a-pagination
            v-model:current="dataPagination.current"
            v-model:pageSize="dataPagination.pageSize"
            :total="dataPagination.total"
            :show-total="dataPagination.showTotal"
            :page-size-options="dataPagination.pageSizeOptions"
            show-size-changer
            size="small"
            @change="handlePageChange"
            @showSizeChange="handlePageSizeChange"
          />
        </div>
      </div>
    </DraggableModal>

    <!-- SubTable Data Modal -->
    <a-modal
      v-model:open="subTableModalVisible"
      :title="`${subTableTitle} - 明细`"
      :footer="null"
      width="800px"
      :zIndex="2200"
    >
      <a-table
        :columns="subTableColumns"
        :data-source="subTableData"
        size="small"
        :pagination="false"
        :scroll="{ y: 500 }"
      >
      </a-table>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, watch, onMounted, computed } from 'vue';
import { 
  PlusOutlined, 
  CopyOutlined,
  EditOutlined,
  FormOutlined,
  SendOutlined,
  StopOutlined,
  ShareAltOutlined,
  DeleteOutlined,
  TableOutlined,
  DownloadOutlined
} from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import dayjs from 'dayjs';
import { useRouter } from 'vue-router';
import { getFormList, createForm, updateForm, deleteForm, getCategoryTree, getFormResults, type FormDefinition } from '@/api/form';
import { getRoleList, type RoleDto } from '@/api/role';
import ExcelJS from 'exceljs';
import { saveAs } from 'file-saver';
import DraggableModal from '@/components/DraggableModal.vue';
import { useElementSize } from '@vueuse/core';
import { usePermissionStore } from '@/stores/permission';
import { useUserStore } from '@/stores/user';

const props = defineProps({
  categoryId: {
    type: Number,
    default: null
  },
  categoryName: {
    type: String,
    default: ''
  }
});

const emit = defineEmits(['open-designer']);

const permissionStore = usePermissionStore();
const userStore = useUserStore();
const router = useRouter();
const loading = ref(false);
const tableData = ref<FormDefinition[]>([]);
const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0,
  showSizeChanger: true,
  pageSizeOptions: ['10', '20', '50', '100'],
  showTotal: (total: number) => `共 ${total} 条`
});
const queryParams = reactive({
  keyword: '',
  categoryId: props.categoryId
});

const canManage = (record: any) => {
  if (userStore.username === 'admin') return true;
  if (!record.manageRoleIds) return false;
  
  const allowedRoles = record.manageRoleIds.split(',').map((r: string) => Number(r.trim()));
  const userRoles = userStore.roles || [];
  
  return userRoles.some((r: number) => allowedRoles.includes(r));
};

const columns: any[] = [
  { title: '序号', key: 'index', width: 70, align: 'center' as const },
  { title: '表单名称', dataIndex: 'name', key: 'name', sorter: true },
  { title: '描述', dataIndex: 'description', key: 'description', ellipsis: true },
  { title: '状态', dataIndex: 'isPublished', key: 'status', width: 100 },
  { title: '修改时间', dataIndex: 'updatedAt', key: 'updatedAt', width: 180, sorter: true },
  { title: '操作', key: 'action', width: 280, fixed: 'right' as const }
];

// Dialog Logic
const dialogVisible = ref(false);
const dialogTitle = ref('新建表单');
const confirmLoading = ref(false);
const categoryTreeData = ref([]);
const roleList = ref<RoleDto[]>([]);
const formState = reactive<FormDefinition & {
  viewRoleIdsList: number[];
  fillRoleIdsList: number[];
  manageRoleIdsList: number[];
}>({
  name: '',
  categoryId: 0,
  description: '',
  requiresLogin: false,
  limitOnePerUser: false,
  viewRoleIdsList: [],
  fillRoleIdsList: [],
  manageRoleIdsList: []
});

const roleOptions = computed(() => {
  return roleList.value.map(r => ({ label: r.name, value: r.id }));
});

const filterRoleOption = (input: string, option: any) => {
  return option.label.toLowerCase().indexOf(input.toLowerCase()) >= 0;
};

// Link Modal
const linkModalVisible = ref(false);
const publishUrl = ref('');

// Data Viewer Modal Logic
const dataModalVisible = ref(false);
const currentFormName = ref('');
const currentFormId = ref<number | null>(null);
const dataLoading = ref(false);
const dataTableData = ref<any[]>([]);
const dataColumns = ref<any[]>([]);

// SubTable Modal Logic
const subTableModalVisible = ref(false);
const subTableTitle = ref('');
const subTableData = ref<any[]>([]);
const subTableColumns = ref<any[]>([]);

const viewSubTable = (data: any[], column: any) => {
  subTableTitle.value = column.title;
  subTableData.value = Array.isArray(data) ? data : [];
  subTableColumns.value = (column.subColumns || []).map((col: any) => ({
    title: col.label,
    dataIndex: col.id,
    key: col.id,
    width: 150
  }));
  subTableModalVisible.value = true;
};

// Auto resize table height
const tableWrapperRef = ref<HTMLElement | null>(null);
const { height: wrapperHeight } = useElementSize(tableWrapperRef);
const tableHeight = computed(() => {
  if (!wrapperHeight.value) return 400;
  // Subtract header height (approx 40px)
  return Math.max(300, wrapperHeight.value - 40); 
});

const dataPagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0,
  showSizeChanger: true,
  pageSizeOptions: ['10', '20', '50', '100'],
  showTotal: (total: number) => `共 ${total} 条`
});

const handleViewData = async (record: FormDefinition) => {
  currentFormId.value = record.id!;
  currentFormName.value = record.name;
  dataModalVisible.value = true;
  dataPagination.current = 1;
  
  // Parse form items to build columns
  try {
    const items = JSON.parse(record.formItems || '[]');
    const cols: any[] = [
      { title: '提交时间', dataIndex: 'submittedAt', key: 'submittedAt', width: 180, fixed: 'left' },
      { title: '提交人', dataIndex: 'submittedBy', key: 'submittedBy', width: 120 }
    ];
    
    // Flatten form items (handle sub-tables later or just show summary)
    // For now, let's extract top-level fields
    items.forEach((item: any) => {
      if (item.type === 'subtable') {
        cols.push({
           title: item.label,
           dataIndex: item.id,
           key: item.id,
           width: 150,
           isSubTable: true,
           subColumns: item.columns
        });
      } else {
        cols.push({
          title: item.label,
          dataIndex: item.id,
          key: item.id,
          width: 150,
          ellipsis: true
        });
      }
    });
    
    dataColumns.value = cols;
    await loadFormData();
  } catch (e) {
    console.error(e);
    message.error('解析表单结构失败');
  }
};

const loadFormData = async () => {
  if (!currentFormId.value) return;
  dataLoading.value = true;
  try {
    const res = await getFormResults(currentFormId.value, {
       page: dataPagination.current,
       pageSize: dataPagination.pageSize
    });
    
    // Check if result is PagedResult
    const data = (res as any).data || res;
    // Structure: { items: [], total: 0, ... }
    
    if (data && Array.isArray(data.items)) {
       const rawItems = data.items;
       dataPagination.total = data.total;
       
       // Process data: parse JSON string in 'data' field
       dataTableData.value = rawItems.map((item: any) => {
          let parsedData = {};
          try {
             parsedData = JSON.parse(item.data);
          } catch (e) { /* ignore */ }
          
          return {
             ...item,
             ...parsedData
          };
       });
    } else {
       dataTableData.value = [];
       dataPagination.total = 0;
    }
  } catch (e) {
    message.error('加载数据失败');
    dataTableData.value = [];
  } finally {
    dataLoading.value = false;
  }
};

const handlePageChange = (page: number, _pageSize: number) => {
  dataPagination.current = page;
  loadFormData();
};

const handlePageSizeChange = (_current: number, size: number) => {
  dataPagination.current = 1;
  dataPagination.pageSize = size;
  loadFormData();
};

const exportExcel = () => {
  if (dataTableData.value.length === 0) {
    message.warning('暂无数据可导出');
    return;
  }
  
  // We should export ALL data, not just current page. 
  // Ideally, call backend for export or fetch all pages.
  // For simplicity, let's fetch all (or a large limit) if user wants export.
  // Or just export current view? User usually wants all.
  // Let's try to fetch all for export.
  
  fetchAllDataAndExport();
};

const fetchAllDataAndExport = async () => {
  const hide = message.loading('正在导出所有数据...', 0);
  try {
    // Use total from pagination to fetch all records
    const totalCount = dataPagination.total > 0 ? dataPagination.total : 10000;
    
    const res = await getFormResults(currentFormId.value!, {
       page: 1,
       pageSize: totalCount
    });
    const data = (res as any).data || res;
    const items = data.items || [];
    
    if (items.length === 0) {
      message.warning('没有数据可导出');
      return;
    }
    
    const exportData = items.map((item: any) => {
       let parsed: any = {};
       try { parsed = JSON.parse(item.data); } catch(e){}
       
       const row: any = {
          '提交时间': dayjs(item.submittedAt).format('YYYY-MM-DD HH:mm:ss'),
          '提交人': item.submittedBy
       };
       
       // Map dynamic fields
       dataColumns.value.forEach((col: any) => {
          if (col.key !== 'submittedAt' && col.key !== 'submittedBy' && !col.isSubTable) {
             let val = parsed[col.key];
             // Handle object
             if (typeof val === 'object' && val !== null) {
                val = JSON.stringify(val);
             }
             row[col.title] = val;
          } else if (col.isSubTable) {
             // Handle subtable
             let val = parsed[col.key];
             if (Array.isArray(val)) {
                // Export as JSON string for now, or maybe count? 
                // User usually wants content.
                val = JSON.stringify(val);
             }
             row[col.title] = val;
          }
       });
       return row;
    });
    
    const workbook = new ExcelJS.Workbook();
    const worksheet = workbook.addWorksheet('Sheet1');
    
    if (exportData.length > 0) {
       const headers = Object.keys(exportData[0]);
       worksheet.columns = headers.map(header => ({ header, key: header, width: 20 }));
       worksheet.addRows(exportData);
    }
    
    const buffer = await workbook.xlsx.writeBuffer();
    const blob = new Blob([buffer], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' });
    saveAs(blob, `${currentFormName.value}_数据汇总.xlsx`);
    
    message.success(`成功导出 ${items.length} 条数据`);
    
  } catch (e) {
    console.error(e);
    message.error('导出失败');
  } finally {
    hide();
  }
};

// Sorting state
const sortState = reactive({
  field: 'updatedAt',
  order: 'descend' // 'ascend' | 'descend'
});

const loadData = async () => {
  loading.value = true;
  try {
    const res = await getFormList({
      categoryId: queryParams.categoryId,
      page: pagination.current,
      pageSize: pagination.pageSize,
      sortBy: sortState.field,
      isDescending: sortState.order === 'descend'
    });
    
    // Check structure. If it's ApiResponse<PagedResult<T>>, then res might be { code, msg, data: { items, total } }
    // Or if axios interceptor unwraps it...
    // Let's assume axios interceptor unwraps "data". So res is { items, total } or similar.
    // BUT previous code was: const list = (Array.isArray(res) ? res : (res as any).data) || [];
    // If backend changed from List<T> to PagedResult<T>, the structure changed.
    // The previous implementation of FormController.GetForms returned ApiResponse<List<T>>.
    // Now it returns ApiResponse<PagedResult<T>>.
    // If interceptor returns `response.data`, then `res` is `ApiResponse`.
    // If interceptor returns `response.data.data` (common pattern), then `res` is `PagedResult`.
    
    // Let's look at `utils/request.ts` if possible, but assuming standard behavior or inspecting previous code.
    // Previous code: `const list = (Array.isArray(res) ? res : (res as any).data) || [];`
    // This suggests res might be the array itself OR an object containing data.
    
    // With PagedResult, we expect:
    // res.items (or res.data.items)
    // res.total (or res.data.total)
    
    // Let's handle it safely.
    const resultData = (res as any).items ? res : (res as any).data;
    
    if (resultData && Array.isArray(resultData.items)) {
       tableData.value = resultData.items;
       pagination.total = resultData.total;
    } else {
       // Fallback or error
       tableData.value = [];
       pagination.total = 0;
    }

  } catch (e) {
    // error
    tableData.value = [];
    pagination.total = 0;
  } finally {
    loading.value = false;
  }
};

const loadCategories = async () => {
  const res = await getCategoryTree();
  categoryTreeData.value = (Array.isArray(res) ? res : (res as any).data) || [];
};

const loadRoles = async () => {
  try {
    const res = await getRoleList();
    roleList.value = res || [];
  } catch (e) {
    console.error(e);
  }
};

const handleSearch = () => {
  pagination.current = 1;
  loadData();
};

const handleTableChange = (pag: any, _filters: any, sorter: any) => {
  pagination.current = pag.current;
  pagination.pageSize = pag.pageSize;
  
  if (sorter.field) {
    sortState.field = sorter.field;
    sortState.order = sorter.order || 'descend'; // Default to descend if order is null (cancelled sort)
  }
  
  loadData();
};

const parseRoleIds = (str?: string) => {
  if (!str) return [];
  return str.split(',').map(s => Number(s)).filter(n => !isNaN(n));
};

const handleCreate = () => {
  formState.id = undefined;
  formState.name = '';
  formState.categoryId = props.categoryId || (categoryTreeData.value[0] as any)?.id;
  formState.description = '';
  formState.requiresLogin = false;
  formState.limitOnePerUser = false;
  formState.viewRoleIdsList = [];
  formState.fillRoleIdsList = [];
  formState.manageRoleIdsList = [];
  dialogTitle.value = '新建表单';
  dialogVisible.value = true;
};

const handleEdit = (record: FormDefinition) => {
  formState.id = record.id;
  formState.name = record.name;
  formState.categoryId = record.categoryId;
  formState.description = record.description;
  formState.requiresLogin = !!record.requiresLogin;
  formState.limitOnePerUser = !!record.limitOnePerUser;
  formState.viewRoleIdsList = parseRoleIds(record.viewRoleIds);
  formState.fillRoleIdsList = parseRoleIds(record.fillRoleIds);
  formState.manageRoleIdsList = parseRoleIds(record.manageRoleIds);
  dialogTitle.value = '编辑表单';
  dialogVisible.value = true;
};

const handleDesign = (record: FormDefinition) => {
  // Open designer
  emit('open-designer', record);
};

const handleDelete = async (id: number) => {
  await deleteForm(id);
  message.success('删除成功');
  loadData();
};

const handleDialogOk = async () => {
  if (!formState.name) {
    message.warning('请输入表单名称');
    return;
  }
  if (!formState.categoryId) {
    message.warning('请选择分类');
    return;
  }
  
  confirmLoading.value = true;
  try {
    const dataToSave = {
      ...formState,
      viewRoleIds: formState.viewRoleIdsList.length > 0 ? formState.viewRoleIdsList.join(',') : undefined,
      fillRoleIds: formState.fillRoleIdsList.length > 0 ? formState.fillRoleIdsList.join(',') : undefined,
      manageRoleIds: formState.manageRoleIdsList.length > 0 ? formState.manageRoleIdsList.join(',') : undefined
    };

    if (formState.id) {
      await updateForm(formState.id, dataToSave);
    } else {
      await createForm(dataToSave);
    }
    message.success('保存成功');
    dialogVisible.value = false;
    loadData();
  } catch (e) {
    // error
  } finally {
    confirmLoading.value = false;
  }
};

const handlePublish = async (record: FormDefinition) => {
  await updateForm(record.id!, {
    ...record,
    isPublished: true
  });
  message.success('发布成功');
  loadData();
  handleViewLink({ ...record, isPublished: true });
};

const handleUnpublish = async (record: FormDefinition) => {
  await updateForm(record.id!, {
    ...record,
    isPublished: false
  });
  message.success('已取消发布');
  loadData();
};

const handleViewLink = (record: FormDefinition) => {
  const routeData = router.resolve({
    name: 'FormSubmit',
    params: { id: record.id }
  });
  publishUrl.value = `${window.location.origin}${routeData.href}`; 
  linkModalVisible.value = true;
};

const copyLink = () => {
  navigator.clipboard.writeText(publishUrl.value);
  message.success('链接已复制');
};

watch(() => props.categoryId, (val) => {
  queryParams.categoryId = val;
  handleSearch();
});

onMounted(() => {
  loadData();
  loadCategories();
  loadRoles();
});
</script>

<style scoped>
.form-list-container {
  padding: 16px;
  background: #fff;
  height: 100%;
  display: flex;
  flex-direction: column;
}

.list-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.category-title {
  font-size: 18px;
  font-weight: 600;
}

.list-content {
  flex: 1;
  overflow: hidden;
}

.data-view-container {
  height: 100%;
  display: flex;
  flex-direction: column;
  padding: 16px;
}

.toolbar {
  flex-shrink: 0;
  margin-bottom: 16px;
  text-align: right;
}

.table-wrapper {
  flex: 1;
  overflow: hidden;
}

.pagination-wrapper {
  flex-shrink: 0;
  margin-top: 16px;
  text-align: right;
}
</style>
