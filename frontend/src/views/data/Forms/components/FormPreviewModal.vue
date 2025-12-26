<template>
  <DraggableModal
    :visible="visible"
    @update:visible="$emit('update:visible', $event)"
    title="表单预览"
    width="800"
    height="600"
    bodyPadding="0"
  >
    <div style="height: 100%; display: flex; flex-direction: column; overflow: hidden;">
    <div style="flex: 1; overflow-y: auto; overflow-x: hidden; padding: 20px; padding-right: 20px;">
    <div style="margin-bottom: 15px; display: flex; justify-content: flex-end; gap: 10px;">
      <a-upload
        name="file"
        :showUploadList="false"
        :beforeUpload="beforeImportData"
        accept=".json"
      >
        <a-button type="default" size="small">
          <template #icon><UploadOutlined /></template>
          导入数据
        </a-button>
      </a-upload>
      <a-button type="default" size="small" @click="exportData">
        <template #icon><DownloadOutlined /></template>
        导出数据
      </a-button>
    </div>
    <a-form layout="vertical" :model="previewForm">
      <a-row :gutter="24">
        <a-col 
          v-for="item in previewFormItems" 
          :key="item.id" 
          :span="item.span || 24"
          v-show="!item.hidden"
        >
          <a-form-item :label="item.showLabel !== false ? item.label : undefined" :required="item.required">
            <a-input v-if="item.type === 'input'" v-model:value="previewForm[item.field]" :placeholder="item.placeholder" />
            <a-textarea v-else-if="item.type === 'textarea'" v-model:value="previewForm[item.field]" :placeholder="item.placeholder" />
            <a-input-number v-else-if="item.type === 'number'" v-model:value="previewForm[item.field]" style="width: 100%" />
            <a-date-picker v-else-if="item.type === 'date'" v-model:value="previewForm[item.field]" style="width: 100%" />
            <a-select v-else-if="item.type === 'select'" v-model:value="previewForm[item.field]" style="width: 100%" />
            
            <div v-else-if="item.type === 'text'" :style="{ fontSize: item.fontSize + 'px', fontWeight: item.bold ? 'bold' : 'normal', textAlign: item.align, color: item.color }">
              {{ item.content }}
            </div>
            <div v-else-if="item.type === 'rich-text'" class="rich-text-display" v-html="item.content" style="overflow: auto;"></div>
            <a-divider v-else-if="item.type === 'divider'" :dashed="item.dashed" :orientation="item.orientation" :style="{ marginTop: item.marginTop + 'px', marginBottom: item.marginBottom + 'px' }">
               {{ item.text }}
            </a-divider>

            <a-input v-else-if="item.type === 'calculation'" v-model:value="previewForm[item.field]" readonly placeholder="自动计算" />
            
            <a-input v-else-if="item.type === 'current-time'" v-model:value="previewForm[item.field]" readonly placeholder="当前时间" />
            
            <a-input v-else-if="item.type === 'current-user'" v-model:value="previewForm[item.field]" readonly placeholder="当前用户" />
            
            <div v-else-if="item.type === 'subtable'">
              <a-table 
                :columns="getSubtableColumns(item)" 
                :data-source="previewForm[item.field]" 
                size="small" 
                :pagination="false"
                row-key="_id"
                bordered
              >
                <template #summary v-if="item.showSummary">
                   <a-table-summary fixed="bottom">
                    <a-table-summary-row>
                      <a-table-summary-cell v-if="item.showRowNumber" :index="0">合计</a-table-summary-cell>
                      <a-table-summary-cell v-for="(col, index) in item.columns" :key="col.id" :index="Number(index) + (item.showRowNumber ? 1 : 0)">
                        {{ getColumnSummary(previewForm[item.field], col) }}
                      </a-table-summary-cell>
                      <a-table-summary-cell :index="item.columns.length + (item.showRowNumber ? 1 : 0)"></a-table-summary-cell>
                    </a-table-summary-row>
                  </a-table-summary>
                </template>
                <template #bodyCell="{ column, record, index }">
                  <template v-if="column.key === 'index'">
                    {{ index + 1 }}
                  </template>
                  <template v-else-if="column.key === 'action'">
                    <a @click="removeSubtableRow(item.field, index)" style="color: red">删除</a>
                  </template>
                  <template v-else>
                    <a-input v-if="column.type === 'input'" v-model:value="record[column.dataIndex]" size="small" />
                    <a-textarea v-else-if="column.type === 'textarea'" v-model:value="record[column.dataIndex]" size="small" :auto-size="{ minRows: 1, maxRows: 3 }" />
                    <a-input-number v-else-if="column.type === 'number'" v-model:value="record[column.dataIndex]" size="small" style="width: 100%" />
                    <a-date-picker v-else-if="column.type === 'date'" v-model:value="record[column.dataIndex]" size="small" style="width: 100%" value-format="YYYY-MM-DD" />
                    <a-select v-else-if="column.type === 'select'" v-model:value="record[column.dataIndex]" size="small" style="width: 100%">
                      <a-select-option value="Option 1">选项 1</a-select-option>
                      <a-select-option value="Option 2">选项 2</a-select-option>
                      <a-select-option value="Option 3">选项 3</a-select-option>
                    </a-select>
                    <a-input v-else v-model:value="record[column.dataIndex]" size="small" />
                  </template>
                </template>
              </a-table>
              <a-button type="dashed" block style="margin-top: 10px" @click="addSubtableRow(item.field, item.columns)">
                <PlusOutlined /> 添加行
              </a-button>
            </div>
          </a-form-item>
        </a-col>
      </a-row>
    </a-form>
    </div>
    </div>
  </DraggableModal>
