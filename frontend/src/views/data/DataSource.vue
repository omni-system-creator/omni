<template>
  <div class="page-container" @click="closeContextMenu">
    <div class="left-panel">
      <div class="panel-header">
        <span class="title">数据源连接</span>
        <a-button type="primary" size="small" @click="showAddModal">
          <template #icon><PlusOutlined /></template>
        </a-button>
      </div>
      <div class="tree-container">
        <a-tree
          v-model:expandedKeys="expandedKeys"
          v-model:selectedKeys="selectedKeys"
          :tree-data="treeData"
          :load-data="onLoadData"
          @select="onSelect"
          @rightClick="onRightClick"
        >
          <template #title="{ title, type }">
            <span v-if="type === 'connection'"><DatabaseOutlined /> {{ title }}</span>
            <span v-else-if="type === 'database'"><FolderOutlined /> {{ title }}</span>
            <span v-else-if="type === 'table'"><TableOutlined /> {{ title }}</span>
            <span v-else>{{ title }}</span>
          </template>
        </a-tree>
      </div>
    </div>
    
    <div class="right-panel">
      <a-tabs 
        v-model:activeKey="activeTabKey" 
        type="editable-card" 
        hide-add 
        @edit="onEditTab"
        class="main-tabs"
      >
        <a-tab-pane v-for="pane in panes" :key="pane.key" :tab="pane.title" :closable="pane.closable">
          
          <!-- Connection View: List Databases -->
           <div v-if="pane.type === 'connection'" class="pane-content">
              <div class="pane-header">
                <h3>{{ pane.title }} - 数据库列表</h3>
                <a-space>
                  <a-button type="primary" @click="showCreateDbModal(pane.data.id)">
                    <template #icon><PlusOutlined /></template> 新建数据库
                  </a-button>
                  <a-button @click="refreshNode(pane.data)">
                    <template #icon><ReloadOutlined /></template> 刷新
                  </a-button>
                </a-space>
              </div>
              <a-table 
                :columns="dbColumns" 
                :data-source="pane.contentData" 
                :loading="pane.loading"
                :pagination="false"
                size="middle"
              >
                 <template #bodyCell="{ column, record }">
                   <template v-if="column.key === 'action'">
                     <a v-if="record.type === 'database'" @click="openTabForNode(record)">查看表</a>
                     <a v-else-if="record.type === 'table'" @click="openTabForNode(record)">查看数据</a>
                   </template>
                 </template>
              </a-table>
           </div>
 
           <!-- Database View: List Tables -->
           <div v-else-if="pane.type === 'database'" class="pane-content">
              <div class="pane-header">
                <h3>{{ pane.title }} - 表列表</h3>
                <a-space>
                  <a-button type="primary" @click="showCreateTableModal(pane.data)">
                    <template #icon><PlusOutlined /></template> 新建表
                  </a-button>
                  <a-button @click="refreshNode(pane.data)">
                    <template #icon><ReloadOutlined /></template> 刷新
                  </a-button>
                </a-space>
              </div>
              <a-table 
                :columns="tableListColumns" 
                :data-source="pane.contentData" 
                :loading="pane.loading"
                :pagination="{ pageSize: 15 }"
                size="middle"
              >
                 <template #bodyCell="{ column, record }">
                   <template v-if="column.key === 'action'">
                     <a @click="openTableTab(record, pane.data)">查看数据</a>
                   </template>
                 </template>
              </a-table>
           </div>
 
           <!-- Table View: Details -->
           <div v-else-if="pane.type === 'table'" class="table-details">
             <div class="detail-header">
               <h3>{{ pane.title }}</h3>
               <a-space>
                 <a-button @click="refreshTable(pane)">
                    <template #icon><ReloadOutlined /></template> 刷新
                 </a-button>
               </a-space>
             </div>
            
            <a-tabs v-model:activeKey="pane.activeSubTab">
              <a-tab-pane key="columns" tab="列信息">
                <div style="margin-bottom: 8px">
                  <a-button type="primary" size="small" @click="handleOpenAddColumn(pane)">
                    <template #icon><PlusOutlined /></template> 添加列
                  </a-button>
                </div>
                <a-table :columns="columnDefs" :data-source="pane.columnData" :pagination="false" size="small" bordered :loading="pane.loadingColumns">
                  <template #bodyCell="{ column, record }">
                    <template v-if="['isPrimaryKey', 'isNullable'].includes(column.key)">
                      <a-checkbox :checked="record[column.key]" disabled />
                    </template>
                    <template v-if="column.key === 'action'">
                      <a-space>
                        <a-button type="text" size="small" @click="handleOpenEditColumn(record, pane)">
                           <template #icon><EditOutlined /></template>
                        </a-button>
                        <a-popconfirm title="确定删除该列吗？" @confirm="handleDeleteColumn(record, pane)">
                           <a-button type="text" danger size="small">
                              <template #icon><DeleteOutlined /></template>
                           </a-button>
                        </a-popconfirm>
                      </a-space>
                    </template>
                  </template>
                </a-table>
              </a-tab-pane>
              <a-tab-pane key="data" tab="数据管理">
                 <div class="data-toolbar">
                   <a-space>
                      <a-button type="primary" @click="handleInsertRow(pane)">
                        <template #icon><PlusOutlined /></template> 新增数据
                      </a-button>
                      <a-divider type="vertical" />
                      <a-select v-model:value="pane.queryState.filterField" style="width: 120px" placeholder="选择字段">
                        <a-select-option v-for="col in pane.columnData" :key="col.name" :value="col.name">{{ getFieldLabel(col) }}</a-select-option>
                      </a-select>
                      <a-select v-model:value="pane.queryState.filterOperator" style="width: 100px">
                        <a-select-option value="=">=</a-select-option>
                        <a-select-option value="like">包含</a-select-option>
                        <a-select-option value=">">&gt;</a-select-option>
                        <a-select-option value="<">&lt;</a-select-option>
                      </a-select>
                      <a-input v-model:value="pane.queryState.filterValue" placeholder="输入值" style="width: 200px" allow-clear />
                      <a-button type="primary" @click="executeFilter(pane)">查询</a-button>
                      <a-button @click="resetFilter(pane)">重置</a-button>
                   </a-space>
                 </div>
                 <a-table 
                    :columns="pane.previewColumns" 
                    :data-source="pane.previewData" 
                    :pagination="pane.pagination" 
                    :loading="pane.loadingData"
                    size="small" 
                    scroll="{ x: 'max-content' }" 
                    @change="(pag: any, filters: any, sorter: any) => handleTableChange(pag, filters, sorter, pane)"
                 >
                    <template #bodyCell="{ column, record }">
                        <template v-if="column.key === 'action'">
                            <a-space>
                                <a-button type="text" size="small" @click="handleEditRow(record, pane)">
                                    <template #icon><EditOutlined /></template>
                                </a-button>
                                <a-popconfirm title="确定删除该行吗？" @confirm="handleDeleteRow(record, pane)">
                                    <a-button type="text" danger size="small">
                                        <template #icon><DeleteOutlined /></template>
                                    </a-button>
                                </a-popconfirm>
                            </a-space>
                        </template>
                    </template>
                 </a-table>
              </a-tab-pane>
            </a-tabs>
          </div>
        </a-tab-pane>
      </a-tabs>
    </div>

    <!-- Context Menu -->
    <div 
      v-if="contextMenu.visible" 
      class="context-menu" 
      :style="{ top: `${contextMenu.y}px`, left: `${contextMenu.x}px` }"
    >
      <a-menu>
        <a-menu-item v-if="contextMenu.node.type === 'connection'" key="refresh" @click="handleMenuClick('refresh')">
          <template #icon><ReloadOutlined /></template> 刷新连接
        </a-menu-item>
        <a-menu-item v-if="contextMenu.node.type === 'connection'" key="createDb" @click="handleMenuClick('createDb')">
          <template #icon><PlusCircleOutlined /></template> 新建数据库
        </a-menu-item>
        <a-menu-item v-if="contextMenu.node.type === 'connection'" key="edit" @click="handleMenuClick('edit')">
          <template #icon><EditOutlined /></template> 编辑连接
        </a-menu-item>
        <a-menu-item v-if="contextMenu.node.type === 'connection'" key="delete" danger @click="handleMenuClick('delete')">
          <template #icon><DeleteOutlined /></template> 删除连接
        </a-menu-item>
        
        <a-menu-item v-if="contextMenu.node.type === 'database'" key="refresh" @click="handleMenuClick('refresh')">
          <template #icon><ReloadOutlined /></template> 刷新数据库
        </a-menu-item>
        <a-menu-item v-if="contextMenu.node.type === 'database'" key="createTable" @click="handleMenuClick('createTable')">
           <template #icon><PlusCircleOutlined /></template> 新建表
        </a-menu-item>
        
        <a-menu-item v-if="contextMenu.node.type === 'table'" key="view" @click="handleMenuClick('view')">
          <template #icon><TableOutlined /></template> 查看数据
        </a-menu-item>
        <a-menu-item v-if="contextMenu.node.type === 'table'" key="refresh" @click="handleMenuClick('refresh')">
          <template #icon><ReloadOutlined /></template> 刷新表
        </a-menu-item>
      </a-menu>
    </div>

    <!-- Add Connection Modal -->
    <a-modal v-model:visible="visible" title="新建数据源连接" :confirmLoading="confirmLoading" @ok="handleOk">
      <a-form :model="formState" :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }">
        <a-form-item label="连接名称" required>
          <a-input v-model:value="formState.name" />
        </a-form-item>
        <a-form-item label="数据源类型" required>
          <a-select v-model:value="formState.type">
            <a-select-option value="mysql">MySQL</a-select-option>
            <a-select-option value="postgresql" disabled>PostgreSQL</a-select-option>
            <a-select-option value="oracle" disabled>Oracle</a-select-option>
            <a-select-option value="sqlserver" disabled>SQL Server</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="主机地址" required>
          <a-input v-model:value="formState.host" placeholder="127.0.0.1" />
        </a-form-item>
        <a-form-item label="端口" required>
          <a-input v-model:value="formState.port" placeholder="3306" />
        </a-form-item>
        <a-form-item label="用户名" required>
          <a-input v-model:value="formState.user" />
        </a-form-item>
        <a-form-item label="密码" required>
          <a-input-password v-model:value="formState.password" />
        </a-form-item>
        <a-form-item label="默认数据库">
          <a-input v-model:value="formState.database" />
        </a-form-item>
      </a-form>
      <template #footer>
        <a-button key="test" :loading="testingConnection" @click="handleTestConnection">测试连接</a-button>
        <a-button key="back" @click="visible = false">取消</a-button>
        <a-button key="submit" type="primary" :loading="confirmLoading" @click="handleOk">确定</a-button>
      </template>
    </a-modal>

    <!-- Create Database Modal -->
    <a-modal v-model:visible="createDbVisible" title="新建数据库" :confirmLoading="createDbLoading" @ok="handleCreateDbOk">
      <a-form :model="createDbForm" :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }">
        <a-form-item label="数据库名称" required>
          <a-input v-model:value="createDbForm.name" placeholder="请输入数据库名称" />
        </a-form-item>
        <a-form-item label="字符集">
          <a-select v-model:value="createDbForm.charSet">
            <a-select-option value="utf8mb4">utf8mb4</a-select-option>
            <a-select-option value="utf8">utf8</a-select-option>
            <a-select-option value="latin1">latin1</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="排序规则">
          <a-select v-model:value="createDbForm.collation">
            <a-select-option value="utf8mb4_general_ci">utf8mb4_general_ci</a-select-option>
            <a-select-option value="utf8mb4_unicode_ci">utf8mb4_unicode_ci</a-select-option>
            <a-select-option value="utf8_general_ci">utf8_general_ci</a-select-option>
          </a-select>
        </a-form-item>
      </a-form>
    </a-modal>

    <!-- Create Table Modal -->
    <a-modal v-model:visible="createTableVisible" title="新建表" width="900px" :confirmLoading="createTableLoading" @ok="handleCreateTableOk">
      <a-form :model="createTableForm" layout="inline" style="margin-bottom: 16px">
        <a-form-item label="表名" required>
          <a-input v-model:value="createTableForm.name" placeholder="表名" />
        </a-form-item>
        <a-form-item label="引擎">
          <a-select v-model:value="createTableForm.engine" style="width: 100px">
            <a-select-option value="InnoDB">InnoDB</a-select-option>
            <a-select-option value="MyISAM">MyISAM</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="字符集">
           <a-select v-model:value="createTableForm.charSet" style="width: 120px">
            <a-select-option value="utf8mb4">utf8mb4</a-select-option>
            <a-select-option value="utf8">utf8</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="备注">
          <a-input v-model:value="createTableForm.comment" placeholder="备注" />
        </a-form-item>
      </a-form>

      <div class="table-columns-editor">
         <div style="margin-bottom: 8px">
            <a-button type="dashed" block @click="addColumn">
              <template #icon><PlusOutlined /></template> 添加列
            </a-button>
         </div>
         <a-table :data-source="createTableForm.columns" :pagination="false" size="small" bordered :scroll="{ y: 400 }">
           <a-table-column title="列名" width="150px">
              <template #default="{ record }">
                <a-input v-model:value="record.name" />
              </template>
           </a-table-column>
           <a-table-column title="类型" width="120px">
              <template #default="{ record }">
                <a-select v-model:value="record.dataType" style="width: 100%">
                   <a-select-option value="int">int</a-select-option>
                   <a-select-option value="varchar">varchar</a-select-option>
                   <a-select-option value="text">text</a-select-option>
                   <a-select-option value="datetime">datetime</a-select-option>
                   <a-select-option value="decimal">decimal</a-select-option>
                   <a-select-option value="bigint">bigint</a-select-option>
                   <a-select-option value="tinyint">tinyint</a-select-option>
                   <a-select-option value="double">double</a-select-option>
                   <a-select-option value="date">date</a-select-option>
                </a-select>
              </template>
           </a-table-column>
           <a-table-column title="长度" width="80px">
              <template #default="{ record }">
                <a-input-number v-model:value="record.length" style="width: 100%" :disabled="['text', 'datetime', 'date'].includes(record.dataType)" />
              </template>
           </a-table-column>
           <a-table-column title="主键" width="60px" align="center">
              <template #default="{ record }">
                <a-checkbox v-model:checked="record.isPrimaryKey" />
              </template>
           </a-table-column>
           <a-table-column title="非空" width="60px" align="center">
              <template #default="{ record }">
                <a-checkbox v-model:checked="record.isNullable" :disabled="record.isPrimaryKey">
                   <template #checkedChildren>空</template>
                   <template #unCheckedChildren>非</template>
                </a-checkbox>
                <!-- Wait, checkbox semantics: checked usually means true. 
                     isNullable=true means allow null. 
                     isNullable=false means NOT NULL.
                     So checked = Allow Null. 
                     If PK, must be NOT NULL (unchecked).
                -->
              </template>
           </a-table-column>
           <a-table-column title="自增" width="60px" align="center">
              <template #default="{ record }">
                <a-checkbox v-model:checked="record.isAutoIncrement" :disabled="!['int', 'bigint', 'tinyint'].includes(record.dataType) || !record.isPrimaryKey" />
              </template>
           </a-table-column>
           <a-table-column title="默认值" width="100px">
              <template #default="{ record }">
                <a-input v-model:value="record.defaultValue" />
              </template>
           </a-table-column>
           <a-table-column title="注释">
              <template #default="{ record }">
                <a-input v-model:value="record.comment" />
              </template>
           </a-table-column>
           <a-table-column title="操作" width="60px" align="center">
              <template #default="{ index }">
                <a-button type="text" danger size="small" @click="removeColumn(index)">
                   <template #icon><DeleteOutlined /></template>
                </a-button>
              </template>
           </a-table-column>
         </a-table>
      </div>
    </a-modal>

    <!-- Column Add/Edit Modal -->
    <a-modal
      v-model:visible="columnModal.visible"
      :title="columnModal.mode === 'add' ? '添加列' : '修改列'"
      :confirmLoading="columnModal.loading"
      @ok="handleSaveColumn"
      width="700px"
    >
      <a-form :model="columnModal.formData" :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }">
        <a-form-item label="列名" required>
          <a-input v-model:value="columnModal.formData.name" />
        </a-form-item>
        
        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="类型" required :label-col="{ span: 12 }" :wrapper-col="{ span: 12 }">
              <a-select v-model:value="columnModal.formData.dataType" style="width: 100%">
                 <a-select-option value="int">int</a-select-option>
                 <a-select-option value="varchar">varchar</a-select-option>
                 <a-select-option value="text">text</a-select-option>
                 <a-select-option value="datetime">datetime</a-select-option>
                 <a-select-option value="decimal">decimal</a-select-option>
                 <a-select-option value="bigint">bigint</a-select-option>
                 <a-select-option value="tinyint">tinyint</a-select-option>
                 <a-select-option value="double">double</a-select-option>
                 <a-select-option value="date">date</a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
          <a-col :span="12">
             <a-form-item label="长度/精度" :label-col="{ span: 8 }" :wrapper-col="{ span: 16 }">
                <a-input-number v-model:value="columnModal.formData.length" style="width: 100%" :disabled="['text', 'datetime', 'date'].includes(columnModal.formData.dataType)" />
             </a-form-item>
          </a-col>
        </a-row>

        <a-form-item label="属性">
            <a-checkbox v-model:checked="columnModal.formData.isPrimaryKey">主键</a-checkbox>
            <a-checkbox v-model:checked="columnModal.formData.isNullable" :disabled="columnModal.formData.isPrimaryKey">允许空</a-checkbox>
            <a-checkbox v-model:checked="columnModal.formData.isAutoIncrement" :disabled="!['int', 'bigint', 'tinyint'].includes(columnModal.formData.dataType)">自增</a-checkbox>
        </a-form-item>

        <a-form-item label="默认值">
          <a-input v-model:value="columnModal.formData.defaultValue" />
        </a-form-item>

        <a-form-item label="注释">
          <a-input v-model:value="columnModal.formData.comment" />
        </a-form-item>

        <a-divider>位置调整</a-divider>
        
        <a-form-item label="插入位置">
           <a-radio-group v-model:value="columnModal.positionType">
              <a-radio value="last" v-if="columnModal.mode === 'add'">最后</a-radio>
              <a-radio value="current" v-if="columnModal.mode === 'edit'">保持不变</a-radio>
              <a-radio value="first">最前</a-radio>
              <a-radio value="after">指定列之后</a-radio>
           </a-radio-group>
        </a-form-item>
        
        <a-form-item v-if="columnModal.positionType === 'after'" label="选择列">
           <a-select v-model:value="columnModal.formData.afterColumn">
              <a-select-option v-for="col in columnModal.existingColumns" :key="col.name" :value="col.name">{{ col.name }}</a-select-option>
           </a-select>
        </a-form-item>

      </a-form>
    </a-modal>

    <!-- Row Edit Modal -->
    <a-modal
      v-model:visible="rowModal.visible"
      :title="rowModal.mode === 'insert' ? '新增数据' : '编辑数据'"
      :confirmLoading="rowModal.loading"
      @ok="handleSaveRow"
      width="600px"
    >
      <a-form :model="rowModal.formData" :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }">
        <template v-if="rowModal.pane && rowModal.pane.columnData">
            <a-form-item 
                v-for="col in rowModal.pane.columnData" 
                :key="col.name" 
                :label="getFieldLabel(col)"
                :required="!col.isNullable && col.defaultValue === null && !col.isAutoIncrement"
            >
                <!-- Auto Increment: Usually Readonly or Hidden in Insert? MySQL allows setting AI value. But usually hidden. -->
                <!-- If PK and AI: Disable in Insert? Usually yes. -->
                <!-- If PK and Not AI: Enable in Insert. -->
                <!-- In Edit: PK usually disabled (unless we support PK update). -->
                
                <a-input 
                    v-if="['varchar', 'char', 'text', 'longtext'].includes(col.columnType) || col.dataType === 'string'"
                    v-model:value="rowModal.formData[col.name]" 
                    :disabled="rowModal.mode === 'edit' && col.isPrimaryKey"
                />
                
                <a-input-number 
                    v-else-if="['int', 'bigint', 'tinyint', 'smallint', 'decimal', 'double', 'float'].includes(col.columnType) || col.dataType === 'number'"
                    v-model:value="rowModal.formData[col.name]"
                    style="width: 100%"
                    :disabled="(col.isAutoIncrement && rowModal.mode === 'insert') || (rowModal.mode === 'edit' && col.isPrimaryKey)"
                />
                
                <a-date-picker 
                    v-else-if="['datetime', 'timestamp'].includes(col.columnType)"
                    v-model:value="rowModal.formData[col.name]"
                    show-time
                    value-format="YYYY-MM-DD HH:mm:ss"
                    style="width: 100%"
                    :disabled="rowModal.mode === 'edit' && col.isPrimaryKey"
                />
                 <a-date-picker 
                    v-else-if="['date'].includes(col.columnType)"
                    v-model:value="rowModal.formData[col.name]"
                    value-format="YYYY-MM-DD"
                    style="width: 100%"
                    :disabled="rowModal.mode === 'edit' && col.isPrimaryKey"
                />

                <a-switch 
                     v-else-if="['bit', 'boolean'].includes(col.columnType)"
                     v-model:checked="rowModal.formData[col.name]"
                     :disabled="rowModal.mode === 'edit' && col.isPrimaryKey"
                />

                <a-input 
                    v-else 
                    v-model:value="rowModal.formData[col.name]"
                    :disabled="rowModal.mode === 'edit' && col.isPrimaryKey"
                />
                
                <div v-if="col.comment" style="font-size: 12px; color: #999">{{ col.comment }}</div>
            </a-form-item>
        </template>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue';
