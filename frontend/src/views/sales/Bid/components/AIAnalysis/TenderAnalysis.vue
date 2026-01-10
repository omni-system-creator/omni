<template>
  <div class="tender-analysis">
    <a-card 
      title="招标文件内容分析" 
      :bordered="false" 
      style="height: 100%; display: flex; flex-direction: column" 
      :body-style="{ padding: '0', flex: 1, overflow: 'hidden' }"
    >
      <template #extra>
        <a-space>
          <a-upload
            v-if="!fileInfo"
            name="file"
            :multiple="false"
            :show-upload-list="false"
            :customRequest="customRequest"
          >
            <a-button type="primary" :disabled="analyzing">
              <upload-outlined /> 上传招标文件
            </a-button>
          </a-upload>
          <div v-if="fileInfo" style="display: flex; align-items: center; margin-left: 10px;">
            <PaperClipOutlined style="margin-right: 5px" />
            <span style="margin-right: 10px">{{ fileInfo.name }}</span>
            <a-dropdown>
              <a class="ant-dropdown-link" @click.prevent>
                <MoreOutlined style="font-size: 16px; color: #1890ff; cursor: pointer" />
              </a>
              <template #overlay>
                <a-menu>
                  <a-menu-item key="preview" @click="handlePreview">
                    预览
                  </a-menu-item>
                  <a-menu-item key="download" @click="handleDownload">
                    下载
                  </a-menu-item>
                  <a-menu-item key="reanalyze" @click="handleReanalyze">
                    重新分析招标文件
                  </a-menu-item>
                  <a-menu-item key="reupload">
                    <a-upload
                      name="file"
                      :multiple="false"
                      :show-upload-list="false"
                      :customRequest="customRequest"
                    >
                      <div style="width: 100%">重新上传</div>
                    </a-upload>
                  </a-menu-item>
                </a-menu>
              </template>
            </a-dropdown>
          </div>
        </a-space>
      </template>

      <div v-if="analyzing" class="analyzing-state">
        <a-spin tip="正在解析招标文件结构、提取关键评分项及废标条款..." size="large" />
        <div style="margin-top: 24px; text-align: center;">
          <a-button danger @click="handleCancelAnalysis">取消分析</a-button>
        </div>
        <div v-if="logs.length" style="max-width: 900px; margin: 24px auto 0;">
          <a-card size="small" title="分析日志" :bordered="false">
            <a-list :data-source="logs" size="small">
              <template #renderItem="{ item }">
                <a-list-item>
                  <span style="color: rgba(0,0,0,0.45); margin-right: 8px;">{{ formatTime(item.createdAt) }}</span>
                  <span>{{ item.message }}</span>
                </a-list-item>
              </template>
            </a-list>
          </a-card>
        </div>
      </div>

      <div v-else class="analysis-container">
        <SplitLayout>
          <template #sidebar>
            <div class="sidebar-wrapper">
              <div class="sidebar-header">
                <span class="sidebar-title">内容目录</span>
                <a-tooltip title="标红章节包含废标项或高权重评分项">
                  <InfoCircleOutlined style="color: rgba(0,0,0,0.45)"/>
                </a-tooltip>
              </div>
              <div class="sidebar-tree">
                <a-tree
                  v-if="treeData.length"
                  :tree-data="treeData"
                  :selectedKeys="selectedKeys"
                  v-model:expandedKeys="expandedKeys"
                  :field-names="{ title: 'title', key: 'key', children: 'children' }"
                  @select="onSelectChapter"
                  block-node
                >
                  <template #title="{ title, data }">
                    <div class="tree-node-wrapper" :class="{ 'risk-high': data.riskLevel === 'high' }">
                      <component :is="data.icon" v-if="data.icon" class="node-icon"/>
                      <span class="node-title" :title="title">{{ title }}</span>
                      <span class="node-tags">
                        <a-tag v-if="data.scoreWeight" color="orange" class="node-tag">{{ data.scoreWeight }}分</a-tag>
                        <a-tag v-if="data.isVeto" color="red" class="node-tag">废标项</a-tag>
                      </span>
                    </div>
                  </template>
                </a-tree>
              </div>
            </div>
          </template>
          <template #main>
            <div class="main-wrapper">
              <div v-if="currentView === 'info'" class="info-view">
                <a-descriptions title="基本信息" bordered :column="2" size="middle">
                  <a-descriptions-item label="标书开始时间">{{ formatTime(tenderInfo.bidStartTime) }}</a-descriptions-item>
                  <a-descriptions-item label="标书截止时间">{{ formatTime(tenderInfo.bidEndTime) }}</a-descriptions-item>
                  <a-descriptions-item label="投标开始时间">{{ formatTime(tenderInfo.tenderStartTime) }}</a-descriptions-item>
                  <a-descriptions-item label="投标截止时间">
                    <span style="color: #cf1322; font-weight: bold">{{ formatTime(tenderInfo.deadline) }}</span>
                  </a-descriptions-item>
                  <a-descriptions-item label="开标时间">{{ formatTime(tenderInfo.openBidTime) }}</a-descriptions-item>
                  <a-descriptions-item label="招标代理">{{ tenderInfo.agencyName || '-' }}</a-descriptions-item>
                  <a-descriptions-item label="联系人">{{ tenderInfo.contactName || '-' }}</a-descriptions-item>
                  <a-descriptions-item label="联系电话">{{ tenderInfo.contactPhone || '-' }}</a-descriptions-item>
                </a-descriptions>
                
                <a-divider style="margin: 24px 0" />
                
                <a-descriptions title="核心指标" bordered :column="2" size="middle">
                  <a-descriptions-item label="投标保证金">{{ tenderInfo.bidBond || '-' }}</a-descriptions-item>
                  <a-descriptions-item label="项目预算/限价">{{ tenderInfo.budget || '-' }}</a-descriptions-item>
                  <a-descriptions-item label="核心资质要求">{{ tenderInfo.qualification || '-' }}</a-descriptions-item>
                </a-descriptions>
              </div>

              <div v-else-if="currentView === 'chapter' && currentChapter" class="chapter-view">
                <div class="chapter-header">
                  <span class="chapter-title">{{ currentChapter.title }}</span>
                  <a-tag v-if="currentChapter.type" color="blue" style="margin-left: 10px">{{ currentChapter.type }}</a-tag>
                </div>

                <a-alert
                  v-if="currentChapter.analysis"
                  message="智能解读"
                  :description="currentChapter.analysis"
                  type="info"
                  show-icon
                  style="margin-bottom: 24px"
                />

                <a-descriptions 
                  v-if="currentChapter.extraction && currentChapter.extraction.length"
                  title="核心要素提取" 
                  bordered 
                  :column="2" 
                  size="small" 
                  style="margin-bottom: 24px"
                >
                  <a-descriptions-item v-for="(item, index) in currentChapter.extraction" :key="index" :label="item.label" :span="item.fullWidth ? 2 : 1">
                    {{ item.value }}
                  </a-descriptions-item>
                </a-descriptions>
                
                <template v-if="currentChapter.content">
                  <a-divider orientation="left">原文条款片段</a-divider>
                  <div class="original-content">
                    <div v-html="currentChapter.content"></div>
                  </div>
                </template>
              </div>

              <div v-else-if="currentView === 'logs'" class="logs-view">
                <div class="logs-header">
                  <h3>智能分析日志</h3>
                </div>
                <a-list :data-source="logs" size="small">
                  <template #renderItem="{ item }">
                    <a-list-item>
                      <span style="color: rgba(0,0,0,0.45); margin-right: 8px;">{{ formatTime(item.createdAt) }}</span>
                      <span>{{ item.message }}</span>
                    </a-list-item>
                  </template>
                </a-list>
              </div>
              
              <div v-else class="empty-state">
                <a-empty description="请选择左侧章节查看详情" />
              </div>
            </div>
          </template>
        </SplitLayout>
      </div>
    </a-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch, onBeforeUnmount, computed } from 'vue';
