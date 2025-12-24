/**
 * 判断颜色是否为浅色
 * @param color HEX颜色值
 * @returns 是否为浅色
 */
export function isLightColor(color: string): boolean {
  // 移除 # 符号
  const hex = color.replace('#', '')
  
  // 转换为 RGB
  const r = parseInt(hex.substr(0, 2), 16)
  const g = parseInt(hex.substr(2, 2), 16)
  const b = parseInt(hex.substr(4, 2), 16)
  
  // 计算亮度 (使用 YIQ 公式)
  const brightness = (r * 299 + g * 587 + b * 114) / 1000
  
  // 亮度大于 128 认为是浅色
  return brightness > 128
}

/**
 * 根据背景颜色计算最佳文字颜色
 * @param backgroundColor HEX背景颜色值
 * @returns 最佳文字颜色 (#000000 或 #ffffff)
 */
export function getBestTextColor(backgroundColor: string): string {
  return isLightColor(backgroundColor) ? '#000000' : '#ffffff'
}