import { message, Modal } from 'ant-design-vue';
import { 
  PlusOutlined, 
  DatabaseOutlined, 
  FolderOutlined, 
  TableOutlined,
  ReloadOutlined,
  PlusCircleOutlined,
  EditOutlined,
  DeleteOutlined
} from '@ant-design/icons-vue';
import * as api from '@/api/dataSource';
import type {
  CreateTableDto,
  ColumnDefinitionDto,
  AddColumnDto,
  ModifyColumnDto
} from '@/api/dataSource';

const getFieldLabel = (col: any) => {
  if (!col.comment) return col.name;
  // Split by comma (Chinese or English)
  let label = col.comment.split(/,|，/)[0];
  // Truncate if too long (e.g., > 8 chars)
  if (label.length > 8) {
    label = label.substring(0, 8) + '...';
  }
  return label;
};

const expandedKeys = ref<string[]>([]);
const selectedKeys = ref<string[]>([]);
const activeTabKey = ref<string>('');
const visible = ref(false);
const confirmLoading = ref(false);
const testingConnection = ref(false);

// Create Database State
const createDbVisible = ref(false);
const createDbLoading = ref(false);
const currentConnectionId = ref<number>(0);
const createDbForm = reactive({
  name: '',
  charSet: 'utf8mb4',
  collation: 'utf8mb4_general_ci'
});

