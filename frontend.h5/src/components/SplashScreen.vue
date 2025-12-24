<template>
  <div class="splash-screen" :class="{ 'fade-out': !visible }">
    <div class="splash-content">
      <div class="logo-container">
        <svg class="logo-svg" viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg">
          <g class="logo-group">
            <circle fill="#00aa01" cx="257.00" cy="28.00" r="23.13" />
            <circle fill="#00aa01" cx="95.28" cy="94.58" r="23.14" />
            <circle fill="#00aa01" cx="418.42" cy="95.28" r="23.14" />
            <circle fill="#00aa01" cx="256.50" cy="116.50" r="42.66" />
            <circle fill="#00aa01" cx="157.50" cy="157.51" r="42.66" />
            <circle fill="#00aa01" cx="355.49" cy="157.51" r="42.66" />
            <circle fill="#e4b801" cx="256.50" cy="256.50" r="72.65" class="center-circle" />
            <circle fill="#00aa01" cx="116.50" cy="256.50" r="42.66" />
            <circle fill="#00aa01" cx="396.50" cy="256.50" r="42.66" />
            <circle fill="#00aa01" cx="28.00" cy="256.00" r="23.13" />
            <circle fill="#00aa01" cx="485.00" cy="257.00" r="23.13" />
            <circle fill="#00aa01" cx="157.50" cy="355.50" r="42.66" />
            <circle fill="#00aa01" cx="355.49" cy="355.50" r="42.66" />
            <circle fill="#00aa01" cx="256.50" cy="396.50" r="42.66" />
            <circle fill="#00aa01" cx="94.58" cy="417.72" r="23.14" />
            <circle fill="#00aa01" cx="417.72" cy="418.42" r="23.14" />
            <circle fill="#00aa01" cx="256.00" cy="485.00" r="23.13" />
          </g>
        </svg>
      </div>
      <div class="text-container">
        <h1 class="app-title">综合信息管理系统</h1>
        <p class="app-subtitle">jinlan.info</p>
      </div>
    </div>
    
    <div class="background-decorations">
      <div class="circle c1"></div>
      <div class="circle c2"></div>
      <div class="line l1"></div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';

const props = defineProps({
  duration: {
    type: Number,
    default: 2000
  }
});

const emit = defineEmits(['finish']);
const visible = ref(true);

onMounted(() => {
  setTimeout(() => {
    visible.value = false;
    setTimeout(() => {
      emit('finish');
    }, 500); // Wait for fade out transition
  }, props.duration);
});
</script>

<style scoped>
.splash-screen {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: linear-gradient(to bottom, #ffffff 0%, #e8f5e9 100%);
  z-index: 9999;
  display: flex;
  justify-content: center;
  align-items: center;
  transition: opacity 0.5s ease-in-out;
  overflow: hidden;
}

.splash-screen.fade-out {
  opacity: 0;
  pointer-events: none;
}

.splash-content {
  z-index: 2;
  display: flex;
  flex-direction: column;
  align-items: center;
  transform: scale(0.8);
  opacity: 0;
  animation: content-in 0.8s ease-out forwards 0.2s;
}

@keyframes content-in {
  from {
    transform: scale(0.8) translateY(20px);
    opacity: 0;
  }
  to {
    transform: scale(1) translateY(0);
    opacity: 1;
  }
}

.logo-container {
  width: 120px;
  height: 120px;
  margin-bottom: 30px;
  animation: logo-float 3s ease-in-out infinite;
}

.logo-svg {
  width: 100%;
  height: 100%;
  filter: drop-shadow(0 4px 6px rgba(0,0,0,0.1));
}

.center-circle {
  animation: pulse 2s infinite;
  transform-origin: center;
  transform-box: fill-box;
}

@keyframes pulse {
  0% { transform: scale(1); }
  50% { transform: scale(1.1); }
  100% { transform: scale(1); }
}

@keyframes logo-float {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-10px); }
}

.text-container {
  text-align: center;
}

.app-title {
  font-size: 24px;
  font-weight: bold;
  color: #333;
  margin: 0 0 10px;
  letter-spacing: 2px;
}

.app-subtitle {
  font-size: 14px;
  color: #666;
  margin: 0;
  letter-spacing: 1px;
}

/* Background Decorations */
.background-decorations {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 1;
  pointer-events: none;
}

.circle {
  position: absolute;
  border-radius: 50%;
  border: 2px solid rgba(0, 170, 1, 0.05);
}

.c1 {
  width: 60vw;
  height: 60vw;
  top: -10%;
  left: -10%;
  animation: rotate 20s linear infinite;
  border-style: dashed;
}

.c2 {
  width: 80vw;
  height: 80vw;
  bottom: -20%;
  right: -20%;
  animation: rotate 30s linear infinite reverse;
}

.line {
  position: absolute;
  background: linear-gradient(90deg, transparent, rgba(0, 170, 1, 0.1), transparent);
  height: 1px;
  width: 100%;
}

.l1 {
  top: 30%;
  animation: slide-right 5s linear infinite;
}

@keyframes rotate {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

@keyframes slide-right {
  from { transform: translateX(-100%); }
  to { transform: translateX(100%); }
}
</style>
