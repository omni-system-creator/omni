<template>
  <div class="sys-org-container" @click="closeContextMenu">
    <div class="canvas-container" ref="canvasContainer" @contextmenu.prevent="handleContextMenu"></div>

    <!-- 右键菜单 -->
    <div v-if="contextMenuVisible" class="custom-context-menu"
      :style="{ left: contextMenuPos.x + 'px', top: contextMenuPos.y + 'px' }" @click.stop>

      <!-- Canvas Menu Items -->
      <template v-if="contextMenuType === 'canvas'">
        <div class="menu-item" @click="handleAddRootAndClose">
          <PlusOutlined /> 新增根节点
        </div>
        <div class="menu-divider"></div>
        <div class="menu-item" @click="fitViewAndClose">
          <ExpandOutlined /> 适应屏幕
        </div>
        <div class="menu-item" @click="refreshAndClose">
          <ReloadOutlined /> 刷新
        </div>
        <div class="menu-divider"></div>
        <div class="menu-item" @click="exportAsImageAndClose">
          <CameraOutlined /> 复制为图片
        </div>
      </template>

      <!-- Node Menu Items -->
      <template v-else-if="contextMenuType === 'node'">
        <div v-if="showAutoArrange" class="menu-item" @click="handleAutoArrangeAndClose">
          <AppstoreOutlined /> 自动排列
        </div>
        <div class="menu-item" @click="handleAddChildAndClose">
          <PlusOutlined /> 新增子节点
        </div>
        <div class="menu-item" @click="handleEditAndClose">
          <EditOutlined /> 编辑
        </div>
        <div class="menu-divider"></div>
        <div class="menu-item danger" @click="handleDeleteAndClose">
          <DeleteOutlined /> 删除
        </div>
      </template>
    </div>

    <a-modal v-model:open="modalVisible" :title="modalTitle" @ok="handleModalOk" :confirmLoading="confirmLoading">
      <a-form ref="formRef" :model="formState" :rules="rules" layout="vertical">
        <a-form-item label="上级" name="parentId">
          <a-tree-select v-model:value="formState.parentId" :tree-data="deptTreeSelectData" placeholder="请选择上级"
            allow-clear tree-default-expand-all disabled>
            <template #title="{ label, type }">
              <span v-if="type === DeptType.Group">
                <BankOutlined style="color: #faad14; margin-right: 4px" />
              </span>
              <span v-else-if="type === DeptType.Company">
                <ApartmentOutlined style="color: #1890ff; margin-right: 4px" />
              </span>
              <span v-else-if="type === DeptType.Department">
                <ClusterOutlined style="color: #8c8c8c; margin-right: 4px" />
              </span>
              {{ label }}
            </template>
          </a-tree-select>
        </a-form-item>
        <a-form-item label="名称" name="name">
          <a-input v-model:value="formState.name" placeholder="请输入名称" />
        </a-form-item>
        <a-form-item label="类型" name="type">
          <a-select v-model:value="formState.type">
            <a-select-option :value="DeptType.Group">集团</a-select-option>
            <a-select-option :value="DeptType.Company">公司</a-select-option>
            <a-select-option :value="DeptType.Department">部门</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="编码" name="code">
          <a-input v-model:value="formState.code" placeholder="请输入编码" />
        </a-form-item>
        <a-form-item label="负责人" name="leader">
          <a-input v-model:value="formState.leader" placeholder="请输入负责人姓名" />
        </a-form-item>
        <a-form-item label="联系电话" name="phone">
          <a-input v-model:value="formState.phone" placeholder="请输入联系电话" />
        </a-form-item>
        <a-form-item label="邮箱" name="email">
          <a-input v-model:value="formState.email" placeholder="请输入邮箱" />
        </a-form-item>
        <a-form-item label="排序" name="sortOrder">
          <a-input-number v-model:value="formState.sortOrder" :min="0" style="width: 100%" />
        </a-form-item>
        <a-form-item label="状态" name="isActive">
          <a-switch v-model:checked="formState.isActive" />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed, reactive, onUnmounted, createVNode } from 'vue';