const createTableVisible = ref(false);
const createTableLoading = ref(false);
const currentDatabaseNode = ref<any>(null);
const createTableForm = reactive<CreateTableDto>({
  name: '',
  comment: '',
  engine: 'InnoDB',
  charSet: 'utf8mb4',
  collation: 'utf8mb4_general_ci',
  columns: []
});

const newColumn = (): ColumnDefinitionDto => ({
  name: '',
  dataType: 'varchar',
  length: 255,
  isNullable: true,
  isPrimaryKey: false,
  isAutoIncrement: false,
  defaultValue: '',
  comment: ''
});

// Tab State
interface Pane {
  title: string;
  key: string;
  type: 'connection' | 'database' | 'table';
  closable?: boolean;
  data: any; // Node data
  contentData?: any[]; // For lists (DBs, Tables)
  loading?: boolean;
  // For Table Details
  activeSubTab?: string;
  loadingColumns?: boolean;
  columnData?: any[];
  loadingData?: boolean;
  previewData?: any[];
  previewColumns?: any[];
  pagination?: any;
  queryState?: any;
}

const panes = ref<Pane[]>([]);

// Context Menu State
const contextMenu = reactive({
  visible: false,
  x: 0,
  y: 0,
  node: null as any
});

const rowModal = reactive({
  visible: false,
  mode: 'insert' as 'insert' | 'edit',
  loading: false,
  pane: null as Pane | null,
  formData: {} as Record<string, any>,
  originalKeys: {} as Record<string, any>
});

