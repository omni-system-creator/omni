<template>
  <div class="widget-card">
    <div class="card-header">
      <h3>最近动态</h3>
      <a href="#" style="font-size: 12px;">查看全部</a>
    </div>
    <div class="activities-container">
      <a-timeline>
        <a-timeline-item color="green">
          <p class="activity-time">10:30</p>
          <p class="activity-content">用户 Admin 发布了新接口 <b>UserLogin</b></p>
        </a-timeline-item>
        <a-timeline-item color="blue">
          <p class="activity-time">09:45</p>
          <p class="activity-content">ETL 任务 <b>每日数据同步</b> 执行成功</p>
        </a-timeline-item>
        <a-timeline-item color="red">
          <p class="activity-time">Yesterday</p>
          <p class="activity-content">系统检测到数据库连接异常</p>
        </a-timeline-item>
        <a-timeline-item>
          <p class="activity-time">Yesterday</p>
          <p class="activity-content">管理员更新了系统配置</p>
        </a-timeline-item>
      </a-timeline>
    </div>
  </div>
</template>

<script setup lang="ts">
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
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.card-header h3 {
  margin: 0;
  font-size: 16px;
  color: #333;
}
.activities-container {
  flex: 1;
  overflow-y: auto;
  padding-right: 8px;
}
.activity-time {
  font-size: 12px;
  color: #999;
  margin: 0;
}
.activity-content {
  margin: 0;
  font-size: 13px;
  color: #333;
}
:deep(.ant-timeline-item) {
  padding-bottom: 16px;
}
:deep(.ant-timeline-item-last) {
  padding-bottom: 0;
}
</style>
