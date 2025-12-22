using omsapi.Models.Dtos.Archive;

namespace omsapi.Services.Interfaces
{
    public interface IArchiveService
    {
        // Fond Management
        Task<(bool Success, string Message, List<ArchFondDto>? Data)> GetFondsAsync();
        Task<(bool Success, string Message, ArchFondDto? Data)> CreateFondAsync(CreateFondDto dto);
        Task<(bool Success, string Message)> UpdateFondAsync(long id, UpdateFondDto dto);
        Task<(bool Success, string Message)> DeleteFondAsync(long id);

        // Type/Category Management
        Task<(bool Success, string Message, List<ArchTypeDto>? Data)> GetTypesAsync();
        Task<(bool Success, string Message, ArchTypeDto? Data)> CreateTypeAsync(CreateArchTypeDto dto);
        Task<(bool Success, string Message)> UpdateTypeAsync(long id, UpdateArchTypeDto dto);
        Task<(bool Success, string Message)> DeleteTypeAsync(long id);
        
        // Archive File Management
        Task<(bool Success, string Message, List<ArchFileDto>? Data)> GetArchFilesAsync(ArchQueryDto query);
        Task<(bool Success, string Message, ArchFileDto? Data)> GetArchFileByIdAsync(long id);
        Task<(bool Success, string Message, ArchFileDto? Data)> CreateArchFileAsync(CreateArchFileDto dto, long currentUserId);
        Task<(bool Success, string Message)> UpdateArchFileAsync(long id, UpdateArchFileDto dto);
        Task<(bool Success, string Message)> DeleteArchFileAsync(long id);
        
        // Box Management
        // Task<(bool Success, string Message, List<ArchBoxDto>? Data)> GetBoxesAsync(long fondId, long typeId);
    }
}