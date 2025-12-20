<template>
  <div class="page-container">
    <div class="stats-overview">
      <a-row :gutter="16">
        <a-col :span="6">
          <a-card>
            <a-statistic title="本月销售目标" :value="1000000" prefix="¥" />
            <a-progress :percent="75" status="active" />
          </a-card>
        </a-col>
        <a-col :span="6">
          <a-card>
            <a-statistic title="本季完成进度" :value="65" suffix="%" />
            <a-progress :percent="65" status="active" />
          </a-card>
        </a-col>
        <a-col :span="6">
          <a-card>
            <a-statistic title="新增商机数" :value="12" />
            <div style="color: green; margin-top: 8px"><ArrowUpOutlined /> 同比增长 20%</div>
          </a-card>
        </a-col>
        <a-col :span="6">
          <a-card>
            <a-statistic title="赢单率" :value="35.5" precision="1" suffix="%" />
            <div style="color: red; margin-top: 8px"><ArrowDownOutlined /> 环比下降 5%</div>
          </a-card>
        </a-col>
      </a-row>
    </div>

    <div class="chart-section" style="margin-top: 24px">
      <a-card title="团队业绩排名">
        <a-table :columns="columns" :data-source="rankingData" :pagination="false" />
      </a-card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ArrowUpOutlined, ArrowDownOutlined } from '@ant-design/icons-vue';

const columns = [
  { title: '排名', dataIndex: 'rank', key: 'rank' },
  { title: '姓名', dataIndex: 'name', key: 'name' },
  { title: '完成金额', dataIndex: 'amount', key: 'amount' },
  { title: '完成率', dataIndex: 'rate', key: 'rate' },
];

const rankingData = [
  { rank: 1, name: '张三', amount: '¥ 800,000', rate: '120%' },
  { rank: 2, name: '李四', amount: '¥ 650,000', rate: '95%' },
  { rank: 3, name: '王五', amount: '¥ 500,000', rate: '80%' },
  { rank: 4, name: '赵六', amount: '¥ 400,000', rate: '70%' },
];
</script>

<style scoped>
.page-container {
  padding: 24px;
}
</style>