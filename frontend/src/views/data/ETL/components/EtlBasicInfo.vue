<template>
  <a-form layout="vertical" :model="formState">
    <a-form-item label="任务名称" required>
      <a-input v-model:value="formState.name" placeholder="例如：每日销售数据汇总" />
    </a-form-item>
    <a-form-item label="调度策略 (Cron表达式)" required>
      <a-input v-model:value="formState.cron" placeholder="0 0 1 * * ? (每天凌晨1点)" />
      <div class="form-tip">支持标准的 Cron 表达式配置自动化运行频率</div>
    </a-form-item>
    <a-form-item label="描述">
      <a-textarea v-model:value="formState.desc" :rows="3" />
    </a-form-item>
    <a-form-item label="告警通知">
      <a-checkbox-group v-model:value="formState.notifications">
        <a-checkbox value="email">邮件通知</a-checkbox>
        <a-checkbox value="dingtalk">钉钉/企微</a-checkbox>
      </a-checkbox-group>
    </a-form-item>
  </a-form>
</template>

<script setup lang="ts">
// import { defineProps } from 'vue'; // defineProps is a compiler macro and doesn't need to be imported

defineProps<{
  formState: {
    name: string;
    cron: string;
    desc: string;
    notifications: string[];
  }
}>();
</script>

<style scoped>
.form-tip {
  font-size: 12px;
  color: #999;
  margin-top: 4px;
}
</style>
