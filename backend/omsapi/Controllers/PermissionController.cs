using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using omsapi.Models.Common;
using omsapi.Models.Dtos;
using omsapi.Services.Interfaces;

namespace omsapi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize] // 实际上应该限制为 ADMIN 角色
    public class PermissionController : ControllerBase
    {
        private readonly IPermissionService _permissionService;

        public PermissionController(IPermissionService permissionService)
        {
            _permissionService = permissionService;
        }

        [HttpGet]
        public async Task<ApiResponse<List<PermissionTreeDto>>> GetAll()
        {
            var (success, message, data) = await _permissionService.GetAllPermissionsAsync();
            if (!success) return ApiResponse<List<PermissionTreeDto>>.Error(message);
            return ApiResponse<List<PermissionTreeDto>>.Success(data!);
        }

        [HttpPost]
        public async Task<ApiResponse<object>> Create([FromBody] CreatePermissionDto dto)
        {
            var (success, message) = await _permissionService.CreatePermissionAsync(dto);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }

        [HttpPut("{id}")]
        public async Task<ApiResponse<object>> Update(long id, [FromBody] UpdatePermissionDto dto)
        {
            var (success, message) = await _permissionService.UpdatePermissionAsync(id, dto);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }

        [HttpDelete("{id}")]
        public async Task<ApiResponse<object>> Delete(long id)
        {
            var (success, message) = await _permissionService.DeletePermissionAsync(id);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }
        [HttpPost("batch-structure")]
        public async Task<ApiResponse<object>> BatchUpdateStructure([FromBody] List<UpdatePermissionStructureDto> dtos)
        {
            var (success, message) = await _permissionService.BatchUpdateStructureAsync(dtos);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }
    }
}
