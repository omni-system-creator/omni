using omsapi.Models.Common;
using omsapi.Models.Dtos.System;

namespace omsapi.Services.Interfaces
{
    public interface IAnonceService
    {
        Task<PagedResult<AnonceDto>> GetListAsync(AnonceQueryDto query);
        Task<AnonceDto?> GetByIdAsync(long id);
        Task<AnonceDto> CreateAsync(CreateAnonceDto dto, long userId);
        Task<AnonceDto?> UpdateAsync(long id, UpdateAnonceDto dto, long userId);
        Task<bool> DeleteAsync(long id);
        Task<bool> PublishAsync(long id, bool isPublish);
    }
}
