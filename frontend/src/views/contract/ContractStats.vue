<template>
  <div class="contract-stats-container">
    <!-- 顶部筛选与标题 -->
    <div class="header-section">
      <div class="filter-area">
        <a-radio-group v-model:value="timeRange" button-style="solid">
          <a-radio-button value="month">本月</a-radio-button>
          <a-radio-button value="quarter">本季度</a-radio-button>
          <a-radio-button value="year">本年</a-radio-button>
        </a-radio-group>
        <a-range-picker v-if="timeRange === 'custom'" style="margin-left: 16px" />
      </div>
    </div>

    <!-- 核心指标卡片 -->
    <a-row :gutter="[16, 16]" class="metrics-row" type="flex">
      <a-col :span="6" style="display: flex; flex-direction: column;">
        <a-card hoverable class="metric-card" style="width: 100%">
          <a-statistic :title="timeRangeMap[timeRange] + '签订合同总数'" :value="statsData.totalContracts" suffix="份">
            <template #prefix><FileProtectOutlined class="icon-blue" /></template>
          </a-statistic>
          <div class="metric-footer">
            <span>同比 {{ statsData.totalContractsGrowth > 0 ? '+' : '' }}{{ statsData.totalContractsGrowth }}%</span>
            <span class="trend-icon up" v-if="statsData.totalContractsGrowth > 0"><ArrowUpOutlined /></span>
            <span class="trend-icon down" v-else><ArrowDownOutlined /></span>
          </div>
        </a-card>
      </a-col>
      <a-col :span="6" style="display: flex; flex-direction: column;">
        <a-card hoverable class="metric-card" style="width: 100%">
          <a-statistic title="合同总金额" :value="statsData.totalAmount" :precision="2" prefix="¥">
            <template #prefix><PayCircleOutlined class="icon-gold" /></template>
          </a-statistic>
          <div class="metric-footer">
            <span>完成率 {{ statsData.amountCompletionRate }}%</span>
            <a-progress :percent="statsData.amountCompletionRate" size="small" :show-info="false" stroke-color="#faad14" />
          </div>
        </a-card>
      </a-col>
      <a-col :span="6" style="display: flex; flex-direction: column;">
        <a-card hoverable class="metric-card" style="width: 100%">
          <a-statistic title="回款金额" :value="statsData.receivedAmount" :precision="2" prefix="¥">
             <template #prefix><CheckCircleOutlined class="icon-green" /></template>
          </a-statistic>
          <div class="metric-footer">
             <span>回款率 {{ statsData.receivedRate }}%</span>
             <a-progress :percent="statsData.receivedRate" size="small" :show-info="false" stroke-color="#52c41a" />
          </div>
        </a-card>
      </a-col>
      <a-col :span="6" style="display: flex; flex-direction: column;">
        <a-card hoverable class="metric-card" style="width: 100%">
          <a-statistic title="待开票金额" :value="statsData.pendingInvoice" :precision="2" prefix="¥">
             <template #prefix><FileTextOutlined class="icon-purple" /></template>
          </a-statistic>
          <div class="metric-footer">
             <span>累计已开票 {{ statsData.invoicedTotal }}</span>
          </div>
        </a-card>
      </a-col>
    </a-row>

    <!-- 图表分析区域 -->
    <a-row :gutter="[16, 16]" class="charts-row">
      <!-- 趋势分析 -->
      <a-col :span="16">
        <a-card title="近几年合同签订趋势" class="chart-card">
          <template #extra>
             <a-select v-model:value="trendMetric" style="width: 120px" size="small">
                <a-select-option value="amount">按金额</a-select-option>
                <a-select-option value="count">按数量</a-select-option>
             </a-select>
          </template>
          <div ref="trendChartRef" class="chart-container"></div>
        </a-card>
      </a-col>
      
      <!-- 合同类型分布 -->
      <a-col :span="8">
        <a-card title="合同类型占比" class="chart-card">
           <div ref="typeChartRef" class="chart-container"></div>
        </a-card>
      </a-col>
    </a-row>

    <!-- 详细执行情况与知识学习 -->
    <a-row :gutter="[16, 16]" class="bottom-row">
       <a-col :span="12">
          <a-card title="合同执行情况概览" class="detail-card">
             <a-table :columns="executionColumns" :data-source="executionData" :pagination="false" size="small">
                <template #bodyCell="{ column, record }">
                   <template v-if="column.key === 'status'">
                      <a-badge :status="record.statusType" :text="record.status" />
                   </template>
                   <template v-if="column.key === 'progress'">
                      <a-progress :percent="record.progress" size="small" />
                   </template>
                </template>
             </a-table>
          </a-card>
       </a-col>

       <a-col :span="12">
          <a-card title="合同知识与合规学习" class="knowledge-card">
             <template #extra><a href="#">更多 ></a></template>
             <a-list item-layout="horizontal" :data-source="knowledgeList">
                <template #renderItem="{ item }">
                  <a-list-item>
                    <a-list-item-meta :description="item.desc">
                      <template #title>
                        <a :href="item.link" target="_blank">{{ item.title }}</a>
                        <a-tag color="blue" style="margin-left: 8px" v-if="item.isNew">NEW</a-tag>
                      </template>
                      <template #avatar>
                        <ReadOutlined style="font-size: 24px; color: #1890ff" />
                      </template>
                    </a-list-item-meta>
                  </a-list-item>
                </template>
             </a-list>
          </a-card>
       </a-col>
    </a-row>

  </div>
