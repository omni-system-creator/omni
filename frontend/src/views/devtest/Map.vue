<template>
  <div ref="container" class="map-container"></div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue';
import * as THREE from 'three';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';

const container = ref<HTMLElement | null>(null);

type Station = {
  name: string;
  line: string;
  lat: number;
  lon: number;
  value: number;
};

const stations: Station[] = [
  { line: '1号线', name: '升仙湖', lat: 30.704, lon: 104.066, value: 1200 },
  { line: '1号线', name: '火车北站', lat: 30.680, lon: 104.082, value: 2600 },
  { line: '1号线', name: '天府广场', lat: 30.658, lon: 104.065, value: 4200 },
  { line: '1号线', name: '金融城', lat: 30.573, lon: 104.071, value: 3800 },
  { line: '1号线', name: '五根松', lat: 30.525, lon: 104.071, value: 2400 },
  { line: '2号线', name: '犀浦', lat: 30.740, lon: 103.941, value: 1800 },
  { line: '2号线', name: '茶店子客运站', lat: 30.696, lon: 104.039, value: 2800 },
  { line: '2号线', name: '人民公园', lat: 30.661, lon: 104.061, value: 3600 },
  { line: '2号线', name: '春熙路', lat: 30.658, lon: 104.082, value: 4100 },
  { line: '2号线', name: '成都东客站', lat: 30.633, lon: 104.103, value: 3900 },
  { line: '7号线', name: '崇义桥', lat: 30.709, lon: 104.055, value: 1500 },
  { line: '7号线', name: '火车北站', lat: 30.680, lon: 104.082, value: 2600 },
  { line: '7号线', name: '太平园', lat: 30.624, lon: 104.026, value: 2200 },
  { line: '7号线', name: '火车南站', lat: 30.610, lon: 104.060, value: 3000 },
  { line: '7号线', name: '成渝立交', lat: 30.641, lon: 104.116, value: 2100 }
];

let scene: THREE.Scene | null = null;
let camera: THREE.PerspectiveCamera | null = null;
let renderer: THREE.WebGLRenderer | null = null;
let controls: OrbitControls | null = null;
let animationId: number | null = null;

const earthRadius = 50;

const latLonToVector3 = (lat: number, lon: number, radius: number) => {
  const phi = (90 - lat) * (Math.PI / 180);
  const theta = (lon + 180) * (Math.PI / 180);
  const x = -radius * Math.sin(phi) * Math.cos(theta);
  const z = radius * Math.sin(phi) * Math.sin(theta);
  const y = radius * Math.cos(phi);
  return new THREE.Vector3(x, y, z);
};

const createEarth = () => {
  if (!scene) return;
  const geometry = new THREE.SphereGeometry(earthRadius, 64, 64);
  const material = new THREE.MeshStandardMaterial({
    map: createMapTexture(),
    roughness: 0.6,
    metalness: 0.1
  });
  const earth = new THREE.Mesh(geometry, material);
  scene.add(earth);

  // Add atmosphere glow
  const atmosGeo = new THREE.SphereGeometry(earthRadius + 2, 64, 64);
  const atmosMat = new THREE.ShaderMaterial({
    vertexShader: `
      varying vec3 vNormal;
      void main() {
        vNormal = normalize(normalMatrix * normal);
        gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
      }
    `,
    fragmentShader: `
      varying vec3 vNormal;
      void main() {
        float intensity = pow(0.6 - dot(vNormal, vec3(0, 0, 1.0)), 4.0);
        gl_FragColor = vec4(0.3, 0.6, 1.0, 1.0) * intensity;
      }
    `,
    blending: THREE.AdditiveBlending,
    side: THREE.BackSide,
    transparent: true
  });
  const atmosphere = new THREE.Mesh(atmosGeo, atmosMat);
  scene.add(atmosphere);
};

// Procedural Map Texture
const createMapTexture = () => {
  const canvas = document.createElement('canvas');
  canvas.width = 2048;
  canvas.height = 1024;
  const ctx = canvas.getContext('2d');
  if (!ctx) return null;

  // Background (Ocean)
  ctx.fillStyle = '#001133';
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  // Grid Lines
  ctx.strokeStyle = '#1a3c6e';
  ctx.lineWidth = 1;
  
  // Longitude lines
  for (let i = 0; i <= 36; i++) {
    const x = (i * canvas.width) / 36;
    ctx.beginPath();
    ctx.moveTo(x, 0);
    ctx.lineTo(x, canvas.height);
    ctx.stroke();
  }
  
  // Latitude lines
  for (let i = 0; i <= 18; i++) {
    const y = (i * canvas.height) / 18;
    ctx.beginPath();
    ctx.moveTo(0, y);
    ctx.lineTo(canvas.width, y);
    ctx.stroke();
  }

  // Simple Continent Approximation (Noise-like)
  // For a real app, load a texture image. Here we just add some random noise to simulate land presence
  // or just keep it as a tech-style grid map.
  // Let's add some "tech" dots
  ctx.fillStyle = '#2a4c8e';
  for (let i = 0; i < 1000; i++) {
    const x = Math.random() * canvas.width;
    const y = Math.random() * canvas.height;
    const size = Math.random() * 2;
    ctx.fillRect(x, y, size, size);
  }

  const texture = new THREE.CanvasTexture(canvas);
  return texture;
};