const isEditMode = ref(false);
const currentDataSourceId = ref(0);

const formState = reactive({
  name: '',
  type: 'mysql',
  host: '',
  port: '3306',
  user: '',
  password: '',
  database: '',
});

const treeData = ref<any[]>([]);

// List Columns
const dbColumns = [
  { title: '数据库名称', dataIndex: 'name', key: 'name' },
  { title: '字符集', dataIndex: 'charSet', key: 'charSet' },
  { title: '排序规则', dataIndex: 'collation', key: 'collation' },
  { title: '表数量', dataIndex: 'tableCount', key: 'tableCount' },
  { title: '数据大小', dataIndex: 'dataLength', key: 'dataLength' },
  { title: '操作', key: 'action', width: 150 }
];

const tableListColumns = [
  { title: '表名称', dataIndex: 'name', key: 'name' },
  { title: '备注', dataIndex: 'comment', key: 'comment' },
  { title: '行数', dataIndex: 'rows', key: 'rows' },
  { title: '数据大小', dataIndex: 'dataLength', key: 'dataLength' },
  { title: '操作', key: 'action', width: 150 }
];

// Columns Definition (for Table Details)
const columnDefs = [
  { title: '列名', dataIndex: 'name', key: 'name' },
  { title: '类型', dataIndex: 'columnType', key: 'columnType' },
  { title: 'PK', dataIndex: 'isPrimaryKey', key: 'isPrimaryKey', width: 60, align: 'center' },
  { title: 'Null', dataIndex: 'isNullable', key: 'isNullable', width: 60, align: 'center' },
  { title: '默认值', dataIndex: 'defaultValue', key: 'defaultValue' },
  { title: '注释', dataIndex: 'comment', key: 'comment' },
  { title: '操作', key: 'action', width: 120 }
];

