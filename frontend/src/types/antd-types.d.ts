import type { TableColumnType } from 'ant-design-vue';
import type { Rule as AntRule } from 'ant-design-vue/es/form';
import type { TreeProps as AntTreeProps } from 'ant-design-vue/es/tree';
import type { TreeSelectProps as AntTreeSelectProps } from 'ant-design-vue/es/tree-select';
import type { UploadFile as AntUploadFile, UploadChangeParam as AntUploadChangeParam } from 'ant-design-vue/es/upload';
import type { PresetStatusColorType as AntPresetStatusColorType } from 'ant-design-vue/es/_util/colors';

declare global {
  export type ColumnType<T = any> = TableColumnType<T>;
  export type Rule = AntRule;
  export type TreeProps = AntTreeProps;
  export type TreeSelectProps = AntTreeSelectProps;
  export type UploadFile = AntUploadFile;
  export type UploadChangeParam = AntUploadChangeParam;
  export type PresetStatusColorType = AntPresetStatusColorType;
}
