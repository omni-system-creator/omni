<template>
  <div class="page-container">
    <a-card :bordered="false" class="table-card">
      
      <div class="content-wrapper">
        <smart-table
          table-key="contract-track-list"
          :columns="columns"
          :data-source="paginatedContracts"
          :pagination="false"
          :loading="loading"
          row-key="id"
          :scroll="{ x: 'max-content', y: 500 }"
        >
          <template #toolbar>
            <div style="display: flex; justify-content: space-between; align-items: center; padding-right: 16px;">
              <a-segmented v-model:value="expiryFilter" :options="expiryOptions" @change="handleExpiryChange" />
              <a-space>
                <a-button type="primary" @click="handleCreate">
                  <template #icon><plus-outlined /></template>
                  新建合同
                </a-button>
                <a-button>
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
            <template v-else-if="column.key === 'endDate'">
              {{ record.endDate ? record.endDate.split('T')[0] : '-' }}
            </template>
            <template v-else-if="column.key === 'manager'">
              {{ getManagerDisplay(record.manager) || '-' }}
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
      :visible="drawerVisible"
      :body-style="{ paddingBottom: '80px' }"
      @close="onClose"
    >
      <contract-form
        ref="contractFormRef"
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
import { ref, reactive, onMounted, computed, nextTick } from 'vue';
import { ExportOutlined, PlusOutlined, EditOutlined, DeleteOutlined, EyeOutlined } from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import dayjs from 'dayjs';
import ContractForm from './ContractForm.vue';
import ContractDetail from './components/ContractDetail.vue';
import SmartTable from '@/components/SmartTable/index.vue';
import { createContract, updateContract, deleteContract, getContracts, getContractById } from '@/api/contract';
import { getUserList, type UserListDto } from '@/api/user';
import { getDeptTree, type Dept } from '@/api/dept';
import { useUserStore } from '@/stores/user';
import type { CreateContractDto, ContractDto, ContractDetailDto } from '@/api/contract';
import type { TablePaginationConfig, ColumnType } from 'ant-design-vue/es/table/interface';

const expiryFilter = ref('all');
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

const formatAmount = (amount: number) => {
  return amount.toLocaleString('zh-CN', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
};

const getDirectionText = (type: string) => {
  if (type === 'sales') return '收款合同';
  if (type === 'purchase') return '付款合同';
  return '其他';
};

const getDirectionColor = (type: string) => {
  if (type === 'sales') return 'blue';
  if (type === 'purchase') return 'orange';
  return 'default';
};

const getPricingTypeText = (record: ContractDto) => {
  if (record.pricingType === 'fixed') return '固定总价合同';
  if (record.pricingType === 'non_fixed') return '无固定总价合同';
  return '固定总价合同'; // Default
};

const getPricingTypeColor = (record: ContractDto) => {
  if (record.pricingType === 'fixed') return 'cyan';
  if (record.pricingType === 'non_fixed') return 'purple';
  return 'cyan';
};

const getSignStatusText = (record: ContractDto) => {
  if (record.lifecycleStatus === 'draft') return '草稿';
  if (record.lifecycleStatus === 'approving') return '审批中';
  if (record.lifecycleStatus === 'signed') return '已签订';
  if (record.lifecycleStatus === 'canceled') return '已作废';
  
  // Fallback for compatibility
  if (!record.signDate) return '草稿';
  return '已签订';
};

const getSignStatusColor = (record: ContractDto) => {
  if (record.lifecycleStatus === 'draft') return 'default';
  if (record.lifecycleStatus === 'approving') return 'processing';
  if (record.lifecycleStatus === 'signed') return 'success';
  if (record.lifecycleStatus === 'canceled') return 'error';
  
  // Fallback for compatibility
  if (!record.signDate) return 'default';
  return 'success';
};

const getPerformanceStatusText = (status: string) => {
  switch (status) {
    case 'executing':
      return '履约中';
    case 'completed':
      return '已履约';
    case 'abnormal':
      return '异常';
    default:
      return '未知';
  }
};

const getPerformanceStatusColor = (status: string) => {
  switch (status) {
    case 'executing':
      return 'processing';
    case 'completed':
      return 'success';
    case 'abnormal':
      return 'error';
    default:
      return 'default';
  }
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
    const res = await getContracts(undefined, undefined, expiryStatus);
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
    key: 'contractName'
  },
  {
    title: '合同总金额',
    dataIndex: 'totalAmount',
    key: 'totalAmount',
    align: 'right',
    width: 150
  },
  {
    title: '合同类型',
    key: 'direction',
    width: 150,
    align: 'center'
  },
  {
    title: '合同编号',
    dataIndex: 'contractNo',
    key: 'contractNo',
    width: 180
  },
  {
    title: '负责人',
    dataIndex: 'manager',
    key: 'manager',
    width: 180
  },
  {
    title: '总价类型',
    key: 'pricingType',
    width: 180,
    align: 'center'
  },
  {
    title: '签订日期',
    dataIndex: 'signDate',
    key: 'signDate',
    width: 150,
    align: 'center'
  },
  {
    title: '状态',
    key: 'signStatus',
    width: 120,
    align: 'center'
  },
  {
    title: '履约状态',
    key: 'performanceStatus',
    width: 120,
    align: 'center'
  },
  {
    title: '到期日期',
    dataIndex: 'endDate',
    key: 'endDate',
    width: 150,
    align: 'center'
  },
  {
    title: '操作',
    key: 'action',
    fixed: 'right',
    width: 100,
    align: 'center'
  }
];

onMounted(() => {
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

const handleCreate = () => {
  currentId.value = undefined;
  drawerVisible.value = true;
  nextTick(() => {
    if (contractFormRef.value) {
      contractFormRef.value.resetFields();
    }
  });
};

const handleEdit = (record: any) => {
  currentId.value = record.id;
  drawerVisible.value = true;
  nextTick(() => {
    if (contractFormRef.value) {
      contractFormRef.value.setFormState(record);
    }
  });
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
        partnerName: formState.customer,
        signDate: formState.signDate ? dayjs(formState.signDate).format('YYYY-MM-DD') : undefined,
        startDate: formState.period && formState.period[0] ? dayjs(formState.period[0]).format('YYYY-MM-DD') : undefined,
        endDate: formState.period && formState.period[1] ? dayjs(formState.period[1]).format('YYYY-MM-DD') : undefined,
        manager: formState.manager,
        totalAmount: formState.amount,
        currency: formState.currency,
        paymentMethod: formState.paymentMethod,
        description: formState.description,
        files: JSON.stringify(formState.fileList),
      };

      if (currentId.value) {
        await updateContract(currentId.value, dto);
        message.success('更新成功');
      } else {
        await createContract(dto);
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

.content-wrapper :deep(.ant-table-wrapper),
.content-wrapper :deep(.ant-spin-nested-loading),
.content-wrapper :deep(.ant-spin-container),
.content-wrapper :deep(.ant-table-container) {
  height: 100%;
}

.content-wrapper :deep(.ant-table) {
  height: 100%;
}

.content-wrapper :deep(.ant-table-container) {
  display: flex;
  flex-direction: column;
}

.content-wrapper :deep(.ant-table-body) {
  flex: 1;
  max-height: none !important;
  overflow-y: auto !important;
  scrollbar-gutter: stable;
}

.content-wrapper :deep(.ant-table-header) {
  flex-shrink: 0;
  overflow: hidden !important;
  scrollbar-gutter: stable;
}

.content-wrapper :deep(.ant-tag) {
  margin-right: 0;
}
</style>
