<template>
  <div ref="container" class="three-container"></div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue';
import * as THREE from 'three';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';
import { EffectComposer } from 'three/examples/jsm/postprocessing/EffectComposer.js';
import { RenderPass } from 'three/examples/jsm/postprocessing/RenderPass.js';
import { UnrealBloomPass } from 'three/examples/jsm/postprocessing/UnrealBloomPass.js';

const container = ref<HTMLElement | null>(null);

// Scene variables
let scene: THREE.Scene;
let camera: THREE.PerspectiveCamera;
let renderer: THREE.WebGLRenderer;
let controls: OrbitControls;
let composer: EffectComposer;
let animationId: number;

// Objects
let mainCrystal: THREE.Mesh;
let rings: THREE.Group;
let particles: THREE.Points;

const init = () => {
  if (!container.value) return;

  // 1. Scene Setup
  scene = new THREE.Scene();
  // Create a procedural skybox using canvas (so we don't need external assets)
  generateSpaceSkybox();

  // 2. Camera Setup
  camera = new THREE.PerspectiveCamera(
    60,
    container.value.clientWidth / container.value.clientHeight,
    0.1,
    1000
  );
  camera.position.set(0, 5, 15);

  // 3. Renderer Setup
  renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
  renderer.setSize(container.value.clientWidth, container.value.clientHeight);
  renderer.setPixelRatio(window.devicePixelRatio);
  renderer.toneMapping = THREE.ReinhardToneMapping;
  container.value.appendChild(renderer.domElement);

  // 4. Controls
  controls = new OrbitControls(camera, renderer.domElement);
  controls.enableDamping = true;
  controls.dampingFactor = 0.05;
  controls.autoRotate = true;
  controls.autoRotateSpeed = 0.5;

  // 5. Lighting
  const ambientLight = new THREE.AmbientLight(0x404040, 2);
  scene.add(ambientLight);

  const pointLight1 = new THREE.PointLight(0x00ffff, 2, 50);
  pointLight1.position.set(10, 10, 10);
  scene.add(pointLight1);

  const pointLight2 = new THREE.PointLight(0xff00ff, 2, 50);
  pointLight2.position.set(-10, -10, -10);
  scene.add(pointLight2);

  // 6. Objects
  createMainCrystal();
  createRings();
  createFloatingParticles();

  // 7. Post-processing (Bloom)
  const renderScene = new RenderPass(scene, camera);
  const bloomPass = new UnrealBloomPass(
    new THREE.Vector2(container.value.clientWidth, container.value.clientHeight),
    1.5, // strength
    0.4, // radius
    0.85 // threshold
  );

  composer = new EffectComposer(renderer);
  composer.addPass(renderScene);
  composer.addPass(bloomPass);

  // Resize listener
  window.addEventListener('resize', onWindowResize);
  
  // Start animation loop
  animate();
};

const generateSpaceSkybox = () => {
  // Generate a simple space skybox using 2D Canvas
  const loader = new THREE.CubeTextureLoader();
  
  const canvases: HTMLCanvasElement[] = [];
  
  for (let i = 0; i < 6; i++) {
    const canvas = document.createElement('canvas');
    canvas.width = 1024;
    canvas.height = 1024;
    const ctx = canvas.getContext('2d')!;
    
    // Deep space background gradient
    const gradient = ctx.createRadialGradient(512, 512, 0, 512, 512, 800);
    gradient.addColorStop(0, '#0b1026'); // Dark blue center
    gradient.addColorStop(1, '#000000'); // Black edges
    
    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, 1024, 1024);
    
    // Draw random stars
    for (let j = 0; j < 500; j++) {
      const x = Math.random() * 1024;
      const y = Math.random() * 1024;
      const size = Math.random() * 2;
      const opacity = Math.random();
      
      ctx.fillStyle = `rgba(255, 255, 255, ${opacity})`;
      ctx.beginPath();
      ctx.arc(x, y, size, 0, Math.PI * 2);
      ctx.fill();
    }
    
    // Draw some nebula clouds
    for (let j = 0; j < 20; j++) {
      const x = Math.random() * 1024;
      const y = Math.random() * 1024;
      const r = Math.random() * 200 + 50;
      
      const g = ctx.createRadialGradient(x, y, 0, x, y, r);
      const color = Math.random() > 0.5 ? '100, 0, 255' : '0, 200, 255'; // Purple or Cyan
      g.addColorStop(0, `rgba(${color}, 0.1)`);
      g.addColorStop(1, 'rgba(0,0,0,0)');
      
      ctx.fillStyle = g;
      ctx.beginPath();
      ctx.arc(x, y, r, 0, Math.PI * 2);
      ctx.fill();
    }
    
    canvases.push(canvas);
  }

  // Convert canvases to data URLs
  const urls = canvases.map(c => c.toDataURL());
  
  const textureCube = loader.load(urls);
  scene.background = textureCube;
};

