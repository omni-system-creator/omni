<template>
  <div class="page-container">
    <a-card :bordered="false" class="table-card">
      
      <div class="content-wrapper" ref="contentWrapperRef" :style="{ '--table-scroll-y': `${tableScrollY}px` }">
        <smart-table
          table-key="contract-track-list"
          :columns="columns"
          :data-source="paginatedContracts"
          :pagination="false"
          :loading="loading"
          row-key="id"
          :scroll="{ x: 'max-content', y: tableScrollY }"
        >
          <template #toolbar>
            <div style="display: flex; justify-content: space-between; align-items: center; padding-right: 16px;">
              <a-segmented v-model:value="expiryFilter" :options="expiryOptions" @change="handleExpiryChange" />
              <a-space>
                <a-button type="primary" @click="handleCreate">
                  <template #icon><plus-outlined /></template>
                  新建合同
                </a-button>
                <a-popover v-model:open="searchVisible" trigger="click" placement="bottomRight">
                  <template #content>
                    <div style="width: 700px; padding: 8px;">
                      <a-form layout="vertical">
                        <a-row :gutter="16">
                          <a-col :span="12">
                            <a-form-item label="关键词">
                              <a-input v-model:value="searchParams.keyword" placeholder="合同名称/编号/对方单位" allow-clear />
                            </a-form-item>
                          </a-col>
                          <a-col :span="12">
                            <a-form-item label="合同编号">
                              <a-input v-model:value="searchParams.contractNo" placeholder="请输入合同编号" allow-clear />
                            </a-form-item>
                          </a-col>
                          <a-col :span="12">
                            <a-form-item label="对方单位">
                              <a-input v-model:value="searchParams.partnerName" placeholder="请输入对方单位" allow-clear />
                            </a-form-item>
                          </a-col>
                          <a-col :span="12">
                            <a-form-item label="经办人">
                              <a-input v-model:value="searchParams.manager" placeholder="请输入经办人" allow-clear />
                            </a-form-item>
                          </a-col>
                          <a-col :span="12">
                            <a-form-item label="合同类型">
                              <a-select v-model:value="searchParams.type" placeholder="请选择" allow-clear>
                                <a-select-option v-for="item in directionOptions" :key="item.value" :value="item.value">{{ item.label }}</a-select-option>
                              </a-select>
                            </a-form-item>
                          </a-col>
                          <a-col :span="12">
                            <a-form-item label="计价方式">
                              <a-select v-model:value="searchParams.pricingType" placeholder="请选择" allow-clear>
                                <a-select-option v-for="item in pricingTypeOptions" :key="item.value" :value="item.value">{{ item.label }}</a-select-option>
                              </a-select>
                            </a-form-item>
                          </a-col>
                          <a-col :span="12">
                            <a-form-item label="合同状态">
                              <a-select v-model:value="searchParams.lifecycleStatus" placeholder="请选择" allow-clear>
                                <a-select-option v-for="item in lifecycleStatusOptions" :key="item.value" :value="item.value">{{ item.label }}</a-select-option>
                              </a-select>
                            </a-form-item>
                          </a-col>
                          <a-col :span="12">
                            <a-form-item label="履约状态">
                              <a-select v-model:value="searchParams.performanceStatus" placeholder="请选择" allow-clear>
                                <a-select-option v-for="item in performanceStatusOptions" :key="item.value" :value="item.value">{{ item.label }}</a-select-option>
                              </a-select>
                            </a-form-item>
                          </a-col>
                          <a-col :span="12">
                            <a-form-item label="付款方式">
                                <a-input v-model:value="searchParams.paymentMethod" placeholder="请输入付款方式" allow-clear />
                            </a-form-item>
                          </a-col>
                          <a-col :span="12">
                            <a-form-item label="合同总金额">
                              <div style="display: flex; align-items: center">
                                <a-input-number v-model:value="searchParams.totalAmountMin" placeholder="最小" style="width: 100%" :min="0" />
                                <span style="padding: 0 4px">-</span>
                                <a-input-number v-model:value="searchParams.totalAmountMax" placeholder="最大" style="width: 100%" :min="0" />
                              </div>
                            </a-form-item>
                          </a-col>
                          <a-col :span="12">
                            <a-form-item label="签订日期">
                              <a-range-picker v-model:value="signDateRange" style="width: 100%" />
                            </a-form-item>
                          </a-col>
                          <a-col :span="12">
                            <a-form-item label="开始日期">
                              <a-range-picker v-model:value="startDateRange" style="width: 100%" />
                            </a-form-item>
                          </a-col>
                          <a-col :span="12">
                            <a-form-item label="结束日期">
                              <a-range-picker v-model:value="endDateRange" style="width: 100%" />
                            </a-form-item>
                          </a-col>
                        </a-row>
                      </a-form>
                      <div style="text-align: right; margin-top: 16px; border-top: 1px solid #f0f0f0; padding-top: 16px;">
                        <a-space>
                          <a-button @click="resetSearch">重置</a-button>
                          <a-button type="primary" @click="handleSearch">查询</a-button>
                        </a-space>
                      </div>
                    </div>
                  </template>
                  <a-button :type="searchVisible ? 'primary' : 'default'" :ghost="searchVisible">
                    <template #icon><filter-outlined /></template>
                    筛选
                  </a-button>
                </a-popover>
                <a-button :loading="exportLoading" @click="handleExport">
                  <template #icon><export-outlined /></template>
                  导出报表
                </a-button>
              </a-space>
            </div>
          </template>
          <template #bodyCell="{ column, record, index }">
            <template v-if="column.key === 'index'">
              {{ ((pagination.current || 1) - 1) * (pagination.pageSize || 10) + index + 1 }}
            </template>
            <template v-else-if="column.key === 'contractName'">
              <a-tooltip :title="record.contractName" placement="topLeft">
                <div style="overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                  {{ record.contractName }}
                </div>
              </a-tooltip>
            </template>
            <template v-else-if="column.key === 'partnerName'">
              <a-tooltip :title="record.partnerName" placement="topLeft">
                <div style="overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                  {{ record.partnerName }}
                </div>
              </a-tooltip>
            </template>
            <template v-else-if="column.key === 'totalAmount'">
              {{ formatAmount(record.totalAmount) }}
            </template>
            <template v-else-if="column.key === 'direction'">
              <a-tag :color="getDirectionColor(record.type)">
                {{ getDirectionText(record.type) }}
              </a-tag>
            </template>
            <template v-else-if="column.key === 'pricingType'">
              <a-tag :color="getPricingTypeColor(record as any)">
                {{ getPricingTypeText(record as any) }}
              </a-tag>
            </template>
            <template v-else-if="column.key === 'signStatus'">
              <a-tag :color="getSignStatusColor(record as any)">
                {{ getSignStatusText(record as any) }}
              </a-tag>
            </template>
            <template v-else-if="column.key === 'performanceStatus'">
              <a-tag :color="getPerformanceStatusColor(record.status)">
                {{ getPerformanceStatusText(record.status) }}
              </a-tag>
            </template>
            <template v-else-if="column.key === 'validityPeriod'">
              {{ formatValidityPeriod(record) }}
            </template>
            <template v-else-if="column.key === 'manager'">
              <a-tooltip :title="getManagerDisplay(record.manager)" placement="topLeft">
                <div style="overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                  {{ getManagerDisplay(record.manager) || '-' }}
                </div>
              </a-tooltip>
            </template>
            <template v-else-if="column.key === 'signDate'">
              {{ record.signDate ? record.signDate.split('T')[0] : '-' }}
            </template>
            <template v-else-if="column.key === 'action'">
              <a-space>
                <a-tooltip title="查看">
                  <a-button type="text" size="small" @click="handleView(record.id)">
                    <template #icon><eye-outlined /></template>
                  </a-button>
                </a-tooltip>
                <a-tooltip title="编辑">
                  <a-button type="text" size="small" @click="handleEdit(record)">
                    <template #icon><edit-outlined /></template>
                  </a-button>
                </a-tooltip>
                <a-popconfirm title="确定要删除吗？" @confirm="handleDelete(record.id)">
                  <a-tooltip title="删除">
                    <a-button type="text" danger size="small">
                      <template #icon><delete-outlined /></template>
                    </a-button>
                  </a-tooltip>
                </a-popconfirm>
              </a-space>
            </template>
          </template>
        </smart-table>
      </div>
      <div class="pagination-footer">
        <a-pagination
          v-model:current="pagination.current"
          v-model:pageSize="pagination.pageSize"
          :total="pagination.total"
          :show-size-changer="pagination.showSizeChanger"
          :show-quick-jumper="pagination.showQuickJumper"
          :show-total="pagination.showTotal"
        />
      </div>
    </a-card>

    <a-drawer
      :title="currentId ? '编辑合同' : '新建合同'"
      :width="720"
      :open="drawerVisible"
      :body-style="{ paddingBottom: '80px' }"
      @close="onClose"
    >
      <contract-form
        ref="contractFormRef"
        :is-edit="!!currentId"
      />
      <template #footer>
        <a-space style="float: right">
          <a-button @click="onClose">取消</a-button>
          <a-button type="primary" :loading="submitting" @click="onSubmit">提交</a-button>
        </a-space>
      </template>
    </a-drawer>

    <contract-detail
      v-model:open="viewDrawerVisible"
      :contract-data="viewContractData"
      @refresh="handleDetailRefresh"
      @open-contract="handleOpenRelatedFromDetail"
    />
  </div>
