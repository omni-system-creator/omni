<template>
  <div @click="clickHandle">
    <n-tooltip v-if="collapsed" placement="right" trigger="hover">
      <template #trigger>
        <n-button ghost type="primary" size="small">
          <template #icon>
            <n-icon>
              <DuplicateOutlineIcon v-show="designStore.getDarkTheme"></DuplicateOutlineIcon>
              <DuplicateIcon v-show="!designStore.getDarkTheme"></DuplicateIcon>
            </n-icon>
          </template>
        </n-button>
      </template>
      <span>
        {{ $t('project.create_btn') }}
      </span>
    </n-tooltip>
    <n-button v-else ghost type="primary">
      <template #icon>
        <n-icon>
          <DuplicateOutlineIcon v-show="designStore.getDarkTheme"></DuplicateOutlineIcon>
          <DuplicateIcon v-show="!designStore.getDarkTheme"></DuplicateIcon>
        </n-icon>
      </template>
      <span>
        {{ $t('project.create_btn') }}
      </span>
    </n-button>
  </div>
  <CreateModal :show="modalShow" @close="closeHandle"></CreateModal>
</template>
<script setup lang="ts">
import { ref } from 'vue'
import { useDesignStore } from '@/store/modules/designStore/designStore'
import { CreateModal } from './components/CreateModal/index'
import { icon } from '@/plugins'
import { myDecrypt } from '@/utils/crypto'

const { DuplicateIcon, DuplicateOutlineIcon } = icon.ionicons5
const designStore = useDesignStore()

const props = defineProps({
  collapsed: Boolean
})

const modalShow = ref<boolean>(false)

const clickHandle = () => {
  modalShow.value = true
  console.log('1',myDecrypt('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'))
  console.log('2',myDecrypt('31KDpmVjM+DIRvUGuMbfDBmgFSw6FrmRb/EbEkPnesIRbdQqUgotJMVDQKh0bwgquCl4V70tvthndMqnrPSR83ImNQJYDrfvXNe3sk2cekP8MHcw8GSVNSVTWneWTM1t6GDYa86f5HhHkEh0esxrc6giIvsLDg8wCzv1hrVcJ3xaoEjBvwpVfvtR9Y8mLkqV4+C/Bnim4gt5ROah8P2jjw=='))
}

const closeHandle = () => {
  modalShow.value = false
}
</script>
