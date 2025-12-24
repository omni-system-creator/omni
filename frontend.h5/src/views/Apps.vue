<template>
  <div class="apps-container">
    <div class="fixed-header">
      <van-nav-bar
        title="全部应用"
        left-text="返回"
        left-arrow
        @click-left="onClickLeft"
      />
      <van-search v-model="searchValue" placeholder="搜索应用" shape="round" />
    </div>

    <div class="apps-content">
      <div class="app-group" v-for="group in filteredApps" :key="group.title">
        <div class="group-title">{{ group.title }}</div>
        <van-grid :column-num="4" :border="false">
          <van-grid-item
            v-for="app in group.items"
            :key="app.text"
            :icon="app.icon"
            :text="app.text"
            :to="app.to"
            :class="{ 'is-disabled': app.disabled }"
            @click="onAppClick(app)"
          />
        </van-grid>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import { useRouter } from 'vue-router';
import { showToast } from 'vant';

const router = useRouter();
const searchValue = ref('');

const onClickLeft = () => {
  router.back();
};

interface AppItem {
  text: string;
  icon: string;
  to?: string;
  disabled?: boolean;
}

const allApps: { title: string; items: AppItem[] }[] = [
  {
    title: '常用应用',
    items: [
      { text: '待办事项', icon: 'todo-list-o', to: '/todo' },
      { text: '审批流程', icon: 'notes-o' },
      { text: '通讯录', icon: 'manager-o' },
      { text: '考勤打卡', icon: 'clock-o' },
    ]
  },
  {
    title: '行政办公',
    items: [
      { text: '会议室', icon: 'calendar-o' },
      { text: '车辆管理', icon: 'logistics' },
      { text: '办公用品', icon: 'bag-o' },
      { text: '公告通知', icon: 'volume-o' },
      { text: '文档中心', icon: 'description' },
    ]
  },
  {
    title: '人力资源',
    items: [
      { text: '薪资条', icon: 'gold-coin-o' },
      { text: '绩效考核', icon: 'chart-trending-o' },
      { text: '招聘管理', icon: 'friends-o' },
      { text: '培训学习', icon: 'play-circle-o' },
    ]
  },
  {
    title: '财务管理',
    items: [
      { text: '我的报销', icon: 'balance-list-o' },
      { text: '付款申请', icon: 'bill-o' },
      { text: '借款申请', icon: 'credit-pay' },
      { text: '合同管理', icon: 'orders-o' },
    ]
  },
  {
    title: '系统工具',
    items: [
      { text: '访客预约', icon: 'qr' },
      { text: '意见反馈', icon: 'comment-o' },
      { text: '帮助中心', icon: 'question-o' },
    ]
  }
];

const filteredApps = computed(() => {
  if (!searchValue.value) return allApps;
  
  const keyword = searchValue.value.toLowerCase();
  return allApps.map(group => ({
    ...group,
    items: group.items.filter(item => item.text.includes(keyword))
  })).filter(group => group.items.length > 0);
});

const onAppClick = (app: any) => {
  if (!app.to) {
    showToast('功能开发中');
  }
};
</script>

<style scoped>
.apps-container {
  min-height: 100vh;
  background-color: #f7f8fa;
}

.fixed-header {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 999;
  background-color: #fff;
}

.apps-content {
  padding-top: calc(54px + var(--nav-bar-height)); /* nav-bar(46px) + search(54px) */
  padding-bottom: 20px;
}

.app-group {
  margin-top: 10px;
  background: #fff;
}

.group-title {
  padding: 16px 16px 8px;
  font-size: 14px;
  font-weight: 500;
  color: #323233;
}

.is-disabled {
  opacity: 0.5;
}
</style>
