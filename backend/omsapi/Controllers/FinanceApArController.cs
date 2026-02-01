using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using omsapi.Models.Dtos;
using omsapi.Models.Common;
using omsapi.Services.Interfaces;

namespace omsapi.Controllers
{
    [ApiController]
    [Route("api/finance/apar")]
    [Authorize]
    public class FinanceApArController : ControllerBase
    {
        private readonly IFinanceApArService _service;

        public FinanceApArController(IFinanceApArService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<ApiResponse<List<FinanceApArDto>>> GetApArList([FromQuery] string type, [FromQuery] string? status, [FromQuery] string? partner)
        {
            if (string.IsNullOrEmpty(type)) return ApiResponse<List<FinanceApArDto>>.Error("必须指定类型(AR/AP)");
            var data = await _service.GetApArListAsync(type, status, partner);
            return ApiResponse<List<FinanceApArDto>>.Success(data);
        }

        [HttpPost]
        public async Task<ApiResponse<object>> CreateApAr([FromForm] CreateFinanceApArDto dto, [FromForm] List<IFormFile> attachments)
        {
            var (success, message, id) = await _service.CreateApArAsync(dto, attachments);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(new { Id = id }, message);
        }

        [HttpGet("stats")]
        public async Task<ApiResponse<FinanceStatsDto>> GetStats()
        {
            var data = await _service.GetStatsAsync();
            return ApiResponse<FinanceStatsDto>.Success(data);
        }

        [HttpPut("{id}")]
        public async Task<ApiResponse<object>> UpdateApAr(long id, [FromForm] UpdateFinanceApArDto dto, [FromForm] List<IFormFile>? attachments)
        {
            var (success, message) = await _service.UpdateApArAsync(id, dto, attachments);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }

        [HttpDelete("{id}")]
        public async Task<ApiResponse<object>> DeleteApAr(long id)
        {
            var (success, message) = await _service.DeleteApArAsync(id);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }
    }
}
