<template>
  <div class="dict-manage-container">
    <SplitLayout>
      <template #left>
        <DictTypeTree @select="handleSelectType" />
      </template>
      <template #right>
        <DictDataList :selected-type="selectedType" />
      </template>
    </SplitLayout>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import SplitLayout from '@/components/SplitLayout/index.vue';
import DictTypeTree from './components/DictTypeTree.vue';
import DictDataList from './components/DictDataList.vue';
import type { DictTypeDto } from '@/api/dict';

const selectedType = ref<DictTypeDto | null>(null);

const handleSelectType = (type: DictTypeDto | null) => {
  selectedType.value = type;
};
</script>

<style scoped>
.dict-manage-container {
    padding: 10px;
    height: 100%;
    display: flex;
    flex-direction: column;
    overflow: hidden;
}
</style>
