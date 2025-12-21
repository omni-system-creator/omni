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
    public class RoleController : ControllerBase
    {
        private readonly IRoleService _roleService;

        public RoleController(IRoleService roleService)
        {
            _roleService = roleService;
        }

        [HttpGet]
        public async Task<ApiResponse<List<RoleDto>>> GetAll()
        {
            var (success, message, data) = await _roleService.GetAllRolesAsync();
            if (!success) return ApiResponse<List<RoleDto>>.Error(message);
            return ApiResponse<List<RoleDto>>.Success(data!);
        }

        [HttpGet("{id}")]
        public async Task<ApiResponse<RoleDto>> GetById(long id)
        {
            var (success, message, data) = await _roleService.GetRoleByIdAsync(id);
            if (!success) return ApiResponse<RoleDto>.Error(message);
            return ApiResponse<RoleDto>.Success(data!);
        }

        [HttpPost]
        public async Task<ApiResponse<object>> Create([FromBody] CreateRoleDto dto)
        {
            var (success, message) = await _roleService.CreateRoleAsync(dto);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }

        [HttpPut("{id}")]
        public async Task<ApiResponse<object>> Update(long id, [FromBody] UpdateRoleDto dto)
        {
            var (success, message) = await _roleService.UpdateRoleAsync(id, dto);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }

        [HttpDelete("{id}")]
        public async Task<ApiResponse<object>> Delete(long id)
        {
            var (success, message) = await _roleService.DeleteRoleAsync(id);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }

        [HttpGet("permissions")]
        public async Task<ApiResponse<List<PermissionTreeDto>>> GetAllPermissions()
        {
            var (success, message, data) = await _roleService.GetAllPermissionsAsync();
            if (!success) return ApiResponse<List<PermissionTreeDto>>.Error(message);
            return ApiResponse<List<PermissionTreeDto>>.Success(data!);
        }

        [HttpGet("{id}/permissions")]
        public async Task<ApiResponse<List<long>>> GetRolePermissionIds(long id)
        {
            var (success, message, data) = await _roleService.GetRolePermissionIdsAsync(id);
            if (!success) return ApiResponse<List<long>>.Error(message);
            return ApiResponse<List<long>>.Success(data!);
        }

        [HttpPost("{id}/permissions")]
        public async Task<ApiResponse<object>> AssignPermissions(long id, [FromBody] AssignPermissionDto dto)
        {
            var (success, message) = await _roleService.AssignPermissionsAsync(id, dto.PermissionIds);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }
    }
}
