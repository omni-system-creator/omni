<template>
  <div class="page-container">
    <div class="search-bar">
      <a-input-search
        v-model:value="searchQuery"
        placeholder="输入物品编码 / 批次号 / 序列号"
        enter-button="开始跟踪"
        size="large"
        @search="onSearch"
        style="max-width: 600px"
      />
    </div>

    <div v-if="currentProduct" class="track-content">
      <!-- 物品基本信息 -->
      <a-descriptions title="物品档案" bordered :column="3" style="background: #fff; padding: 16px; margin-bottom: 16px">
        <a-descriptions-item label="物品编码">{{ currentProduct.code }}</a-descriptions-item>
        <a-descriptions-item label="物品名称">{{ currentProduct.name }}</a-descriptions-item>
        <a-descriptions-item label="规格型号">{{ currentProduct.spec }}</a-descriptions-item>
        <a-descriptions-item label="当前总库存"><span style="color: #1890ff; font-weight: bold">{{ currentProduct.totalStock }}</span> {{ currentProduct.unit }}</a-descriptions-item>
        <a-descriptions-item label="锁定/占用">
          <a-tooltip title="因销售订单或领料任务被锁定的库存">
            <span style="color: #faad14">{{ currentProduct.lockedStock }}</span> {{ currentProduct.unit }}
          </a-tooltip>
        </a-descriptions-item>
        <a-descriptions-item label="可用库存"><span style="color: #52c41a">{{ currentProduct.totalStock - currentProduct.lockedStock }}</span> {{ currentProduct.unit }}</a-descriptions-item>
      </a-descriptions>

      <a-row :gutter="16">
        <!-- 库存分布 -->
        <a-col :span="14">
          <a-card title="库存分布详情" :bordered="false" class="mb-16">
            <a-table :columns="distributionColumns" :data-source="distributionData" size="small" :pagination="false">
              <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'status'">
                  <a-badge :status="record.status === 'normal' ? 'success' : 'warning'" :text="record.status === 'normal' ? '良品' : '待检/不良'" />
                </template>
              </template>
            </a-table>
          </a-card>
        </a-col>

        <!-- 批次/序列号追踪 -->
        <a-col :span="10">
          <a-card title="批次/序列号信息" :bordered="false" class="mb-16">
             <a-list item-layout="horizontal" :data-source="lotData">
              <template #renderItem="{ item }">
                <a-list-item>
                  <a-list-item-meta
                    :description="`生产日期: ${item.prodDate} | 过期日期: ${item.expDate}`"
                  >
                    <template #title>
                      <span>批次号: {{ item.lotNo }}</span>
                      <a-tag v-if="item.daysLeft < 30" color="red" style="margin-left: 8px">临期 (剩{{ item.daysLeft }}天)</a-tag>
                    </template>
                  </a-list-item-meta>
                  <div>库存: {{ item.qty }}</div>
                </a-list-item>
              </template>
            </a-list>
          </a-card>
        </a-col>
      </a-row>

      <!-- 全生命周期流转记录 -->
      <a-card title="流转全链路追踪" :bordered="false">
        <a-steps progress-dot :current="historyData.length - 1" direction="vertical">
          <a-step v-for="item in historyData" :key="item.id" :title="item.action" :sub-title="item.time">
            <template #description>
              <div>
                <p style="margin: 0">单号: <a>{{ item.docNo }}</a></p>
                <p style="margin: 0">{{ item.desc }}</p>
                <p style="margin: 0; color: #999">操作人: {{ item.operator }} | {{ item.warehouse }}</p>
              </div>
            </template>
          </a-step>
        </a-steps>
      </a-card>
    </div>

    <div v-else-if="searched" class="empty-state">
      <a-empty description="未找到相关物品或批次信息" />
    </div>
    
    <div v-else class="empty-state">
      <div style="text-align: center; color: #999; margin-top: 100px">
        <p>请输入物品编码、名称、批次号或序列号进行全链路跟踪</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';

const searchQuery = ref('');
const searched = ref(false);
const currentProduct = ref<any>(null);

const onSearch = () => {
  searched.value = true;
  // Mock search result
  if (searchQuery.value) {
    currentProduct.value = {
      code: 'M001',
      name: '304不锈钢板',
      spec: '2mm*1000mm*2000mm',
      unit: '张',
      totalStock: 150,
      lockedStock: 20,
    };
  } else {
    currentProduct.value = null;
  }
};

const distributionColumns = [
  { title: '仓库', dataIndex: 'warehouse', key: 'warehouse' },
  { title: '库区/库位', dataIndex: 'location', key: 'location' },
  { title: '批次号', dataIndex: 'lotNo', key: 'lotNo' },
  { title: '数量', dataIndex: 'qty', key: 'qty' },
  { title: '质量状态', dataIndex: 'status', key: 'status' },
];

const distributionData = [
  { warehouse: '上海主仓库', location: 'A区-01-01', lotNo: 'LOT20251101', qty: 50, status: 'normal' },
  { warehouse: '上海主仓库', location: 'A区-01-02', lotNo: 'LOT20251201', qty: 80, status: 'normal' },
  { warehouse: '虚拟退货仓', location: '暂存区', lotNo: 'LOT20251101', qty: 20, status: 'defect' },
];

const lotData = [
  { lotNo: 'LOT20251101', prodDate: '2025-11-01', expDate: '2026-11-01', daysLeft: 315, qty: 70 },
  { lotNo: 'LOT20251201', prodDate: '2025-12-01', expDate: '2026-12-01', daysLeft: 345, qty: 80 },
];

const historyData = [
  { id: 1, action: '采购入库', time: '2025-11-05 10:00', docNo: 'IN20251105001', desc: '供应商XX送货，入库50张', operator: '张三', warehouse: '上海主仓库' },
  { id: 2, action: '生产领料', time: '2025-11-10 14:30', docNo: 'OUT20251110002', desc: '生产工单WO001领料10张', operator: '李四', warehouse: '上海主仓库' },
  { id: 3, action: '销售退货', time: '2025-12-20 09:15', docNo: 'IN20251220002', desc: '客户退回20张 (质量问题)', operator: '王五', warehouse: '虚拟退货仓' },
  { id: 4, action: '库存移库', time: '2025-12-21 11:00', docNo: 'TR20251221001', desc: '整理库位，从A-01-01移至A-01-02', operator: '赵六', warehouse: '上海主仓库' },
];
</script>

<style scoped>
.page-container {
  padding: 24px;
  background: #f0f2f5;
  min-height: 100%;
}
.search-bar {
  text-align: center;
  margin-bottom: 24px;
}
.track-content {
  max-width: 1200px;
  margin: 0 auto;
}
.mb-16 {
  margin-bottom: 16px;
}
.empty-state {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 400px;
}
</style>