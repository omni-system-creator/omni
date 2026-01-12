import { watch, nextTick, type Ref } from 'vue';

/**
 * 模态框拖动 Hook
 * @param openRef 控制模态框显示的 ref
 * @returns 
 * - wrapClassName: 绑定到 a-modal 的 wrap-class-name 属性
 * - handleTitleMouseDown: 绑定到标题区域的 mousedown 事件
 * - transformStyle: (可选) 如果需要手动绑定样式
 */
export function useDraggableModal(openRef: Ref<boolean>) {
  // 生成唯一标识类名
  const id = `draggable-modal-${Math.random().toString(36).substr(2, 9)}`;
  const wrapClassName = id;
  
  let startX = 0;
  let startY = 0;
  let transformX = 0;
  let transformY = 0;
  let dragTarget: HTMLElement | null = null;

  const handleMouseMove = (e: MouseEvent) => {
    if (!dragTarget) return;
    const moveX = e.clientX - startX;
    const moveY = e.clientY - startY;
    dragTarget.style.transform = `translate(${transformX + moveX}px, ${transformY + moveY}px)`;
  };

  const handleMouseUp = () => {
    document.removeEventListener('mousemove', handleMouseMove);
    document.removeEventListener('mouseup', handleMouseUp);
    dragTarget = null;
  };

  const handleTitleMouseDown = (e: MouseEvent) => {
    // 查找当前 modal 的 content 元素
    // Ant Design Vue Modal 结构: .wrap-class > .ant-modal > .ant-modal-content
    const modalContainer = document.querySelector(`.${wrapClassName}`);
    if (!modalContainer) return;
    
    const modalContent = modalContainer.querySelector('.ant-modal-content') as HTMLElement;
    if (!modalContent) return;

    dragTarget = modalContent;
    startX = e.clientX;
    startY = e.clientY;
    
    // 获取当前的 transform 值
    const transform = window.getComputedStyle(modalContent).transform;
    if (transform && transform !== 'none') {
        const matrix = new DOMMatrix(transform);
        transformX = matrix.m41;
        transformY = matrix.m42;
    } else {
        transformX = 0;
        transformY = 0;
    }

    document.addEventListener('mousemove', handleMouseMove);
    document.addEventListener('mouseup', handleMouseUp);
    
    // 防止选中文本
    e.preventDefault();
  };

  // 监听显示状态，重置位置
  watch(openRef, (val) => {
    if (val) {
      nextTick(() => {
        // 稍微延时以确保 DOM 渲染完成
        setTimeout(() => {
          const modalContainer = document.querySelector(`.${wrapClassName}`);
          const modalContent = modalContainer?.querySelector('.ant-modal-content') as HTMLElement;
          if (modalContent) {
            modalContent.style.transform = 'none';
          }
        }, 100);
      });
    }
  });

  return {
    wrapClassName,
    handleTitleMouseDown
  };
}
