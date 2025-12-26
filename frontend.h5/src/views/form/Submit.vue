<template>
  <div class="mobile-form-submit">
    
    <div v-if="loading" class="loading-state">
      <van-loading type="spinner" vertical>加载中...</van-loading>
    </div>
    
    <div v-else-if="error" class="error-state">
      <van-empty image="error" :description="error">
        <template #bottom>
          <van-button v-if="error === 'requires_login'" type="primary" @click="goToLogin">去登录</van-button>
        </template>
      </van-empty>
    </div>
    
    <div v-else-if="submitted" class="success-state">
      <van-empty image="network" description="提交成功" />
      <div class="success-actions">
        <van-button block type="primary" @click="resetForm">再填一份</van-button>
        <van-button block plain type="primary" @click="onClickLeft" style="margin-top: 10px">返回首页</van-button>
      </div>
    </div>
    
    <van-form v-else @submit="onSubmit">
      <van-cell-group inset style="margin-top: 10px;">
        <div v-for="item in formItems" :key="item.id">
           <!-- Subtable -->
           <div v-if="item.type === 'subtable'" class="subtable-wrapper">
             <div class="subtable-label">{{ item.label }}</div>
             
             <div v-for="(row, index) in formData[item.id]" :key="index" class="subtable-card">
               <div class="subtable-card-header">
                 <span>第 {{ Number(index) + 1 }} 行</span>
                 <van-icon name="delete-o" color="#ee0a24" size="20" @click="removeSubTableRow(item.id, Number(index))" />
               </div>
               
               <div v-for="col in item.columns" :key="col.id">
                 <!-- Subtable Input -->
                 <van-field
                   v-if="col.type === 'input'"
                   v-model="row[col.id]"
                   :name="`${item.id}_${index}_${col.id}`"
                   :label="col.label"
                   :placeholder="col.placeholder || '请输入'"
                   :rules="[{ required: item.required, message: '必填' }]"
                 />
                 <!-- Subtable Textarea -->
                 <van-field
                   v-else-if="col.type === 'textarea'"
                   v-model="row[col.id]"
                   :name="`${item.id}_${index}_${col.id}`"
                   :label="col.label"
                   :placeholder="col.placeholder || '请输入'"
                   type="textarea"
                   rows="1"
                   autosize
                   :rules="[{ required: item.required, message: '必填' }]"
                 />
                 <!-- Subtable Number -->
                 <van-field
                   v-else-if="col.type === 'number'"
                   v-model="row[col.id]"
                   :name="`${item.id}_${index}_${col.id}`"
                   :label="col.label"
                   :placeholder="col.placeholder || '请输入'"
                   type="number"
                   :rules="[{ required: item.required, message: '必填' }]"
                 />
                 <!-- Subtable Date -->
                 <van-field
                   v-else-if="col.type === 'date'"
                   v-model="row[col.id]"
                   :name="`${item.id}_${index}_${col.id}`"
                   :label="col.label"
                   :placeholder="col.placeholder || '选择日期'"
                   type="date"
                   :rules="[{ required: item.required, message: '必填' }]"
                 />
                 <!-- Subtable Other -->
                 <van-field
                   v-else
                   v-model="row[col.id]"
                   :name="`${item.id}_${index}_${col.id}`"
                   :label="col.label"
                   :placeholder="'(暂不支持: ' + col.type + ')'"
                   readonly
                 />
               </div>
             </div>
             
             <div class="add-row-btn">
               <van-button icon="plus" block plain type="primary" size="small" @click="addSubTableRow(item.id, item.columns)">
                 添加行
               </van-button>
             </div>
           </div>

           <!-- Input -->
           <van-field
             v-else-if="item.type === 'input'"
             v-model="formData[item.id]"
             :name="item.id"
             :label="item.label"
             :placeholder="item.placeholder || '请输入'"
             :rules="[{ required: item.required, message: item.label + '不能为空' }]"
           />
           <!-- Textarea -->
           <van-field
             v-else-if="item.type === 'textarea'"
             v-model="formData[item.id]"
             :name="item.id"
             :label="item.label"
             :placeholder="item.placeholder || '请输入'"
             type="textarea"
             rows="2"
             autosize
             :rules="[{ required: item.required, message: item.label + '不能为空' }]"
           />
           <!-- Number -->
            <van-field
             v-else-if="item.type === 'number'"
             v-model="formData[item.id]"
             :name="item.id"
             :label="item.label"
             :placeholder="item.placeholder || '请输入'"
             type="number"
             :rules="[{ required: item.required, message: item.label + '不能为空' }]"
           />
           <!-- Date Picker -->
           <van-field
             v-else-if="item.type === 'date'"
             v-model="formData[item.id]"
             :name="item.id"
             :label="item.label"
             :placeholder="item.placeholder || '选择日期'"
             type="date"
             :rules="[{ required: item.required, message: item.label + '不能为空' }]"
           />
           
           <!-- Others simplified for now -->
           <van-field
             v-else
             v-model="formData[item.id]"
             :name="item.id"
             :label="item.label"
             :placeholder="'(暂不支持的类型: ' + item.type + ')'"
             readonly
           />
        </div>
      </van-cell-group>
      <div style="margin: 16px;">
        <van-button round block type="primary" native-type="submit" :loading="submitting">
          提交
        </van-button>
      </div>
    </van-form>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { showToast } from 'vant';