import { useRoute } from 'vue-router';
import { UploadOutlined, InfoCircleOutlined, PaperClipOutlined, MoreOutlined, FileTextOutlined } from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import request from '@/utils/request';
import { getKkViewUrl } from '@/utils/kkview';
import SplitLayout from '@/components/SplitLayout/index.vue';

const props = defineProps<{
  projectType?: string;
}>();

const route = useRoute();
const bidProjectId = route.params.id as string;

const analyzing = ref(false);
const rawChapters = ref<any[]>([]);
const currentChapter = ref<any>(null);
const tenderInfo = ref<any>({});
const fileInfo = ref<{ name: string, url: string } | null>(null);
const logs = ref<Array<{ id: number; runId: number; message: string; createdAt: string }>>([]);
const selectedKeys = ref<(string | number)[]>(['tender_info']);
const expandedKeys = ref<(string | number)[]>([]);
const currentRunId = ref<number | null>(null);
let logStreamAbort: AbortController | null = null;

const treeData = computed(() => {
   const nodes = [
     { key: 'tender_info', title: '招标信息', isLeaf: true, icon: FileTextOutlined },
     ...rawChapters.value,
     { key: 'analysis_logs', title: '智能分析日志', isLeaf: true, icon: FileTextOutlined }
   ];
   return nodes;
 });