// Load Initial Data Sources
const loadDataSources = async () => {
  try {
    const res = await api.getDataSources();
    if (res) {
      treeData.value = res.map((item: any) => ({
        title: item.name,
        key: `conn-${item.id}`,
        type: 'connection',
        id: item.id,
        isLeaf: false
      }));
    }
  } catch (error) {
    message.error('加载数据源失败');
  }
};

onMounted(() => {
  loadDataSources();
});

// Async Tree Load
const onLoadData = (treeNode: any): Promise<void> => {
  return new Promise(async (resolve) => {
    if (treeNode.children && treeNode.children.length > 0) {
      resolve();
      return;
    }

    try {
      if (treeNode.type === 'connection') {
        const res = await api.getDatabases(treeNode.id);
        if (res) {
          treeNode.dataRef.children = res.map((db: any) => ({
            title: db.name,
            key: `db-${treeNode.id}-${db.name}`,
            type: 'database',
            connectionId: treeNode.id,
            name: db.name,
            isLeaf: false
          }));
          treeData.value = [...treeData.value];
        }
      } else if (treeNode.type === 'database') {
        const res = await api.getTables(treeNode.connectionId, treeNode.name);
        if (res) {
          treeNode.dataRef.children = res.map((tb: any) => ({
            title: tb.name,
            key: `tb-${treeNode.connectionId}-${treeNode.name}-${tb.name}`,
            type: 'table',
            connectionId: treeNode.connectionId,
            databaseName: treeNode.name,
            tableName: tb.name,
            isLeaf: true
          }));
          treeData.value = [...treeData.value];
        }
      }
    } catch (error) {
      message.error('加载子节点失败');
    }
    resolve();
  });
};

const onSelect = (_keys: string[], info: any) => {
  if (info.selected) {
    openTabForNode(info.node);
  }
};

const openTabForNode = (node: any) => {
  const existingPane = panes.value.find(p => p.key === node.key);
  if (existingPane) {
    activeTabKey.value = existingPane.key;
    return;
  }

  const newPane: Pane = {
    title: node.title,
    key: node.key,
    type: node.type,
    closable: true,
    data: node,
    loading: false
  };

  if (node.type === 'connection') {
    newPane.contentData = [];
    panes.value.push(newPane);
    activeTabKey.value = newPane.key;
    refreshNode(node);
  } else if (node.type === 'database') {
    newPane.contentData = [];
    panes.value.push(newPane);
    activeTabKey.value = newPane.key;
    refreshNode(node);
  } else if (node.type === 'table') {
    // Initialize Table Detail State
    newPane.activeSubTab = 'columns';
    newPane.columnData = [];
    newPane.previewData = [];
    newPane.previewColumns = [];
    newPane.pagination = {
      current: 1,
      pageSize: 20,
      total: 0,
      showSizeChanger: true,
      pageSizeOptions: ['10', '20', '50', '100']
    };
    newPane.queryState = {
      filterField: undefined,
      filterOperator: '=',
      filterValue: '',
      sortField: '',
      sortOrder: ''
    };
    
    panes.value.push(newPane);
    activeTabKey.value = newPane.key;
    const reactivePane = panes.value.find(p => p.key === newPane.key);
    if (reactivePane) {
      refreshTable(reactivePane);
    }
  }
};

const onEditTab = (targetKey: string, action: string) => {
  if (action === 'remove') {
    const targetIndex = panes.value.findIndex(pane => pane.key === targetKey);
    if (targetIndex >= 0) {
      panes.value.splice(targetIndex, 1);
      if (activeTabKey.value === targetKey) {
        if (panes.value.length > 0) {
          const nextPane = panes.value[Math.min(targetIndex, panes.value.length - 1)];
          if (nextPane) {
            activeTabKey.value = nextPane.key;
          }
        } else {
          activeTabKey.value = '';
        }
      }
    }
  }
};

const formatBytes = (bytes: number, decimals = 2) => {
    if (!bytes) return '0 B';
    const k = 1024;
    const dm = decimals < 0 ? 0 : decimals;
    const sizes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
};

// --- Column Management Logic ---

const columnModal = reactive({
  visible: false,
  mode: 'add' as 'add' | 'edit',
  loading: false,
  pane: null as Pane | null,
  formData: {
     name: '',
     dataType: 'varchar',
     length: 255,
     isNullable: true,
     isPrimaryKey: false,
     isAutoIncrement: false,
     defaultValue: '',
     comment: '',
     isFirst: false,
     afterColumn: undefined as string | undefined
  },
  positionType: 'last', // 'last', 'first', 'after', 'current'
  existingColumns: [] as any[],
  originalName: ''
});

const handleOpenAddColumn = (pane: Pane) => {
  columnModal.pane = pane;
  columnModal.mode = 'add';
  // Reset form
  columnModal.formData = {
     name: '',
     dataType: 'varchar',
     length: 255,
     isNullable: true,
     isPrimaryKey: false,
     isAutoIncrement: false,
     defaultValue: '',
     comment: '',
     isFirst: false,
     afterColumn: undefined
  };
  columnModal.positionType = 'last';
  columnModal.existingColumns = pane.columnData || [];
  columnModal.visible = true;
};

const handleOpenEditColumn = (record: any, pane: Pane) => {
  columnModal.pane = pane;
  columnModal.mode = 'edit';
  columnModal.originalName = record.name;
  
  // Try to parse length from columnType, e.g. "varchar(255)"
  let length = 255;
  const match = (record.columnType || '').match(/\((\d+)(?:,(\d+))?\)/);
  if (match) {
      length = parseInt(match[1]);
  }

  columnModal.formData = {
     name: record.name,
     dataType: record.dataType,
     length: length,
     isNullable: record.isNullable,
     isPrimaryKey: record.isPrimaryKey,
     isAutoIncrement: (record.columnType || '').toLowerCase().includes('auto_increment'),
     defaultValue: record.defaultValue,
     comment: record.comment,
     isFirst: false,
     afterColumn: undefined
  };
  
  columnModal.positionType = 'current'; // Default: No move
  columnModal.existingColumns = (pane.columnData || []).filter((c: any) => c.name !== record.name);
  columnModal.visible = true;
};

