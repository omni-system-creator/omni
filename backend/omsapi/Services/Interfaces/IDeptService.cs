using omsapi.Models.Common;
using omsapi.Models.Dtos;

namespace omsapi.Services.Interfaces
{
    public interface IDeptService
    {
        Task<List<DeptTreeDto>> GetDeptTreeAsync(long userId, long? rootId = null);
        Task<List<DeptTreeDto>> GetRootDeptsAsync();
        Task<long?> GetRootDeptIdAsync(long deptId);
        Task<DeptTreeDto?> GetDeptByIdAsync(long id);
        Task<DeptTreeDto> CreateDeptAsync(CreateDeptDto dto);
        Task<bool> UpdateDeptAsync(long id, UpdateDeptDto dto);
        Task<bool> DeleteDeptAsync(long id);
        Task<bool> BatchUpdateStructureAsync(List<UpdateDeptStructureDto> dtos);
        Task<PagedResult<DeptTreeDto>> GetDeptListAsync(string? keyword, int page, int pageSize);
    }
}