import { message, Modal } from 'ant-design-vue';
import {
  PlusOutlined, EditOutlined, DeleteOutlined,
  BankOutlined, ApartmentOutlined, ClusterOutlined,
  ExclamationCircleOutlined, ExpandOutlined, ReloadOutlined,
  CameraOutlined, AppstoreOutlined
} from '@ant-design/icons-vue';
import {
  getDeptTree, createDept, updateDept, deleteDept, updateDeptStructure,
  type Dept, DeptType, type UpdateDeptStructureParams
} from '@/api/dept';
import { App, Rect, Text, Group, Line, Ellipse, PointerEvent, DragEvent } from 'leafer-ui';
import '@leafer-in/find'; // 导入查找插件
import '@leafer-in/export'; // 导入导出插件

const loading = ref(false);
const deptList = ref<Dept[]>([]);
const canvasContainer = ref<HTMLElement | null>(null);
let app: App | null = null;
let treeLayer: Group | null = null;

// Context Menu State
const contextMenuVisible = ref(false);
const contextMenuType = ref<'canvas' | 'node'>('canvas');
const contextMenuPos = reactive({ x: 0, y: 0 });
const showAutoArrange = ref(false);

// DOM context menu handler - only prevents default browser menu
const handleContextMenu = () => {
  // Logic moved to Leafer events
};

const closeContextMenu = () => {
  contextMenuVisible.value = false;
};

const handleAddRootAndClose = () => {
  handleAddRoot();
  closeContextMenu();
};

const handleAutoArrangeAndClose = async () => {
  const node = findNodeById(deptList.value, currentId.value!);
  if (node) {
    try {
      node.x = undefined;
      node.y = undefined;
      renderChart();

      await updateDept(node.id, { resetPosition: true });
      message.success('已恢复自动排列');
      fetchDeptTree();
    } catch (error) {
      console.error(error);
      message.error('操作失败');
      fetchDeptTree();
    }
  }
  closeContextMenu();
};

const handleAddChildAndClose = () => {
  const node = findNodeById(deptList.value, currentId.value!);
  if (node) {
    handleAdd(node);
  }
  closeContextMenu();
};

const handleEditAndClose = () => {
  const node = findNodeById(deptList.value, currentId.value!);
  if (node) {
    handleEdit(node);
  }
  closeContextMenu();
};

const handleDeleteAndClose = () => {
  handleDelete();
  closeContextMenu();
};

const findNodeById = (nodes: Dept[], id: number): Dept | null => {
  for (const node of nodes) {
    if (node.id === id) return node;
    if (node.children) {
      const found = findNodeById(node.children, id);
      if (found) return found;
    }
  }
  return null;
};

const fitViewAndClose = () => {
  fitView();
  closeContextMenu();
};

const refreshAndClose = () => {
  refresh();
  closeContextMenu();
};

const exportAsImageAndClose = async () => {
  closeContextMenu();
  if (!app || !treeLayer) return;

  try {
    // 1. 获取完整内容边界
    const bounds = treeLayer.getBounds();
    if (!bounds || bounds.width === 0 || bounds.height === 0) {
      message.warning('画布为空，无法导出');
      return;
    }

    // 2. 导出配置
    const exportOptions = {
      quality: 1,
      pixelRatio: 2, // 高清导出
      padding: 20, // 增加内边距
      fill: '#ffffff' // 确保背景为白色
    };

    // 3. 导出为 Blob
    // Leafer 的 export 方法可以直接导出整个应用或特定层
    // 导出 treeLayer (内容层) 而不是整个 app，这样可以自动裁剪空白
    // 注意：export 方法在某些版本中可能返回 Promise<IExportResult>

    const result = await treeLayer.export('png', exportOptions);

    console.log('Export result:', result); // Debug info

    if (result && result.data) {
      // 4. 复制到剪贴板
      // result.data 是 base64 字符串或者 Blob，取决于配置。

      // 将 dataURL 转为 Blob
      const res = await fetch(result.data);
      const blob = await res.blob();

      if (navigator.clipboard && navigator.clipboard.write) {
        const item = new ClipboardItem({ 'image/png': blob });
        await navigator.clipboard.write([item]);
        message.success('图片已复制到剪贴板');
      } else {
        // 降级处理：尝试使用 document.execCommand 或者提示用户
        console.warn('Clipboard API not supported or permission denied');
        message.error('当前浏览器不支持自动复制，请尝试右键另存为');

        // 可选：在新窗口打开图片让用户手动保存
        // window.open(result.data);
      }
    } else {
      console.error('Export result is empty or invalid', result);
      message.error('导出结果为空');
    }

  } catch (error) {
    console.error('Export image failed:', error);
    message.error('导出图片失败');
  }
};

