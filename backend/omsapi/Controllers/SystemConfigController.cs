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
        private readonly IWebHostEnvironment _env;

        public SystemConfigController(ISystemConfigService service, IWebHostEnvironment env)
        {
            _service = service;
            _env = env;
        }

        [HttpPost("upload")]
        public async Task<ApiResponse<object>> Upload(IFormFile file)
        {
            if (file == null || file.Length == 0) return ApiResponse<object>.Error("请选择文件");

            var webRootPath = _env.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
            var uploadPath = Path.Combine(webRootPath, "uploads", "system");
            if (!Directory.Exists(uploadPath)) Directory.CreateDirectory(uploadPath);

            var ext = Path.GetExtension(file.FileName);
            var fileName = $"{Guid.NewGuid()}{ext}";
            var filePath = Path.Combine(uploadPath, fileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            var url = $"/uploads/system/{fileName}";
            return ApiResponse<object>.Success(new { url });
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

        [HttpDelete("{id}")]
        public async Task<ApiResponse<object>> Delete(long id)
        {
            var (success, message) = await _service.DeleteConfigAsync(id);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }
    }
}
