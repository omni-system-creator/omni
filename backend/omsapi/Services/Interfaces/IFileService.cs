using omsapi.Models.Dtos;

namespace omsapi.Services.Interfaces
{
    public interface IFileService
    {
        Task<(bool Success, string Message, List<FileDto>? Data)> GetFilesAsync(FileQueryDto query, long currentUserId);
        Task<(bool Success, string Message, FileDto? Data)> GetFileByIdAsync(long id);
        Task<(bool Success, string Message, FileDto? Data)> CreateFolderAsync(CreateFolderDto dto, long ownerId);
        Task<(bool Success, string Message, FileDto? Data)> UploadFileAsync(IFormFile file, long? parentId, long ownerId, long? deptId, bool isPublic = false);
        Task<(bool Success, string Message)> UpdateFileAsync(long id, UpdateFileDto dto, long currentUserId);
        Task<(bool Success, string Message)> DeleteFileAsync(long id, long ownerId); // Should also verify owner or permission
        Task<(bool Success, string Message)> RenameFileAsync(long id, RenameFileDto dto, long ownerId);
        Task<(bool Success, string Message, string? ContentType, Stream? FileStream, string? FileName)> DownloadFileAsync(long id, long ownerId);
        
        // Share methods
        Task<(bool Success, string Message)> ShareFileAsync(ShareFileDto dto, long currentUserId);
        Task<(bool Success, string Message, List<FileShareDto>? Data)> GetSharedWithMeAsync(long currentUserId);
        Task<(bool Success, string Message, List<FileShareDto>? Data)> GetMySharedFilesAsync(long currentUserId);
        
        // Public Share
        Task<(bool Success, string Message, FileShareDto? Data)> GetPublicShareByTokenAsync(string token);
        Task<(bool Success, string Message, string? ContentType, Stream? FileStream, string? FileName)> DownloadPublicShareAsync(string token);
    }
}
