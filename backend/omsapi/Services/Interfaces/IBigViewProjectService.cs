using omsapi.Models.Dtos.BigView;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace omsapi.Services.Interfaces
{
    public interface IBigViewProjectService
    {
        Task<(bool Success, string Message, IEnumerable<BigViewProjectDto>? Data, int Total)> GetListAsync(int page, int limit, string? keyword);
        Task<(bool Success, string Message, BigViewProjectDto? Data)> GetByIdAsync(long id);
        Task<(bool Success, string Message, long Id)> CreateAsync(CreateBigViewProjectDto dto, long userId);
        Task<(bool Success, string Message)> UpdateAsync(UpdateBigViewProjectDto dto);
        Task<(bool Success, string Message)> DeleteAsync(long id);
        Task<(bool Success, string Message)> ChangeReleaseStateAsync(long id, string state);
    }
}
