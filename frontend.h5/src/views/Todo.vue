<template>
  <div class="todo-container">
    <div class="fixed-header">
      <van-nav-bar
        title="待办事项"
        left-text="返回"
        left-arrow
        @click-left="onClickLeft"
      />
      
      <van-search v-model="value" placeholder="搜索待办任务" />
    </div>

    <div class="header-placeholder"></div>

    <van-tabs v-model:active="activeTab" sticky offset-top="100px">
      <van-tab title="待处理">
        <van-pull-refresh v-model="refreshing" @refresh="onRefresh">
          <div class="todo-list">
            <div class="todo-card" v-for="item in todos" :key="item.id" @click="showDetail(item)">
              <div class="todo-header">
                <span class="todo-title">{{ item.title }}</span>
                <van-tag :type="getPriorityColor(item.priority)">{{ item.priority }}</van-tag>
              </div>
              <div class="todo-content">
                <p>来源: {{ item.source }}</p>
                <p>截止: {{ item.deadline }}</p>
              </div>
              <div class="todo-footer">
                <van-button size="small" type="primary" plain round>立即处理</van-button>
              </div>
            </div>
            <!-- 为了让空列表也能撑开高度以便下拉 -->
            <div v-if="todos.length === 0" style="min-height: 50vh">
               <van-empty description="暂无待处理任务" />
            </div>
          </div>
        </van-pull-refresh>
      </van-tab>
      <van-tab title="已处理">
        <van-pull-refresh v-model="refreshing" @refresh="onRefresh">
          <div style="min-height: 80vh">
            <van-empty description="暂无已处理任务" />
          </div>
        </van-pull-refresh>
      </van-tab>
      <van-tab title="我发起的">
        <van-pull-refresh v-model="refreshing" @refresh="onRefresh">
          <div style="min-height: 80vh">
            <van-empty description="暂无发起记录" />
          </div>
        </van-pull-refresh>
      </van-tab>
    </van-tabs>

    <van-action-sheet v-model:show="show" :title="currentItem?.title">
      <div class="content">
        <van-cell-group>
          <van-cell title="任务详情" :label="currentItem?.desc" />
          <van-cell title="优先级" :value="currentItem?.priority" />
          <van-cell title="截止时间" :value="currentItem?.deadline" />
        </van-cell-group>
        <div style="padding: 16px;">
          <van-button round block type="primary" @click="handleTask">
            提交处理
          </van-button>
        </div>
      </div>
    </van-action-sheet>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { showToast } from 'vant';

const router = useRouter();
const value = ref('');
const activeTab = ref(0);
const show = ref(false);
const currentItem = ref<any>(null);
const refreshing = ref(false);

const todos = ref([
  { id: 1, title: '采购合同审批 - 20231001', priority: 'High', source: '采购部', deadline: '2023-10-25', desc: '请审批关于服务器采购的合同，总金额 50,000 元。' },
  { id: 2, title: '请假申请 - 张三', priority: 'Medium', source: '研发部', deadline: '2023-10-24', desc: '张三申请年假 3 天。' },
  { id: 3, title: '季度报表审核', priority: 'Low', source: '财务部', deadline: '2023-10-30', desc: 'Q3 财务报表初稿审核。' },
  { id: 4, title: '新员工入职办理', priority: 'High', source: '人事部', deadline: '2023-10-23', desc: '李四入职手续办理。' },
  { id: 5, title: '项目立项审批', priority: 'High', source: '总经办', deadline: '2023-10-26', desc: 'OMS 二期项目立项申请。' },
]);

const onClickLeft = () => history.back();

const getPriorityColor = (p: string) => {
  if (p === 'High') return 'danger';
  if (p === 'Medium') return 'warning';
  return 'primary';
};

const showDetail = (item: any) => {
  currentItem.value = item;
  show.value = true;
};

const handleTask = () => {
  showToast('处理成功');
  show.value = false;
  // 移除处理项
  todos.value = todos.value.filter(t => t.id !== currentItem.value.id);
};

const onRefresh = () => {
  setTimeout(() => {
    showToast('刷新成功');
    refreshing.value = false;
  }, 1000);
};
</script>

<style scoped>
.todo-container {
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
.header-placeholder {
  height: 100px;
}
.todo-list {
  padding: 12px;
}
.todo-card {
  background: #fff;
  border-radius: 8px;
  padding: 16px;
  margin-bottom: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}
.todo-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}
.todo-title {
  font-weight: 500;
  font-size: 16px;
}
.todo-content {
  font-size: 13px;
  color: #666;
  margin-bottom: 12px;
}
.todo-content p {
  margin: 4px 0;
}
.todo-footer {
  text-align: right;
  border-top: 1px solid #f0f0f0;
  padding-top: 8px;
}
.content {
  padding: 16px 0;
}
</style>