const createStars = () => {
  if (!scene) return;
  const count = 3000;
  const positions = new Float32Array(count * 3);
  for (let i = 0; i < count; i++) {
    const r = 1000 + Math.random() * 2000;
    const theta = Math.random() * Math.PI * 2;
    const phi = Math.acos(2 * Math.random() - 1);
    positions[i * 3] = r * Math.sin(phi) * Math.cos(theta);
    positions[i * 3 + 1] = r * Math.sin(phi) * Math.sin(theta);
    positions[i * 3 + 2] = r * Math.cos(phi);
  }
  const geometry = new THREE.BufferGeometry();
  geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
  const material = new THREE.PointsMaterial({
    color: 0xffffff,
    size: 2,
    sizeAttenuation: true
  });
  const points = new THREE.Points(geometry, material);
  scene.add(points);
};

const createLinesAndStations = () => {
  const lines = new Map<string, Station[]>();
  stations.forEach(s => {
    const list = lines.get(s.line) || [];
    list.push(s);
    lines.set(s.line, list);
  });
  const lineColors: { [key: string]: number } = {
    '1号线': 0x1f78b4,
    '2号线': 0x33a02c,
    '7号线': 0xff7f00
  };
  lines.forEach((list, line) => {
    const sorted = [...list];
    const positions: number[] = [];
    sorted.forEach(station => {
      const linePos = latLonToVector3(station.lat, station.lon, earthRadius + 0.2);
      positions.push(linePos.x, linePos.y, linePos.z);

      const valueScale = THREE.MathUtils.clamp(station.value / 5000, 0.2, 1.2);
      const height = 8 * valueScale;
      const radius = 0.6 + 0.4 * valueScale;
      const geo = new THREE.CylinderGeometry(radius, radius, height, 12);
      const mat = new THREE.MeshStandardMaterial({
        color: lineColors[line] || 0xffffff,
        emissive: lineColors[line] || 0xffffff,
        emissiveIntensity: 0.8,
        metalness: 0.3,
        roughness: 0.4
      });

      if (!scene) return;
      const mesh = new THREE.Mesh(geo, mat);
      const surfacePos = latLonToVector3(station.lat, station.lon, earthRadius);
      const dir = surfacePos.clone().normalize();
      const up = new THREE.Vector3(0, 1, 0);

      mesh.quaternion.setFromUnitVectors(up, dir);
      mesh.position.copy(surfacePos.clone().add(dir.clone().multiplyScalar(height / 2)));

      scene.add(mesh);
    });

    if (positions.length >= 6) {
      const geo = new THREE.BufferGeometry();
      geo.setAttribute('position', new THREE.Float32BufferAttribute(positions, 3));
      const mat = new THREE.LineBasicMaterial({
        color: lineColors[line] || 0xffffff,
        linewidth: 2
      });
      if (scene) {
        const lineMesh = new THREE.Line(geo, mat);
        scene.add(lineMesh);
      }
    }
  });
};

const initScene = () => {
  if (!container.value) return;
  scene = new THREE.Scene();
  scene.background = new THREE.Color(0x000010);
  const width = container.value.clientWidth;
  const height = container.value.clientHeight;
  // 2. Camera Setup
  camera = new THREE.PerspectiveCamera(45, width / height, 0.1, 5000);
  
  // Position camera to look at Chengdu (Lat 30.6, Lon 104.0)
  // Chengdu Vector
  const targetLat = 30.6;
  const targetLon = 104.0;
  // Position slightly above Chengdu
  const camPos = latLonToVector3(targetLat, targetLon, earthRadius + 15);
  camera.position.copy(camPos);
  camera.lookAt(0, 0, 0);

  // 3. Renderer Setup
  renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
  renderer.setSize(width, height);
  renderer.setPixelRatio(window.devicePixelRatio);
  container.value.appendChild(renderer.domElement);
  const ambient = new THREE.AmbientLight(0xffffff, 0.6);
  scene.add(ambient);
  const dirLight = new THREE.DirectionalLight(0xffffff, 1.2);
  dirLight.position.set(100, 200, 100);
  dirLight.castShadow = true;
  scene.add(dirLight);
  createEarth();
  createStars();
  createLinesAndStations();
  // 4. Controls
  controls = new OrbitControls(camera, renderer.domElement);
  controls.enableDamping = true;
  controls.dampingFactor = 0.05;
  controls.minDistance = earthRadius + 2; // Allow zooming closer
  controls.maxDistance = earthRadius * 15;
  controls.enablePan = false; // Panning on sphere is weird, usually rotation is used
  controls.rotateSpeed = 0.5; // Slower rotation feels more like map panning
  controls.zoomSpeed = 1.2;
  controls.autoRotate = false; // Disable auto rotate for better control
  
  // Set controls target to 0,0,0 so we orbit around earth center
  controls.target.set(0, 0, 0);
  const onResize = () => {
    if (!container.value || !camera || !renderer) return;
    const w = container.value.clientWidth;
    const h = container.value.clientHeight;
    camera.aspect = w / h;
    camera.updateProjectionMatrix();
    renderer.setSize(w, h);
  };
  window.addEventListener('resize', onResize);
  const animate = () => {
    animationId = requestAnimationFrame(animate);
    controls && controls.update();
    renderer && camera && renderer.render(scene as THREE.Scene, camera);
  };
  animate();
};

onMounted(() => {
  initScene();
});

onUnmounted(() => {
  if (animationId) cancelAnimationFrame(animationId);
  if (renderer) {
    renderer.dispose();
    renderer.forceContextLoss();
  }
  if (scene) {
    const children = [...scene.children];
    children.forEach(obj => {
      scene && scene.remove(obj);
    });
  }
  scene = null;
  camera = null;
  renderer = null;
  controls = null;
});
</script>

<style scoped>
.map-container {
  width: 100%;
  height: 100vh;
  overflow: hidden;
  background-color: #000;
}
</style>