</template>

<script lang="ts" setup>
import { ref, reactive, onMounted, computed, nextTick, watch, onUnmounted } from 'vue';
import { ExportOutlined, PlusOutlined, EditOutlined, DeleteOutlined, EyeOutlined, FilterOutlined } from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import dayjs from 'dayjs';
import ContractForm from './ContractForm.vue';
import ContractDetail from './components/ContractDetail.vue';
import SmartTable from '@/components/SmartTable/index.vue';
import { createContract, updateContract, deleteContract, getContracts, getContractById, exportContracts } from '@/api/contract';
import { getDictDataByCode, type DictDataDto } from '@/api/dict';
import { getUserList, type UserListDto } from '@/api/user';
import { getDeptTree, type Dept } from '@/api/dept';
import { useUserStore } from '@/stores/user';
import type { CreateContractDto, ContractDto, ContractDetailDto, ContractQueryDto } from '@/api/contract';
import type { TablePaginationConfig, ColumnType } from 'ant-design-vue/es/table/interface';

const contentWrapperRef = ref<HTMLDivElement>();
const tableScrollY = ref(500);

const updateTableHeight = () => {
  if (contentWrapperRef.value) {
    const height = contentWrapperRef.value.clientHeight;
    // 减去 SmartTable toolbar (32px + 16px padding) 和 表头高度 (~55px)
    tableScrollY.value = height - 103;
  }
};