// 默认展开两级目录
watch(treeData, (nodes) => {
  if (nodes && nodes.length > 0) {
    const keys: (string | number)[] = [];
    nodes.forEach(node => {
      // Level 1
      if (node.children && node.children.length > 0) {
        keys.push(node.key);
        // Level 2
        node.children.forEach((child: any) => {
          if (child.children && child.children.length > 0) {
            keys.push(child.key);
          }
        });
      }
    });
    if (keys.length > 0) {
      expandedKeys.value = [...new Set(keys)];
    }
  }
}, { immediate: true });

const currentView = computed(() => {
  if (selectedKeys.value[0] === 'tender_info') return 'info';
  if (selectedKeys.value[0] === 'analysis_logs') return 'logs';
  return 'chapter';
});


const formatTime = (iso: string) => {
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return iso;
  return d.toLocaleString();
};

const getToken = () => {
  try {
    const authData = JSON.parse(localStorage.getItem('oms.auth') || '{}');
    return authData.token as string | undefined;
  } catch {
    return undefined;
  }
};

const applyAnalysisDto = (dto: any) => {
  if (dto?.fileName && dto?.fileUrl) {
    fileInfo.value = { name: dto.fileName, url: dto.fileUrl };
  } else {
    fileInfo.value = null;
  }

  tenderInfo.value = {
    deadline: dto?.deadline,
    bidBond: dto?.bidBond,
    budget: dto?.budget,
    qualification: dto?.qualification,
    bidStartTime: dto?.bidStartTime,
    bidEndTime: dto?.bidEndTime,
    tenderStartTime: dto?.tenderStartTime,
    openBidTime: dto?.openBidTime,
    contactName: dto?.contactName,
    contactPhone: dto?.contactPhone,
    agencyName: dto?.agencyName
  };

  rawChapters.value = Array.isArray(dto?.chapters) ? dto.chapters : [];
  currentChapter.value = null;
};

const loadAnalysis = async () => {
  try {
    const dto = await request.get(`/sales/tender-analysis/${bidProjectId}`);
    applyAnalysisDto(dto);
  } catch {
    rawChapters.value = [];
    tenderInfo.value = {};
    currentChapter.value = null;
  }
};

const loadStatus = async () => {
  const status: any = await request.get(`/sales/tender-analysis/${bidProjectId}/status`);
  analyzing.value = !!status?.isAnalyzing;
  currentRunId.value = status?.runId ?? null;
  return status;
};

const loadLogs = async (runId?: number | null) => {
  if (!runId) {
    logs.value = [];
    return;
  }

  const pageSize = 500;
  const all: any[] = [];
  let afterId: number | undefined;

  while (true) {
    const params: any = { runId, take: pageSize };
    if (afterId != null) params.afterId = afterId;

    const items = await request.get(`/sales/tender-analysis/${bidProjectId}/logs`, { params });
    const list = Array.isArray(items) ? items : [];
    if (!list.length) break;

    all.push(...list);
    afterId = list[list.length - 1]?.id;

    if (list.length < pageSize) break;
  }

  logs.value = all;
};

