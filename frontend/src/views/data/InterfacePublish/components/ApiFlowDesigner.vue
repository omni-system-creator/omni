<template>
  <div class="flow-container">
    <!-- Toolbar -->
    <div class="flow-toolbar" v-if="!readOnly">
      <div class="tool-item" draggable="true" @dragstart="onDragStart($event, 'request')">
        <GlobalOutlined /> 接收请求 (Request)
      </div>
      <div class="tool-item" draggable="true" @dragstart="onDragStart($event, 'database')">
        <DatabaseOutlined /> 数据操作 (Database)
      </div>
      <div class="tool-item" draggable="true" @dragstart="onDragStart($event, 'api')">
        <CloudServerOutlined /> 外部接口 (HTTP)
      </div>
      <div class="tool-item" draggable="true" @dragstart="onDragStart($event, 'script')">
        <CodeOutlined /> 脚本逻辑 (Script)
      </div>
      <div class="tool-item" draggable="true" @dragstart="onDragStart($event, 'response')">
        <ExportOutlined /> 发送响应 (Response)
      </div>
    </div>

    <div class="flow-main">
      <!-- Canvas -->
      <div 
        class="flow-canvas" 
        ref="canvasRef"
        @drop="onDrop" 
        @dragover.prevent
      >
        <!-- Leafer Canvas will be mounted here -->
      </div>
    </div>

    <!-- Properties Panel (Dialog) -->
    <DraggableModal
      v-if="selectedNode"
      :visible="!!selectedNode"
      :title="'节点配置: ' + (selectedNode.label || 'Node')"
      :width="500"
      :height="600"
      body-padding="0"
      :maskClosable="false"
      @close="deselectAll"
    >
      <div class="props-content">
        <a-form layout="vertical" :disabled="readOnly">
          <a-form-item label="节点名称">
            <a-input v-model:value="selectedNode.label" @change="updateNodeLabel" @input="updateNodeLabel" />
          </a-form-item>
          
          <RequestNodeConfig 
            v-if="selectedNode.type === 'request'" 
            :node="selectedNode" 
            :readOnly="readOnly" 
          />

          <DatabaseNodeConfig 
            v-if="selectedNode.type === 'database'" 
            :node="selectedNode" 
            :readOnly="readOnly" 
            @change="updateNodeVisual" 
          />

          <ApiNodeConfig 
            v-if="selectedNode.type === 'api'" 
            :node="selectedNode" 
            :readOnly="readOnly" 
            @change="updateNodeVisual" 
          />

          <ScriptNodeConfig 
            v-if="selectedNode.type === 'script'" 
            :node="selectedNode" 
            :readOnly="readOnly" 
            @change="updateNodeVisual" 
          />

          <ResponseNodeConfig 
            v-if="selectedNode.type === 'response'" 
            :node="selectedNode" 
            :readOnly="readOnly" 
          />
        </a-form>
      </div>
    </DraggableModal>
  </div>
</template>

<script setup lang="ts">
import DraggableModal from '@/components/DraggableModal.vue';
import { ref, onMounted, onUnmounted, computed, watch, nextTick } from 'vue';
import { 
  GlobalOutlined, 
  DatabaseOutlined, 
  CloudServerOutlined, 
  CodeOutlined, 
  ExportOutlined
} from '@ant-design/icons-vue';
import RequestNodeConfig from './node-config/RequestNodeConfig.vue';
import DatabaseNodeConfig from './node-config/DatabaseNodeConfig.vue';
import ApiNodeConfig from './node-config/ApiNodeConfig.vue';
import ScriptNodeConfig from './node-config/ScriptNodeConfig.vue';
import ResponseNodeConfig from './node-config/ResponseNodeConfig.vue';
import { Leafer, Rect, Text, Group, Ellipse, PointerEvent, Path, Line } from 'leafer-ui';
import '@leafer-in/find';
import '@leafer-in/arrow';
import { v4 as uuidv4 } from 'uuid';

interface Node {
  id: string;
  type: string;
  x: number;
  y: number;
  label?: string;
  data: any;
}

interface Edge {
  id: string;
  sourceId: string;
  targetId: string;
}

const props = defineProps<{
  initialData?: any;
  debugResult?: any;
  readOnly?: boolean;
}>();

const emit = defineEmits(['node-click']);

const nodes = ref<Node[]>([]);
const edges = ref<Edge[]>([]);
const canvasRef = ref<HTMLElement | null>(null);

// Selection
const selectedNodeId = ref<string | null>(null);
const selectedEdgeId = ref<string | null>(null);
const selectedNode = computed(() => nodes.value.find(n => n.id === selectedNodeId.value));

