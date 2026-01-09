<template>
  <div class="online-users-container">
    <a-tooltip title="在线用户">
      <div class="action-btn" @click="showDrawer">
        <a-badge :count="onlineCount" :offset="[-5, 5]" size="small">
          <TeamOutlined class="icon" />
        </a-badge>
      </div>
    </a-tooltip>

    <a-drawer
      v-model:open="visible"
      title="在线用户列表"
      placement="right"
      :width="900"
      :closable="true"
      :bodyStyle="{ padding: '0', display: 'flex', flexDirection: 'column', height: '100%', overflow: 'hidden' }"
    >
      <div class="drawer-content">
        <div class="table-wrapper">
          <a-table
            :data-source="paginatedUsers"
            :columns="columns"
            :loading="loading"
            :pagination="false"
            :scroll="{ y: 'calc(100vh - 210px)' }"
            row-key="connectionId"
            size="middle"
          >
            <template #bodyCell="{ column, record, index }">
              <template v-if="column.key === 'index'">
                {{ (pagination.current - 1) * pagination.pageSize + index + 1 }}
              </template>
              <template v-if="column.key === 'user'">
                <div style="display: flex; align-items: center;">
                  <a-avatar v-if="record.avatar" :src="record.avatar" :style="{ marginRight: '8px' }" />
                  <a-avatar v-else :style="{ backgroundColor: getAvatarColor(record.userName), marginRight: '8px' }">
                    {{ (record.nickname || record.userName).charAt(0).toUpperCase() }}
                  </a-avatar>
                  <span>{{ record.nickname || record.userName }}</span>
                  <a-tag v-if="record.connectionId === myConnectionId" color="blue" style="margin-left: 8px; font-size: 10px;">当前</a-tag>
                  <a-tag v-else-if="String(record.userId) === String(userStore.id)" color="cyan" style="margin-left: 8px; font-size: 10px;">我的其他设备</a-tag>
                </div>
              </template>
              <template v-if="column.key === 'loginTime'">
                {{ formatTime(record.loginTime) }}
              </template>
              <template v-if="column.key === 'action'">
                <a-button type="link" size="small" @click="startChat(record as any)">
                  <MessageOutlined /> 发消息
                </a-button>
              </template>
            </template>
          </a-table>
        </div>
        <div class="pagination-wrapper">
          <a-pagination
            v-model:current="pagination.current"
            v-model:pageSize="pagination.pageSize"
            :total="uniqueUsers.length"
            :show-total="(total: number) => `共 ${total} 条`"
            show-size-changer
            show-quick-jumper
            @change="handlePageChange"
          />
        </div>
      </div>
    </a-drawer>
  </div>
</template>

<script lang="ts" setup>
import { ref, reactive, onMounted, onUnmounted, computed, watch } from 'vue';
import { TeamOutlined, MessageOutlined } from '@ant-design/icons-vue';
import { HubConnectionBuilder, HubConnection } from '@microsoft/signalr';
import { useRouter } from 'vue-router';
import { useUserStore } from '@/stores/user';
import dayjs from 'dayjs';

interface OnlineUser {
  connectionId: string;
  userId?: string;
  userName: string;
  nickname?: string;
  avatar?: string;
  loginTime: string;
  ipAddress?: string;
  currentOrgId?: number;
}

const router = useRouter();
const userStore = useUserStore();
const visible = ref(false);
const loading = ref(false);
const allConnections = ref<OnlineUser[]>([]);
const connection = ref<HubConnection | null>(null);
const myConnectionId = ref<string>('');

const uniqueUsers = computed(() => {
  const map = new Map<string, OnlineUser>();
  const currentOrgId = userStore.currentOrg?.id;

  allConnections.value.forEach(conn => {
    // Filter by Organization
    if (currentOrgId !== undefined && conn.currentOrgId !== currentOrgId) {
      return;
    }

    // Group by userId if available, otherwise userName
    const key = conn.userId || conn.userName;
    const existing = map.get(key);
    
    if (!existing) {
      map.set(key, { ...conn });
    } else {
      // Prioritize the current connection if duplicate found
      if (conn.connectionId === myConnectionId.value) {
        map.set(key, { ...conn });
      }
    }
  });
  return Array.from(map.values());
});

// Watch for organization changes
watch(() => userStore.currentOrg, (newOrg) => {
  if (newOrg && connection.value?.state === 'Connected') {
    connection.value.invoke('SwitchOrganization', newOrg.id).catch(err => {
      console.error('Failed to switch organization in Hub', err);
    });
  }
}, { deep: true });

const onlineCount = computed(() => uniqueUsers.value.length);

const pagination = reactive({
  current: 1,
  pageSize: 10
});