const createMainCrystal = () => {
  // Icosahedron with glass-like material
  const geometry = new THREE.IcosahedronGeometry(3, 1);
  const material = new THREE.MeshPhysicalMaterial({
    color: 0xffffff,
    metalness: 0.1,
    roughness: 0.1,
    transmission: 0.9, // Glass-like
    thickness: 1.0,
    ior: 1.5,
    clearcoat: 1.0,
    clearcoatRoughness: 0.1,
  });

  mainCrystal = new THREE.Mesh(geometry, material);
  scene.add(mainCrystal);

  // Inner core geometry to make it look more interesting
  const coreGeo = new THREE.OctahedronGeometry(1.5);
  const coreMat = new THREE.MeshBasicMaterial({ 
    color: 0x00ffff,
    wireframe: true 
  });
  const core = new THREE.Mesh(coreGeo, coreMat);
  mainCrystal.add(core);
};

const createRings = () => {
  rings = new THREE.Group();
  
  const geometry = new THREE.TorusGeometry(5, 0.1, 16, 100);
  const material = new THREE.MeshBasicMaterial({ color: 0x00ffff, transparent: true, opacity: 0.5 });
  
  const ring1 = new THREE.Mesh(geometry, material);
  ring1.rotation.x = Math.PI / 2;
  rings.add(ring1);

  const ring2 = new THREE.Mesh(geometry, material);
  ring2.rotation.x = Math.PI / 2;
  ring2.rotation.y = Math.PI / 4;
  ring2.scale.set(1.2, 1.2, 1.2);
  rings.add(ring2);

  const ring3 = new THREE.Mesh(geometry, material);
  ring3.rotation.x = Math.PI / 2;
  ring3.rotation.y = -Math.PI / 4;
  ring3.scale.set(1.4, 1.4, 1.4);
  rings.add(ring3);

  scene.add(rings);
};

const createFloatingParticles = () => {
  const geometry = new THREE.BufferGeometry();
  const count = 2000;
  
  const positions = new Float32Array(count * 3);
  const colors = new Float32Array(count * 3);
  
  const color1 = new THREE.Color(0x00ffff);
  const color2 = new THREE.Color(0xff00ff);

  for (let i = 0; i < count; i++) {
    // Random position in a sphere
    const r = 20 + Math.random() * 30;
    const theta = Math.random() * Math.PI * 2;
    const phi = Math.acos(2 * Math.random() - 1);
    
    positions[i * 3] = r * Math.sin(phi) * Math.cos(theta);
    positions[i * 3 + 1] = r * Math.sin(phi) * Math.sin(theta);
    positions[i * 3 + 2] = r * Math.cos(phi);

    // Mix colors
    const mixedColor = color1.clone().lerp(color2, Math.random());
    colors[i * 3] = mixedColor.r;
    colors[i * 3 + 1] = mixedColor.g;
    colors[i * 3 + 2] = mixedColor.b;
  }
  
  geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
  geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));
  
  const material = new THREE.PointsMaterial({
    size: 0.2,
    vertexColors: true,
    transparent: true,
    opacity: 0.8,
    blending: THREE.AdditiveBlending
  });
  
  particles = new THREE.Points(geometry, material);
  scene.add(particles);
};

const onWindowResize = () => {
  if (!container.value) return;
  
  camera.aspect = container.value.clientWidth / container.value.clientHeight;
  camera.updateProjectionMatrix();
  
  renderer.setSize(container.value.clientWidth, container.value.clientHeight);
  composer.setSize(container.value.clientWidth, container.value.clientHeight);
};

const animate = () => {
  animationId = requestAnimationFrame(animate);
  
  controls.update();
  
  const time = Date.now() * 0.001;
  
  // Rotate crystal
  if (mainCrystal) {
    mainCrystal.rotation.y = time * 0.2;
    mainCrystal.rotation.z = time * 0.1;
  }
  
  // Rotate rings
  if (rings) {
    rings.rotation.x = Math.sin(time * 0.5) * 0.2;
    rings.rotation.y = time * 0.1;
  }
  
  // Rotate particles
  if (particles) {
    particles.rotation.y = -time * 0.05;
  }
  
  // Render via composer for post-processing
  composer.render();
};

onMounted(() => {
  init();
});

onUnmounted(() => {
  if (animationId) cancelAnimationFrame(animationId);
  window.removeEventListener('resize', onWindowResize);
  
  // Cleanup Three.js resources
  if (renderer) {
    renderer.dispose();
    renderer.forceContextLoss();
  }
  if (scene) {
    scene.clear();
  }
  // Dispose geometries and materials if needed (simplified here)
});
</script>

<style scoped>
.three-container {
  width: 100%;
  height: 100vh;
  overflow: hidden;
  background-color: #000;
}
</style>