const handleSaveColumn = async () => {
   if (!columnModal.pane) return;
   
   if (!columnModal.formData.name) {
       message.error('请输入列名');
       return;
   }

   columnModal.loading = true;
   try {
       const pane = columnModal.pane;
       const connId = pane.data.connectionId;
       const dbName = pane.data.databaseName;
       const tbName = pane.data.tableName;
       
       const commonData = {
           name: columnModal.formData.name,
           dataType: columnModal.formData.dataType,
           length: columnModal.formData.length,
           isNullable: columnModal.formData.isNullable,
           isPrimaryKey: columnModal.formData.isPrimaryKey,
           isAutoIncrement: columnModal.formData.isAutoIncrement,
           defaultValue: columnModal.formData.defaultValue,
           comment: columnModal.formData.comment,
       };

       if (columnModal.mode === 'add') {
           const dto: AddColumnDto = {
               ...commonData,
               isFirst: columnModal.positionType === 'first',
               afterColumn: columnModal.positionType === 'after' ? columnModal.formData.afterColumn : undefined
           };
           
           await api.addColumn(connId, dbName, tbName, dto);
           message.success('添加列成功');
       } else {
           // Edit
           const dto: ModifyColumnDto = {
               ...commonData,
               newName: columnModal.formData.name !== columnModal.originalName ? columnModal.formData.name : undefined,
               isFirst: columnModal.positionType === 'first',
               afterColumn: columnModal.positionType === 'after' ? columnModal.formData.afterColumn : undefined
           };
           
           await api.modifyColumn(connId, dbName, tbName, columnModal.originalName, dto);
           message.success('修改列成功');
       }
       
       columnModal.visible = false;
       loadColumns(pane); // Refresh columns
   } catch (error) {
       console.error(error);
       message.error(columnModal.mode === 'add' ? '添加列失败' : '修改列失败');
   } finally {
       columnModal.loading = false;
   }
};

const handleDeleteColumn = async (record: any, pane: Pane) => {
    try {
        await api.deleteColumn(pane.data.connectionId, pane.data.databaseName, pane.data.tableName, record.name);
        message.success('删除列成功');
        loadColumns(pane);
    } catch (error) {
        message.error('删除列失败');
    }
};

// --- View List Logic ---

const fetchNodeChildren = async (nodeData: any) => {
  if (nodeData.type === 'connection') {
    const res = await api.getDatabases(nodeData.id);
    if (res) {
      return res.map((db: any) => ({
        title: db.name,
        key: `db-${nodeData.id}-${db.name}`,
        type: 'database',
        connectionId: nodeData.id,
        name: db.name,
        charSet: db.charSet,
        collation: db.collation,
        tableCount: db.tableCount,
        dataLength: formatBytes(db.dataLength),
        isLeaf: false
      }));
    }
  } else if (nodeData.type === 'database') {
    const res = await api.getTables(nodeData.connectionId, nodeData.name);
    if (res) {
      return res.map((tb: any) => ({
        title: tb.name,
        key: `tb-${nodeData.connectionId}-${nodeData.name}-${tb.name}`,
        type: 'table',
        connectionId: nodeData.connectionId,
        databaseName: nodeData.name,
        tableName: tb.name,
        name: tb.name,
        comment: tb.comment,
        rows: tb.rows,
        dataLength: formatBytes(tb.dataLength),
        isLeaf: true
      }));
    }
  }
  return [];
};

const refreshNode = async (node: any) => {
  const nodeData = node.dataRef || node;
  const pane = panes.value.find(p => p.key === nodeData.key);
  
  if (pane) pane.loading = true;
  
  try {
    const children = await fetchNodeChildren(nodeData);
    
    // Update Tree Data
    nodeData.children = children;
    treeData.value = [...treeData.value];
    
    // Update Tab Data if exists
    if (pane) {
      pane.contentData = children;
    }
    message.success('刷新成功');
  } catch (error) {
    message.error('刷新失败');
  } finally {
    if (pane) pane.loading = false;
  }
};


const openTableTab = (record: any, parentNode: any) => {
  const node = {
    ...record,
    connectionId: parentNode.connectionId,
    databaseName: parentNode.name,
    tableName: record.name,
    type: 'table',
    title: record.name,
    key: `tb-${parentNode.connectionId}-${parentNode.name}-${record.name}`
  };
  openTabForNode(node);
};

// --- Table Detail Logic ---

const loadColumns = async (pane: Pane) => {
  pane.loadingColumns = true;
  try {
    const res = await api.getColumns(
      pane.data.connectionId, 
      pane.data.databaseName, 
      pane.data.tableName
    );
    if (res) {
      // Normalize comment (handle potential casing issues)
      pane.columnData = res.map((col: any) => ({
          ...col,
          comment: col.comment || col.Comment || ''
      }));
    }
  } catch (error) {
    message.error('加载列信息失败');
  } finally {
    pane.loadingColumns = false;
  }
};

const loadTableData = async (pane: Pane) => {
  pane.loadingData = true;
  
  const filters = [];
  if (pane.queryState.filterField && pane.queryState.filterValue) {
    filters.push({
      field: pane.queryState.filterField,
      operator: pane.queryState.filterOperator,
      value: pane.queryState.filterValue
    });
  }

  const query = {
    page: pane.pagination.current,
    pageSize: pane.pagination.pageSize,
    sortField: pane.queryState.sortField,
    sortOrder: pane.queryState.sortOrder,
    filters: filters
  };

  try {
    const res = await api.getTableData(
      pane.data.connectionId, 
      pane.data.databaseName, 
      pane.data.tableName,
      query
    );
    
    // Check res directly as per previous fix
    if (res && res.rows) {
      const result = res; // Assuming res is the data object
      pane.pagination.total = result.total;
      
      if (result.columns && result.columns.length > 0) {
        const cols: any[] = result.columns.map((col: any) => {
          // col is now ColumnSchema object from backend
          return {
            title: getFieldLabel(col),
            dataIndex: col.name,
            key: col.name,
            width: 150,
            ellipsis: true,
            sorter: true,
            tooltip: col.name
          };
        });
        // Add Action Column
        cols.push({
            title: '操作',
            key: 'action',
            width: 120,
            fixed: 'right'
        });
        pane.previewColumns = cols;
      }
      
      pane.previewData = result.rows;
    } else {
        // Fallback or if structure is different
        // Based on previous edit, api returns res.data directly if success
        if (res.rows) {
             pane.pagination.total = res.total;
             if (res.columns) {
                const cols: any[] = res.columns.map((col: any) => {
                  return {
                    title: getFieldLabel(col),
                    dataIndex: col.name,
                    key: col.name,
                    width: 150,
                    ellipsis: true,
                    sorter: true,
                    tooltip: col.name
                  };
                });
                cols.push({
                    title: '操作',
                    key: 'action',
                    width: 120,
                    fixed: 'right'
                });
                pane.previewColumns = cols;
             }
             pane.previewData = res.rows;
        }
    }
  } catch (error) {
    message.error('加载数据失败');
  } finally {
    pane.loadingData = false;
  }
};