// Patch data when node is selected
watch(selectedNodeId, (newId) => {
  if (newId) {
    const node = nodes.value.find(n => n.id === newId);
    if (node && node.type === 'api') {
        if (!node.data.paramMode) node.data.paramMode = 'all';
        if (!node.data.headers) node.data.headers = [];
        if (!node.data.params) node.data.params = [];
    }
  }
});



// Leafer Instances
let leaferApp: Leafer | null = null;
let graphGroup: Group | null = null;
let activeConnectionLine: Path | null = null;
let connectionStartNode: Group | null = null;
let hGuideLine: Line | null = null;
let vGuideLine: Line | null = null;

// Pan & Zoom State
let isPanning = false;
let lastPanX = 0;
let lastPanY = 0;
const isSpacePressed = ref(false);
let resizeObserver: ResizeObserver | null = null;

// Initialization
onMounted(() => {
  nextTick(initLeafer);
  window.addEventListener('keydown', onKeyDown);
  window.addEventListener('keyup', onKeyUp);

  if (canvasRef.value) {
    resizeObserver = new ResizeObserver((entries) => {
      for (const entry of entries) {
        if (entry.contentRect.width > 0 && entry.contentRect.height > 0) {
           if (!leaferApp) {
             initLeafer();
           } else {
             fitView();
           }
        }
      }
    });
    resizeObserver.observe(canvasRef.value);
  }
});

onUnmounted(() => {
  if (resizeObserver) {
    resizeObserver.disconnect();
  }
  if (leaferApp) {
    leaferApp.destroy();
  }
  window.removeEventListener('keydown', onKeyDown);
  window.removeEventListener('keyup', onKeyUp);
  window.removeEventListener('mousemove', onGlobalMove);
  window.removeEventListener('mouseup', onGlobalUp);
});

// Watch for external data loading
watch(() => props.initialData, (val) => {
  if (val && val.nodes && val.edges) {
    nodes.value = JSON.parse(JSON.stringify(val.nodes));
    edges.value = JSON.parse(JSON.stringify(val.edges));
    renderGraph();
    // Auto fit view when data loaded
    nextTick(() => {
      fitView();
      if (graphGroup) graphGroup.opacity = 1;
    });
  }
}, { deep: true });

// Watch for debug result to highlight executed nodes
watch(() => props.debugResult, () => {
    if (!leaferApp || !graphGroup) return;
    
    // Always refresh visuals when debugResult changes, 
    // including when it becomes null (to clear highlights)
    refreshVisuals();
}, { deep: true });

const getDebugStatus = (nodeId: string) => {
    if (!props.debugResult) return null;
    
    // Check running first
    if (props.debugResult.runningNodes && props.debugResult.runningNodes.includes(nodeId)) {
        return 'running';
    }

    if (props.debugResult.executedNodes && props.debugResult.executedNodes.includes(nodeId)) {
        // Check if error
        // Only consider it an error if status code is non-zero and not 200
        if (props.debugResult.statusCode !== 0 && props.debugResult.statusCode !== 200 && 
            props.debugResult.executedNodes[props.debugResult.executedNodes.length - 1] === nodeId) {
            return 'error';
        }
        return 'success';
    }
    return null;
};

// ...



const initLeafer = () => {
  if (!canvasRef.value) return;
  
  // Wait for container size
  if (canvasRef.value.clientWidth === 0) {
    setTimeout(initLeafer, 100);
    return;
  }

  // Destroy existing instance if any
  if (leaferApp) {
      leaferApp.destroy();
  }

  leaferApp = new Leafer({
    view: canvasRef.value,
    fill: '#f0f2f5', // Canvas background
  });

  graphGroup = new Group({ id: 'graph-group', opacity: 0 });
  leaferApp.add(graphGroup);

  // Initial Render
  if (props.initialData && props.initialData.nodes) {
     nodes.value = JSON.parse(JSON.stringify(props.initialData.nodes));
     edges.value = JSON.parse(JSON.stringify(props.initialData.edges || []));
  }
  renderGraph();

  // Events - Listen on tree to capture background taps
  leaferApp.on(PointerEvent.TAP, (e: PointerEvent) => {
    // Check if clicked on a node
    let target = e.target;

    // Check if clicked directly on a port (or its vicinity if wrapped)
    // We should not select the node if a port is clicked
    if (target && (target.name === 'port-in' || target.name === 'port-out')) {
        return;
    }

    while(target && target.tag !== 'Leafer' && target.id !== 'graph-group') {
        if (target.tag === 'Group' && target.id && target.name === 'node-group') {
            selectNode(target.id);
            // Emit click event for parent to handle (e.g. show debug info)
            emit('node-click', target.id);
            return;
        }
        // Check if clicked on an edge
        if (target.tag === 'Path' && target.id && target.name === 'connection-line') {
            selectEdge(target.id);
            return;
        }
        target = target.parent as any;
    }
    // Clicked on background
    deselectAll();
    emit('node-click', null); // Emit null to indicate deselection
  });
  
  setupInteractions();

  // Fit view initially
  fitView();
  graphGroup.opacity = 1;
};

