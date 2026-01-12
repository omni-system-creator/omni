<template>
  <div class="widget-card announcement-card">
    <div class="card-header">
      <h3>
        <DynamicIcon icon="ant-design:sound-outlined" style="margin-right: 8px; color: #faad14;" />
        系统公告
      </h3>
      <div style="display: flex; align-items: center;">
        <a-button 
          v-if="hasPermission('integrated:anonce')" 
          type="link" 
          size="small" 
          @click="router.push('/integrated/anonce')"
          style="display: flex; align-items: center;"
        >
          更多 <DoubleRightOutlined style="font-size: 10px; margin-left: 2px;" />
        </a-button>
      </div>
    </div>
    <div class="announcement-content" v-if="latestAnonce">
      <div class="main-notice" @click="handleDetail(latestAnonce.id)" style="cursor: pointer;">
        <h4>{{ latestAnonce.title }}</h4>
        <p class="notice-meta">
          发布时间：{{ dayjs(latestAnonce.publishTime).format('YYYY-MM-DD HH:mm') }} &nbsp;|&nbsp; 
          <a-tag v-if="latestAnonce.priority" :color="getPriorityColor(latestAnonce.priority)" style="margin-left: 8px; margin-right: 0;">
            {{ getPriorityName(latestAnonce.priority) }}
          </a-tag>
        </p>
        <p class="notice-desc">
          {{ latestAnonce.content ? (latestAnonce.content.length > 100 ? latestAnonce.content.substring(0, 100) + '...' : latestAnonce.content) : '暂无内容' }}
        </p>
      </div>
      <div class="other-notices">
        <div 
          v-for="item in otherAnonces" 
          :key="item.id" 
          class="notice-item"
          @click="handleDetail(item.id)"
          style="cursor: pointer;"
        >
          <span class="dot"></span>
          <span class="text" :title="item.title">{{ item.title }}</span>
          <span class="date">{{ dayjs(item.publishTime).format('MM-DD') }}</span>
        </div>
        <div v-if="otherAnonces.length === 0" class="no-data">
          暂无更多公告
        </div>
      </div>
    </div>
    <div class="announcement-content empty" v-else>
      <a-empty description="暂无公告" />
    </div>

    <!-- Detail Modal -->
    <a-modal
      v-model:open="detailVisible"
      :footer="null"
      :title="null"
      width="900px"
      :body-style="{ padding: '0' }"
      :wrap-class-name="wrapClassName"
      :modal-render="(args: any) => args.originVNode"
    >
      <div class="anonce-detail">
        <div 
          class="anonce-header" 
          @mousedown="handleTitleMouseDown"
        >
          <h2 class="anonce-title">{{ detailData?.title }}</h2>
          <div class="anonce-meta">
            <a-space size="middle" wrap>
              <a-tag color="blue" v-if="detailData?.type">{{ getTypeName(detailData.type) }}</a-tag>
              <a-tag v-if="detailData?.priority" :color="getPriorityColor(detailData.priority)">
                {{ getPriorityName(detailData.priority) }}
              </a-tag>
              <span class="meta-item">
                <a-badge 
                  v-if="detailData?.status"
                  :status="getStatusColor(detailData.status) as any" 
                  :text="getStatusText(detailData.status)" 
                />
              </span>
              <span class="meta-text" v-if="detailData?.publishTime">
                发布时间：{{ dayjs(detailData.publishTime).format('YYYY-MM-DD HH:mm') }}
              </span>
              <span class="meta-text" v-if="detailData?.createdAt">
                创建时间：{{ dayjs(detailData.createdAt).format('YYYY-MM-DD HH:mm') }}
              </span>
            </a-space>
          </div>
        </div>
        <a-divider style="margin: 0" />
        <div class="anonce-content">
          {{ detailData?.content }}
        </div>
      </div>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import DynamicIcon from '@/components/DynamicIcon.vue';
import { DoubleRightOutlined } from '@ant-design/icons-vue';
import { getAnonceList, getAnonce } from '@/api/anonce';
import type { AnonceDto } from '@/api/anonce';
import dayjs from 'dayjs';
import { getDictDataByCode } from '@/api/dict';
import { usePermissionStore } from '@/stores/permission';
import { useRouter } from 'vue-router';
import { useDraggableModal } from '@/hooks/useDraggableModal';

const permissionStore = usePermissionStore();
const router = useRouter();

