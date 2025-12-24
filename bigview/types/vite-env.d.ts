/// <reference types="vite/client" />

interface ImportMetaEnv {
  // 端口
  VITE_DEV_PORT: string;
  // 开发地址
  VITE_DEV_PATH: string
  // 生产地址
  VITE_PRO_PATH: string
  //
  VITE_MAP_METRO_BASE_URL:string
  // 是否是内网
  VITE_IS_LOCAL:string
}