// Layout Constants
const NODE_WIDTH = 180;
const NODE_HEIGHT = 90;
const GAP_X = 30;
const GAP_Y = 80;
const COLOR_GROUP = '#faad14';
const COLOR_COMPANY = '#1890ff';
const COLOR_DEPT = '#8c8c8c';
const BG_COLOR = '#ffffff';

const fetchDeptTree = async () => {
  loading.value = true;
  try {
    const res = await getDeptTree();
    deptList.value = res || [];
    renderChart();
  } catch (error) {
    console.error(error);
  } finally {
    loading.value = false;
  }
};

const refresh = () => {
  fetchDeptTree();
};

// --- Layout Algorithm ---

interface LayoutNode extends Dept {
  _width?: number; // Total subtree width
  _x?: number;
  _y?: number;
  children?: LayoutNode[];
}

// 辅助线图层
let guideLayer: Group | null = null;
// 存储节点与线的关系，用于拖动更新
const nodeLinesMap = new Map<number, { incoming: LineInfo | null, outgoing: LineInfo[] }>();

const calculateSubtreeWidth = (node: LayoutNode): number => {
  if (!node.children || node.children.length === 0) {
    node._width = NODE_WIDTH;
    return NODE_WIDTH;
  }
  let width = 0;
  node.children.forEach((child, index) => {
    width += calculateSubtreeWidth(child);
    if (index < (node.children?.length || 0) - 1) {
      width += GAP_X;
    }
  });
  // Ensure parent is at least NODE_WIDTH, but usually children width dominates
  node._width = Math.max(NODE_WIDTH, width);
  return node._width;
};

const assignCoordinates = (node: LayoutNode, x: number, y: number) => {
  // Center the node within its allocated subtree width
  // x is the left boundary of the area allocated for this node and its children

  // node's own position should be centered in its _width
  node._x = x + (node._width! / 2) - (NODE_WIDTH / 2);
  node._y = y;

  let currentChildX = x;
  // If the node's width is determined by NODE_WIDTH (single child or no children narrower than parent), 
  // we need to center the children relative to the parent? 
  // Actually the logic above sets _width to be at least NODE_WIDTH.
  // If children total width < NODE_WIDTH, we need to center children.

  let childrenTotalWidth = 0;
  if (node.children && node.children.length > 0) {
    node.children.forEach((child, idx) => {
      childrenTotalWidth += child._width!;
      if (idx < node.children!.length - 1) childrenTotalWidth += GAP_X;
    });

    // If children are narrower than parent (unlikely with GAP_X, but possible), center them
    if (childrenTotalWidth < node._width!) {
      currentChildX = x + (node._width! - childrenTotalWidth) / 2;
    }

    node.children.forEach(child => {
      assignCoordinates(child, currentChildX, y + NODE_HEIGHT + GAP_Y);
      currentChildX += child._width! + GAP_X;
    });
  }
};

const renderChart = () => {
  if (!app) return;

  // 先隐藏根节点，避免布局计算过程中的视觉跳动
  app.tree.visible = false;
  app.tree.opacity = 1; // 重置 opacity，主要用 visible 控制

  // Clear previous content
  app.tree.clear();
  treeLayer = new Group();
  app.tree.add(treeLayer);

  if (deptList.value.length === 0) {
    const text = new Text({
      text: '暂无数据，请“新增根节点”',
      x: (app.width || 0) / 2,
      y: (app.height || 0) / 2,
      textAlign: 'center',
      verticalAlign: 'middle',
      fill: '#999',
      fontSize: 16
    });
    treeLayer.add(text);
    app.tree.visible = true; // 恢复显示
    return;
  }

  // 1. Calculate Layout
  // Assume multiple roots are laid out horizontally
  let totalWidth = 0;
  const roots = deptList.value as LayoutNode[];

  roots.forEach((root, idx) => {
    totalWidth += calculateSubtreeWidth(root);
    if (idx < roots.length - 1) totalWidth += GAP_X * 2; // Extra gap between trees
  });

  let currentRootX = 0;
  // Start drawing
  roots.forEach(root => {
    assignCoordinates(root, currentRootX, 50); // Start Y at 50

    // Apply saved positions (Override layout)
    const applySavedPos = (node: LayoutNode) => {
      if (typeof node.x === 'number' && typeof node.y === 'number') {
        node._x = node.x;
        node._y = node.y;
      }
      if (node.children) node.children.forEach(applySavedPos);
    };
    applySavedPos(root);

    drawNodeRecursive(root);
    currentRootX += root._width! + GAP_X * 2;
  });

  // Add Guide Layer on top
  guideLayer = new Group({ zIndex: 100 }); // High z-index
  treeLayer.add(guideLayer);

  // 渲染完成后自动适应视图

  // 必须先恢复显示，否则 getBounds 可能无法获取正确的大小
  app.tree.opacity = 1;
  app.tree.visible = true;

  fitView();
};

