<template>
  <div class="go-items-list">
    <!-- 加载 -->
    <div v-show="loading">
      <go-loading></go-loading>
    </div>
    <!-- 列表 -->
    <div v-show="!loading && list.length > 0">
      <n-grid :x-gap="20" :y-gap="20" cols="2 s:2 m:3 l:4 xl:4 xxl:4" responsive="screen">
        <n-grid-item v-for="(item, index) in list" :key="item.id">
          <project-items-card
            :cardData="item"
            @preview="previewHandle"
            @copy="(c) => copyHandle(c, fetchList)"
            @resize="resizeHandle"
            @delete="deleteHandle(item)"
            @release="releaseHandle(item, index)"
            @edit="editHandle"
          ></project-items-card>
        </n-grid-item>
      </n-grid>
    </div>

    <!-- 暂无数据 -->
    <div v-show="!loading && list.length === 0" class="go-items-list-empty">
      <n-empty description="暂无项目">
        <template #extra>
          <n-button size="small" type="primary" @click="openCreateModal">
            立即创建
          </n-button>
        </template>
      </n-empty>
    </div>

    <!-- 分页 -->
    <div class="list-pagination" v-show="list.length > 0">
      <n-pagination
        :page="paginat.page"
        :page-size="paginat.limit"
        :item-count="paginat.count"
        :page-sizes="[12, 24, 36, 48]"
        @update:page="changePage"
        @update:page-size="changeSize"
        show-size-picker
      />
    </div>
  </div>

  <!-- model -->
  <project-items-modal-card
    v-if="modalData"
    :modalShow="modalShow"
    :cardData="modalData"
    @close="closeModal"
    @edit="editHandle"
  ></project-items-modal-card>

  <!-- create modal -->
  <create-modal :show="createModalShow" @close="closeCreateModal"></create-modal>
</template>

<script setup lang="ts">
import { ProjectItemsCard } from '../ProjectItemsCard/index'
import { ProjectItemsModalCard } from '../ProjectItemsModalCard/index'
import { CreateModal } from '@/views/project/layout/components/ProjectLayoutCreate/components/CreateModal/index'
import { icon } from '@/plugins'
import { useModalDataInit } from './hooks/useModal.hook'
import { useDataListInit } from './hooks/useData.hook'
import { ref } from 'vue'

const { CopyIcon, EllipsisHorizontalCircleSharpIcon } = icon.ionicons5
const { modalData, modalShow, closeModal, copyHandle, previewHandle, resizeHandle, editHandle } = useModalDataInit()
const { loading, paginat, list, changeSize, changePage, releaseHandle, deleteHandle, fetchList } = useDataListInit()

const createModalShow = ref(false)
const openCreateModal = () => {
  createModalShow.value = true
}
const closeCreateModal = () => {
  createModalShow.value = false
}
</script>

<style lang="scss" scoped>
$contentHeight: 250px;
@include go('items-list') {
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  min-height: calc(100vh - #{$--header-height} - 40px - 2px);
  .list-content {
    position: relative;
    height: $contentHeight;
  }
  .list-pagination {
    display: flex;
    justify-content: flex-end;
    margin-top: 20px;
  }
  .go-items-list-empty {
    display: flex;
    flex: 1;
    flex-direction: column;
    align-items: center;
    justify-content: center;
  }
}
</style>
