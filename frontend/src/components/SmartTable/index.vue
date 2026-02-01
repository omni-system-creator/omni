<template>
  <div class="smart-table" ref="smartTableRef" :style="cssVars">
    <!-- Toolbar with Settings -->
    <div class="smart-table-toolbar" :style="{ padding: props.toolbarPadding }">
      <div class="toolbar-content">
        <slot name="toolbar" />
      </div>
      <a-popover
        trigger="click"
        placement="bottomRight"
        v-model:open="settingsVisible"
        overlayClassName="smart-table-settings-popover"
      >
        <template #content>
          <div class="table-settings-content">
            <div class="settings-header">
              <span>列配置</span>
              <a-button type="link" size="small" @click="resetConfig">重置</a-button>
            </div>
            <div class="settings-body">
              <draggable
                v-model="configList"
                item-key="key"
                handle=".drag-handle"
                @end="saveConfig"
              >
                <template #item="{ element }">
                  <div class="column-item">
                    <holder-outlined class="drag-handle" />
                    <a-checkbox
                      v-model:checked="element.visible"
                      @change="saveConfig"
                      class="column-checkbox"
                    >
                      <span class="column-title" :title="element.title">{{ element.title }}</span>
                    </a-checkbox>
                    <div class="width-input">
                      <a-input-number
                        v-model:value="element.width"
                        size="small"
                        :min="50"
                        :step="10"
                        placeholder="宽度"
                        @blur="saveConfig"
                        style="width: 100%"
                      />
                    </div>
                  </div>
                </template>
              </draggable>
            </div>
          </div>
        </template>
        <a-tooltip title="表格设置">
          <a-button type="text">
            <template #icon><setting-outlined /></template>
          </a-button>
        </a-tooltip>
      </a-popover>
    </div>

    <!-- Table -->
    <a-table
      v-bind="$attrs"
      :columns="displayColumns"
      :data-source="props.dataSource"
      :scroll="tableScroll"
    >
      <!-- Forward all slots -->
      <template v-for="(_, name) in $slots" #[name]="slotData">
        <slot :name="name" v-bind="slotData" />
      </template>
    </a-table>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted, onUnmounted, useAttrs } from 'vue';
import { SettingOutlined, HolderOutlined } from '@ant-design/icons-vue';
import draggable from 'vuedraggable';
import { useUserConfigStore } from '@/stores/userConfig';
import type { TableColumnType } from 'ant-design-vue';

interface Props {
  tableKey: string; // Unique key for storing configuration
  columns: TableColumnType[];
  toolbarPadding?: string;
  dataSource?: any[];
}

const props = withDefaults(defineProps<Props>(), {
  toolbarPadding: '8px',
  dataSource: () => [],
});

const attrs = useAttrs();
const userConfigStore = useUserConfigStore();
const smartTableRef = ref<HTMLDivElement>();
const containerWidth = ref(0);
let resizeObserver: ResizeObserver | null = null;

const settingsVisible = ref(false);
const configList = ref<any[]>([]);

// Compute CSS variables for styling
const cssVars = computed(() => {
  const vars: Record<string, string> = {};
  const data = props.dataSource;
  
  // Calculate total width of visible columns to decide on width strategy
  const totalWidth = displayColumns.value.reduce((sum, col) => {
    const width = Number(col.width);
    return sum + (isNaN(width) ? 80 : width); 
  }, 0);
  
  // Apply empty height if data is empty and scroll.y is provided
  // Subtract 2px to avoid triggering scrollbars due to border/sub-pixel differences
  if (data.length === 0 && tableScroll.value.y) {
     vars['--empty-height'] = typeof tableScroll.value.y === 'number' 
        ? `calc(${tableScroll.value.y}px - 2px)` 
        : `${tableScroll.value.y}`;
  }
  
  // Inject container width for sticky positioning
  // If container width is not yet measured (0), default to 100% to ensure full width
  if (containerWidth.value === 0 || totalWidth <= containerWidth.value) {
     vars['--container-width'] = '100%';
  } else {
     vars['--container-width'] = `${containerWidth.value}px`;
  }

  return vars;
});