interface LineInfo {
  line: Line;
  from: LayoutNode;
  to: LayoutNode;
}

const updateLinePath = (info: LineInfo) => {
  const parent = info.from;
  const child = info.to;

  // 使用实时坐标 (_x, _y 应该在拖动时更新)
  const startX = parent._x! + NODE_WIDTH / 2;
  const startY = parent._y! + NODE_HEIGHT;
  const endX = child._x! + NODE_WIDTH / 2;
  const endY = child._y!;

  const midY = startY + (endY - startY) / 2;

  info.line.points = [startX, startY, startX, midY, endX, midY, endX, endY];
};

const drawNodeRecursive = (node: LayoutNode) => {
  if (!treeLayer) return;

  const x = node._x!;
  const y = node._y!;

  // Initialize Line Map for this node
  if (!nodeLinesMap.has(node.id)) {
    // @ts-ignore
    nodeLinesMap.set(node.id, { incoming: null, outgoing: [] });
  }

  // 1. Draw Lines to Children
  if (node.children && node.children.length > 0) {
    const bottomX = x + NODE_WIDTH / 2;
    const bottomY = y + NODE_HEIGHT;

    node.children.forEach(child => {
      const childTopX = child._x! + NODE_WIDTH / 2;
      const childTopY = child._y!;

      // Draw simple elbow connector or straight line
      // Elbow: Down -> Horizontal -> Down
      const midY = bottomY + (childTopY - bottomY) / 2;

      const line = new Line({
        points: [bottomX, bottomY, bottomX, midY, childTopX, midY, childTopX, childTopY],
        strokeWidth: 2,
        stroke: '#ccc',
        cornerRadius: 10 // Rounded corners
      });
      treeLayer?.add(line);

      // Store Line Reference
      const lineInfo: LineInfo = { line, from: node, to: child };

      // Add to parent outgoing
      // @ts-ignore
      if (nodeLinesMap.get(node.id)) nodeLinesMap.get(node.id)!.outgoing.push(lineInfo);

      // Initialize child map and add to incoming
      // @ts-ignore
      if (!nodeLinesMap.has(child.id)) nodeLinesMap.set(child.id, { incoming: null, outgoing: [] });
      // @ts-ignore
      nodeLinesMap.get(child.id)!.incoming = lineInfo;

      drawNodeRecursive(child);
    });
  }

  // 2. Draw Node Box
  const nodeGroup = new Group({
    x: x,
    y: y,
    width: NODE_WIDTH,
    height: NODE_HEIGHT,
    cursor: 'move', // Change cursor to move
    draggable: true, // Enable Drag
    zIndex: 10 // Ensure nodes are above lines
  });

  // Shadow/Border
  const box = new Rect({
    width: NODE_WIDTH,
    height: NODE_HEIGHT,
    cornerRadius: 8,
    fill: BG_COLOR,
    stroke: node.type === DeptType.Group ? COLOR_GROUP : (node.type === DeptType.Company ? COLOR_COMPANY : COLOR_DEPT),
    strokeWidth: 2,
    shadow: {
      x: 2,
      y: 2,
      blur: 5,
      color: 'rgba(0,0,0,0.1)'
    }
  });

  // Header Color Bar
  const header = new Rect({
    width: NODE_WIDTH,
    height: 6,
    cornerRadius: [8, 8, 0, 0],
    fill: node.type === DeptType.Group ? COLOR_GROUP : (node.type === DeptType.Company ? COLOR_COMPANY : COLOR_DEPT),
  });

  // Layout calculations
  const hasLeader = !!node.leader;
  const headerHeight = 6;
  const leaderAreaHeight = 24; // Height reserved for leader text
  const nameAreaHeight = hasLeader ? (NODE_HEIGHT - headerHeight - leaderAreaHeight) : (NODE_HEIGHT - headerHeight);

  // Text: Name
  const nameText = new Text({
    text: node.name,
    x: 10,
    y: headerHeight,
    textAlign: 'center',
    verticalAlign: 'middle',
    fontSize: 14,
    fontWeight: 'bold',
    fill: '#333',
    width: NODE_WIDTH - 20,
    height: nameAreaHeight, // Ensure vertical centering within available space
    textWrap: 'break', // 自动换行
    lineHeight: 20
  });

  // Text: Leader
  const leaderText = new Text({
    text: hasLeader ? `负责人: ${node.leader}` : '',
    x: 10,
    y: NODE_HEIGHT - leaderAreaHeight,
    textAlign: 'center',
    verticalAlign: 'middle',
    fontSize: 12,
    fill: '#666',
    width: NODE_WIDTH - 20,
    height: leaderAreaHeight,
    textOverflow: 'ellipsis'
  });

  // Add Child Button (Circle + Plus)
  const addBtnGroup = new Group({
    x: NODE_WIDTH / 2,
    y: NODE_HEIGHT, // On the bottom edge
    cursor: 'pointer',
    visible: false // 默认隐藏
  });

  const addBtnBg = new Ellipse({
    width: 20,
    height: 20,
    x: -10, // center
    y: -10, // center
    fill: '#fff',
    stroke: '#1890ff',
    strokeWidth: 1
  });

  const addBtnIcon = new Text({
    text: '+',
    x: 0,
    y: 0,
    textAlign: 'center',
    verticalAlign: 'middle',
    fontSize: 16,
    fill: '#1890ff',
    fontWeight: 'bold'
  });

  addBtnGroup.add(addBtnBg);
  addBtnGroup.add(addBtnIcon);

  // Event: Add Child
  addBtnGroup.on('click', (e) => {
    e.stop(); // Prevent bubbling to node click
    handleAdd(node);
  });

  // Drag Logic
  let isDragging = false;

  // 阻止事件冒泡，防止触发画布拖拽
  nodeGroup.on(PointerEvent.DOWN, (e) => {
    e.stop();
  });

  nodeGroup.on(DragEvent.START, () => {
    isDragging = false;
  });

  nodeGroup.on(DragEvent.DRAG, () => {
    isDragging = true;
    // Update model coordinates
    node._x = nodeGroup.x;
    node._y = nodeGroup.y;

    // 1. Update Lines
    const lines = nodeLinesMap.get(node.id);
    if (lines) {
      // Update lines to children
      lines.outgoing.forEach((info: LineInfo) => updateLinePath(info));
      // Update line from parent
      if (lines.incoming) updateLinePath(lines.incoming);
    }

    // 2. Alignment Guides
    if (guideLayer) guideLayer.clear();

    const threshold = 5;

    const traverse = (n: LayoutNode) => {
      if (n.id !== node.id) {
        // Align Left
        if (Math.abs(n._x! - node._x!) < threshold) {
          nodeGroup.x = n._x!;
          node._x = n._x!;
          guideLayer!.add(new Line({
            points: [n._x!, Math.min(n._y!, node._y!) - 20, n._x!, Math.max(n._y!, node._y!) + NODE_HEIGHT + 20],
            stroke: '#ff0000',
            strokeWidth: 1,
            dashPattern: [5, 5]
          }));
        }
        // Align Top
        if (Math.abs(n._y! - node._y!) < threshold) {
          nodeGroup.y = n._y!;
          node._y = n._y!;
          guideLayer!.add(new Line({
            points: [Math.min(n._x!, node._x!) - 20, n._y!, Math.max(n._x!, node._x!) + NODE_WIDTH + 20, n._y!],
            stroke: '#ff0000',
            strokeWidth: 1,
            dashPattern: [5, 5]
          }));
        }
      }
      if (n.children) n.children.forEach(traverse);
    };
    deptList.value.forEach((r: any) => traverse(r));
  });

  nodeGroup.on(DragEvent.END, async () => {
    if (guideLayer) guideLayer.clear();

    // Save to Backend
    node.x = node._x;
    node.y = node._y;

    try {
      await updateDept(node.id, {
        x: node.x,
        y: node.y
      });

      // Recalculate sort order for siblings
      // 1. Find siblings
      let siblings: Dept[] = [];
      let parentId: number | null = null;
      
      const findParent = (nodes: Dept[], targetId: number): Dept | null => {
          for (const n of nodes) {
              if (n.children && n.children.some(c => c.id === targetId)) {
                  return n;
              }
              if (n.children) {
                  const found = findParent(n.children, targetId);
                  if (found) return found;
              }
          }
          return null;
      };

      const parent = findParent(deptList.value, node.id);
      if (parent) {
          siblings = parent.children || [];
          parentId = parent.id;
      } else {
          // Check if it is a root node
          if (deptList.value.some(n => n.id === node.id)) {
              siblings = deptList.value;
              parentId = null;
          }
      }

      if (siblings.length > 1) {
          // Create a list of { node, x } to sort
          // Use _x (visual pos) which is up-to-date for the dragged node
          const siblingPositions = siblings.map(s => ({
              node: s,
              x: (s as any)._x ?? s.x ?? 0
          }));

          // Sort by x ascending (left to right)
          siblingPositions.sort((a, b) => a.x - b.x);

          const updates: UpdateDeptStructureParams[] = [];
          
          siblingPositions.forEach((item, index) => {
              const newSortOrder = index; 
              if (item.node.sortOrder !== newSortOrder) {
                  item.node.sortOrder = newSortOrder;
                  updates.push({
                      id: item.node.id,
                      parentId: item.node.parentId ?? null,
                      sortOrder: newSortOrder
                  });
              }
          });

          if (updates.length > 0) {
              await updateDeptStructure(updates);
          }
      }

    } catch (error) {
      console.error('Failed to save position or sort order', error);
      message.error('保存失败');
    }

    setTimeout(() => { isDragging = false; }, 100);
  });

  nodeGroup.on('click', () => {
    if (!isDragging) {
      handleEdit(node);
    }
  });

  // 鼠标悬停显示加号
  nodeGroup.on(PointerEvent.ENTER, () => {
    addBtnGroup.visible = true;
  });

  // 鼠标移出隐藏加号
  nodeGroup.on(PointerEvent.LEAVE, () => {
    addBtnGroup.visible = false;
  });

  // 右键菜单
  nodeGroup.on(PointerEvent.MENU, (e: any) => {
    e.stop(); // 阻止冒泡，避免触发背景菜单
    // e.origin 是原始 DOM 事件 (MouseEvent)
    const originEvent = e.origin;

    contextMenuType.value = 'node';
    currentId.value = node.id;
    // Check if node has custom position
    showAutoArrange.value = node.x != null && node.y != null;
    contextMenuVisible.value = true;

    // 使用原始事件坐标
    if (originEvent) {
      contextMenuPos.x = originEvent.clientX;
      contextMenuPos.y = originEvent.clientY;
    } else {
      // Fallback
      contextMenuPos.x = e.x; // 这可能是画布坐标，需注意
      // 这里通常 e.origin 存在
    }
  });

  // Add elements to group
  nodeGroup.add(box);
  nodeGroup.add(header);
  nodeGroup.add(nameText);
  nodeGroup.add(leaderText);
  nodeGroup.add(addBtnGroup);

  treeLayer?.add(nodeGroup);
};

