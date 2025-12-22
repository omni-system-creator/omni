<template>
  <div class="watermark-settings-content">
    <a-card :bordered="false">
      <a-form layout="vertical" :model="formState" @finish="onFinish">
        <a-row :gutter="24">
          <a-col :span="12">
            <a-form-item label="水印内容" name="content">
              <a-input v-model:value="formState.content" placeholder="请输入水印内容，支持变量 {username}, {date}" />
              <div class="tip">支持变量：{username} - 当前用户名, {date} - 当前日期</div>
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="字体大小" name="fontSize">
              <a-slider v-model:value="formState.fontSize" :min="12" :max="48" />
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="24">
          <a-col :span="12">
            <a-form-item label="字体颜色" name="color">
              <a-input type="color" v-model:value="formState.color" style="width: 100px" />
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="透明度" name="opacity">
              <a-slider v-model:value="formState.opacity" :min="0" :max="1" :step="0.1" />
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="24">
          <a-col :span="12">
            <a-form-item label="旋转角度" name="rotate">
              <a-slider v-model:value="formState.rotate" :min="-90" :max="90" />
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="启用状态" name="enabled">
              <a-switch v-model:checked="formState.enabled" checked-children="开启" un-checked-children="关闭" />
            </a-form-item>
          </a-col>
        </a-row>

        <a-divider>预览效果</a-divider>
        <div class="preview-container" :style="previewStyle">
          <div class="watermark-layer" :style="watermarkStyle">
            {{ previewText }}
          </div>
          <div class="content-layer">
            <h3>示例文件内容</h3>
            <p>这是一个水印效果预览区域。水印将覆盖在文档内容之上，用于防止截屏泄密。</p>
            <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>
            <p>这是一段测试文本，用于展示水印在实际文档中的显示效果。</p>
          </div>
        </div>

        <a-form-item style="margin-top: 24px">
          <a-button type="primary" html-type="submit">保存设置</a-button>
          <a-button style="margin-left: 10px" @click="resetForm">恢复默认</a-button>
        </a-form-item>
      </a-form>
    </a-card>
  </div>
</template>

<script setup lang="ts">
import { reactive, computed } from 'vue';
import { message } from 'ant-design-vue';

const formState = reactive({
  content: '{username} {date}',
  fontSize: 16,
  color: '#000000',
  opacity: 0.15,
  rotate: -20,
  enabled: true
});

const previewText = computed(() => {
  let text = formState.content;
  text = text.replace('{username}', 'Admin');
  text = text.replace('{date}', new Date().toLocaleDateString());
  return text;
});

const watermarkStyle = computed(() => ({
  position: 'absolute' as const,
  top: '50%',
  left: '50%',
  transform: `translate(-50%, -50%) rotate(${formState.rotate}deg)`,
  fontSize: `${formState.fontSize}px`,
  color: formState.color,
  opacity: formState.opacity,
  pointerEvents: 'none' as const,
  whiteSpace: 'nowrap' as const,
  zIndex: 10
}));

const previewStyle = computed(() => ({
  position: 'relative' as const,
  width: '100%',
  height: '200px',
  border: '1px solid #d9d9d9',
  background: '#fff',
  overflow: 'hidden',
  display: 'flex',
  justifyContent: 'center',
  alignItems: 'center'
}));

const onFinish = (values: any) => {
  console.log('Success:', values);
  message.success('水印设置已保存');
};

const resetForm = () => {
  formState.content = '{username} {date}';
  formState.fontSize = 16;
  formState.color = '#000000';
  formState.opacity = 0.15;
  formState.rotate = -20;
  formState.enabled = true;
};
</script>

<style scoped>
.watermark-settings-content {
  padding: 0;
}
.tip {
  font-size: 12px;
  color: #999;
  margin-top: 4px;
}
.content-layer {
  padding: 20px;
  text-align: center;
  color: #333;
}
</style>
