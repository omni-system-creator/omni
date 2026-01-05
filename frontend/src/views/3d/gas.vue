<template>
  <div class="gas-station-container">
    <div ref="canvasContainer" class="canvas-container"></div>
    
    <!-- UI Overlay -->
    <div class="ui-overlay">
      <div class="panel info-panel">
        <h2>燃气站数字孪生 (演示)</h2>
        <p>位置：新疆克拉玛依 (45.603°N, 84.886°E)</p>
        <p>占地面积：约50亩 | 设施：LNG储罐区、加气岛、综合楼</p>
        <div class="controls-guide">
          <div class="mode-switch">
            <a-radio-group v-model:value="viewMode" button-style="solid">
              <a-radio-button value="orbit">上帝视角 (Orbit)</a-radio-button>
              <a-radio-button value="roam">漫游模式 (WASD)</a-radio-button>
            </a-radio-group>
            <a-button type="primary" ghost size="small" style="margin-left: 10px" @click="flyToSpace" v-if="viewMode === 'orbit'">
              🚀 太空视角
            </a-button>
          </div>
          <p v-if="viewMode === 'orbit'">操作：左键旋转 / 右键平移 / 滚轮缩放 (可至太空)</p>
          <p v-else>操作：W/A/S/D 移动 / Shift 加速 / 鼠标转向</p>
        </div>
      </div>
      
      <div class="panel status-panel">
        <div class="stat-item">
          <span class="label">当前帧率</span>
          <span class="value">{{ fps }} FPS</span>
        </div>
        <div class="stat-item">
          <span class="label">渲染对象</span>
          <span class="value">{{ objectCount }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted, watch } from 'vue';
import * as THREE from 'three';
import { MapControls } from 'three/examples/jsm/controls/MapControls.js';
// import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'; // Import OrbitControls base type
import { PointerLockControls } from 'three/examples/jsm/controls/PointerLockControls.js';

// --- State ---
const canvasContainer = ref<HTMLElement | null>(null);
const viewMode = ref<'orbit' | 'roam'>('orbit');
const fps = ref(60);
const objectCount = ref(0);

// --- Three.js Variables ---
let scene: THREE.Scene;
let camera: THREE.PerspectiveCamera;
let renderer: THREE.WebGLRenderer;
let orbitControls: MapControls;
let roamControls: PointerLockControls;
let animationId: number;
let clock: THREE.Clock;

// Roaming State
const moveState = {
  forward: false,
  backward: false,
  left: false,
  right: false,
  run: false
};
const velocity = new THREE.Vector3();
const direction = new THREE.Vector3();

// --- Constants ---
const LOCATION = {
  name: '新疆克拉玛依',
  lat: 45.603,
  lon: 84.886,
  zoom: 16
};

// --- Initialization ---
const initScene = () => {
  if (!canvasContainer.value) return;

  // 1. Scene
  scene = new THREE.Scene();
  scene.background = new THREE.Color(0x000000); // Space black

  // 2. Camera
  const width = canvasContainer.value.clientWidth;
  const height = canvasContainer.value.clientHeight;
  // Use huge far plane for Earth view
  camera = new THREE.PerspectiveCamera(60, width / height, 0.1, 100000000);
  camera.position.set(0, 50, 100);

  // 3. Renderer
  // logarithmicDepthBuffer is essential for mixing huge scales (Earth) and small scales (Bolts)
  renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true, logarithmicDepthBuffer: true });
  renderer.setSize(width, height);
  renderer.setPixelRatio(window.devicePixelRatio);
  renderer.shadowMap.enabled = true;
  renderer.shadowMap.type = THREE.PCFSoftShadowMap;
  canvasContainer.value.appendChild(renderer.domElement);

  // 4. Lighting
  setupLighting();

  // 5. Environment (Earth & Space)
  createEarth();
  // Keep local high-res ground for "P6 precision" feel near the station
  createRealWorldGround();

  // 6. Facility (Tanks, Buildings)
  createFacility();

  // 7. Controls
  setupControls();

  // 8. Clock
  clock = new THREE.Clock();

  // 9. Resize Handler
  window.addEventListener('resize', onWindowResize);
  
  // 10. Start Loop
  animate();
};

