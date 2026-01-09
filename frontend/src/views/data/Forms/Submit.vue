<template>
  <div class="form-submit-container">
    <div class="form-content">
      <div v-if="loading" class="loading-state">
        <a-spin size="large" />
      </div>
      <template v-else-if="error === 'requires_login'">
        <a-result status="403" title="需要登录" sub-title="请登录后填写此表单">
          <template #extra>
            <a-button type="primary" @click="goToLogin">去登录</a-button>
          </template>
        </a-result>
      </template>
      <template v-else-if="error">
        <a-result status="error" :title="error" />
      </template>
      <template v-else-if="submitted && !isReadOnly">
        <a-result status="success" title="提交成功" sub-title="感谢您的参与">
          <template #extra>
            <a-button v-if="!formDefinition?.limitOnePerUser" type="primary" @click="resetForm">再填一份</a-button>
          </template>
        </a-result>
      </template>
      <template v-else>
        <div v-if="isReadOnly" class="readonly-alert">
           <a-alert message="您已提交过此表单，以下是您的提交内容（只读）" type="info" show-icon style="margin-bottom: 20px" />
        </div>
        <a-form
          ref="formRef"
          :model="formData"
          layout="vertical"
          class="submit-form"
        >
          <!-- 这里使用 FormDesigner 中相同的渲染逻辑，但只读/填写模式 -->
          <!-- 简化版渲染，实际应抽取通用的 Renderer 组件 -->
          <div v-for="item in formItems" :key="item.id" class="form-item-wrapper">
            <template v-if="item.type === 'subtable'">
              <div class="subtable-wrapper">
                <div class="form-label" v-if="item.showLabel !== false" style="margin-bottom: 8px;">
                  <span v-if="item.required" style="color: #ff4d4f; margin-right: 4px">*</span>
                  <span style="font-weight: 500">{{ item.label }}</span>
                </div>
                <a-table
                  :columns="getSubTableColumns(item)"
                  :data-source="formData[item.id] || []"
                  :pagination="false"
                  bordered
                  size="small"
                  :row-key="(_record: any, index: number | undefined) => index || 0"
                >
                  <template #bodyCell="{ column, record, index }">
                    <template v-if="(column as any).key === 'action'">
                      <div style="text-align: center">
                        <DeleteOutlined v-if="!isReadOnly" class="delete-btn" @click="removeSubTableRow(item.id, index)" />
                      </div>
                    </template>
                    <template v-else>
                      <component
                        :is="getComponent((column as any).type)"
                        v-model:value="(record as any)[(column as any).key as string]"
                        style="width: 100%"
                        v-bind="(column as any).props"
                        :options="(column as any).options"
                        :placeholder="(column as any).title"
                        :disabled="isReadOnly"
                      />
                    </template>
                  </template>
                </a-table>
                <a-button v-if="!isReadOnly" type="dashed" block @click="addSubTableRow(item.id, item.columns)" style="margin-top: 8px">
                  <PlusOutlined /> 添加一行
                </a-button>
              </div>
            </template>
            <a-form-item
              v-else
              :label="item.label"
              :name="item.id"
              :required="item.required"
              :rules="[{ required: item.required, message: `${item.label}不能为空` }]"
            >
              <component
                :is="getComponent(item.type)"
                v-model:value="formData[item.id]"
                :placeholder="item.placeholder"
                v-bind="item.props"
                :options="item.options"
                style="width: 100%"
                :disabled="isReadOnly"
              />
            </a-form-item>
          </div>

          <div class="form-actions" v-if="!isReadOnly">
            <a-button type="primary" size="large" :loading="submitting" block @click="handleSubmit">
              提交
            </a-button>
          </div>
        </a-form>
      </template>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { getFormDetail, submitForm } from '@/api/form';
import { useUserStore } from '@/stores/user';
import { 
  PlusOutlined,
  DeleteOutlined
} from '@ant-design/icons-vue';
import { 
  Input, 
  InputNumber, 
  Select, 
  Radio, 
  Checkbox, 
  DatePicker, 
  TimePicker,
  Switch
} from 'ant-design-vue';

const route = useRoute();
const router = useRouter();
const userStore = useUserStore();
const loading = ref(true);
const submitting = ref(false);
const submitted = ref(false);
const error = ref('');
const formDefinition = ref<any>(null);
const formItems = ref<any[]>([]);
const formData = ref<Record<string, any>>({});
const isReadOnly = ref(false);

const goToLogin = () => {
  router.push({
    path: '/login',
    query: { redirect: route.fullPath }
  });
};

const formRef = ref();

const getComponent = (type: string) => {
  switch (type) {
    case 'input': return Input;
    case 'textarea': return Input.TextArea; // Antdv Input.TextArea
    case 'number': return InputNumber;
    case 'select': return Select;
    case 'radio': return Radio.Group;
    case 'checkbox': return Checkbox.Group;
    case 'date': return DatePicker;
    case 'time': return TimePicker;
    case 'switch': return Switch;
    // ... 其他组件映射
    default: return Input;
  }
};

