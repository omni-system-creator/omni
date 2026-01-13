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
        Task InitEbomDataAsync();
        Task<(bool Success, string Message, EbomDocumentDto? Data)> UploadEbomDocumentAsync(IFormFile file);
        Task<(bool Success, string Message, string? ContentType, Stream? FileStream, string? FileName)> DownloadEbomDocumentAsync(long id);
    }
}
