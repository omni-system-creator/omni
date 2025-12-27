<template>
  <a-drawer
    v-model:open="visible"
    :title="editingId ? (formState.name ? `${formState.name} ${formState.version}` : '编辑接口') : '发布新接口'"
    width="80%"
    placement="right"
    destroyOnClose
    @close="onClose"
    :bodyStyle="{ padding: 0, display: 'flex', flexDirection: 'column', height: '100vh' }"
  >
    <div class="drawer-content">
      <div v-if="categoryId" style="padding: 16px 24px; background: #e6f7ff; border-bottom: 1px solid #91d5ff;">
        <InfoCircleOutlined style="color: #1890ff; margin-right: 8px" />
        当前接口将发布到：<strong>{{ fullCategoryPath }}</strong>，完整访问路径预览：<strong>{{ previewFullPath }}</strong>
      </div>
      <a-alert v-if="formState.isPublished" message="当前接口已发布，仅支持查看，如需修改请先下线。" type="warning" show-icon style="margin: 16px 24px 0;" />
      <a-tabs v-model:activeKey="activeTab" class="custom-tabs">
        <template #tabBarExtraContent>
          <a-space>
            <a-button @click="handleCheck">
              <template #icon><CheckCircleOutlined /></template>
              接口检查
            </a-button>
            <a-button 
                v-if="activeTab === 'flow'" 
                @click="handleDebug"
            >
              <template #icon><BugOutlined /></template>
              在线调试
            </a-button>
            <a-button 
                v-if="activeTab === 'flow' && debugResult" 
                @click="clearDebug"
            >
              清理调试
            </a-button>
            <a-popconfirm
              v-if="formState.isPublished"
              title="确定要下线该接口吗？"
              @confirm="togglePublish"
            >
              <a-button danger>下线</a-button>
            </a-popconfirm>
            <a-popconfirm
              v-else-if="editingId"
              title="确定要发布该接口吗？"
              @confirm="togglePublish"
            >
               <a-button type="primary" ghost>发布</a-button>
            </a-popconfirm>
            <a-button type="primary" @click="handleSave" :disabled="formState.isPublished">
              <template #icon><CloudUploadOutlined /></template>
              保存
            </a-button>
          </a-space>
        </template>
        <a-tab-pane key="basic" tab="基本信息">
          <div class="tab-panel">
            <a-form layout="vertical" :model="formState" style="max-width: 800px; margin: 0 auto; padding-top: 24px;" :disabled="formState.isPublished">
              <a-row :gutter="16">
                <a-col :span="12">
                  <a-form-item label="所属分类" required>
                    <a-tree-select
                      v-model:value="formState.categoryId"
                      :tree-data="treeData"
                      :field-names="{ children: 'children', label: 'name', value: 'id' }"
                      placeholder="请选择分类"
                      tree-default-expand-all
                      allow-clear
                      @change="handleCategoryChange"
                    />
                  </a-form-item>
                </a-col>
                <a-col :span="12">
                  <a-form-item label="接口名称" required>
                    <a-input v-model:value="formState.name" placeholder="例如：查询用户详情" />
                  </a-form-item>
                </a-col>
              </a-row>
              <a-row :gutter="16">
                <a-col :span="12">
                  <a-form-item label="版本号" required>
                    <a-input v-model:value="formState.version" placeholder="v1.0.0" />
                  </a-form-item>
                </a-col>
              </a-row>
              <a-row :gutter="16">
                <a-col :span="8">
                  <a-form-item label="请求方法" required>
                    <a-select v-model:value="formState.method">
                      <a-select-option value="GET">GET</a-select-option>
                      <a-select-option value="POST">POST</a-select-option>
                      <a-select-option value="PUT">PUT</a-select-option>
                      <a-select-option value="DELETE">DELETE</a-select-option>
                    </a-select>
                  </a-form-item>
                </a-col>
                <a-col :span="16">
                  <a-form-item label="请求路径" required>
                    <a-input v-model:value="formState.path" placeholder="user/detail" />
                  </a-form-item>
                </a-col>
              </a-row>
              <a-form-item label="接口描述">
                <a-textarea v-model:value="formState.description" :rows="4" />
              </a-form-item>

              <a-divider orientation="left">权限控制</a-divider>
              <a-row :gutter="16">
                <a-col :span="24">
                  <a-form-item label="可见角色" tooltip="哪些角色可以在列表中看到此接口">
                    <a-select
                      v-model:value="formState.viewRoles"
                      mode="multiple"
                      placeholder="请选择可见角色（留空表示不限制）"
                      :options="roleList"
                      :field-names="{ label: 'name', value: 'id' }"
                      allow-clear
                    />
                  </a-form-item>
                </a-col>
                <a-col :span="24">
                  <a-form-item label="调用角色" tooltip="哪些角色可以调用执行此接口">
                    <a-select
                      v-model:value="formState.callRoles"
                      mode="multiple"
                      placeholder="请选择调用角色（留空表示不限制）"
                      :options="roleList"
                      :field-names="{ label: 'name', value: 'id' }"
                      allow-clear
                    />
                  </a-form-item>
                </a-col>
                <a-col :span="24">
                  <a-form-item label="管理角色" tooltip="哪些角色可以编辑、发布、下线此接口">
                    <a-select
                      v-model:value="formState.manageRoles"
                      mode="multiple"
                      placeholder="请选择管理角色（留空表示不限制）"
                      :options="roleList"
                      :field-names="{ label: 'name', value: 'id' }"
                      allow-clear
                    />
                  </a-form-item>
                </a-col>
              </a-row>

              <a-form-item label="鉴权方式">
                <a-radio-group v-model:value="formState.auth.type">
                  <a-radio value="none">公开访问 (无需认证)</a-radio>
                  <a-radio value="apikey">API Key</a-radio>
                  <a-radio value="oauth2">OAuth 2.0</a-radio>
                </a-radio-group>
              </a-form-item>
              <div v-if="formState.auth.type === 'apikey'" style="background: #f5f5f5; padding: 16px; border-radius: 4px; margin-bottom: 24px;">
                <a-form-item label="Key Header Name" style="margin-bottom: 0;">
                  <a-input v-model:value="formState.auth.keyName" placeholder="X-API-KEY" />
                </a-form-item>
              </div>
            </a-form>
          </div>
        </a-tab-pane>

        <a-tab-pane key="flow" tab="接口编排">
          <div class="tab-panel flow-designer-container" style="padding: 0;">
            <div class="flow-designer-wrapper">
                <div v-if="formState.isPublished" style="position: absolute; top: 0; left: 0; right: 0; bottom: 0; z-index: 10; background: rgba(255,255,255,0.1); cursor: not-allowed;"></div>
                <ApiFlowDesigner 
                  ref="designerRef" 
                  :initialData="formState.flow" 
                  :debugResult="debugResult"
                  :readOnly="formState.isPublished"
                  @node-click="handleNodeClick"
                />
            </div>
            
            <!-- Debug Info Panel -->
            <div class="debug-panel" :class="{ 'visible': nodeDetailVisible }">
                <div class="debug-panel-header">
                    <span>
                        <span v-if="selectedNodeDebugData">节点详情: {{ selectedNodeDebugData.nodeName || selectedNodeDebugData.nodeType }}</span>
                        <span v-else>执行日志</span>
                    </span>
                    <a-button type="text" size="small" @click="nodeDetailVisible = false">
                        <template #icon><CloseOutlined /></template>
                    </a-button>
                </div>
                <div class="debug-panel-content">
                    <div v-if="selectedNodeDebugData" style="height: 100%; display: flex; flex-direction: column;">
                        <a-descriptions bordered size="small" :column="2">
                            <a-descriptions-item label="状态">
                                <a-tag :color="selectedNodeDebugData.success ? 'green' : 'red'">
                                    {{ selectedNodeDebugData.success ? '成功' : '失败' }}
                                </a-tag>
                            </a-descriptions-item>
                            <a-descriptions-item label="耗时">{{ selectedNodeDebugData.durationMs }} ms</a-descriptions-item>
                            <a-descriptions-item label="错误" v-if="selectedNodeDebugData.errorMessage" :span="2">
                                <span style="color: red">{{ selectedNodeDebugData.errorMessage }}</span>
                            </a-descriptions-item>
                        </a-descriptions>
                        <a-row :gutter="16" style="margin-top: 10px; flex: 1; min-height: 0;">
                            <a-col :span="12" style="height: 100%; display: flex; flex-direction: column;">
                                <div style="font-weight: bold; margin-bottom: 5px;">Input</div>
                                <pre class="json-view">{{ JSON.stringify(selectedNodeDebugData.input, null, 2) }}</pre>
                            </a-col>
                            <a-col :span="12" style="height: 100%; display: flex; flex-direction: column;">
                                <div style="font-weight: bold; margin-bottom: 5px;">Output</div>
                                <pre class="json-view">{{ JSON.stringify(selectedNodeDebugData.output, null, 2) }}</pre>
                            </a-col>
                        </a-row>
                    </div>
                    <div v-else style="height: 100%; display: flex; flex-direction: column;">
                         <div style="background: #333; color: #fff; padding: 10px; border-radius: 4px; flex: 1; overflow: auto; font-family: monospace;">
                           <div v-if="debugResult && debugResult.logs && debugResult.logs.length > 0">
                                <div v-for="(log, idx) in debugResult.logs" :key="idx">{{ log }}</div>
                           </div>
                           <div v-else style="color: #999; text-align: center; margin-top: 20px;">暂无日志</div>
                         </div>
                    </div>
                </div>
            </div>
          </div>
        </a-tab-pane>
      </a-tabs>
      <div class="drawer-footer" style="padding: 10px 24px; border-top: 1px solid #f0f0f0; text-align: right; background: #fff;">
        <a-button style="margin-right: 8px" @click="onClose">关闭</a-button>
      </div>
    </div>

    <!-- Debug Modal -->
    <a-modal
      v-model:open="debugVisible"
      title="在线调试"
      width="800px"
      @ok="executeDebug"
      :confirmLoading="debugLoading"
      okText="运行"
      cancelText="关闭"
    >
       <a-form layout="vertical">
         <a-form-item label="Params (JSON)">
           <a-textarea v-model:value="debugData.params" :rows="5" placeholder='{ "id": 1 }' style="font-family: monospace;" />
         </a-form-item>
         <a-form-item label="Body (JSON)">
           <a-textarea v-model:value="debugData.body" :rows="5" placeholder='{ "name": "test" }' style="font-family: monospace;" />
         </a-form-item>
       </a-form>
    </a-modal>

    <!-- Node Detail Drawer (Removed, replaced by bottom panel) -->
    <!-- 
    <a-drawer ... > ... </a-drawer>
    -->
  </a-drawer>
