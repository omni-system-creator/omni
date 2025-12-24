import { ref, onBeforeUnmount, nextTick } from 'vue'
import { useDesignStore } from '@/store/modules/designStore/designStore'
import * as monaco from 'monaco-editor/esm/vs/editor/editor.api.js'
import { languages } from 'monaco-editor';

export const useMonacoEditor = (language = 'javascript') => {
  const designStore = useDesignStore()

  let monacoEditor: monaco.editor.IStandaloneCodeEditor | null = null
  let initReadOnly = false
  const el = ref<HTMLElement | null>(null)

  // 格式化
  const onFormatDoc = async () => {
    await monacoEditor?.getAction('monacoEditor.action.formatDocument')?.run()
  }

  // 更新
  const updateVal = (val: string) => {
    nextTick(async () => {
      monacoEditor?.setValue(val)
      initReadOnly && monacoEditor?.updateOptions({ readOnly: false })
      await onFormatDoc()
      initReadOnly && monacoEditor?.updateOptions({ readOnly: true })
    })
  }

  // 创建实例
  const createEditor = (editorOption: monaco.editor.IStandaloneEditorConstructionOptions = {}) => {
    if (!el.value) return
    const javascriptModel = monaco.editor.createModel('', language)
    initReadOnly = !!editorOption.readOnly
    // 创建
    monacoEditor = monaco.editor.create(el.value, {
      model: javascriptModel,
      // 是否启用预览图
      minimap: { enabled: false },
      // 圆角
      roundedSelection: true,
      // 主题
      theme: designStore.getDarkTheme ? 'vs-dark' : 'vs',
      // 主键
      multiCursorModifier: 'ctrlCmd',
      // 滚动条
      scrollbar: {
        verticalScrollbarSize: 8,
        horizontalScrollbarSize: 8
      },
      // 行号
      lineNumbers: 'off',
      // tab大小
      tabSize: 2,
      //字体大小
      fontSize: 16,
      // 控制编辑器在用户键入、粘贴、移动或缩进行时是否应自动调整缩进
      autoIndent: 'advanced',
      // 自动布局
      automaticLayout: true,
      ...editorOption
    })
    if (!window.firstInit) {
      monaco.languages.registerCompletionItemProvider('javascript', {
        provideCompletionItems:
          (): languages.ProviderResult<languages.CompletionList> => {
            const suggestions = [
              {
                label: '$Component',
                kind: monaco.languages.CompletionItemKind.Snippet,
                insertText: 'components.$0=$1',
                insertTextRules:
                  monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
                documentation: '选择一个组件',
              },
              {
                label: '$api',
                kind: monaco.languages.CompletionItemKind.Snippet,
                insertText: 'var k = $0',
                insertTextRules:
                  monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
                documentation: '选择API接口',
              },
              {
                label: '$set',
                kind: monaco.languages.CompletionItemKind.Snippet,
                insertText: 'var k = $0',
                insertTextRules:
                  monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
                documentation: '设置变量',
              },
              {
                label: '$if',
                kind: monaco.languages.CompletionItemKind.Snippet,
                insertText: 'if ($0) {\n$1\n}',
                insertTextRules:
                  monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
                documentation: '分支',
              },
            ];

            return { suggestions } as languages.CompletionList;
          },
      });
    }
    window.firstInit = true

    return monacoEditor
  }

  // 卸载
  onBeforeUnmount(() => {
    if (monacoEditor) monacoEditor.dispose()
  })

  return {
    el,
    updateVal,
    getEditor: () => monacoEditor,
    createEditor,
    onFormatDoc
  }
}