const resizeObserver = new ResizeObserver(() => {
  updateTableHeight();
});

onMounted(() => {
  if (contentWrapperRef.value) {
    resizeObserver.observe(contentWrapperRef.value);
    updateTableHeight();
  }
  loadDicts();
  fetchContracts();
});

onUnmounted(() => {
  resizeObserver.disconnect();
});

const expiryFilter = ref('all');
const searchVisible = ref(false);
const searchParams = reactive<ContractQueryDto>({});
const signDateRange = ref<[dayjs.Dayjs, dayjs.Dayjs]>();
const startDateRange = ref<[dayjs.Dayjs, dayjs.Dayjs]>();

const endDateRange = ref<[dayjs.Dayjs, dayjs.Dayjs]>();
watch(signDateRange, (val) => {
  if (val) {
    searchParams.signDateStart = val[0].format('YYYY-MM-DD');
    searchParams.signDateEnd = val[1].format('YYYY-MM-DD');
  } else {
    searchParams.signDateStart = undefined;
    searchParams.signDateEnd = undefined;
  }
});

watch(startDateRange, (val) => {
  if (val) {
    searchParams.startDateStart = val[0].format('YYYY-MM-DD');
    searchParams.startDateEnd = val[1].format('YYYY-MM-DD');
  } else {
    searchParams.startDateStart = undefined;
    searchParams.startDateEnd = undefined;
  }
});

watch(endDateRange, (val) => {
  if (val) {
    searchParams.endDateStart = val[0].format('YYYY-MM-DD');
    searchParams.endDateEnd = val[1].format('YYYY-MM-DD');
  } else {
    searchParams.endDateStart = undefined;
    searchParams.endDateEnd = undefined;
  }
});

const handleSearch = () => {
  searchVisible.value = false;
  fetchContracts();
};

const resetSearch = () => {
  Object.keys(searchParams).forEach(key => delete (searchParams as any)[key]);
  signDateRange.value = undefined;
  startDateRange.value = undefined;
  endDateRange.value = undefined;
  fetchContracts();
};

const expiryOptions = [
  { label: '全部', value: 'all' },
  { label: '未到期', value: 'notExpired' },
  { label: '7日内到期', value: 'within7' },
  { label: '已到期', value: 'expired' }
];

const loading = ref(false);
const userStore = useUserStore();
const contracts = ref<ContractDto[]>([]);
const managerDisplayMap = ref<Record<string, { name: string; organization: string }>>({});
const cachedDeptTree = ref<Dept[]>([]);

