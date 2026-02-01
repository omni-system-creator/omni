using Microsoft.AspNetCore.Http;
using omsapi.Models.Dtos;

namespace omsapi.Services.Interfaces
{
    public interface IFinanceInvoiceService
    {
        Task<List<FinanceInvoiceDto>> GetInvoicesAsync(string? direction = null, string? type = null, string? status = null, string? keyword = null);
        Task<FinanceInvoiceDto?> GetInvoiceByIdAsync(long id);
        Task<(bool Success, string Message, long Id)> CreateInvoiceAsync(CreateFinanceInvoiceDto dto, List<IFormFile>? attachments = null);
        Task<(bool Success, string Message)> UpdateInvoiceAsync(long id, UpdateFinanceInvoiceDto dto, List<IFormFile>? attachments = null);
        Task<(bool Success, string Message)> DeleteInvoiceAsync(long id);
        Task<(bool Success, string Message, FinanceInvoiceDto? Data)> RecognizeInvoiceAsync(IFormFile file);
    }
}
