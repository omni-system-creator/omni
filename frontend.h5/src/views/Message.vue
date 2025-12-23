<template>
  <div class="message-container">
    <van-nav-bar title="消息中心" fixed placeholder />
    
    <van-tabs v-model:active="active" sticky offset-top="46px">
      <van-tab title="全部">
        <van-pull-refresh v-model="refreshing" @refresh="onRefresh">
          <van-list
            v-model:loading="loading"
            :finished="finished"
            finished-text="没有更多了"
            @load="onLoad"
          >
            <van-cell v-for="item in list" :key="item.id" :title="item.title" :label="item.desc" :value="item.time" center>
              <template #icon>
                <van-badge :dot="!item.read" style="margin-right: 10px">
                  <div class="msg-icon" :class="item.type">
                    <van-icon :name="getIcon(item.type)" />
                  </div>
                </van-badge>
              </template>
            </van-cell>
          </van-list>
        </van-pull-refresh>
      </van-tab>
      <van-tab title="审批">
        <van-pull-refresh v-model="refreshingApproval" @refresh="onRefreshApproval">
          <div class="approval-list">
             <van-cell-group inset class="approval-item" v-for="i in 5" :key="i">
              <van-cell center>
                <template #title>
                  <div class="approval-header">
                    <span class="approval-title">请假申请 - 张三</span>
                    <span class="approval-status warning">待审批</span>
                  </div>
                </template>
                <template #label>
                  <div class="approval-content">
                    <p>申请类型：年假</p>
                    <p>申请时间：2023-10-{{ 20 + i }}</p>
                    <p>请假天数：3天</p>
                  </div>
                  <div class="approval-footer">
                    <van-button size="small" type="primary" plain round>同意</van-button>
                    <van-button size="small" type="danger" plain round style="margin-left: 8px">拒绝</van-button>
                  </div>
                </template>
              </van-cell>
            </van-cell-group>
          </div>
        </van-pull-refresh>
      </van-tab>
      <van-tab title="通知">
        <van-pull-refresh v-model="refreshingNotice" @refresh="onRefreshNotice">
          <div class="notice-list">
            <van-cell-group inset class="notice-item" v-for="i in 3" :key="i">
              <van-cell center>
                <template #title>
                  <span class="notice-title">系统维护通知</span>
                  <van-tag type="danger" plain style="margin-left: 8px">重要</van-tag>
                </template>
                <template #label>
                  <div class="notice-desc">为了提供更好的服务，系统将于本周六凌晨 02:00 进行例行维护，预计耗时 2 小时。</div>
                  <div class="notice-time">2023-10-{{ 20 + i }} 10:00</div>
                </template>
              </van-cell>
            </van-cell-group>
          </div>
        </van-pull-refresh>
      </van-tab>
    </van-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { showToast } from 'vant';

const active = ref(0);
const list = ref<any[]>([]);
const loading = ref(false);
const finished = ref(false);
const refreshing = ref(false);
const refreshingApproval = ref(false);
const refreshingNotice = ref(false);

const getIcon = (type: string) => {
  switch(type) {
    case 'system': return 'bell';
    case 'workflow': return 'todo-list';
    case 'chat': return 'chat';
    default: return 'bell';
  }
};

const onLoad = () => {
  // 模拟异步请求
  setTimeout(() => {
    if (refreshing.value) {
      list.value = [];
      refreshing.value = false;
    }
    
    for (let i = 0; i < 10; i++) {
      const id = list.value.length + 1;
      list.value.push({
        id,
        title: `系统通知消息 ${id}`,
        desc: '这是一条模拟的系统通知消息内容...',
        time: '10:00',
        read: i > 2,
        type: i % 3 === 0 ? 'system' : (i % 3 === 1 ? 'workflow' : 'chat')
      });
    }

    // 加载状态结束
    loading.value = false;

    // 数据全部加载完成
    if (list.value.length >= 20) {
      finished.value = true;
    }
  }, 1000);
};

const onRefresh = () => {
  // 清空列表数据
  finished.value = false;

  // 重新加载数据
  // 将 loading 设置为 true，表示处于加载状态
  loading.value = true;
  onLoad();
};

const onRefreshApproval = () => {
  setTimeout(() => {
    showToast('刷新成功');
    refreshingApproval.value = false;
  }, 1000);
};

const onRefreshNotice = () => {
  setTimeout(() => {
    showToast('刷新成功');
    refreshingNotice.value = false;
  }, 1000);
};
</script>

<style scoped>
.msg-icon {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 20px;
}
.msg-icon.system {
  background-color: #1989fa;
}
.msg-icon.workflow {
  background-color: #ff976a;
}
.msg-icon.chat {
  background-color: #07c160;
}

.notice-list, .approval-list {
  padding: 12px 0;
  background-color: #f7f8fa;
  min-height: calc(100vh - 90px);
}
.notice-item, .approval-item {
  margin-bottom: 12px;
}
.notice-title {
  font-weight: bold;
  font-size: 15px;
}
.notice-desc {
  margin-top: 4px;
  color: #646566;
  font-size: 13px;
  line-height: 1.5;
}
.notice-time {
  margin-top: 8px;
  color: #969799;
  font-size: 12px;
}

.approval-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.approval-title {
  font-weight: bold;
  font-size: 15px;
}
.approval-status {
  font-size: 12px;
  padding: 2px 6px;
  border-radius: 4px;
}
.approval-status.warning {
  color: #ff976a;
  background-color: rgba(255, 151, 106, 0.1);
}
.approval-content {
  margin: 8px 0;
  padding: 8px;
  background-color: #f7f8fa;
  border-radius: 4px;
}
.approval-content p {
  margin: 4px 0;
  font-size: 13px;
  color: #646566;
}
.approval-footer {
  display: flex;
  justify-content: flex-end;
  margin-top: 8px;
}
</style>
