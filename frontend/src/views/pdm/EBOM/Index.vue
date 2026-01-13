<template>
  <div class="ebom-container">
    <SplitLayout position="left" :initialWidth="280" :minWidth="220" :maxWidth="520">
      <template #sidebar>
        <a-card title="产品结构树" class="tree-card" :bordered="false">
          <template #extra>
            <a-tooltip title="新增产品">
              <a-button type="text" @click="openCreateProductModal">
                <template #icon><PlusOutlined /></template>
              </a-button>
            </a-tooltip>
          </template>
          <div class="card-tools">
            <a-input-search v-model:value="searchValue" style="margin-bottom: 8px" placeholder="搜索零部件" @change="onSearchChange" />
          </div>
          <div class="scroll-panel">
            <a-tree
              :tree-data="(treeData as any)"
              blockNode
              v-model:expanded-keys="expandedKeys"
              :auto-expand-parent="autoExpandParent"
              :selected-keys="selectedKeys"
              @expand="onExpand"
              @select="onSelect"
            >
              <template #title="{ title }">
                <a-tooltip placement="topLeft" :title="title">
                  <span class="tree-node-title" v-if="title.toLowerCase().indexOf(searchValue.toLowerCase()) > -1">
                      {{ title.substring(0, title.toLowerCase().indexOf(searchValue.toLowerCase())) }}
                      <span style="color: #f50">{{ title.substring(title.toLowerCase().indexOf(searchValue.toLowerCase()), title.toLowerCase().indexOf(searchValue.toLowerCase()) + searchValue.length) }}</span>
                      {{ title.substring(title.toLowerCase().indexOf(searchValue.toLowerCase()) + searchValue.length) }}
                  </span>
                  <span class="tree-node-title" v-else>{{ title }}</span>
                </a-tooltip>
              </template>
            </a-tree>
          </div>
        </a-card>
      </template>
      <template #main>
        <a-card title="零部件详情" class="detail-card" :bordered="false">
          <template #extra>
            <a-space>
              <a-button type="primary" @click="openCreateChildModal">新增子件</a-button>
              <a-dropdown>
                <template #overlay>
                  <a-menu>
                    <a-menu-item key="addToCompare" @click="handleAddToCompare">
                      加入对比
                    </a-menu-item>
                    <a-menu-item key="compare" @click="handleCompare">
                      开始对比 ({{ compareList.length }})
                    </a-menu-item>
                    <a-menu-item key="clearCompare" @click="handleClearCompare" v-if="compareList.length > 0">
                      清空对比
                    </a-menu-item>
                    <a-menu-divider />
                    <a-menu-item key="import" @click="handleImport">导入EBOM</a-menu-item>
                    <a-menu-item key="export" @click="handleExport">导出EBOM</a-menu-item>
                  </a-menu>
                </template>
                <a-button>
                  <template #icon><MoreOutlined /></template>
                </a-button>
              </a-dropdown>
            </a-space>
          </template>
          <div class="scroll-panel">
            <a-descriptions bordered size="small" style="margin-bottom: 24px">
              <template #title>
                <a-breadcrumb>
                  <a-breadcrumb-item v-for="(item, index) in breadcrumbs" :key="item.key">
                     <a-tooltip>
                        <template #title>
                            <div>编码: {{ item.key }}</div>
                            <div>名称: {{ item.title }}</div>
                            <div>版本: {{ item.version || '-' }}</div>
                        </template>
                        <span v-if="index === breadcrumbs.length - 1">{{ item.title }}</span>
                        <a v-else @click="handleBreadcrumbClick(item.key)">{{ item.title }}</a>
                     </a-tooltip>
                  </a-breadcrumb-item>
                </a-breadcrumb>
              </template>
              <template #extra>
                <a-space>
                  <a-button type="link" size="small" @click="handleEdit">
                    <template #icon><EditOutlined /></template>修改
                  </a-button>
                  <a-button type="link" size="small" danger @click="handleDelete">
                    <template #icon><DeleteOutlined /></template>删除
                  </a-button>
                </a-space>
              </template>
              <a-descriptions-item label="物料编码">{{ currentNode.key || '-' }}</a-descriptions-item>
              <a-descriptions-item label="物料名称">{{ currentNode.title || '-' }}</a-descriptions-item>
              <a-descriptions-item label="规格型号">{{ currentNode.spec || '-' }}</a-descriptions-item>
              <a-descriptions-item label="单位">{{ currentNode.unit || '-' }}</a-descriptions-item>
              <a-descriptions-item label="产品分类">{{ getProductTypeLabel(currentNode.productType) || '-' }}</a-descriptions-item>
              <a-descriptions-item label="版本">{{ currentNode.version || '-' }}</a-descriptions-item>
              <a-descriptions-item label="设计者">{{ currentNode.designer || '-' }}</a-descriptions-item>
              <a-descriptions-item label="状态"><a-badge status="processing" :text="currentNode.status || '设计中'" /></a-descriptions-item>
              <a-descriptions-item label="关联文档">
                <div v-if="currentNode.relatedDocuments && currentNode.relatedDocuments.length">
                  <div v-for="doc in currentNode.relatedDocuments" :key="doc.id">
                    <a :href="doc.path" target="_blank">{{ doc.name }}</a>
                  </div>
                </div>
                <span v-else>-</span>
              </a-descriptions-item>
            </a-descriptions>

            <a-table :columns="columns" :data-source="currentNodeChildren" :pagination="false" size="middle" childrenColumnName="none">
              <template #bodyCell="{ column, record, index }">
                <template v-if="column.key === 'index'">
                  {{ index + 1 }}
                </template>
                <template v-else-if="column.key === 'status'">
                  <a-tag :color="record.status === '已归档' ? 'green' : 'blue'">{{ record.status }}</a-tag>
                </template>
                <template v-else-if="column.key === 'qty'">
                   <a @click="openEditQty(record as EbomItemDto)">{{ record.qty }}</a>
                </template>
                <template v-else-if="column.key === 'action'">
                   <a-popconfirm
                      title="确定要移除该子件吗?"
                      ok-text="是"
                      cancel-text="否"
                      @confirm="handleRemoveChild(record as EbomItemDto)"
                    >
                      <a style="color: red;">移除</a>
                    </a-popconfirm>
                </template>
              </template>
            </a-table>
          </div>
        </a-card>
      </template>
    </SplitLayout>

    <!-- Create Product Modal -->
    <a-modal
      v-model:visible="createModalVisible"
      :title="createForm.parentId ? '新增子件' : '新增产品'"
      @ok="handleCreateProduct"
      :confirmLoading="createLoading"
      width="1000px"
    >
      <a-tabs v-if="createForm.parentId" v-model:activeKey="addChildTab">
        <a-tab-pane key="create" tab="新建子件" />
        <a-tab-pane key="select" tab="选择已有" />
      </a-tabs>

      <div v-if="addChildTab === 'select' && createForm.parentId" style="margin-top: 16px">
         <a-input-search
           v-model:value="searchKeyword"
           placeholder="输入编码或名称搜索"
           enter-button
           @search="handleSearch"
           style="margin-bottom: 16px"
         />
         <div style="margin-bottom: 16px; border: 1px solid #f0f0f0; border-radius: 2px;">
            <a-table
              :columns="searchColumns"
              :data-source="searchResults"
              size="small"
              childrenColumnName="none"
              :pagination="false"
              :row-selection="{ 
                  type: 'radio', 
                  selectedRowKeys: selectedExistingItem ? [selectedExistingItem] : [], 
                  onChange: onSelectSearchItem 
              }"
              rowKey="key"
              :scroll="{ y: 240 }"
              :locale="{ emptyText: searchKeyword ? '无搜索结果' : '请输入关键字搜索' }"
            />
         </div>
         <div style="display: flex; align-items: center;">
            <span style="margin-right: 8px;">数量: </span>
            <a-input-number v-model:value="addChildQty" :min="0.1" :step="1" style="width: 120px" />
         </div>
      </div>

      <a-form v-else :model="createForm" :label-col="{ span: 6 }" :wrapper-col="{ span: 18 }" style="margin-top: 16px">
        <a-row :gutter="24">
            <a-col :span="12">
                <a-form-item label="产品编码" required>
                    <a-input v-model:value="createForm.key" placeholder="例如: PRD-2024xxx" />
                </a-form-item>
            </a-col>
            <a-col :span="12">
                <a-form-item label="产品名称" required>
                    <a-input v-model:value="createForm.title" placeholder="请输入产品名称" />
                </a-form-item>
            </a-col>
            <a-col :span="12" v-if="createForm.parentId">
                <a-form-item label="数量" required>
                    <a-input-number v-model:value="createForm.qty" :min="0.01" :step="1" style="width: 100%" />
                </a-form-item>
            </a-col>
            <a-col :span="12">
                <a-form-item label="产品分类">
                <a-select v-model:value="createForm.productType" placeholder="请选择产品分类">
                    <a-select-option v-for="item in productTypeDict" :key="item.value" :value="item.value">
                    {{ item.label }}
                    </a-select-option>
                </a-select>
                </a-form-item>
            </a-col>
            <a-col :span="12">
                <a-form-item label="版本">
                <a-input v-model:value="createForm.version" />
                </a-form-item>
            </a-col>
            <a-col :span="12">
                <a-form-item label="设计者">
                <a-input v-model:value="createForm.designer" />
                </a-form-item>
            </a-col>
            <a-col :span="12">
                <a-form-item label="规格型号">
                <a-input v-model:value="createForm.spec" />
                </a-form-item>
            </a-col>
            <a-col :span="12">
                <a-form-item label="单位">
                <a-input v-model:value="createForm.unit" />
                </a-form-item>
            </a-col>
            <a-col :span="24">
                <a-form-item label="关联文档" :label-col="{ span: 3 }" :wrapper-col="{ span: 21 }">
                <a-upload
                    v-model:file-list="fileList"
                    :custom-request="customUploadRequest"
                    @change="handleUploadChange"
                    :multiple="true"
                >
                    <a-button>
                    <upload-outlined />
                    上传文档
                    </a-button>
                </a-upload>
                </a-form-item>
            </a-col>
        </a-row>
      </a-form>
    </a-modal>

    <!-- Edit Product Modal -->
    <a-modal
      v-model:visible="editModalVisible"
      title="编辑产品"
      @ok="handleUpdateProduct"
      :confirmLoading="editLoading"
    >
      <a-form :model="editForm" :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }">
        <a-form-item label="产品名称" required>
          <a-input v-model:value="editForm.title" placeholder="请输入产品名称" />
        </a-form-item>
        <a-form-item label="产品分类">
          <a-select v-model:value="editForm.productType" placeholder="请选择产品分类">
            <a-select-option v-for="item in productTypeDict" :key="item.value" :value="item.value">
              {{ item.label }}
            </a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="版本">
          <a-input v-model:value="editForm.version" />
        </a-form-item>
        <a-form-item label="设计者">
          <a-input v-model:value="editForm.designer" />
        </a-form-item>
        <a-form-item label="关联文档">
          <a-upload
            v-model:file-list="fileList"
            :custom-request="customUploadRequest"
            @change="handleUploadChange"
            :multiple="true"
          >
            <a-button>
              <upload-outlined />
              上传文档
            </a-button>
          </a-upload>
        </a-form-item>
        <a-form-item label="规格型号">
          <a-input v-model:value="editForm.spec" />
        </a-form-item>
        <a-form-item label="单位">
          <a-input v-model:value="editForm.unit" />
        </a-form-item>
        <a-form-item label="状态">
          <a-select v-model:value="editForm.status">
            <a-select-option value="设计中">设计中</a-select-option>
            <a-select-option value="已归档">已归档</a-select-option>
          </a-select>
        </a-form-item>
      </a-form>
    </a-modal>

    <!-- Edit Qty Modal -->
    <a-modal v-model:visible="editQtyModalVisible" title="修改数量" @ok="handleUpdateQty">
      <p>当前子件: {{ editingQtyItem?.childId }}</p>
      <a-input-number v-model:value="editQtyValue" :min="0.1" :step="1" style="width: 100%" />
    </a-modal>
    
    <!-- Compare Result Modal -->
    <a-modal v-model:visible="compareModalVisible" width="1200px" :footer="null" :wrap-class-name="wrapClassName">
      <template #title>
        <div style="width: 100%; cursor: move;" @mousedown="handleTitleMouseDown">BOM 差异对比</div>
      </template>
      <div v-if="compareResult">
        <div style="margin-bottom: 16px;">
            <a-alert :message="`共发现 ${compareResult.diffCount} 处差异`" type="info" show-icon />
        </div>
        <a-table :dataSource="compareResult.rows" :pagination="false" bordered size="middle" :scroll="{ x: 'max-content', y: 500 }">
            <a-table-column title="物料编码" dataIndex="Key" fixed="left" width="150" />
            <a-table-column title="物料名称" dataIndex="Title" fixed="left" width="150" />
            <a-table-column title="规格" dataIndex="Spec" width="120" />
            <a-table-column title="单位" dataIndex="Unit" width="80" />
            <a-table-column title="差异类型" dataIndex="DiffType" width="100">
                 <template #default="{ text }">
                    <a-tag :color="text === 'Common' ? 'green' : (text === 'Unique' ? 'red' : 'orange')">
                        {{ text === 'Common' ? '一致' : (text === 'Unique' ? '独有' : '差异') }}
                    </a-tag>
                 </template>
            </a-table-column>
            
            <a-table-column v-for="header in compareResult.headers" :key="header.id" width="180">
                <template #title>
                    <a-tooltip :title="header.name + ' (' + header.version + ')'">
                        <div style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                            {{ header.name }} ({{ header.version }})
                        </div>
                    </a-tooltip>
                </template>
                <template #default="{ record }">
                    <div v-if="record.Cells[header.id] && record.Cells[header.id].exists">
                        <div><span style="color: #888;">Qty:</span> <b>{{ record.Cells[header.id].qty }}</b></div>
                        <div v-if="record.Cells[header.id].version" style="color: #888; font-size: 12px;">Ver: {{ record.Cells[header.id].version }}</div>
                    </div>
                    <div v-else style="color: #ccc; text-align: center;">-</div>
                </template>
            </a-table-column>
        </a-table>
      </div>
    </a-modal>
    
    <!-- Hidden Import Input -->
    <input type="file" ref="importInput" style="display: none" accept=".xlsx, .xls" @change="onImportFileChange" />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, reactive, h } from 'vue';
