
/**
 * 获取kkview预览地址
 * @param fileUrl 文件地址
 * @param fileName 文件名（用于判断文件类型）
 * @returns 预览地址
 */
export const getKkViewUrl = (fileUrl: string, fileName: string): string => {
    if (!fileUrl) return '';

    // Construct full URL if it's relative
    if (fileUrl.startsWith('/')) {
        fileUrl = `${window.location.origin}${fileUrl}`;
    }
    
    const encodedUrl = window.btoa(fileUrl);
    let url = `https://kkview.dingzhi.info/onlinePreview?url=${encodedUrl}`;
    
    const ext = fileName.split('.').pop()?.toLowerCase();
    if (['doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'pdf'].includes(ext || '')) {
        url += '&officePreviewType=pdf';
    }
    
    return url;
};
