using Microsoft.AspNetCore.Http;
using omsapi.Models.Dtos;

namespace omsapi.Services.Interfaces
{
    public interface IFinanceAttachmentService
    {
        Task<(bool Success, string Message, FinanceAttachmentDto? Data)> UploadAttachmentAsync(IFormFile file, string targetType, long targetId);
        Task<(bool Success, string Message, FinanceAttachmentDto? Data)> UploadInternalAsync(IFormFile file, string targetType, long targetId, long orgId, string? uploader);
        Task<(bool Success, string Message)> DeleteAttachmentAsync(long id);
        Task<(bool Success, string Message)> DeleteAttachmentsByTargetAsync(string targetType, long targetId);
        Task<(bool Success, string Message, FinanceAttachmentDto? FileInfo, Stream? Stream)> GetAttachmentStreamAsync(long id);
    }
}
