using omsapi.Models.Dtos.Sales;
using omsapi.Models.Common;

namespace omsapi.Services.Interfaces
{
    public interface ISalesBidProjectService
    {
        Task<PagedResult<SalesBidProjectDto>> GetListAsync(int page, int pageSize, string? keyword = null, string? region = null, string? type = null, string? status = null);
        Task<SalesBidProjectDto?> GetByIdAsync(string id);
        Task<SalesBidProjectDto> CreateAsync(CreateSalesBidProjectDto dto);
        Task<SalesBidProjectDto?> UpdateAsync(string id, UpdateSalesBidProjectDto dto);
        Task<bool> DeleteAsync(string id);
    }
}
