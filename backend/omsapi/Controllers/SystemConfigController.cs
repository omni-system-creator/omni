using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using omsapi.Models.Common;
using omsapi.Models.Dtos;
using omsapi.Services.Interfaces;

namespace omsapi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class SystemConfigController : ControllerBase
    {
        private readonly ISystemConfigService _service;

        public SystemConfigController(ISystemConfigService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<ApiResponse<List<SystemConfigDto>>> GetAll()
        {
            var (success, message, data) = await _service.GetAllConfigsAsync();
            if (!success) return ApiResponse<List<SystemConfigDto>>.Error(message);
            return ApiResponse<List<SystemConfigDto>>.Success(data!);
        }

        [HttpGet("{key}")]
        public async Task<ApiResponse<SystemConfigDto>> GetByKey(string key)
        {
            var (success, message, data) = await _service.GetConfigByKeyAsync(key);
            if (!success) return ApiResponse<SystemConfigDto>.Error(message);
            return ApiResponse<SystemConfigDto>.Success(data!);
        }

        [HttpPut("{id}")]
        public async Task<ApiResponse<object>> Update(long id, [FromBody] UpdateSystemConfigDto dto)
        {
            var (success, message) = await _service.UpdateConfigAsync(id, dto);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }
    }
}
