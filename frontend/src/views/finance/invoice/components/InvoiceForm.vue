<template>
  <a-modal
    :open="visible"
    :title="title"
    :width="800"
    :confirm-loading="confirmLoading"
    @ok="handleOk"
    @cancel="handleCancel"
    :mask-closable="false"
  >
    <a-spin :spinning="recognizing" tip="AI 识别中...">
      <a-form :model="formState" layout="vertical" ref="formRef">
        <!-- AI Recognition Upload -->
        <a-alert
          message="AI 智能识别"
          description="上传发票文件（图片/PDF）可自动识别并填充表单信息。识别结果仅供参考，请务必核对。"
          type="info"
          show-icon
          style="margin-bottom: 16px"
        >
          <template #action>
             <a-upload
              name="file"
              :show-upload-list="false"
              :before-upload="handleRecognizeUpload"
              accept=".jpg,.jpeg,.png,.pdf"
            >
              <a-button type="primary" size="small">
                <template #icon><CloudUploadOutlined /></template>
                上传识别
              </a-button>
            </a-upload>
          </template>
        </a-alert>

        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="发票号码" name="invoiceNo" :rules="[{ required: true, message: '请输入发票号码' }]">
              <a-input v-model:value="formState.invoiceNo" placeholder="请输入" />
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="发票代码" name="invoiceCode">
              <a-input v-model:value="formState.invoiceCode" placeholder="请输入" />
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="收/开票" name="direction" :rules="[{ required: true, message: '请选择方向' }]">
              <a-select v-model:value="formState.direction" placeholder="请选择">
                <a-select-option value="input">收票 (Input)</a-select-option>
                <a-select-option value="output">开票 (Output)</a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="发票类型" name="type" :rules="[{ required: true, message: '请选择类型' }]">
              <a-select v-model:value="formState.type" placeholder="请选择">
                <a-select-option v-for="item in typeOptions" :key="item.value" :value="item.value">
                  {{ item.label }}
                </a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="8">
            <a-form-item label="金额 (不含税)" name="amount" :rules="[{ required: true, message: '请输入金额' }]">
              <a-input-number v-model:value="formState.amount" style="width: 100%" :precision="2" @change="calculateTotal" />
            </a-form-item>
          </a-col>
          <a-col :span="8">
            <a-form-item label="税额" name="taxAmount" :rules="[{ required: true, message: '请输入税额' }]">
              <a-input-number v-model:value="formState.taxAmount" style="width: 100%" :precision="2" @change="calculateTotal" />
            </a-form-item>
          </a-col>
          <a-col :span="8">
            <a-form-item label="价税合计" name="totalAmount" :rules="[{ required: true, message: '请输入价税合计' }]">
              <a-input-number v-model:value="formState.totalAmount" style="width: 100%" :precision="2" />
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="开票日期" name="invoiceDate" :rules="[{ required: true, message: '请选择日期' }]">
              <a-date-picker v-model:value="formState.invoiceDate" style="width: 100%" value-format="YYYY-MM-DD" />
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="状态" name="status">
              <a-select v-model:value="formState.status">
                <a-select-option v-for="item in statusOptions" :key="item.value" :value="item.value">
                  {{ item.label }}
                </a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
        </a-row>

        <a-divider orientation="left">交易方信息</a-divider>

        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="购买方名称" name="purchaserName" :rules="[{ required: true, message: '请输入购买方名称' }]">
              <a-input v-model:value="formState.purchaserName" placeholder="请输入" />
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="购买方税号" name="purchaserTaxId">
              <a-input v-model:value="formState.purchaserTaxId" placeholder="请输入" />
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="销售方名称" name="sellerName" :rules="[{ required: true, message: '请输入销售方名称' }]">
              <a-input v-model:value="formState.sellerName" placeholder="请输入" />
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="销售方税号" name="sellerTaxId">
              <a-input v-model:value="formState.sellerTaxId" placeholder="请输入" />
            </a-form-item>
          </a-col>
        </a-row>

        <a-divider orientation="left">其他信息</a-divider>

        <a-form-item label="备注" name="remark">
          <a-textarea v-model:value="formState.remark" :rows="2" />
        </a-form-item>

        <a-form-item label="附件" name="attachments">
          <a-upload
            v-model:file-list="fileList"
            :before-upload="() => false"
            multiple
          >
            <a-button>
              <template #icon><UploadOutlined /></template>
              选择文件
            </a-button>
          </a-upload>
          <div v-if="existingAttachments.length > 0" style="margin-top: 8px">
            <div v-for="file in existingAttachments" :key="file.id" style="margin-bottom: 4px; display: flex; align-items: center;">
              <span style="margin-right: 8px;">{{ file.fileName }}</span>
              <a-space>
                <a-tooltip title="预览">
                  <a-button type="text" size="small" @click="handlePreview(file)">
                    <template #icon><EyeOutlined /></template>
                  </a-button>
                </a-tooltip>
                <a-tooltip title="下载">
                  <a-button type="text" size="small" @click="handleDownload(file)">
                    <template #icon><DownloadOutlined /></template>
                  </a-button>
                </a-tooltip>
                <a-tooltip title="删除">
                  <a-button type="text" danger size="small" @click="deleteExistingAttachment(file.id)">
                    <template #icon><DeleteOutlined /></template>
                  </a-button>
                </a-tooltip>
              </a-space>
            </div>
          </div>
        </a-form-item>

      </a-form>
    </a-spin>
  </a-modal>
