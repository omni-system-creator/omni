<template>
  <div class="office-supplies-container">
    <a-row :gutter="16">
      <!-- Left: Supply List -->
      <a-col :span="16">
        <a-card title="库存列表" :bordered="false">
          <template #extra>
            <a-space>
              <a-input-search placeholder="搜索物品" style="width: 200px" />
              <a-button type="primary">
                <template #icon><PlusOutlined /></template>
                新增品类
              </a-button>
            </a-space>
          </template>

          <a-table 
            :columns="columns" 
            :data-source="data" 
            :pagination="pagination"
            row-key="id"
          >
            <template #bodyCell="{ column, record }">
              <template v-if="column.key === 'stock'">
                <span :class="{ 'low-stock': record.stock <= record.minStock }">
                  {{ record.stock }} {{ record.unit }}
                </span>
                <a-tag color="red" v-if="record.stock <= record.minStock" style="margin-left: 8px">库存不足</a-tag>
              </template>
              
              <template v-if="column.key === 'action'">
                <a-space>
                  <a @click="handleInStock(record)">入库</a>
                  <a @click="handleOutStock(record)">领用</a>
                  <a-divider type="vertical" />
                  <a @click="handleEdit(record)">编辑</a>
                </a-space>
              </template>
            </template>
          </a-table>
        </a-card>
      </a-col>

      <!-- Right: Recent Logs & Quick Stats -->
      <a-col :span="8">
        <a-card title="待办事项" :bordered="false" style="margin-bottom: 16px">
          <a-list item-layout="horizontal" :data-source="todos">
            <template #renderItem="{ item }">
              <a-list-item>
                <a-list-item-meta :description="item.desc">
                  <template #title>
                    <span style="color: #ff4d4f" v-if="item.type === 'alert'">[预警] {{ item.title }}</span>
                    <span v-else>{{ item.title }}</span>
                  </template>
                </a-list-item-meta>
                <template #actions>
                  <a v-if="item.type === 'alert'">去采购</a>
                  <a v-else>查看</a>
                </template>
              </a-list-item>
            </template>
          </a-list>
        </a-card>

        <a-card title="最近领用记录" :bordered="false">
          <a-timeline>
            <a-timeline-item color="green">
              <p>张三 领用了 A4纸 2包</p>
              <p style="font-size: 12px; color: #999">10分钟前</p>
            </a-timeline-item>
            <a-timeline-item color="green">
              <p>李四 领用了 黑色签字笔 5支</p>
              <p style="font-size: 12px; color: #999">1小时前</p>
            </a-timeline-item>
            <a-timeline-item color="blue">
              <p>行政部 入库 电池(5号) 50节</p>
              <p style="font-size: 12px; color: #999">昨天 16:00</p>
            </a-timeline-item>
             <a-timeline-item color="green">
              <p>王五 领用了 笔记本 1本</p>
              <p style="font-size: 12px; color: #999">昨天 14:30</p>
            </a-timeline-item>
          </a-timeline>
        </a-card>
      </a-col>
    </a-row>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { PlusOutlined } from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';

const columns = [
  { title: '物品名称', dataIndex: 'name', key: 'name' },
  { title: '规格', dataIndex: 'spec', key: 'spec' },
  { title: '当前库存', dataIndex: 'stock', key: 'stock' },
  { title: '安全库存', dataIndex: 'minStock', key: 'minStock' },
  { title: '操作', key: 'action', width: 180 }
];

const data = ref([
  { id: 1, name: 'A4 打印纸', spec: '80g/500张/包', stock: 5, unit: '包', minStock: 10 },
  { id: 2, name: '黑色签字笔', spec: '0.5mm', stock: 45, unit: '支', minStock: 20 },
  { id: 3, name: '笔记本', spec: 'A5/软面', stock: 12, unit: '本', minStock: 5 },
  { id: 4, name: '电池(5号)', spec: '碱性', stock: 8, unit: '节', minStock: 10 },
  { id: 5, name: '屏幕清洁套装', spec: '200ml+布', stock: 3, unit: '套', minStock: 5 },
  { id: 6, name: '订书钉', spec: '12#', stock: 20, unit: '盒', minStock: 5 }
]);

const todos = ref([
  { title: '库存不足提醒', desc: 'A4纸、屏幕清洁套装库存低于安全线', type: 'alert' },
  { title: '月度盘点计划', desc: '本月底需要进行耗材盘点', type: 'info' }
]);

const pagination = {
  pageSize: 10
};

const handleInStock = (record: any) => message.success(`${record.name} 入库操作`);
const handleOutStock = (record: any) => message.success(`${record.name} 领用操作`);
const handleEdit = (record: any) => message.info(`编辑: ${record.name}`);
</script>

<style scoped>
.office-supplies-container {
  padding: 16px;
  background-color: #f0f2f5;
  min-height: 100%;
}
.low-stock {
  color: #cf1322;
  font-weight: bold;
}
</style>