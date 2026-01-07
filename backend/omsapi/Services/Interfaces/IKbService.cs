using OmsApi.Models.Dtos.Kb;
using OmsApi.Models.Entities.Kb;

namespace omsapi.Services.Interfaces
{
    public interface IKbService
    {
        // KB Management
        Task<List<KbInfoDto>> GetAllKbsAsync();
        Task<KbInfoDto?> GetKbByIdAsync(Guid id);
        Task<KbInfoDto> CreateKbAsync(CreateKbDto dto, Guid userId);
        Task<bool> UpdateKbAsync(Guid id, UpdateKbDto dto);
        Task<bool> DeleteKbAsync(Guid id);

        // File Management
        Task<List<KbFileDto>> GetKbFilesAsync(Guid kbId);
        Task<List<KbFileDto>> GetFoldersAsync(Guid kbId, Guid? parentId = null);
        Task<KbFileDto> CreateFolderAsync(CreateKbFolderDto dto);
        Task<KbFileDto> UploadFileAsync(Guid kbId, IFormFile file, Guid? parentId = null);
        Task<bool> DeleteFileAsync(Guid fileId);
        Task<bool> RenameFileAsync(Guid fileId, string newName);
        Task<bool> MoveFileAsync(Guid fileId, Guid? targetFolderId);
        Task<(string PhysicalPath, string Name, string ContentType)?> GetFileDownloadInfoAsync(Guid fileId);

        // Knowledge Node Management (Catalog)
        Task<List<KbNodeDto>> GetKbNodesAsync(Guid kbId);
        Task<KbNodeDto?> GetNodeDetailAsync(string key);

        // Chat
        Task<List<ChatMessageDto>> GetChatHistoryAsync(Guid kbId, Guid? userId);
        Task<bool> DeleteChatHistoryAsync(Guid kbId, Guid? userId);
        Task<bool> DeleteKbQaHistoryAsync(Guid id);
        Task<ChatMessageDto> SendMessageAsync(SendMessageDto dto, Guid? userId);
        IAsyncEnumerable<string> SendMessageStreamAsync(SendMessageDto dto, Guid? userId);
        Task<List<SiliconModelDto>> GetAvailableModelsAsync();
    }
}