const startLogStream = async (runId: number) => {
  if (logStreamAbort) logStreamAbort.abort();
  logStreamAbort = new AbortController();

  try {
    const token = getToken();
    const res = await fetch(`/api/sales/tender-analysis/${bidProjectId}/logs/stream?runId=${runId}`, {
      method: 'GET',
      headers: token ? { Authorization: `Bearer ${token}` } : undefined,
      signal: logStreamAbort.signal
    });

    if (!res.ok || !res.body) return;

    const reader = res.body.getReader();
    const decoder = new TextDecoder('utf-8');
    let buffer = '';

    const pushEventBlock = (block: string) => {
      const lines = block.split('\n').filter(Boolean);
      let eventName = 'message';
      let dataText = '';
      for (const line of lines) {
        if (line.startsWith('event:')) {
          eventName = line.slice(6).trim();
        } else if (line.startsWith('data:')) {
          dataText += line.slice(5).trim();
        }
      }
      if (eventName === 'done' || eventName === 'completed') {
        analyzing.value = false;
        selectedKeys.value = ['tender_info'];
        void loadAnalysis();
        return;
      }
      if (!dataText) return;
      try {
        const item = JSON.parse(dataText);
        if (item?.id && !logs.value.some(x => x.id === item.id)) {
          logs.value.push(item);
        }
      } catch {
      }
    };

    while (true) {
      const { value, done } = await reader.read();
      if (done) break;
      buffer += decoder.decode(value, { stream: true });
      const parts = buffer.split('\n\n');
      buffer = parts.pop() || '';
      for (const p of parts) {
        pushEventBlock(p);
      }
    }
    
    // Stream ended, check status to be sure
    const finalStatus = await loadStatus();
    if (!finalStatus?.isAnalyzing && analyzing.value) {
      analyzing.value = false;
      selectedKeys.value = ['tender_info'];
      void loadAnalysis();
    }
  } catch (err: any) {
    if (err.name !== 'AbortError') {
      console.error('Log stream error:', err);
    }
  }
};

const startOrResume = async () => {
  const status = await loadStatus();
  if (status?.runId) {
    await loadLogs(status.runId);
    if (status.isAnalyzing) {
      selectedKeys.value = ['analysis_logs'];
      void startLogStream(status.runId);
    }
  }

  if (!status?.isAnalyzing) {
    await loadAnalysis();
  }
};

const customRequest = async (options: any) => {
  const { file, onSuccess, onError } = options;
  analyzing.value = true;
  selectedKeys.value = ['analysis_logs'];
  logs.value = [];
  try {
    const formData = new FormData();
    formData.append('file', file);
    
    // Call dedicated upload endpoint
    const res: any = await request.post(`/sales/tender-analysis/${bidProjectId}/upload`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    });

    if (res?.fileName && res?.fileUrl) {
      fileInfo.value = { name: res.fileName, url: res.fileUrl };
    } else {
      fileInfo.value = { name: file.name, url: `/api/sales/tender-analysis/${bidProjectId}/download` };
    }
    
    onSuccess(res);

    const status = await loadStatus();
    if (status?.runId) {
      await loadLogs(status.runId);
      if (status.isAnalyzing) {
        void startLogStream(status.runId);
      } else {
        analyzing.value = false;
        selectedKeys.value = ['tender_info'];
        await loadAnalysis();
      }
    }

    message.success('已开始分析招标文件');
  } catch (err) {
    onError(err);
    analyzing.value = false;
    message.error('上传失败');
  }
};

const handleReanalyze = async () => {
  try {
    analyzing.value = true;
    selectedKeys.value = ['analysis_logs'];
    logs.value = [];
    const status: any = await request.post(`/sales/tender-analysis/${bidProjectId}/reanalyze`, {});
    if (status?.runId) {
      await loadLogs(status.runId);
      void startLogStream(status.runId);
    }
    message.success('已开始重新分析');
  } catch {
    analyzing.value = false;
    message.error('重新分析失败');
  }
};