const renderGraph = () => {
  if (!leaferApp || !graphGroup) return;
  graphGroup.clear();

  // Render Edges
  edges.value.forEach(edge => {
    const sourceNode = nodes.value.find(n => n.id === edge.sourceId);
    const targetNode = nodes.value.find(n => n.id === edge.targetId);
    if (sourceNode && targetNode) {
      createConnectionLine(sourceNode, targetNode, edge.id);
    }
  });

  // Render Nodes
  nodes.value.forEach(node => {
    createNodeVisual(node);
  });
};

// --- View Control ---

const fitView = () => {
  if (!graphGroup || nodes.value.length === 0 || !canvasRef.value) {
      if (graphGroup) {
          graphGroup.x = 0;
          graphGroup.y = 0;
          graphGroup.scale = 1;
      }
      return;
  }

  // Calculate bounds
  let minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity;
  
  nodes.value.forEach(node => {
      minX = Math.min(minX, node.x);
      minY = Math.min(minY, node.y);
      maxX = Math.max(maxX, node.x + 180);
      maxY = Math.max(maxY, node.y + 70);
  });

  if (minX === Infinity) return;

  const padding = 50;
  const contentWidth = maxX - minX;
  const contentHeight = maxY - minY;
  
  const containerWidth = canvasRef.value.clientWidth;
  const containerHeight = canvasRef.value.clientHeight;
  
  let scale = 1;
  if (contentWidth > 0 && contentHeight > 0) {
      // Ensure positive dimensions for calculation
      const validContainerWidth = Math.max(containerWidth, padding * 2 + 100);
      const validContainerHeight = Math.max(containerHeight, padding * 2 + 100);
      
      const scaleX = (validContainerWidth - padding * 2) / contentWidth;
      const scaleY = (validContainerHeight - padding * 2) / contentHeight;
      scale = Math.min(scaleX, scaleY);
  }
  
  scale = Math.min(Math.max(scale, 0.1), 1); // Clamp scale between 0.1 and 1
  
  graphGroup.scale = scale;
  graphGroup.x = containerWidth / 2 - (minX + contentWidth / 2) * scale;
  graphGroup.y = containerHeight / 2 - (minY + contentHeight / 2) * scale;
};

// --- Alignment & Interaction ---

const checkAlignment = (currentId: string, x: number, y: number) => {
    if (!leaferApp || !graphGroup) return { x: undefined, y: undefined };

    const threshold = 5;
    const currentCenterX = x + 90;
    const currentCenterY = y + 35;
    
    let snappedX: number | undefined = undefined;
    let snappedY: number | undefined = undefined;
    
    let showVLine = false;
    let showHLine = false;
    let vLineX = 0;
    let hLineY = 0;

    // Check against all other nodes
    for (const otherNode of nodes.value) {
        if (otherNode.id === currentId) continue;

        const otherCenterX = otherNode.x + 90;
        const otherCenterY = otherNode.y + 35;

        // Vertical Alignment (Center X)
        if (Math.abs(currentCenterX - otherCenterX) < threshold) {
            snappedX = otherCenterX - 90;
            vLineX = otherCenterX;
            showVLine = true;
        }

        // Horizontal Alignment (Center Y)
        if (Math.abs(currentCenterY - otherCenterY) < threshold) {
            snappedY = otherCenterY - 35;
            hLineY = otherCenterY;
            showHLine = true;
        }
    }

    // Draw/Update Vertical Line
    if (showVLine) {
        if (!vGuideLine) {
            vGuideLine = new Line({
                stroke: '#ff0000',
                strokeWidth: 1,
                dashPattern: [4, 4],
                pointerEvents: 'none'
            });
            graphGroup.add(vGuideLine);
        }
        vGuideLine.points = [vLineX, -10000, vLineX, 10000]; // Long line
    } else if (vGuideLine) {
        vGuideLine.remove();
        vGuideLine = null;
    }

    // Draw/Update Horizontal Line
    if (showHLine) {
        if (!hGuideLine) {
            hGuideLine = new Line({
                stroke: '#ff0000',
                strokeWidth: 1,
                dashPattern: [4, 4],
                pointerEvents: 'none'
            });
            graphGroup.add(hGuideLine);
        }
        hGuideLine.points = [-10000, hLineY, 10000, hLineY]; // Long line
    } else if (hGuideLine) {
        hGuideLine.remove();
        hGuideLine = null;
    }

    return { x: snappedX, y: snappedY };
};

const clearAlignmentLines = () => {
    if (vGuideLine) {
        vGuideLine.remove();
        vGuideLine = null;
    }
    if (hGuideLine) {
        hGuideLine.remove();
        hGuideLine = null;
    }
};

