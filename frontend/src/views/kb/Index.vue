<template>
  <div class="kb-container">
    <SplitLayout
      position="left"
      :min-width="200"
      :max-width="500"
      :default-width="200"
      save-key="kb-sidebar-width"
    >
      <template #sidebar>
        <KbSidebar
          @select="onKbSelect"
        />
      </template>
      <template #main>
        <div class="kb-body" ref="kbBodyRef">
          <div v-if="!currentKb" class="empty-state">
            <a-empty description="请选择或创建一个知识库" />
          </div>
          <SplitLayout 
            v-else-if="splitReady"
            position="right"
            :min-width="300" 
            :max-width="1600" 
            :default-width="splitWidth"
            save-key="kb-chat-width-v2"
          >
            <template #main>
              <KbExplorer
                :currentKb="currentKb"
              />
            </template>
            <template #sidebar>
              <KbChat
                :currentKb="currentKb"
              />
            </template>
          </SplitLayout>
        </div>
      </template>
    </SplitLayout>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, nextTick, watch } from 'vue';
import type { KbInfoDto } from '@/types/kb';
import SplitLayout from '@/components/SplitLayout/index.vue';

// Components
import KbSidebar from './components/KbSidebar.vue';
import KbExplorer from './components/KbExplorer.vue';
import KbChat from './components/KbChat.vue';

// --- State ---
const currentKb = ref<KbInfoDto | null>(null);
const kbBodyRef = ref<HTMLElement | null>(null);
const splitWidth = ref(480);
const splitReady = ref(false);

// --- Methods ---

const onKbSelect = (kb: KbInfoDto) => {
  currentKb.value = kb;
};

// --- Lifecycle ---
onMounted(() => {
  // 这里的 ResizeObserver 主要是为了应对初始状态就有 kbBody 的情况
  // 但如果初始 currentKb 为空，kbBody 不存在，ro 不会被 attach 或者 attach 到空
  // 所以主要依赖 watch(currentKb) 中的 nextTick 逻辑来初始化 splitWidth
});

// --- Watchers ---

// Fetch data when Current KB changes
watch(currentKb, (newKb) => {
  if (newKb) {
    // Measure container and show split
    nextTick(() => {
      try {
        if (kbBodyRef.value && !splitReady.value) {
          const w = kbBodyRef.value.clientWidth || 1000;
          splitWidth.value = Math.round(w / 2);
          splitReady.value = true;
        }
      } catch {
        splitReady.value = true;
      }
    });
  }
});
</script>

<style scoped>
.kb-container {
  display: flex;
  height: 100%;
  background: #fff;
}

.kb-body {
  width: 100%;
  height: 100%;
  overflow: hidden;
  position: relative;
}

.empty-state {
  width: 100%;
  height: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
}
</style>