const setupLighting = () => {
  // Ambient
  const ambientLight = new THREE.AmbientLight(0xffffff, 0.5);
  scene.add(ambientLight);

  // Directional (Sun)
  const sunLight = new THREE.DirectionalLight(0xffffff, 1.2);
  // Position sun based on approximate lat/lon/time (simplified)
  sunLight.position.set(100, 300, 150);
  sunLight.castShadow = true;
  
  // Shadow properties for large area
  sunLight.shadow.mapSize.width = 4096;
  sunLight.shadow.mapSize.height = 4096;
  sunLight.shadow.camera.near = 0.5;
  sunLight.shadow.camera.far = 1000;
  const shadowSize = 300;
  sunLight.shadow.camera.left = -shadowSize;
  sunLight.shadow.camera.right = shadowSize;
  sunLight.shadow.camera.top = shadowSize;
  sunLight.shadow.camera.bottom = -shadowSize;
  sunLight.shadow.bias = -0.0001;
  
  scene.add(sunLight);
};

// --- Tile Logic ---
const long2tile = (lon: number, zoom: number) => {
  return (Math.floor((lon + 180) / 360 * Math.pow(2, zoom)));
}

const lat2tile = (lat: number, zoom: number) => {
  return (Math.floor((1 - Math.log(Math.tan(lat * Math.PI / 180) + 1 / Math.cos(lat * Math.PI / 180)) / Math.PI) / 2 * Math.pow(2, zoom)));
}

const getTileUrl = (x: number, y: number, z: number) => {
  // Use local tiles if available (for the main area), otherwise fallback to online
  // We downloaded zoom 16 tiles for Karamay
  if (z === 16) {
    return `/tiles/${z}/${y}/${x}.jpg`;
  }
  return `https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/${z}/${y}/${x}`;
};

const createRealWorldGround = () => {
  const { lat, lon, zoom } = LOCATION;
  
  const centerTileX = long2tile(lon, zoom);
  const centerTileY = lat2tile(lat, zoom);
  
  // Calculate meters per pixel at this latitude
  // Earth Circumference ~ 40,075,017 meters
  // Resolution = 156543.03 meters/pixel * cos(lat) / (2 ^ zoom)
  const metersPerPixel = 156543.03 * Math.cos(lat * Math.PI / 180) / Math.pow(2, zoom);
  const tileSizePixels = 256;
  const tileSizeMeters = tileSizePixels * metersPerPixel;

  const loader = new THREE.TextureLoader();
  const groundGroup = new THREE.Group();
  
  // Load 3x3 grid centered on target
  const range = 1; // 1 means 3x3, 2 means 5x5
  
  for (let dx = -range; dx <= range; dx++) {
    for (let dy = -range; dy <= range; dy++) {
      const tileX = centerTileX + dx;
      const tileY = centerTileY + dy;
      const url = getTileUrl(tileX, tileY, zoom);
      
      loader.load(url, (texture) => {
        texture.colorSpace = THREE.SRGBColorSpace;
        const geometry = new THREE.PlaneGeometry(tileSizeMeters, tileSizeMeters);
        const material = new THREE.MeshStandardMaterial({ 
          map: texture,
          roughness: 0.9,
          metalness: 0.1
        });
        const mesh = new THREE.Mesh(geometry, material);
        mesh.rotation.x = -Math.PI / 2;
        
        // Position tiles
        // dx, dy are relative to center.
        // Web Mercator Y grows downwards (North to South), but 3D Z grows towards viewer (South).
        // So dy + 1 means South, which is +Z.
        mesh.position.set(dx * tileSizeMeters, -0.1, dy * tileSizeMeters);
        mesh.receiveShadow = true;
        
        groundGroup.add(mesh);
      }, undefined, (err) => {
        console.error('Failed to load tile', err);
      });
    }
  }
  
  scene.add(groundGroup);

  // Add a faint grid for scale reference
  const grid = new THREE.GridHelper(tileSizeMeters * 3, 30, 0xffffff, 0xffffff);
  grid.material.opacity = 0.1;
  grid.material.transparent = true;
  grid.position.y = 0.1;
  scene.add(grid);
  
  // Note: Fog removed to allow visibility of Earth from space
};