const onGlobalMove = (e: MouseEvent) => {
    if (!isPanning || !graphGroup) return;
    
    const dx = e.clientX - lastPanX;
    const dy = e.clientY - lastPanY;
    
    graphGroup.x = (graphGroup.x || 0) + dx;
    graphGroup.y = (graphGroup.y || 0) + dy;
    
    lastPanX = e.clientX;
    lastPanY = e.clientY;
};

const onGlobalUp = () => {
    isPanning = false;
    if (leaferApp && canvasRef.value) canvasRef.value.style.cursor = 'default';
    window.removeEventListener('mousemove', onGlobalMove);
    window.removeEventListener('mouseup', onGlobalUp);
};

const setupInteractions = () => {
    if (!leaferApp || !canvasRef.value) return;

    // Pan (Start)
    leaferApp.on(PointerEvent.DOWN, (e: PointerEvent) => {
        const originEvent = (e.origin || (e as any).event) as PointerEvent;
        if (originEvent && originEvent.target) {
            const target = originEvent.target as any;
            if (target.tagName === 'INPUT' || target.tagName === 'TEXTAREA') return;
        }
        if (!originEvent) return;

        // Check if target is interactive (Node, Port, etc.)
        let isInteractive = false;
        let curr = e.target;
        while (curr && curr.tag !== 'Leafer' && curr.id !== 'graph-group') {
            if (curr.name === 'node-group' || curr.name === 'port-in' || curr.name === 'port-out' || (curr.tag === 'Path' && curr.id)) {
                isInteractive = true;
                break;
            }
            curr = curr.parent as any;
        }

        const isMiddleBtn = (originEvent as any).button === 1 || (originEvent as any).buttons === 4;
        const isLeftBtn = (originEvent as any).button === 0 || (originEvent as any).buttons === 1;
        
        const shouldPan = isSpacePressed.value || isMiddleBtn || (isLeftBtn && !isInteractive);

        if (shouldPan) {
            if (isSpacePressed.value || isMiddleBtn) {
                 e.stop(); 
            }

            isPanning = true;
            const clientX = (originEvent as any).clientX;
            const clientY = (originEvent as any).clientY;
            
            if (typeof clientX === 'number') {
                lastPanX = clientX;
                lastPanY = clientY;
                if (canvasRef.value) canvasRef.value.style.cursor = 'grabbing';
                
                window.addEventListener('mousemove', onGlobalMove);
                window.addEventListener('mouseup', onGlobalUp);
            }
        }
    });
    
    // Zoom (Ctrl + Wheel)
    canvasRef.value.addEventListener('wheel', (e: WheelEvent) => {
        // Allow zoom without Ctrl if desired, but standard is usually Ctrl+Wheel or just Wheel for maps
        // EtlDesigner uses Ctrl+Wheel
        // if (e.ctrlKey && graphGroup) {
        if (graphGroup) {
            e.preventDefault();
            e.stopPropagation();

            const currentScale = (graphGroup.scaleX || 1);
            const zoomFactor = e.deltaY > 0 ? 0.9 : 1.1;
            let newScale = currentScale * zoomFactor;
            
            // Limit scale
            newScale = Math.max(0.1, Math.min(newScale, 5));
            
            const rect = canvasRef.value!.getBoundingClientRect();
            const mouseX = e.clientX - rect.left;
            const mouseY = e.clientY - rect.top;
            
            const localX = (mouseX - (graphGroup.x || 0)) / currentScale;
            const localY = (mouseY - (graphGroup.y || 0)) / currentScale;
            
            graphGroup.scale = newScale;
            graphGroup.x = mouseX - localX * newScale;
            graphGroup.y = mouseY - localY * newScale;
        }
    }, { passive: false });

    // Touch Zoom (Pinch) - Simplified version
    let initialPinchDistance: number | null = null;
    let initialScale = 1;
    let initialGraphX = 0;
    let initialGraphY = 0;
    let initialCenterPoint: { x: number, y: number } | null = null;

    canvasRef.value.addEventListener('touchstart', (e: TouchEvent) => {
        if (e.touches.length === 2 && graphGroup) {
            e.preventDefault();
            if (!e.touches[0] || !e.touches[1]) return;
            const dx = e.touches[0].clientX - e.touches[1].clientX;
            const dy = e.touches[0].clientY - e.touches[1].clientY;
            initialPinchDistance = Math.sqrt(dx * dx + dy * dy);
            initialScale = graphGroup.scaleX || 1;
            initialGraphX = graphGroup.x || 0;
            initialGraphY = graphGroup.y || 0;
            
            const rect = canvasRef.value!.getBoundingClientRect();
            const centerClientX = (e.touches[0].clientX + e.touches[1].clientX) / 2;
            const centerClientY = (e.touches[0].clientY + e.touches[1].clientY) / 2;
            initialCenterPoint = {
                x: centerClientX - rect.left,
                y: centerClientY - rect.top
            };
        }
    }, { passive: false });

    canvasRef.value.addEventListener('touchmove', (e: TouchEvent) => {
        if (e.touches.length === 2 && initialPinchDistance && graphGroup && initialCenterPoint) {
            e.preventDefault();
            
            if (!e.touches[0] || !e.touches[1]) return;
            const dx = e.touches[0].clientX - e.touches[1].clientX;
            const dy = e.touches[0].clientY - e.touches[1].clientY;
            const currentDistance = Math.sqrt(dx * dx + dy * dy);
            
            const scaleFactor = currentDistance / initialPinchDistance;
            let newScale = initialScale * scaleFactor;
            
            newScale = Math.max(0.1, Math.min(newScale, 5));
            
            const localX = (initialCenterPoint.x - initialGraphX) / initialScale;
            const localY = (initialCenterPoint.y - initialGraphY) / initialScale;
            
            const rect = canvasRef.value!.getBoundingClientRect();
            if (!e.touches[0] || !e.touches[1]) return;
            const currentCenterClientX = (e.touches[0].clientX + e.touches[1].clientX) / 2;
            const currentCenterClientY = (e.touches[0].clientY + e.touches[1].clientY) / 2;
            const currentCenterX = currentCenterClientX - rect.left;
            const currentCenterY = currentCenterClientY - rect.top;

            graphGroup.scale = newScale;
            graphGroup.x = currentCenterX - localX * newScale;
            graphGroup.y = currentCenterY - localY * newScale;
        }
    }, { passive: false });
    
    canvasRef.value.addEventListener('touchend', (e: TouchEvent) => {
        if (e.touches.length < 2) {
            initialPinchDistance = null;
            initialCenterPoint = null;
        }
    });
};

