import { defineStore } from 'pinia';
import { computed, ref } from 'vue';

/**
 * 通用全屏 Loading 服务（配套 App.vue 的遮罩 DOM）。
 *
 * 设计目标：
 *   - 任意业务（整页切换初始化、批量导入导出、大文件处理、模拟登录等）都能复用这一个遮罩
 *   - 支持多层嵌套调用：A 打开后 B 也打开，等 A、B **都关掉**遮罩才消失，不会互相误伤
 *   - 文案取最后一次写入的内容：最贴近"当前正在做什么"的那个显示
 *
 * 用法示例：
 *   import { useLoadingStore } from '@/stores/loading';
 *   const loadingStore = useLoadingStore();
 *
 *   // 方式一：传 id，手动关（推荐用于生命周期明确、需要跨函数/跨 Promise 关闭的场景）
 *   loadingStore.show('正在批量导入...', 'import-batch-1');
 *   try { await importData(); } finally { loadingStore.hide('import-batch-1'); }
 *
 *   // 方式二：不传 id，用返回的 close 句柄关（最简洁，不容易忘关）
 *   const close = loadingStore.show('正在加载看板...');
 *   try { await fetchDashboards(); } finally { close(); }
 *
 *   // 方式三：只开不关，指定超时自动关（兜底短任务不推荐，避免忘记关）
 *   loadingStore.show('查询中...', 'temp');
 *   setTimeout(() => loadingStore.hide('temp'), 1500);
 */
export const useLoadingStore = defineStore('globalLoading', () => {
  /** 存储所有"已打开但尚未关闭"的 Loading 实例 */
  type LoadingEntry = { text: string; order: number };
  const instances = ref<Map<string, LoadingEntry>>(new Map());
  let _autoInc = 0;

  /** 遮罩是否显示：只要还有至少一个实例未关闭就显示 */
  const isVisible = computed(() => instances.value.size > 0);

  /** 当前显示的文案：取所有实例中「最后一次写入」的，更贴合"此刻在干什么" */
  const currentText = computed(() => {
    if (instances.value.size === 0) return '';
    let latest: LoadingEntry | null = null;
    for (const entry of instances.value.values()) {
      if (!latest || entry.order > latest.order) latest = entry;
    }
    return latest?.text ?? '';
  });

  /**
   * 打开全屏 Loading 遮罩。
   * @param text  可选提示文案，默认「加载中...」
   * @param id    可选实例 id，不传会自动生成。同一个 id 重复 show 会覆盖文案并延长生命周期。
   * @returns close 关闭函数：无论调多少次都只会关这一次，安全幂等。
   */
  function show(text: string = '加载中...', id?: string): () => void {
    const useId = id ?? `__auto_${Date.now()}_${_autoInc++}`;
    instances.value.set(useId, { text, order: ++_autoInc });
    let closed = false;
    const close = () => {
      if (closed) return;
      closed = true;
      instances.value.delete(useId);
    };
    return close;
  }

  /**
   * 用 id 手动关闭 Loading（对应 show 时传了 id 的场景）。
   * 找不到的 id 会静默忽略，幂等安全。
   */
  function hide(id: string) {
    instances.value.delete(id);
  }

  /**
   * 紧急清空全部 Loading（仅用于整页刷新/路由跳转时兜底清理，业务代码不要直接调用）。
   */
  function clearAll() {
    instances.value.clear();
  }

  return {
    isVisible,
    currentText,
    show,
    hide,
    clearAll,
  };
});
