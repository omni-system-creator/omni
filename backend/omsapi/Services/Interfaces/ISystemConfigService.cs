using omsapi.Models.Dtos;

namespace omsapi.Services.Interfaces
{
    public interface ISystemConfigService
    {
        Task<(bool Success, string Message, List<SystemConfigDto>? Data)> GetAllConfigsAsync();
        Task<(bool Success, string Message, SystemConfigDto? Data)> GetConfigByKeyAsync(string key);
        Task<(bool Success, string Message)> UpdateConfigAsync(long id, UpdateSystemConfigDto dto);
        Task<(bool Success, string Message)> DeleteConfigAsync(long id);
    }
}
