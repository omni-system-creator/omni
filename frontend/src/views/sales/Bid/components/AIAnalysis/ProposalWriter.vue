<template>
  <div class="proposal-writer">
    <a-row :gutter="24">
      <a-col :span="6">
        <a-card title="标书目录" class="catalog-card">
          <a-menu
            v-model:selectedKeys="selectedKeys"
            mode="inline"
            @click="handleMenuClick"
          >
            <a-menu-item v-for="item in catalog" :key="item.key">
              <template #icon>
                <FileTextOutlined />
              </template>
              {{ item.title }}
              <CheckCircleTwoTone v-if="item.status === 'completed'" two-tone-color="#52c41a" style="margin-left: 8px"/>
            </a-menu-item>
          </a-menu>
        </a-card>
      </a-col>
      <a-col :span="18">
        <a-card :title="currentChapter?.title || '编辑区域'" class="editor-card">
          <template #extra>
             <a-space>
               <a-button type="primary" ghost @click="handleAiGenerate" :loading="generating">
                 <ThunderboltOutlined /> AI一键生成
               </a-button>
               <a-button @click="handleSave">保存</a-button>
             </a-space>
          </template>
          
          <div v-if="currentChapter">
            <div class="requirements-tip">
               <InfoCircleOutlined style="color: #1890ff; margin-right: 5px"/>
               <strong>编写要求：</strong> {{ currentChapter.requirement }}
            </div>
            
            <a-textarea
              v-model:value="content"
              :rows="20"
              placeholder="在此编写内容，或点击右上角AI生成..."
            />
            
            <div class="image-generation" style="margin-top: 20px;">
               <a-divider orientation="left">图文增强</a-divider>
               <a-space>
                 <a-button size="small">
                    <PictureOutlined /> 插入架构图
                 </a-button>
                 <a-button size="small">
                    <BarChartOutlined /> 插入数据图表
                 </a-button>
               </a-space>
            </div>
          </div>
          <a-empty v-else description="请选择左侧章节开始编写" />
        </a-card>
      </a-col>
    </a-row>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue';
import { 
  FileTextOutlined, 
  ThunderboltOutlined, 
  CheckCircleTwoTone,
  InfoCircleOutlined,
  PictureOutlined,
  BarChartOutlined
} from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';

const selectedKeys = ref<string[]>(['1']);
const generating = ref(false);
const content = ref('');

const catalog = reactive([
  { key: '1', title: '1. 公司简介', status: 'completed', requirement: '重点突出500强背景及相关行业经验', content: '我司成立于...' },
  { key: '2', title: '2. 总体方案', status: 'pending', requirement: '响应招标文件第三章技术要求，提出整体架构设计', content: '' },
  { key: '3', title: '3. 项目实施计划', status: 'pending', requirement: '包含进度表、人员配置、风险控制', content: '' },
  { key: '4', title: '4. 售后服务承诺', status: 'pending', requirement: '提供7*24小时响应，驻场服务', content: '' },
]);

const currentChapter = ref<any>(catalog[0]);
content.value = catalog[0]?.content || '';

const handleMenuClick: any = ({ key }: { key: string }) => {
  const item = catalog.find(c => c.key === key);
  if (item) {
    currentChapter.value = item;
    content.value = item.content;
  }
};

const handleAiGenerate = () => {
  if (!currentChapter.value) return;
  
  generating.value = true;
  // Mock AI generation
  setTimeout(() => {
    content.value = `[AI生成内容 - 基于要求: ${currentChapter.value.requirement}]\n\n` +
                    `针对本项目，我们提出以下创新方案：\n` +
                    `1. 采用云原生架构，确保系统高可用性。\n` +
                    `2. 引入AI智能分析引擎，提升数据价值。\n` +
                    `3. ...\n\n` +
                    `(此处已自动优化措辞并排版)`;
    generating.value = false;
    message.success('内容已生成');
  }, 1500);
};

const handleSave = () => {
  if (currentChapter.value) {
    currentChapter.value.content = content.value;
    currentChapter.value.status = 'completed';
    message.success('保存成功');
  }
};
</script>

<style scoped>
.proposal-writer {
  min-height: 600px;
}
.catalog-card {
  height: 700px;
  overflow-y: auto;
}
.editor-card {
  height: 700px;
  display: flex;
  flex-direction: column;
}
.requirements-tip {
  background: #e6f7ff;
  padding: 10px;
  border-radius: 4px;
  margin-bottom: 15px;
  border: 1px solid #91d5ff;
}
</style>