</template>

<script setup lang="ts">
import { ref, watch, nextTick } from 'vue';
import DraggableModal from '../../../../components/DraggableModal.vue';
import { UploadOutlined, DownloadOutlined, PlusOutlined } from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import dayjs from 'dayjs';

const props = defineProps({
  visible: {
    type: Boolean,
    default: false
  },
  formItems: {
    type: Array as () => any[],
    default: () => []
  }
});

const emit = defineEmits(['update:visible']);

const previewForm = ref<any>({});
const previewFormItems = ref<any[]>([]);

// Mock current user
const currentUser = {
  name: '管理员',
  id: 'admin',
  dept: '研发部'
};

const calculateValues = () => {
  if (!previewFormItems.value) return;

  previewFormItems.value.forEach(item => {
    if (item.type === 'calculation' && item.formula) {
      try {
        let formulaStr = item.formula;
        // Replace {field} with value
        formulaStr = formulaStr.replace(/\{(\w+)\}/g, (_match: string, field: string) => {
          const val = previewForm.value[field];
          return (val === null || val === undefined || val === '') ? 0 : val;
        });
        
        // Evaluate
        // Using new Function for safer evaluation than eval, though still has access to globals
        // Ideally use a math parser library, but for now this is standard
        const result = new Function(`return ${formulaStr}`)();
        
        // Update value if changed
        if (previewForm.value[item.field] !== result) {
          previewForm.value[item.field] = isNaN(result) ? '' : result;
        }
      } catch (e) {
        console.error('Calculation error:', e);
        previewForm.value[item.field] = 'Error';
      }
    }
  });
};

watch(() => props.visible, (val) => {
  if (val) {
    // Deep copy formItems to avoid modifying original
    previewFormItems.value = JSON.parse(JSON.stringify(props.formItems));
    // Initialize form model
    const form: any = {};
    previewFormItems.value.forEach(item => {
      if (item.type === 'subtable') {
        form[item.field] = [];
      } else if (item.type === 'current-time') {
         const format = item.format || 'YYYY-MM-DD HH:mm:ss';
         form[item.field] = dayjs().format(format);
      } else if (item.type === 'current-user') {
         const showField = item.showField || 'name';
         form[item.field] = (currentUser as any)[showField] || currentUser.name;
      } else {
        form[item.field] = null;
      }
    });
    previewForm.value = form;
    
    // Initial calculation
    nextTick(() => {
      calculateValues();
    });
  }
});

// Watch for form changes to trigger calculation
watch(previewForm, () => {
  calculateValues();
}, { deep: true });

const addSubtableRow = (field: string, columns: any[]) => {
  const row: any = { _id: Date.now() };
  columns.forEach(col => {
    row[col.field] = '';
  });
  if (!previewForm.value[field]) {
    previewForm.value[field] = [];
  }
  previewForm.value[field].push(row);
};

const removeSubtableRow = (field: string, index: number) => {
  previewForm.value[field].splice(index, 1);
};

const getSubtableColumns = (item: any) => {
  const cols = [];
  if (item.showRowNumber) {
    cols.push({ title: '序号', key: 'index', width: 50, align: 'center' });
  }
  cols.push(...item.columns.map((c: any) => ({
    title: c.label,
    dataIndex: c.field,
    type: c.type,
    width: c.width ? (c.widthType === 'percent' ? `${c.width}%` : `${c.width}px`) : undefined
  })));
  cols.push({ title: '操作', key: 'action', width: 80 });
  return cols;
};

const getColumnSummary = (data: any[], col: any) => {
  if (!col.summaryType || !data || data.length === 0) return '';
  
  const values = data.map(row => {
    const val = row[col.field];
    return val === '' || val === null || val === undefined ? 0 : Number(val);
  });

  if (col.summaryType === 'count') {
    return data.length;
  } else if (col.summaryType === 'sum') {
    const sum = values.reduce((acc, curr) => acc + (isNaN(curr) ? 0 : curr), 0);
    return isNaN(sum) ? '' : sum;
  } else if (col.summaryType === 'avg') {
    const sum = values.reduce((acc, curr) => acc + (isNaN(curr) ? 0 : curr), 0);
    const avg = sum / data.length;
    return isNaN(avg) ? '' : avg.toFixed(2);
  }
  return '';
};

const exportData = () => {
  const content = JSON.stringify(previewForm.value, null, 2);
  const blob = new Blob([content], { type: 'application/json' });
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = `form_data_${Date.now()}.json`;
  link.click();
  URL.revokeObjectURL(url);
  message.success('导出数据成功');
};

const beforeImportData = (file: File) => {
  const reader = new FileReader();
  reader.onload = (e) => {
    try {
      const content = JSON.parse(e.target?.result as string);
      if (typeof content === 'object') {
        previewForm.value = content;
        message.success('导入数据成功');
      } else {
        message.error('数据格式不正确');
      }
    } catch (err) {
      message.error('解析数据失败');
    }
  };
  reader.readAsText(file);
  return false;
};
</script>

<style scoped>
.rich-text-display table {
  border-collapse: collapse;
}
.rich-text-display table td, .rich-text-display table th {
  border: 1px solid #ccc;
  padding: 3px 5px;
}
.rich-text-display img {
  max-width: 100%;
}
.rich-text-display blockquote {
  border-left: 8px solid #d0e5f2;
  padding: 5px 10px;
  margin: 10px 0;
  background-color: #f1f1f1;
}
</style>
