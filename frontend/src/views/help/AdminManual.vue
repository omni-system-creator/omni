<template>
  <div class="help-manual-container">
    <a-layout style="height: 100%; background: #fff;">
      <a-layout-sider width="280" style="background: #fff; border-right: 1px solid #f0f0f0;">
        <div class="search-wrapper">
          <a-input-search
            v-model:value="searchText"
            placeholder="搜索运维文档..."
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
          <a-sub-menu key="deploy">
            <template #title>
              <span>
                <CloudServerOutlined />
                <span>部署与安装</span>
              </span>
            </template>
            <a-menu-item key="env">环境要求</a-menu-item>
            <a-menu-item key="install">安装步骤</a-menu-item>
            <a-menu-item key="config">配置文件说明</a-menu-item>
          </a-sub-menu>
          <a-sub-menu key="maintenance">
            <template #title>
              <span>
                <ToolOutlined />
                <span>日常运维</span>
              </span>
            </template>
            <a-menu-item key="backup">数据备份与恢复</a-menu-item>
            <a-menu-item key="logs">日志查看与分析</a-menu-item>
            <a-menu-item key="update">系统升级流程</a-menu-item>
          </a-sub-menu>
          <a-sub-menu key="security">
            <template #title>
              <span>
                <SafetyCertificateOutlined />
                <span>安全管理</span>
              </span>
            </template>
            <a-menu-item key="audit">审计日志</a-menu-item>
            <a-menu-item key="permissions">权限体系说明</a-menu-item>
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
            <a-empty description="请在左侧选择运维主题" />
          </div>
        </div>
      </a-layout-content>
    </a-layout>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import { 
  CloudServerOutlined, 
  ToolOutlined, 
  SafetyCertificateOutlined 
} from '@ant-design/icons-vue';

const searchText = ref('');
const selectedKeys = ref(['env']);
const openKeys = ref(['deploy', 'maintenance', 'security']);

const articles: Record<string, { title: string, content: string }> = {
  env: {
    title: '环境要求',
    content: `
      <p>部署 OMS 系统需要满足以下基础环境要求：</p>
      <h3>硬件配置</h3>
      <ul>
        <li><strong>CPU：</strong> 4核及以上</li>
        <li><strong>内存：</strong> 8GB及以上</li>
        <li><strong>磁盘：</strong> 100GB SSD及以上</li>
      </ul>
      <h3>软件依赖</h3>
      <ul>
        <li><strong>操作系统：</strong> CentOS 7.9 / Ubuntu 20.04 LTS</li>
        <li><strong>数据库：</strong> MySQL 8.0+</li>
        <li><strong>缓存：</strong> Redis 6.0+</li>
        <li><strong>运行环境：</strong> Node.js 18+, JDK 17, Nginx 1.20+</li>
      </ul>
    `
  },
  install: {
    title: '安装步骤',
    content: `
      <p>标准 Docker 部署流程如下：</p>
      <ol>
        <li>安装 Docker 和 Docker Compose。</li>
        <li>获取 docker-compose.yml 配置文件。</li>
        <li>执行 <code>docker-compose up -d</code> 启动服务。</li>
        <li>检查容器状态：<code>docker ps</code>。</li>
      </ol>
    `
  },
  config: {
    title: '配置文件说明',
    content: `
      <p>系统核心配置文件位于 <code>/etc/oms/config.yaml</code> (或项目根目录 .env)。</p>
      <p>主要配置项说明：</p>
      <ul>
        <li><strong>DB_HOST:</strong> 数据库地址</li>
        <li><strong>REDIS_HOST:</strong> Redis 地址</li>
        <li><strong>JWT_SECRET:</strong> Token 签名密钥（部署时务必修改）</li>
      </ul>
    `
  },
  backup: {
    title: '数据备份与恢复',
    content: `
      <h3>自动备份</h3>
      <p>系统默认每天凌晨 02:00 执行全量数据库备份，保留最近 7 天的数据。</p>
      <h3>手动恢复</h3>
      <p>使用 mysql 命令行工具导入 SQL 文件：</p>
      <pre>mysql -u root -p oms_db < backup_20231201.sql</pre>
    `
  },
  logs: {
    title: '日志查看与分析',
    content: `
      <p>系统日志路径：<code>/var/log/oms/</code></p>
      <ul>
        <li><strong>access.log:</strong> Nginx 访问日志</li>
        <li><strong>error.log:</strong> 系统错误日志</li>
        <li><strong>app.log:</strong> 应用业务日志</li>
      </ul>
      <p>建议接入 ELK 或 Loki 进行日志聚合分析。</p>
    `
  },
  update: {
    title: '系统升级流程',
    content: `
      <ol>
        <li>备份数据库和配置文件。</li>
        <li>拉取最新 Docker 镜像：<code>docker-compose pull</code></li>
        <li>重启服务：<code>docker-compose up -d</code></li>
        <li>验证系统功能是否正常。</li>
      </ol>
    `
  },
  audit: {
    title: '审计日志',
    content: `
      <p>系统自动记录关键操作的审计日志，包括登录、敏感数据修改、权限变更等。</p>
      <p>管理员可在“系统管理 -> 操作日志”菜单中查看详细记录。</p>
    `
  },
  permissions: {
    title: '权限体系说明',
    content: `
      <p>OMS 采用 RBAC (Role-Based Access Control) 权限模型。</p>
      <ul>
        <li><strong>用户 (User):</strong> 系统的操作主体。</li>
        <li><strong>角色 (Role):</strong> 权限的集合。</li>
        <li><strong>权限 (Permission):</strong> 具体的操作资源（菜单、按钮、API）。</li>
      </ul>
    `
  }
};

const currentArticle = computed(() => {
  const key = selectedKeys.value[0];
  return articles[key as string] || {
    title: '文档未找到', 
    content: '<p>该主题暂无详细文档。</p>' 
  };
});

const onSearch = () => {
  if (!searchText.value) return;
  const keyword = searchText.value.toLowerCase();
  for (const [key, article] of Object.entries(articles)) {
    if (article.title.toLowerCase().includes(keyword) || article.content.toLowerCase().includes(keyword)) {
      selectedKeys.value = [key];
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

.article-body :deep(pre) {
  background: #f5f5f5;
  padding: 12px;
  border-radius: 4px;
  overflow-x: auto;
}

.article-body :deep(code) {
  background: #f5f5f5;
  padding: 2px 6px;
  border-radius: 4px;
  color: #d63384;
}

.empty-state {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 400px;
}
</style>