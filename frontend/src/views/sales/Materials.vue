<template>
  <div class="page-container">
    <a-tabs v-model:activeKey="activeTab">
      <a-tab-pane key="1" tab="话术库">
        <div class="material-list">
          <a-card title="初次接触话术" class="material-card">
            <p>适用于电话或面谈初次接触客户...</p>
            <template #actions>
              <CopyOutlined key="copy" />
              <EditOutlined key="edit" />
            </template>
          </a-card>
          <a-card title="产品介绍话术" class="material-card">
            <p>针对不同痛点的产品价值阐述...</p>
            <template #actions>
              <CopyOutlined key="copy" />
              <EditOutlined key="edit" />
            </template>
          </a-card>
        </div>
      </a-tab-pane>
      <a-tab-pane key="2" tab="产品资料">
        <a-list :grid="{ gutter: 16, column: 4 }" :data-source="productDocs">
          <template #renderItem="{ item }">
            <a-list-item>
              <a-card :title="item.title">
                <template #extra><a href="#">下载</a></template>
                <FilePdfOutlined style="font-size: 48px; color: #ff4d4f; display: block; margin: 0 auto 16px" />
                <div style="text-align: center">{{ item.size }}</div>
              </a-card>
            </a-list-item>
          </template>
        </a-list>
      </a-tab-pane>
      <a-tab-pane key="3" tab="流程规则">
        <a-collapse v-model:activeKey="activeKey">
          <a-collapse-panel key="1" header="销售提成制度">
            <p>详细的销售提成计算规则...</p>
          </a-collapse-panel>
          <a-collapse-panel key="2" header="合同审批流程">
            <p>合同审批的各级节点和要求...</p>
          </a-collapse-panel>
        </a-collapse>
      </a-tab-pane>
    </a-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { CopyOutlined, EditOutlined, FilePdfOutlined } from '@ant-design/icons-vue';

const activeTab = ref('1');
const activeKey = ref(['1']);

const productDocs = [
  { title: '产品白皮书.pdf', size: '2.5MB' },
  { title: '功能清单.pdf', size: '1.2MB' },
  { title: '竞品分析报告.pdf', size: '3.8MB' },
  { title: '用户操作手册.pdf', size: '5.0MB' },
];
</script>

<style scoped>
.page-container {
  padding: 24px;
  background: #fff;
}

.material-list {
  display: flex;
  gap: 24px;
  flex-wrap: wrap;
}

.material-card {
  width: 300px;
}
</style>