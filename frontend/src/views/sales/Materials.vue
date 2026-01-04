<template>
  <div class="page-container">
    <a-tabs v-model:activeKey="activeTab">
      <a-tab-pane key="1" tab="话术库">
        <div class="material-list">
          <a-card v-for="script in salesScripts" :key="script.id" :title="script.title" class="material-card">
            <p>{{ script.content }}</p>
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
                <template #extra><a :href="item.url" target="_blank">下载</a></template>
                <FilePdfOutlined style="font-size: 48px; color: #ff4d4f; display: block; margin: 0 auto 16px" />
                <div style="text-align: center">{{ item.size }}</div>
              </a-card>
            </a-list-item>
          </template>
        </a-list>
      </a-tab-pane>
      <a-tab-pane key="3" tab="流程规则">
        <a-collapse v-model:activeKey="activeKey">
          <a-collapse-panel v-for="rule in processRules" :key="rule.id" :header="rule.title">
            <p>{{ rule.content }}</p>
          </a-collapse-panel>
        </a-collapse>
      </a-tab-pane>
    </a-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { CopyOutlined, EditOutlined, FilePdfOutlined } from '@ant-design/icons-vue';
import { getSalesScripts, getProductDocs, getProcessRules, type SalesScriptDto, type ProductDocDto, type ProcessRuleDto } from '@/api/sales';

const activeTab = ref('1');
const activeKey = ref(['1']);

const salesScripts = ref<SalesScriptDto[]>([]);
const productDocs = ref<ProductDocDto[]>([]);
const processRules = ref<ProcessRuleDto[]>([]);

const loadData = async () => {
    try {
        const [scripts, docs, rules] = await Promise.all([
            getSalesScripts(),
            getProductDocs(),
            getProcessRules()
        ]);
        salesScripts.value = scripts;
        productDocs.value = docs;
        processRules.value = rules;
    } catch (e) {
        console.error(e);
    }
};

onMounted(() => {
    loadData();
});
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