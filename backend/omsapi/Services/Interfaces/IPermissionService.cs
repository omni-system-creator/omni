using omsapi.Models.Dtos;

namespace omsapi.Services.Interfaces
{
    public interface IPermissionService
    {
        Task<(bool Success, string Message, List<PermissionTreeDto>? Data)> GetAllPermissionsAsync();
        Task<(bool Success, string Message)> CreatePermissionAsync(CreatePermissionDto dto);
        Task<(bool Success, string Message)> UpdatePermissionAsync(long id, UpdatePermissionDto dto);
        Task<(bool Success, string Message)> DeletePermissionAsync(long id);
        Task<(bool Success, string Message)> BatchUpdateStructureAsync(List<UpdatePermissionStructureDto> dtos);
    }
}