// --- Visual Creation ---

const getNodeColor = (_type: string) => {
  return '#1677ff'; 
};

const getNodeTitle = (type: string) => {
  const titles: any = {
    request: '接收请求',
    database: '数据操作',
    api: '外部接口',
    script: '脚本逻辑',
    response: '发送响应'
  };
  return titles[type] || '节点';
};



const createNodeVisual = (node: Node) => {
  if (!leaferApp) return;

  const isSelected = selectedNodeId.value === node.id;

  const group = new Group({
    id: node.id,
    name: 'node-group',
    x: node.x,
    y: node.y,
    draggable: true,
    cursor: 'move',
    zIndex: isSelected ? 10 : 1
  });

  const debugStatus = getDebugStatus(node.id);
  
  // 1. Initialize Visual Properties
  let strokeColor = getNodeColor(node.type);
  let strokeWidth = 2;
  let shadow = { x: 0, y: 2, blur: 8, color: 'rgba(0,0,0,0.1)' }; // Default Shadow

  // 2. Determine Stroke Color & Base Styles based on Debug Status
  if (debugStatus === 'success') {
      strokeColor = '#52c41a'; // Green
      strokeWidth = 3;
  } else if (debugStatus === 'error') {
      strokeColor = '#ff4d4f'; // Red
      strokeWidth = 3;
  } else if (debugStatus === 'running') {
      strokeColor = '#faad14'; // Yellow
      strokeWidth = 3;
      shadow = { x: 0, y: 0, blur: 10, color: 'rgba(250, 173, 20, 0.6)' }; // Running Glow (default)
  } else if (isSelected) {
      strokeColor = '#1890ff'; // Blue (only if no debug status)
      strokeWidth = 3;
  }

  // 3. Selection Shadow Overrides (Glow effects)
  if (isSelected) {
      if (debugStatus === 'success') {
          shadow = { x: 0, y: 4, blur: 12, color: 'rgba(82, 196, 26, 0.6)' }; // Green Glow
      } else if (debugStatus === 'error') {
          shadow = { x: 0, y: 4, blur: 12, color: 'rgba(255, 77, 79, 0.6)' }; // Red Glow
      } else if (debugStatus === 'running') {
          shadow = { x: 0, y: 4, blur: 12, color: 'rgba(250, 173, 20, 0.6)' }; // Yellow Glow
      } else {
          shadow = { x: 0, y: 4, blur: 12, color: 'rgba(24, 144, 255, 0.4)' }; // Blue Glow
      }
  }

  // Main Box
  const rect = new Rect({
    width: 180,
    height: 70,
    fill: '#fff',
    stroke: strokeColor,
    strokeWidth: strokeWidth,
    cornerRadius: 4,
    shadow: shadow
  });

  // Header Bar
  const header = new Rect({
    width: 180,
    height: 6,
    fill: getNodeColor(node.type), // Header always keeps type color
    cornerRadius: [4, 4, 0, 0]
  });

  // Title
  const titleText = new Text({
    text: node.label || getNodeTitle(node.type),
    fill: '#333',
    fontSize: 14,
    fontWeight: 'bold',
    x: 10,
    y: 12,
    pointerEvents: 'none'
  });

  // Info Text
  let info = '';
  if (node.type === 'request') info = `${node.data.method || 'GET'} ${node.data.path || ''}`;
  else if (node.type === 'database') info = `${node.data.opType || ''} ${node.data.sourceId || ''}`;
  else if (node.type === 'api') info = node.data.url || '';
  else if (node.type === 'script') info = (node.data.language || 'javascript').toUpperCase();
  else if (node.type === 'response') info = node.data.contentType || '';
  
  if (info.length > 20) info = info.substring(0, 18) + '...';

  const detailText = new Text({
    text: info,
    fill: '#888',
    fontSize: 12,
    x: 10,
    y: 36,
    pointerEvents: 'none'
  });

  // Ports
  const inPort = new Ellipse({
    width: 10, height: 10,
    fill: '#fff', stroke: '#666', strokeWidth: 1,
    x: -5, y: 30,
    cursor: 'crosshair',
    name: 'port-in',
    visible: node.type !== 'request'
  });

  const outPort = new Ellipse({
    width: 10, height: 10,
    fill: '#fff', stroke: '#666', strokeWidth: 1,
    x: 175, y: 30,
    cursor: 'crosshair',
    name: 'port-out',
    visible: node.type !== 'response'
  });

  // Events
  // Note: EtlDesigner handles selection via global TAP listener on leaferApp,
  // so we don't need individual TAP listeners on groups/lines that stop propagation.
  // We just let the event bubble up to the global handler.

  /*
  group.on(PointerEvent.TAP, (e: PointerEvent) => {
    e.stop(); // Prevent bubbling to background
    selectNode(node.id);
  });
  */

  outPort.on(PointerEvent.DOWN, (e: PointerEvent) => {
    e.stop();
    group.draggable = false;
    startConnection(group);
  });

  // Auto Connect on Double Click
  outPort.on(PointerEvent.DOUBLE_TAP, (e: PointerEvent) => {
    e.stop();
    
    // 1. Check if current node already has outgoing edges
    const hasOutgoing = edges.value.some(edge => edge.sourceId === node.id);
    if (hasOutgoing) return;

    // 2. Find potential target nodes
    // - Must be to the right of current node
    // - Must have no incoming edges
    // - Must have an input port (type !== 'request')
    const candidates = nodes.value.filter(n => {
        if (n.id === node.id) return false;
        if (n.x <= node.x) return false; // Must be to the right
        if (n.type === 'request') return false; // Request node has no input

        const hasIncoming = edges.value.some(edge => edge.targetId === n.id);
        return !hasIncoming;
    });

    if (candidates.length === 0) return;

    // 3. Find the nearest candidate
    const startX = node.x + 180;
    const startY = node.y + 35;

    candidates.sort((a, b) => {
        const distA = Math.pow(a.x - startX, 2) + Math.pow((a.y + 35) - startY, 2);
        const distB = Math.pow(b.x - startX, 2) + Math.pow((b.y + 35) - startY, 2);
        return distA - distB;
    });

    const targetNode = candidates[0];
    if (!targetNode) return;

    // 4. Create Connection
    const newEdge: Edge = {
        id: uuidv4(),
        sourceId: node.id,
        targetId: targetNode.id
    };
    edges.value.push(newEdge);
    createConnectionLine(node, targetNode, newEdge.id);
  });

  group.add(rect);
  group.add(header);
  group.add(titleText);
  group.add(detailText);
  if (node.type !== 'request') group.add(inPort);
  if (node.type !== 'response') group.add(outPort);

  // Drag Sync
  group.on('drag', () => {
    const n = nodes.value.find(item => item.id === node.id);
    if (n) {
      // Check alignment
    const snapped = checkAlignment(node.id, group.x || 0, group.y || 0);
    if (snapped.x !== undefined) group.x = snapped.x;
    if (snapped.y !== undefined) group.y = snapped.y;

    n.x = group.x || 0;
    n.y = group.y || 0;
    updateConnectedLines(node.id);
    }
  });

  group.on('drag.end', () => {
      clearAlignmentLines();
  });

  graphGroup?.add(group);
};

