using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using omsapi.Data;
using omsapi.Services.Interfaces;
using System.Web;

namespace omsapi.Controllers
{
    [Route("api/pdm/preview")]
    [ApiController]
    // [Authorize] // Optional: decided by project policy, keeping open for now or add if needed
    public class DwgPreviewController : ControllerBase
    {
        private readonly IDwgService _dwgService;
        private readonly IWebHostEnvironment _env;
        private readonly ILogger<DwgPreviewController> _logger;
        private readonly OmsContext _context;

        public DwgPreviewController(IDwgService dwgService, IWebHostEnvironment env, ILogger<DwgPreviewController> logger, OmsContext context)
        {
            _dwgService = dwgService;
            _env = env;
            _logger = logger;
            _context = context;
        }

        [HttpGet("dwg/{id}")]
        public async Task<IActionResult> PreviewDwgById(long id)
        {
            try
            {
                var doc = await _context.Set<omsapi.Models.Entities.Pdm.PdmEbomDocument>()
                    .FirstOrDefaultAsync(d => d.Id == id);

                if (doc == null)
                {
                    return NotFound("Document not found");
                }

                return PreviewDwgFile(doc.Path, doc.Name);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Preview failed for document id: {Id}", id);
                return StatusCode(500, $"Preview generation failed: {ex.Message}");
            }
        }

        [HttpGet("dwg")]
        public IActionResult PreviewDwg([FromQuery] string path)
        {
            if (string.IsNullOrEmpty(path))
            {
                return BadRequest("Path is required");
            }
            return PreviewDwgFile(path);
        }

        private IActionResult PreviewDwgFile(string path, string? downloadName = null)
        {
            try
            {
                // Security check and path resolution
                // Assuming path is relative like "/uploads/..."
                // Remove potential domain prefix if present
                if (path.StartsWith("http"))
                {
                    var uri = new Uri(path);
                    path = uri.AbsolutePath;
                }

                // Prevent directory traversal
                if (path.Contains(".."))
                {
                    return BadRequest("Invalid path");
                }

                // Remove leading slash for Path.Combine
                var relativePath = path.TrimStart('/', '\\');
                var physicalPath = Path.Combine(_env.WebRootPath, relativePath);

                if (!System.IO.File.Exists(physicalPath))
                {
                    _logger.LogWarning("DWG file not found at: {Path}", physicalPath);
                    return NotFound("File not found");
                }

                var dxfStream = _dwgService.ConvertToDxf(physicalPath);
                
                // If we want to suggest a filename (though for inline preview it might not matter as much)
                // if (!string.IsNullOrEmpty(downloadName))
                // {
                //    var pdfName = Path.ChangeExtension(downloadName, ".pdf");
                //    return File(pdfStream, "application/pdf", pdfName);
                // }
                
                return File(dxfStream, "application/dxf");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Preview failed for path: {Path}", path);
                return StatusCode(500, $"Preview generation failed: {ex.Message}");
            }
        }
    }
}
