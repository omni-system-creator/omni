<template>
  <a-dropdown>
    <span class="user-dropdown-link">
      <a-avatar v-if="userStore.avatar" :src="userStore.avatar" />
      <a-avatar v-else style="background-color: #bfbfbf">
        <template #icon><UserOutlined /></template>
      </a-avatar>
      <div class="user-info">
        <span class="username-text">{{ userStore.nickname || userStore.username }}</span>
        <a-tooltip v-if="userStore.currentOrg" :title="userStore.currentOrg.name" placement="bottom">
            <span class="org-name">{{ userStore.currentOrg.name }}</span>
        </a-tooltip>
      </div>
    </span>
    <template #overlay>
      <a-menu>
        <a-sub-menu key="orgs" v-if="userStore.organizations.length > 1">
            <template #title>
                <span style="display: inline-flex; align-items: center; white-space: nowrap;">
                    <DynamicIcon icon="ant-design:bank-outlined" />
                    <span style="margin-left: 8px">切换组织</span>
                </span>
            </template>
            <a-menu-item v-for="org in userStore.organizations.slice(0, 10)" :key="'org-'+org.id" @click="handleSwitchOrg(org)">
                <span style="display: flex; justify-content: space-between; align-items: center; min-width: 150px;">
                    <span>{{ org.name }}</span>
                    <CheckOutlined v-if="userStore.currentOrg?.id === org.id" style="color: #52c41a" />
                </span>
            </a-menu-item>
            <a-menu-divider v-if="userStore.organizations.length > 10" />
            <a-menu-item v-if="userStore.organizations.length > 10" key="org-more" @click="openOrgSelectModal">
                <span style="color: #1890ff">更多组织...</span>
            </a-menu-item>
        </a-sub-menu>
        <a-menu-divider v-if="userStore.organizations.length > 1" />

        <a-menu-item key="account" @click="router.push('/personal/account')">
          <DynamicIcon icon="ant-design:user-outlined" />
          <span style="margin-left: 8px">个人中心</span>
        </a-menu-item>
        <a-menu-item key="password" @click="showChangePassword">
          <DynamicIcon icon="ant-design:lock-outlined" />
          <span style="margin-left: 8px">修改密码</span>
        </a-menu-item>
        <a-menu-item key="about" @click="showAbout">
          <DynamicIcon icon="ant-design:info-circle-outlined" />
          <span style="margin-left: 8px">关于系统</span>
        </a-menu-item>
        <a-menu-divider />
        <a-menu-item key="logout" @click="handleLogout">
          <DynamicIcon icon="ant-design:logout-outlined" />
          <span style="margin-left: 8px">退出登录</span>
        </a-menu-item>
      </a-menu>
    </template>
  </a-dropdown>

  <AboutModal v-model:open="aboutVisible" />

  <a-modal
    v-model:open="orgModalVisible"
    title="切换组织"
    width="800px"
    @ok="handleOrgModalOk"
    :confirmLoading="orgLoading"
  >
    <div style="margin-bottom: 16px; display: flex; justify-content: space-between;">
      <a-input-search
        v-model:value="orgQuery.keyword"
        placeholder="请输入组织名称或编码"
        enter-button
        @search="fetchOrgList"
        style="width: 300px"
      />
    </div>
    <a-table
      :columns="columns"
      :data-source="orgList"
      :pagination="{
        current: orgQuery.page,
        pageSize: orgQuery.pageSize,
        total: orgTotal,
        showTotal: (total: number) => `共 ${total} 条`
      }"
      :loading="orgLoading"
      row-key="id"
      :row-selection="{
        type: 'radio',
        selectedRowKeys: selectedOrgId ? [selectedOrgId] : [],
        onChange: onSelectChange
      }"
      @change="handleTableChange"
      size="small"
    />
  </a-modal>
</template>