// --- Connections ---

const getCurvePath = (x1: number, y1: number, x2: number, y2: number) => {
    const offset = Math.max(Math.abs(x2 - x1) * 0.5, 50);
    const cp1x = x1 + offset;
    const cp1y = y1;
    const cp2x = x2 - offset;
    const cp2y = y2;
    return `M ${x1} ${y1} C ${cp1x} ${cp1y} ${cp2x} ${cp2y} ${x2} ${y2}`;
};

const createConnectionLine = (source: Node, target: Node, id: string) => {
    if (!graphGroup) return;
    
    const isSelected = selectedEdgeId.value === id;

    const pathData = getCurvePath(
        source.x + 180, source.y + 35,
        target.x, target.y + 35
    );

    const line = new Path({
        id: id,
        name: 'connection-line',
        stroke: isSelected ? '#1890ff' : '#999',
        strokeWidth: isSelected ? 4 : 2,
        path: pathData,
        endArrow: 'arrow',
        cursor: 'pointer'
    });
    
    line.on(PointerEvent.TAP, (_e: PointerEvent) => {
        // e.stop(); // Let it bubble to global handler
        // selectEdge(id);
    });

    graphGroup.add(line);
};

const updateConnectedLines = (nodeId: string) => {
    edges.value.forEach(edge => {
        if (edge.sourceId === nodeId || edge.targetId === nodeId) {
            const line = graphGroup?.findId(edge.id) as Path;
            const source = nodes.value.find(n => n.id === edge.sourceId);
            const target = nodes.value.find(n => n.id === edge.targetId);
            
            if (line && source && target) {
                line.path = getCurvePath(
                    source.x + 180, source.y + 35,
                    target.x, target.y + 35
                );
            }
        }
    });
};

