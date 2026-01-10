using omsapi.Models.Dtos.Sales;
using Microsoft.AspNetCore.Http;

namespace omsapi.Services.Interfaces
{
    public interface ISalesTenderAnalysisService
    {
        Task<SalesTenderAnalysisDto?> GetByBidProjectIdAsync(string bidProjectId);
        Task<SalesTenderAnalysisDto> CreateOrUpdateAsync(CreateSalesTenderAnalysisDto dto);
        Task<SalesTenderAnalysisDto> UploadTenderDocAsync(string bidProjectId, IFormFile file, long userId);
        Task<(bool success, string message, string? contentType, Stream? stream, string? fileName)> DownloadTenderDocAsync(string bidProjectId, long userId);
        Task<SalesTenderAnalysisStatusDto> GetStatusAsync(string bidProjectId, long userId);
        Task CancelAnalysisAsync(string bidProjectId, long userId);
        Task<SalesTenderAnalysisStatusDto> StartReanalyzeAsync(string bidProjectId, long userId);
        Task<List<SalesTenderAnalysisLogDto>> GetLogsAsync(string bidProjectId, long? runId, long? afterId, int take, long userId);
    }
}