// Initialize config list from props.columns
const initConfig = () => {
  // Load saved config
  const savedConfig = userConfigStore.getConfig<any[]>(`table.${props.tableKey}.columns`, []);
  
  // Create a map of saved configs for easy lookup
  const savedMap = new Map(savedConfig.map((c: any) => [c.key || c.dataIndex, c]));

  // Map current columns to config items
  const currentCols = props.columns.map(col => {
    const key = (col.key || col.dataIndex) as string;
    const saved = savedMap.get(key);
    return {
      key: key,
      title: col.title as string,
      dataIndex: col.dataIndex,
      visible: saved ? saved.visible : true,
      width: saved?.width || col.width || undefined,
      order: saved?.order ?? 0 // We'll handle order by sorting the array
    };
  });

  // If we have saved config, we need to reorder currentCols based on saved order
  if (savedConfig.length > 0) {
    // Create a list of keys in the saved order
    const savedKeys = savedConfig.map((c: any) => c.key);
    
    // Sort currentCols: items in saved config come first in that order, then new items
    currentCols.sort((a, b) => {
      const indexA = savedKeys.indexOf(a.key);
      const indexB = savedKeys.indexOf(b.key);
      
      if (indexA !== -1 && indexB !== -1) return indexA - indexB;
      if (indexA !== -1) return -1;
      if (indexB !== -1) return 1;
      return 0;
    });
  }

  configList.value = currentCols;
};

// Compute columns to pass to a-table
const displayColumns = computed(() => {
  return configList.value
    .filter(c => c.visible)
    .map(c => {
      // Find original column definition to preserve render functions, etc.
      const originalCol = props.columns.find(col => (col.key || col.dataIndex) === c.key);
      if (!originalCol) return null;
      
      return {
        ...originalCol,
        // Only use config width if it's set, otherwise fallback to original width
        width: c.width || originalCol.width,
        // Ensure key/dataIndex is preserved
        key: c.key,
        dataIndex: c.dataIndex
      };
    })
    .filter(Boolean) as TableColumnType[];
});

// Compute table scroll props to ensure horizontal scrolling works with fixed layout
const tableScroll = computed(() => {
  const originalScroll = (attrs.scroll as { x?: string | number | true, y?: string | number }) || {};
  
  // Calculate total width of visible columns
  const totalWidth = displayColumns.value.reduce((sum, col) => {
    const width = Number(col.width);
    return sum + (isNaN(width) ? 80 : width); 
  }, 0);

  let scrollX = originalScroll.x;

  if (containerWidth.value !== 0 && totalWidth > containerWidth.value) {
    scrollX = totalWidth;
  } else {
    // Fits container (or containerWidth is 0)
    // If no data, disable scroll.x to use auto layout (fixes wide column issue in empty state)
    // If has data, use '100%' to ensure full width fixed layout
    if (props.dataSource.length === 0) {
       scrollX = undefined;
    } else {
       scrollX = '100%';
    }
  }

  return {
    ...originalScroll,
    x: scrollX
  };
});

// Save config to store
const saveConfig = () => {
  const configToSave = configList.value.map((c, index) => ({
    key: c.key,
    visible: c.visible,
    width: c.width,
    order: index
  }));
  userConfigStore.setConfig(`table.${props.tableKey}.columns`, configToSave);
};

// Reset to default
const resetConfig = () => {
  userConfigStore.removeConfig(`table.${props.tableKey}.columns`);
  // Re-init
  configList.value = props.columns.map(col => ({
    key: (col.key || col.dataIndex) as string,
    title: col.title as string,
    dataIndex: col.dataIndex,
    visible: true,
    width: col.width || undefined
  }));
  saveConfig();
};