const startConnection = (nodeGroup: Group) => {
    connectionStartNode = nodeGroup;
    activeConnectionLine = new Path({
        stroke: '#1890ff',
        strokeWidth: 2,
        dashPattern: [5, 5],
        path: getCurvePath(
            (nodeGroup.x || 0) + 180, (nodeGroup.y || 0) + 35, 
            (nodeGroup.x || 0) + 180, (nodeGroup.y || 0) + 35
        ),
        endArrow: 'arrow',
        pointerEvents: 'none'
    });
    graphGroup?.add(activeConnectionLine);
    
    leaferApp?.on(PointerEvent.MOVE, onConnectionMove);
    leaferApp?.on(PointerEvent.UP, onConnectionUp);
};

const onConnectionMove = (e: PointerEvent) => {
    if (activeConnectionLine && connectionStartNode && graphGroup) {
        // Manual coordinate conversion to match EtlDesigner
        const scale = graphGroup.scaleX || 1;
        const localX = (e.x - (graphGroup.x || 0)) / scale;
        const localY = (e.y - (graphGroup.y || 0)) / scale;
        
        activeConnectionLine.path = getCurvePath(
            (connectionStartNode.x || 0) + 180, 
            (connectionStartNode.y || 0) + 35, 
            localX, 
            localY
        );
    }
};

const onConnectionUp = (e: PointerEvent) => {
    if (activeConnectionLine && connectionStartNode) {
        // Manual coordinate conversion
        const scale = graphGroup?.scaleX || 1;
        const localX = (e.x - (graphGroup?.x || 0)) / scale;
        const localY = (e.y - (graphGroup?.y || 0)) / scale;
        const point = { x: localX, y: localY };

        let targetNodeId: string | null = null;
        
        // Check collision with any node
        const targetNode = nodes.value.find(n => {
            if (n.id === connectionStartNode!.id) return false;
            // Bounding box check
            return point.x >= n.x && point.x <= n.x + 180 &&
                   point.y >= n.y && point.y <= n.y + 70;
        });

        if (targetNode) {
            targetNodeId = targetNode.id;
        }

        if (targetNodeId) {
            const targetGroup = graphGroup?.findId(targetNodeId) as Group;
            if (targetGroup) {
                endConnection(targetGroup);
                return;
            }
        }
    }
    cancelConnection();
};

const endConnection = (targetGroup: Group) => {
    if (connectionStartNode && targetGroup) {
        const sourceId = connectionStartNode.id;
        const targetId = targetGroup.id;
        
        if (sourceId && targetId) {
            const exists = edges.value.some(e => e.sourceId === sourceId && e.targetId === targetId);
            if (!exists) {
                const newEdge: Edge = {
                    id: uuidv4(),
                    sourceId,
                    targetId
                };
                edges.value.push(newEdge);
                
                const sourceNode = nodes.value.find(n => n.id === sourceId);
                const targetNode = nodes.value.find(n => n.id === targetId);
                if (sourceNode && targetNode) {
                    createConnectionLine(sourceNode, targetNode, newEdge.id);
                }
            }
        }
    }
    cancelConnection();
};

const cancelConnection = () => {
    if (activeConnectionLine) {
        activeConnectionLine.remove();
        activeConnectionLine = null;
    }
    if (connectionStartNode) {
        connectionStartNode.draggable = true;
        connectionStartNode = null;
    }
    leaferApp?.off(PointerEvent.MOVE, onConnectionMove);
    leaferApp?.off(PointerEvent.UP, onConnectionUp);
};

// --- Drag & Drop from Toolbar ---

