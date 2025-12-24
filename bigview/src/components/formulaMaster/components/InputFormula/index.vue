<template > 
  <div >
    <Row @click="handleDialog">
      <slot></slot>
    </Row>
    <Modal v-model:open="modalParams.open" @handleOk="handelOk" @handleCancel="handelCancel" >
      <Row class="modal-content">
        <Col span="5" class="modal-variable">
          <Tree v-bind="formParams" @handleSelectNode="handleSelectNode(0, $event)" />
        </Col>
        <Col span="14" class="modal-editor">
          <Row class="editor">
            <CodeEditor ref="codeEditorRef" v-bind="codeEditorOptions" @handleTipsKeyDown="handleTipsKeyDown" />
          </Row>
          <Row class="explain">
            <Explain v-bind="explainParams" />
          </Row>
        </Col>
        <Col span="5" class="modal-func">
          <Tree v-bind="funcParams" @handleExplain="handleExplain" @handleSelectNode="handleSelectNode(1, $event)" />
        </Col>
      </Row>
    </Modal>
  </div>
 
</template>

<script lang="ts">
import { defineComponent, reactive, ref, nextTick } from 'vue';
import { Row, Col, message  } from 'ant-design-vue';
import Modal from './components/Modal.vue';
import Tree from './components/Tree.vue';
import Explain from './components/Explain.vue';
import CodeEditor from './components/CodeEditor/index.vue';
import * as formula from 'hot-formula-parser';
import style from './index.module.scss';
import { console } from 'inspector';

const groupByNamespace = (items: any) => {
  const grouped: any = {};
  items.forEach((item: any) => {
    const { namespace } = item;
    if (!grouped[namespace]) {
      grouped[namespace] = [];
    }
    grouped[namespace].push(item);
  });
  const result: any = [];
  Object.keys(grouped).forEach((item, index) => {
    result.push({
      value: index,
      label: item,
      children: grouped[item],
    });
  });
  return result;
};

const flattenOrganizationTree = (tree: any, parentPath = '', namespace: any[] = []): any[] => {
  let flattenedArray: any = [];
  for (const node of tree) {
    let isShow = true;
    if (namespace && namespace.length > 0) {
      if (namespace.indexOf(node.namespace) > -1) {
        isShow = false;
      }
    }
    const fullPath = parentPath && !isShow ? `${parentPath}.${node.label}` : node.label;
    flattenedArray.push({ ...node, label: parentPath == '' ? node.label : fullPath });
    if (node.children && node.children.length > 0) {
      flattenedArray = flattenedArray.concat(flattenOrganizationTree(node.children, fullPath, namespace));
    }
  }
  return flattenedArray;
};

export default defineComponent({
  name: 'InputFormula',
  components: {
    Row,
    Col,
    Modal,
    Tree,
    Explain,
    CodeEditor,
  },
  props: {
    modalOptions: {
      type: Object,
      required: true,
    },
    formOptions: {
      type: Object,
      required: true,
    },
    editorOptions: {
      type: Object,
      required: true,
    },
    funcOptions: {
      type: Object,
      required: true,
    },
    explainOptions: {
      type: Object,
      default: () => ({ list: [] }),
      required: true,
    },
  },
  emits: ['confirm'],
  setup(props, { emit, slots }) {
    const { modalOptions, formOptions, editorOptions, funcOptions, explainOptions } = props;

    // Modal 弹窗配置
    const modalParams = reactive({
      open: false,
      ...modalOptions,
    });

    // 左侧变量树配置
    const { treeData: formTreeData, showParentByNameSpace } = formOptions as any;
    const formParams = reactive({
      ...formOptions,
      treeData: groupByNamespace(formTreeData),
    });

    // 右侧函数树配置
    const { treeData: funcTreeData } = funcOptions as any;
    const funcParams = reactive({
      ...funcOptions,
      treeData: groupByNamespace(funcTreeData),
    });

    // 解释器配置
    const explainParams = reactive({
      ...explainOptions,
    });

    // 编辑器配置
    const codeEditorOptions = reactive({
      entityFields: flattenOrganizationTree(formTreeData, '', showParentByNameSpace),
      formulaFunctions: flattenOrganizationTree(funcTreeData),
    });

    const codeEditorRef = ref();

    // 弹窗点击确认
    const handelOk = (e: any) => {
      let docs = codeEditorRef.value.getEditorValue();
      if (docs == '') {
        message.warning('请编辑公式内容后进行保存');
        return false;
      }
      const parser = new formula.Parser();
      let result = parser.parse(docs.replace(/\{.*?\}/g, '1'));
      if (result.error != null) {
        message.warning('公式校验失败，请检查公式语法');
        return false;
      }
      modalParams.open = false;
      emit('confirm', docs);
    };

    // 弹窗点击取消
    const handelCancel = (e: any) => {
      modalParams.open = false;
    };

    // 按钮打开弹窗
    const handleDialog = () => {
      modalParams.open = true;
      nextTick(() => {
        codeEditorRef.value.setEditorValue((editorOptions as any)['docs']);
      });
    };

    // 函数选中更新解释
    const handleExplain = (e: any) => {
      (explainParams as any)['list'] = e;
    };

    // 代码提示回车选中
    const handleTipsKeyDown = (e: any) => {
      handleExplain(e.detail ? e.detail.split(' ; ') : undefined);
    };

    // 侧边栏选中节点后
    const handleSelectNode = (type: number, event: any) => {
      switch (type) {
        case 0:
          codeEditorRef.value.insertTag(event);
          break;
        case 1:
          codeEditorRef.value.insertFormula(event);
          break;
      }
    };

    return {
      modalParams,
      formParams,
      funcParams,
      explainParams,
      codeEditorOptions,
      codeEditorRef,
      handelOk,
      handelCancel,
      handleDialog,
      handleExplain,
      handleTipsKeyDown,
      handleSelectNode,
      slots,
    };
  },
});
</script>

<style scoped lang="scss">
.modal-content {
  display: flex;
  .modal-variable,
  .modal-editor,
  .modal-func {
    padding: 10px;
  }
  .modal-variable {
    background-color: #f0f2f5;
  }
  .modal-editor {
    background-color: #ffffff;
  }
  .modal-func {
    background-color: #f0f2f5;
  }
  .editor {
    height: 300px;
  }
  .explain {
    margin-top: 10px;
  }
}
</style>