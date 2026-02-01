using Microsoft.AspNetCore.Http;
using omsapi.Models.Dtos;

namespace omsapi.Services.Interfaces
{
    public interface IFinanceSubjectService
    {
        Task<List<FinanceSubjectDto>> GetSubjectsAsync(string? direction = null);
        Task<(bool Success, string Message)> CreateSubjectAsync(CreateFinanceSubjectDto dto);
        Task<(bool Success, string Message)> UpdateSubjectAsync(long id, UpdateFinanceSubjectDto dto);
        Task<(bool Success, string Message)> DeleteSubjectAsync(long id);
    }
}
