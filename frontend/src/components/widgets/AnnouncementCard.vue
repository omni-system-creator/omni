<template>
  <div class="widget-card announcement-card">
    <div class="card-header">
      <h3>
        <DynamicIcon icon="ant-design:sound-outlined" style="margin-right: 8px; color: #faad14;" />
        系统公告
      </h3>
      <a-tag color="blue">New</a-tag>
    </div>
    <div class="announcement-content">
      <div class="main-notice">
        <h4>关于系统将于本周日进行升级维护的通知</h4>
        <p class="notice-meta">发布时间：2023-10-27 10:00 &nbsp;|&nbsp; 发布人：系统管理员</p>
        <p class="notice-desc">
          尊敬的用户，为了提供更优质的服务，我们将于本周日（10月29日）凌晨 02:00 - 06:00 对系统进行升级维护。期间系统将无法访问，请提前做好数据保存。给您带来的不便敬请谅解。
        </p>
      </div>
      <div class="other-notices">
        <div class="notice-item">
          <span class="dot"></span>
          <span class="text">新版工作台上线通知</span>
          <span class="date">2023-10-25</span>
        </div>
        <div class="notice-item">
          <span class="dot"></span>
          <span class="text">关于加强账号安全管理的提醒</span>
          <span class="date">2023-10-20</span>
        </div>
        <div class="notice-item">
          <span class="dot"></span>
          <span class="text">国庆节放假安排通知</span>
          <span class="date">2023-09-28</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import DynamicIcon from '@/components/DynamicIcon.vue';
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
  margin-bottom: 12px;
  border-bottom: 1px solid #f0f0f0;
  padding-bottom: 8px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.card-header h3 {
  margin: 0;
  font-size: 16px;
  color: #333;
  display: flex;
  align-items: center;
}
.announcement-content {
  flex: 1;
  display: flex;
  gap: 24px;
  overflow: hidden;
}
.main-notice {
  flex: 2;
  padding-right: 24px;
  border-right: 1px solid #f0f0f0;
}
.main-notice h4 {
  font-size: 15px;
  color: #333;
  margin-bottom: 8px;
}
.notice-meta {
  font-size: 12px;
  color: #999;
  margin-bottom: 12px;
}
.notice-desc {
  font-size: 13px;
  color: #666;
  line-height: 1.6;
}
.other-notices {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
  padding-top: 4px;
}
.notice-item {
  display: flex;
  align-items: center;
  margin-bottom: 12px;
  font-size: 13px;
  cursor: pointer;
}
.notice-item:hover .text {
  color: #1890ff;
}
.dot {
  width: 6px;
  height: 6px;
  background: #d9d9d9;
  border-radius: 50%;
  margin-right: 8px;
}
.text {
  flex: 1;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  color: #333;
  margin-right: 8px;
}
.date {
  color: #999;
  font-size: 12px;
}
</style>