const fitView = () => {
  if (!app || !treeLayer || deptList.value.length === 0) return;

  // 手动计算边界，不依赖 getBounds()
  let minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity;

  const traverse = (nodes: LayoutNode[]) => {
    nodes.forEach(node => {
      if (typeof node._x === 'number' && typeof node._y === 'number') {
        minX = Math.min(minX, node._x);
        minY = Math.min(minY, node._y);
        maxX = Math.max(maxX, node._x + NODE_WIDTH);
        maxY = Math.max(maxY, node._y + NODE_HEIGHT);
      }
      if (node.children && node.children.length > 0) {
        traverse(node.children as LayoutNode[]);
      }
    });
  };

  traverse(deptList.value as LayoutNode[]);

  // 如果没有有效节点
  if (minX === Infinity) return;

  const padding = 50;
  const contentWidth = maxX - minX;
  const contentHeight = maxY - minY;

  const containerWidth = app.width || 0;
  const containerHeight = app.height || 0;

  // 计算缩放比例，适应屏幕
  let scale = 1;
  if (contentWidth > 0 && contentHeight > 0) {
    const scaleX = (containerWidth - padding * 2) / contentWidth;
    const scaleY = (containerHeight - padding * 2) / contentHeight;
    scale = Math.min(scaleX, scaleY);
  }

  // 限制最大缩放为 1（不放大模糊）
  scale = Math.min(scale, 1);

  // 应用缩放和居中
  // 公式: 容器中心 - (内容中心 * 缩放)
  app.tree.scaleX = scale;
  app.tree.scaleY = scale;

  app.tree.x = containerWidth / 2 - (minX + contentWidth / 2) * scale;
  app.tree.y = containerHeight / 2 - (minY + contentHeight / 2) * scale;
};