const getInitialData = (type: string) => {
  if (type === 'api') {
    return {
      method: 'GET',
      paramMode: 'all',
      headers: [],
      params: []
    };
  }
  if (type === 'database') {
      return {
          sourceId: 'db1',
          opType: 'select'
      };
  }
  if (type === 'script') {
      return {
          language: 'javascript'
      };
  }
  if (type === 'response') {
      return {
          contentType: 'json'
      };
  }
  return {};
};

const onDragStart = (e: DragEvent, type: string) => {
  if (e.dataTransfer) {
    e.dataTransfer.setData('type', type);
    e.dataTransfer.effectAllowed = 'copy';
  }
};

const onDrop = (e: DragEvent) => {
  e.preventDefault();
  const type = e.dataTransfer?.getData('type');
  if (type && canvasRef.value && graphGroup) {
    const rect = canvasRef.value.getBoundingClientRect();
    const clientX = e.clientX - rect.left;
    const clientY = e.clientY - rect.top;
    
    let x = clientX;
    let y = clientY;
    
    // Transform to world coordinates
    if (graphGroup) {
        const scale = graphGroup.scaleX || 1;
        x = (clientX - (graphGroup.x || 0)) / scale;
        y = (clientY - (graphGroup.y || 0)) / scale;
    }

    const newNode: Node = {
      id: uuidv4(),
      type,
      x,
      y,
      label: getNodeTitle(type),
      data: getInitialData(type)
    };
    
    nodes.value.push(newNode);
    createNodeVisual(newNode);
  }
};

// --- Selection & Properties ---

const selectNode = (id: string) => {
  selectedNodeId.value = id;
  selectedEdgeId.value = null;
  refreshVisuals();
};

const selectEdge = (id: string) => {
  selectedEdgeId.value = id;
  selectedNodeId.value = null;
  refreshVisuals();
};

const deselectAll = () => {
  selectedNodeId.value = null;
  selectedEdgeId.value = null;
  refreshVisuals();
};

const refreshVisuals = () => {
    renderGraph();
};

// --- Deletion ---

const onKeyDown = (e: KeyboardEvent) => {
    // Check if input is focused to avoid deleting when typing
    const target = e.target as HTMLElement;
    if (target.tagName === 'INPUT' || target.tagName === 'TEXTAREA') return;

    if (e.code === 'Space' && !isSpacePressed.value) {
        e.preventDefault(); 
        isSpacePressed.value = true;
        if (canvasRef.value && !isPanning) {
            canvasRef.value.style.cursor = 'grab';
        }
    }

    if (e.key === 'Delete' || e.key === 'Backspace') {
        if (selectedNodeId.value) {
            deleteNode(selectedNodeId.value);
        } else if (selectedEdgeId.value) {
            deleteEdge(selectedEdgeId.value);
        }
    }
};

const onKeyUp = (e: KeyboardEvent) => {
    if (e.code === 'Space') {
        isSpacePressed.value = false;
        if (canvasRef.value && !isPanning) {
            canvasRef.value.style.cursor = 'default';
        }
    }
};

const deleteNode = (id: string) => {
    const index = nodes.value.findIndex(n => n.id === id);
    if (index > -1) {
        nodes.value.splice(index, 1);
        edges.value = edges.value.filter(e => e.sourceId !== id && e.targetId !== id);
        selectedNodeId.value = null;
        renderGraph();
    }
};

const deleteEdge = (id: string) => {
    const index = edges.value.findIndex(e => e.id === id);
    if (index > -1) {
        edges.value.splice(index, 1);
        selectedEdgeId.value = null;
        renderGraph();
    }
};

const updateNodeLabel = () => {
  if (selectedNodeId.value) {
    refreshVisuals();
  }
};

const updateNodeVisual = () => {
  refreshVisuals();
};

defineExpose({
  nodes,
  edges,
  selectNode,
  clearSelection: deselectAll
});
</script>

<style scoped>
.flow-container {
  display: flex;
  height: 100%;
  position: relative;
  overflow: hidden;
}

.flow-toolbar {
  width: 200px;
  background: #f5f5f5;
  border-right: 1px solid #ddd;
  padding: 16px;
  display: flex;
  flex-direction: column;
  gap: 12px;
  z-index: 2;
}

.tool-item {
  background: #fff;
  padding: 10px;
  border: 1px solid #e8e8e8;
  border-radius: 4px;
  cursor: grab;
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  transition: all 0.3s;
}

.tool-item:hover {
  border-color: #1890ff;
  color: #1890ff;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.flow-main {
  flex: 1;
  display: flex;
  flex-direction: column;
  position: relative;
  overflow: hidden;
}

.flow-canvas {
  flex: 1;
  background: #f0f2f5;
  position: relative;
  overflow: hidden;
  touch-action: none;
}

.props-content {
  padding: 16px;
  flex: 1;
  overflow-y: auto;
}
</style>