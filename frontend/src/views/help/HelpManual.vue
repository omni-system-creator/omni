<template>
  <div class="help-manual-container">
    <a-layout style="height: 100%; background: #fff;">
      <a-layout-sider width="280" style="background: #fff; border-right: 1px solid #f0f0f0;">
        <div class="search-wrapper">
          <a-input-search
            v-model:value="searchText"
            placeholder="搜索帮助文档..."
            enter-button
            @search="onSearch"
          />
        </div>
        <a-menu
          v-model:selectedKeys="selectedKeys"
          mode="inline"
          style="border-right: 0;"
          :openKeys="openKeys"
        >
          <a-sub-menu key="start">
            <template #title>
              <span>
                <RocketOutlined />
                <span>快速开始</span>
              </span>
            </template>
            <a-menu-item key="intro">系统介绍</a-menu-item>
            <a-menu-item key="login">登录与注册</a-menu-item>
            <a-menu-item key="dashboard">工作台概览</a-menu-item>
          </a-sub-menu>
          <a-sub-menu key="modules">
            <template #title>
              <span>
                <AppstoreOutlined />
                <span>功能模块</span>
              </span>
            </template>
            <a-menu-item key="crm">客户管理 (CRM)</a-menu-item>
            <a-menu-item key="project">项目管理</a-menu-item>
            <a-menu-item key="contract">合同管理</a-menu-item>
            <a-menu-item key="inventory">库存管理</a-menu-item>
            <a-menu-item key="finance">财务管理</a-menu-item>
          </a-sub-menu>
          <a-sub-menu key="faq">
            <template #title>
              <span>
                <QuestionCircleOutlined />
                <span>常见问题</span>
              </span>
            </template>
            <a-menu-item key="password-reset">忘记密码怎么办？</a-menu-item>
            <a-menu-item key="browser">推荐使用什么浏览器？</a-menu-item>
            <a-menu-item key="export">如何导出报表？</a-menu-item>
          </a-sub-menu>
        </a-menu>
      </a-layout-sider>
      <a-layout-content style="padding: 24px; overflow-y: auto;">
        <div class="article-content">
          <a-typography>
            <a-typography-title :level="2">{{ currentArticle.title }}</a-typography-title>
            <a-divider />
            <a-typography-paragraph>
              <div class="article-body" v-html="currentArticle.content"></div>
            </a-typography-paragraph>
          </a-typography>
          
          <div v-if="!currentArticle.content" class="empty-state">
            <a-empty description="请在左侧选择帮助主题" />
          </div>
        </div>
      </a-layout-content>
    </a-layout>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import { 
  RocketOutlined, 
  AppstoreOutlined, 
  QuestionCircleOutlined 
} from '@ant-design/icons-vue';

const searchText = ref('');
const selectedKeys = ref(['intro']);
const openKeys = ref(['start', 'modules', 'faq']);

const articles: Record<string, { title: string, content: string }> = {
  intro: {
    title: '系统介绍',
    content: `
      <p>欢迎使用 <strong>金兰®综合信息管理系统</strong>。这是一个集成了组织管理、客户关系管理(CRM)、项目管理、合同管理、进销存(库存)、财务管理等多种功能于一体的企业级数字化管理平台。</p>
      <p>我们的目标是帮助企业实现业务流程的标准化、自动化和智能化，提升运营效率，降低管理成本。</p>
      <h3>主要特性：</h3>
      <ul>
        <li><strong>一站式管理：</strong> 打通各业务环节，数据互联互通。</li>
        <li><strong>高度可配置：</strong> 支持自定义流程、字段和报表。</li>
        <li><strong>安全可靠：</strong> 完备的权限控制和数据备份机制。</li>
      </ul>
    `
  },
  login: {
    title: '登录与注册',
    content: `
      <p>您可以通过以下方式访问系统：</p>
      <ol>
        <li>在浏览器地址栏输入系统网址。</li>
        <li>在登录页输入您的用户名和密码。</li>
        <li>点击“登录”按钮。</li>
      </ol>
      <p>如果您还没有账号，请联系系统管理员为您创建账号。</p>
    `
  },
  dashboard: {
    title: '工作台概览',
    content: `
      <p>登录系统后，您首先看到的是工作台（Dashboard）。工作台汇集了您最关心的核心数据和待办事项。</p>
      <p>您可以根据个人喜好自定义工作台的布局和展示内容，例如添加“今日销售额”、“待审批流程”、“我的任务”等卡片。</p>
    `
  },
  crm: {
    title: '客户管理 (CRM)',
    content: `
      <p>CRM 模块帮助您管理客户全生命周期，从线索获取、商机转化到客户维护。</p>
      <ul>
        <li><strong>线索管理：</strong> 记录和跟踪潜在客户线索。</li>
        <li><strong>客户档案：</strong> 建立完整的客户信息库，包括联系人、沟通记录等。</li>
        <li><strong>商机漏斗：</strong> 可视化展示销售漏斗，预测销售业绩。</li>
      </ul>
    `
  },
  project: {
    title: '项目管理',
    content: `
      <p>项目管理模块支持项目的立项、计划、执行和验收全过程管理。</p>
      <p>主要功能包括：项目任务分解(WBS)、进度跟踪(甘特图)、团队协作、文档共享等。</p>
    `
  },
  'password-reset': {
    title: '忘记密码怎么办？',
    content: '<p>如果您忘记了登录密码，请点击登录页面的“忘记密码”链接，按照提示通过邮箱或手机号找回。或者，您可以直接联系公司的系统管理员重置密码。</p>'
  },
  browser: {
    title: '推荐使用什么浏览器？',
    content: '<p>为了获得最佳的使用体验，我们强烈推荐使用最新版本的 <strong>Google Chrome</strong>、<strong>Microsoft Edge</strong> 或 <strong>Firefox</strong> 浏览器。系统不完全支持 IE 浏览器。</p>'
  }
};

const currentArticle = computed(() => {
  const key = selectedKeys.value[0];
  return articles[key as string] || {
    title: '文档未找到', 
    content: '<p>抱歉，该帮助主题的内容正在编写中...</p>' 
  };
});

const onSearch = () => {
  if (!searchText.value) return;
  // 简单的搜索逻辑：查找标题或内容包含关键字的文章
  const keyword = searchText.value.toLowerCase();
  for (const [key, article] of Object.entries(articles)) {
    if (article.title.toLowerCase().includes(keyword) || article.content.toLowerCase().includes(keyword)) {
      selectedKeys.value = [key];
      // 展开对应的 submenu (简化处理，这里默认都展开了)
      return;
    }
  }
};
</script>

<style scoped>
.help-manual-container {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.search-wrapper {
  padding: 16px;
  border-bottom: 1px solid #f0f0f0;
}

.article-content {
  max-width: 900px;
  margin: 0 auto;
  background: #fff;
  padding: 0 24px 48px;
  min-height: 100%;
}

.article-body {
  font-size: 16px;
  line-height: 1.8;
  color: #333;
}

.article-body :deep(h3) {
  margin-top: 24px;
  margin-bottom: 16px;
  font-weight: 600;
}

.article-body :deep(ul), .article-body :deep(ol) {
  padding-left: 24px;
  margin-bottom: 16px;
}

.article-body :deep(li) {
  margin-bottom: 8px;
}

.empty-state {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 400px;
}
</style>