onMounted(() => {
  initLeafer();
  fetchDeptTree();
});

onUnmounted(() => {
  if (app) {
    app.destroy();
  }
  if (canvasContainer.value) {
    canvasContainer.value.removeEventListener('wheel', handleWheel);
    // canvasContainer.value.removeEventListener('mousedown', handleMouseDown);
  }
  window.removeEventListener('mousemove', handleGlobalMove);
  window.removeEventListener('mouseup', handleGlobalUp);
});

const initLeafer = () => {
  if (!canvasContainer.value) return;

  app = new App({
    view: canvasContainer.value,
    tree: {}, // 普通图层模式，完全手动控制交互
    fill: '#f0f2f5', // 画布背景色
  });

  // 绑定交互事件
  const container = canvasContainer.value;
  // container.addEventListener('mousedown', handleMouseDown);
  container.addEventListener('wheel', handleWheel, { passive: false });

  // 画布拖拽：监听 Leafer 事件，这样如果节点阻止了冒泡，这里就不会触发
  app.on(PointerEvent.DOWN, handleCanvasDown);

  // 背景右键菜单
  app.on(PointerEvent.MENU, (e: any) => {
    // 如果是节点触发的，已经在节点事件中 e.stop() 了，所以这里只处理背景
    const originEvent = e.origin;

    contextMenuType.value = 'canvas';
    contextMenuVisible.value = true;

    if (originEvent) {
      contextMenuPos.x = originEvent.clientX;
      contextMenuPos.y = originEvent.clientY;
    }
  });
};

