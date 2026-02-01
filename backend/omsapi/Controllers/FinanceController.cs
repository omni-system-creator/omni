using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using omsapi.Models.Dtos;
using omsapi.Models.Common;
using omsapi.Services;

namespace omsapi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class FinanceController : ControllerBase
    {
        private readonly FinanceService _financeService;

        public FinanceController(FinanceService financeService)
        {
            _financeService = financeService;
        }

        [HttpGet("subject")]
        public async Task<ApiResponse<List<FinanceSubjectDto>>> GetSubjects([FromQuery] string? direction)
        {
            var data = await _financeService.GetSubjectsAsync(direction);
            return ApiResponse<List<FinanceSubjectDto>>.Success(data);
        }

        [HttpPost("subject")]
        public async Task<ApiResponse<object>> CreateSubject([FromBody] CreateFinanceSubjectDto dto)
        {
            var (success, message) = await _financeService.CreateSubjectAsync(dto);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }

        [HttpPut("subject/{id}")]
        public async Task<ApiResponse<object>> UpdateSubject(long id, [FromBody] UpdateFinanceSubjectDto dto)
        {
            var (success, message) = await _financeService.UpdateSubjectAsync(id, dto);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }

        [HttpDelete("subject/{id}")]
        public async Task<ApiResponse<object>> DeleteSubject(long id)
        {
            var (success, message) = await _financeService.DeleteSubjectAsync(id);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }

        [HttpGet("apar")]
        public async Task<ApiResponse<List<FinanceApArDto>>> GetApArList([FromQuery] string type, [FromQuery] string? status, [FromQuery] string? partner)
        {
            if (string.IsNullOrEmpty(type)) return ApiResponse<List<FinanceApArDto>>.Error("必须指定类型(AR/AP)");
            var data = await _financeService.GetApArListAsync(type, status, partner);
            return ApiResponse<List<FinanceApArDto>>.Success(data);
        }

        [HttpPost("apar")]
        public async Task<ApiResponse<object>> CreateApAr([FromForm] CreateFinanceApArDto dto, [FromForm] List<IFormFile> attachments)
        {
            var (success, message, id) = await _financeService.CreateApArAsync(dto, attachments);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(new { Id = id }, message);
        }

        [HttpGet("stats")]
        public async Task<ApiResponse<FinanceStatsDto>> GetStats()
        {
            var data = await _financeService.GetStatsAsync();
            return ApiResponse<FinanceStatsDto>.Success(data);
        }

        [HttpPut("apar/{id}")]
        public async Task<ApiResponse<object>> UpdateApAr(long id, [FromForm] UpdateFinanceApArDto dto, [FromForm] List<IFormFile>? attachments)
        {
            var (success, message) = await _financeService.UpdateApArAsync(id, dto, attachments);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }

        [HttpDelete("apar/{id}")]
        public async Task<ApiResponse<object>> DeleteApAr(long id)
        {
            var (success, message) = await _financeService.DeleteApArAsync(id);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }

        [HttpPost("attachment")]
        public async Task<ApiResponse<FinanceAttachmentDto>> UploadAttachment(IFormFile file, [FromForm] string targetType, [FromForm] long targetId)
        {
            var (success, message, data) = await _financeService.UploadAttachmentAsync(file, targetType, targetId);
            if (!success) return ApiResponse<FinanceAttachmentDto>.Error(message);
            return ApiResponse<FinanceAttachmentDto>.Success(data, message);
        }

        [HttpDelete("attachment/{id}")]
        public async Task<ApiResponse<object>> DeleteAttachment(long id)
        {
            var (success, message) = await _financeService.DeleteAttachmentAsync(id);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }

        [HttpGet("attachment/{id}/download")]
        [AllowAnonymous]
        public async Task<IActionResult> DownloadAttachment(long id)
        {
            var (success, message, fileInfo, stream) = await _financeService.GetAttachmentStreamAsync(id);
            if (!success) return NotFound(message);
            return File(stream, fileInfo.ContentType, fileInfo.FileName);
        }
    }
}