import { message, Modal } from 'ant-design-vue';
import { PlusOutlined, EditOutlined, DeleteOutlined, ExclamationCircleOutlined, UploadOutlined, MoreOutlined } from '@ant-design/icons-vue';
import type { TreeProps, UploadChangeParam, UploadFile } from 'ant-design-vue';
import type { Key, ColumnType } from 'ant-design-vue/es/table/interface';
import SplitLayout from '@/components/SplitLayout/index.vue';
import { 
  getEbomTrees, initPdmData, createEbomItem, updateEbomItem, deleteEbomItem,
  type EbomItemDto, type CreateEbomItemDto, type UpdateEbomItemDto, type EbomDocumentDto,
  uploadEbomDocument,
  addChildItem,
  updateChildItemQty,
  removeChildItem,
  searchEbomItems,
  importEbom,
  exportEbom,
  compareEbom
} from '@/api/pdm';
import { getDictDataByCode, type DictDataDto } from '@/api/dict';
import { useDraggableModal } from '@/hooks/useDraggableModal';

const selectedKeys = ref<Key[]>([]);
const expandedKeys = ref<Key[]>([]);
const treeData = ref<EbomItemDto[]>([]);
const loading = ref(false);

// Search
const searchValue = ref('');
const autoExpandParent = ref(true);

