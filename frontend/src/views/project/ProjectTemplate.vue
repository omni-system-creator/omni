<template>
  <div class="project-template-container">
    <a-row :gutter="16">
      <a-col :span="6">
        <a-card title="模板分类" :bordered="false" style="height: 100%">
          <a-menu v-model:selectedKeys="selectedKeys" mode="vertical" @click="handleMenuClick">
            <a-menu-item key="all">全部模板</a-menu-item>
            <a-menu-item key="dev">研发项目模板</a-menu-item>
            <a-menu-item key="impl">实施项目模板</a-menu-item>
            <a-menu-item key="internal">内部事务模板</a-menu-item>
            <a-menu-item key="custom">自定义模板</a-menu-item>
          </a-menu>
        </a-card>
      </a-col>
      <a-col :span="18">
        <a-card :bordered="false" title="模板列表">
          <template #extra>
             <a-button type="primary">
              <template #icon><PlusOutlined /></template>
              新建模板
            </a-button>
          </template>
          
          <a-list :grid="{ gutter: 16, column: 3 }" :data-source="templates">
            <template #renderItem="{ item }">
              <a-list-item>
                <a-card hoverable>
                  <template #actions>
                    <a-tooltip title="编辑"><EditOutlined key="edit" /></a-tooltip>
                    <a-tooltip title="复制"><CopyOutlined key="copy" /></a-tooltip>
                    <a-tooltip title="删除"><DeleteOutlined key="delete" /></a-tooltip>
                  </template>
                  <a-card-meta :title="item.title" :description="item.description">
                    <template #avatar>
                      <a-avatar style="background-color: #1890ff">{{ item.type[0] }}</a-avatar>
                    </template>
                  </a-card-meta>
                  <div style="margin-top: 16px; font-size: 12px; color: #888;">
                    <div>包含阶段：{{ item.phases }} 个</div>
                    <div>预设任务：{{ item.tasks }} 个</div>
                    <div>使用次数：{{ item.usageCount }} 次</div>
                  </div>
                </a-card>
              </a-list-item>
            </template>
          </a-list>
        </a-card>
      </a-col>
    </a-row>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { PlusOutlined, EditOutlined, CopyOutlined, DeleteOutlined } from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';

const selectedKeys = ref(['all']);

const templates = ref([
  { title: '敏捷研发标准模板', description: '适用于Sprint周期的敏捷开发项目', type: '研发', phases: 5, tasks: 24, usageCount: 156 },
  { title: '瀑布式开发模板', description: '传统的大型软件开发流程', type: '研发', phases: 6, tasks: 45, usageCount: 89 },
  { title: '标准实施项目模板', description: '适用于客户现场实施交付', type: '实施', phases: 4, tasks: 18, usageCount: 230 },
  { title: '市场活动模板', description: '市场推广与活动策划', type: '内部', phases: 3, tasks: 12, usageCount: 45 },
  { title: '年度审计模板', description: '财务与合规审计', type: '内部', phases: 4, tasks: 30, usageCount: 12 },
]);

const handleMenuClick = (e: any) => {
  message.info(`筛选分类：${e.key}`);
};
</script>

<style scoped>
.project-template-container {
  padding: 16px;
  flex: 1;
}
</style>
