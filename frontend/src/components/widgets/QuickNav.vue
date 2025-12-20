<template>
  <div class="widget-card">
    <div class="card-header">
      <h3>快捷导航</h3>
    </div>
    <div class="nav-grid">
      <div class="nav-item" v-for="item in navItems" :key="item.title">
        <DynamicIcon :icon="item.icon" class="nav-icon" />
        <span class="nav-text">{{ item.title }}</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import DynamicIcon from '../DynamicIcon.vue';

const navItems = [
  { title: '合同录入', icon: 'ant-design:file-add-outlined' },
  { title: '项目立项', icon: 'ant-design:project-outlined' },
  { title: '费用报销', icon: 'ant-design:account-book-outlined' },
  { title: '客户查询', icon: 'ant-design:search-outlined' },
  { title: '审批中心', icon: 'ant-design:audit-outlined' },
  { title: '报表查看', icon: 'ant-design:bar-chart-outlined' },
];
</script>

<style scoped>
.widget-card {
  height: 100%;
  padding: 16px;
  background: #fff;
  border-radius: 8px;
  display: flex;
  flex-direction: column;
}
.card-header {
  margin-bottom: 16px;
  border-bottom: 1px solid #f0f0f0;
  padding-bottom: 8px;
}
.nav-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
  flex: 1;
}
.nav-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.3s;
  padding: 8px;
  border-radius: 4px;
}
.nav-item:hover {
  background: #f5f5f5;
  color: #1890ff;
}
.nav-icon {
  font-size: 24px;
  margin-bottom: 8px;
}
.nav-text {
  font-size: 12px;
}
</style>