<script lang="ts" setup>
import { ref, onMounted, reactive } from 'vue';
import { useRouter } from 'vue-router';
import { message } from 'ant-design-vue';
import { UserOutlined, CheckOutlined } from '@ant-design/icons-vue';
import { useUserStore } from '@/stores/user';
import { getDeptList, type Dept } from '@/api/dept';
import DynamicIcon from '@/components/DynamicIcon.vue';
import AboutModal from './AboutModal.vue';

const router = useRouter();
const userStore = useUserStore();
const aboutVisible = ref(false);

onMounted(() => {
  userStore.fetchOrganizations();
});

const orgModalVisible = ref(false);
const orgList = ref<Dept[]>([]);
const orgTotal = ref(0);
const orgLoading = ref(false);
const selectedOrgId = ref<number | undefined>(undefined);

const orgQuery = reactive({
  keyword: '',
  page: 1,
  pageSize: 10
});

const columns = [
  { title: '组织名称', dataIndex: 'name', key: 'name' },
  { title: '编码', dataIndex: 'code', key: 'code' },
  { title: '类型', dataIndex: 'type', key: 'type', customRender: ({ text }: any) => {
    const typeMap: Record<string | number, string> = { 
      1: '集团', 2: '公司', 3: '部门',
      'Group': '集团', 'Company': '公司', 'Department': '部门'
    };
    return typeMap[text] || text;
  }},
  { title: '负责人', dataIndex: 'leader', key: 'leader' }
];

const openOrgSelectModal = () => {
  orgModalVisible.value = true;
  selectedOrgId.value = userStore.currentOrg?.id;
  fetchOrgList();
};

const fetchOrgList = async () => {
  orgLoading.value = true;
  try {
    const res = await getDeptList({
      keyword: orgQuery.keyword,
      page: orgQuery.page,
      pageSize: orgQuery.pageSize
    });
    if (res) {
      orgList.value = res.items;
      orgTotal.value = res.total;
    }
  } catch (error) {
    message.error('获取组织列表失败');
  } finally {
    orgLoading.value = false;
  }
};

const handleTableChange = (pag: any) => {
  orgQuery.page = pag.current;
  orgQuery.pageSize = pag.pageSize;
  fetchOrgList();
};

const onSelectChange = (keys: any[]) => {
    selectedOrgId.value = keys[0];
};

const handleOrgModalOk = async () => {
  if (!selectedOrgId.value) {
    message.warning('请选择一个组织');
    return;
  }
  const selectedOrg = orgList.value.find(o => o.id === selectedOrgId.value);
  if (selectedOrg) {
    const orgDto = {
        id: selectedOrg.id,
        name: selectedOrg.name,
        isCurrent: false
    };
    await handleSwitchOrg(orgDto);
    orgModalVisible.value = false;
  }
};

const handleSwitchOrg = async (org: any) => {
  if (userStore.currentOrg?.id === org.id) return;
  try {
    await userStore.switchOrg(org);
    message.success(`已切换到组织: ${org.name}`);
    // 如果需要刷新数据，可以考虑刷新页面
    // window.location.reload();
  } catch (error) {
    message.error('切换组织失败');
  }
};

const showChangePassword = () => {
  router.push('/personal/account?tab=security');
};

const showAbout = () => {
  aboutVisible.value = true;
};

const handleLogout = () => {
  userStore.logout();
  message.success('已退出登录');
  router.push('/login');
};
</script>

<style scoped>
.user-dropdown-link {
  cursor: pointer;
  display: flex;
  align-items: center;
  padding: 0 12px;
  transition: all 0.3s;
}

.user-dropdown-link:hover {
  background: rgba(0, 0, 0, 0.025);
}

.user-info {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: flex-start;
  margin-left: 8px;
  line-height: 1.3;
}

.username-text {
  font-size: 14px;
  font-weight: 500;
  color: rgba(0, 0, 0, 0.85);
}

.org-name {
  font-size: 12px;
  color: #888;
  max-width: 100px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  display: inline-block;
}
</style>