</template>

<script lang="ts" setup>
import { ref, reactive, computed, onMounted, onUnmounted, watch, nextTick } from 'vue';
import {
  FileProtectOutlined,
  PayCircleOutlined,
  CheckCircleOutlined,
  FileTextOutlined,
  ArrowUpOutlined,
  ArrowDownOutlined,
  ReadOutlined
} from '@ant-design/icons-vue';
import * as echarts from 'echarts';
import { 
  getCurrentStats, 
  getTrendStats, 
  getKnowledgeFiles, 
  getKnowledgeCategories,
  type ContractStatDto
} from '@/api/contract';

// --- 状态 ---
const timeRange = ref('year');
const trendMetric = ref('amount');
// const currentDate = new Date().toLocaleDateString();

const trendChartRef = ref<HTMLElement | null>(null);
const typeChartRef = ref<HTMLElement | null>(null);
let trendChartInstance: echarts.ECharts | null = null;
let typeChartInstance: echarts.ECharts | null = null;

const timeRangeMap: Record<string, string> = {
  month: '本月',
  quarter: '本季度',
  year: '本年',
  custom: '自定义'
};

// 核心指标数据
const statsData = reactive({
  totalContracts: 0,
  totalContractsGrowth: 0,
  totalAmount: 0,
  amountCompletionRate: 0,
  receivedAmount: 0,
  receivedRate: 0,
  pendingInvoice: 0,
  invoicedTotal: '0'
});

// 趋势图数据
const rawTrendData = ref<ContractStatDto[]>([]);

const trendData = computed(() => {
  return rawTrendData.value.map(item => {
    // 假设 statDate 是 "2023-01-01T00:00:00"
    const year = new Date(item.statDate).getFullYear().toString();
    return {
      year,
      value: trendMetric.value === 'amount' ? (item.totalAmount / 10000) : item.totalContracts // 金额转为万元
    };
  });
});

// 类型分布数据
const typeData = [
  { type: 'sales', name: '销售合同', value: 45 },
  { type: 'purchase', name: '采购合同', value: 25 },
  { type: 'service', name: '服务合同', value: 15 },
  { type: 'labor', name: '劳动合同', value: 10 },
  { type: 'other', name: '其他', value: 5 },
];

// 获取核心指标
const fetchCurrentStats = async () => {
  try {
    const periodTypeMap: Record<string, string> = {
      month: 'Month',
      quarter: 'Quarter',
      year: 'Year'
    };
    const periodType = periodTypeMap[timeRange.value] || 'Year';
    const res = await getCurrentStats(periodType);
    if (res) {
      statsData.totalContracts = res.totalContracts;
      statsData.totalContractsGrowth = res.totalContractsGrowth;
      statsData.totalAmount = res.totalAmount;
      statsData.amountCompletionRate = res.amountCompletionRate;
      statsData.receivedAmount = res.receivedAmount;
      statsData.receivedRate = res.receivedRate;
      statsData.pendingInvoice = res.pendingInvoiceAmount;
      statsData.invoicedTotal = (res.invoicedAmount / 10000).toFixed(1) + '万';
    }
  } catch (error) {
    console.error('Failed to fetch current stats:', error);
  }
};

