using omsapi.Models.Dtos;

namespace omsapi.Services.Interfaces
{
    public interface IAuthService
    {
        Task<(bool Success, string Message, LoginResultDto? Data)> LoginAsync(LoginRequest request);
    }
}