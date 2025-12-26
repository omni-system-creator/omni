<template>
  <div class="forms-index">
    <!-- Management View -->
    <div v-if="!isDesignerOpen" class="management-view">
      <SplitLayout :initialLeftWidth="280">
        <template #left>
          <CategoryTree @select="handleCategorySelect" />
        </template>
        <template #right>
          <FormList 
            :categoryId="currentCategoryId" 
            :categoryName="currentCategoryName"
            @open-designer="openDesigner"
          />
        </template>
      </SplitLayout>
    </div>

    <!-- Designer View -->
    <div v-else class="designer-view">
      <FormDesigner 
        :formId="currentForm.id" 
        :formName="currentForm.name"
        :initialContent="currentForm.content"
        @back="closeDesigner"
        @save="handleDesignerSave"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import SplitLayout from '@/components/SplitLayout/index.vue';
import CategoryTree from './components/CategoryTree.vue';
import FormList from './components/FormList.vue';
import FormDesigner from './components/FormDesigner.vue';
import { updateForm, getFormDetail, type FormCategory } from '@/api/form';

const currentCategoryId = ref<number | undefined>(undefined);
const currentCategoryName = ref('');
const isDesignerOpen = ref(false);
const currentForm = ref<any>({});

const handleCategorySelect = (category: FormCategory | null) => {
  if (category) {
    currentCategoryId.value = category.id;
    currentCategoryName.value = category.name;
  } else {
    currentCategoryId.value = undefined;
    currentCategoryName.value = '';
  }
};

const openDesigner = async (form: any) => {
  // Fetch latest detail to get content
  const res = await getFormDetail(form.id);
  currentForm.value = (res as any).data;
  isDesignerOpen.value = true;
};

const closeDesigner = () => {
  isDesignerOpen.value = false;
  currentForm.value = {};
};

const handleDesignerSave = async (content: string) => {
  if (currentForm.value.id) {
    await updateForm(currentForm.value.id, {
      ...currentForm.value,
      content
    });
    // Maybe show success message here or inside component
  }
};
</script>

<style scoped>
.forms-index {
  width: 100%;
  height: 100%;
}

.management-view {
  width: 100%;
  height: 100%;
}

.designer-view {
  width: 100%;
  height: 100%;
  position: fixed;
  top: 0;
  left: 0;
  z-index: 1000;
  background: #fff;
}
</style>
