<template>
  <div class="supplier-analysis">
    <a-card title="供应商投标文件分析" :bordered="false">
      <div class="upload-section">
        <a-upload-dragger
          name="file"
          :multiple="true"
          :file-list="fileList"
          @change="handleUpload"
          :before-upload="beforeUpload"
        >
          <p class="ant-upload-drag-icon">
            <InboxOutlined />
          </p>
          <p class="ant-upload-text">点击或拖拽上传多家供应商投标文件</p>
          <p class="ant-upload-hint">支持 PDF, Word 格式，上传后自动进行查重和串标分析</p>
        </a-upload-dragger>
      </div>

      <div class="actions" style="margin: 20px 0; text-align: center;">
         <a-button type="primary" size="large" @click="startAnalysis" :loading="analyzing" :disabled="fileList.length < 2">
           <SafetyCertificateOutlined /> 开始智能分析 (串标/围标检测)
         </a-button>
      </div>

      <div v-if="analysisResult" class="result-section">
        <a-tabs>
          <a-tab-pane key="1" tab="风险预警">
             <a-alert
                message="发现高风险项"
                description="经AI分析，供应商A与供应商C的投标文件在技术参数部分存在高度雷同，且文档作者元数据一致。"
                type="error"
                show-icon
                style="margin-bottom: 20px"
             />
             <a-table :columns="riskColumns" :data-source="analysisResult.risks" row-key="id" />
          </a-tab-pane>
          
          <a-tab-pane key="2" tab="串标特征分析">
             <a-row :gutter="16">
               <a-col :span="12">
                 <a-card title="文档相似度矩阵" size="small">
                    <!-- Placeholder for Matrix Visualization -->
                    <div class="similarity-matrix">
                        <div v-for="(row, rIndex) in analysisResult.matrix" :key="rIndex" class="matrix-row">
                           <div v-for="(cell, cIndex) in row" :key="cIndex" 
                                class="matrix-cell"
                                :style="{ backgroundColor: getCellColor(cell) }">
                                {{ cell }}%
                           </div>
                        </div>
                    </div>
                    <div style="text-align: center; margin-top: 10px; color: #666;">
                        (行/列对应供应商列表，颜色越深相似度越高)
                    </div>
                 </a-card>
               </a-col>
               <a-col :span="12">
                 <a-card title="关键特征提取" size="small">
                   <a-list item-layout="horizontal" :data-source="analysisResult.features">
                      <template #renderItem="{ item }">
                        <a-list-item>
                          <a-list-item-meta
                            :description="item.description"
                          >
                            <template #title>
                              <a-tag color="red" v-if="item.riskLevel === 'high'">高危</a-tag>
                              <a-tag color="orange" v-else>警告</a-tag>
                              {{ item.title }}
                            </template>
                          </a-list-item-meta>
                        </a-list-item>
                      </template>
                   </a-list>
                 </a-card>
               </a-col>
             </a-row>
          </a-tab-pane>
          
          <a-tab-pane key="3" tab="分析报告">
             <div class="report-preview">
                <h3>项目招投标合规性分析报告</h3>
                <p><strong>生成时间：</strong> {{ new Date().toLocaleString() }}</p>
                <p><strong>分析结论：</strong> 疑似存在串标行为。</p>
                <a-button type="primary">下载完整PDF报告</a-button>
             </div>
          </a-tab-pane>
        </a-tabs>
      </div>
    </a-card>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { InboxOutlined, SafetyCertificateOutlined } from '@ant-design/icons-vue';
import type { UploadChangeParam } from 'ant-design-vue';

const fileList = ref<any[]>([]);
const analyzing = ref(false);
const analysisResult = ref<any>(null);

const handleUpload = (info: UploadChangeParam) => {
  fileList.value = [...info.fileList];
};

const beforeUpload = () => {
  return false; // Prevent auto upload, manual trigger
};

const startAnalysis = () => {
  analyzing.value = true;
  // Mock analysis process
  setTimeout(() => {
    analyzing.value = false;
    analysisResult.value = {
      risks: [
        { id: 1, supplier: '江苏科技信息有限公司', type: '文档属性', content: '文档创建作者与"浙江智汇网络"一致', level: '高' },
        { id: 2, supplier: '所有供应商', type: '报价规律', content: '报价呈等差数列分布', level: '中' },
        { id: 3, supplier: '上海数据服务商', type: '标书内容', content: '技术方案页出现非本项目名称', level: '低' }
      ],
      matrix: [
        [100, 15, 85, 10],
        [15, 100, 12, 8],
        [85, 12, 100, 9],
        [10, 8, 9, 100]
      ],
      features: [
        { title: 'MAC地址一致', description: '检测到三家供应商上传标书的设备MAC地址相同', riskLevel: 'high' },
        { title: 'IP地址相同', description: '投标文件上传IP地址均为 114.23.xx.xx', riskLevel: 'high' },
        { title: '错别字雷同', description: '在第4章第2节发现相同的罕见错别字', riskLevel: 'high' }
      ]
    };
  }, 2500);
};

const riskColumns = [
  { title: '涉及供应商', dataIndex: 'supplier', key: 'supplier' },
  { title: '预警类型', dataIndex: 'type', key: 'type' },
  { title: '详细内容', dataIndex: 'content', key: 'content' },
  { title: '风险等级', dataIndex: 'level', key: 'level' }
];

const getCellColor = (value: number) => {
  if (value === 100) return '#eee'; // Self
  if (value > 80) return '#ffccc7'; // High similarity
  if (value > 50) return '#fff7e6'; // Medium
  return '#f6ffed'; // Low
};
</script>

<style scoped>
.supplier-analysis {
  min-height: 500px;
}
.upload-section {
  margin-bottom: 20px;
}
.similarity-matrix {
  display: flex;
  flex-direction: column;
  gap: 2px;
}
.matrix-row {
  display: flex;
  gap: 2px;
}
.matrix-cell {
  width: 50px;
  height: 50px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  border: 1px solid #f0f0f0;
}
.report-preview {
  padding: 20px;
  background: #f9f9f9;
  border: 1px solid #ddd;
  text-align: center;
}
</style>
