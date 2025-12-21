<template>
  <div class="workflow-container">
    <div class="workflow-toolbar">
      <div 
        class="draggable-item" 
        draggable="true" 
        @dragstart="onDragStart($event, 'extract')"
      >
        <DatabaseOutlined /> 数据抽取 (Extract)
      </div>
      <div 
        class="draggable-item" 
        draggable="true" 
        @dragstart="onDragStart($event, 'transform')"
      >
        <FunctionOutlined /> 数据转换 (Transform)
      </div>
      <div 
        class="draggable-item" 
        draggable="true" 
        @dragstart="onDragStart($event, 'load')"
      >
        <SaveOutlined /> 数据加载 (Load)
      </div>
    </div>

    <div 
        class="workflow-canvas-wrapper" 
        ref="canvasContainer" 
        @drop="onDrop" 
        @dragover.prevent
    >
      <!-- Leafer Canvas will be mounted here -->
    </div>

    <div class="workflow-properties" v-if="selectedNodeId">
        <div class="prop-header">
            <span>节点属性</span>
            <a @click="deselectNode">关闭</a>
        </div>
        <div class="prop-body">
            <a-form layout="vertical" :model="selectedNodeData">
                 <!-- Extract Config -->
              <div v-if="props.nodes.find(n => n.id === selectedNodeId)?.type === 'extract'">
                <a-form-item label="数据源">
                    <a-select v-model:value="selectedNodeData.sourceId" placeholder="选择数据源">
                        <a-select-option value="db1">主业务库 (MySQL)</a-select-option>
                        <a-select-option value="db2">日志库 (MongoDB)</a-select-option>
                        <a-select-option value="api1">CRM接口</a-select-option>
                    </a-select>
                </a-form-item>
                <a-form-item label="查询SQL">
                    <a-textarea v-model:value="selectedNodeData.query" :rows="4" />
                </a-form-item>
              </div>

              <!-- Transform Config -->
              <div v-if="props.nodes.find(n => n.id === selectedNodeId)?.type === 'transform'">
                <a-form-item label="处理方式">
                    <a-select v-model:value="selectedNodeData.method">
                        <a-select-option value="filter">数据过滤</a-select-option>
                        <a-select-option value="map">字段映射</a-select-option>
                        <a-select-option value="script">JS脚本处理</a-select-option>
                    </a-select>
                </a-form-item>
                <a-form-item label="脚本内容">
                     <a-textarea v-model:value="selectedNodeData.script" :rows="4" />
                </a-form-item>
              </div>

              <!-- Load Config -->
              <div v-if="props.nodes.find(n => n.id === selectedNodeId)?.type === 'load'">
                <a-form-item label="目标数据源">
                    <a-select v-model:value="selectedNodeData.targetId">
                        <a-select-option value="dw1">数据仓库 (ClickHouse)</a-select-option>
                        <a-select-option value="db1">报表库 (MySQL)</a-select-option>
                    </a-select>
                </a-form-item>
                <a-form-item label="目标表">
                    <a-input v-model:value="selectedNodeData.targetTable" />
                </a-form-item>
                <a-form-item label="写入模式">
                    <a-radio-group v-model:value="selectedNodeData.mode">
                        <a-radio value="append">追加</a-radio>
                        <a-radio value="overwrite">覆盖</a-radio>
                    </a-radio-group>
                </a-form-item>
              </div>
            </a-form>
        </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted, nextTick } from 'vue';
import { 
  DatabaseOutlined, 
  FunctionOutlined, 
  SaveOutlined 
} from '@ant-design/icons-vue';
import { Leafer, Rect, Text, Group, Line, Ellipse, PointerEvent, Path } from 'leafer-ui';
import '@leafer-in/find';
import '@leafer-in/arrow';
import { v4 as uuidv4 } from 'uuid';

interface NodeData {
  id: string;
  type: 'extract' | 'transform' | 'load';
  x: number;
  y: number;
  data: any;
}

interface EdgeData {
  id: string;
  sourceId: string;
  targetId: string;
}

const props = defineProps<{
  nodes: NodeData[];
  edges: EdgeData[];
}>();