</template>

<script setup lang="ts">
import { ref, watch, computed, reactive, onUnmounted } from 'vue';
import { message } from 'ant-design-vue';
import { 
  CheckCircleOutlined, 
  BugOutlined, 
  CloudUploadOutlined,
  InfoCircleOutlined,
  CloseOutlined
} from '@ant-design/icons-vue';
import ApiFlowDesigner from './ApiFlowDesigner.vue';
import { interfaceApi, type InterfaceCategory } from '@/api/interface';
import { getRoleList } from '@/api/role';
import { HubConnectionBuilder, HubConnection } from '@microsoft/signalr';
import { v4 as uuidv4 } from 'uuid';

const props = defineProps<{
  visible: boolean;
  editingId: string | null;
  initialData: any;
  categoryId?: number;
}>();

const emit = defineEmits(['update:visible', 'save', 'publish']);

const activeTab = ref('basic');
const designerRef = ref<any>(null);
const fullCategoryPath = ref('');
const globalPrefix = '/api/data';
const treeData = ref<InterfaceCategory[]>([]);

const defaultFormState = {
  categoryId: undefined as number | undefined,
  name: '',
  version: 'v1.0.0',
  method: 'GET',
  path: '',
  description: '',
  auth: {
    type: 'none',
    keyName: 'X-API-KEY'
  },
  viewRoles: [] as number[],
  callRoles: [] as number[],
  manageRoles: [] as number[],
  flow: null as any,
  isPublished: false
};