// 获取趋势数据
const fetchTrendStats = async () => {
  try {
    // 总是获取年度趋势
    const res = await getTrendStats('Year', 5);
    if (res) {
      // 按时间升序排序
      rawTrendData.value = res.sort((a, b) => {
        const dateA = a.statDate ? new Date(a.statDate).getTime() : 0;
        const dateB = b.statDate ? new Date(b.statDate).getTime() : 0;
        return dateA - dateB;
      });
      updateTrendChart();
    }
  } catch (error) {
    console.error('Failed to fetch trend stats:', error);
  }
};

// 获取知识库数据
const knowledgeList = ref<any[]>([]);
const fetchKnowledge = async () => {
  try {
    // 获取所有分类，找到"合同知识库"下的文件
    // 这里简化处理，直接获取某个分类下的文件，或者搜索
    // 假设我们要展示最新的知识库文件
    // 先获取分类
    const categories = await getKnowledgeCategories();
    // 假设我们取第一个分类的文件，或者所有文件的最新几个
    // 这里我们先mock一下，或者如果后端支持获取最新文件更好
    // 由于后端API限制，我们先获取根分类下的文件，或者 hardcode 一个 categoryId 如果知道的话
    // 或者遍历获取。为了演示，我们先尝试获取 categoryId=1 的文件 (Usually Root or first category)
    // 实际上 DbInitializer 创建了多个分类。
    // 我们可以获取 "民法典" (civilCode) 的文件
    
    // 暂时用 API 获取 categoryId=1 的文件 (假设存在)
    // Better: Recursive search or just fetch a known category.
    // Let's try to find "法律法规" category.
    let targetId = 1;
    if (categories && categories.length > 0) {
       const target = categories.find((c: any) => c.name === '法律法规');
       const firstCategory = categories[0];
       targetId = target ? target.id : (firstCategory ? firstCategory.id : 1);
    }
    
    const files = await getKnowledgeFiles(targetId);
    if (files) {
      knowledgeList.value = files.map(f => ({
        title: f.name,
        desc: `类型: ${f.type} | 大小: ${f.size} | 上传者: ${f.uploader}`,
        link: '#', // 暂无下载链接
        isNew: new Date(f.uploadTime) > new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)
      }));
    }
  } catch (error) {
    console.error('Failed to fetch knowledge:', error);
    // Fallback to mock if failed
    knowledgeList.value = [
      { title: '民法典合同编核心条款解读', desc: '深入理解新法典下的合同签订风险点', link: '#', isNew: true },
      { title: '企业合同管理常见法律风险及防范', desc: '实务案例分析与风控建议', link: '#', isNew: false },
    ];
  }
};

watch(timeRange, () => {
  fetchCurrentStats();
});

// 初始化趋势图
const initTrendChart = () => {
  if (!trendChartRef.value) return;
  trendChartInstance = echarts.init(trendChartRef.value);
  updateTrendChart();
};

// 更新趋势图
const updateTrendChart = () => {
  if (!trendChartInstance) return;
  
  const isAmount = trendMetric.value === 'amount';
  const unit = isAmount ? '万元' : '份';
  const color = isAmount ? '#1890ff' : '#722ed1';
  
  const option = {
    tooltip: {
      trigger: 'axis',
      formatter: `{b}<br/>{a}: {c} ${unit}`
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      containLabel: true
    },
    xAxis: {
      type: 'category',
      data: trendData.value.map(item => item.year),
      axisTick: { alignWithLabel: true }
    },
    yAxis: {
      type: 'value',
      name: unit
    },
    series: [
      {
        name: isAmount ? '合同金额' : '合同数量',
        type: 'bar',
        barWidth: '40%',
        data: trendData.value.map(item => item.value),
        itemStyle: {
          color: color,
          borderRadius: [4, 4, 0, 0]
        },
        label: {
          show: true,
          position: 'top',
          color: '#666'
        }
      }
    ]
  };
  trendChartInstance.setOption(option);
};

