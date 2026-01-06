<template>
  <div class="product-docs-container" v-if="documents.length > 0">
    <a-list :grid="{ gutter: 16, column: 4 }" :data-source="documents">
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
  </div>
  <div class="product-docs-empty" v-else>
    <a-spin :spinning="true" size="large" />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { FilePdfOutlined } from '@ant-design/icons-vue';
import type { ProductDocDto } from '@/api/sales';
import { getProductDocs } from '@/api/sales';

const documents = ref<ProductDocDto[]>([]);

const loadData = async () => {
  try {
    documents.value = await getProductDocs();
  } catch (e) {
    console.error('加载产品资料失败:', e);
  }
};

onMounted(() => {
  loadData();
});
</script>

<style scoped>
.product-docs-empty {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 200px;
}
</style>
