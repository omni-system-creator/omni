<template>
  <div class="workflow-design-container">
    <a-card :bordered="false">
      <div class="table-page-search-wrapper">
        <a-form layout="inline">
          <a-form-item label="流程名称">
            <a-input v-model:value="queryParam.name" placeholder="请输入" />
          </a-form-item>
          <a-form-item label="状态">
            <a-select v-model:value="queryParam.status" placeholder="请选择" style="width: 120px">
              <a-select-option value="all">全部</a-select-option>
              <a-select-option value="active">已发布</a-select-option>
              <a-select-option value="draft">草稿</a-select-option>
              <a-select-option value="suspended">已停用</a-select-option>
            </a-select>
          </a-form-item>
          <a-form-item>
            <a-space>
              <a-button type="primary" @click="handleSearch">查询</a-button>
              <a-button @click="handleReset">重置</a-button>
            </a-space>
          </a-form-item>
        </a-form>
      </div>

      <div class="table-operator my-4">
        <a-button type="primary" @click="handleAdd">
          <template #icon><PlusOutlined /></template>
          新建流程
        </a-button>
        <a-button>
          <template #icon><ImportOutlined /></template>
          导入BPMN
        </a-button>
      </div>

      <a-table :columns="columns" :data-source="data" :pagination="pagination">
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'status'">
            <a-badge :status="getStatusBadge(record.status)" :text="record.statusLabel" />
          </template>
          <template v-if="column.key === 'version'">
            <a-tag color="blue">v{{ record.version }}</a-tag>
          </template>
          <template v-if="column.key === 'action'">
            <a>设计</a>
            <a-divider type="vertical" />
            <a>配置</a>
            <a-divider type="vertical" />
            <a-dropdown>
              <a class="ant-dropdown-link" @click.prevent>
                更多 <DownOutlined />
              </a>
              <template #overlay>
                <a-menu>
                  <a-menu-item v-if="record.status === 'active'">停用</a-menu-item>
                  <a-menu-item v-else>发布</a-menu-item>
                  <a-menu-item>复制</a-menu-item>
                  <a-menu-item>版本历史</a-menu-item>
                  <a-menu-divider />
                  <a-menu-item danger>删除</a-menu-item>
                </a-menu>
              </template>
            </a-dropdown>
          </template>
        </template>
      </a-table>
    </a-card>

    <!-- 模拟流程设计器弹窗 -->
    <a-modal
      v-model:open="visible"
      title="流程设计器 - 项目立项申请"
      width="1000px"
      :footer="null"
      centered
    >
      <div class="designer-mock">
        <div class="sidebar">
          <div class="node-item circle">开始</div>
          <div class="node-item rect">用户任务</div>
          <div class="node-item rect">审批任务</div>
          <div class="node-item diamond">网关</div>
          <div class="node-item circle end">结束</div>
        </div>
        <div class="canvas">
          <!-- 简单的CSS绘制流程图 -->
          <div class="flow-node start" style="top: 50px; left: 50px;">Start</div>
          <div class="arrow" style="top: 65px; left: 90px; width: 60px;"></div>
          <div class="flow-node task" style="top: 40px; left: 150px;">填写立项书</div>
          <div class="arrow" style="top: 65px; left: 250px; width: 60px;"></div>
          <div class="flow-node task" style="top: 40px; left: 310px;">部门经理审批</div>
          <div class="arrow" style="top: 65px; left: 410px; width: 60px;"></div>
          <div class="flow-node gateway" style="top: 50px; left: 470px;">?</div>
          
          <div class="arrow" style="top: 65px; left: 510px; width: 60px;"></div>
          <div class="flow-node task" style="top: 40px; left: 570px;">CTO审批</div>
           <div class="arrow" style="top: 65px; left: 670px; width: 60px;"></div>
          <div class="flow-node end" style="top: 50px; left: 730px;">End</div>

          <div class="connection-line-down" style="top: 90px; left: 490px; height: 50px;"></div>
          <div class="flow-node task" style="top: 140px; left: 440px;">退回修改</div>
        </div>
        <div class="properties">
          <h4>节点属性</h4>
          <a-form layout="vertical">
            <a-form-item label="节点名称"><a-input value="部门经理审批" /></a-form-item>
            <a-form-item label="审批人">
              <a-select value="dept_manager">
                <a-select-option value="dept_manager">部门负责人</a-select-option>
                <a-select-option value="user">指定用户</a-select-option>
              </a-select>
            </a-form-item>
          </a-form>
        </div>
      </div>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue';
