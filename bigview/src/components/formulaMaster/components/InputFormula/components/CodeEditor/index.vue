<script setup lang="ts">
import {ref, defineProps, defineEmits, defineExpose, nextTick} from "vue";
import {Row} from 'ant-design-vue';
import Title from "../Title.vue";
import {
  ViewUpdate,
  type DecorationSet,
  Decoration,
  ViewPlugin,
  MatchDecorator,
  EditorView,
  WidgetType,
  highlightActiveLine,
  highlightActiveLineGutter,
} from '@codemirror/view';
import {
  autocompletion,
  closeBrackets,
  type Completion,
  pickedCompletion,
} from "@codemirror/autocomplete";
import {minimalSetup} from "codemirror";
import CodeMirror from "vue-codemirror6";

const emits = defineEmits(['handleTipsKeyDown']);
const props = defineProps({
  title: {
    type: String,
    default: '编辑器'
  },
  isSearch: {
    type: Boolean,
    default: false
  },
  entityFields: {
    type: Array,
    default: () => []
  },
  formulaFunctions: {
    type: Array,
    default: () => []
  }
})
//关键字
let keywords = props.formulaFunctions.map((item:any) => item?.label)
const mirrorRef = ref();
const editor = ref<EditorView>();
//匹配规则
const regexp = new RegExp(keywords.join('|'), 'g');

//关键字匹配器
const keywordsMatcher = new MatchDecorator({
  regexp,
  decoration: (match, view, pos) => {
    let style: string = `color: #AE4597;font-weight:bold;`;
    return Decoration.mark({
      attributes: {
        style
      }
    });
  },
});
//关键字插件
const keywordsPlugin = ViewPlugin.fromClass(class {
      keywords: DecorationSet;

      constructor(view: EditorView) {
        this.keywords = keywordsMatcher.createDeco(view);
      }

      update(update: ViewUpdate) {
        this.keywords = keywordsMatcher.updateDeco(update, this.keywords);
      }
    },
    {
      decorations: (instance: any) => instance.keywords,
      provide: plugin => EditorView.atomicRanges.of(view => {
        return view.plugin(plugin)?.keywords || Decoration.none
      })
    });

//标签类
class PlaceholderWidget extends WidgetType {
  name: string;

  constructor(name: any) {
    super();
    this.name = name;
  }

  eq(other: any) {
    return this.name == other.name;
  }

  toDOM() {
    let elt = document.createElement("span");
    elt.style.cssText = `
      box-sizing: border-box;
      margin: 0 5px;
      list-style: none;
      display: inline-block;
      height: auto;
      padding: 0 6px;
      font-size: 14px;
      line-height: 20px;
      white-space: nowrap;
      border-radius: 3px;
      color: #fff;
      font-weight: bold;
      background: #1677FC;
    `;
    elt.textContent = this.name;
    return elt;
  }

  ignoreEvent() {
    return false
  }
}

//标签元素匹配器
const placeholderMatcher = new MatchDecorator({
  regexp: /\{(\w+)\}/g,
  decoration: (match) => {
    let res = props.entityFields.find((item:any) => item?.value == match[1]);
    let label = !res ? match[1] : res.label;
    return Decoration.replace({
      widget: new PlaceholderWidget(label),
    });
  },
});
//标签元素插件
const placeholders = ViewPlugin.fromClass(
    class {
      placeholders: DecorationSet

      constructor(view: EditorView) {
        this.placeholders = placeholderMatcher.createDeco(view)
      }

      update(update: ViewUpdate) {
        this.placeholders = placeholderMatcher.updateDeco(update, this.placeholders)
      }
    },
    {
      decorations: instance => instance.placeholders,
      provide: plugin => EditorView.atomicRanges.of(view => {
        return view.plugin(plugin)?.placeholders || Decoration.none
      })
    }
)
//公式检索
let formulaCompletions: Completion[] = props.formulaFunctions.map((item:any) => {
  let {label,explain} = item
  return {
    label: label,
    type: "keyword",
    detail: explain ? explain.join(" ; ") : '',
    apply: (
        view: EditorView,
        completion: Completion,
        from: number,
        to: number
    ) => {
      view.dispatch({
        changes: {
          from,
          to,
          insert: `${completion.label}()`,
        },
      });
      let cursor = getCursor();
      view.dispatch({
        selection: {anchor: cursor - 1},
        annotations: pickedCompletion.of(completion),
      });
      emits('handleTipsKeyDown', completion)
    },
  };
});

//变量检索
let entityCompletions: Completion[] = props.entityFields.map((item:any) => {
  let {value,label} = item
  return {
    label: value,
    type: "variable",
    detail: label,
    apply: `{${value}}`,
  };
});
//代码提示
const autoCompletions = (context: any) => {
  let before = context.matchBefore(/\w+/);
  if (!context.explicit && !before) return null;
  return {
    from: before ? before.from : context.pos,
    options: [...formulaCompletions, ...entityCompletions],
    validFor: /^\w*$/,
  };
}
//codemirror 插件
const extensions = [
  placeholders,
  keywordsPlugin,
  minimalSetup,
  highlightActiveLine(),
  highlightActiveLineGutter(),
  autocompletion({override: [autoCompletions]}),
  closeBrackets(),
]

//codemirror 加载完成钩子
const onReady = ({view}: any) => {
  editor.value = view
}

//获取光标位置
const getCursor = () => {
  return editor.value?.state.selection.main.head || 0;
}

//插入函数方法
const insertFormula = (item: any) => {
  mirrorRef.value.replaceSelection(`${item.label}()`);
  let cursor = getCursor();
  mirrorRef.value.setSelection(cursor - 1);
  editor.value?.focus();
}

//插入变量标签
const insertTag = (item: any) => {
  mirrorRef.value.replaceSelection(`{${item.value}}`);
  editor.value?.focus();
}
//获取codemirror中的内容
const getEditorValue = () => {
  return editor.value?.state.doc.toString();
}
//设置codemirror中的内容
const setEditorValue = (docs:string = '') => {
  nextTick(()=>{
    let docsLength = editor.value?.state.doc.toString().length;
    // @ts-ignore
    mirrorRef.value.replaceRange(docs,0,docsLength)
  })
}
defineExpose({
  insertTag,
  insertFormula,
  getEditorValue,
  setEditorValue
})
</script>
<template>
  <Row id="code-editor">
    <Title v-bind="{title:props.title,isSearch:props.isSearch}"/>
    <Row class="editor-content">
      <CodeMirror
          class="mirror"
          ref="mirrorRef"
          placeholder="请输入 例如:SUM(数值1,数值2)"
          :extensions="extensions"
          @ready="onReady"
      />
    </Row>
  </Row>
</template>

<style lang="scss" scoped>
#code-editor {
  width: 100%;
  padding: 10px;
  color: #81bae9;
  .editor-content {
    width: 100%;
    height: calc(100% - 1px);
    overflow-y: auto;
    // background: #f8f8f8 !important;
    border-radius: 6px;
    padding: 5px 10px;

    .mirror {
      width: 100% !important;
      font-size: 14px !important;

      :deep(.cm-editor) {
        height: 338px !important;
      }

      :deep(.cm-focused) {
        outline: none !important;
      }

      :deep(.cm-line) {
        line-height: 20px;
        margin-bottom: 5px;
      }
    }
  }
}
</style>
