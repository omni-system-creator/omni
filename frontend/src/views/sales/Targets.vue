<template>
  <div class="page-container">
    <div class="stats-overview">
      <a-row :gutter="16">
        <a-col :span="6">
          <a-card>
            <a-statistic title="本月销售目标" :value="stats.monthlyTarget" prefix="¥" />
            <a-progress :percent="stats.monthlyProgress" status="active" />
          </a-card>
        </a-col>
        <a-col :span="6">
          <a-card>
            <a-statistic title="本季完成进度" :value="stats.quarterlyProgress" suffix="%" />
            <a-progress :percent="stats.quarterlyProgress" status="active" />
          </a-card>
        </a-col>
        <a-col :span="6">
          <a-card>
            <a-statistic title="新增商机数" :value="stats.newOpportunities" />
            <div :style="{ color: stats.newOpportunitiesGrowth >= 0 ? 'green' : 'red', marginTop: '8px' }">
                <component :is="stats.newOpportunitiesGrowth >= 0 ? ArrowUpOutlined : ArrowDownOutlined" /> 
                {{ stats.newOpportunitiesGrowth >= 0 ? '同比增长' : '同比下降' }} {{ Math.abs(stats.newOpportunitiesGrowth) }}%
            </div>
          </a-card>
        </a-col>
        <a-col :span="6">
          <a-card>
            <a-statistic title="赢单率" :value="stats.winRate" precision="1" suffix="%" />
             <div :style="{ color: stats.winRateGrowth >= 0 ? 'green' : 'red', marginTop: '8px' }">
                <component :is="stats.winRateGrowth >= 0 ? ArrowUpOutlined : ArrowDownOutlined" /> 
                {{ stats.winRateGrowth >= 0 ? '环比增长' : '环比下降' }} {{ Math.abs(stats.winRateGrowth) }}%
            </div>
          </a-card>
        </a-col>
      </a-row>
    </div>

    <div class="chart-section" style="margin-top: 24px">
      <a-card title="团队业绩排名">
        <a-table :columns="columns" :data-source="rankingData" :pagination="false">
             <template #bodyCell="{ column, record }">
                 <template v-if="column.key === 'amount'">
                     ¥ {{ record.amount.toLocaleString() }}
                 </template>
                 <template v-if="column.key === 'rate'">
                     {{ record.rate }}%
                 </template>
             </template>
        </a-table>
      </a-card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { ArrowUpOutlined, ArrowDownOutlined } from '@ant-design/icons-vue';
import { getSalesDashboardStats, getTeamRanking, type SalesDashboardStatsDto, type TeamRankingDto } from '@/api/sales';

const stats = ref<SalesDashboardStatsDto>({
    monthlyTarget: 0,
    monthlyProgress: 0,
    quarterlyProgress: 0,
    newOpportunities: 0,
    newOpportunitiesGrowth: 0,
    winRate: 0,
    winRateGrowth: 0
});

const rankingData = ref<TeamRankingDto[]>([]);

const columns = [
  { title: '排名', dataIndex: 'rank', key: 'rank' },
  { title: '姓名', dataIndex: 'name', key: 'name' },
  { title: '完成金额', dataIndex: 'amount', key: 'amount' },
  { title: '完成率', dataIndex: 'rate', key: 'rate' },
];

onMounted(async () => {
    try {
        const [statsData, ranking] = await Promise.all([
            getSalesDashboardStats(),
            getTeamRanking()
        ]);
        stats.value = statsData;
        rankingData.value = ranking;
    } catch (e) {
        console.error(e);
    }
});
</script>

<style scoped>
.page-container {
  padding: 24px;
}
</style>