const formState = ref({ ...defaultFormState });
const roleList = ref<any[]>([]);

// Debug State
const debugVisible = ref(false);
const debugLoading = ref(false);
const debugData = reactive({
  params: '{}',
  body: '{}'
});
const debugResult = ref<any>(null);
const debugSessionId = ref<string>('');
const nodeExecutionMap = reactive(new Map<string, any>()); // Key: NodeId, Value: NodeEventData
let hubConnection: HubConnection | null = null;

const initSignalR = async () => {
    if (hubConnection) return;
    
    // Generate new session ID
    debugSessionId.value = uuidv4();
    
    hubConnection = new HubConnectionBuilder()
        .withUrl('/hubs/debug') // Use relative path, proxy handles it
        .withAutomaticReconnect()
        .build();
        
    hubConnection.on('ReceiveDebugEvent', (event: any) => {
        // console.log('Debug Event:', event);
        if (!debugResult.value) {
             debugResult.value = { logs: [], executedNodes: [] };
        }
        
        switch (event.type) {
            case 0: // ExecutionStart
                debugResult.value = { logs: [], executedNodes: [], runningNodes: [], statusCode: 0 };
                nodeExecutionMap.clear();
                break;
            case 1: // NodeStart
                if (debugResult.value && event.data && event.data.nodeId) {
                    if (!debugResult.value.runningNodes) debugResult.value.runningNodes = [];
                    if (!debugResult.value.runningNodes.includes(event.data.nodeId)) {
                        debugResult.value.runningNodes.push(event.data.nodeId);
                    }
                }
                break;
            case 2: // NodeEnd
                if (event.data && event.data.nodeId) {
                    if (debugResult.value && debugResult.value.runningNodes) {
                        const idx = debugResult.value.runningNodes.indexOf(event.data.nodeId);
                        if (idx > -1) debugResult.value.runningNodes.splice(idx, 1);
                    }

                    if (!debugResult.value.executedNodes.includes(event.data.nodeId)) {
                        debugResult.value.executedNodes.push(event.data.nodeId);
                    }
                    // Store detailed node execution data
                    nodeExecutionMap.set(event.data.nodeId, event.data);
                    
                    // Auto select the latest executed node to show details
                    // We need to wait for DOM update or visual update? No, just set state.
                    // But we don't want to interrupt if user is looking at another node?
                    // User said "自动选中最新有动态的节点弹出详情" (Auto select the latest dynamic node and pop up details)
                    selectedNodeDebugData.value = event.data;
                    nodeDetailVisible.value = true;
                    // Auto select the latest executed node in the designer to show visual selection
                    if (designerRef.value) {
                         designerRef.value.selectNode(event.data.nodeId);
                    }
                }
                break;
            case 3: // Log
                if (event.data && event.data.message) {
                    debugResult.value.logs.push(`[${new Date(event.timestamp).toLocaleTimeString()}] ${event.data.message}`);
                }
                break;
            case 4: // Error
                debugResult.value.error = event.data;
                debugResult.value.statusCode = 500;
                break;
            case 5: // ExecutionEnd
                if (event.data) {
                    // Merge final result
                    debugResult.value = { ...debugResult.value, ...event.data };
                }
                break;
        }
    });
    
    try {
        await hubConnection.start();
        await hubConnection.invoke('JoinGroup', debugSessionId.value);
        console.log('Connected to Debug Hub with Session:', debugSessionId.value);
    } catch (err) {
        console.error('SignalR Connection Error: ', err);
    }
};

