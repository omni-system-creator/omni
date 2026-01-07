<template>
  <div v-if="rules.length > 0" class="rules-grid">
    <div v-for="rule in rules" :key="rule.id" class="rule-card">
      <div class="rule-header">
        <h3>{{ rule.title }}</h3>
      </div>
      <div class="rule-content-wrapper">
        <div class="rule-content" v-html="formatContent(rule.content)"></div>
      </div>
    </div>
  </div>
  <div class="process-rules-empty" v-else>
    <a-spin :spinning="true" size="large" />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import type { ProcessRuleDto } from '@/api/sales';
import { getProcessRules } from '@/api/sales';

const rules = ref<ProcessRuleDto[]>([]);

const loadData = async () => {
  try {
    rules.value = await getProcessRules();
  } catch (e) {
    console.error('加载流程规则失败:', e);
  }
};

onMounted(() => {
  loadData();
});

const formatContent = (content: string) => {
  // 将1.、2.、3.等开头的行换行显示，但第一个编号前不加<br>
  const lines = content.split('\n').map(line => line.trim()).filter(line => line);
  return lines.map((line, index) => {
    if (index === 0) return line;
    return line.replace(/^(\d+\.)/, '<br>$1');
  }).join('');
};
</script>

<style scoped>
.rules-grid {
  padding: 16px;
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: 16px;
}

@media (min-width: 1200px) {
  .rules-grid {
    grid-template-columns: repeat(3, 1fr);
  }
}

@media (min-width: 768px) and (max-width: 1199px) {
  .rules-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 767px) {
  .rules-grid {
    grid-template-columns: 1fr;
  }
}

.rule-card {
  border: 1px solid #e8e8e8;
  border-radius: 8px;
  background: #fff;
  overflow: hidden;
  transition: box-shadow 0.3s;
}

.rule-card:hover {
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.rule-header {
  display: flex;
  align-items: center;
  padding: 16px;
  background: #f5f5f5;
  border-bottom: 1px solid #e8e8e8;
}

.rule-header h3 {
  margin: 0;
  font-size: 16px;
  font-weight: 500;
}

.rule-content-wrapper {
  padding: 16px;
}

.rule-content {
  margin: 0;
  line-height: 1.6;
  white-space: pre-wrap;
}

.process-rules-empty {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 200px;
}
</style>