</template>

<script lang="ts" setup>
import { ref, reactive, computed, onMounted } from 'vue';
import { message } from 'ant-design-vue';
import { CloudUploadOutlined, UploadOutlined, EyeOutlined, DownloadOutlined, DeleteOutlined } from '@ant-design/icons-vue';
import { getKkViewUrl } from '@/utils/kkview';
import { getDictDataByCode, type DictDataDto } from '@/api/dict';
import { 
  createInvoice, 
  updateInvoice, 
  recognizeInvoice, 
  deleteAttachment,
  downloadAttachment,
  type FinanceInvoice, 
  type FinanceAttachment 
} from '@/api/finance';
import dayjs from 'dayjs';

const props = defineProps<{
  // No props needed as we control visibility via expose
}>();

const emit = defineEmits(['success']);

const visible = ref(false);
const confirmLoading = ref(false);
const recognizing = ref(false);
const isEdit = ref(false);
const currentId = ref<number>(0);
const formRef = ref();

const formState = reactive({
  invoiceNo: '',
  invoiceCode: '',
  direction: 'input',
  type: 'vat_spec',
  amount: 0,
  taxAmount: 0,
  totalAmount: 0,
  invoiceDate: '',
  purchaserName: '',
  purchaserTaxId: '',
  sellerName: '',
  sellerTaxId: '',
  remark: '',
  status: 'draft'
});

const fileList = ref<any[]>([]);
const existingAttachments = ref<FinanceAttachment[]>([]);
const statusOptions = ref<DictDataDto[]>([]);
const typeOptions = ref<DictDataDto[]>([]);

const title = computed(() => isEdit.value ? '编辑发票' : '新增发票');

onMounted(async () => {
  try {
    statusOptions.value = await getDictDataByCode('finance_invoice_status');
    typeOptions.value = await getDictDataByCode('finance_invoice_type');
  } catch (error) {
    console.error('Failed to load dicts', error);
  }
});

const open = (record?: FinanceInvoice) => {
  visible.value = true;
  fileList.value = [];
  existingAttachments.value = [];
  
  if (record) {
    isEdit.value = true;
    currentId.value = record.id;
    // Fill form
    formState.invoiceNo = record.invoiceNo;
    formState.invoiceCode = record.invoiceCode || '';
    formState.direction = record.direction;
    formState.type = record.type;
    formState.amount = record.amount;
    formState.taxAmount = record.taxAmount;
    formState.totalAmount = record.totalAmount;
    formState.invoiceDate = record.invoiceDate;
    formState.purchaserName = record.purchaserName;
    formState.purchaserTaxId = record.purchaserTaxId || '';
    formState.sellerName = record.sellerName;
    formState.sellerTaxId = record.sellerTaxId || '';
    formState.remark = record.remark || '';
    formState.status = record.status || 'draft';
    
    existingAttachments.value = record.attachments || [];
  } else {
    isEdit.value = false;
    currentId.value = 0;
    // Reset form
    formState.invoiceNo = '';
    formState.invoiceCode = '';
    formState.direction = 'input';
    formState.type = 'vat_spec';
    formState.amount = 0;
    formState.taxAmount = 0;
    formState.totalAmount = 0;
    formState.invoiceDate = dayjs().format('YYYY-MM-DD');
    formState.purchaserName = '';
    formState.purchaserTaxId = '';
    formState.sellerName = '';
    formState.sellerTaxId = '';
    formState.remark = '';
    formState.status = 'draft';
  }
};

