using System.IO;

namespace omsapi.Services.Interfaces
{
    public interface IDwgService
    {
        /// <summary>
        /// Convert DWG file to DXF stream for frontend preview
        /// </summary>
        /// <param name="filePath">Physical path to the DWG file</param>
        /// <returns>MemoryStream containing the DXF content</returns>
        Stream ConvertToDxf(string filePath);
    }
}
