using omsapi.Models.Dtos;

namespace omsapi.Services.Interfaces
{
    public interface IUserService
    {
        Task<(bool Success, string Message, string? AvatarUrl)> UploadAvatarAsync(long userId, IFormFile file);
        Task<(bool Success, string Message, UserDto? Data)> GetCurrentUserAsync(long userId);
        Task<(bool Success, string Message)> UpdateProfileAsync(long userId, UpdateProfileDto dto);
        Task<(bool Success, string Message)> ChangePasswordAsync(long userId, ChangePasswordDto dto);
    }
}