const handleTableChange = (pag: any, _filters: any, sorter: any, pane: Pane) => {
  pane.pagination.current = pag.current;
  pane.pagination.pageSize = pag.pageSize;
  
  if (sorter.field) {
    pane.queryState.sortField = sorter.field;
    pane.queryState.sortOrder = sorter.order === 'ascend' ? 'asc' : (sorter.order === 'descend' ? 'desc' : '');
  }
  
  loadTableData(pane);
};

const executeFilter = (pane: Pane) => {
  pane.pagination.current = 1;
  loadTableData(pane);
};

const resetFilter = (pane: Pane) => {
  pane.queryState.filterField = undefined;
  pane.queryState.filterOperator = '=';
  pane.queryState.filterValue = '';
  pane.queryState.sortField = '';
  pane.queryState.sortOrder = '';
  executeFilter(pane);
};

const refreshTable = async (pane: Pane) => {
  await loadColumns(pane);
  // Always load data if on data tab or just refresh it anyway? 
  // Let's load data if it was already loaded or just to be safe
  loadTableData(pane); 
};

// --- Row CRUD Operations ---

const handleInsertRow = (pane: Pane) => {
  rowModal.pane = pane;
  rowModal.mode = 'insert';
  rowModal.formData = {};
  
  // Initialize default values
  if (pane.columnData) {
      pane.columnData.forEach(col => {
          if (col.defaultValue !== null) {
             rowModal.formData[col.name] = col.defaultValue;
          } else {
             rowModal.formData[col.name] = null; // or undefined
          }
      });
  }
  
  rowModal.visible = true;
};

const handleEditRow = (record: any, pane: Pane) => {
  rowModal.pane = pane;
  rowModal.mode = 'edit';
  rowModal.formData = { ...record }; // Clone data
  
  // Extract Primary Keys for identification
  rowModal.originalKeys = {};
  if (pane.columnData) {
      pane.columnData.filter(c => c.isPrimaryKey).forEach(c => {
          rowModal.originalKeys[c.name] = record[c.name];
      });
  }
  
  // If no PK defined, we might have trouble updating. 
  // Warn user? Or try to use all columns as keys?
  // Ideally, backend needs PKs.
  const pkCount = Object.keys(rowModal.originalKeys).length;
  if (pkCount === 0) {
      message.warning('该表没有主键，无法精确更新行数据');
      // Still allow trying? Maybe unsafe.
  }
  
  rowModal.visible = true;
};

const handleDeleteRow = async (record: any, pane: Pane) => {
  const keys: Record<string, any> = {};
  if (pane.columnData) {
      pane.columnData.filter(c => c.isPrimaryKey).forEach(c => {
          keys[c.name] = record[c.name];
      });
  }
  
  if (Object.keys(keys).length === 0) {
      message.error('该表没有主键，无法删除行数据');
      return;
  }
  
  try {
      await api.deleteRow(pane.data.connectionId, pane.data.databaseName, pane.data.tableName, keys);
      message.success('删除成功');
      loadTableData(pane);
  } catch (error) {
      message.error('删除失败');
  }
};

const handleSaveRow = async () => {
  if (!rowModal.pane) return;
  
  rowModal.loading = true;
  try {
      const pane = rowModal.pane;
      const connId = pane.data.connectionId;
      const dbName = pane.data.databaseName;
      const tbName = pane.data.tableName;
      
      if (rowModal.mode === 'insert') {
          // Filter out nulls if column is auto-increment and value is null/empty?
          // Or just send everything and let backend/DB handle.
          // If AutoIncrement and null/0, usually DB generates it.
          // But if we send explicit null for NOT NULL AI column, it might fail or work depending on strict mode.
          // Let's try sending as is.
          
          await api.insertRow(connId, dbName, tbName, rowModal.formData);
          message.success('新增成功');
      } else {
          await api.updateRow(connId, dbName, tbName, rowModal.originalKeys, rowModal.formData);
          message.success('更新成功');
      }
      
      rowModal.visible = false;
      loadTableData(pane);
  } catch (error) {
      console.error(error);
      message.error(rowModal.mode === 'insert' ? '新增失败' : '更新失败');
  } finally {
      rowModal.loading = false;
  }
};

// --- Context Menu ---

const onRightClick = ({ event, node }: any) => {
  contextMenu.visible = true;
  contextMenu.x = event.clientX;
  contextMenu.y = event.clientY;
  contextMenu.node = node;
};

const closeContextMenu = () => {
  contextMenu.visible = false;
};

const showCreateDbModal = (connectionId: number) => {
  currentConnectionId.value = connectionId;
  createDbForm.name = '';
  createDbForm.charSet = 'utf8mb4';
  createDbForm.collation = 'utf8mb4_general_ci';
  createDbVisible.value = true;
};

const handleCreateDbOk = async () => {
  if (!createDbForm.name) {
    message.warning('请输入数据库名称');
    return;
  }
  
  createDbLoading.value = true;
  try {
    await api.createDatabase(currentConnectionId.value, createDbForm);
    message.success('数据库创建成功');
    createDbVisible.value = false;
    
    // Refresh the connection node to show the new database
    const pane = panes.value.find(p => p.type === 'connection' && p.data.id === currentConnectionId.value);
    if (pane) {
      refreshNode(pane.data);
    } else {
      // If no tab is open, we might want to find the tree node and refresh it, 
      // but refreshNode logic handles tree update too.
      // We just need the node object. 
      // If we don't have the node object easily, we can reload the whole datasource list or just let user refresh manually.
      // But refreshNode(pane.data) works if pane exists.
      // If pane doesn't exist, we might need to find the node in treeData.
      const node = treeData.value.find(n => n.key === `conn-${currentConnectionId.value}`);
      if (node) refreshNode(node);
    }
  } catch (error) {
    // Error is handled by interceptor usually, but if not:
    console.error(error);
  } finally {
    createDbLoading.value = false;
  }
};

