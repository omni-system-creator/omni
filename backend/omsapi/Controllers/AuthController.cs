using Microsoft.AspNetCore.Mvc;
using omsapi.Models.Common;
using omsapi.Models.Dtos;
using omsapi.Services.Interfaces;

namespace omsapi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        [HttpPost("login")]
        public async Task<ApiResponse<object>> Login([FromBody] LoginRequest request)
        {
            var (success, message, data) = await _authService.LoginAsync(request);

            if (!success)
            {
                return ApiResponse<object>.Error(message, 400);
            }

            return ApiResponse<object>.Success(data);
        }
    }
}