// 初始化类型分布图
const initTypeChart = () => {
  if (!typeChartRef.value) return;
  typeChartInstance = echarts.init(typeChartRef.value);
  
  const option = {
    tooltip: {
      trigger: 'item',
      formatter: '{a} <br/>{b}: {c}%'
    },
    legend: {
      bottom: '0%',
      left: 'center'
    },
    series: [
      {
        name: '合同类型',
        type: 'pie',
        radius: ['40%', '70%'],
        avoidLabelOverlap: false,
        itemStyle: {
          borderRadius: 10,
          borderColor: '#fff',
          borderWidth: 2
        },
        label: {
          show: true,
          formatter: '{b}: {c} ({d}%)'
        },
        emphasis: {
          label: {
            show: true,
            fontSize: 16,
            fontWeight: 'bold'
          }
        },
        labelLine: {
          show: true
        },
        data: typeData
      }
    ]
  };
  typeChartInstance.setOption(option);
};

// 监听数据变化
watch(trendMetric, () => {
  updateTrendChart();
});

// 响应式调整
const handleResize = () => {
  trendChartInstance?.resize();
  typeChartInstance?.resize();
};

onMounted(() => {
  nextTick(() => {
    fetchCurrentStats();
    fetchTrendStats();
    fetchKnowledge();
    initTrendChart();
    initTypeChart();
    window.addEventListener('resize', handleResize);
  });
});

onUnmounted(() => {
  window.removeEventListener('resize', handleResize);
  trendChartInstance?.dispose();
  typeChartInstance?.dispose();
});


// 执行情况表格列
const executionColumns = [
  { title: '部门', dataIndex: 'dept', key: 'dept' },
  { title: '合同数', dataIndex: 'count', key: 'count' },
  { title: '履约进度', dataIndex: 'progress', key: 'progress' },
  { title: '状态', dataIndex: 'status', key: 'status' },
];

// 执行情况数据
const executionData = [
  { dept: '销售一部', count: 42, progress: 85, status: '正常', statusType: 'success' },
  { dept: '销售二部', count: 35, progress: 60, status: '有风险', statusType: 'warning' },
  { dept: '采购部', count: 25, progress: 92, status: '正常', statusType: 'success' },
  { dept: '研发部', count: 12, progress: 100, status: '完成', statusType: 'default' },
  { dept: '行政部', count: 8, progress: 100, status: '完成', statusType: 'default' },
];

</script>

<style scoped>
.contract-stats-container {
  padding: 24px;
  background: #f0f2f5;
  min-height: 100%;
}

.header-section {
  display: flex;
  justify-content: flex-end;
  align-items: center;
  margin-bottom: 24px;
}

.metrics-row {
  margin-bottom: 24px;
}

.metric-card {
  border-radius: 8px;
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.icon-blue { color: #1890ff; font-size: 24px; background: #e6f7ff; padding: 8px; border-radius: 50%; }
.icon-gold { color: #faad14; font-size: 24px; background: #fffbe6; padding: 8px; border-radius: 50%; }
.icon-green { color: #52c41a; font-size: 24px; background: #f6ffed; padding: 8px; border-radius: 50%; }
.icon-purple { color: #722ed1; font-size: 24px; background: #f9f0ff; padding: 8px; border-radius: 50%; }

.metric-footer {
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid #f0f0f0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  color: #666;
  font-size: 12px;
}

.trend-icon.up { color: #f5222d; margin-left: 4px; }
.trend-icon.down { color: #52c41a; margin-left: 4px; }

/* 图表区域样式 */
.charts-row {
  margin-bottom: 24px;
}

.chart-card {
  border-radius: 8px;
  height: 100%;
}

.chart-container {
  height: 300px;
  width: 100%;
}

/* 底部区域 */
.detail-card, .knowledge-card {
  border-radius: 8px;
  height: 100%;
}
</style>
