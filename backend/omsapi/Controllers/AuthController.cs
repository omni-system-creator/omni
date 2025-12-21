using Microsoft.AspNetCore.Authorization;
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

        [HttpGet("routes")]
        [Authorize]
        public async Task<ApiResponse<List<MenuItemDto>>> GetRoutes()
        {
            var userIdClaim = User.FindFirst("id");
            if (userIdClaim == null || !long.TryParse(userIdClaim.Value, out long userId))
            {
                return ApiResponse<List<MenuItemDto>>.Error("无法获取用户信息", 401);
            }

            var (success, message, data) = await _authService.GetUserRoutesAsync(userId);
            if (!success) return ApiResponse<List<MenuItemDto>>.Error(message);
            return ApiResponse<List<MenuItemDto>>.Success(data!);
        }

        [HttpGet("permissions")]
        [Authorize]
        public async Task<ApiResponse<List<string>>> GetPermissions()
        {
            var userIdClaim = User.FindFirst("id");
            if (userIdClaim == null || !long.TryParse(userIdClaim.Value, out long userId))
            {
                return ApiResponse<List<string>>.Error("无法获取用户信息", 401);
            }

            var (success, message, data) = await _authService.GetUserPermissionsAsync(userId);
            if (!success) return ApiResponse<List<string>>.Error(message);
            return ApiResponse<List<string>>.Success(data!);
        }
    }
}