const onExpand = (keys: Key[]) => {
  expandedKeys.value = keys;
  autoExpandParent.value = false;
};

const onSearchChange = (e: any) => {
    const value = e.target.value;
    if (!value) {
        // Optional: collapse all or restore default state
        return;
    }
    
    const expanded: Key[] = [];
    const filterExpandedKeys = (data: EbomItemDto[], val: string): boolean => {
        let anyChildMatch = false;
        for (const item of data) {
            let match = item.title.toLowerCase().includes(val.toLowerCase());
            let childMatch = false;
            if (item.children) {
                childMatch = filterExpandedKeys(item.children, val);
            }
            
            if (childMatch) {
                expanded.push(item.key);
                anyChildMatch = true;
            }
            
            if (match) {
                anyChildMatch = true;
            }
        }
        return anyChildMatch;
    };
    
    filterExpandedKeys(treeData.value, value);
    expandedKeys.value = expanded;
    autoExpandParent.value = true;
};

// Compare List
const compareList = ref<{ key: string, title: string, version: string }[]>([]);
const compareModalVisible = ref(false);
const compareResult = ref<any>(null);

const { wrapClassName, handleTitleMouseDown } = useDraggableModal(compareModalVisible);

// Common
const fileList = ref<UploadFile[]>([]);

