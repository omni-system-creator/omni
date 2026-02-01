using Microsoft.AspNetCore.Http;
using omsapi.Models.Dtos;

namespace omsapi.Services.Interfaces
{
    public interface IFinanceApArService
    {
        Task<List<FinanceApArDto>> GetApArListAsync(string type, string? status = null, string? partner = null);
        Task<(bool Success, string Message, long Id)> CreateApArAsync(CreateFinanceApArDto dto, List<IFormFile>? attachments = null);
        Task<FinanceStatsDto> GetStatsAsync();
        Task<(bool Success, string Message)> UpdateApArAsync(long id, UpdateFinanceApArDto dto, List<IFormFile>? attachments = null);
        Task<(bool Success, string Message)> DeleteApArAsync(long id);
    }
}
