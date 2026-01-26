using System.IO;
using System.Threading;
using System.Threading.Tasks;

namespace omsapi.Services.Interfaces
{
    public interface IDwgService
    {
        /// <summary>
        /// Convert DWG file to DXF stream for desktop or further processing
        /// </summary>
        /// <param name="filePath">Physical path to the DWG file</param>
        /// <returns>MemoryStream containing the DXF content</returns>
        Stream ConvertToDxf(string filePath);

        /// <summary>
        /// Convert DWG file to PDF stream for web preview (via LibreCAD CLI)
        /// </summary>
        /// <param name="filePath">Physical path to the DWG file</param>
        /// <returns>Stream containing PDF content</returns>
        Task<Stream> ConvertToPdfAsync(string filePath, string paperSize = "A3", string orientation = "portrait", CancellationToken cancellationToken = default);

        /// <summary>
        /// Convert DWG file to SVG stream for web preview (via LibreCAD CLI, if available)
        /// </summary>
        /// <param name="filePath">Physical path to the DWG file</param>
        /// <returns>Stream containing SVG content</returns>
        Task<Stream> ConvertToSvgAsync(string filePath, CancellationToken cancellationToken = default);
    }
}