import { PlusOutlined, ImportOutlined, DownOutlined } from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';

const queryParam = reactive({
  name: '',
  status: 'all'
});

const visible = ref(false);

const columns = [
  { title: '流程标识', dataIndex: 'key', key: 'key' },
  { title: '流程名称', dataIndex: 'name', key: 'name' },
  { title: '分类', dataIndex: 'category', key: 'category' },
  { title: '版本', dataIndex: 'version', key: 'version' },
  { title: '状态', dataIndex: 'status', key: 'status' },
  { title: '最后更新时间', dataIndex: 'updatedAt', key: 'updatedAt' },
  { title: '操作', key: 'action', width: 200 }
];

const data = ref([
  { key: 'PR_INIT', name: '项目立项申请', category: '项目研发', version: 3, status: 'active', statusLabel: '已发布', updatedAt: '2024-12-20 10:00' },
  { key: 'PR_DEPLOY', name: '生产环境发布', category: '项目研发', version: 5, status: 'active', statusLabel: '已发布', updatedAt: '2024-12-18 14:30' },
  { key: 'HR_LEAVE', name: '请假申请', category: '人事行政', version: 1, status: 'active', statusLabel: '已发布', updatedAt: '2024-11-05 09:00' },
  { key: 'FIN_EXP', name: '差旅报销', category: '财务相关', version: 2, status: 'draft', statusLabel: '草稿', updatedAt: '2024-12-21 16:45' },
  { key: 'IT_VPN', name: 'VPN申请', category: 'IT运维', version: 1, status: 'suspended', statusLabel: '已停用', updatedAt: '2024-10-01 11:20' },
]);

const pagination = {
  total: 50,
  current: 1,
  pageSize: 10
};

const getStatusBadge = (status: string) => {
  switch (status) {
    case 'active': return 'success';
    case 'draft': return 'default';
    case 'suspended': return 'error';
    default: return 'default';
  }
};

const handleSearch = () => {
  message.loading('查询中...');
};

const handleReset = () => {
  queryParam.name = '';
  queryParam.status = 'all';
};

const handleAdd = () => {
  visible.value = true;
};
</script>

<style scoped>
.workflow-design-container {
  padding: 16px;
  flex: 1;
}
.my-4 {
  margin-top: 16px;
  margin-bottom: 16px;
}
.designer-mock {
  display: flex;
  height: 500px;
  border: 1px solid #d9d9d9;
}
.sidebar {
  width: 150px;
  border-right: 1px solid #d9d9d9;
  padding: 10px;
  background: #f5f5f5;
}
.node-item {
  margin-bottom: 10px;
  padding: 8px;
  border: 1px solid #d9d9d9;
  background: #fff;
  text-align: center;
  cursor: grab;
  font-size: 12px;
}
.node-item.circle { border-radius: 50%; width: 40px; height: 40px; line-height: 24px; margin: 0 auto 10px; }
.node-item.rect { border-radius: 4px; }
.node-item.diamond { transform: rotate(45deg); width: 40px; height: 40px; margin: 10px auto; display: flex; align-items: center; justify-content: center; }
.canvas {
  flex: 1;
  background: #fff;
  position: relative;
  overflow: auto;
  background-image: radial-gradient(#e0e0e0 1px, transparent 1px);
  background-size: 20px 20px;
}
.properties {
  width: 250px;
  border-left: 1px solid #d9d9d9;
  padding: 10px;
  background: #f5f5f5;
}

/* Canvas Elements Mock */
.flow-node {
  position: absolute;
  background: #e6f7ff;
  border: 1px solid #1890ff;
  border-radius: 4px;
  padding: 8px 16px;
  font-size: 12px;
  cursor: pointer;
}
.flow-node.start, .flow-node.end {
  border-radius: 50%;
  width: 40px;
  height: 40px;
  padding: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f6ffed;
  border-color: #52c41a;
}
.flow-node.end {
  background: #fff1f0;
  border-color: #ff4d4f;
}
.flow-node.gateway {
  width: 40px;
  height: 40px;
  transform: rotate(45deg);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0;
  background: #fff7e6;
  border-color: #fa8c16;
}
.arrow {
  position: absolute;
  height: 1px;
  background: #8c8c8c;
}
.arrow::after {
  content: '';
  position: absolute;
  right: 0;
  top: -3px;
  width: 0;
  height: 0;
  border-top: 3px solid transparent;
  border-bottom: 3px solid transparent;
  border-left: 6px solid #8c8c8c;
}
.connection-line-down {
  position: absolute;
  width: 1px;
  background: #8c8c8c;
}
</style>
