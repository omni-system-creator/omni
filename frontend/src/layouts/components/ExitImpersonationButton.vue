<template>
  <!--
    根用 div（块级），和 OnlineUsersButton 的根 <div class="online-users-container"> 完全一致：
    1. 块级元素放进 a-space 后，会被 align-items: stretch 自动拉满父容器高度（header 全高）
       → 外层 .action-item 高度 = header 高度，hover 背景高和 StatusDropdown / OnlineUsersButton 严格齐平
    2. 内部 28px 的 a-button 单独加 align-self: center，保持本身尺寸和垂直居中，不随外层拉伸
    3. 不再用 inline-flex：inline-flex 本质还是 inline 盒，父容器不会向它传递固定高度参考，
       height:100% 就失效，外层会塌缩到内部按钮的 28px（就是你看到的现象）
  -->
  <div
    v-if="userStore.isImpersonating"
    class="action-item"
  >
    <a-tooltip
      :title="`退出模拟，回到「${userStore.impersonationOriginName || '原账号'}」`"
      placement="bottomLeft"
    >
      <a-button
        type="text"
        size="small"
        class="exit-impersonation-btn"
        @click.stop="handleExitImpersonation"
      >
        <!-- 用户指定的 logout SVG 图标 -->
        <svg
          focusable="false"
          data-icon="logout"
          width="1em"
          height="1em"
          fill="currentColor"
          aria-hidden="true"
          viewBox="64 64 896 896"
        >
          <path d="M868 732h-70.3c-4.8 0-9.3 2.1-12.3 5.8-7 8.5-14.5 16.7-22.4 24.5a353.84 353.84 0 01-112.7 75.9A352.8 352.8 0 01512.4 866c-47.9 0-94.3-9.4-137.9-27.8a353.84 353.84 0 01-112.7-75.9 353.28 353.28 0 01-76-112.5C167.3 606.2 158 559.9 158 512s9.4-94.2 27.8-137.8c17.8-42.1 43.4-80 76-112.5s70.5-58.1 112.7-75.9c43.6-18.4 90-27.8 137.9-27.8 47.9 0 94.3 9.3 137.9 27.8 42.2 17.8 80.1 43.4 112.7 75.9 7.9 7.9 15.3 16.1 22.4 24.5 3 3.7 7.6 5.8 12.3 5.8H868c6.3 0 10.2-7 6.7-12.3C798 160.5 663.8 81.6 511.3 82 271.7 82.6 79.6 277.1 82 516.4 84.4 751.9 276.2 942 512.4 942c152.1 0 285.7-78.8 362.3-197.7 3.4-5.3-.4-12.3-6.7-12.3zm88.9-226.3L815 393.7c-5.3-4.2-13-.4-13 6.3v76H488c-4.4 0-8 3.6-8 8v56c0 4.4 3.6 8 8 8h314v76c0 6.7 7.8 10.5 13 6.3l141.9-112a8 8 0 000-12.6z"></path>
        </svg>
      </a-button>
    </a-tooltip>
  </div>
</template>

<script lang="ts" setup>
import { useUserStore } from '@/stores/user';

const userStore = useUserStore();

// 退出模拟：与原 UserDropdown 里 handleExitImpersonation 一致，封装到组件内部
const handleExitImpersonation = async () => {
  try {
    await userStore.exitImpersonation();
  } catch (error) {
    console.error(error);
  }
};
</script>

<style scoped>
.action-item {
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.3s;
}

.exit-impersonation-btn {
  padding: 8px !important;
  width: 36px;
  height: 36px;
  min-width: 36px !important;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  color: #595959;
  border: 0 !important;
  border-radius: 4px;
}
.exit-impersonation-btn:hover {
  background: rgba(24, 144, 255, 0.08);
  color: #1890ff;
}
</style>