const pagination = reactive<TablePaginationConfig>({
  total: 0,
  current: 1,
  pageSize: 10,
  showSizeChanger: true,
  showQuickJumper: true,
  showTotal: total => `共 ${total} 条`
});

const directionOptions = ref<DictDataDto[]>([]);
const pricingTypeOptions = ref<DictDataDto[]>([]);
const lifecycleStatusOptions = ref<DictDataDto[]>([]);
const performanceStatusOptions = ref<DictDataDto[]>([]);

const loadDicts = async () => {
  try {
    const [direction, pricing, lifecycle, performance] = await Promise.all([
      getDictDataByCode('contract_direction'),
      getDictDataByCode('contract_pricing_type'),
      getDictDataByCode('contract_status'),
      getDictDataByCode('contract_performance_status')
    ]);
    directionOptions.value = direction || [];
    pricingTypeOptions.value = pricing || [];
    lifecycleStatusOptions.value = lifecycle || [];
    performanceStatusOptions.value = performance || [];
  } catch (e) {
    console.error('Load dicts error:', e);
  }
};

const formatAmount = (amount: number) => {
  return amount.toLocaleString('zh-CN', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
};

const getDirectionText = (type: string) => {
  const opt = directionOptions.value.find(x => x.value === type);
  if (opt) return opt.label;
  return '未知';
};

const getDirectionColor = (type: string) => {
  const opt = directionOptions.value.find(x => x.value === type);
  if (opt && opt.listClass) return opt.listClass;
  
  return 'default';
};

const getPricingTypeText = (record: ContractDto) => {
  const opt = pricingTypeOptions.value.find(x => x.value === record.pricingType);
  if (opt) return opt.label;
  
  return '未知';
};

const getPricingTypeColor = (record: ContractDto) => {
  const opt = pricingTypeOptions.value.find(x => x.value === record.pricingType);
  if (opt && opt.listClass) return opt.listClass;

  return 'cyan';
};

const getSignStatusText = (record: ContractDto) => {
  const opt = lifecycleStatusOptions.value.find(x => x.value === record.lifecycleStatus);
  if (opt) return opt.label;

  
  // Fallback for compatibility
  if (!record.signDate) return '草稿';
  return record.lifecycleStatus || '未知';
};

const getSignStatusColor = (record: ContractDto) => {
  const opt = lifecycleStatusOptions.value.find(x => x.value === record.lifecycleStatus);
  if (opt && opt.listClass) return opt.listClass;
  return 'default';
};

const getPerformanceStatusText = (status: string) => {
  const opt = performanceStatusOptions.value.find(x => x.value === status);
  if (opt) return opt.label;

  return '未知';
};

const getPerformanceStatusColor = (status: string) => {
  const opt = performanceStatusOptions.value.find(x => x.value === status);
  if (opt && opt.listClass) return opt.listClass;
  return 'default';
};

const formatValidityPeriod = (record: ContractDto) => {
  if (!record.startDate && !record.endDate) return '无';
  const start = record.startDate ? record.startDate.split('T')[0] : '-';
  const end = record.endDate ? record.endDate.split('T')[0] : '-';
  return `${start} 至 ${end}`;
};

const getDeptFullPath = (depts: Dept[], id: number): string | null => {
  for (const dept of depts) {
    if (dept.id === id) {
      return dept.name;
    }
    if (dept.children) {
      const childPath = getDeptFullPath(dept.children, id);
      if (childPath) {
        return `${dept.name}-${childPath}`;
      }
    }
  }
  return null;
};

const getRootOrgName = (deptId: number): string => {
  if (!deptId || cachedDeptTree.value.length === 0) return '';
  const fullPath = getDeptFullPath(cachedDeptTree.value, deptId);
  if (!fullPath) return '';
  const parts = fullPath.split('-');
  return parts[0] || '';
};

const fetchContracts = async () => {
  loading.value = true;
  try {
    const expiryStatus = expiryFilter.value === 'all' ? undefined : expiryFilter.value;
    const res = await getContracts({ ...searchParams, expiryStatus });
    contracts.value = res || [];
    const managers = Array.from(new Set((contracts.value || []).map(c => c.manager).filter(Boolean))) as string[];
    managerDisplayMap.value = {};
    if (managers.length > 0) {
      try {
        if (cachedDeptTree.value.length === 0) {
          const tree = await getDeptTree();
          cachedDeptTree.value = tree || [];
        }
        const users: UserListDto[] = await getUserList({ keyword: '' });
        managers.forEach(username => {
          const u = users.find(x => x.username === username);
          if (u) {
            const rootOrg = u.dept?.id ? getRootOrgName(u.dept.id) : '';
            managerDisplayMap.value[username] = {
              name: u.nickname || u.username,
              organization: rootOrg
            };
          }
        });
      } catch (e) {
        console.error(e);
      }
    }
    pagination.total = contracts.value.length;
  } catch (e) {
    console.error(e);
    message.error('加载合同数据失败');
  } finally {
    loading.value = false;
  }
};

const handleExpiryChange = () => {
  pagination.current = 1;
  fetchContracts();
};

const paginatedContracts = computed(() => {
  const current = pagination.current || 1;
  const pageSize = pagination.pageSize || 10;
  return contracts.value.slice((current - 1) * pageSize, current * pageSize);
});

const getManagerDisplay = (username?: string) => {
  if (!username) return '';
  const info = managerDisplayMap.value[username];
  if (!info) return username;
  const currentOrgName = userStore.currentOrg?.name;
  if (info.organization && currentOrgName && info.organization !== currentOrgName) {
    return `${info.name} (${info.organization})`;
  }
  return info.name;
};

const columns: ColumnType<ContractDto>[] = [
  {
    title: '序号',
    key: 'index',
    width: 60,
    align: 'center',
    fixed: 'left'
  },
  {
    title: '合同名称',
    dataIndex: 'contractName',
    key: 'contractName',
    ellipsis: true
  },
  {
    title: '客户/供应商',
    dataIndex: 'partnerName',
    key: 'partnerName',
    width: 200,
    ellipsis: true
  },
  {
    title: '合同总金额',
    dataIndex: 'totalAmount',
    key: 'totalAmount',
    align: 'right',
    width: 150,
    ellipsis: true
  },
  {
    title: '合同类型',
    key: 'direction',
    width: 150,
    align: 'center',
    ellipsis: true
  },
  {
    title: '合同编号',
    dataIndex: 'contractNo',
    key: 'contractNo',
    width: 180,
    ellipsis: true
  },
  {
    title: '负责人',
    dataIndex: 'manager',
    key: 'manager',
    width: 180,
    ellipsis: true
  },
  {
    title: '总价类型',
    key: 'pricingType',
    width: 180,
    align: 'center',
    ellipsis: true
  },
  {
    title: '签订日期',
    dataIndex: 'signDate',
    key: 'signDate',
    width: 150,
    align: 'center',
    ellipsis: true
  },
  {
    title: '状态',
    key: 'signStatus',
    width: 120,
    align: 'center',
    ellipsis: true
  },
  {
    title: '履约状态',
    key: 'performanceStatus',
    width: 120,
    align: 'center',
    ellipsis: true
  },
  {
    title: '有效期限',
    key: 'validityPeriod',
    width: 200,
    align: 'center',
    ellipsis: true
  },
  {
    title: '操作',
    key: 'action',
    fixed: 'right',
    width: 120,
    align: 'center'
  }
];

onMounted(() => {
  loadDicts();
  fetchContracts();
});

const drawerVisible = ref(false);
const submitting = ref(false);
const contractFormRef = ref();
const currentId = ref<number | undefined>(undefined);

// View drawer state
const viewDrawerVisible = ref(false);
const viewContractData = ref<ContractDetailDto | null>(null);

const handleView = async (id: number) => {
  try {
    const res = await getContractById(id);
    if (res) {
      viewContractData.value = res;
      viewDrawerVisible.value = true;
    }
  } catch (error) {
    console.error(error);
    message.error('获取合同详情失败');
  }
};

const handleOpenRelatedFromDetail = async (id: number) => {
  await handleView(id);
};

const handleDetailRefresh = async () => {
  if (!viewContractData.value?.id) return;
  try {
    const res = await getContractById(viewContractData.value.id);
    if (res) {
      viewContractData.value = res;
      fetchContracts();
    }
  } catch (error) {
    console.error(error);
    message.error('刷新合同详情失败');
  }
};

const exportLoading = ref(false);
const handleExport = async () => {
  exportLoading.value = true;
  try {
    const exportColumns = columns
      .filter(c => c.key !== 'index' && c.key !== 'action')
      .map(c => ({
        title: c.title as string,
        dataIndex: (c.dataIndex || c.key) as string
      }));
    
    const expiryStatus = expiryFilter.value === 'all' ? undefined : expiryFilter.value;
    const res = await exportContracts({
      ...searchParams,
      expiryStatus,
      columns: exportColumns
    });
    
    // Extract filename from headers
    let filename = `Contracts_${dayjs().format('YYYYMMDDHHmmss')}.xlsx`;
    const contentDisposition = (res as any).headers['content-disposition'];
    if (contentDisposition) {
      const filenameMatch = contentDisposition.match(/filename\*=UTF-8''(.+)/) || contentDisposition.match(/filename="?([^";]+)"?/);
      if (filenameMatch && filenameMatch[1]) {
        filename = decodeURIComponent(filenameMatch[1]);
      }
    }

    const url = window.URL.createObjectURL(new Blob([(res as any).data]));
    const link = document.createElement('a');
    link.href = url;
    link.setAttribute('download', filename);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    window.URL.revokeObjectURL(url);
  } catch (e) {
    console.error(e);
    message.error('导出失败');
  } finally {
    exportLoading.value = false;
  }
};