// Watch for columns prop change (e.g. async loading)
watch(() => props.columns, () => {
  if (configList.value.length === 0) {
    initConfig();
  } else {
    // Merge new columns if necessary, but keep existing config
    // For simplicity, we might just re-init if columns change significantly
    // But usually columns prop is stable.
    // Let's just re-sync titles and add new columns if any.
    
    // Merge: existing config order + new columns appended
    // Actually we need to respect the list order in configList
    // So we iterate configList, update items, and append new ones.
    const newConfigList = [...configList.value];
    // Update existing
    newConfigList.forEach((item, index) => {
        const fresh = props.columns.find(c => (c.key || c.dataIndex) === item.key);
        if (fresh) {
            newConfigList[index].title = fresh.title;
            // 如果配置中没有宽度（undefined），但新 props 有宽度，则应用新宽度
            if (item.width === undefined && fresh.width !== undefined) {
              newConfigList[index].width = fresh.width;
            }
        }
    });
    // Add new ones
    props.columns.forEach(col => {
        const key = (col.key || col.dataIndex) as string;
        if (!newConfigList.find(c => c.key === key)) {
            newConfigList.push({
                key: key,
                title: col.title as string,
                dataIndex: col.dataIndex,
                visible: true,
                width: col.width || undefined
            });
        }
    });
    configList.value = newConfigList;
  }
}, { deep: true });

onMounted(async () => {
  if (smartTableRef.value) {
    resizeObserver = new ResizeObserver(entries => {
      for (const entry of entries) {
        containerWidth.value = entry.contentRect.width;
      }
    });
    resizeObserver.observe(smartTableRef.value);
  }
  await userConfigStore.loadConfigs(`table.${props.tableKey}`);
  initConfig();
});

onUnmounted(() => {
  if (resizeObserver) {
    resizeObserver.disconnect();
    resizeObserver = null;
  }
});
</script>

<style scoped>
.smart-table {
  display: flex;
  flex-direction: column;
  height: 100%;
  overflow: hidden;
}

.smart-table-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-shrink: 0;
}

/* Make table take remaining height */
:deep(.ant-table-wrapper) {
  flex: 1;
  height: auto !important;
  min-height: 0;
  display: flex;
  flex-direction: column;
}

:deep(.ant-spin-nested-loading) {
  flex: 1;
  height: auto;
  min-height: 0;
  display: flex;
  flex-direction: column;
}

:deep(.ant-spin-container) {
  flex: 1;
  height: auto;
  min-height: 0;
  display: flex;
  flex-direction: column;
}

:deep(.ant-table) {
  flex: 1;
  min-height: 0;
  overflow: hidden;
}

:deep(.ant-table-container) {
  height: 100%;
  display: flex;
  flex-direction: column;
}

:deep(.ant-table-body),
:deep(.ant-table-content) {
  flex: 1;
  overflow: auto !important;
}

/* Push pagination to bottom */
:deep(.ant-pagination) {
  margin-top: auto !important;
  margin-bottom: 0 !important;
  padding: 12px 0;
  flex-shrink: 0;
}

.toolbar-content {
  flex: 1;
}

.table-settings-content {
  width: 280px;
  max-height: 600px;
  display: flex;
  flex-direction: column;
}
.settings-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px 8px;
  border-bottom: 1px solid #f0f0f0;
  margin-bottom: 0;
  font-weight: bold;
}
.settings-body {
  overflow-y: auto;
  overflow-x: hidden;
  flex: 1;
  padding: 8px 16px 12px;
}
:global(.smart-table-settings-popover .ant-popover-inner),
:global(.smart-table-settings-popover .ant-popover-inner-content) {
  padding: 0 !important;
}
.column-item {
  display: flex;
  align-items: center;
  padding: 4px 0;
  background: #fff;
  width: 100%;
}
.column-checkbox {
  flex: 1;
  overflow: hidden;
  white-space: nowrap;
  margin-right: 8px;
}
.column-title {
  display: inline-block;
  max-width: 100%;
  overflow: hidden;
  text-overflow: ellipsis;
  vertical-align: middle;
}
.width-input {
  width: 80px;
  flex-shrink: 0;
}
.drag-handle {
  cursor: move;
  color: #999;
  margin-right: 8px;
  padding: 4px;
}
.drag-handle:hover {
  color: #1890ff;
}

/* Ensure empty state placeholder takes full height and centers content */
.is-empty :deep(.ant-table-body > table) {
  height: 100%;
}

.is-empty :deep(.ant-table-placeholder .ant-table-cell) {
  vertical-align: middle !important;
  border-bottom: none !important;
}

</style>