const showCreateTableModal = (databaseNode: any) => {
  currentDatabaseNode.value = databaseNode;
  createTableForm.name = '';
  createTableForm.comment = '';
  createTableForm.columns = [
    { ...newColumn(), name: 'id', dataType: 'int', length: 11, isPrimaryKey: true, isAutoIncrement: true, isNullable: false }
  ];
  createTableVisible.value = true;
};

const addColumn = () => {
  createTableForm.columns.push(newColumn());
};

const removeColumn = (index: number) => {
  if (createTableForm.columns.length > 1) {
    createTableForm.columns.splice(index, 1);
  } else {
    message.warning('至少保留一列');
  }
};

const handleCreateTableOk = async () => {
  if (!createTableForm.name) {
    message.warning('请输入表名');
    return;
  }
  if (createTableForm.columns.length === 0) {
     message.warning('请至少添加一列');
     return;
  }
  // Validate columns
  for(const col of createTableForm.columns) {
    if (!col.name) {
       message.warning('列名不能为空');
       return;
    }
  }

  createTableLoading.value = true;
  try {
    // If called from tree node (type='database'), node structure might vary from tab pane data
    // Tree Node: { key, title, type: 'database', connectionId, name (dbname), ... }
    // Tab Pane Data: { id: connectionId, name: dbname } or similar?
    // Let's verify structure. 
    // Tree Node for DB: key=`db-${connId}-${dbName}`, title=dbName, type='database', connectionId=connId, name=dbName
    
    // Actually in showCreateTableModal(pane.data) where pane.type='database', pane.data is the DB node data.
    
    const connId = currentDatabaseNode.value.connectionId;
    const dbName = currentDatabaseNode.value.name;

    await api.createTable(connId, dbName, createTableForm);
    message.success('表创建成功');
    createTableVisible.value = false;
    
    // Refresh the database node/tab
    refreshNode(currentDatabaseNode.value);
    
  } catch (error) {
    console.error(error);
  } finally {
    createTableLoading.value = false;
  }
};

const handleEditDataSource = async (node: any) => {
  isEditMode.value = true;
  currentDataSourceId.value = node.id;
  try {
    const res = await api.getDataSource(node.id);
    if (res) {
      formState.name = res.name;
      formState.type = res.type;
      formState.host = res.host;
      formState.port = res.port;
      formState.user = res.user;
      formState.database = res.database;
      formState.password = ''; // Do not fill password for security
      visible.value = true;
    }
  } catch (e) {
    message.error('获取连接详情失败');
  }
};

const handleDeleteDataSource = (node: any) => {
  Modal.confirm({
    title: '确定删除该数据源连接吗？',
    content: '删除后无法恢复，且会清空相关的配置信息。',
    okText: '确认',
    cancelText: '取消',
    onOk: async () => {
      try {
        await api.deleteDataSource(node.id);
        message.success('删除成功');
        loadDataSources();
      } catch (e) {
        message.error('删除失败');
      }
    }
  });
};

const handleMenuClick = (action: string) => {
  const node = contextMenu.node;
  closeContextMenu();

  if (action === 'refresh') {
    if (node.dataRef) {
       node.dataRef.children = [];
    }
    refreshNode(node);
    message.success('刷新请求已发送');
  } else if (action === 'createDb') {
    if (node.type === 'connection') {
      showCreateDbModal(node.id);
    }
  } else if (action === 'createTable') {
    if (node.type === 'database') {
      showCreateTableModal(node);
    }
  } else if (action === 'view') {
    openTabForNode(node);
  } else if (action === 'edit') {
    if (node.type === 'connection') {
      handleEditDataSource(node);
    } else {
      message.info('仅支持编辑连接');
    }
  } else if (action === 'delete') {
    if (node.type === 'connection') {
      handleDeleteDataSource(node);
    } else {
      message.info('仅支持删除连接');
    }
  }
};

const showAddModal = () => {
  isEditMode.value = false;
  currentDataSourceId.value = 0;
  visible.value = true;
  formState.name = '';
  formState.type = 'mysql';
  formState.host = '';
  formState.port = '3306';
  formState.user = '';
  formState.password = '';
  formState.database = '';
};

const handleTestConnection = async () => {
  testingConnection.value = true;
  try {
    const res = await api.testConnection(formState);
    if (res) {
      message.success('连接成功');
    } else {
      message.error('连接测试失败');
    }
  } catch (error) {
    message.error('连接测试出错');
  } finally {
    testingConnection.value = false;
  }
};

const handleOk = async () => {
  confirmLoading.value = true;
  try {
    if (isEditMode.value) {
      await api.updateDataSource(currentDataSourceId.value, formState);
      message.success('更新成功');
    } else {
      await api.createDataSource(formState);
      message.success('创建成功');
    }
    visible.value = false;
    loadDataSources(); // Refresh tree
  } catch (error) {
    message.error(isEditMode.value ? '更新失败' : '创建失败');
  } finally {
    confirmLoading.value = false;
  }
};
</script>

<style scoped>
.page-container {
  display: flex;
  height: 100%;
  background: #fff;
}

.left-panel {
  width: 300px;
  border-right: 1px solid #f0f0f0;
  display: flex;
  flex-direction: column;
}

.panel-header {
  height: 50px;
  padding: 12px 16px;
  border-bottom: 1px solid #f0f0f0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #fafafa;
}

.title {
  font-weight: 500;
  color: #333;
}

.tree-container {
  flex: 1;
  overflow-y: auto;
  padding: 8px;
}

.right-panel {
  flex: 1;
  overflow-y: auto;
  background: #fff;
  display: flex;
  flex-direction: column;
}

.main-tabs {
  height: 100%;
}

.pane-content {
  padding: 16px;
}

.pane-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.table-details {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.detail-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.data-toolbar {
  margin-bottom: 16px;
  padding: 12px;
  background: #fafafa;
  border-radius: 4px;
}

.context-menu {
  position: fixed;
  z-index: 1000;
  background: #fff;
  border: 1px solid #f0f0f0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
  border-radius: 4px;
  min-width: 120px;
}

/* Ant Design Override for full height */
:deep(.ant-tabs) {
  flex: 1;
  display: flex;
  flex-direction: column;
}

:deep(.ant-tabs-content) {
  flex: 1;
  display: flex;
  flex-direction: column;
}

:deep(.ant-tabs-tabpane) {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow-y: auto; /* Allow scrolling within tab pane */
}

/* Custom Tab Styles */
:deep(.ant-tabs-nav-wrap) {
  height: 50px;
}

:deep(.ant-tabs-tab) {
  border-radius: 0 !important;
  height: 50px; /* Align tab height with nav wrap if needed, or let it center */
  border-top: none !important; /* Optional: cleaner look */
}
</style>