// 交互状态
let isPanning = false;
let lastPanX = 0;
let lastPanY = 0;

const handleCanvasDown = (e: any) => {
  // e 是 Leafer 的 PointerEvent
  const nativeEvent = e.origin;
  // 如果没有原生事件，或者点击的是右键，不处理
  if (!nativeEvent || nativeEvent.button === 2) return;

  isPanning = true;
  lastPanX = nativeEvent.clientX;
  lastPanY = nativeEvent.clientY;

  if (app) {
    app.cursor = 'grabbing';
  }

  window.addEventListener('mousemove', handleGlobalMove);
  window.addEventListener('mouseup', handleGlobalUp);
};

const handleGlobalMove = (e: MouseEvent) => {
  if (!isPanning || !app) return;

  const dx = e.clientX - lastPanX;
  const dy = e.clientY - lastPanY;

  lastPanX = e.clientX;
  lastPanY = e.clientY;

  app.tree.x = (app.tree.x || 0) + dx;
  app.tree.y = (app.tree.y || 0) + dy;
};

const handleGlobalUp = () => {
  isPanning = false;
  if (app) {
    app.cursor = 'default';
  }
  window.removeEventListener('mousemove', handleGlobalMove);
  window.removeEventListener('mouseup', handleGlobalUp);
};

const handleWheel = (e: WheelEvent) => {
  if (!app || !app.tree) return;

  // 仅当按住Ctrl键时触发缩放
  if (e.ctrlKey) {
    e.preventDefault(); // 阻止浏览器默认缩放

    const currentScale = app.tree.scaleX || 1;
    const zoomFactor = e.deltaY > 0 ? 0.9 : 1.1; // 向下滚缩小，向上滚放大
    let newScale = currentScale * zoomFactor;

    // 限制缩放范围
    newScale = Math.max(0.1, Math.min(newScale, 5));

    const rect = canvasContainer.value!.getBoundingClientRect();
    const mouseX = e.clientX - rect.left;
    const mouseY = e.clientY - rect.top;

    // 计算缩放后的位置，保持鼠标指向的点不变
    // 公式: newPos = mousePos - (mousePos - oldPos) * (newScale / oldScale)
    // 或者: localX = (mouseX - graphX) / currentScale
    //       graphX = mouseX - localX * newScale

    const localX = (mouseX - (app.tree.x || 0)) / currentScale;
    const localY = (mouseY - (app.tree.y || 0)) / currentScale;

    app.tree.scaleX = newScale;
    app.tree.scaleY = newScale;
    app.tree.x = mouseX - localX * newScale;
    app.tree.y = mouseY - localY * newScale;
  }
};

// --- Modal Logic (Kept mostly same, adjusted for context) ---
const modalVisible = ref(false);
const modalTitle = ref('');
const confirmLoading = ref(false);
const formRef = ref();
const currentId = ref<number | null>(null);