const createEarth = () => {
  const R = 6371000; // Earth Radius in meters
  const earthGroup = new THREE.Group();
  earthGroup.position.set(0, -R, 0); // Place center so top touches (0,0,0)

  const loader = new THREE.TextureLoader();
  const geometry = new THREE.SphereGeometry(R, 128, 128);
  const material = new THREE.MeshStandardMaterial({
    map: loader.load('/textures/earth-blue-marble.jpg'),
    normalMap: loader.load('/textures/earth-topology.png'),
    roughness: 0.6,
    metalness: 0.1,
  });

  const earth = new THREE.Mesh(geometry, material);
  
  // Alignment Logic:
  // Rotate Earth so that Karamay (Lat, Lon) is at the top (0, R, 0) relative to Earth center.
  // Standard Equirectangular Texture:
  // (0,0) UV is usually Lat 0, Lon -180 (Left edge) or Lat 0, Lon 0 (Center)? 
  // Most "Blue Marble" maps have Lon 0 (Greenwich) at center (0.5).
  // North Pole is at V=1.
  
  // Let's rotate the sphere mesh to align.
  // 1. Rotate Y to bring target Lon to -Z axis?
  //    If Lon 0 is at +Z (front), we rotate Y by -Lon to bring it to +Z?
  // 2. Rotate X to bring target Lat to +Y axis (Top).
  
  const { lat, lon } = LOCATION;
  
  // Rotate around Y axis (Longitude)
  // We want our Longitude to face "Up" after X rotation? No.
  // We want our location to be at (0, 1, 0) in world space (relative to sphere center).
  
  // Let's use lookAt trick.
  // Create a dummy object at the surface coordinate of (Lat, Lon) on an unrotated sphere.
  // Then calculate quaternion to rotate that point to (0, 1, 0).
  
  // const phi = (90 - lat) * (Math.PI / 180);
  // const theta = (lon + 180) * (Math.PI / 180); // Adjust 180 depending on texture start
  
  // Spherical to Cartesian (Z-up in math, but Y-up in Three.js)
  // In Three.js SphereGeometry:
  // u starts at 0 (approx -180 lon?) -> 1 (+180 lon)
  // v starts at 0 (South Pole) -> 1 (North Pole)
  // So North Pole is (0, R, 0).
  // Greenwich (Lat 0, Lon 0) is at Z axis?
  
  // Let's assume standard Three.js alignment:
  // North Pole (0, 1, 0).
  // Prime Meridian usually faces +Z.
  
  // To bring (Lat, Lon) to (0, 1, 0) [The North Pole of our local scene]:
  // We need to rotate the Earth such that (Lat, Lon) moves to (0, 1, 0).
  // Actually, we are just placing the Earth under us.
  // If we assume the "North Pole" of the geometry is the actual North Pole,
  // Then we are currently standing at the North Pole of the model.
  // But we want to be at Lat 45.
  // So we must rotate the Earth model by -(90 - 45) = -45 degrees around X axis?
  // Yes, tilting the North Pole away from us.
  
  earth.rotation.y = -lon * (Math.PI / 180) - (Math.PI / 2); // Adjust longitude
  earth.rotation.x = (90 - lat) * (Math.PI / 180); // Tilt latitude
  
  // Fine-tuning might be needed visually, but this is a good start.
  
  earthGroup.add(earth);
  scene.add(earthGroup);

  // Stars background
  const starGeo = new THREE.BufferGeometry();
  const starCount = 5000;
  const positions = new Float32Array(starCount * 3);
  for(let i = 0; i < starCount; i++) {
    const r = 20000000 + Math.random() * 20000000; // Far away
    const theta = Math.random() * Math.PI * 2;
    const phi = Math.acos(2 * Math.random() - 1);
    positions[i*3] = r * Math.sin(phi) * Math.cos(theta);
    positions[i*3+1] = r * Math.sin(phi) * Math.sin(theta);
    positions[i*3+2] = r * Math.cos(phi);
  }
  starGeo.setAttribute('position', new THREE.BufferAttribute(positions, 3));
  const starMat = new THREE.PointsMaterial({
    color: 0xffffff,
    size: 50000, // Size needs to be huge due to distance
    sizeAttenuation: true
  });
  const stars = new THREE.Points(starGeo, starMat);
  scene.add(stars);
  
  // Atmosphere Glow (Sprite)
  const spriteMaterial = new THREE.SpriteMaterial({ 
    map: createGlowTexture(),
    color: 0x4444ff,
    transparent: true,
    opacity: 0.6,
    depthWrite: false,
    blending: THREE.AdditiveBlending
  });
  const sprite = new THREE.Sprite(spriteMaterial);
  sprite.scale.set(R * 2.2, R * 2.2, 1);
  sprite.position.set(0, -R, 0);
  scene.add(sprite);
};

