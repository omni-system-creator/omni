using omsapi.Models.Dtos;

namespace omsapi.Services.Interfaces
{
    public interface IUserConfigService
    {
        Task<(bool Success, string Message, List<UserConfigDto>? Data)> GetConfigsAsync(string? prefix = null);
        Task<(bool Success, string Message)> SetConfigAsync(UserConfigDto dto);
        Task<(bool Success, string Message)> DeleteConfigAsync(string key);
    }
}