// Add Child Logic
const addChildTab = ref('create');
const searchKeyword = ref('');
const searchResults = ref<EbomItemDto[]>([]);
const selectedExistingItem = ref<string | undefined>(undefined);
const addChildQty = ref(1);

const searchColumns = [
  { title: '#', key: 'index', width: 50, customRender: ({ index }: { index: number }) => index + 1 },
  { title: '编码', dataIndex: 'key', key: 'key', width: 200 },
  { title: '名称', dataIndex: 'title', key: 'title' },
  { title: '规格', dataIndex: 'spec', key: 'spec' },
  { title: '版本', dataIndex: 'version', key: 'version', width: 80 },
  { title: '设计者', dataIndex: 'designer', key: 'designer', width: 100 },
];

const onSelectSearchItem = (selectedRowKeys: Key[]) => {
    if (selectedRowKeys.length > 0) {
        selectedExistingItem.value = selectedRowKeys[0] as string;
    } else {
        selectedExistingItem.value = undefined;
    }
};

// Edit Qty Logic
const editQtyModalVisible = ref(false);
const editingQtyItem = ref<{ parentId: string, childId: string, qty: number } | null>(null);
const editQtyValue = ref(1);

// Import/Export
const importInput = ref<HTMLInputElement | null>(null);

// Create Product State
const createModalVisible = ref(false);
const createLoading = ref(false);
const productTypeDict = ref<DictDataDto[]>([]);
const createForm = reactive<CreateEbomItemDto>({
  key: '',
  title: '',
  spec: 'Standard',
  unit: 'PCS',
  productType: '',
  isLeaf: false,
  qty: 1,
  parentId: '',
  version: 'V1.0',
  designer: '工程师A',
  relatedDocuments: []
});