const paginatedUsers = computed(() => {
  const start = (pagination.current - 1) * pagination.pageSize;
  const end = start + pagination.pageSize;
  return uniqueUsers.value.slice(start, end);
});

const handlePageChange = (page: number, pageSize: number) => {
  pagination.current = page;
  pagination.pageSize = pageSize;
};

const columns = [
  {
    title: '序号',
    key: 'index',
    width: 70,
    align: 'center',
  },
  {
    title: '用户',
    key: 'user',
  },
  {
    title: '登录时间',
    key: 'loginTime',
    width: 150,
  },
  {
    title: 'IP地址',
    dataIndex: 'ipAddress',
    key: 'ipAddress',
    width: 140,
  },
  {
    title: '操作',
    key: 'action',
    width: 120,
    align: 'center',
  },
] as any[];

const showDrawer = () => {
  visible.value = true;
  // If not connected (should be connected on mount, but retry if needed)
  if (connection.value?.state !== 'Connected') {
    connectSignalR();
  } else {
    // Refresh list manually if needed, though events should handle it
    fetchOnlineUsers();
  }
};

const getAvatarColor = (name: string) => {
  const colors = ['#f56a00', '#7265e6', '#ffbf00', '#00a2ae', '#1890ff', '#52c41a'];
  let hash = 0;
  for (let i = 0; i < name.length; i++) {
    hash = name.charCodeAt(i) + ((hash << 5) - hash);
  }
  return colors[Math.abs(hash) % colors.length];
};

const formatTime = (time: string) => {
  return dayjs(time).format('YYYY-MM-DD HH:mm:ss');
};

const startChat = (user: OnlineUser) => {
  visible.value = false;
  // Navigate to messages with query params to open chat
  // Note: userId might be null if not authenticated, but we assume authenticated for this system
  // If same user has multiple connections, we just pick the userId
  router.push({
    path: '/personal/messages',
    query: {
      chatWith: user.userId,
      myUserId: String(userStore.id),
      userName: user.nickname || user.userName,
      type: 'private'
    }
  });
};

const fetchOnlineUsers = async () => {
  if (connection.value?.state === 'Connected') {
    try {
      loading.value = true;
      const users = await connection.value.invoke<OnlineUser[]>('GetOnlineUsers');
      // Show all users including self (all connections)
      allConnections.value = users;
    } catch (err) {
      console.error('Failed to get online users', err);
    } finally {
      loading.value = false;
    }
  }
};

const connectSignalR = async () => {
  if (connection.value) return;

  const token = userStore.token;
  connection.value = new HubConnectionBuilder()
    .withUrl('/hubs/user', {
      accessTokenFactory: () => token || ''
    })
    .withAutomaticReconnect()
    .build();

  connection.value.on('UserConnected', (user: OnlineUser) => {
    // Check if already in list
    const index = allConnections.value.findIndex(u => u.connectionId === user.connectionId);
    if (index === -1) {
      allConnections.value.push(user);
    }
  });

  connection.value.on('UserDisconnected', (connectionId: string) => {
    allConnections.value = allConnections.value.filter(u => u.connectionId !== connectionId);
  });

  connection.value.on('UserUpdated', (user: OnlineUser) => {
    const index = allConnections.value.findIndex(u => u.connectionId === user.connectionId);
    if (index !== -1) {
      allConnections.value[index] = user;
    } else {
      allConnections.value.push(user);
    }
  });

  try {
    await connection.value.start();
    myConnectionId.value = connection.value.connectionId || '';
    console.log('User Hub Connected');
    fetchOnlineUsers();
  } catch (err) {
    console.error('User Hub Connection Failed', err);
  }
};

onMounted(() => {
  connectSignalR();
});

onUnmounted(() => {
  if (connection.value) {
    connection.value.stop();
  }
});
</script>

<style scoped>
.online-users-container {
  display: flex;
  align-items: center;
}

.action-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  cursor: pointer;
  transition: all 0.3s;
  color: rgba(0, 0, 0, 0.65);
}

.action-btn:hover {
  background: rgba(0, 0, 0, 0.025);
  color: #1890ff;
}

.icon {
  font-size: 18px;
}

.user-desc {
  font-size: 12px;
  color: #999;
}

.ip-address {
  font-size: 10px;
  color: #ccc;
}

.drawer-content {
  display: flex;
  flex-direction: column;
  height: 100%;
  padding: 10px;
}

.table-wrapper {
  flex: 1;
  overflow: hidden;
  margin-bottom: 16px;
}

.pagination-wrapper {
  display: flex;
  justify-content: flex-end;
  padding-top: 16px;
  border-top: 1px solid #f0f0f0;
}

.table-wrapper :deep(.ant-table-body) {
  overflow-y: auto !important;
}
</style>