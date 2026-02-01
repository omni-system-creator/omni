using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using omsapi.Models.Dtos;
using omsapi.Models.Common;
using omsapi.Services.Interfaces;

namespace omsapi.Controllers
{
    [ApiController]
    [Route("api/finance/subject")]
    [Authorize]
    public class FinanceSubjectController : ControllerBase
    {
        private readonly IFinanceSubjectService _service;

        public FinanceSubjectController(IFinanceSubjectService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<ApiResponse<List<FinanceSubjectDto>>> GetSubjects([FromQuery] string? direction)
        {
            var data = await _service.GetSubjectsAsync(direction);
            return ApiResponse<List<FinanceSubjectDto>>.Success(data);
        }

        [HttpPost]
        public async Task<ApiResponse<object>> CreateSubject([FromBody] CreateFinanceSubjectDto dto)
        {
            var (success, message) = await _service.CreateSubjectAsync(dto);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }

        [HttpPut("{id}")]
        public async Task<ApiResponse<object>> UpdateSubject(long id, [FromBody] UpdateFinanceSubjectDto dto)
        {
            var (success, message) = await _service.UpdateSubjectAsync(id, dto);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }

        [HttpDelete("{id}")]
        public async Task<ApiResponse<object>> DeleteSubject(long id)
        {
            var (success, message) = await _service.DeleteSubjectAsync(id);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }
    }
}