const handleCancelAnalysis = async () => {
  try {
    await request.post(`/sales/tender-analysis/${bidProjectId}/cancel`);
    message.success('已取消分析任务');
    if (logStreamAbort) {
      logStreamAbort.abort();
      logStreamAbort = null;
    }
    analyzing.value = false;
    loadAnalysis();
  } catch (err) {
    message.error('取消失败');
  }
};

const handleDownload = () => {
  if (fileInfo.value?.url) {
    // Check if URL is absolute or relative
    if (fileInfo.value.url.startsWith('http')) {
        window.open(fileInfo.value.url, '_blank');
    } else {
        // Prepend origin for API call or just open it (browser handles relative)
        // If it is an API call returning a stream, window.open works if it is GET
        // Ideally use a download utility that handles auth, but for window.open we might need query param auth if strict
        // For now assume cookie or standard open
        window.open(fileInfo.value.url, '_blank');
    }
  }
};

const handlePreview = () => {
  if (fileInfo.value?.url && fileInfo.value?.name) {
    const previewUrl = getKkViewUrl(fileInfo.value.url, fileInfo.value.name);
    window.open(previewUrl, '_blank');
  }
};

const onSelectChapter = (keys: (string | number)[], info: any) => {
  selectedKeys.value = keys;
  if (info.selected && info.node) {
    if (keys[0] === 'tender_info' || keys[0] === 'analysis_logs') {
      currentChapter.value = null;
    } else {
      currentChapter.value = info.node.dataRef || info.node;
    }
  }
};

onMounted(() => {
  void startOrResume();
});

watch(() => props.projectType, () => {
  void loadAnalysis();
});

onBeforeUnmount(() => {
  if (logStreamAbort) logStreamAbort.abort();
});
</script>

<style scoped>
.tender-analysis {
  height: 100%;
  overflow: hidden;
}
.analyzing-state {
  height: 100%;
  overflow-y: auto;
  text-align: center;
  padding: 40px;
  box-sizing: border-box;
}
.analysis-container {
  height: 100%;
}

/* Sidebar Styles */
.sidebar-wrapper {
  height: 100%;
  display: flex;
  flex-direction: column;
  background: #fff;
  overflow: hidden;
}
.sidebar-header {
  padding: 12px 16px;
  border-bottom: 1px solid #f0f0f0;
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-shrink: 0;
}
.sidebar-title {
  font-weight: 500;
  color: rgba(0, 0, 0, 0.85);
}
.sidebar-tree {
  flex: 1;
  overflow-x: hidden;
  overflow-y: auto;
  padding: 8px 0;
  min-height: 0;
}

/* Main Content Styles */
.main-wrapper {
  height: 100%;
  overflow-y: auto;
  padding: 24px;
  background: #fff;
  box-sizing: border-box;
}
.info-view {
  max-width: 1200px;
  margin: 0 auto;
}
.chapter-view {
  max-width: 1200px;
  margin: 0 auto;
}
.chapter-header {
  margin-bottom: 24px;
  display: flex;
  align-items: center;
}
.chapter-title {
  font-size: 20px;
  font-weight: 500;
  color: rgba(0, 0, 0, 0.85);
}
.logs-view {
  max-width: 1000px;
  margin: 0 auto;
}
.logs-header {
  margin-bottom: 16px;
  padding-bottom: 16px;
  border-bottom: 1px solid #f0f0f0;
}
.original-content {
  background-color: #f9f9f9;
  padding: 15px;
  border: 1px solid #e8e8e8;
  border-radius: 4px;
  min-height: 200px;
}
.empty-state {
  height: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
  color: #999;
}
.risk-high {
  color: #cf1322;
  font-weight: 500;
}

/* Tree Node Styles */
.tree-node-wrapper {
  display: flex;
  align-items: center;
  width: 100%;
  overflow: hidden;
}
.node-icon {
  margin-right: 5px;
  flex-shrink: 0;
}
.node-title {
  flex: 1;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.node-tags {
  flex-shrink: 0;
  display: flex;
  align-items: center;
}
.node-tag {
  margin-left: 5px;
  margin-right: 0;
}
</style>
