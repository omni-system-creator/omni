<template>
  <div class="borrow-container">
    <SplitLayout>
      <template #left>
        <div class="left-tree-container">
          <a-card title="部门结构" :bordered="false" class="tree-card">
            <a-input-search style="margin-bottom: 8px" placeholder="搜索部门" allow-clear />
            <a-tree
              :tree-data="deptTreeData"
              :default-expand-all="true"
              :show-line="true"
              @select="onSelectTree"
            >
            </a-tree>
          </a-card>
        </div>
      </template>
      <template #right>
        <div class="right-content-container">
          <a-card :bordered="false" class="content-card">
            <a-tabs v-model:activeKey="activeKey">
              <a-tab-pane key="1" tab="借阅申请">
                <div class="tab-content">
                  <div class="table-operations">
                    <a-button type="primary" @click="handleApply">
                      <template #icon><PlusOutlined /></template>
                      发起申请
                    </a-button>
                  </div>
                  <a-table :columns="applyColumns" :data-source="applyData">
                    <template #bodyCell="{ column, record }">
                      <template v-if="column.key === 'status'">
                        <a-tag color="processing" v-if="record.status === 'audit'">审批中</a-tag>
                        <a-tag color="success" v-else-if="record.status === 'approved'">已通过</a-tag>
                        <a-tag color="error" v-else>已驳回</a-tag>
                      </template>
                      <template v-if="column.key === 'action'">
                        <a-tooltip title="详情">
                          <a-button type="text" size="small" @click="handleViewApply(record)">
                            <template #icon><EyeOutlined /></template>
                          </a-button>
                        </a-tooltip>
                        <a-tooltip title="撤回" v-if="record.status === 'audit'">
                          <a-button type="text" danger size="small" @click="handleRevoke(record)">
                            <template #icon><UndoOutlined /></template>
                          </a-button>
                        </a-tooltip>
                      </template>
                    </template>
                  </a-table>
                </div>
              </a-tab-pane>
              
              <a-tab-pane key="2" tab="审批管理" force-render>
                <div class="tab-content">
                  <a-table :columns="approveColumns" :data-source="approveData">
                    <template #bodyCell="{ column, record }">
                      <template v-if="column.key === 'action'">
                        <a-tooltip title="审批">
                          <a-button type="text" size="small" @click="handleAudit(record)">
                            <template #icon><CheckSquareOutlined /></template>
                          </a-button>
                        </a-tooltip>
                      </template>
                    </template>
                  </a-table>
                </div>
              </a-tab-pane>
              
              <a-tab-pane key="3" tab="借阅记录">
                <div class="tab-content">
                   <a-form layout="inline" style="margin-bottom: 16px">
                    <a-form-item label="关键词">
                      <a-input placeholder="借阅人/档号" />
                    </a-form-item>
                    <a-form-item>
                      <a-button type="primary">查询</a-button>
                    </a-form-item>
                  </a-form>
                  <a-table :columns="recordColumns" :data-source="recordData">
                     <template #bodyCell="{ column, record }">
                      <template v-if="column.key === 'status'">
                        <a-tag color="warning" v-if="record.status === 'borrowing'">借阅中</a-tag>
                        <a-tag color="default" v-else>已归还</a-tag>
                      </template>
                    </template>
                  </a-table>
                </div>
              </a-tab-pane>
            </a-tabs>
          </a-card>
        </div>
      </template>
    </SplitLayout>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { PlusOutlined, EyeOutlined, UndoOutlined, CheckSquareOutlined } from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import SplitLayout from '@/components/SplitLayout/index.vue';

const activeKey = ref('1');

const deptTreeData = [
  {
    title: '全公司',
    key: 'all',
    children: [
      { title: '总经办', key: 'dept-gm' },
      { title: '行政部', key: 'dept-admin' },
      { title: '人力资源部', key: 'dept-hr' },
      { title: '财务部', key: 'dept-finance' },
      { title: '研发部', key: 'dept-rd' },
      { title: '市场部', key: 'dept-market' },
    ]
  }
];

const onSelectTree = (selectedKeys: any, info: any) => {
  message.info(`选择了部门: ${info.node.title}`);
};

// Tab 1: Apply
const applyColumns = [
  { title: '申请单号', dataIndex: 'applyNo', key: 'applyNo' },
  { title: '申请时间', dataIndex: 'applyTime', key: 'applyTime' },
  { title: '借阅类型', dataIndex: 'type', key: 'type' },
  { title: '借阅天数', dataIndex: 'days', key: 'days' },
  { title: '申请理由', dataIndex: 'reason', key: 'reason' },
  { title: '状态', dataIndex: 'status', key: 'status' },
  { title: '操作', key: 'action' }
];

const applyData = ref([
  { key: '1', applyNo: 'SQ-20241222-001', applyTime: '2024-12-22 10:00', type: '实体借阅', days: 7, reason: '项目查阅', status: 'audit' },
  { key: '2', applyNo: 'SQ-20241220-005', applyTime: '2024-12-20 15:30', type: '电子下载', days: 30, reason: '数据统计', status: 'approved' },
]);

const handleApply = () => message.info('填写申请单');
const handleViewApply = (record: any) => message.info('查看申请详情');
const handleRevoke = (record: any) => message.success('撤回成功');

// Tab 2: Approve
const approveColumns = [
  { title: '申请单号', dataIndex: 'applyNo', key: 'applyNo' },
  { title: '申请人', dataIndex: 'applicant', key: 'applicant' },
  { title: '所属部门', dataIndex: 'dept', key: 'dept' },
  { title: '申请时间', dataIndex: 'applyTime', key: 'applyTime' },
  { title: '借阅内容', dataIndex: 'content', key: 'content' },
  { title: '操作', key: 'action' }
];

const approveData = ref([
  { key: '1', applyNo: 'SQ-20241222-008', applicant: '李四', dept: '财务部', applyTime: '2024-12-22 11:00', content: '2023年财务凭证...' },
]);

const handleAudit = (record: any) => message.info('打开审批窗口');

// Tab 3: Record
const recordColumns = [
  { title: '借阅单号', dataIndex: 'borrowNo', key: 'borrowNo' },
  { title: '档号', dataIndex: 'archCode', key: 'archCode' },
  { title: '题名', dataIndex: 'title', key: 'title' },
  { title: '借阅人', dataIndex: 'borrower', key: 'borrower' },
  { title: '借阅时间', dataIndex: 'borrowTime', key: 'borrowTime' },
  { title: '应还时间', dataIndex: 'returnDeadline', key: 'returnDeadline' },
  { title: '状态', dataIndex: 'status', key: 'status' }
];

const recordData = ref([
  { key: '1', borrowNo: 'JY-20241201-003', archCode: 'WS-2023-005', title: '关于信息化建设的通知', borrower: '张三', borrowTime: '2024-12-01', returnDeadline: '2024-12-08', status: 'returned' },
  { key: '2', borrowNo: 'JY-20241215-001', archCode: 'RS-2024-002', title: '2024人员招聘计划', borrower: '王五', borrowTime: '2024-12-15', returnDeadline: '2024-12-22', status: 'borrowing' },
]);

</script>

<style scoped>
.borrow-container {
  height: 100%;
  padding: 0;
}
.left-tree-container {
  height: 100%;
  padding: 16px;
  overflow-y: auto;
  background-color: #fff;
  border-right: 1px solid #f0f0f0;
}
.right-content-container {
  height: 100%;
  padding: 24px;
  overflow-y: auto;
}
.table-operations {
  margin-bottom: 16px;
}
:deep(.ant-card-body) {
  padding: 12px;
}
</style>