const clearDebug = () => {
    debugResult.value = null;
    nodeExecutionMap.clear();
    nodeDetailVisible.value = false;
    selectedNodeDebugData.value = null;
    if (designerRef.value) {
        designerRef.value.clearSelection();
    }
};

const destroySignalR = async () => {
    if (hubConnection) {
        try {
            await hubConnection.stop();
        } catch (e) {
            console.error(e);
        }
        hubConnection = null;
    }
};

onUnmounted(() => {
    destroySignalR();
});

const loadRoles = async () => {
    try {
        const res = await getRoleList();
        roleList.value = (res as any).data || res || [];
    } catch (e) {
        console.error('Failed to load roles', e);
    }
};

const previewFullPath = computed(() => {
    let p = formState.value.path || '';
    if (!p.startsWith('/')) p = '/' + p;
    // fullCategoryPath already includes global prefix if we calculate it that way?
    // No, let's keep fullCategoryPath as category structure prefix.
    // Wait, backend logic: GlobalPrefix + CategoryPath + InterfacePath
    // Let's mimic backend logic here for preview
    
    let cp = fullCategoryPath.value;
    if (!cp.startsWith('/')) cp = '/' + cp;
    if (cp.endsWith('/')) cp = cp.slice(0, -1);
    
    return `${globalPrefix}${cp}${p}`.replace('//', '/');
});

const handleCategoryChange = (value: number) => {
    if (value) {
        loadCategoryPath(value);
    } else {
        fullCategoryPath.value = '';
    }
};