const createGlowTexture = () => {
  const canvas = document.createElement('canvas');
  canvas.width = 128;
  canvas.height = 128;
  const context = canvas.getContext('2d');
  if (context) {
    const gradient = context.createRadialGradient(
      64, 64, 0,
      64, 64, 64
    );
    gradient.addColorStop(0, 'rgba(255, 255, 255, 1)');
    gradient.addColorStop(0.5, 'rgba(255, 255, 255, 0.5)');
    gradient.addColorStop(1, 'rgba(255, 255, 255, 0)');
    context.fillStyle = gradient;
    context.fillRect(0, 0, 128, 128);
  }
  return new THREE.CanvasTexture(canvas);
};

// --- Procedural Generation Helpers ---
const createTank = (x: number, z: number, label: string) => {
  const group = new THREE.Group();
  group.position.set(x, 0, z);

  // Tank Body
  const radius = 8;
  const height = 20;
  const geometry = new THREE.CylinderGeometry(radius, radius, height, 32);
  const material = new THREE.MeshStandardMaterial({ 
    color: 0xffffff, 
    roughness: 0.3, 
    metalness: 0.5 
  });
  const tank = new THREE.Mesh(geometry, material);
  tank.position.y = height / 2;
  tank.castShadow = true;
  tank.receiveShadow = true;
  group.add(tank);

  // Tank Cap
  const capGeo = new THREE.SphereGeometry(radius, 32, 16, 0, Math.PI * 2, 0, Math.PI / 2);
  const cap = new THREE.Mesh(capGeo, material);
  cap.position.y = height;
  cap.castShadow = true;
  group.add(cap);

  // Base
  const baseGeo = new THREE.CylinderGeometry(radius + 1, radius + 1, 1, 32);
  const baseMat = new THREE.MeshStandardMaterial({ color: 0x333333 });
  const base = new THREE.Mesh(baseGeo, baseMat);
  base.position.y = 0.5;
  group.add(base);

  // Tank Label
  const canvas = document.createElement('canvas');
  const context = canvas.getContext('2d');
  if (context) {
    context.font = 'Bold 40px Arial';
    context.fillStyle = 'rgba(0,0,0,1)';
    context.fillText(label, 0, 50);
    const texture = new THREE.CanvasTexture(canvas);
    const spriteMaterial = new THREE.SpriteMaterial({ map: texture });
    const sprite = new THREE.Sprite(spriteMaterial);
    sprite.position.set(0, 32, 0);
    sprite.scale.set(10, 5, 1);
    group.add(sprite);
  }

  scene.add(group);
};

