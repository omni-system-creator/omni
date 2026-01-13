using omsapi.Models.Dtos.Pdm;

namespace omsapi.Services.Interfaces
{
    public interface IPdmService
    {
        Task<List<EbomItemDto>> GetEbomTreesAsync();
        Task<EbomDetailDto?> GetEbomItemAsync(string id);
        Task<List<EbomItemDto>> GetEbomChildrenAsync(string parentId);
        Task<EbomItemDto> CreateEbomItemAsync(CreateEbomItemDto dto);
        Task<EbomItemDto> UpdateEbomItemAsync(string id, UpdateEbomItemDto dto);
        Task<bool> DeleteEbomItemAsync(string id);
        Task<bool> AddChildItemAsync(AddChildItemDto dto);
        Task<bool> UpdateChildItemQtyAsync(string parentId, string childId, decimal qty);
        Task<bool> RemoveChildItemAsync(string parentId, string childId);
        Task<List<EbomItemDto>> SearchEbomItemsAsync(string keyword, string excludeId);
        Task InitEbomDataAsync();
        Task<(bool Success, string Message, EbomDocumentDto? Data)> UploadEbomDocumentAsync(IFormFile file);
        Task<(bool Success, string Message, string? ContentType, Stream? FileStream, string? FileName)> DownloadEbomDocumentAsync(long id);

        Task<(bool Success, string Message)> ImportEbomAsync(IFormFile file);
        Task<(bool Success, string Message, byte[]? FileContent, string? FileName)> ExportEbomAsync(string? rootId);
        Task<(bool Success, string Message, object? ComparisonResult)> CompareEbomAsync(List<string> itemIds);
    }
}
