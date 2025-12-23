<template>
  <div class="contacts-container">
    <div class="fixed-header">
      <van-nav-bar
        title="通讯录"
        left-text="返回"
        left-arrow
        @click-left="onClickLeft"
      />
      <van-search
        v-model="searchText"
        placeholder="搜索姓名/部门/手机号"
        shape="round"
        background="#fff"
      />
      <div class="breadcrumb" v-if="breadcrumbs.length > 1">
        <span 
          v-for="(item, index) in breadcrumbs" 
          :key="item.id"
          class="breadcrumb-item"
          :class="{ active: index === breadcrumbs.length - 1 }"
          @click="navigateToBreadcrumb(index)"
        >
          {{ item.name }}
          <van-icon name="arrow" v-if="index < breadcrumbs.length - 1" class="separator" />
        </span>
      </div>
    </div>

    <div class="contacts-content" :class="{ 'has-breadcrumb': breadcrumbs.length > 1 }">
      <!-- Loading State -->
      <van-loading v-if="loading" class="loading-state" vertical>加载中...</van-loading>

      <template v-else>
        <!-- Department List -->
        <div class="group-title" v-if="currentDepartments.length > 0">部门</div>
        <van-cell-group inset class="dept-group" v-if="currentDepartments.length > 0">
          <van-cell 
            v-for="dept in currentDepartments" 
            :key="dept.id" 
            :title="dept.name" 
            is-link 
            center
            @click="enterDepartment(dept)"
          >
            <template #icon>
              <div class="dept-icon">
                <van-icon name="cluster" />
              </div>
            </template>
            <template #value>
              <span class="member-count">{{ dept.memberCount }}人</span>
            </template>
          </van-cell>
        </van-cell-group>

        <!-- Member List -->
        <div class="group-title" v-if="currentMembers.length > 0">成员 ({{ currentMembers.length }})</div>
        <div class="member-list" v-if="currentMembers.length > 0">
          <div 
            class="member-card" 
            v-for="member in currentMembers" 
            :key="member.id"
            @click="showMemberDetail(member)"
          >
            <van-image
              round
              width="40px"
              height="40px"
              :src="member.avatar || 'https://fastly.jsdelivr.net/npm/@vant/assets/cat.jpeg'"
              class="avatar"
            />
            <div class="member-info">
              <div class="name-row">
                <span class="name">{{ member.name }}</span>
                <van-tag type="primary" plain v-if="member.isLeader">负责人</van-tag>
              </div>
              <div class="position">{{ member.position }}</div>
            </div>
            <div class="actions">
              <van-button circle size="small" icon="phone-o" type="success" plain @click.stop="onCall(member)" />
              <van-button circle size="small" icon="chat-o" type="primary" plain @click.stop="onMessage(member)" class="ml-2" />
            </div>
          </div>
        </div>

        <van-empty v-if="currentDepartments.length === 0 && currentMembers.length === 0" description="暂无数据" />
      </template>
    </div>

    <!-- Member Detail Popup -->
    <van-popup
      v-model:show="showDetail"
      position="bottom"
      round
      closeable
      :style="{ height: '60%' }"
    >
      <div class="detail-popup">
        <div class="detail-header">
          <van-image
            round
            width="80px"
            height="80px"
            :src="selectedMember?.avatar || 'https://fastly.jsdelivr.net/npm/@vant/assets/cat.jpeg'"
          />
          <h2 class="detail-name">{{ selectedMember?.name }}</h2>
          <p class="detail-position">{{ selectedMember?.deptName }} | {{ selectedMember?.position }}</p>
        </div>
        
        <van-cell-group class="detail-info">
          <van-cell title="手机号码" :value="selectedMember?.phone" is-link @click="onCall(selectedMember)">
            <template #right-icon>
              <van-icon name="phone-o" class="action-icon phone" />
            </template>
          </van-cell>
          <van-cell title="电子邮箱" :value="selectedMember?.email" is-link>
            <template #right-icon>
              <van-icon name="envelop-o" class="action-icon email" />
            </template>
          </van-cell>
          <van-cell title="办公地点" :value="selectedMember?.location" />
        </van-cell-group>

        <div class="detail-actions">
          <van-button type="primary" block round icon="chat-o" @click="onMessage(selectedMember)">发消息</van-button>
          <van-button type="success" block round icon="phone-o" class="mt-3" @click="onCall(selectedMember)">打电话</van-button>
        </div>
      </div>
    </van-popup>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import { useRouter } from 'vue-router';
import { showToast } from 'vant';

const router = useRouter();
const searchText = ref('');
const loading = ref(false);
const showDetail = ref(false);
const selectedMember = ref<any>(null);