const createPipe = (start: THREE.Vector3, end: THREE.Vector3) => {
  const path = new THREE.LineCurve3(start, end);
  const tubeGeo = new THREE.TubeGeometry(path, 1, 0.5, 8, false);
  const material = new THREE.MeshStandardMaterial({ color: 0xeeeeee, metalness: 0.8 });
  const pipe = new THREE.Mesh(tubeGeo, material);
  pipe.castShadow = true;
  scene.add(pipe);
};

const createBuilding = (x: number, z: number, w: number, l: number, h: number) => {
  const geo = new THREE.BoxGeometry(w, h, l);
  const mat = new THREE.MeshStandardMaterial({ color: 0xcccccc });
  const b = new THREE.Mesh(geo, mat);
  b.position.set(x, h / 2, z);
  b.castShadow = true;
  b.receiveShadow = true;
  scene.add(b);
  
  // Windows (Simple Textures)
  // ... simplified for base
};

const createFacility = () => {
  // 1. LNG Tanks Area
  for (let i = 0; i < 3; i++) {
    for (let j = 0; j < 2; j++) {
      createTank(-50 + i * 30, -50 + j * 30, `Tank ${i}-${j}`);
    }
  }

  // 2. Pipes connecting tanks
  createPipe(new THREE.Vector3(-50, 5, -50), new THREE.Vector3(10, 5, -50));
  createPipe(new THREE.Vector3(10, 5, -50), new THREE.Vector3(10, 5, -20));

  // 3. Office Building
  createBuilding(60, 20, 30, 20, 10);
  
  // 4. Canopy (Gas Station Roof)
  const canopyGeo = new THREE.BoxGeometry(40, 2, 60);
  const canopyMat = new THREE.MeshStandardMaterial({ color: 0x1890ff });
  const canopy = new THREE.Mesh(canopyGeo, canopyMat);
  canopy.position.set(-60, 12, 40);
  canopy.castShadow = true;
  scene.add(canopy);

  // Pillars
  const pillarGeo = new THREE.CylinderGeometry(1, 1, 12);
  const pillarMat = new THREE.MeshStandardMaterial({ color: 0xeeeeee });
  const p1 = new THREE.Mesh(pillarGeo, pillarMat); p1.position.set(-75, 6, 20); scene.add(p1);
  const p2 = new THREE.Mesh(pillarGeo, pillarMat); p2.position.set(-45, 6, 20); scene.add(p2);
  const p3 = new THREE.Mesh(pillarGeo, pillarMat); p3.position.set(-75, 6, 60); scene.add(p3);
  const p4 = new THREE.Mesh(pillarGeo, pillarMat); p4.position.set(-45, 6, 60); scene.add(p4);

  objectCount.value = scene.children.length;
};

// --- Controls Setup ---
const setupControls = () => {
  // 1. Orbit (Map) Controls
  orbitControls = new MapControls(camera, renderer.domElement);
  orbitControls.enableDamping = true;
  orbitControls.dampingFactor = 0.05;
  // Increase zoom speed significantly to handle Earth scale
  orbitControls.zoomSpeed = 5.0; 
  // Allow zooming out far enough to see the whole Earth (Radius ~6,371km, so 20,000km is good)
  orbitControls.maxDistance = 20000000; 
  
  // 2. Roam (PointerLock) Controls
  roamControls = new PointerLockControls(camera, renderer.domElement);
  
  // Event listeners for roaming input
  document.addEventListener('keydown', onKeyDown);
  document.addEventListener('keyup', onKeyUp);
  
  // Switch handler
  roamControls.addEventListener('lock', () => {
    viewMode.value = 'roam';
  });
  roamControls.addEventListener('unlock', () => {
    if (viewMode.value === 'roam') {
        // If unlocked by ESC, maybe we want to pause or just switch back to orbit?
        // For now, keep state but maybe show menu
    }
  });
};

