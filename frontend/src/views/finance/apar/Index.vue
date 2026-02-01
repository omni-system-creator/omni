<template>
  <div class="finance-apar-container">
    <div class="statistics-section mb-4">
      <a-row :gutter="16">
        <a-col :span="6">
          <a-card>
            <a-statistic
              title="应收总额"
              :value="stats.totalReceivables"
              :precision="2"
              prefix="¥"
              :value-style="{ color: '#3f8600' }"
            >
              <template #suffix>
                <ArrowUpOutlined />
              </template>
            </a-statistic>
          </a-card>
        </a-col>
        <a-col :span="6">
          <a-card>
            <a-statistic
              title="应付总额"
              :value="stats.totalPayables"
              :precision="2"
              prefix="¥"
              :value-style="{ color: '#cf1322' }"
            >
              <template #suffix>
                <ArrowDownOutlined />
              </template>
            </a-statistic>
          </a-card>
        </a-col>
        <a-col :span="6">
          <a-card>
            <a-statistic
              title="逾期应收"
              :value="stats.overdueReceivables"
              :precision="2"
              prefix="¥"
              :value-style="{ color: '#faad14' }"
            />
          </a-card>
        </a-col>
        <a-col :span="6">
          <a-card>
            <a-statistic
              title="逾期应付"
              :value="stats.overduePayables"
              :precision="2"
              prefix="¥"
              :value-style="{ color: '#faad14' }"
            />
          </a-card>
        </a-col>
      </a-row>
    </div>

    <a-card :bordered="false" class="flex-1 main-card">
      <a-tabs v-model:activeKey="activeTab">
        <a-tab-pane key="ar" tab="应收账款 (AR)">
          <ArList @refresh="fetchStats" />
        </a-tab-pane>

        <a-tab-pane key="ap" tab="应付账款 (AP)">
          <ApList @refresh="fetchStats" />
        </a-tab-pane>
      </a-tabs>
    </a-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { ArrowUpOutlined, ArrowDownOutlined } from '@ant-design/icons-vue';
import ArList from './components/ArList.vue';
import ApList from './components/ApList.vue';
import { getStats, type FinanceStats } from '@/api/finance';

const activeTab = ref('ar');
const stats = ref<FinanceStats>({
  totalReceivables: 0,
  totalPayables: 0,
  overdueReceivables: 0,
  overduePayables: 0
});

const fetchStats = async () => {
  try {
    const res = await getStats();
    if (res) {
      stats.value = res;
    }
  } catch (error) {
    console.error('Fetch stats failed', error);
  }
};

onMounted(() => {
  fetchStats();
});
</script>

<style scoped>
.finance-apar-container {
  padding: 16px;
  display: flex;
  flex-direction: column;
  height: 100%;
}
.mb-4 {
  margin-bottom: 16px;
}
.flex-1 {
  flex: 1;
}

.main-card :deep(.ant-card-body) {
  padding: 0 !important;
  height: 100%;
  display: flex;
  flex-direction: column;
}

.main-card :deep(.ant-tabs) {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.main-card :deep(.ant-tabs-content) {
  height: 100%;
  flex: 1;
}

.main-card :deep(.ant-tabs-tabpane) {
  height: 100%;
}

.main-card :deep(.ant-tabs-nav) {
  margin-bottom: 0;
}

.main-card :deep(.ant-tabs-tab) {
  margin: 0 !important;
  padding: 12px 24px !important;
}
</style>
