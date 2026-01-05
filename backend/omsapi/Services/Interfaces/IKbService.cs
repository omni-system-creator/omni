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
        Task<bool> DeleteKbAsync(Guid id);

        // File Management
        Task<List<KbFileDto>> GetKbFilesAsync(Guid kbId);
        Task<KbFileDto> UploadFileAsync(Guid kbId, IFormFile file);
        Task<bool> DeleteFileAsync(Guid fileId);

        // Knowledge Node Management (Catalog)
        Task<List<KbNodeDto>> GetKbNodesAsync(Guid kbId);
        Task<KbNodeDto?> GetNodeDetailAsync(string key);

        // Chat
        Task<List<ChatMessageDto>> GetChatHistoryAsync(Guid kbId, Guid? userId);
        Task<ChatMessageDto> SendMessageAsync(SendMessageDto dto, Guid? userId);
    }
}