// Input Handlers
const onKeyDown = (event: KeyboardEvent) => {
  if (viewMode.value !== 'roam') return;
  switch (event.code) {
    case 'ArrowUp':
    case 'KeyW': moveState.forward = true; break;
    case 'ArrowLeft':
    case 'KeyA': moveState.left = true; break;
    case 'ArrowDown':
    case 'KeyS': moveState.backward = true; break;
    case 'ArrowRight':
    case 'KeyD': moveState.right = true; break;
    case 'ShiftLeft':
    case 'ShiftRight': moveState.run = true; break;
  }
};

const onKeyUp = (event: KeyboardEvent) => {
  if (viewMode.value !== 'roam') return;
  switch (event.code) {
    case 'ArrowUp':
    case 'KeyW': moveState.forward = false; break;
    case 'ArrowLeft':
    case 'KeyA': moveState.left = false; break;
    case 'ArrowDown':
    case 'KeyS': moveState.backward = false; break;
    case 'ArrowRight':
    case 'KeyD': moveState.right = false; break;
    case 'ShiftLeft':
    case 'ShiftRight': moveState.run = false; break;
  }
};

// Watch View Mode Change
watch(viewMode, (newMode) => {
  if (newMode === 'roam') {
    orbitControls.enabled = false;
    // Set camera to human height if it was high up
    camera.position.set(0, 2, 50); 
    camera.lookAt(0, 2, 0);
    roamControls.lock();
  } else {
    roamControls.unlock();
    orbitControls.enabled = true;
    // Restore bird's eye view
    camera.position.set(50, 50, 100);
    camera.lookAt(0, 0, 0);
  }
});

// --- Animation Loop ---
const animate = () => {
  animationId = requestAnimationFrame(animate);
  
  const delta = clock.getDelta();

  if (viewMode.value === 'orbit') {
    updateOrbitMode();
    orbitControls.update();
  } else {
    // Roaming Logic
    if (roamControls.isLocked) {
        velocity.x -= velocity.x * 10.0 * delta;
        velocity.z -= velocity.z * 10.0 * delta;
        velocity.y -= 9.8 * 100.0 * delta; // Gravity (simple)

        direction.z = Number(moveState.forward) - Number(moveState.backward);
        direction.x = Number(moveState.right) - Number(moveState.left);
        direction.normalize(); // consistent movement in all directions

        const speed = moveState.run ? 100.0 : 40.0; // Units per second

        if (moveState.forward || moveState.backward) velocity.z -= direction.z * speed * delta;
        if (moveState.left || moveState.right) velocity.x -= direction.x * speed * delta;

        roamControls.moveRight(-velocity.x * delta);
        roamControls.moveForward(-velocity.z * delta);
        
        // Simple floor collision
        if (camera.position.y < 2) {
            velocity.y = 0;
            camera.position.y = 2;
        }
    }
  }

  renderer.render(scene, camera);
  
  // Calculate FPS (simple)
  fps.value = Math.round(1 / delta);
};