const formState = reactive<any>({
  parentId: undefined,
  name: '',
  code: '',
  type: DeptType.Department,
  leader: '',
  phone: '',
  email: '',
  sortOrder: 0,
  isActive: true
});

const rules = {
  name: [{ required: true, message: '请输入名称', trigger: 'blur' }]
};

// Tree Select Data
const deptTreeSelectData = computed(() => {
  const mapData = (list: Dept[]): any[] => {
    return list.map(item => ({
      label: item.name,
      value: item.id,
      type: item.type,
      children: item.children ? mapData(item.children) : undefined,
      disabled: item.id === currentId.value // Prevent selecting self as parent
    }));
  };
  return [
    { label: '顶级节点', value: 0, children: null },
    ...mapData(deptList.value)
  ];
});

const handleAddRoot = () => {
  handleAdd(undefined);
};

const handleAdd = (record?: Dept) => {
  modalTitle.value = '新增节点';
  currentId.value = null;
  formState.parentId = record ? record.id : undefined; // 0 or undefined for root? If record is undefined, parentId is undefined (root)
  formState.name = '';
  formState.code = '';
  formState.leader = '';
  formState.phone = '';
  formState.email = '';
  formState.sortOrder = 0;
  formState.isActive = true;
  modalVisible.value = true;
};

const handleEdit = (record: Dept) => {
  modalTitle.value = '编辑节点';
  currentId.value = record.id;
  formState.parentId = record.parentId;
  formState.name = record.name;
  formState.code = record.code;
  formState.type = record.type;
  formState.leader = record.leader;
  formState.phone = record.phone;
  formState.email = record.email;
  formState.sortOrder = record.sortOrder;
  formState.isActive = record.isActive;

  // Add a "Delete" button to the modal footer or add a separate delete action?
  // For now, let's keep the modal for editing. 
  // We can add a "Delete" button inside the modal if we want, but usually it's separate.
  // I'll add a delete button in the modal footer or a specific delete action.
  // Let's modify the modal footer to include Delete.
  modalVisible.value = true;
};

// Custom footer for modal to include Delete
// But Ant Design Modal footer customization requires slot. 
// Simpler: Add a Delete button in the form or keep it simple for now.
// The user asked for "Org Chart Style", not removing functionality. 
// I should add a delete button in the modal or on the node.
// I'll add a delete button in the modal for now to keep the UI clean.

const handleDelete = async () => {
  if (!currentId.value) return;
  Modal.confirm({
    title: '确定删除吗？',
    icon: createVNode(ExclamationCircleOutlined),
    content: '删除后无法恢复，如果有子节点可能会被删除或失去关联。',
    async onOk() {
      try {
        await deleteDept(currentId.value!);
        message.success('删除成功');
        modalVisible.value = false;
        fetchDeptTree();
      } catch (error) {
        console.error(error);
      }
    }
  });
};

const handleModalOk = async () => {
  try {
    await formRef.value.validate();
    confirmLoading.value = true;

    const payload = { ...formState };
    if (payload.parentId === 0) payload.parentId = null;

    if (currentId.value) {
      await updateDept(currentId.value, payload);
      message.success('更新成功');
    } else {
      await createDept(payload);
      message.success('创建成功');
    }
    modalVisible.value = false;
    fetchDeptTree();
  } catch (error) {
    console.error(error);
  } finally {
    confirmLoading.value = false;
  }
};
</script>

<style scoped>
.sys-org-container {
  height: calc(100vh - 84px);
  /* Adjust based on layout */
  display: flex;
  flex-direction: column;
}

.canvas-container {
  flex: 1;
  background-color: #f0f2f5;
  border-radius: 8px;
  overflow: hidden;
  position: relative;
}

.custom-context-menu {
  position: fixed;
  background: #fff;
  border-radius: 4px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
  padding: 4px 0;
  min-width: 140px;
  z-index: 1000;
  user-select: none;
}

.menu-item {
  padding: 8px 16px;
  cursor: pointer;
  display: flex;
  align-items: center;
  font-size: 14px;
  color: #333;
  transition: all 0.2s;
}

.menu-item .anticon {
  margin-right: 8px;
}

.menu-item:hover {
  background-color: #f5f5f5;
  color: #1890ff;
}

.menu-item.danger {
  color: #ff4d4f;
}

.menu-item.danger:hover {
  background-color: #fff1f0;
}

.menu-divider {
  height: 1px;
  background-color: #f0f0f0;
  margin: 4px 0;
}
</style>