// Load category path
const loadCategoryPath = async (catId: number) => {
    try {
        // Ideally we should get the path from the tree component or backend.
        // For now, let's fetch the category tree and find the path.
        if (treeData.value.length === 0) {
             const res = await interfaceApi.getCategoryTree();
             const data = (res as any).data || res;
             if (Array.isArray(data)) {
                treeData.value = data;
             } else if (data && Array.isArray(data.children)) {
                treeData.value = [data];
             } else {
                treeData.value = [];
             }
        }
        
        let path = '';
        const findPath = (nodes: InterfaceCategory[], targetId: number, currentPath: string): boolean => {
            for (const node of nodes) {
                let nodePrefix = node.urlPrefix || '';
                if (!nodePrefix.startsWith('/')) nodePrefix = '/' + nodePrefix;
                if (nodePrefix.endsWith('/')) nodePrefix = nodePrefix.slice(0, -1);
                
                const nextPath = currentPath + nodePrefix;
                
                if (node.id === targetId) {
                    path = nextPath;
                    return true;
                }
                if (node.children && node.children.length > 0) {
                    if (findPath(node.children, targetId, nextPath)) return true;
                }
            }
            return false;
        };
        
        findPath(treeData.value, catId, '');
        fullCategoryPath.value = path;
    } catch (e) {
        console.error('Failed to load category path', e);
    }
};

watch(
  () => props.visible,
  (val) => {
    if (val) {
      activeTab.value = 'basic';
      
      // Initialize category data
      if (props.initialData && props.initialData.categoryId) {
          // Edit mode: use category from data
          formState.value.categoryId = props.initialData.categoryId;
          loadCategoryPath(props.initialData.categoryId);
      } else if (props.categoryId) {
          // Create mode: use passed categoryId
          formState.value.categoryId = props.categoryId;
          loadCategoryPath(props.categoryId);
      } else {
          fullCategoryPath.value = '';
          // Ensure tree data is loaded even if no category is selected initially
          loadCategoryPath(0); 
      }
      
      if (props.initialData) {
        // Deep copy initial data to avoid reference issues
        // Especially flow object needs to be cloned properly if it exists
        const initData = JSON.parse(JSON.stringify(props.initialData));
        
        formState.value = {
          ...defaultFormState,
          ...initData,
          auth: {
            ...defaultFormState.auth,
            ...(initData.auth || {})
          },
          viewRoles: initData.viewRoles || [],
          callRoles: initData.callRoles || [],
          manageRoles: initData.manageRoles || [],
          // Ensure flow is restored correctly
          flow: initData.flow || (initData.flowConfig ? JSON.parse(initData.flowConfig) : null),
          // Ensure isPublished is synced from initData (the record)
          isPublished: initData.isPublished || false
        };
        // Ensure categoryId is set if present in initialData
        if (initData.categoryId) {
            formState.value.categoryId = initData.categoryId;
        }
      } else {
        // Reset form
        formState.value = { 
          ...defaultFormState,
          categoryId: props.categoryId, // Set default category from props
          auth: { ...defaultFormState.auth },
          viewRoles: [],
          callRoles: [],
          manageRoles: []
        };
      }
      
      // Load roles when drawer opens
      if (roleList.value.length === 0) {
          loadRoles();
      }
    }
  }
);

watch(
    () => props.initialData,
    (val) => {
        if (val && props.visible) {
             const initData = JSON.parse(JSON.stringify(val));
             // Merge with current state or replace? 
             // Since this is usually triggered by "reload" after publish, we should probably update specific fields.
             formState.value.isPublished = initData.isPublished || false;
             // Update roles if they might have changed (though unlikely from publish action)
             // Update flow? No, flow shouldn't change from publish action.
        }
    },
    { deep: true }
);

const visible = computed({
  get: () => props.visible,
  set: (val) => emit('update:visible', val)
});

// const debugVisible = ref(false); // Already declared above

const handleCheck = () => {
  // Basic validation
  if (!formState.value.name) {
      message.error('接口名称不能为空');
      return;
  }
  if (!formState.value.path) {
      message.error('接口路径不能为空');
      return;
  }
  
  let flowData = formState.value.flow;
  if (designerRef.value) {
      flowData = {
        nodes: designerRef.value.nodes,
        edges: designerRef.value.edges
      };
  }
  
  if (!flowData || !flowData.nodes || flowData.nodes.length === 0) {
      message.warning('流程配置为空');
      return;
  }
  
  const hasResponse = flowData.nodes.some((n: any) => n.type === 'response');
  if (!hasResponse) {
      message.warning('建议包含“发送响应”节点，否则接口可能无返回值');
  } else {
      message.success('基本检查通过');
  }
};

const selectedNodeDebugData = ref<any>(null);
const nodeDetailVisible = ref(false);

