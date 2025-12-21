using omsapi.Models.Dtos;

namespace omsapi.Services.Interfaces
{
    public interface IRoleService
    {
        Task<(bool Success, string Message, List<RoleDto>? Data)> GetAllRolesAsync();
        Task<(bool Success, string Message, RoleDto? Data)> GetRoleByIdAsync(long id);
        Task<(bool Success, string Message)> CreateRoleAsync(CreateRoleDto dto);
        Task<(bool Success, string Message)> UpdateRoleAsync(long id, UpdateRoleDto dto);
        Task<(bool Success, string Message)> DeleteRoleAsync(long id);
        
        Task<(bool Success, string Message, List<PermissionTreeDto>? Data)> GetAllPermissionsAsync();
        Task<(bool Success, string Message, List<long>? Data)> GetRolePermissionIdsAsync(long roleId);
        Task<(bool Success, string Message)> AssignPermissionsAsync(long roleId, List<long> permissionIds);
    }
}
