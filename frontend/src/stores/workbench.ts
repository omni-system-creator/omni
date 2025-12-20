import { defineStore } from 'pinia';
import { ref } from 'vue';

export const useWorkbenchStore = defineStore('workbench', () => {
  const isEditMode = ref(false);

  function toggleEditMode() {
    isEditMode.value = !isEditMode.value;
  }

  function setEditMode(value: boolean) {
    isEditMode.value = value;
  }

  return {
    isEditMode,
    toggleEditMode,
    setEditMode,
  };
});