// Logic to switch between Ground Mode (Pan) and Space Mode (Rotate Earth)
const updateOrbitMode = () => {
  if (!orbitControls || !camera) return;

  const R = 6371000;
  const SPACE_THRESHOLD = 500000; // 500km altitude to switch mode
  
  // Calculate altitude (roughly y position if near origin, or distance to surface)
  // Since we are top down mostly, y is good enough approximation for altitude
  const altitude = camera.position.y;
  
  // Current Target Y tells us if we are targeting Center (-R) or Surface (0)
  const currentTargetY = orbitControls.target.y;
  
  if (altitude > SPACE_THRESHOLD) {
    // --- SPACE MODE ---
    // User expects "Drag to Rotate Earth" -> Orbit around Earth Center
    // Left Mouse: ROTATE, Right Mouse: PAN (or Zoom)
    
    // 1. Switch Mouse Buttons
    if (orbitControls.mouseButtons.LEFT !== THREE.MOUSE.ROTATE) {
      orbitControls.mouseButtons.LEFT = THREE.MOUSE.ROTATE;
      orbitControls.mouseButtons.RIGHT = THREE.MOUSE.PAN;
      
      // Update help text if possible (not implemented reactively here but ok)
    }
    
    // 2. Move Target to Earth Center (0, -R, 0)
    // Smoothly interpolate target Y to -R
    if (Math.abs(currentTargetY - (-R)) > 100) {
      orbitControls.target.y += (-R - currentTargetY) * 0.1;
      // Also center X/Z to 0 to rotate around true center
      orbitControls.target.x += (0 - orbitControls.target.x) * 0.1;
      orbitControls.target.z += (0 - orbitControls.target.z) * 0.1;
    }
    
  } else {
    // --- GROUND MODE ---
    // User expects "Drag to Pan Map" -> MapControls default
    // Left Mouse: PAN, Right Mouse: ROTATE
    
    // 1. Switch Mouse Buttons
    if (orbitControls.mouseButtons.LEFT !== THREE.MOUSE.PAN) {
      orbitControls.mouseButtons.LEFT = THREE.MOUSE.PAN;
      orbitControls.mouseButtons.RIGHT = THREE.MOUSE.ROTATE;
    }
    
    // 2. Move Target to Surface (0, 0, 0) - Only Y component!
    // We preserve X/Z so user can pan around the station area
    if (currentTargetY < -1000) {
      // If we are coming back from deep space target, bring it up quickly
      orbitControls.target.y += (0 - currentTargetY) * 0.1;
    }
  }
};

const onWindowResize = () => {
  if (!canvasContainer.value) return;
  const width = canvasContainer.value.clientWidth;
  const height = canvasContainer.value.clientHeight;
  camera.aspect = width / height;
  camera.updateProjectionMatrix();
  renderer.setSize(width, height);
};

const flyToSpace = () => {
  if (viewMode.value !== 'orbit') return;
  
  // Animate camera to space
  const targetY = 15000000; // 15,000 km
  const startY = camera.position.y;
  const startTime = performance.now();
  const duration = 2000;

  const animateFly = (time: number) => {
    const elapsed = time - startTime;
    const progress = Math.min(elapsed / duration, 1);
    // Ease out cubic
    const ease = 1 - Math.pow(1 - progress, 3);
    
    camera.position.set(0, startY + (targetY - startY) * ease, 0);
    camera.lookAt(0, 0, 0);
    
    if (progress < 1) {
      requestAnimationFrame(animateFly);
    }
  };
  requestAnimationFrame(animateFly);
};

onMounted(() => {
  initScene();
});

onUnmounted(() => {
  cancelAnimationFrame(animationId);
  window.removeEventListener('resize', onWindowResize);
  document.removeEventListener('keydown', onKeyDown);
  document.removeEventListener('keyup', onKeyUp);
  if (renderer) renderer.dispose();
  if (scene) scene.clear();
});
</script>

<style scoped>
.gas-station-container {
  width: 100%;
  height: 100%;
  position: relative;
  overflow: hidden;
  background: #000;
}

.canvas-container {
  width: 100%;
  height: 100%;
}

.ui-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  padding: 20px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.panel {
  background: rgba(0, 0, 0, 0.6);
  backdrop-filter: blur(10px);
  padding: 20px;
  border-radius: 8px;
  color: white;
  pointer-events: auto;
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.info-panel {
  align-self: flex-start;
  max-width: 400px;
}

.info-panel h2 {
  margin: 0 0 10px 0;
  color: #1890ff;
  font-size: 20px;
}

.controls-guide {
  margin-top: 15px;
  padding-top: 15px;
  border-top: 1px solid rgba(255, 255, 255, 0.2);
}

.mode-switch {
  margin-bottom: 10px;
}

.status-panel {
  align-self: flex-end;
  display: flex;
  gap: 20px;
}

.stat-item {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
}

.stat-item .label {
  font-size: 12px;
  color: #aaa;
}

.stat-item .value {
  font-size: 18px;
  font-weight: bold;
  color: #52c41a;
}
</style>
