<template>
  <div class="page-container">
    <div class="header-actions">
      <div class="filters">
        <a-input-search placeholder="搜索接口名称/URL" style="width: 300px" />
        <a-select defaultValue="all" style="width: 120px; margin-left: 16px">
          <a-select-option value="all">全部状态</a-select-option>
          <a-select-option value="active">启用</a-select-option>
          <a-select-option value="disabled">停用</a-select-option>
        </a-select>
      </div>
      <a-button type="primary" @click="showDrawer">
        <template #icon><PlusOutlined /></template>
        新增接口
      </a-button>
    </div>

    <a-table :columns="columns" :data-source="data" :pagination="{ pageSize: 10 }">
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'method'">
          <a-tag :color="getMethodColor(record.method)">{{ record.method }}</a-tag>
        </template>
        <template v-else-if="column.key === 'status'">
          <a-switch v-model:checked="record.status" checked-children="启用" un-checked-children="停用" />
        </template>
        <template v-else-if="column.key === 'action'">
          <a-space>
            <a>编辑</a>
            <a>测试</a>
            <a>日志</a>
            <a-popconfirm title="确定删除吗？">
              <a style="color: #ff4d4f">删除</a>
            </a-popconfirm>
          </a-space>
        </template>
      </template>
    </a-table>

    <!-- Interface Detail/Edit Drawer -->
    <a-drawer
      v-model:visible="visible"
      title="接口配置"
      width="720"
      placement="right"
      :footer-style="{ textAlign: 'right' }"
    >
      <a-tabs v-model:activeKey="drawerTab">
        <a-tab-pane key="basic" tab="基本信息">
          <a-form layout="vertical" :model="formState">
            <a-row :gutter="16">
              <a-col :span="12">
                <a-form-item label="接口名称" required>
                  <a-input v-model:value="formState.name" placeholder="例如：ERP订单同步" />
                </a-form-item>
              </a-col>
              <a-col :span="12">
                <a-form-item label="请求方法" required>
                  <a-select v-model:value="formState.method">
                    <a-select-option value="GET">GET</a-select-option>
                    <a-select-option value="POST">POST</a-select-option>
                    <a-select-option value="PUT">PUT</a-select-option>
                    <a-select-option value="DELETE">DELETE</a-select-option>
                  </a-select>
                </a-form-item>
              </a-col>
            </a-row>
            <a-form-item label="源接口地址 (URL)" required>
              <a-input v-model:value="formState.url" placeholder="https://api.external-system.com/v1/orders" />
            </a-form-item>
            <a-form-item label="描述">
              <a-textarea v-model:value="formState.desc" :rows="3" />
            </a-form-item>
          </a-form>
        </a-tab-pane>

        <a-tab-pane key="auth" tab="授权认证">
          <a-alert message="配置访问该外部接口所需的凭证" type="info" show-icon style="margin-bottom: 16px" />
          <a-form layout="vertical" :model="formState">
            <a-form-item label="认证类型">
              <a-select v-model:value="formState.authType">
                <a-select-option value="none">无</a-select-option>
                <a-select-option value="basic">Basic Auth</a-select-option>
                <a-select-option value="bearer">Bearer Token</a-select-option>
                <a-select-option value="apikey">API Key</a-select-option>
              </a-select>
            </a-form-item>
            <template v-if="formState.authType === 'bearer'">
              <a-form-item label="Token">
                <a-input-password v-model:value="formState.token" />
              </a-form-item>
            </template>
             <template v-if="formState.authType === 'apikey'">
              <a-row :gutter="16">
                <a-col :span="10">
                   <a-form-item label="Key Name">
                    <a-input v-model:value="formState.apiKeyName" placeholder="X-API-KEY" />
                  </a-form-item>
                </a-col>
                <a-col :span="14">
                   <a-form-item label="Key Value">
                    <a-input-password v-model:value="formState.apiKeyValue" />
                  </a-form-item>
                </a-col>
              </a-row>
            </template>
          </a-form>
        </a-tab-pane>

        <a-tab-pane key="forward" tab="转发与组合">
          <div class="flow-editor">
             <div class="step-card">
               <div class="step-title">1. 请求接收</div>
               <div class="step-content">系统接收内部调用请求</div>
             </div>
             <div class="arrow-down">↓</div>
             <div class="step-card action">
               <div class="step-title">2. 数据转换 (可选)</div>
               <div class="step-content">
                 <a-checkbox>启用请求体映射</a-checkbox>
               </div>
             </div>
             <div class="arrow-down">↓</div>
             <div class="step-card primary">
               <div class="step-title">3. 调用外部接口</div>
               <div class="step-content">{{ formState.url || '未设置URL' }}</div>
             </div>
             <div class="arrow-down">↓</div>
             <div class="step-card action">
               <div class="step-title">4. 结果聚合 (可选)</div>
               <div class="step-content">
                 <a-button type="dashed" size="small">添加后续调用</a-button>
               </div>
             </div>
          </div>
        </a-tab-pane>
      </a-tabs>

      <template #footer>
        <a-button style="margin-right: 8px" @click="visible = false">取消</a-button>
        <a-button type="primary" @click="visible = false">保存</a-button>
      </template>
    </a-drawer>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue';
import { PlusOutlined } from '@ant-design/icons-vue';

const visible = ref(false);
const drawerTab = ref('basic');

const columns = [
  { title: '接口名称', dataIndex: 'name', key: 'name', width: 200 },
  { title: 'URL', dataIndex: 'url', key: 'url' },
  { title: '方法', dataIndex: 'method', key: 'method', width: 100 },
  { title: '类型', dataIndex: 'type', key: 'type', width: 120 }, // Direct, Composite
  { title: '状态', dataIndex: 'status', key: 'status', width: 100 },
  { title: '操作', key: 'action', width: 200 },
];

const data = ref([
  { key: '1', name: 'ERP库存查询', url: 'http://erp.internal/api/stock', method: 'GET', type: '直连', status: true },
  { key: '2', name: 'CRM客户同步', url: 'https://api.crm.com/v2/customers', method: 'POST', type: '组合转发', status: true },
  { key: '3', name: '物流轨迹订阅', url: 'https://kuaidi100.com/poll', method: 'POST', type: '直连', status: false },
]);

const formState = reactive({
  name: '',
  method: 'GET',
  url: '',
  desc: '',
  authType: 'none',
  token: '',
  apiKeyName: '',
  apiKeyValue: ''
});

const showDrawer = () => {
  visible.value = true;
};

const getMethodColor = (method: string) => {
  const map: Record<string, string> = {
    GET: 'blue',
    POST: 'green',
    PUT: 'orange',
    DELETE: 'red',
  };
  return map[method] || 'default';
};
</script>

<style scoped>
.page-container {
  padding: 24px;
  background: #fff;
  min-height: 100%;
}

.header-actions {
  display: flex;
  justify-content: space-between;
  margin-bottom: 24px;
}

.flow-editor {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 20px;
  background: #f5f5f5;
  border-radius: 4px;
}

.step-card {
  width: 300px;
  background: #fff;
  border: 1px solid #e8e8e8;
  border-radius: 4px;
  padding: 12px;
  text-align: center;
  box-shadow: 0 2px 4px rgba(0,0,0,0.05);
}

.step-card.primary {
  border-color: #1890ff;
  background: #e6f7ff;
}

.step-card.action {
  border-style: dashed;
}

.step-title {
  font-weight: bold;
  margin-bottom: 8px;
}

.arrow-down {
  font-size: 20px;
  color: #999;
  margin: 8px 0;
}
</style>