// --- Data ---
const latestAnonce = ref<AnonceDto | null>(null);
const otherAnonces = ref<AnonceDto[]>([]);
const anonceTypes = ref<any[]>([]);
const priorityTypes = ref<any[]>([]);

// --- Detail Modal Data ---
const detailVisible = ref(false);
const detailData = ref<AnonceDto | null>(null);

// --- Modal Drag Logic ---
const { wrapClassName, handleTitleMouseDown } = useDraggableModal(detailVisible);

// --- Helpers ---
const hasPermission = (permission: string) => {
  return permissionStore.hasPermission(permission);
};

const getTypeName = (value: string | undefined) => {
  if (!value) return '-';
  const found = anonceTypes.value.find((item: any) => item.value === value);
  return found ? found.label : value;
};

const getPriorityName = (value: string | undefined) => {
  if (!value) return '-';
  const found = priorityTypes.value.find((item: any) => item.value === value);
  return found ? found.label : value;
};

const getPriorityColor = (value: string | undefined) => {
  if (!value) return 'default';
  const map: Record<string, string> = {
    high: 'red',
    medium: 'orange',
    normal: 'blue',
    low: 'default'
  };
  return map[value] || 'default';
};

const getStatusText = (status: string | undefined) => {
  const map: Record<string, string> = {
    draft: '草稿',
    published: '已发布',
    revoked: '已撤回'
  };
  return status ? map[status] || status : '-';
};

const getStatusColor = (status: string | undefined) => {
  const map: Record<string, string> = {
    draft: 'default',
    published: 'success',
    revoked: 'warning'
  };
  return status ? map[status] || 'default' : 'default';
};

// --- Actions ---
const handleDetail = async (id: number) => {
  try {
    const res = await getAnonce(id);
    detailData.value = res;
    detailVisible.value = true;
  } catch (error) {
    console.error('Failed to get anonce detail', error);
  }
};

const loadDicts = async () => {
  try {
    const [anonceTypeRes, priorityRes] = await Promise.all([
      getDictDataByCode('anonce_type'),
      getDictDataByCode('priority')
    ]);
    anonceTypes.value = anonceTypeRes || [];
    priorityTypes.value = priorityRes || [];
  } catch (error) {
    console.error('Failed to load dicts', error);
  }
};

const loadData = async () => {
  try {
    // Get published announcements, sort by publish time desc
    const res = await getAnonceList({ 
      page: 1, 
      pageSize: 4, 
      status: 'published'
    } as any);
    
    if (res.items && res.items.length > 0) {
      // Need to fetch detail for the first item to get content if list doesn't return it
      // Based on previous context, list api excludes content. 
      // So we fetch detail for the main notice.
      const firstItem = res.items[0];
      if (firstItem) {
        try {
           const detail = await getAnonce(firstItem.id);
           latestAnonce.value = detail;
        } catch {
           latestAnonce.value = firstItem as AnonceDto; // Fallback
        }
        
        otherAnonces.value = res.items.slice(1);
      } else {
        latestAnonce.value = null;
        otherAnonces.value = [];
      }
    } else {
      latestAnonce.value = null;
      otherAnonces.value = [];
    }
  } catch (error) {
    console.error('Failed to load announcements', error);
  }
};

onMounted(() => {
  loadDicts();
  loadData();
});
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
.announcement-content.empty {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100%;
}
.anonce-detail {
  display: flex;
  flex-direction: column;
}

.anonce-header {
  padding: 24px 32px 16px;
  text-align: center;
  background-color: #fcfcfc;
  cursor: move;
  user-select: none;
}

.anonce-title {
  font-size: 24px;
  font-weight: 600;
  color: #1f1f1f;
  margin-bottom: 16px;
  line-height: 1.4;
}

.anonce-meta {
  color: #8c8c8c;
  font-size: 13px;
}

.meta-text {
  color: #8c8c8c;
}

.anonce-content {
  padding: 32px;
  font-size: 16px;
  line-height: 1.8;
  color: #262626;
  white-space: pre-wrap;
  min-height: 200px;
  max-height: 60vh;
  overflow-y: auto;
  background-color: #fff;
}
.no-data {
  text-align: center;
  color: #999;
  font-size: 13px;
  margin-top: 10px;
}
</style>

<style>
.anonce-detail-modal .ant-modal-content {
  padding: 0 !important;
  overflow: hidden;
}
.anonce-detail-modal .ant-modal-header {
  display: none;
}
</style>
