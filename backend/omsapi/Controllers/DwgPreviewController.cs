using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using omsapi.Data;
using omsapi.Services.Interfaces;
using System.Threading;

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

        [HttpGet("dwg/{id}/pdf")]
        public async Task<IActionResult> PreviewDwgPdfById(long id, [FromQuery] string paperSize = "A3", [FromQuery] string orientation = "portrait", CancellationToken cancellationToken = default)
        {
            try
            {
                var doc = await _context.Set<omsapi.Models.Entities.Pdm.PdmEbomDocument>()
                    .FirstOrDefaultAsync(d => d.Id == id, cancellationToken);

                if (doc == null)
                {
                    return NotFound("Document not found");
                }

                var physicalPath = ResolvePhysicalPath(doc.Path);
                if (!System.IO.File.Exists(physicalPath))
                {
                    _logger.LogWarning("DWG file not found at: {Path}", physicalPath);
                    return NotFound("File not found");
                }

                var pdfStream = await _dwgService.ConvertToPdfAsync(physicalPath, paperSize, orientation, cancellationToken);
                return File(pdfStream, "application/pdf");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "PDF preview failed for document id: {Id}", id);
                return StatusCode(500, $"PDF preview generation failed: {ex.Message}");
            }
        }

        [HttpGet("dwg/pdf")]
        public async Task<IActionResult> PreviewDwgPdf([FromQuery] string path, [FromQuery] string paperSize = "A3", [FromQuery] string orientation = "portrait", CancellationToken cancellationToken = default)
        {
            if (string.IsNullOrEmpty(path))
            {
                return BadRequest("Path is required");
            }

            try
            {
                var physicalPath = ResolvePhysicalPath(path);
                if (!System.IO.File.Exists(physicalPath))
                {
                    _logger.LogWarning("DWG file not found at: {Path}", physicalPath);
                    return NotFound("File not found");
                }

                var pdfStream = await _dwgService.ConvertToPdfAsync(physicalPath, paperSize, orientation, cancellationToken);
                return File(pdfStream, "application/pdf");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "PDF preview failed for path: {Path}", path);
                return StatusCode(500, $"PDF preview generation failed: {ex.Message}");
            }
        }

        [HttpGet("dwg/{id}/svg")]
        public async Task<IActionResult> PreviewDwgSvgById(long id, CancellationToken cancellationToken)
        {
            try
            {
                var doc = await _context.Set<omsapi.Models.Entities.Pdm.PdmEbomDocument>()
                    .FirstOrDefaultAsync(d => d.Id == id, cancellationToken);

                if (doc == null)
                {
                    return NotFound("Document not found");
                }

                var physicalPath = ResolvePhysicalPath(doc.Path);
                if (!System.IO.File.Exists(physicalPath))
                {
                    _logger.LogWarning("DWG file not found at: {Path}", physicalPath);
                    return NotFound("File not found");
                }

                var svgStream = await _dwgService.ConvertToSvgAsync(physicalPath, cancellationToken);
                return File(svgStream, "image/svg+xml");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "SVG preview failed for document id: {Id}", id);
                return StatusCode(500, $"SVG preview generation failed: {ex.Message}");
            }
        }

        [HttpGet("dwg/svg")]
        public async Task<IActionResult> PreviewDwgSvg([FromQuery] string path, CancellationToken cancellationToken)
        {
            if (string.IsNullOrEmpty(path))
            {
                return BadRequest("Path is required");
            }

            try
            {
                var physicalPath = ResolvePhysicalPath(path);
                if (!System.IO.File.Exists(physicalPath))
                {
                    _logger.LogWarning("DWG file not found at: {Path}", physicalPath);
                    return NotFound("File not found");
                }

                var svgStream = await _dwgService.ConvertToSvgAsync(physicalPath, cancellationToken);
                return File(svgStream, "image/svg+xml");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "SVG preview failed for path: {Path}", path);
                return StatusCode(500, $"SVG preview generation failed: {ex.Message}");
            }
        }

        private string ResolvePhysicalPath(string path)
        {
            if (path.StartsWith("http"))
            {
                var uri = new Uri(path);
                path = uri.AbsolutePath;
            }

            if (path.Contains(".."))
            {
                throw new InvalidOperationException("Invalid path");
            }

            var relativePath = path.TrimStart('/', '\\');
            var physicalPath = Path.Combine(_env.WebRootPath, relativePath);
            return physicalPath;
        }

        private IActionResult PreviewDwgFile(string path, string? downloadName = null)
        {
            try
            {
                var physicalPath = ResolvePhysicalPath(path);

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
