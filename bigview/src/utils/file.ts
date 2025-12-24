/**
 * * base64转file
 * @param dataurl 
 * @param fileName 
 * @returns 
 */
export const base64toFile = (dataurl: string, fileName: string) => {
  let dataArr = dataurl.split(","),
  mime = (dataArr as any[])[0].match(/:(.*?);/)[1],
  bstr = atob(dataArr[1]),
  n = bstr.length,
  u8arr = new Uint8Array(n);
  while (n--) {
    u8arr[n] = bstr.charCodeAt(n);
  }
  return new File([u8arr], fileName, { type: mime });
}

/**
 * * file转url
 */
 export const fileToUrl = (file: File): string => {
  const Url = URL || window.URL || window.webkitURL
  const ImageUrl = Url.createObjectURL(file)
  return ImageUrl
}

/**
 * * url转file
 */
 export const urlToFile = (fileUrl: string, fileName = `${new Date().getTime()}`): File => {
  const dataArr = fileUrl.split(',')
  const mime = (dataArr as any[])[0].match(/:(.*);/)[1]
  const originStr = atob(dataArr[1])
  return new File([originStr], `${fileName}`, { type: mime })
}

/**
 * * file转base64
 * @param file 文件数据
 * @param callback 回调函数 
 */
export const fileTobase64 = (file: File, callback: Function) => {
  let reader = new FileReader()
  reader.readAsDataURL(file)
  reader.onload = function (e: ProgressEvent<FileReader>) {
    if (e.target) {
      let base64 = e.target.result
      callback(base64)
    }
  }
}

/**
 * * canvas转file
 * @param canvas 
 */
export const canvastoFile = (canvas: HTMLCanvasElement, name?: string) => {
  const dataurl = canvas.toDataURL('image/png')
  return urlToFile(dataurl, name)
}

/**
 * *获取上传的文件数据
 * @param { File } file 文件对象
 */
export const readFile = (file: File) => {
  return new Promise((resolve: Function) => {
    try {
      const reader = new FileReader()
      reader.onload = (evt: ProgressEvent<FileReader>) => {
        if (evt.target) {
          resolve(evt.target.result)
        }
      }
      reader.readAsText(file)
    } catch (error) {
      window['$message'].error('文件读取失败！')
    }
  })
}

/**
 * * 通过 a 标签下载数据
 * @param url 
 * @param filename 
 * @param fileSuffix 
 */
export const downloadByA = (url: string, filename = new Date().getTime(), fileSuffix?: string) => {
  const ele = document.createElement('a') // 创建下载链接
  ele.download = `${filename}.${fileSuffix}` //设置下载的名称
  ele.style.display = 'none' // 隐藏的可下载链接
  // 字符内容转变成blob地址
  ele.href = url
  // 绑定点击时间
  document.body.appendChild(ele)
  ele.click()
  // 然后移除
  document.body.removeChild(ele)
}

/**
 * * 下载数据
 * @param { string } content 数据内容
 * @param { ?string } filename 文件名称（默认随机字符）
 * @param { ?string } fileSuffix 文件名称（默认随机字符）
 */
export const downloadTextFile = (
  content: string,
  filename = new Date().getTime(),
  fileSuffix?: string
) => {
  // 字符内容转变成blob地址
  const blob = new Blob([content])
  downloadByA(URL.createObjectURL(blob), filename, fileSuffix)
}

/**
 * * 解析CSV数据的表头
 * @param { string } csvData CSV数据字符串
 * @returns { string[] } 表头字段数组
 */
export const parseCSVHeaders = (csvData: string): string[] => {
  if (!csvData || typeof csvData !== 'string') {
    return []
  }
  
  // 获取第一行数据
  const firstLine = csvData.split('\n')[0]
  if (!firstLine) {
    return []
  }
  
  // 按逗号分割并去除空白字符
  return firstLine.split(',').map(header => header.trim()).filter(header => header)
}

/**
 * * JSON验证状态检查
 * @param { string } jsonStr JSON字符串
 * @returns { 'success' | 'error' | undefined } 验证状态
 */
export const getJsonValidationStatus = (jsonStr: string): 'success' | 'error' | undefined => {
  if (!jsonStr) return undefined
  try {
    const data = JSON.parse(jsonStr)
    if (!Array.isArray(data)) return 'error'
    if (data.length === 0) return 'error'
    if (!data.every(item => typeof item === 'object' && item !== null)) return 'error'
    return 'success'
  } catch {
    return 'error'
  }
}

/**
 * * JSON数据验证
 * @param { string } jsonStr JSON字符串
 * @returns { { isValid: boolean, error: string } } 验证结果
 */
export const validateJsonData = (jsonStr: string): { isValid: boolean, error: string } => {
  if (!jsonStr) {
    return { isValid: true, error: '' }
  }

  try {
    const data = JSON.parse(jsonStr)
    if (!Array.isArray(data)) {
      return { isValid: false, error: '数据必须是数组格式' }
    }
    if (data.length === 0) {
      return { isValid: false, error: '数据数组不能为空' }
    }
    if (!data.every(item => typeof item === 'object' && item !== null)) {
      return { isValid: false, error: '数组中的每个元素都必须是对象' }
    }
    return { isValid: true, error: '' }
  } catch (error) {
    return { isValid: false, error: 'JSON格式错误，请检查语法' }
  }
}