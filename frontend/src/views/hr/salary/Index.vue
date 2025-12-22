<template>
  <div class="salary-container">
    <!-- KPI Cards -->
    <a-row :gutter="16" class="kpi-row">
      <a-col :span="6">
        <a-card>
          <a-statistic title="本月预计发薪 (万元)" :value="345.2" :precision="1">
            <template #suffix>
              <span style="font-size: 14px; color: #cf1322"><ArrowUpOutlined /> 5.2%</span>
            </template>
          </a-statistic>
          <div class="kpi-footer">上月: 328.1万</div>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card>
          <a-statistic title="平均薪资 (k)" :value="26.8" :precision="1">
            <template #prefix><PayCircleOutlined /></template>
          </a-statistic>
          <div class="kpi-footer">行业平均: 24.5k</div>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card>
          <a-statistic title="本月奖金总额 (万元)" :value="48.5" :precision="1">
             <template #prefix><GiftOutlined /></template>
          </a-statistic>
          <div class="kpi-footer">季度绩效奖金发放月</div>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card>
          <a-statistic title="五险一金缴纳 (万元)" :value="88.4" :precision="1">
             <template #prefix><SafetyCertificateOutlined /></template>
          </a-statistic>
          <div class="kpi-footer">正常缴纳</div>
        </a-card>
      </a-col>
    </a-row>

    <!-- Charts & Actions -->
    <a-row :gutter="16" style="margin-bottom: 24px">
      <a-col :span="16">
        <a-card title="薪资支出趋势 (近6个月)" :bordered="false">
          <div ref="chartRef" style="height: 300px; width: 100%"></div>
        </a-card>
      </a-col>
      <a-col :span="8">
        <a-card title="快捷操作" :bordered="false" style="height: 100%">
          <a-space direction="vertical" style="width: 100%">
            <a-button type="primary" block size="large">
              <template #icon><CalculatorOutlined /></template> 
              计算本月薪资
            </a-button>
            <a-button block size="large">
              <template #icon><MailOutlined /></template>
              发送工资条
            </a-button>
            <a-button block size="large">
              <template #icon><FileExcelOutlined /></template>
              导出报税表格
            </a-button>
            <a-alert
              message="温馨提示"
              description="本月工资发放日为15号（周五），请务必在13号前完成核算。"
              type="warning"
              show-icon
              style="margin-top: 16px"
            />
          </a-space>
        </a-card>
      </a-col>
    </a-row>

    <!-- Salary Table -->
    <a-card title="员工薪资明细" :bordered="false">
      <template #extra>
        <a-space>
          <a-input-search placeholder="搜索姓名" style="width: 200px" />
          <a-month-picker placeholder="选择月份" />
        </a-space>
      </template>
      <a-table :columns="columns" :data-source="data" :pagination="{ pageSize: 5 }">
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'status'">
            <a-badge status="success" text="已核算" v-if="record.status === 'calculated'" />
            <a-badge status="processing" text="待核算" v-else />
          </template>
          <template v-if="column.key === 'action'">
            <a>详情</a>
            <a-divider type="vertical" />
            <a>调整</a>
          </template>
        </template>
      </a-table>
    </a-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import * as echarts from 'echarts';
import { 
  ArrowUpOutlined, 
  PayCircleOutlined, 
  GiftOutlined, 
  SafetyCertificateOutlined,
  CalculatorOutlined,
  MailOutlined,
  FileExcelOutlined
} from '@ant-design/icons-vue';

const chartRef = ref<HTMLElement | null>(null);

const columns = [
  { title: '工号', dataIndex: 'id', key: 'id' },
  { title: '姓名', dataIndex: 'name', key: 'name' },
  { title: '部门', dataIndex: 'dept', key: 'dept' },
  { title: '基本工资', dataIndex: 'base', key: 'base' },
  { title: '绩效奖金', dataIndex: 'bonus', key: 'bonus' },
  { title: '五险一金', dataIndex: 'insurance', key: 'insurance' },
  { title: '个税', dataIndex: 'tax', key: 'tax' },
  { title: '实发工资', dataIndex: 'net', key: 'net', sorter: (a: any, b: any) => a.net - b.net },
  { title: '状态', key: 'status', dataIndex: 'status' },
  { title: '操作', key: 'action' },
];

const data = [
  { key: 1, id: 'EMP001', name: '张三', dept: '研发部', base: 35000, bonus: 5000, insurance: 4500, tax: 2800, net: 32700, status: 'calculated' },
  { key: 2, id: 'EMP002', name: '李四', dept: '研发部', base: 28000, bonus: 3000, insurance: 3800, tax: 1500, net: 25700, status: 'calculated' },
  { key: 3, id: 'EMP003', name: '王五', dept: '产品部', base: 30000, bonus: 8000, insurance: 4000, tax: 3200, net: 30800, status: 'calculated' },
  { key: 4, id: 'EMP004', name: '赵六', dept: '测试部', base: 22000, bonus: 2000, insurance: 3000, tax: 1000, net: 20000, status: 'calculated' },
  { key: 5, id: 'EMP005', name: '钱七', dept: '设计部', base: 20000, bonus: 2500, insurance: 2800, tax: 800, net: 18900, status: 'calculated' },
];

onMounted(() => {
  if (chartRef.value) {
    const myChart = echarts.init(chartRef.value);
    const option = {
      tooltip: {
        trigger: 'axis'
      },
      grid: {
        left: '3%',
        right: '4%',
        bottom: '3%',
        containLabel: true
      },
      xAxis: {
        type: 'category',
        boundaryGap: false,
        data: ['7月', '8月', '9月', '10月', '11月', '12月']
      },
      yAxis: {
        type: 'value',
        name: '万元'
      },
      series: [
        {
          name: '薪资总支出',
          type: 'line',
          smooth: true,
          data: [310, 312, 315, 320, 328, 345],
          areaStyle: {
            color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
              { offset: 0, color: 'rgba(24, 144, 255, 0.5)' },
              { offset: 1, color: 'rgba(24, 144, 255, 0.01)' }
            ])
          },
          itemStyle: {
            color: '#1890ff'
          }
        }
      ]
    };
    myChart.setOption(option);
    
    window.addEventListener('resize', () => {
      myChart.resize();
    });
  }
});
</script>

<style scoped>
.salary-container {
  padding: 16px;
  flex: 1;
}
.kpi-row {
  margin-bottom: 24px;
}
.kpi-footer {
  margin-top: 8px;
  font-size: 12px;
  color: #8c8c8c;
}
</style>
