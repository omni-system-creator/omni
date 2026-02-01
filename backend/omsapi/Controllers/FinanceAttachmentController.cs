using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using omsapi.Models.Dtos;
using omsapi.Models.Common;
using omsapi.Services.Interfaces;

namespace omsapi.Controllers
{
    [ApiController]
    [Route("api/finance/attachment")]
    [Authorize]
    public class FinanceAttachmentController : ControllerBase
    {
        private readonly IFinanceAttachmentService _service;

        public FinanceAttachmentController(IFinanceAttachmentService service)
        {
            _service = service;
        }

        [HttpPost]
        public async Task<ApiResponse<FinanceAttachmentDto>> UploadAttachment(IFormFile file, [FromForm] string targetType, [FromForm] long targetId)
        {
            var (success, message, data) = await _service.UploadAttachmentAsync(file, targetType, targetId);
            if (!success) return ApiResponse<FinanceAttachmentDto>.Error(message);
            return ApiResponse<FinanceAttachmentDto>.Success(data, message);
        }

        [HttpDelete("{id}")]
        public async Task<ApiResponse<object>> DeleteAttachment(long id)
        {
            var (success, message) = await _service.DeleteAttachmentAsync(id);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }

        [HttpGet("{id}/download")]
        public async Task<IActionResult> DownloadAttachment(long id)
        {
            var (success, message, fileInfo, stream) = await _service.GetAttachmentStreamAsync(id);
            if (!success || fileInfo == null || stream == null) return NotFound(message);
            return File(stream, fileInfo.ContentType, fileInfo.FileName);
        }
    }
}