// Edit Product State
const editModalVisible = ref(false);
const editLoading = ref(false);
const editForm = reactive<UpdateEbomItemDto>({
  title: '',
  spec: '',
  unit: '',
  productType: '',
  status: '',
  version: '',
  designer: '',
  relatedDocuments: []
});

const loadDicts = async () => {
  try {
    const res = await getDictDataByCode('product_type');
    productTypeDict.value = res || [];
  } catch (error) {
    console.error('Failed to load dicts:', error);
  }
};

const loadData = async () => {
  loading.value = true;
  try {
    await initPdmData();
    const res = await getEbomTrees();
    treeData.value = res;
    
    // Expand root nodes by default if empty
    if (expandedKeys.value.length === 0) {
        expandedKeys.value = res.map(node => node.key);
    }
    
    // Select first node if nothing selected
    if (selectedKeys.value.length === 0 && res.length > 0 && res[0]) {
      selectedKeys.value = [res[0].key];
    }
  } finally {
    loading.value = false;
  }
};

onMounted(() => {
  loadData();
  loadDicts();
});

const getProductTypeLabel = (code?: string) => {
  if (!code) return '';
  const found = productTypeDict.value.find(d => d.value === code);
  return found ? found.label : code;
};

const getDefaultProductType = () => {
  const found = productTypeDict.value.find(d => d.isDefault);
  return found ? found.value : (productTypeDict.value.length > 0 ? productTypeDict.value[0]?.value : '');
};

const openCreateProductModal = () => {
  createForm.key = '';
  createForm.title = '';
  createForm.spec = 'Standard';
  createForm.unit = 'PCS';
  createForm.productType = getDefaultProductType() || '';
  createForm.isLeaf = false;
  createForm.parentId = ''; // Root item
  createForm.version = 'V1.0';
  createForm.designer = '工程师A';
  createForm.relatedDocuments = [];
  fileList.value = [];
  createModalVisible.value = true;
};