const handleCreate = () => {
  currentId.value = undefined;
  drawerVisible.value = true;
  nextTick(() => {
    if (contractFormRef.value) {
      contractFormRef.value.resetFields();
    }
  });
};

const handleEdit = async (record: any) => {
  currentId.value = record.id;
  drawerVisible.value = true;
  try {
    const detail = await getContractById(record.id);
    if (detail) {
      nextTick(() => {
        if (contractFormRef.value) {
          contractFormRef.value.setFormState(detail);
        }
      });
    }
  } catch (error) {
    console.error(error);
    message.error('获取合同详情失败');
  }
};

const handleDelete = async (id: number) => {
  try {
    await deleteContract(id);
    message.success('删除成功');
    fetchContracts();
  } catch (error) {
    console.error(error);
    message.error('删除失败');
  }
};

const onClose = () => {
  drawerVisible.value = false;
};

const onSubmit = () => {
  contractFormRef.value.validate().then(async () => {
    submitting.value = true;
    try {
      const formState = contractFormRef.value.getFormState();
      
      const dto: CreateContractDto = {
        contractNo: formState.contractNo,
        contractName: formState.contractName,
        type: formState.type,
        pricingType: formState.pricingType,
        lifecycleStatus: formState.lifecycleStatus,
        partnerName: formState.customer,
        partnerId: formState.partnerId,
        signDate: formState.signDate ? dayjs(formState.signDate).format('YYYY-MM-DD') : undefined,
        startDate: formState.period && formState.period[0] ? dayjs(formState.period[0]).format('YYYY-MM-DD') : undefined,
        endDate: formState.period && formState.period[1] ? dayjs(formState.period[1]).format('YYYY-MM-DD') : undefined,
        manager: formState.manager,
        totalAmount: formState.amount,
        currency: formState.currency,
        paymentMethod: formState.paymentMethod,
        description: formState.description,
      };

      if (currentId.value) {
        await updateContract(currentId.value, dto);
        message.success('更新成功');
      } else {
        // Use FormData for unified submission (simultaneous file upload)
        const formData = new FormData();
        Object.keys(dto).forEach(key => {
          const val = (dto as any)[key];
          if (val !== undefined && val !== null) {
             formData.append(key, String(val));
          }
        });

        // Append new files
        if ((formState as any).newUploadFiles && (formState as any).newUploadFiles.length > 0) {
          (formState as any).newUploadFiles.forEach((file: File) => {
            formData.append('files', file);
          });
        }

        await createContract(formData);
        message.success('创建成功');
      }
      
      drawerVisible.value = false;
      fetchContracts();
    } catch (error) {
      console.error(error);
      message.error(currentId.value ? '更新失败' : '创建失败');
    } finally {
      submitting.value = false;
    }
  }).catch((err: any) => {
    console.log('Validation failed:', err);
  });
};

</script>

<style scoped>
.page-container {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  height: 100%;
  padding: 16px;
}

.table-card {
  flex: 1;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

:deep(.ant-card-body) {
  flex: 1;
  overflow: hidden;
  padding: 0;
  display: flex;
  flex-direction: column;
}

:deep(.ant-card-head) {
  flex-shrink: 0;
  padding: 0 12px;
}

.pagination-footer {
  flex-shrink: 0;
  padding: 12px 16px;
  border-top: 1px solid #f0f0f0;
  display: flex;
  justify-content: flex-end;
  background: #fff;
}

.content-wrapper {
  flex: 1;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.content-wrapper :deep(.ant-table-body) {
  min-height: var(--table-scroll-y);
}

.content-wrapper :deep(.ant-tag) {
  margin-right: 0;
}
</style>
