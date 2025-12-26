using omsapi.Models.Dtos;

namespace omsapi.Services.Interfaces
{
    public interface IUserService
    {
        Task<(bool Success, string Message, string? AvatarUrl)> UploadAvatarAsync(long userId, IFormFile file);
        Task<(bool Success, string Message, UserDto? Data)> GetCurrentUserAsync(long userId);
        Task<(bool Success, string Message)> UpdateProfileAsync(long userId, UpdateProfileDto dto);
        Task<(bool Success, string Message)> ChangePasswordAsync(long userId, ChangePasswordDto dto);
        
        // 管理员接口
        Task<(bool Success, string Message, List<UserListDto>? Data)> GetAllUsersAsync();
        Task<(bool Success, string Message, UserListDto? Data)> GetUserByIdAsync(long id);
        Task<(bool Success, string Message)> CreateUserAsync(CreateUserDto dto);
        Task<(bool Success, string Message)> UpdateUserAsync(long id, UpdateUserDto dto);
        Task<(bool Success, string Message)> DeleteUserAsync(long id);
        Task<(bool Success, string Message)> ResetPasswordAsync(long id, string newPassword);

        // 权限辅助接口
        Task<(bool IsAdmin, List<long> RoleIds)> GetUserPermissionsAsync(long? userId);
    }
}