const handleCancel = () => {
  visible.value = false;
};

const calculateTotal = () => {
  if (formState.amount !== undefined && formState.taxAmount !== undefined) {
    formState.totalAmount = parseFloat((formState.amount + formState.taxAmount).toFixed(2));
  }
};

const handleRecognizeUpload = (file: File) => {
  recognizing.value = true;
  // Add file to fileList automatically if not there
  if (!fileList.value.some(f => f.name === file.name)) {
    fileList.value = [...fileList.value, file];
  }

  recognizeInvoice(file).then(res => {
    message.success('识别成功');
    // Fill form with recognized data
    if (res.invoiceNo) formState.invoiceNo = res.invoiceNo;
    if (res.invoiceCode) formState.invoiceCode = res.invoiceCode;
    if (res.direction) formState.direction = res.direction;
    if (res.type) formState.type = res.type;
    if (res.amount) formState.amount = res.amount;
    if (res.taxAmount) formState.taxAmount = res.taxAmount;
    if (res.totalAmount) formState.totalAmount = res.totalAmount;
    if (res.invoiceDate) formState.invoiceDate = res.invoiceDate; // Ensure format match
    if (res.purchaserName) formState.purchaserName = res.purchaserName;
    if (res.purchaserTaxId) formState.purchaserTaxId = res.purchaserTaxId;
    if (res.sellerName) formState.sellerName = res.sellerName;
    if (res.sellerTaxId) formState.sellerTaxId = res.sellerTaxId;
    
  }).catch(err => {
    console.error(err);
    message.error('识别失败，请手动填写');
  }).finally(() => {
    recognizing.value = false;
  });
  
  return false; // Prevent auto upload
};

const handleDownload = async (file: FinanceAttachment) => {
  try {
    const res: any = await downloadAttachment(file.id);
    const blob = res.data; 
    const url = window.URL.createObjectURL(blob);
    
    const link = document.createElement('a');
    link.href = url;
    link.download = file.fileName;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    
    setTimeout(() => window.URL.revokeObjectURL(url), 10000);
  } catch (err) {
    console.error(err);
    message.error('下载失败');
  }
};

const handlePreview = (file: FinanceAttachment) => {
  if (file.filePath) {
    const url = getKkViewUrl(file.filePath, file.fileName);
    window.open(url, '_blank');
  } else {
    message.error('文件路径不存在');
  }
};

const deleteExistingAttachment = async (id: number) => {
  try {
    await deleteAttachment(id);
    existingAttachments.value = existingAttachments.value.filter(item => item.id !== id);
    message.success('删除成功');
  } catch (err) {
    message.error('删除失败');
  }
};

const handleOk = () => {
  formRef.value.validate().then(async () => {
    confirmLoading.value = true;
    try {
      const formData = new FormData();
      Object.keys(formState).forEach(key => {
        const val = (formState as any)[key];
        if (val !== undefined && val !== null) {
          formData.append(key, val.toString());
        }
      });
      
      fileList.value.forEach(file => {
        if (file.originFileObj) {
            formData.append('attachments', file.originFileObj);
        } else {
            formData.append('attachments', file);
        }
      });

      if (isEdit.value) {
        await updateInvoice(currentId.value, formData);
        message.success('更新成功');
      } else {
        await createInvoice(formData);
        message.success('创建成功');
      }
      visible.value = false;
      emit('success');
    } catch (err) {
      console.error(err);
      message.error(isEdit.value ? '更新失败' : '创建失败');
    } finally {
      confirmLoading.value = false;
    }
  });
};

defineExpose({
  open
});
</script>
