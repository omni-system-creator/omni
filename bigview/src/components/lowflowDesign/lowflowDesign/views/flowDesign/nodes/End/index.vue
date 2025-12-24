<script setup lang="ts">
import { ElText } from 'element-plus';
</script>

<template>
  <div class="node-box">
    <el-text class="end-node">
      结束
    </el-text>
  </div>
</template>

<style scoped >
.node-box {
  padding: 0 50px 50px;
  position: relative;
  display: flex;
  flex-direction: column;
  cursor: pointer;

  
}
.end-node {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 50px;
    height: 50px;
    border-radius: 50%;
    font-size: 17px;
    box-shadow: var(--el-box-shadow-light);
    background-color: var(--el-color-primary);

    
  }
  .end-node:hover {
      box-shadow: 0 0 5px 0 var(--el-color-primary);
    }
</style>