const customUploadRequest = async (options: any) => {
  const { file, onSuccess, onError } = options;
  try {
    const res = await uploadEbomDocument(file as File);
    onSuccess(res, file);
  } catch (err) {
    onError(err);
  }
};

const handleUploadChange = (info: UploadChangeParam) => {
  let resFileList = [...info.fileList];
  
  // Update file list with response data
  resFileList = resFileList.map(file => {
    if (file.response) {
      file.url = file.response.path; // Correct download url
    }
    return file;
  });

  fileList.value = resFileList;
};

const getDocumentsFromList = (): EbomDocumentDto[] => {
  return fileList.value.map(file => {
    if (file.originFileObj && file.response) {
        // Newly uploaded
        const resp = file.response as EbomDocumentDto; 
        return {
            id: resp.id,
            name: resp.name,
            path: resp.path,
            fileType: resp.fileType,
            size: resp.size,
            uploadedAt: resp.uploadedAt
        };
    } else {
        // Existing
        return {
            id: Number(file.uid),
            name: file.name,
            path: file.url || '',
            fileType: (file as any).type || file.name.split('.').pop() || '',
            size: file.size || 0,
            uploadedAt: new Date().toISOString()
        };
    }
  });
};

const openCreateChildModal = () => {
  if (!currentNode.value.key) return;
  
  if (currentNode.value.isLeaf) {
     message.warning('当前节点是零件/原材料，不能添加子件');
     return;
  }

  createForm.key = '';
  createForm.title = '';
  createForm.spec = '';
  createForm.unit = 'PCS';
  createForm.productType = getDefaultProductType() || '';
  createForm.isLeaf = true;
  createForm.parentId = currentNode.value.key;
  createForm.version = 'V1.0';
  createForm.designer = '工程师A';
  createForm.qty = 1;
  createForm.relatedDocuments = [];
  fileList.value = [];
  
  addChildTab.value = 'create';
  searchKeyword.value = '';
  searchResults.value = [];
  selectedExistingItem.value = undefined;
  addChildQty.value = 1;

  createModalVisible.value = true;
};

const handleImport = () => {
  importInput.value?.click();
};

const onImportFileChange = async (e: Event) => {
    const target = e.target as HTMLInputElement;
    if (target.files && target.files.length > 0) {
        const file = target.files[0];
        if (!file) return;
        try {
            message.loading({ content: '正在导入...', key: 'importProcess' });
            await importEbom(file);
            message.success({ content: '导入成功', key: 'importProcess' });
            loadData();
        } catch (error) {
            message.error({ content: '导入失败', key: 'importProcess' });
            console.error(error);
        } finally {
            target.value = '';
        }
    }
};