const handleNodeClick = (nodeId: string | null) => {
    if (!nodeId) {
        // Deselect / Clicked background
        // If we have debug results, show logs instead of hiding
        if (debugResult.value) {
            selectedNodeDebugData.value = null;
            nodeDetailVisible.value = true;
        } else {
            nodeDetailVisible.value = false;
        }
        return;
    }
    
    if (nodeExecutionMap.has(nodeId)) {
        selectedNodeDebugData.value = nodeExecutionMap.get(nodeId);
        nodeDetailVisible.value = true;
    } else {
        // Selected node but no debug data available
        // Show logs? or hide?
        // Let's hide if we select a node that wasn't executed, 
        // OR show empty details? 
        // Better to just hide or show basic info? 
        // Current logic hides it. Let's keep it simple.
        nodeDetailVisible.value = false;
    }
};

const handleDebug = () => {
  debugVisible.value = true;
  debugResult.value = null;
  // Initialize SignalR
  initSignalR();
};

const executeDebug = async () => {
  debugLoading.value = true;
  try {
    let params = {};
    let body = null;
    try {
       params = JSON.parse(debugData.params || '{}');
    } catch(e) {
       message.error('Params JSON 格式错误');
       return;
    }
    try {
       body = JSON.parse(debugData.body || 'null');
    } catch(e) {
       message.error('Body JSON 格式错误');
       return;
    }

    let flowData = formState.value.flow;
    if (designerRef.value) {
        flowData = {
          nodes: designerRef.value.nodes,
          edges: designerRef.value.edges
        };
    }
    
    if (!flowData) {
        message.warning('请先配置接口流程');
        return;
    }

    // Start execution (do not await result to close dialog immediately)
    interfaceApi.debugFlow({
        flowConfig: JSON.stringify(flowData),
        data: {
            params,
            body,
            sessionId: debugSessionId.value // Pass session ID for real-time events
        }
    }).catch(e => {
        message.error('执行请求失败: ' + (e.message || '未知错误'));
    });
    
    // Close debug modal immediately
    debugVisible.value = false;
    message.success('执行已启动');
  } catch (e: any) {
    message.error('参数解析失败: ' + (e.message || '未知错误'));
  } finally {
    debugLoading.value = false;
  }
};

const onClose = () => {
  visible.value = false;
};

const handleSave = () => {
  // If designerRef is available (tab visited), use its data.
  // If not (tab not visited), keep existing flow data from formState.
  let flowData = formState.value.flow;
  
  if (designerRef.value) {
      flowData = {
        nodes: designerRef.value.nodes,
        edges: designerRef.value.edges
      };
  }

  emit('save', {
    ...formState.value,
    flow: flowData
  });
};

const togglePublish = () => {
  const newStatus = !formState.value.isPublished;
  if (newStatus) {
      // If publishing, clear debug state and selection
      clearDebug();
  }
  emit('publish', {
    id: props.editingId,
    isPublished: newStatus
  });
};
</script>

<style scoped>
.drawer-content {
  height: 100%;
  display: flex;
  flex-direction: column;
  background: #fcfcfc;
}

.custom-tabs {
  flex: 1;
  display: flex;
  flex-direction: column;
}

:deep(.ant-tabs-nav) {
  padding: 0 24px;
  margin: 0;
}

:deep(.ant-tabs-content) {
  flex: 1;
  height: 100%;
}

.tab-panel {
  height: 100%;
  overflow-y: auto;
  padding: 24px;
}

.debug-panel {
    height: 0;
    overflow: hidden;
    background: #fff;
    border-top: 1px solid #e8e8e8;
    transition: height 0.3s ease;
    display: flex;
    flex-direction: column;
}

.debug-panel.visible {
    height: 300px;
    padding-bottom: 0;
    box-shadow: 0 -2px 8px rgba(0, 0, 0, 0.15);
    border-top: 1px solid #d9d9d9;
}

.flow-designer-container {
    height: 100%;
    display: flex;
    flex-direction: column;
    position: relative;
    overflow: hidden;
}

.flow-designer-wrapper {
    flex: 1;
    overflow: hidden;
    position: relative;
    transition: height 0.3s ease; 
}

.debug-panel-header {
    padding: 8px 16px;
    border-bottom: 1px solid #f0f0f0;
    display: flex;
    justify-content: space-between;
    align-items: center;
    background: #fafafa;
    font-weight: bold;
}

.debug-panel-content {
    flex: 1;
    overflow: hidden;
    padding: 16px;
}

.json-view {
    background: #f5f5f5; 
    padding: 10px; 
    border-radius: 4px; 
    overflow: auto; 
    font-family: monospace;
    flex: 1;
    margin: 0;
}
</style>