// Mock Data
const mockData = {
  root: {
    id: 'root',
    name: '组织架构',
    departments: [
      { id: 'd1', name: '总经办', memberCount: 3 },
      { id: 'd2', name: '研发中心', memberCount: 45 },
      { id: 'd3', name: '市场部', memberCount: 12 },
      { id: 'd4', name: '人力资源部', memberCount: 5 },
      { id: 'd5', name: '财务部', memberCount: 4 },
    ],
    members: []
  },
  d2: {
    id: 'd2',
    name: '研发中心',
    departments: [
      { id: 'd2-1', name: '前端组', memberCount: 15 },
      { id: 'd2-2', name: '后端组', memberCount: 20 },
      { id: 'd2-3', name: 'UI设计组', memberCount: 5 },
      { id: 'd2-4', name: '测试组', memberCount: 5 },
    ],
    members: [
      { id: 'm1', name: '张总监', position: '技术总监', isLeader: true, phone: '13800138000', email: 'zhang@oms.com', location: '10楼 1001', deptName: '研发中心' }
    ]
  },
  'd2-1': {
    id: 'd2-1',
    name: '前端组',
    departments: [],
    members: [
      { id: 'm2', name: '王组长', position: '前端架构师', isLeader: true, phone: '13800138001', email: 'wang@oms.com', location: '10楼 1002', deptName: '研发中心-前端组' },
      { id: 'm3', name: '李开发', position: '高级前端工程师', isLeader: false, phone: '13800138002', email: 'li@oms.com', location: '10楼 1003', deptName: '研发中心-前端组' },
      { id: 'm4', name: '赵开发', position: '前端工程师', isLeader: false, phone: '13800138003', email: 'zhao@oms.com', location: '10楼 1003', deptName: '研发中心-前端组' },
      { id: 'm5', name: '孙实习', position: '前端实习生', isLeader: false, phone: '13800138004', email: 'sun@oms.com', location: '10楼 1003', deptName: '研发中心-前端组' },
    ]
  }
};

interface Breadcrumb {
  id: string;
  name: string;
}

const breadcrumbs = ref<Breadcrumb[]>([
  { id: 'root', name: '联系人' }
]);

const currentId = ref('root');

const currentDepartments = computed(() => {
  // @ts-ignore
  const data = mockData[currentId.value] || { departments: [] };
  if (searchText.value) {
    return []; // Simple search implementation can be added later
  }
  return data.departments;
});

const currentMembers = computed(() => {
  // @ts-ignore
  const data = mockData[currentId.value] || { members: [] };
  if (searchText.value) {
    // Mock search
    const allMembers = [
       ...mockData['d2'].members,
       ...mockData['d2-1'].members
    ];
    return allMembers.filter((m: any) => m.name.includes(searchText.value) || m.phone.includes(searchText.value));
  }
  return data.members;
});

const onClickLeft = () => {
  router.back();
};

const enterDepartment = (dept: any) => {
  breadcrumbs.value.push({ id: dept.id, name: dept.name });
  currentId.value = dept.id;
};

const navigateToBreadcrumb = (index: number) => {
  if (index === breadcrumbs.value.length - 1) return;
  const target = breadcrumbs.value[index];
  if (target) {
    breadcrumbs.value = breadcrumbs.value.slice(0, index + 1);
    currentId.value = target.id;
  }
};

const showMemberDetail = (member: any) => {
  selectedMember.value = member;
  showDetail.value = true;
};

const onCall = (member: any) => {
  if (!member) return;
  window.location.href = `tel:${member.phone}`;
};

const onMessage = (member: any) => {
  showToast(`正在打开与 ${member?.name} 的会话`);
};
</script>

<style scoped>
.contacts-container {
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
  box-shadow: 0 2px 8px rgba(0,0,0,0.02);
}

.breadcrumb {
  padding: 0 16px 12px;
  font-size: 14px;
  color: #666;
  white-space: nowrap;
  overflow-x: auto;
  display: flex;
  align-items: center;
}

.breadcrumb-item {
  display: flex;
  align-items: center;
}

.breadcrumb-item.active {
  color: #1989fa;
  font-weight: 500;
}

.separator {
  margin: 0 4px;
  color: #999;
  font-size: 12px;
}

.contacts-content {
  padding-top: 100px; /* nav(46) + search(54) */
  padding-bottom: 20px;
}

.contacts-content.has-breadcrumb {
  padding-top: 132px; /* + breadcrumb(32) */
}

.group-title {
  padding: 16px 16px 8px;
  font-size: 14px;
  color: #969799;
}

.dept-group {
  margin-bottom: 16px;
}

.dept-icon {
  width: 36px;
  height: 36px;
  background: #e8f3ff;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 12px;
  color: #1989fa;
  font-size: 20px;
}

.member-list {
  padding: 0 16px;
}

.member-card {
  background: #fff;
  border-radius: 12px;
  padding: 16px;
  display: flex;
  align-items: center;
  margin-bottom: 12px;
}

.member-info {
  flex: 1;
  margin-left: 12px;
}

.name-row {
  display: flex;
  align-items: center;
  margin-bottom: 4px;
}

.name {
  font-size: 16px;
  font-weight: 500;
  color: #323233;
  margin-right: 8px;
}

.position {
  font-size: 13px;
  color: #969799;
}

.loading-state {
  margin-top: 100px;
}

.ml-2 {
  margin-left: 8px;
}

.mt-3 {
  margin-top: 12px;
}

/* Detail Popup */
.detail-popup {
  padding: 40px 20px;
  display: flex;
  flex-direction: column;
  align-items: center;
  height: 100%;
  box-sizing: border-box;
}

.detail-header {
  text-align: center;
  margin-bottom: 30px;
}

.detail-name {
  margin: 16px 0 8px;
  font-size: 24px;
  color: #323233;
}

.detail-position {
  font-size: 14px;
  color: #969799;
}

.detail-info {
  width: 100%;
  margin-bottom: auto;
}

.detail-actions {
  width: 100%;
}

.action-icon {
  font-size: 20px;
}

.action-icon.phone {
  color: #07c160;
}

.action-icon.email {
  color: #1989fa;
}
</style>