const canvasContainer = ref<HTMLElement | null>(null);
const selectedNodeId = ref<string | null>(null);
const selectedNodeData = ref<any>(null);
const selectedEdgeId = ref<string | null>(null);

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

const initLeafer = () => {
  if (!canvasContainer.value) return;
  
  // Wait for container to have size
  if (canvasContainer.value.clientWidth === 0 || canvasContainer.value.clientHeight === 0) {
      setTimeout(initLeafer, 100);
      return;
  }

  if (leaferApp) {
    leaferApp.destroy();
  }

  leaferApp = new Leafer({
    view: canvasContainer.value,
    fill: '#f0f2f5', // Canvas background
  });

  graphGroup = new Group({ id: 'graph-group' });
  leaferApp.add(graphGroup);

  // Load existing nodes/edges
  renderGraph();

  // Event Listeners
  leaferApp.on(PointerEvent.TAP, (e: PointerEvent) => {
    // Check if clicked on a node
    let target = e.target;
    while(target && target.tag !== 'Leafer' && target.id !== 'graph-group') {
        if (target.tag === 'Group' && target.id && target.name === 'node-group') {
            selectNode(target.id);
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
    deselectNode();
    deselectEdge();
  });

  setupInteractions();
};

const renderGraph = () => {
    if (!leaferApp || !graphGroup) return;
    graphGroup.clear(); // Clear graphGroup instead of leaferApp

    // Render Edges
    props.edges.forEach(edge => {
        const sourceNode = props.nodes.find(n => n.id === edge.sourceId);
        const targetNode = props.nodes.find(n => n.id === edge.targetId);
        if (sourceNode && targetNode) {
            createConnectionLine(sourceNode, targetNode, edge.id);
        }
    });

    // Render Nodes
    props.nodes.forEach(node => {
        createNodeVisual(node);
    });
    
    fitView(); // Auto fit
};

const createNodeVisual = (node: NodeData) => {
    if (!leaferApp) return;

    const group = new Group({
        id: node.id,
        name: 'node-group',
        x: node.x,
        y: node.y,
        draggable: true,
        cursor: 'move'
    });

    const colorMap: Record<string, string> = {
        extract: '#1890ff',
        transform: '#faad14',
        load: '#52c41a'
    };

    const rect = new Rect({
        width: 180,
        height: 70,
        fill: '#fff',
        stroke: colorMap[node.type] || '#999',
        strokeWidth: 2,
        cornerRadius: 4,
        shadow: { x: 0, y: 2, blur: 8, color: 'rgba(0,0,0,0.1)' }
    });

    const text = new Text({
        text: getStepTypeName(node.type),
        fill: '#333',
        fontSize: 14,
        fontWeight: 'bold',
        x: 10,
        y: 8,
        pointerEvents: 'none' // Let clicks pass to group
    });

    // Detail Text
    let detailContent = '';
    const data = node.data || {};
    if (node.type === 'extract') {
        detailContent = `Source: ${data.sourceId || '-'}`;
    } else if (node.type === 'transform') {
        const methodMap: Record<string, string> = { filter: 'Filter', map: 'Map', script: 'Script' };
        detailContent = `Method: ${methodMap[data.method] || data.method || '-'}`;
    } else if (node.type === 'load') {
        detailContent = `Target: ${data.targetId || '-'}\nTable: ${data.targetTable || '-'}`;
    }

    const detailText = new Text({
        text: detailContent,
        fill: '#888',
        fontSize: 12,
        x: 10,
        y: 30,
        lineHeight: 16,
        pointerEvents: 'none'
    });

    // Input Port (Left)
    const inPort = new Ellipse({
        width: 10,
        height: 10,
        fill: '#fff',
        stroke: '#666',
        strokeWidth: 1,
        x: -5,
        y: 30,
        cursor: 'crosshair',
        name: 'port-in'
    });

    // Output Port (Right)
    const outPort = new Ellipse({
        width: 10,
        height: 10,
        fill: '#fff',
        stroke: '#666',
        strokeWidth: 1,
        x: 175,
        y: 30,
        cursor: 'crosshair',
        name: 'port-out'
    });

    // Port Events
    outPort.on(PointerEvent.DOWN, (e: PointerEvent) => {
        e.stop(); // Prevent dragging the node
        group.draggable = false;
        startConnection(group);
    });
    
    group.add(rect);
    group.add(text);
    group.add(detailText);
    group.add(inPort);
    group.add(outPort);

    // Update data on drag
    group.on('drag', () => {
        const n = props.nodes.find(item => item.id === node.id);
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

const getStepTypeName = (type: string) => {
  const map: Record<string, string> = {
    extract: '抽取 (Extract)',
    transform: '转换 (Transform)',
    load: '加载 (Load)'
  };
  return map[type];
};

// ... Helper functions like getCurvePath, checkAlignment, etc. ...
// I will include all of them.

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
    for (const otherNode of props.nodes) {
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
        vGuideLine.points = [vLineX, 0, vLineX, 2000];
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
        hGuideLine.points = [0, hLineY, 2000, hLineY];
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

const getCurvePath = (x1: number, y1: number, x2: number, y2: number) => {
    const offset = Math.max(Math.abs(x2 - x1) * 0.5, 50);
    const cp1x = x1 + offset;
    const cp1y = y1;
    const cp2x = x2 - offset;
    const cp2y = y2;
    return `M ${x1} ${y1} C ${cp1x} ${cp1y} ${cp2x} ${cp2y} ${x2} ${y2}`;
};

const createConnectionLine = (source: NodeData, target: NodeData, id: string) => {
    if (!leaferApp || !graphGroup) return;
    
    const pathData = getCurvePath(
        source.x + 180, source.y + 35,
        target.x, target.y + 35
    );

    const line = new Path({
        id: id,
        name: 'connection-line',
        stroke: '#999',
        strokeWidth: 2,
        path: pathData,
        endArrow: 'arrow',
        cursor: 'pointer'
    });
    
    graphGroup.add(line);
};

const updateConnectedLines = (nodeId: string) => {
    // Find edges connected to this node
    props.edges.forEach(edge => {
        if (edge.sourceId === nodeId || edge.targetId === nodeId) {
            const line = graphGroup?.findId(edge.id) as Path;
            const source = props.nodes.find(n => n.id === edge.sourceId);
            const target = props.nodes.find(n => n.id === edge.targetId);
            
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
    // Create temp line
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
    
    // Bind global move
    leaferApp?.on(PointerEvent.MOVE, onConnectionMove);
    leaferApp?.on(PointerEvent.UP, onConnectionUp);
};

const onConnectionMove = (e: PointerEvent) => {
    if (activeConnectionLine && connectionStartNode && graphGroup) {
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
        const scale = graphGroup?.scaleX || 1;
        const localX = (e.x - (graphGroup?.x || 0)) / scale;
        const localY = (e.y - (graphGroup?.y || 0)) / scale;
        const point = { x: localX, y: localY };

        let targetNodeId: string | null = null;
        
        // Iterate through all nodes to check if we are dropping near an inPort
        for (const node of props.nodes) {
            // Skip self
            if (node.id === connectionStartNode.id) continue;
            
            const inPortCenterX = node.x;
            const inPortCenterY = node.y + 35;
            
            // Check distance (radius 5 + 15px buffer = 20px detection radius)
            const dist = Math.sqrt(
                Math.pow(point.x - inPortCenterX, 2) + 
                Math.pow(point.y - inPortCenterY, 2)
            );
            
            if (dist < 20) {
                targetNodeId = node.id;
                break;
            }
        }

        if (targetNodeId) {
            const targetGroup = graphGroup?.findId(targetNodeId) as Group;
            if (targetGroup) {
                endConnection(targetGroup);
                return;
            }
        }
    }

    // If dropped on empty space or invalid target, cancel
    cancelConnection();
};

const endConnection = (targetGroup: Group) => {
    if (connectionStartNode && targetGroup) {
        const sourceId = connectionStartNode.id;
        const targetId = targetGroup.id;
        
        if (sourceId && targetId) {
            // Check duplicates
            const exists = props.edges.some(e => e.sourceId === sourceId && e.targetId === targetId);
            if (!exists) {
                const newEdge: EdgeData = {
                    id: uuidv4(),
                    sourceId,
                    targetId
                };
                props.edges.push(newEdge);
                
                // Draw real line
                const sourceNode = props.nodes.find(n => n.id === sourceId);
                const targetNode = props.nodes.find(n => n.id === targetId);
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

const onDragStart = (event: DragEvent, type: string) => {
    if (event.dataTransfer) {
        event.dataTransfer.setData('type', type);
        event.dataTransfer.effectAllowed = 'copy';
    }
};

const onDrop = (event: DragEvent) => {
    event.preventDefault();
    const type = event.dataTransfer?.getData('type') as 'extract' | 'transform' | 'load';
    if (type && canvasContainer.value && graphGroup) {
        const rect = canvasContainer.value.getBoundingClientRect();
        const screenX = event.clientX - rect.left;
        const screenY = event.clientY - rect.top;
        
        // Convert to Graph Coordinates
        const scale = graphGroup.scaleX || 1;
        const x = (screenX - (graphGroup.x || 0)) / scale;
        const y = (screenY - (graphGroup.y || 0)) / scale;
        
        const newNode: NodeData = {
            id: uuidv4(),
            type,
            x,
            y,
            data: {} // Init data
        };
        
        props.nodes.push(newNode);
        createNodeVisual(newNode);
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
    if (leaferApp) leaferApp.cursor = 'auto';
    window.removeEventListener('mousemove', onGlobalMove);
    window.removeEventListener('mouseup', onGlobalUp);
};

const setupInteractions = () => {
    if (!leaferApp || !canvasContainer.value) return;

    // Pan (Start)
    leaferApp.on(PointerEvent.DOWN, (e: PointerEvent) => {
        const originEvent = (e.origin || (e as any).event) as PointerEvent;
        if (!originEvent) return;

        // Check if target is interactive (Node, Port, etc.)
        let isInteractive = false;
        let curr = e.target;
        while (curr && curr.tag !== 'Leafer' && curr.id !== 'graph-group') {
            // Check for specific interactive elements by name or properties
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
            // Stop propagation to prevent node selection/drag if we are forcing pan (e.g. space key)
            if (isSpacePressed.value || isMiddleBtn) {
                 e.stop(); 
            }

            isPanning = true;
            // Use native event client coordinates
            const clientX = (originEvent as any).clientX;
            const clientY = (originEvent as any).clientY;
            
            if (typeof clientX === 'number') {
                lastPanX = clientX;
                lastPanY = clientY;
                leaferApp!.cursor = 'grabbing';
                
                // Attach global listeners
                window.addEventListener('mousemove', onGlobalMove);
                window.addEventListener('mouseup', onGlobalUp);
            }
        }
    });
    
    // Zoom (Ctrl + Wheel)
    canvasContainer.value.addEventListener('wheel', (e: WheelEvent) => {
        if (e.ctrlKey && graphGroup) {
            e.preventDefault();
            e.stopPropagation();

            const currentScale = (graphGroup.scaleX || 1);
            const zoomFactor = e.deltaY > 0 ? 0.9 : 1.1;
            let newScale = currentScale * zoomFactor;
            
            // Limit scale
            newScale = Math.max(0.1, Math.min(newScale, 5));
            
            const rect = canvasContainer.value!.getBoundingClientRect();
            const mouseX = e.clientX - rect.left;
            const mouseY = e.clientY - rect.top;
            
            const localX = (mouseX - (graphGroup.x || 0)) / currentScale;
            const localY = (mouseY - (graphGroup.y || 0)) / currentScale;
            
            graphGroup.scale = newScale;
            graphGroup.x = mouseX - localX * newScale;
            graphGroup.y = mouseY - localY * newScale;
        }
    }, { passive: false });

    // Touch Zoom (Pinch)
    let initialPinchDistance: number | null = null;
    let initialScale = 1;
    let initialGraphX = 0;
    let initialGraphY = 0;
    let initialCenterPoint: { x: number, y: number } | null = null;

    canvasContainer.value.addEventListener('touchstart', (e: TouchEvent) => {
        if (e.touches.length === 2 && graphGroup) {
            e.preventDefault();
            if (!e.touches[0] || !e.touches[1]) return;
            const dx = e.touches[0].clientX - e.touches[1].clientX;
            const dy = e.touches[0].clientY - e.touches[1].clientY;
            initialPinchDistance = Math.sqrt(dx * dx + dy * dy);
            initialScale = graphGroup.scaleX || 1;
            initialGraphX = graphGroup.x || 0;
            initialGraphY = graphGroup.y || 0;
            
            const rect = canvasContainer.value!.getBoundingClientRect();
            const centerClientX = (e.touches[0].clientX + e.touches[1].clientX) / 2;
            const centerClientY = (e.touches[0].clientY + e.touches[1].clientY) / 2;
            initialCenterPoint = {
                x: centerClientX - rect.left,
                y: centerClientY - rect.top
            };
        }
    }, { passive: false });

    canvasContainer.value.addEventListener('touchmove', (e: TouchEvent) => {
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
            
            const rect = canvasContainer.value!.getBoundingClientRect();
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
    
    canvasContainer.value.addEventListener('touchend', (e: TouchEvent) => {
        if (e.touches.length < 2) {
            initialPinchDistance = null;
            initialCenterPoint = null;
        }
        if (e.touches.length === 0) {
            onGlobalUp();
        }
    });

    canvasContainer.value.addEventListener('touchcancel', (_e: TouchEvent) => {
        initialPinchDistance = null;
        initialCenterPoint = null;
        onGlobalUp();
    });
};

const fitView = () => {
    if (!graphGroup || props.nodes.length === 0 || !canvasContainer.value) {
        if (graphGroup) {
            graphGroup.x = 0;
            graphGroup.y = 0;
            graphGroup.scale = 1;
        }
        return;
    }

    // Calculate bounds
    let minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity;
    
    props.nodes.forEach(node => {
        minX = Math.min(minX, node.x);
        minY = Math.min(minY, node.y);
        maxX = Math.max(maxX, node.x + 180);
        maxY = Math.max(maxY, node.y + 70);
    });

    const padding = 50;
    const contentWidth = maxX - minX;
    const contentHeight = maxY - minY;
    
    const containerWidth = canvasContainer.value.clientWidth;
    const containerHeight = canvasContainer.value.clientHeight;
    
    let scale = 1;
    if (contentWidth > 0 && contentHeight > 0) {
        const scaleX = (containerWidth - padding * 2) / contentWidth;
        const scaleY = (containerHeight - padding * 2) / contentHeight;
        scale = Math.min(scaleX, scaleY);
    }
    
    scale = Math.min(scale, 1);
    
    graphGroup.scale = scale;
    graphGroup.x = containerWidth / 2 - (minX + contentWidth / 2) * scale;
    graphGroup.y = containerHeight / 2 - (minY + contentHeight / 2) * scale;
};

const selectNode = (id: string) => {
    const prevId = selectedNodeId.value;
    if (selectedEdgeId.value) deselectEdge();
    
    selectedNodeId.value = id;
    const node = props.nodes.find(n => n.id === id);
    if (node) {
        selectedNodeData.value = node.data;
    }

    if (prevId !== id) {
        updateNodeVisual(prevId);
        updateNodeVisual(id);
    }
};

const deselectNode = () => {
    const prevId = selectedNodeId.value;
    selectedNodeId.value = null;
    selectedNodeData.value = null;
    updateNodeVisual(prevId);
};

const updateNodeVisual = (id: string | null) => {
    if (!id || !graphGroup) return;
    const nodeGroup = graphGroup.findId(id) as Group;
    if (!nodeGroup) return;
    
    const isSelected = id === selectedNodeId.value;
    const rect = nodeGroup.children[0] as Rect;
    
    if (rect) {
         const node = props.nodes.find(n => n.id === id);
         const colorMap: Record<string, string> = {
              extract: '#1890ff',
              transform: '#faad14',
              load: '#52c41a'
         };
         const baseColor = node ? (colorMap[node.type] || '#999') : '#999';

         rect.stroke = isSelected ? '#1890ff' : baseColor;
         rect.strokeWidth = isSelected ? 3 : 2;
         rect.shadow = isSelected 
            ? { x: 0, y: 4, blur: 12, color: 'rgba(24, 144, 255, 0.4)' } 
            : { x: 0, y: 2, blur: 8, color: 'rgba(0,0,0,0.1)' };
    }
};

const selectEdge = (id: string) => {
    if (selectedNodeId.value) deselectNode();
    
    if (selectedEdgeId.value && selectedEdgeId.value !== id) {
        const prevLine = graphGroup?.findId(selectedEdgeId.value) as Path;
        if (prevLine) {
            prevLine.stroke = '#999';
            prevLine.strokeWidth = 2;
        }
    }

    selectedEdgeId.value = id;
    const line = graphGroup?.findId(id) as Path;
    if (line) {
        line.stroke = '#1890ff';
        line.strokeWidth = 3;
    }
};

const deselectEdge = () => {
    if (selectedEdgeId.value) {
        const line = graphGroup?.findId(selectedEdgeId.value) as Path;
        if (line) {
            line.stroke = '#999';
            line.strokeWidth = 2;
        }
        selectedEdgeId.value = null;
    }
};

const deleteNode = (id: string) => {
    // Remove edges connected to this node
    const edgesToRemove = props.edges.filter(edge => edge.sourceId === id || edge.targetId === id);
    edgesToRemove.forEach(edge => deleteEdge(edge.id));

    // Remove node data
    const nodeIndex = props.nodes.findIndex(n => n.id === id);
    if (nodeIndex !== -1) {
        props.nodes.splice(nodeIndex, 1);
    }

    // Remove visual
    const nodeGroup = graphGroup?.findId(id);
    if (nodeGroup) {
        nodeGroup.remove();
    }
    
    deselectNode();
};

const deleteEdge = (id: string) => {
    // Remove edge data
    const edgeIndex = props.edges.findIndex(e => e.id === id);
    if (edgeIndex !== -1) {
        props.edges.splice(edgeIndex, 1);
    }

    // Remove visual
    const line = graphGroup?.findId(id);
    if (line) {
        line.remove();
    }

    if (selectedEdgeId.value === id) {
        deselectEdge();
    }
};

const onKeyDown = (e: KeyboardEvent) => {
    if (e.code === 'Space' && !isSpacePressed.value) {
        isSpacePressed.value = true;
        if (leaferApp && !isPanning) leaferApp.cursor = 'grab';
        if (graphGroup) graphGroup.hitChildren = false;
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
        if (leaferApp && !isPanning) leaferApp.cursor = 'auto';
        if (graphGroup) graphGroup.hitChildren = true;
    }
};

const destroyLeafer = () => {
    if (leaferApp) {
        leaferApp.destroy();
        leaferApp = null;
    }
    window.removeEventListener('mousemove', onGlobalMove);
    window.removeEventListener('mouseup', onGlobalUp);
    window.removeEventListener('keydown', onKeyDown);
    window.removeEventListener('keyup', onKeyUp);
};

onMounted(() => {
    nextTick(initLeafer);
    window.addEventListener('keydown', onKeyDown);
    window.addEventListener('keyup', onKeyUp);
});

onUnmounted(() => {
    destroyLeafer();
});
</script>

<style scoped>
.workflow-container {
  display: flex;
  height: 100%;
  border: 1px solid #f0f0f0;
  border-radius: 4px;
  overflow: hidden;
  position: relative; /* For absolute positioning of children */
}

.workflow-toolbar {
  width: 250px;
  flex-shrink: 0;
  padding: 16px;
  border-right: 1px solid #f0f0f0;
  background: #fafafa;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.draggable-item {
  padding: 12px;
  background: #fff;
  border: 1px solid #d9d9d9;
  border-radius: 4px;
  cursor: grab;
  user-select: none;
  display: flex;
  align-items: center;
  gap: 8px;
}

.draggable-item:hover {
  border-color: #1890ff;
  color: #1890ff;
}

.workflow-canvas-wrapper {
  flex: 1;
  height: 100%;
  position: relative;
  background: #f0f2f5;
  overflow: hidden;
}

.workflow-properties {
    position: absolute;
    right: 0;
    top: 0;
    bottom: 0;
    width: 300px;
    background: #fff;
    border-left: 1px solid #f0f0f0;
    box-shadow: -2px 0 8px rgba(0,0,0,0.1);
    display: flex;
    flex-direction: column;
    z-index: 10;
}

.prop-header {
    padding: 16px;
    border-bottom: 1px solid #f0f0f0;
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-weight: bold;
}

.prop-body {
    padding: 16px;
    overflow-y: auto;
    flex: 1;
}
</style>