import { getFormDetail, submitForm } from '@/api/form';
import { useUserStore } from '@/stores/user';

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

const onClickLeft = () => {
  if (window.history.length > 1) {
    history.back();
  } else {
    router.push('/');
  }
};

const goToLogin = () => {
  router.push({
    path: '/login',
    query: { redirect: route.fullPath }
  });
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

    if (data.requiresLogin && !userStore.token) {
       error.value = 'requires_login';
       loading.value = false;
       return;
    }

    formDefinition.value = data;
    try {
      formItems.value = JSON.parse(data.formItems || '[]');
    } catch (e) {
      formItems.value = [];
    }
    
    // Init form data
    formItems.value.forEach((item: any) => {
      if (item.type === 'subtable') {
        formData.value[item.id] = item.defaultValue || [];
      } else {
        formData.value[item.id] = item.defaultValue;
      }
    });

  } catch (e) {
    error.value = '加载表单失败';
    console.error(e);
  } finally {
    loading.value = false;
  }
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

const onSubmit = async () => {
  try {
    submitting.value = true;
    await submitForm({
      formId: formDefinition.value.id,
      data: JSON.stringify(formData.value),
      submittedBy: userStore.username || 'Anonymous'
    });
    submitted.value = true;
  } catch (e) {
    showToast('提交失败');
    console.error(e);
  } finally {
    submitting.value = false;
  }
};

const resetForm = () => {
  submitted.value = false;
  formData.value = {};
  formItems.value.forEach((item: any) => {
    if (item.type === 'subtable') {
      formData.value[item.id] = item.defaultValue || [];
    } else {
      formData.value[item.id] = item.defaultValue;
    }
  });
};

onMounted(() => {
  loadForm();
});
</script>

<style scoped>
.mobile-form-submit {
  min-height: 100vh;
  background-color: #f7f8fa;
  padding-bottom: 30px;
}

/* 样式优化：Label和Input同一行，增强边框和背景 */
:deep(.van-cell-group--inset) {
  margin: 10px 12px;
  overflow: visible; 
}

:deep(.van-cell-group) {
    background-color: transparent;
}

:deep(.van-field) {
  margin-bottom: 0;
  border-radius: 8px; /* 圆角增加 */
  padding: 14px 16px; /* 增加内边距 */
  background-color: #f7f8fa;
  /* 移除边框，改用阴影或仅背景区分，或者保留淡边框 */
  box-shadow: 0 1px 2px rgba(0,0,0,0.02); 
}

/* 必填星号颜色 */
:deep(.van-field--required::before) {
  color: #ee0a24;
  left: 8px; /* 调整星号位置 */
}

/* Label 样式 */
:deep(.van-field__label) {
  width: 6em; /* 固定宽度确保对齐，或者根据需要调整 */
  color: #323233;
  font-weight: 500;
  margin-right: 12px;
  display: flex;
  align-items: center; /* 垂直居中 */
}

/* Input 区域样式 */
:deep(.van-field__value) {
  background-color: #ffffff; /* 浅灰色背景框 */
  border-radius: 4px;
  padding: 4px 10px;
  border: 1px solid transparent; /* 预留边框位置 */
  transition: all 0.2s;
}

/* 输入框聚焦时高亮背景或边框 (Vant input 自身没有focus伪类在父级，需要 focus-within) */
:deep(.van-field:focus-within .van-field__value) {
  background-color: #fff;
  border-color: #1989fa; /* 聚焦色 */
  box-shadow: 0 0 0 2px rgba(25, 137, 250, 0.1);
}

:deep(.van-cell) {
  /* 恢复默认 flex 布局 (左右结构) */
  flex-direction: row; 
  align-items: center; /* 垂直居中 */
  overflow: visible;
}

:deep(.van-field__body) {
  height: 100%;
  display: flex;
  align-items: center;
}

/* 文本域特殊处理 */
:deep(.van-field--min-height .van-field__value) {
  padding-top: 8px;
  padding-bottom: 8px;
}

.loading-state, .error-state {
  padding-top: 100px;
  text-align: center;
}
.success-actions {
  padding: 20px;
}
.subtable-wrapper {
  padding: 10px 0;
}
.subtable-label {
  padding: 0 16px 8px;
  font-size: 14px;
  color: #646566;
}
.subtable-card {
  border-radius: 8px;
  margin: 0 16px 12px;
  padding: 12px;
  box-shadow: 0 1px 4px rgba(0,0,0,0.05);
}
.subtable-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-bottom: 8px;
  margin-bottom: 0;
  border-bottom: 1px solid #ebedf0;
  font-size: 14px;
  font-weight: bold;
  color: #323233;
}
.add-row-btn {
  padding: 0 16px;
}
</style>