const loadForm = async () => {
  const id = route.params.id as string;
  if (!id) {
    error.value = '无效的表单链接';
    loading.value = false;
    return;
  }

  try {
    const res = await getFormDetail(parseInt(id));
    const data = (res as any).data || res;
    
    if (!data.isPublished) {
      error.value = '该表单未发布或已停止收集';
      loading.value = false;
      return;
    }

    if ((data.requiresLogin || data.limitOnePerUser) && !userStore.isLoggedIn()) {
      error.value = 'requires_login'; // Special error code
      loading.value = false;
      return;
    }

    formDefinition.value = data;

    if (data.limitOnePerUser && data.hasSubmitted) {
      // 如果已提交，不显示错误，而是进入只读模式
      // error.value = '您已填写过此表单，不可重复提交';
      submitted.value = true; // 复用提交成功状态，或者新增一个状态
      // 这里我们为了显示已填内容，直接在正常表单页面显示，但禁用所有输入
      isReadOnly.value = true;
    }

    try {
      formItems.value = JSON.parse(data.formItems || '[]');
    } catch (e) {
      formItems.value = [];
    }
    
    // 初始化 formData
    if (data.limitOnePerUser && data.hasSubmitted && data.submittedData) {
       try {
         formData.value = JSON.parse(data.submittedData);
       } catch (e) {
         console.error('Failed to parse submitted data', e);
         formData.value = {};
       }
    } else {
       formItems.value.forEach(item => {
        if (item.type === 'subtable') {
          formData.value[item.id] = item.defaultValue || [];
        } else {
          formData.value[item.id] = item.defaultValue;
        }
      });
    }

  } catch (e) {
    error.value = '加载表单失败';
    console.error(e);
  } finally {
    loading.value = false;
  }
};

const handleSubmit = async () => {
  try {
    await formRef.value.validate();
    submitting.value = true;
    
    // 调用提交数据的 API
    await submitForm({
      formId: formDefinition.value.id,
      data: JSON.stringify(formData.value),
      submittedBy: userStore.username || 'Anonymous'
    });
    
    submitted.value = true;
  } catch (e) {
    // 验证失败或提交失败
    console.error(e);
  } finally {
    submitting.value = false;
  }
};

const resetForm = () => {
  submitted.value = false;
  formData.value = {};
  formItems.value.forEach(item => {
    if (item.type === 'subtable') {
      formData.value[item.id] = item.defaultValue || [];
    } else {
      formData.value[item.id] = item.defaultValue;
    }
  });
};

const addSubTableRow = (itemId: string, columns: any[]) => {
  if (!formData.value[itemId]) {
    formData.value[itemId] = [];
  }
  const row: any = {};
  columns.forEach(col => {
    row[col.id] = undefined;
  });
  formData.value[itemId].push(row);
};

const removeSubTableRow = (itemId: string, index: number) => {
  formData.value[itemId].splice(index, 1);
};

const getSubTableColumns = (item: any): any[] => {
  const cols: any[] = item.columns.map((col: any) => ({
    title: col.label,
    dataIndex: col.id,
    key: col.id,
    width: col.width ? (col.width + (col.widthType || 'px')) : undefined,
    type: col.type, 
    props: col.props,
    options: col.options
  }));
  
  if (!isReadOnly.value) {
    cols.push({
      title: '操作',
      key: 'action',
      width: 60,
      align: 'center'
    });
  }
  
  return cols;
};

onMounted(() => {
  loadForm();
});
</script>

<style scoped>
.form-submit-container {
  min-height: 100vh;
  background-color: #f0f2f5;
  padding: 40px 20px;
  display: flex;
}

.form-content {
  width: 100%;
  max-width: 800px;
  margin: auto;
  background: white;
  padding: 40px;
  border-radius: 8px;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
}

.form-header {
  text-align: center;
  margin-bottom: 40px;
  border-bottom: 1px solid #f0f0f0;
  padding-bottom: 20px;
}

.form-header h1 {
  margin-bottom: 10px;
  font-size: 24px;
  color: #1f1f1f;
}

.description {
  color: #8c8c8c;
  font-size: 14px;
}

.form-item-wrapper {
  margin-bottom: 24px;
}

.form-actions {
  margin-top: 40px;
}

.loading-state {
  display: flex;
  justify-content: center;
  padding: 40px;
}

@media (max-width: 576px) {
  .form-submit-container {
    padding: 0;
    background: white;
  }
  
  .form-content {
    box-shadow: none;
    padding: 20px;
  }
}

.subtable-wrapper {
  background: #fafafa;
  padding: 12px;
  border-radius: 4px;
  border: 1px solid #f0f0f0;
  margin-bottom: 24px;
}

.delete-btn {
  color: #ff4d4f;
  cursor: pointer;
}

.delete-btn:hover {
  color: #ff7875;
}

/* 增强只读模式下的文字显示 */
:deep(.ant-input[disabled]), 
:deep(.ant-input-number-input[disabled]), 
:deep(.ant-select-disabled.ant-select:not(.ant-select-customize-input) .ant-select-selector),
:deep(.ant-picker-input > input[disabled]) {
  color: rgba(0, 0, 0, 0.85) !important;
  background-color: #fcfcfc;
  cursor: default;
}

:deep(.ant-radio-disabled + span), 
:deep(.ant-checkbox-disabled + span) {
  color: rgba(0, 0, 0, 0.85) !important;
}
</style>