const handleExport = async () => {
    try {
        message.loading({ content: '正在导出...', key: 'exportProcess' });
        // Export current node tree if selected, otherwise all? 
        // Logic: if currentNode.value.key exists, export that tree.
        const rootId = currentNode.value?.key;
        
        const res = await exportEbom(rootId);
        // Ensure res is blob
        const blob = new Blob([res as any], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' });
        const url = window.URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = url;
        link.setAttribute('download', `EBOM_Export_${new Date().getTime()}.xlsx`);
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        window.URL.revokeObjectURL(url);
        message.success({ content: '导出成功', key: 'exportProcess' });
    } catch (error) {
        message.error({ content: '导出失败', key: 'exportProcess' });
        console.error(error);
    }
};

const handleAddToCompare = () => {
    if (!currentNode.value || !currentNode.value.key) {
        message.warning('请选择一个节点');
        return;
    }
    
    // Check duplication
    if (compareList.value.some(x => x.key === currentNode.value.key)) {
        message.warning('该节点已在对比列表中');
        return;
    }
    
    compareList.value.push({
        key: currentNode.value.key,
        title: currentNode.value.title,
        version: currentNode.value.version
    });
    message.success(`已加入对比列表，当前数量: ${compareList.value.length}`);
};

const handleClearCompare = () => {
    compareList.value = [];
    message.success('已清空对比列表');
};

const handleCompare = async () => {
   if (compareList.value.length < 2) {
       message.warning('请至少选择两个项目进行对比');
       return;
   }
   
   try {
       const ids = compareList.value.map(x => x.key);
       const res = await compareEbom(ids);
       compareResult.value = res;
       compareModalVisible.value = true;
   } catch (error) {
       console.error(error);
   }
};

const handleSearch = async () => {
    if (!searchKeyword.value) return;
    try {
        const res = await searchEbomItems(searchKeyword.value, currentNode.value.key || '');
        searchResults.value = res;
    } catch (e) {
        console.error(e);
    }
};

const handleCreateProduct = async () => {
  createLoading.value = true;
  try {
    if (createForm.parentId && addChildTab.value === 'select') {
        // Add existing
        if (!selectedExistingItem.value) {
            message.warning('请选择一个部件');
            createLoading.value = false;
            return;
        }
        await addChildItem({
            parentId: createForm.parentId,
            childId: selectedExistingItem.value,
            qty: addChildQty.value
        });
        message.success('添加子件成功');
    } else {
        if (!createForm.key || !createForm.title) {
             message.warning('请输入产品编码和名称');
             createLoading.value = false;
             return;
        }
        const docs = getDocumentsFromList();
        createForm.relatedDocuments = docs;
        await createEbomItem(createForm);
        message.success(createForm.parentId ? '新增子件成功' : '新增产品成功');
    }

    createModalVisible.value = false;

    loadData();
  } catch (error) {
    console.error(error);
  } finally {
    createLoading.value = false;
  }
};

const openEditQty = (record: EbomItemDto) => {
    if (!currentNode.value.key) return;
    editingQtyItem.value = {
        parentId: currentNode.value.key,
        childId: record.key,
        qty: record.qty
    };
    editQtyValue.value = record.qty;
    editQtyModalVisible.value = true;
};

const handleUpdateQty = async () => {
    if (!editingQtyItem.value) return;
    try {
        await updateChildItemQty(editingQtyItem.value.parentId, editingQtyItem.value.childId, editQtyValue.value);
        message.success('更新数量成功');
        editQtyModalVisible.value = false;
        loadData();
    } catch (e) {
        console.error(e);
    }
};

const handleRemoveChild = async (record: EbomItemDto) => {
    if (!currentNode.value.key) return;
    try {
        await removeChildItem(currentNode.value.key, record.key);
        message.success('移除子件成功');
        loadData();
    } catch (e) {
        console.error(e);
    }
};

const handleEdit = () => {
  if (!currentNode.value || !currentNode.value.key) {
    message.warning('请选择一个节点');
    return;
  }
  
  editForm.title = currentNode.value.title;
  editForm.spec = currentNode.value.spec || '';
  editForm.unit = currentNode.value.unit || '';
  editForm.productType = currentNode.value.productType || '';
  editForm.status = currentNode.value.status || '设计中';
  editForm.version = currentNode.value.version || '';
  editForm.designer = currentNode.value.designer || '';
  
  // Populate file list
  fileList.value = currentNode.value.relatedDocuments?.map((doc: EbomDocumentDto) => ({
    uid: String(doc.id),
    name: doc.name,
    status: 'done',
    url: doc.path,
    size: doc.size,
    type: doc.fileType
  })) || [];
  
  editModalVisible.value = true;
};

const handleUpdateProduct = async () => {
  if (!currentNode.value || !currentNode.value.key) return;
  
  if (!editForm.title) {
    message.warning('请输入产品名称');
    return;
  }
  
  editLoading.value = true;
  try {
    editForm.relatedDocuments = getDocumentsFromList();
    await updateEbomItem(currentNode.value.key, editForm);
    message.success('更新成功');
    editModalVisible.value = false;
    loadData();
  } catch (error) {
    console.error(error);
  } finally {
    editLoading.value = false;
  }
};

const handleDelete = () => {
  if (!currentNode.value || !currentNode.value.key) {
    message.warning('请选择一个节点');
    return;
  }

  Modal.confirm({
    title: '确认删除',
    icon: () => h(ExclamationCircleOutlined),
    content: `确定要删除 "${currentNode.value.title}" 吗？如果该节点包含子节点，删除将失败。`,
    okText: '确认',
    cancelText: '取消',
    onOk: async () => {
      try {
        await deleteEbomItem(currentNode.value.key);
        message.success('删除成功');
        selectedKeys.value = []; // Clear selection
        loadData();
      } catch (error) {
        console.error(error);
      }
    }
  });
};

const columns: ColumnType[] = [
  { title: '序号', key: 'index', width: 60, align: 'center' },
  { title: '物料编码', dataIndex: 'key', key: 'key', width: 150, customRender: ({ text, record }: { text: string, record: any }) => {
      return h('a', {
          onClick: () => {
              selectedKeys.value = [record.key];
              // Ensure parent is expanded
              if (selectedKeys.value.length > 0) {
                 expandedKeys.value = [...expandedKeys.value, currentNode.value.key];
              }
          }
      }, text);
  }},
  { title: '物料名称', dataIndex: 'title', key: 'title' },
  { title: '规格型号', dataIndex: 'spec', key: 'spec' },
  { title: '版本', dataIndex: 'version', key: 'version', width: 80 },
  { title: '数量', dataIndex: 'qty', key: 'qty', width: 80 },
  { title: '单位', dataIndex: 'unit', key: 'unit', width: 80 },
  { title: '状态', dataIndex: 'status', key: 'status', width: 100 },
  { title: '操作', key: 'action', width: 100 }
];

const flattenData = (data: any[]): any[] => {
  let result: any[] = [];
  data.forEach(item => {
    result.push(item);
    if (item.children) {
      result = result.concat(flattenData(item.children));
    }
  });
  return result;
};

const allNodes = computed(() => flattenData(treeData.value));

const currentNode = computed(() => {
  const key = selectedKeys.value[0];
  if (!key && treeData.value.length > 0) return treeData.value[0];
  return allNodes.value.find(item => item.key === key) || (treeData.value.length > 0 ? treeData.value[0] : {});
});

const currentNodeChildren = computed(() => {
  const node = currentNode.value;
  if (!node || !node.children) return [];
  return node.children;
});

const onSelect: TreeProps['onSelect'] = (keys, _info) => {
  if (keys.length > 0) {
    selectedKeys.value = keys;
  }
};

const breadcrumbs = computed(() => {
    const key = selectedKeys.value[0];
    if (!key) return [];
    
    const path: any[] = [];
    const findPath = (data: any[], targetKey: string, currentPath: any[]): boolean => {
        for (const item of data) {
            const newPath = [...currentPath, { key: item.key, title: item.title, version: item.version }];
            if (item.key === targetKey) {
                path.push(...newPath);
                return true;
            }
            if (item.children && findPath(item.children, targetKey, newPath)) {
                return true;
            }
        }
        return false;
    };
    
    findPath(treeData.value, key as string, []);
    return path;
});

const handleBreadcrumbClick = (key: string) => {
    selectedKeys.value = [key];
};
</script>

<style scoped>
.ebom-container {
  padding: 10px;
  flex: 1;
  overflow: hidden;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
}
.ebom-container :deep(.split-layout) {
  flex: 1;
  width: 100%;
  height: 100%;
  overflow: hidden;
}
.tree-card {
  height: 100%;
  display: flex;
  flex-direction: column;
}
.tree-card :deep(.ant-card-head) {
  padding-right: 12px;
}
.tree-card :deep(.ant-card-body) {
  flex: 1;
  min-height: 0;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  padding: 16px 0 0 16px;
}
.detail-card {
  height: 100%;
  display: flex;
  flex-direction: column;
}
.detail-card :deep(.ant-card-head) {
  padding-right: 10px;
}
.detail-card :deep(.ant-card-body) {
  flex: 1;
  min-height: 0;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  padding: 16px 0 0 16px;
}
.scroll-panel {
  flex: 1;
  min-height: 0;
  overflow: auto;
  overflow-x: hidden;
}
.card-tools {
  padding-right: 16px;
}
.tree-node-title {
  display: inline-block;
  width: 100%;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  vertical-align: bottom;
}
.tree-card :deep(.ant-tree.ant-tree-block-node .ant-tree-list-holder-inner .ant-tree-node-content-wrapper) {
  overflow: hidden;
}
</style>
