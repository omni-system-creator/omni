declare module 'echarts' {
  export interface ECharts {
    setOption(option: any, notMerge?: boolean, lazyUpdate?: boolean): void;
    resize(opts?: any): void;
    on(eventName: string, handler: Function, context?: any): void;
    off(eventName: string, handler?: Function): void;
    dispose(): void;
    clear(): void;
    [key: string]: any;
  }

  export interface EChartsOption {
    [key: string]: any;
  }

  export function init(dom: HTMLElement | null, theme?: string | object | null, opts?: {
    devicePixelRatio?: number;
    renderer?: 'canvas' | 'svg';
    useDirtyRect?: boolean;
    useCoarsePointer?: 'auto' | boolean;
    pointerSize?: number;
    ssr?: boolean;
    width?: number | string | 'auto';
    height?: number | string | 'auto';
    locale?: string;
  }): ECharts;

  export function getInstanceByDom(dom: HTMLElement): ECharts | undefined;
  
  export function registerMap(mapName: string, geoJson: any, specialAreas?: any): void;
  
  export function registerTheme(themeName: string, theme: any): void;

  export function connect(group: string | any[]): void;
  
  export function disconnect(group: string): void;

  export const graphic: any;
  
  export const version: string;
}
