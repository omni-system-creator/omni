<template>
  <div class="home-container">
    <van-nav-bar title="工作台" fixed placeholder>
      <template #right>
        <van-icon name="plus" size="18" @click="showActionSheet = true" />
      </template>
    </van-nav-bar>
    
    <van-pull-refresh v-model="refreshing" @refresh="onRefresh" style="min-height: calc(100vh - 46px)">
      <div class="banner">
        <div class="user-card">
          <van-image
            v-if="userStore.avatar"
            round
            width="48px"
            height="48px"
            :src="userStore.avatar"
            class="avatar"
          />
          <div v-else class="avatar-placeholder">
            <van-icon name="user-o" size="24" color="#fff" />
          </div>
          <div class="welcome-text">
            <h3>早安，{{ userStore.nickname }}</h3>
            <p>今天也是充满活力的一天！</p>
          </div>
        </div>
        
        <div class="stats-row">
          <div class="stat-item">
            <span class="num">12</span>
            <span class="label">待办事项</span>
          </div>
          <div class="stat-item">
            <span class="num">5</span>
            <span class="label">待阅消息</span>
          </div>
          <div class="stat-item">
            <span class="num">3</span>
            <span class="label">发起审批</span>
          </div>
          <div class="stat-item">
            <span class="num">98%</span>
            <span class="label">本月考勤</span>
          </div>
        </div>
      </div>

      <van-notice-bar
        left-icon="volume-o"
        text="温馨提示：本周五下午3点在大会议室举行全员季度总结会议，请准时参加。"
        mode="closeable"
        background="#fff"
      />

      <van-grid :column-num="4" class="menu-grid">
        <van-grid-item icon="todo-list-o" text="待办事项" to="/todo" badge="5" />
        <van-grid-item icon="notes-o" text="审批流程" />
        <van-grid-item icon="manager-o" text="通讯录" to="/contacts" />
        <van-grid-item icon="clock-o" text="考勤打卡" />
        <van-grid-item icon="chart-trending-o" text="报表分析" />
        <van-grid-item icon="balance-list-o" text="我的报销" />
        <van-grid-item icon="calendar-o" text="会议室" />
        <van-grid-item icon="apps-o" text="更多应用" to="/apps" />
      </van-grid>

      <div class="section-card">
        <div class="card-header">
          <span class="title">今日日程</span>
          <span class="more" @click="$router.push('/schedule')">查看全部 <van-icon name="arrow" /></span>
        </div>
        <van-steps direction="vertical" :active="1" active-color="#1989fa">
          <van-step>
            <h3>部门晨会</h3>
            <p>09:00 - 10:00 | 2号会议室</p>
          </van-step>
          <van-step>
            <h3>产品需求评审</h3>
            <p>14:00 - 15:30 | 1号会议室</p>
          </van-step>
          <van-step>
            <h3>客户拜访</h3>
            <p>16:00 - 17:30 | 外出</p>
          </van-step>
        </van-steps>
      </div>

      <div class="section-card">
        <div class="card-header">
          <span class="title">常用服务</span>
        </div>
        <van-cell-group :border="false">
          <van-cell title="发起审批" is-link icon="add-o" />
          <van-cell title="IT报修" is-link icon="setting-o" />
          <van-cell title="用车申请" is-link icon="logistics" />
          <van-cell title="查看公告" is-link icon="volume-o" value="新通知" />
        </van-cell-group>
      </div>
    </van-pull-refresh>

    <van-action-sheet
      v-model:show="showActionSheet"
      :actions="actions"
      cancel-text="取消"
      close-on-click-action
      @select="onSelect"
    />
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { showToast } from 'vant';
import { useUserStore } from '@/stores/user';

const userStore = useUserStore();
const refreshing = ref(false);
const showActionSheet = ref(false);

const actions = [
  { name: '扫一扫', icon: 'scan' },
  { name: '新建待办', icon: 'todo-list-o' },
  { name: '发起审批', icon: 'notes-o' },
];

const onSelect = (item: any) => {
  showToast(item.name);
};

const onRefresh = () => {
  setTimeout(() => {
    showToast('刷新成功');
    refreshing.value = false;
  }, 1000);
};
</script>

<style scoped>
.home-container {
  min-height: 100vh;
  background-color: #f7f8fa;
}
.banner {
  background: linear-gradient(135deg, #1989fa, #39b9f5);
  padding: 20px 20px 30px;
  color: #fff;
  margin-bottom: 0;
}
.user-card {
  display: flex;
  align-items: center;
  margin-bottom: 24px;
}
.avatar {
  border: 2px solid rgba(255,255,255,0.4);
  margin-right: 12px;
}
.avatar-placeholder {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  background-color: #bfbfbf;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 2px solid rgba(255,255,255,0.4);
  margin-right: 12px;
}
.welcome-text h3 {
  margin: 0;
  font-size: 18px;
  font-weight: 500;
}
.welcome-text p {
  margin: 4px 0 0;
  font-size: 13px;
  opacity: 0.9;
}
.stats-row {
  display: flex;
  justify-content: space-between;
  padding: 0 10px;
}
.stat-item {
  text-align: center;
}
.stat-item .num {
  display: block;
  font-size: 20px;
  font-weight: bold;
  margin-bottom: 4px;
  font-family: DINAlternate-Bold, sans-serif;
}
.stat-item .label {
  font-size: 12px;
  opacity: 0.8;
}

.menu-grid {
  margin-top: 10px;
  background-color: #fff;
}

.section-card {
  margin: 10px;
  background: #fff;
  border-radius: 8px;
  overflow: hidden;
}
.card-header {
  padding: 15px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid #f5f6f7;
}
.card-header .title {
  font-weight: bold;
  font-size: 16px;
  border-left: 4px solid #1989fa;
  padding-left: 8px;
  line-height: 1;
}
.card-header .more {
  font-size: 12px;
  color: #969799;
  display: flex;
  align-items: center;
}

:deep(.van-step__title h3) {
  margin: 0 0 4px 0;
  font-size: 14px;
  font-weight: 500;
}
:deep(.van-step__title p) {
  margin: 0;
  font-size: 12px;
  color: #969799;
}
</style>
