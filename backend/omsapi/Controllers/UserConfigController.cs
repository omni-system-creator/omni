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
    public class UserConfigController : ControllerBase
    {
        private readonly IUserConfigService _service;

        public UserConfigController(IUserConfigService service)
        {
            _service = service;
        }

        /// <summary>
        /// 获取当前用户在当前组织的配置
        /// </summary>
        /// <param name="prefix">可选：按Key前缀过滤</param>
        [HttpGet]
        public async Task<ApiResponse<List<UserConfigDto>>> GetConfigs([FromQuery] string? prefix)
        {
            var result = await _service.GetConfigsAsync(prefix);
            if (!result.Success) return ApiResponse<List<UserConfigDto>>.Error(result.Message);
            return ApiResponse<List<UserConfigDto>>.Success(result.Data);
        }

        /// <summary>
        /// 保存或更新配置
        /// </summary>
        [HttpPost]
        public async Task<ApiResponse<object>> SetConfig([FromBody] UserConfigDto dto)
        {
            var result = await _service.SetConfigAsync(dto);
            if (!result.Success) return ApiResponse<object>.Error(result.Message);
            return ApiResponse<object>.Success(null, result.Message);
        }

        /// <summary>
        /// 删除配置
        /// </summary>
        [HttpDelete("{key}")]
        public async Task<ApiResponse<object>> DeleteConfig(string key)
        {
            var result = await _service.DeleteConfigAsync(key);
            if (!result.Success) return ApiResponse<object>.Error(result.Message);
            return ApiResponse<object>.Success(null, result.Message);
        }
    }
}
