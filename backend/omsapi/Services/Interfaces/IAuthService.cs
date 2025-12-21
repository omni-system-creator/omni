using omsapi.Models.Dtos;

namespace omsapi.Services.Interfaces
{
    public interface IAuthService
    {
        Task<(bool Success, string Message, LoginResultDto? Data)> LoginAsync(LoginRequest request);
        Task<(bool Success, string Message, List<MenuItemDto>? Data)> GetUserRoutesAsync(long userId);
        Task<(bool Success, string Message, List<string>? Data)> GetUserPermissionsAsync(long userId);
    }
}